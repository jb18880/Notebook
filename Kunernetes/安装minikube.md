### 安装docker

> docker安装：https://mirrors.tuna.tsinghua.edu.cn/help/docker-ce/

### 修改docker镜像加速地址

```shell
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://dockertest.jsdelivr.fyi"]  
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker

#备用加速地址
    "https://docker.fxxk.dedyn.io",
    "https://docker.registry.cyou",
    "https://docker-cf.registry.cyou",
    "https://dockercf.jsdelivr.fyi",
    "https://docker.jsdelivr.fyi",
    "https://dockertest.jsdelivr.fyi"
```

### 拉取minikube启动镜像

```shell
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kicbase:v0.0.44
```

### 启动minikube

```shell
minikube delete ; minikube start --force  --memory=1690mb --base-image='registry.cn-hangzhou.aliyuncs.com/google_containers/kicbase:v0.0.44' --image-repository='registry.cn-hangzhou.aliyuncs.com/google_containers'

 #--force是以root身份启动的docker的必须选项
 #--memory=1690mb 是因为资源不足需要添加的限制性参数，可忽略
 #--image-repository  指定镜像仓库为国内的仓库
 #--base-image为指定minikube start 采用的基础镜像，上面docker pull拉取了什么镜像，这里就改成什么镜像
```