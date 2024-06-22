# kubernetes部署



### 环境介绍

ubuntu 20.04 	kubeadm	kubernetes version v1.27.1	flannal v0.21.5   cri-dockerd 0.3.2.3

参考文章：

```
https://blog.csdn.net/cp_dvd/article/details/127696229?ops_request_misc=&request_id=&biz_id=102&utm_term=%E6%95%B4%E5%90%88kubelet%E5%92%8Ccri-dockerd&utm_medium=distribute.pc_search_result.none-task-blog-2~all~sobaiduweb~default-0-127696229.142^v82^koosearch_v1,201^v4^add_ask,239^v2^insert_chatgpt&spm=1018.2226.3001.4187
```



### 环境准备

1. 修改IP地址

   主节点修改ip地址为10.0.0.101

   从节点修改IP地址为10.0.0.104、10.0.0.105、10.0.0.106

   ```
   vim /etc/netplan/00-installer-config.yaml
   
   netplan apply
   ip a 
   ```

2. 修改主机名

   主节点修改主机名为`k8s-master01`

   从节点修改主机名为`k8s-node01`、`k8s-node02`、`k8s-node03`

   ```
   hostnamectl set-hostname k8s-master01
   hostnamectl set-hostname k8s-node01
   hostnamectl set-hostname k8s-node02
   hostnamectl set-hostname k8s-node03
   ```

3. 添加主机名解析

   每台服务器都要添加，无论主从

   ```
   cat >> /etc/hosts << EOF
   10.0.0.101 k8s-master01 k8s-master01.wang.org kubeapi.wang.org kubeapi
   10.0.0.102 k8s-master02 k8s-master02.wang.org
   10.0.0.103 k8s-master03 k8s-master03.wang.org
   10.0.0.104 k8s-node01 k8s-node01.wang.org
   10.0.0.105 k8s-node02 k8s-node02.wang.org
   10.0.0.106 k8s-node03 k8s-node03.wang.org
   EOF
   ```

4. 时间同步

   ```
   cat > /etc/apt/sources.list << EOF
   # 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
   deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse
   # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse
   deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse
   # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse
   deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse
   # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse
   deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse
   # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse
   
   # 预发布软件源，不建议启用
   # deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-proposed main restricted universe multiverse
   # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-proposed main restricted universe multiverse
   EOF
   apt clean all
   apt update
   apt -y install chrony
   ```

   安装完chronyd再通过下面的命令配置chronyd

   ```
   sed  -ri  "17s/(pool).*/\1 ntp1.aliyun.com iburst maxsources 4/" /etc/chrony/chrony.conf
   sed  -ri  "18s/(pool).*/\1 s1a.time.edu.cn iburst maxsources 1/" /etc/chrony/chrony.conf
   sed  -ri  "19s/(pool).*/\1 s1b.time.edu.cn iburst maxsources 1/" /etc/chrony/chrony.conf
   sed  -ri  "20s/(pool.*)/\\t/" /etc/chrony/chrony.conf
   timedatectl set-timezone Asia/Shanghai
   systemctl start chronyd
   systemctl is-active chronyd
   date
   ```

5. 禁用swap设备

   ```
   sed -r -i '/\/swap/s@^@#@' /etc/fstab ; swapoff -a ; systemctl --type swap
   ```

   ```
   检查是否禁用
   # systemctl --type swap
   如果上述命令有检查出来设备，通过下面的命令进行禁用
   # systemctl mask SWAP_DEV
   ```

   ```
   备用方案：
   编辑kubelet的配置文件/etc/default/kubelet，设置kubeadm忽略Swap启用的状态错误
   vim /etc/default/kubelet
   KUBELET_EXTRA_ARGS="--fail-swap-on=false"
   ```

6. 关闭防火墙

   ```
   ufw disable ; ufw status
   ```

至此，基础linux环境已经配好

### 部署应用

#### 安装docker

1. 部署docker

   ```
   #先设置环境变量，但是不配置环境变量好像更快
   export DOWNLOAD_URL="https://mirrors.tuna.tsinghua.edu.cn/docker-ce"
   # 如您使用 curl , 
   apt -y install curl
   curl -fsSL https://get.docker.com/ | sh
   # 如您使用 wget ，
   apt -y install wget
   wget -O- https://get.docker.com/ | sh
   ```

