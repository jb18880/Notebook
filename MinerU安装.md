# MinerU安装

> [!NOTE]
>
> 服务器配置：Ubuntu2204

### 安装Anaconda

1. 安装依赖

   ```
   apt-get install libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6
   ```

2. 下载安装包

   ```
   wget https://repo.anaconda.com/archive/Anaconda3-2024.06-1-Linux-x86_64.sh
   ```

3. 校验安装包

   ```
   shasum -a 256 Anaconda3-2024.06-1-Linux-x86_64.sh | grep 539bb43d9a52d758d0fdfa1b1b049920ec6f8c6d15ee9fe4a423355fe551a8f7
   ```

4. 安装

   ```
   bash Anaconda3-2024.06-1-Linux-x86_64.sh
   ```

   - 开始安装

     ```
     ENTER
     ```

   - 是否同意条款

     ```
     yes
     ```
   
   - 指定安装路径
   
     ```
     ENTER
     #默认安装路径
     ```

   - 是否每次打开Terminal的时候自动打开base虚拟环境

     ```
     yes
     ```
   
        > [!NOTE]
        >
        > ```
        > # The base environment is activated by default
        > conda config --set auto_activate_base True
        > 
        > # The base environment is not activated by default
        > conda config --set auto_activate_base False
        > ```
   
   - 刷新~/.bashrc配置
   
     ```
     source ~/.bashrc
     ```

### 配置MinerU虚拟环境

```
conda create -n MinerU python=3.10
conda activate MinerU
```

### 安装配置

#### 1. 安装Magic-PDF

```
pip install magic-pdf[full-cpu]
```

```
magic-pdf --version
```

```
pip install detectron2 --extra-index-url https://myhloli.github.io/wheels/
```

#### 2. 下载模型权重文件

##### 安装 Git LFS

1. 添加仓库

   ```
   (. /etc/lsb-release &&
   curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh |
   sudo env os=ubuntu dist="${DISTRIB_CODENAME}" bash)
   ```

2. 安装

   ```
   sudo apt-get install git-lfs
   ```

##### 初始化 Git LFS

```
git lfs install
```

##### 从 Hugging Face 下载模型

```
#git lfs clone https://huggingface.co/wanderkid/PDF-Extract-Kit
git clone https://www.modelscope.cn/wanderkid/PDF-Extract-Kit.git
```

#### 3. 拷贝配置文件并进行配置

