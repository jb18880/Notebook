# Open-WebUI的安装与配置

#### 1. 安装依赖

- **安装Node.js**：Open-WebUI基于Node.js开发，因此你需要先安装Node.js。建议通过[Node.js官网](https://nodejs.org/)下载并安装最新稳定版。
- **安装Python**：Open-WebUI的后端部分使用Python编写，因此你还需要前往[Python官网](https://www.python.org/)安装Python 3.11或更高版本。
- 安装Git：前往[git官网](https://git-scm.com/downloads)下载git并安装。

- 验证依赖：

  ```powershell
  $ python --version
  Python 3.13.0
  
  $ node -v
  v20.18.0
  
  $ npm -v
  10.8.2
  
  $ git --version
  git version 2.47.0.windows.1
  ```

#### 2. 克隆项目

在Windows终端中，使用Git命令克隆Open-WebUI项目到本地：

```powershell
git clone https://github.com/open-webui/open-webui
```

#### 3. 安装依赖并构建

- **前端**：进入Open-WebUI项目目录，运行`npm install`安装前端依赖，然后执行`npm run build`构建前端项目。

  ```powershell
  $ cd \PATH\TO\open-webui\
  $ npm install
  
  added 833 packages, and audited 834 packages in 2m
  
  175 packages are looking for funding
    run `npm fund` for details
  
  found 0 vulnerabilities
  npm notice
  npm notice New minor version of npm available! 10.8.2 -> 10.9.0
  npm notice Changelog: https://github.com/npm/cli/releases/tag/v10.9.0
  npm notice To update run: npm install -g npm@10.9.0
  npm notice
  
  $ npm run build
  ✓ built in 27.78s
  
  Run npm run preview to preview your production build locally.
  
  > Using @sveltejs/adapter-static
    Wrote site to "build"
    ✔ done
  ```

- **后端**：进入`backend`目录，使用`pip install -r requirements.txt`安装Python依赖。

  ```powershell
  $ cd .\backend\
  
  
  PS C:\Users\v_jinbaohu\open-webui\backend> pip install --upgrade pip setuptools
  Requirement already satisfied: pip in c:\users\v_jinbaohu\appdata\local\programs\python\python313\lib\site-packages (24.2)
  Collecting setuptools
    Using cached setuptools-75.2.0-py3-none-any.whl.metadata (6.9 kB)
  Using cached setuptools-75.2.0-py3-none-any.whl (1.2 MB)
  Installing collected packages: setuptools
  Successfully installed setuptools-75.2.0
  
  #安装pgsql
  #pgsql官网：https://www.enterprisedb.com/downloads/postgres-postgresql-downloads
  #$ pip install psycopg2-binary
  pip install python-pptx==1.0.0
  pip install unstructured
  $ pip install -r requirements.txt
  ```

  

#### 4. 启动服务

在`backend`目录下，执行`start_windows.bat`脚本启动Open-WebUI服务。如果脚本中需要下载模型文件，请确保你的[网络](https://cloud.baidu.com/product/et.html)连接正常，并可能需要配置代理以加速下载。