2. 配置docker镜像的加速源

   ```
   cat > /etc/docker/daemon.json << EOF
   {
           "registry-mirrors": [
                     "https://docker.mirrors.ustc.edu.cn",
                       "https://hub-mirror.c.163.com",
                         "https://reg-mirror.qiniu.com",
                           "https://registry.docker-cn.com"
           ],
           "exec-opts": ["native.cgroupdriver=systemd"],
           "log-driver": "json-file",
           "log-opts": {
                     "max-size": "200m"
           }
   }
   EOF
   systemctl daemon-reload;systemctl restart docker;docker info
   ```

#### 安装cri-dockerd

1. 查看自己系统的架构相关信息

   ```
   lsb_release -rc ; dpkg --print-architecture
   ```

2. 在浏览器下载适配自己版本的cri-dockerd文件，并传到linux服务器

   ```
   https://github.com/Mirantis/cri-dockerd/releases/
   ```

3. 安装cri-dockerd

   ```
   dpkg -i cri-dockerd_0.3.2.3-0.ubuntu-focal_amd64.deb
   ```

4. 检查cri-dockerd状态

   ```
   systemctl status cri-docker.service
   ```

#### 安装kubelet、kubeadm和kubectl

1. 阿里巴巴开源镜像站有配置下载k8s环境的步骤如下：

   ```
   apt-get update && apt-get install -y apt-transport-https
   curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add - 
   cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
   deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
   EOF
   apt-get update
   apt-get install -y kubelet kubeadm kubectl
   ```

2. 设置kubelet开机自启，查看kubeadm版本

   ```
   systemctl enable kubelet ; kubeadm version
   ```

#### 整合kubelet和cri-dockerd

1. 编辑service文件，把启动程序的参数换成下面这个

   ```
   vim /usr/lib/systemd/system/cri-docker.service
   ExecStart=/usr/bin/cri-dockerd --pod-infra-container-image=registry.aliyuncs.com/google_containers/pause:3.8 --container-runtime-endpoint fd:// --network-plugin=cni --cni-bin-dir=/opt/cni/bin --cni-cache-dir=/var/lib/cni/cache --cni-conf-dir=/etc/cni/net.d
   
   ```

2. 重新加载cri-dockerd服务

   ```
   systemctl daemon-reload ; systemctl restart cri-docker.service ; systemctl status cri-docker
   ```

#### 配置kubelet

如果不配置该文件，后续在执行每条kubeadm命令时都需要加上一个参数"--cri-socket unix:///run/cri-dockerd.sock"

1. 创建文件夹

   ```
   mkdir /etc/sysconfig
   ```

2. 编辑kubelet配置文件

   ```
   cat > /etc/sysconfig/kubelet << EOF
   KUBELET_KUBEADM_ARGS="--container-runtime=remote --container-runtime-endpoint=/run/cri-dockerd.sock"
   EOF
   ```

### 配置kubernetes

#### 初始化master节点

在master01上执行以下操作

1. 查看需要的images列表

   ```
   kubeadm config images list
   ```

2. 拉取镜像

   - 通过kubernetes镜像源拉取镜像

     ```
     kubeadm config images pull --cri-socket unix:///run/cri-dockerd.sock
     ```

   - 通过阿里云镜像源拉取镜像

     ```
     kubeadm config images pull --image-repository=registry.aliyuncs.com/google_containers --cri-socket unix:///run/cri-dockerd.sock
     ```

3. 初始化主节点

   ```sh
   systemctl daemon-reload ; systemctl restart cri-docker.service
   kubeadm init --apiserver-advertise-address  10.0.0.101 --kubernetes-version=v1.27.1 --pod-network-cidr=10.244.0.0/16 --service-cidr=10.96.0.0/12 --token-ttl=0 --cri-socket unix:///run/cri-dockerd.sock --upload-certs --image-repository registry.aliyuncs.com/google_containers
   ```
   
   初始化主节点之后，把加入主节点的这条命令复制出来，后面从节点加入到主节点时会用到的
   
   请把换行符去掉，把命令写在一行里面
   
   把***换行符去掉，命令写一行里
   
   后面再加上调用cri 的参数
   
   ```sh
   kubeadm join 10.0.0.101:6443 --token q53qro.3yv4fh1azerb5le2 --discovery-token-ca-cert-hash sha256:440e0c28bdba85d6042c5f59c2e318093d0c25f6e2eabf03e3ebe778d95b7574 --cri-socket unix:///run/cri-dockerd.sock
   ```

