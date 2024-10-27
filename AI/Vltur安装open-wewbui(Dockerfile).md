# Vltur安装open-webui和ollama



## 准备工作

1. 连接到Vltur

   ```
   ssh root@66.42.39.135
   ```

   

2. 安装docker

   [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

   ```
   for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
   ```

   ```
   # Add Docker's official GPG key:
   sudo apt-get update
   sudo apt-get install ca-certificates curl
   sudo install -m 0755 -d /etc/apt/keyrings
   sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
   sudo chmod a+r /etc/apt/keyrings/docker.asc
   
   # Add the repository to Apt sources:
   echo \
     "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
     $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
     sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   sudo apt-get update
   ```

   ```
   sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
   ```

   ```
   sudo docker run hello-world
   ```

## Docker安装ollama

- 仅CPU

  ```
  docker run -d -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama
  ```

- 其他

  ```
  https://hub.docker.com/r/ollama/ollama
  ```

- ollama项目地址和官方地址

  ```
  https://github.com/ollama/ollama
  https://ollama.com/
  ```

  



## 安装open-webui

1. 使用官方dockerfile编译

   ```
   mkdir webui
   cd webui
   git clone https://github.com/open-webui/open-webui.git
   ```

   ```
   cd open-webui
   docker build -t webui:v1 .
   ```

   ```
   # 基础镜像
   FROM dyrnq/open-webui:main
   
   # 设置环境变量
   ENV PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
   ENV LANG=C.UTF-8
   ENV GPG_KEY=A035C8C19219BA821ECEA86B64E628F8D684696D
   ENV PYTHON_VERSION=3.11.10
   ENV PYTHON_SHA256=07a4356e912900e61a15cb0949a06c4a05012e213ecd6b4e84d0f67aabbee372
   ENV ENV=prod
   ENV PORT=8080
   ENV USE_OLLAMA_DOCKER=true
   #ENV USE_OLLAMA_DOCKER=false
   ENV USE_CUDA_DOCKER=false
   ENV OLLAMA_BASE_URL=/ollama
   ENV OPENAI_API_BASE_URL=
   ENV OPENAI_API_KEY=
   ENV WEBUI_SECRET_KEY=
   ENV SCARF_NO_ANALYTICS=true
   ENV DO_NOT_TRACK=true
   ENV WHISPER_MODEL=base
   ENV WHISPER_MODEL_DIR=/app/backend/data/cache/whisper/models
   ENV RAG_EMBEDDING_MODEL=sentence-transformers/all-MiniLM-L6-v2
   ENV RAG_RERANKING_MODEL=
   ENV SENTENCE_TRANSFORMERS_HOME=/app/backend/data/cache/embedding/models
   ENV TIKTOKEN_ENCODING_NAME=cl100k_base
   ENV TIKTOKEN_CACHE_DIR=/app/backend/data/cache/tiktoken
   ENV HF_HOME=/app/backend/data/cache/embedding/models
   ENV HOME=/root
   ENV WEBUI_BUILD_VERSION=d056923479defa91de3fb51341b71a5e4160d725
   ENV DOCKER=true
   
   # 工作目录
   WORKDIR /app/backend
   
   # 拷贝文件
   COPY --chown=0:0 ./backend/requirements.txt ./requirements.txt
   COPY --chown=0:0 /app/build /app/build
   COPY --chown=0:0 /app/CHANGELOG.md /app/CHANGELOG.md
   COPY --chown=0:0 /app/package.json /app/package.json
   COPY --chown=0:0 ./backend .
   
   # 暴露端口
   EXPOSE 8080
   
   # 健康检查
   HEALTHCHECK CMD curl --silent --fail http://localhost:8080/health || exit 1
   
   # 用户设置
   USER 0:0
   
   # 启动命令
   CMD ["bash", "start.sh"]
   ```

   ```
   # syntax=docker/dockerfile:1
   # Initialize device type args
   # use build args in the docker build command with --build-arg="BUILDARG=true"
   ARG USE_CUDA=false
   ARG USE_OLLAMA=false
   # Tested with cu117 for CUDA 11 and cu121 for CUDA 12 (default)
   ARG USE_CUDA_VER=cu121
   # any sentence transformer model; models to use can be found at https://huggingface.co/models?library=sentence-transformers
   # Leaderboard: https://huggingface.co/spaces/mteb/leaderboard 
   # for better performance and multilangauge support use "intfloat/multilingual-e5-large" (~2.5GB) or "intfloat/multilingual-e5-base" (~1.5GB)
   # IMPORTANT: If you change the embedding model (sentence-transformers/all-MiniLM-L6-v2) and vice versa, you aren't able to use RAG Chat with your previous documents loaded in the WebUI! You need to re-embed them.
   ARG USE_EMBEDDING_MODEL=intfloat/multilingual-e5-large
   #ARG USE_EMBEDDING_MODEL=sentence-transformers/all-MiniLM-L6-v2
   ARG USE_RERANKING_MODEL=""
   
   # Tiktoken encoding name; models to use can be found at https://huggingface.co/models?library=tiktoken
   ARG USE_TIKTOKEN_ENCODING_NAME="cl100k_base"
   
   ARG BUILD_HASH=dev-build
   # Override at your own risk - non-root configurations are untested
   ARG UID=0
   ARG GID=0
   
   ######## WebUI frontend ########
   FROM --platform=$BUILDPLATFORM node:22-alpine3.20 AS build
   ARG BUILD_HASH
   
   WORKDIR /app
   
   COPY package.json package-lock.json ./
   RUN npm ci
   
   COPY . .
   ENV APP_BUILD_HASH=${BUILD_HASH}
   RUN npm run build
   
   ######## WebUI backend ########
   FROM python:3.11-slim-bookworm AS base
   
   # Use args
   ARG USE_CUDA
   ARG USE_OLLAMA
   ARG USE_CUDA_VER
   ARG USE_EMBEDDING_MODEL
   ARG USE_RERANKING_MODEL
   ARG UID
   ARG GID
   
   ## Basis ##
   ENV ENV=prod \
       PORT=8080 \
       # pass build args to the build
       USE_OLLAMA_DOCKER=${USE_OLLAMA} \
       USE_CUDA_DOCKER=${USE_CUDA} \
       USE_CUDA_DOCKER_VER=${USE_CUDA_VER} \
       USE_EMBEDDING_MODEL_DOCKER=${USE_EMBEDDING_MODEL} \
       USE_RERANKING_MODEL_DOCKER=${USE_RERANKING_MODEL}
   
   ## Basis URL Config ##
   ENV OLLAMA_BASE_URL="/ollama" \
       OPENAI_API_BASE_URL=""
   
   ## API Key and Security Config ##
   ENV OPENAI_API_KEY="" \
       WEBUI_SECRET_KEY="" \
       SCARF_NO_ANALYTICS=true \
       DO_NOT_TRACK=true \
       ANONYMIZED_TELEMETRY=false
   
   #### Other models #########################################################
   ## whisper TTS model settings ##
   ENV WHISPER_MODEL="base" \
       WHISPER_MODEL_DIR="/app/backend/data/cache/whisper/models"
   
   ## RAG Embedding model settings ##
   ENV RAG_EMBEDDING_MODEL="$USE_EMBEDDING_MODEL_DOCKER" \
       RAG_RERANKING_MODEL="$USE_RERANKING_MODEL_DOCKER" \
       SENTENCE_TRANSFORMERS_HOME="/app/backend/data/cache/embedding/models"
   
   ## Tiktoken model settings ##
   ENV TIKTOKEN_ENCODING_NAME="cl100k_base" \
       TIKTOKEN_CACHE_DIR="/app/backend/data/cache/tiktoken"
   
   ## Hugging Face download cache ##
   ENV HF_HOME="/app/backend/data/cache/embedding/models"
   
   ## Torch Extensions ##
   # ENV TORCH_EXTENSIONS_DIR="/.cache/torch_extensions"
   
   #### Other models ##########################################################
   
   WORKDIR /app/backend
   
   ENV HOME=/root
   # Create user and group if not root
   RUN if [ $UID -ne 0 ]; then \
       if [ $GID -ne 0 ]; then \
       addgroup --gid $GID app; \
       fi; \
       adduser --uid $UID --gid $GID --home $HOME --disabled-password --no-create-home app; \
       fi
   
   RUN mkdir -p $HOME/.cache/chroma
   RUN echo -n 00000000-0000-0000-0000-000000000000 > $HOME/.cache/chroma/telemetry_user_id
   
   # Make sure the user has access to the app and root directory
   RUN chown -R $UID:$GID /app $HOME
   
   RUN if [ "$USE_OLLAMA" = "true" ]; then \
       apt-get update && \
       # Install pandoc and netcat
       apt-get install -y --no-install-recommends git build-essential pandoc netcat-openbsd curl && \
       apt-get install -y --no-install-recommends gcc python3-dev && \
       # for RAG OCR
       apt-get install -y --no-install-recommends ffmpeg libsm6 libxext6 && \
       # install helper tools
       apt-get install -y --no-install-recommends curl jq && \
       # install ollama
       curl -fsSL https://ollama.com/install.sh | sh && \
       # cleanup
       rm -rf /var/lib/apt/lists/*; \
       else \
       apt-get update && \
       # Install pandoc, netcat and gcc
       apt-get install -y --no-install-recommends git build-essential pandoc gcc netcat-openbsd curl jq && \
       apt-get install -y --no-install-recommends gcc python3-dev && \
       # for RAG OCR
       apt-get install -y --no-install-recommends ffmpeg libsm6 libxext6 && \
       # cleanup
       rm -rf /var/lib/apt/lists/*; \
       fi
   
   # install python dependencies
   COPY --chown=$UID:$GID ./backend/requirements.txt ./requirements.txt
   
   RUN pip3 install uv && \
       if [ "$USE_CUDA" = "true" ]; then \
       # If you use CUDA the whisper and embedding model will be downloaded on first use
       pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/$USE_CUDA_DOCKER_VER --no-cache-dir && \
       uv pip install --system -r requirements.txt --no-cache-dir && \
       python -c "import os; from sentence_transformers import SentenceTransformer; SentenceTransformer(os.environ['RAG_EMBEDDING_MODEL'], device='cpu')" && \
       python -c "import os; from faster_whisper import WhisperModel; WhisperModel(os.environ['WHISPER_MODEL'], device='cpu', compute_type='int8', download_root=os.environ['WHISPER_MODEL_DIR'])"; \
       python -c "import os; import tiktoken; tiktoken.get_encoding(os.environ['TIKTOKEN_ENCODING_NAME'])"; \
       else \
       pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu --no-cache-dir && \
       uv pip install --system -r requirements.txt --no-cache-dir && \
       python -c "import os; from sentence_transformers import SentenceTransformer; SentenceTransformer(os.environ['RAG_EMBEDDING_MODEL'], device='cpu')" && \
       python -c "import os; from faster_whisper import WhisperModel; WhisperModel(os.environ['WHISPER_MODEL'], device='cpu', compute_type='int8', download_root=os.environ['WHISPER_MODEL_DIR'])"; \
       python -c "import os; import tiktoken; tiktoken.get_encoding(os.environ['TIKTOKEN_ENCODING_NAME'])"; \
       fi; \
       chown -R $UID:$GID /app/backend/data/
   
   
   
   # copy embedding weight from build
   # RUN mkdir -p /root/.cache/chroma/onnx_models/all-MiniLM-L6-v2
   # COPY --from=build /app/onnx /root/.cache/chroma/onnx_models/all-MiniLM-L6-v2/onnx
   
   # copy built frontend files
   COPY --chown=$UID:$GID --from=build /app/build /app/build
   COPY --chown=$UID:$GID --from=build /app/CHANGELOG.md /app/CHANGELOG.md
   COPY --chown=$UID:$GID --from=build /app/package.json /app/package.json
   
   # copy backend files
   COPY --chown=$UID:$GID ./backend .
   
   EXPOSE 8080
   
   HEALTHCHECK CMD curl --silent --fail http://localhost:${PORT:-8080}/health | jq -ne 'input.status == true' || exit 1
   
   USER $UID:$GID
   
   ARG BUILD_HASH
   ENV WEBUI_BUILD_VERSION=${BUILD_HASH}
   ENV DOCKER=true
   
   CMD [ "bash", "start.sh"]
   ```

   