在仓库根目录可以获得 [magic-pdf.template.json](https://github.com/opendatalab/MinerU/blob/master/magic-pdf.template.json) 配置模版文件

```
wget -c "https://github.com/opendatalab/MinerU/blob/master/magic-pdf.template.json" -O ~/magic-pdf.json
```

修改`magic-pdf.json`的模型路径

```
{
  "models-dir": "/root/PDF-Extract-Kit/models"
}
```

#### 4. 使用CUDA或MPS加速推理

跳过



### 使用

```
magic-pdf pdf-command --pdf "/root/test-doc.pdf" --inside_model true
```





失败了

```
(MinerU) root@vultr:~# magic-pdf pdf-command --pdf "/root/test-doc.pdf" --inside_model true
2024-07-30 10:08:30.315 | WARNING  | magic_pdf.cli.magicpdf:get_model_json:310 - not found json /root/test-doc.json existed
2024-07-30 10:08:30.317 | INFO     | magic_pdf.cli.magicpdf:do_parse:91 - local output dir is /tmp/magic-pdf/test-doc/auto
[2024-07-30 10:08:36,394][INFO] - Downloading https://dl.fbaipublicfiles.com/fasttext/supervised-models/lid.176.ftz to lid.176.ftz (916.0K)
100%|█████████████████████████████████████████████████████████████████████████████████████| 916k/916k [00:01<00:00, 594kB/s]
2024-07-30 10:08:39.729 | INFO     | magic_pdf.libs.pdf_check:detect_invalid_chars:57 - cid_count: 0, text_len: 7654, cid_chars_radio: 0.0
2024-07-30 10:08:39.743 | WARNING  | magic_pdf.filter.pdf_classify_by_type:classify:334 - pdf is not classified by area and text_len, by_image_area: False, by_text: True, by_avg_words: True, by_img_num: True, by_text_layout: True, by_img_narrow_strips: True, by_invalid_chars: True
2024-07-30 10:08:49.000 | INFO     | magic_pdf.model.pdf_extract_kit:__init__:92 - DocAnalysis init, this may take some times. apply_layout: True, apply_formula: True, apply_ocr: True
2024-07-30 10:08:49.001 | INFO     | magic_pdf.model.pdf_extract_kit:__init__:100 - using device: cpu
CustomVisionEncoderDecoderModel init
CustomMBartForCausalLM init
CustomMBartDecoder init
[07/30 10:09:37 detectron2]: Rank of current process: 0. World size: 1
[07/30 10:09:43 detectron2]: Environment info:
-------------------------------  ----------------------------------------------------------------------------------
sys.platform                     linux
Python                           3.10.14 (main, May  6 2024, 19:42:50) [GCC 11.2.0]
numpy                            1.26.4
detectron2                       0.6 @/root/anaconda3/envs/MinerU/lib/python3.10/site-packages/detectron2
Compiler                         GCC 11.4
CUDA compiler                    not available
DETECTRON2_ENV_MODULE            <not set>
PyTorch                          2.3.1+cu121 @/root/anaconda3/envs/MinerU/lib/python3.10/site-packages/torch
PyTorch debug build              False
torch._C._GLIBCXX_USE_CXX11_ABI  False
GPU available                    No: torch.cuda.is_available() == False
Pillow                           10.4.0
torchvision                      0.18.1+cu121 @/root/anaconda3/envs/MinerU/lib/python3.10/site-packages/torchvision
fvcore                           0.1.5.post20221221
iopath                           0.1.9
cv2                              4.6.0
-------------------------------  ----------------------------------------------------------------------------------
PyTorch built with:
  - GCC 9.3
  - C++ Version: 201703
  - Intel(R) oneAPI Math Kernel Library Version 2022.2-Product Build 20220804 for Intel(R) 64 architecture applications
  - Intel(R) MKL-DNN v3.3.6 (Git Hash 86e6af5974177e513fd3fee58425e1063e7f1361)
  - OpenMP 201511 (a.k.a. OpenMP 4.5)
  - LAPACK is enabled (usually provided by MKL)
  - NNPACK is enabled
  - CPU capability usage: AVX512
  - Build settings: BLAS_INFO=mkl, BUILD_TYPE=Release, CUDA_VERSION=12.1, CUDNN_VERSION=8.9.2, CXX_COMPILER=/opt/rh/devtoolset-9/root/usr/bin/c++, CXX_FLAGS= -D_GLIBCXX_USE_CXX11_ABI=0 -fabi-version=11 -fvisibility-inlines-hidden -DUSE_PTHREADPOOL -DNDEBUG -DUSE_KINETO -DLIBKINETO_NOROCTRACER -DUSE_FBGEMM -DUSE_QNNPACK -DUSE_PYTORCH_QNNPACK -DUSE_XNNPACK -DSYMBOLICATE_MOBILE_DEBUG_HANDLE -O2 -fPIC -Wall -Wextra -Werror=return-type -Werror=non-virtual-dtor -Werror=bool-operation -Wnarrowing -Wno-missing-field-initializers -Wno-type-limits -Wno-array-bounds -Wno-unknown-pragmas -Wno-unused-parameter -Wno-unused-function -Wno-unused-result -Wno-strict-overflow -Wno-strict-aliasing -Wno-stringop-overflow -Wsuggest-override -Wno-psabi -Wno-error=pedantic -Wno-error=old-style-cast -Wno-missing-braces -fdiagnostics-color=always -faligned-new -Wno-unused-but-set-variable -Wno-maybe-uninitialized -fno-math-errno -fno-trapping-math -Werror=format -Wno-stringop-overflow, LAPACK_INFO=mkl, PERF_WITH_AVX=1, PERF_WITH_AVX2=1, PERF_WITH_AVX512=1, TORCH_VERSION=2.3.1, USE_CUDA=ON, USE_CUDNN=ON, USE_CUSPARSELT=1, USE_EXCEPTION_PTR=1, USE_GFLAGS=OFF, USE_GLOG=OFF, USE_GLOO=ON, USE_MKL=ON, USE_MKLDNN=ON, USE_MPI=OFF, USE_NCCL=1, USE_NNPACK=ON, USE_OPENMP=ON, USE_ROCM=OFF, USE_ROCM_KERNEL_ASSERT=OFF, 

[07/30 10:09:43 detectron2]: Command line arguments: {'config_file': '/root/anaconda3/envs/MinerU/lib/python3.10/site-packages/magic_pdf/resources/model_config/layoutlmv3/layoutlmv3_base_inference.yaml', 'resume': False, 'eval_only': False, 'num_gpus': 1, 'num_machines': 1, 'machine_rank': 0, 'dist_url': 'tcp://127.0.0.1:57823', 'opts': ['MODEL.WEIGHTS', '/root/PDF-Extract-Kit/models/Layout/model_final.pth']}
[07/30 10:09:43 detectron2]: Contents of args.config_file=/root/anaconda3/envs/MinerU/lib/python3.10/site-packages/magic_pdf/resources/model_config/layoutlmv3/layoutlmv3_base_inference.yaml:
AUG:
  DETR: true
CACHE_DIR: /mnt/localdata/users/yupanhuang/cache/huggingface
CUDNN_BENCHMARK: false
DATALOADER:
  ASPECT_RATIO_GROUPING: true
  FILTER_EMPTY_ANNOTATIONS: false
  NUM_WORKERS: 4
  REPEAT_THRESHOLD: 0.0
  SAMPLER_TRAIN: TrainingSampler
DATASETS:
  PRECOMPUTED_PROPOSAL_TOPK_TEST: 1000
  PRECOMPUTED_PROPOSAL_TOPK_TRAIN: 2000
  PROPOSAL_FILES_TEST: []
  PROPOSAL_FILES_TRAIN: []
  TEST:
  - scihub_train
  TRAIN:
  - scihub_train
GLOBAL:
  HACK: 1.0
ICDAR_DATA_DIR_TEST: ''
ICDAR_DATA_DIR_TRAIN: ''
INPUT:
  CROP:
    ENABLED: true
    SIZE:
    - 384
    - 600
    TYPE: absolute_range
  FORMAT: RGB
  MASK_FORMAT: polygon
  MAX_SIZE_TEST: 1333
  MAX_SIZE_TRAIN: 1333
  MIN_SIZE_TEST: 800
  MIN_SIZE_TRAIN:
  - 480
  - 512
  - 544
  - 576
  - 608
  - 640
  - 672
  - 704
  - 736
  - 768
  - 800
  MIN_SIZE_TRAIN_SAMPLING: choice
  RANDOM_FLIP: horizontal
MODEL:
  ANCHOR_GENERATOR:
    ANGLES:
    - - -90
      - 0
      - 90
    ASPECT_RATIOS:
    - - 0.5
      - 1.0
      - 2.0
    NAME: DefaultAnchorGenerator
    OFFSET: 0.0
    SIZES:
    - - 32
    - - 64
    - - 128
    - - 256
    - - 512
  BACKBONE:
    FREEZE_AT: 2
    NAME: build_vit_fpn_backbone
  CONFIG_PATH: ''
  DEVICE: cuda
  FPN:
    FUSE_TYPE: sum
    IN_FEATURES:
    - layer3
    - layer5
    - layer7
    - layer11
    NORM: ''
    OUT_CHANNELS: 256
  IMAGE_ONLY: true
  KEYPOINT_ON: false
  LOAD_PROPOSALS: false
  MASK_ON: true
  META_ARCHITECTURE: VLGeneralizedRCNN
  PANOPTIC_FPN:
    COMBINE:
      ENABLED: true
      INSTANCES_CONFIDENCE_THRESH: 0.5
      OVERLAP_THRESH: 0.5
      STUFF_AREA_LIMIT: 4096
    INSTANCE_LOSS_WEIGHT: 1.0
  PIXEL_MEAN:
  - 127.5
  - 127.5
  - 127.5
  PIXEL_STD:
  - 127.5
  - 127.5
  - 127.5
  PROPOSAL_GENERATOR:
    MIN_SIZE: 0
    NAME: RPN
  RESNETS:
    DEFORM_MODULATED: false
    DEFORM_NUM_GROUPS: 1
    DEFORM_ON_PER_STAGE:
    - false
    - false
    - false
    - false
    DEPTH: 50
    NORM: FrozenBN
    NUM_GROUPS: 1
    OUT_FEATURES:
    - res4
    RES2_OUT_CHANNELS: 256
    RES5_DILATION: 1
    STEM_OUT_CHANNELS: 64
    STRIDE_IN_1X1: true
    WIDTH_PER_GROUP: 64
  RETINANET:
    BBOX_REG_LOSS_TYPE: smooth_l1
    BBOX_REG_WEIGHTS:
    - 1.0
    - 1.0
    - 1.0
    - 1.0
    FOCAL_LOSS_ALPHA: 0.25
    FOCAL_LOSS_GAMMA: 2.0
    IN_FEATURES:
    - p3
    - p4
    - p5
    - p6
    - p7
    IOU_LABELS:
    - 0
    - -1
    - 1
    IOU_THRESHOLDS:
    - 0.4
    - 0.5
    NMS_THRESH_TEST: 0.5
    NORM: ''
    NUM_CLASSES: 10
    NUM_CONVS: 4
    PRIOR_PROB: 0.01
    SCORE_THRESH_TEST: 0.05
    SMOOTH_L1_LOSS_BETA: 0.1
    TOPK_CANDIDATES_TEST: 1000
  ROI_BOX_CASCADE_HEAD:
    BBOX_REG_WEIGHTS:
    - - 10.0
      - 10.0
      - 5.0
      - 5.0
    - - 20.0
      - 20.0
      - 10.0
      - 10.0
    - - 30.0
      - 30.0
      - 15.0
      - 15.0
    IOUS:
    - 0.5
    - 0.6
    - 0.7
  ROI_BOX_HEAD:
    BBOX_REG_LOSS_TYPE: smooth_l1
    BBOX_REG_LOSS_WEIGHT: 1.0
    BBOX_REG_WEIGHTS:
    - 10.0
    - 10.0
    - 5.0
    - 5.0
    CLS_AGNOSTIC_BBOX_REG: true
    CONV_DIM: 256
    FC_DIM: 1024
    NAME: FastRCNNConvFCHead
    NORM: ''
    NUM_CONV: 0
    NUM_FC: 2
    POOLER_RESOLUTION: 7
    POOLER_SAMPLING_RATIO: 0
    POOLER_TYPE: ROIAlignV2
    SMOOTH_L1_BETA: 0.0
    TRAIN_ON_PRED_BOXES: false
  ROI_HEADS:
    BATCH_SIZE_PER_IMAGE: 512
    IN_FEATURES:
    - p2
    - p3
    - p4
    - p5
    IOU_LABELS:
    - 0
    - 1
    IOU_THRESHOLDS:
    - 0.5
    NAME: CascadeROIHeads
    NMS_THRESH_TEST: 0.5
    NUM_CLASSES: 10
    POSITIVE_FRACTION: 0.25
    PROPOSAL_APPEND_GT: true
    SCORE_THRESH_TEST: 0.05
  ROI_KEYPOINT_HEAD:
    CONV_DIMS:
    - 512
    - 512
    - 512
    - 512
    - 512
    - 512
    - 512
    - 512
    LOSS_WEIGHT: 1.0
    MIN_KEYPOINTS_PER_IMAGE: 1
    NAME: KRCNNConvDeconvUpsampleHead
    NORMALIZE_LOSS_BY_VISIBLE_KEYPOINTS: true
    NUM_KEYPOINTS: 17
    POOLER_RESOLUTION: 14
    POOLER_SAMPLING_RATIO: 0
    POOLER_TYPE: ROIAlignV2
  ROI_MASK_HEAD:
    CLS_AGNOSTIC_MASK: false
    CONV_DIM: 256
    NAME: MaskRCNNConvUpsampleHead
    NORM: ''
    NUM_CONV: 4
    POOLER_RESOLUTION: 14
    POOLER_SAMPLING_RATIO: 0
    POOLER_TYPE: ROIAlignV2
  RPN:
    BATCH_SIZE_PER_IMAGE: 256
    BBOX_REG_LOSS_TYPE: smooth_l1
    BBOX_REG_LOSS_WEIGHT: 1.0
    BBOX_REG_WEIGHTS:
    - 1.0
    - 1.0
    - 1.0
    - 1.0
    BOUNDARY_THRESH: -1
    CONV_DIMS:
    - -1
    HEAD_NAME: StandardRPNHead
    IN_FEATURES:
    - p2
    - p3
    - p4
    - p5
    - p6
    IOU_LABELS:
    - 0
    - -1
    - 1
    IOU_THRESHOLDS:
    - 0.3
    - 0.7
    LOSS_WEIGHT: 1.0
    NMS_THRESH: 0.7
    POSITIVE_FRACTION: 0.5
    POST_NMS_TOPK_TEST: 1000
    POST_NMS_TOPK_TRAIN: 2000
    PRE_NMS_TOPK_TEST: 1000
    PRE_NMS_TOPK_TRAIN: 2000
    SMOOTH_L1_BETA: 0.0
  SEM_SEG_HEAD:
    COMMON_STRIDE: 4
    CONVS_DIM: 128
    IGNORE_VALUE: 255
    IN_FEATURES:
    - p2
    - p3
    - p4
    - p5
    LOSS_WEIGHT: 1.0
    NAME: SemSegFPNHead
    NORM: GN
    NUM_CLASSES: 10
  VIT:
    DROP_PATH: 0.1
    IMG_SIZE:
    - 224
    - 224
    NAME: layoutlmv3_base
    OUT_FEATURES:
    - layer3
    - layer5
    - layer7
    - layer11
    POS_TYPE: abs
  WEIGHTS: 
OUTPUT_DIR: 
SCIHUB_DATA_DIR_TRAIN: /mnt/petrelfs/share_data/zhaozhiyuan/publaynet/layout_scihub/train
SEED: 42
SOLVER:
  AMP:
    ENABLED: true
  BACKBONE_MULTIPLIER: 1.0
  BASE_LR: 0.0002
  BIAS_LR_FACTOR: 1.0
  CHECKPOINT_PERIOD: 2000
  CLIP_GRADIENTS:
    CLIP_TYPE: full_model
    CLIP_VALUE: 1.0
    ENABLED: true
    NORM_TYPE: 2.0
  GAMMA: 0.1
  GRADIENT_ACCUMULATION_STEPS: 1
  IMS_PER_BATCH: 32
  LR_SCHEDULER_NAME: WarmupCosineLR
  MAX_ITER: 20000
  MOMENTUM: 0.9
  NESTEROV: false
  OPTIMIZER: ADAMW
  REFERENCE_WORLD_SIZE: 0
  STEPS:
  - 10000
  WARMUP_FACTOR: 0.01
  WARMUP_ITERS: 333
  WARMUP_METHOD: linear
  WEIGHT_DECAY: 0.05
  WEIGHT_DECAY_BIAS: null
  WEIGHT_DECAY_NORM: 0.0
TEST:
  AUG:
    ENABLED: false
    FLIP: true
    MAX_SIZE: 4000
    MIN_SIZES:
    - 400
    - 500
    - 600
    - 700
    - 800
    - 900
    - 1000
    - 1100
    - 1200
  DETECTIONS_PER_IMAGE: 100
  EVAL_PERIOD: 1000
  EXPECTED_RESULTS: []
  KEYPOINT_OKS_SIGMAS: []
  PRECISE_BN:
    ENABLED: false
    NUM_ITER: 200
VERSION: 2
VIS_PERIOD: 0

[07/30 10:09:49 d2.checkpoint.detection_checkpoint]: [DetectionCheckpointer] Loading from /root/PDF-Extract-Kit/models/Layout/model_final.pth ...
[07/30 10:09:49 fvcore.common.checkpoint]: [Checkpointer] Loading from /root/PDF-Extract-Kit/models/Layout/model_final.pth ...
download https://paddleocr.bj.bcebos.com/PP-OCRv4/chinese/ch_PP-OCRv4_det_infer.tar to /root/.paddleocr/whl/det/ch/ch_PP-OCRv4_det_infer/ch_PP-OCRv4_det_infer.tar
100%|██████████████████████████████████████████████████████████████████████████████████| 4.89M/4.89M [00:08<00:00, 572kiB/s]
download https://paddleocr.bj.bcebos.com/PP-OCRv4/chinese/ch_PP-OCRv4_rec_infer.tar to /root/.paddleocr/whl/rec/ch/ch_PP-OCRv4_rec_infer/ch_PP-OCRv4_rec_infer.tar
100%|██████████████████████████████████████████████████████████████████████████████████| 11.0M/11.0M [00:11<00:00, 950kiB/s]
download https://paddleocr.bj.bcebos.com/dygraph_v2.0/ch/ch_ppocr_mobile_v2.0_cls_infer.tar to /root/.paddleocr/whl/cls/ch_ppocr_mobile_v2.0_cls_infer/ch_ppocr_mobile_v2.0_cls_infer.tar
100%|██████████████████████████████████████████████████████████████████████████████████| 2.19M/2.19M [00:07<00:00, 293kiB/s]
2024-07-30 10:10:26.155 | INFO     | magic_pdf.model.pdf_extract_kit:__init__:124 - DocAnalysis init done!
2024-07-30 10:10:26.157 | INFO     | magic_pdf.model.doc_analyze_by_custom_model:doc_analyze:74 - model init cost: 106.41275095939636
Killed
```

使用demo1，又失败了

```
(MinerU) root@vultr:~# magic-pdf pdf-command --pdf "/root/demo1.pdf" --inside_model true
2024-07-30 10:19:07.593 | WARNING  | magic_pdf.cli.magicpdf:get_model_json:310 - not found json /root/demo1.json existed
2024-07-30 10:19:07.594 | INFO     | magic_pdf.cli.magicpdf:do_parse:91 - local output dir is /tmp/magic-pdf/demo1/auto
Traceback (most recent call last):
  File "/root/anaconda3/envs/MinerU/bin/magic-pdf", line 8, in <module>
    sys.exit(cli())
  File "/root/anaconda3/envs/MinerU/lib/python3.10/site-packages/click/core.py", line 1157, in __call__
    return self.main(*args, **kwargs)
  File "/root/anaconda3/envs/MinerU/lib/python3.10/site-packages/click/core.py", line 1078, in main
    rv = self.invoke(ctx)
  File "/root/anaconda3/envs/MinerU/lib/python3.10/site-packages/click/core.py", line 1688, in invoke
    return _process_result(sub_ctx.command.invoke(sub_ctx))
  File "/root/anaconda3/envs/MinerU/lib/python3.10/site-packages/click/core.py", line 1434, in invoke
    return ctx.invoke(self.callback, **ctx.params)
  File "/root/anaconda3/envs/MinerU/lib/python3.10/site-packages/click/core.py", line 783, in invoke
    return __callback(*args, **kwargs)
  File "/root/anaconda3/envs/MinerU/lib/python3.10/site-packages/magic_pdf/cli/magicpdf.py", line 325, in pdf_command
    do_parse(
  File "/root/anaconda3/envs/MinerU/lib/python3.10/site-packages/magic_pdf/cli/magicpdf.py", line 106, in do_parse
    pipe.pipe_classify()
  File "/root/anaconda3/envs/MinerU/lib/python3.10/site-packages/magic_pdf/pipe/UNIPipe.py", line 25, in pipe_classify
    self.pdf_type = AbsPipe.classify(self.pdf_bytes)
  File "/root/anaconda3/envs/MinerU/lib/python3.10/site-packages/magic_pdf/pipe/AbsPipe.py", line 63, in classify
    pdf_meta = pdf_meta_scan(pdf_bytes)
  File "/root/anaconda3/envs/MinerU/lib/python3.10/site-packages/magic_pdf/filter/pdf_meta_scan.py", line 314, in pdf_meta_scan
    doc = fitz.open("pdf", pdf_bytes)
  File "/root/anaconda3/envs/MinerU/lib/python3.10/site-packages/pymupdf/__init__.py", line 2801, in __init__
    doc = mupdf.fz_open_document_with_stream(magic, data)
  File "/root/anaconda3/envs/MinerU/lib/python3.10/site-packages/pymupdf/mupdf.py", line 44296, in fz_open_document_with_stream
    return _mupdf.fz_open_document_with_stream(magic, stream)
pymupdf.mupdf.FzErrorFormat: code=7: no objects found
```