#### 保存master认证文件

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

#### 部署flannel网络插件

flannel网络插件只需要在主节点上部署就好

1. 查看系统架构

   ```
   dpkg --print-architecture
   ```

2. 下载对应的flannel插件

   ```
   https://github.com/flannel-io/flannel/releases
   ```

3. 创建/opt/bin/目录

   ```
   mkdir /opt/bin/ ; cd /opt/bin/
   ```

4. 将文件放到/opt/bin/目录下，并解压

   确保flanneld*是有执行权限的

   ```
   tar xf flannel-v0.21.4-linux-amd64.tar.gz
   ll flanneld*
   ```

5. 通过配置文件启用flannel

   在/opt/bin/目录下执行启动命令

   ```
   kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
   ```

6. 检查flannel是否启动

   ```
   kubectl get pods -n kube-flannel
   ```

#### 验证master节点就绪状态

```
kubectl get nodes
```

#### 从节点加入到集群

master部署成功之后，终端上会显示一串从节点添加到集群中的命令，在这个命令最后加上"--cri-socket unix:///run/cri-dockerd.sock"，从节点就能成功加入集群

```
systemctl restart kubelet
```

```
kubeadm join 10.0.0.101:6443 --token q53qro.3yv4fh1azerb5le2 --discovery-token-ca-cert-hash sha256:440e0c28bdba85d6042c5f59c2e318093d0c25f6e2eabf03e3ebe778d95b7574 --cri-socket unix:///run/cri-dockerd.sock
```

#### 验证从节点添加结果

在主节点上执行

```
kubectl get nodes
```









# kubernetes平台上各种控制器的用法



熟练掌握kubectl管理命令

熟练掌握POD原理

熟练掌握集群调度规则

熟悉控制器资源文件



kubectl子命令

```
root@k8s-master01:~# kubectl --help
kubectl controls the Kubernetes cluster manager.

 Find more information at: https://kubernetes.io/docs/reference/kubectl/

Basic Commands (Beginner):
  create          Create a resource from a file or from stdin
  expose          Take a replication controller, service, deployment or pod and expose it as a new
Kubernetes service
  run             Run a particular image on the cluster
  set             Set specific features on objects

Basic Commands (Intermediate):
  explain         Get documentation for a resource
  get             Display one or many resources
  edit            Edit a resource on the server
  delete          Delete resources by file names, stdin, resources and names, or by resources and
label selector

Deploy Commands:
  rollout         Manage the rollout of a resource
  scale           Set a new size for a deployment, replica set, or replication controller
  autoscale       Auto-scale a deployment, replica set, stateful set, or replication controller

Cluster Management Commands:
  certificate     Modify certificate resources.
  cluster-info    Display cluster information
  top             Display resource (CPU/memory) usage
  cordon          Mark node as unschedulable
  uncordon        Mark node as schedulable
  drain           Drain node in preparation for maintenance
  taint           Update the taints on one or more nodes

Troubleshooting and Debugging Commands:
  describe        Show details of a specific resource or group of resources
  logs            Print the logs for a container in a pod
  attach          Attach to a running container
  exec            Execute a command in a container
  port-forward    Forward one or more local ports to a pod
  proxy           Run a proxy to the Kubernetes API server
  cp              Copy files and directories to and from containers
  auth            Inspect authorization
  debug           Create debugging sessions for troubleshooting workloads and nodes
  events          List events

Advanced Commands:
  diff            Diff the live version against a would-be applied version
  apply           Apply a configuration to a resource by file name or stdin
  patch           Update fields of a resource
  replace         Replace a resource by file name or stdin
  wait            Experimental: Wait for a specific condition on one or many resources
  kustomize       Build a kustomization target from a directory or URL

Settings Commands:
  label           Update the labels on a resource
  annotate        Update the annotations on a resource
  completion      Output shell completion code for the specified shell (bash, zsh, fish, or
powershell)

Other Commands:
  api-resources   Print the supported API resources on the server
  api-versions    Print the supported API versions on the server, in the form of "group/version"
  config          Modify kubeconfig files
  plugin          Provides utilities for interacting with plugins
  version         Print the client and server version information

Usage:
  kubectl [flags] [options]

Use "kubectl <command> --help" for more information about a given command.
Use "kubectl options" for a list of global command-line options (applies to all commands).
```



