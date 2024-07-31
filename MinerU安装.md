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
pip install magic-pdf[full-cpu] -i https://pypi.tuna.tsinghua.edu.cn/simple 
```

```
magic-pdf --version
```

```
pip install detectron2 --extra-index-url https://myhloli.github.io/wheels/ -i https://pypi.tuna.tsinghua.edu.cn/simple 
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

##### 下载模型

```
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