查看k8s所有资源类型

NAMESPACED：该资源是否有对应的名称空间

KIND：

```
root@k8s-master01:~# kubectl api-resources
NAME                              SHORTNAMES   APIVERSION                             NAMESPACED   KIND
bindings                                       v1                                     true         Binding
componentstatuses                 cs           v1                                     false        ComponentStatus
configmaps                        cm           v1                                     true         ConfigMap
endpoints                         ep           v1                                     true         Endpoints
events                            ev           v1                                     true         Event
limitranges                       limits       v1                                     true         LimitRange
namespaces                        ns           v1                                     false        Namespace
nodes                             no           v1                                     false        Node
persistentvolumeclaims            pvc          v1                                     true         PersistentVolumeClaim
persistentvolumes                 pv           v1                                     false        PersistentVolume
pods                              po           v1                                     true         Pod
podtemplates                                   v1                                     true         PodTemplate
replicationcontrollers            rc           v1                                     true         ReplicationController
resourcequotas                    quota        v1                                     true         ResourceQuota
secrets                                        v1                                     true         Secret
serviceaccounts                   sa           v1                                     true         ServiceAccount
services                          svc          v1                                     true         Service
mutatingwebhookconfigurations                  admissionregistration.k8s.io/v1        false        MutatingWebhookConfiguration
validatingwebhookconfigurations                admissionregistration.k8s.io/v1        false        ValidatingWebhookConfiguration
customresourcedefinitions         crd,crds     apiextensions.k8s.io/v1                false        CustomResourceDefinition
apiservices                                    apiregistration.k8s.io/v1              false        APIService
controllerrevisions                            apps/v1                                true         ControllerRevision
daemonsets                        ds           apps/v1                                true         DaemonSet
deployments                       deploy       apps/v1                                true         Deployment
replicasets                       rs           apps/v1                                true         ReplicaSet
statefulsets                      sts          apps/v1                                true         StatefulSet
tokenreviews                                   authentication.k8s.io/v1               false        TokenReview
localsubjectaccessreviews                      authorization.k8s.io/v1                true         LocalSubjectAccessReview
selfsubjectaccessreviews                       authorization.k8s.io/v1                false        SelfSubjectAccessReview
selfsubjectrulesreviews                        authorization.k8s.io/v1                false        SelfSubjectRulesReview
subjectaccessreviews                           authorization.k8s.io/v1                false        SubjectAccessReview
horizontalpodautoscalers          hpa          autoscaling/v2                         true         HorizontalPodAutoscaler
cronjobs                          cj           batch/v1                               true         CronJob
jobs                                           batch/v1                               true         Job
certificatesigningrequests        csr          certificates.k8s.io/v1                 false        CertificateSigningRequest
leases                                         coordination.k8s.io/v1                 true         Lease
endpointslices                                 discovery.k8s.io/v1                    true         EndpointSlice
events                            ev           events.k8s.io/v1                       true         Event
flowschemas                                    flowcontrol.apiserver.k8s.io/v1beta3   false        FlowSchema
prioritylevelconfigurations                    flowcontrol.apiserver.k8s.io/v1beta3   false        PriorityLevelConfiguration
ingressclasses                                 networking.k8s.io/v1                   false        IngressClass
ingresses                         ing          networking.k8s.io/v1                   true         Ingress
networkpolicies                   netpol       networking.k8s.io/v1                   true         NetworkPolicy
runtimeclasses                                 node.k8s.io/v1                         false        RuntimeClass
poddisruptionbudgets              pdb          policy/v1                              true         PodDisruptionBudget
clusterrolebindings                            rbac.authorization.k8s.io/v1           false        ClusterRoleBinding
clusterroles                                   rbac.authorization.k8s.io/v1           false        ClusterRole
rolebindings                                   rbac.authorization.k8s.io/v1           true         RoleBinding
roles                                          rbac.authorization.k8s.io/v1           true         Role
priorityclasses                   pc           scheduling.k8s.io/v1                   false        PriorityClass
csidrivers                                     storage.k8s.io/v1                      false        CSIDriver
csinodes                                       storage.k8s.io/v1                      false        CSINode
csistoragecapacities                           storage.k8s.io/v1                      true         CSIStorageCapacity
storageclasses                    sc           storage.k8s.io/v1                      false        StorageClass
volumeattachments                              storage.k8s.io/v1                      false        VolumeAttachment
```



### kubectl命令



- kubectl get

  查看各个资源的状态

  - 查看各个组件状态

    ```
    root@k8s-master01:~# kubectl get componentstatuses
    Warning: v1 ComponentStatus is deprecated in v1.19+
    NAME                 STATUS    MESSAGE                         ERROR
    controller-manager   Healthy   ok                              
    scheduler            Healthy   ok                              
    etcd-0               Healthy   {"health":"true","reason":""}   
    ```

  - 查看各个节点状态

    ```
    root@k8s-master01:~# kubectl get nodes
    NAME           STATUS   ROLES           AGE   VERSION
    k8s-master01   Ready    control-plane   10h   v1.27.1
    k8s-node01     Ready    <none>          10h   v1.27.1
    k8s-node02     Ready    <none>          10h   v1.27.1
    k8s-node03     Ready    <none>          10h   v1.27.1
    ```

    - 查看单个节点状态

      ```
      root@k8s-master01:~# kubectl get node k8s-master01
      NAME           STATUS   ROLES           AGE   VERSION
      k8s-master01   Ready    control-plane   10h   v1.27.1
      ```

  - 查看名称空间

    default是默认名称空间，不指定特定的名称空间时，操作的就是该名称空间下的资源

    kube-system是k8s系统自己用的名称空间，该名称空间中包含了k8s各个组件

    kube-public是用来存放公共数据的名称空间，该名称空间中的内容所有用户都可以访问

    kube-node-lease是为了保证高可用提供心跳监测的名称空间

    ```sh
    root@k8s-master01:~# kubectl get namespace
    NAME              STATUS   AGE
    default           Active   11h
    kube-flannel      Active   11h
    kube-node-lease   Active   11h
    kube-public       Active   11h
    kube-system       Active   11h
    ```

  - 查看deployment

    查看默认名称空间内的deployment

    ```sh
    root@k8s-master01:~# kubectl get deployments
    No resources found in default namespace.
    ```

    查看kube-system名称空间内的deployment

    ```sh
    root@k8s-master01:~# kubectl -n kube-system get deployments
    NAME      READY   UP-TO-DATE   AVAILABLE   AGE
    coredns   2/2     2            2           11h
    ```

  - 查看pod

    查看默认名称空间中的pods

    ```sh
    root@k8s-master01:~#  kubectl get pods
    No resources found in default namespace.
    ```

    查看kube-system名称空间内的pods

    ```sh
    root@k8s-master01:~# kubectl -n kube-system get pods
    NAME                                   READY   STATUS    RESTARTS   AGE
    coredns-7bdc4cb885-g98v9               1/1     Running   0          11h
    coredns-7bdc4cb885-gxgl2               1/1     Running   0          11h
    etcd-k8s-master01                      1/1     Running   0          11h
    kube-apiserver-k8s-master01            1/1     Running   0          11h
    kube-controller-manager-k8s-master01   1/1     Running   0          11h
    kube-proxy-5cv9f                       1/1     Running   0          11h
    kube-proxy-g2bwv                       1/1     Running   0          11h
    kube-proxy-n8tm5                       1/1     Running   0          11h
    kube-proxy-qwnm9                       1/1     Running   0          11h
    kube-scheduler-k8s-master01            1/1     Running   0          11h
    ```

    

  

  - kubectl命令

  NAME：pod的名称

  READY：容器的就绪状态，x/y中的y代表一个pod中有几个容器，x代表正常运行的容器个数

  STATUS：pod的状态

  RESTARTS：pod重启的次数

  AGE：pod创建时长

  ```sh
  root@k8s-master01:~# kubectl -n kube-system get pods
  NAME                                   READY   STATUS    RESTARTS   AGE
  coredns-7bdc4cb885-g98v9               1/1     Running   0          11h
  coredns-7bdc4cb885-gxgl2               1/1     Running   0          11h
  etcd-k8s-master01                      1/1     Running   0          11h
  kube-apiserver-k8s-master01            1/1     Running   0          11h
  kube-controller-manager-k8s-master01   1/1     Running   0          11h
  kube-proxy-5cv9f                       1/1     Running   0          11h
  kube-proxy-g2bwv                       1/1     Running   0          11h
  kube-proxy-n8tm5                       1/1     Running   0          11h
  kube-proxy-qwnm9                       1/1     Running   0          11h
  kube-scheduler-k8s-master01            1/1     Running   0          11h
  ```

  

  ### k8s排错

  kubectl get 定位

  kubectl describe 查看具体报错

  kubectl logs 查看日志

  

  场景：某个pod的容器就绪状态为0/1

  拍错思路：1、找到这个pod运行在哪台主机上（通过IP和node确定故障机）

  根据STATUS看到粗略的错误原因

  ```sh
  root@k8s-master01:~# kubectl -n kube-system get pods -o wide
  NAME                                   READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
  coredns-7bdc4cb885-g98v9               1/1     Running   0          13h   10.244.0.2   k8s-master01   <none>           <none>
  coredns-7bdc4cb885-gxgl2               1/1     Running   0          13h   10.244.0.3   k8s-master01   <none>           <none>
  etcd-k8s-master01                      1/1     Running   0          13h   10.0.0.101   k8s-master01   <none>           <none>
  kube-apiserver-k8s-master01            1/1     Running   0          13h   10.0.0.101   k8s-master01   <none>           <none>
  kube-controller-manager-k8s-master01   1/1     Running   0          13h   10.0.0.101   k8s-master01   <none>           <none>
  kube-proxy-5cv9f                       1/1     Running   0          12h   10.0.0.106   k8s-node03     <none>           <none>
  kube-proxy-g2bwv                       1/1     Running   0          12h   10.0.0.104   k8s-node01     <none>           <none>
  kube-proxy-n8tm5                       1/1     Running   0          13h   10.0.0.101   k8s-master01   <none>           <none>
  kube-proxy-qwnm9                       1/1     Running   0          12h   10.0.0.105   k8s-node02     <none>           <none>
  kube-scheduler-k8s-master01            1/1     Running   0          13h   10.0.0.101   k8s-master01   <none>           <none>
  ```

  

  -o后面可以接很多选项

  -o wide 代表以命令行方式显示（显示的信息更全一点）

  -o json 代表以json格式显示（显示pod的完整信息）

  -o yaml 代表以yaml格式显示（显示pod的完整信息）

  ```sh
  root@k8s-master01:~# kubectl -n kube-system get pods -o help
  error: unable to match a printer suitable for the output format "help", allowed formats are: custom-columns,custom-columns-file,go-template,go-template-file,json,jsonpath,jsonpath-as-json,jsonpath-file,name,template,templatefile,wide,yaml
  ```

  ```sh
  root@k8s-master01:~# kubectl -n kube-system get pod etcd-k8s-master01 -o wide
  NAME                READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
  etcd-k8s-master01   1/1     Running   0          13h   10.0.0.101   k8s-master01   <none>           <none>
  ```

  ```sh
  root@k8s-master01:~# kubectl -n kube-system get pod etcd-k8s-master01 -o json
  ```

  ```sh
  root@k8s-master01:~# kubectl -n kube-system get pod etcd-k8s-master01 -o yaml
  ```

  2、 describe中的events可以看到具体的报错信息

  ```sh
  root@k8s-master01:~# kubectl -n kube-system describe pod kube-apiserver-k8s-master01
  ```





### Pod与控制器

kubectl run 创建容器

```
root@k8s-master01:~# kubectl run httpd-app --image=httpd 
pod/httpd-app created
root@k8s-master01:~# kubectl get pods
NAME        READY   STATUS             RESTARTS   AGE
httpd-app   1/1     Running            0          29s
root@k8s-master01:~# kubectl get pods -o wide
NAME        READY   STATUS             RESTARTS   AGE    IP           NODE         NOMINATED NODE   READINESS GATES
httpd-app   1/1     Running            0          53s    10.244.3.2   k8s-node01   <none>           <none>
root@k8s-master01:~# ping 10.244.3.2
PING 10.244.3.2 (10.244.3.2) 56(84) bytes of data.
64 bytes from 10.244.3.2: icmp_seq=1 ttl=63 time=0.625 ms
64 bytes from 10.244.3.2: icmp_seq=2 ttl=63 time=3.81 ms
```