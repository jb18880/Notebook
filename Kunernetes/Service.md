# Service

## 1. Service创建

### 1.1 定义service

定义 Service 的 yaml 文件如下：

```yaml
###文件名：service.yaml

kind: Service
apiVersion: v1
metadata:
  name: my-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80   #Service自己的端口号
      targetPort: 80   #容器暴露出来的端口号

```

定义deployment的yaml文件如下：

```yaml
###文件名：nginx-dp.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12-alpine
        ports:
        - containerPort: 80

```

### 1.2 创建pod&&创建svc

```sh
controlplane $ kubectl apply -f nginx-dp.yaml 
deployment.apps/nginx created
controlplane $ kubectl apply -f service.yaml 
service/my-service created
```

### 1.3 验证

#### 1.3.1 验证通过svc是否可以正常访问pod的内容

```sh
# 查看带有"app=nginx"的pod是否被创建
controlplane $ kubectl get pod -l app=nginx
NAME                     READY   STATUS    RESTARTS   AGE
nginx-64cc5f8d84-brwx8   1/1     Running   0          66s
nginx-64cc5f8d84-k8nw4   1/1     Running   0          66s
nginx-64cc5f8d84-l895k   1/1     Running   0          66s

#查看Service是否被创建成功
controlplane $ kubectl get service
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP   12d
my-service   ClusterIP   10.99.178.229   <none>        80/TCP    14s

#通过Service的IP地址访问后端的服务
controlplane $ curl 10.99.178.229
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

#### 1.3.2 验证重建pod后，是否不影响pod的访问

```sh
#查看pod当前的IP地址
controlplane $ kubectl get pod -o wide
NAME                     READY   STATUS    RESTARTS   AGE     IP            NODE           NOMINATED NODE   READINESS GATES
nginx-64cc5f8d84-brwx8   1/1     Running   0          2m53s   192.168.0.4   controlplane   <none>           <none>
nginx-64cc5f8d84-k8nw4   1/1     Running   0          2m53s   192.168.1.4   node01         <none>           <none>
nginx-64cc5f8d84-l895k   1/1     Running   0          2m53s   192.168.1.5   node01         <none>           <none>

#删除pod
controlplane $ kubectl delete po -l app=nginx
pod "nginx-64cc5f8d84-brwx8" deleted
pod "nginx-64cc5f8d84-k8nw4" deleted
pod "nginx-64cc5f8d84-l895k" deleted

#再次查看pod的IP地址
controlplane $ kubectl get pod -o wide
NAME                     READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
nginx-64cc5f8d84-2qnpf   1/1     Running   0          16s   192.168.0.5   controlplane   <none>           <none>
nginx-64cc5f8d84-59bqj   1/1     Running   0          15s   192.168.1.6   node01         <none>           <none>
nginx-64cc5f8d84-62748   1/1     Running   0          15s   192.168.1.7   node01         <none>           <none>

#访问Service的IP，观察返回结果
controlplane $ curl 10.99.178.229
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

#### 1.3.3 访问同名称空间下的Service

```sh
#查看pod状态
controlplane $ kubectl get pod -o wide
NAME                     READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
nginx-64cc5f8d84-2qnpf   1/1     Running   0          22m   192.168.0.5   controlplane   <none>           <none>
nginx-64cc5f8d84-59bqj   1/1     Running   0          22m   192.168.1.6   node01         <none>           <none>
nginx-64cc5f8d84-62748   1/1     Running   0          22m   192.168.1.7   node01         <none>           <none>

#进入其中一个pod里面
controlplane $ kubectl exec -it nginx-64cc5f8d84-2qnpf -- sh

#用wget命令，通过"Service名称"访问服务
#如果没有wget命令，尝试更换为alpine的镜像，例如："registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12-alpine"

/ # wget my-service
Connecting to my-service (10.99.178.229:80)
index.html           100% |**********************|   612  0:00:00 ETA
```

#### 1.3.4 访问不同名称空间下的Service

```sh
# 查看系统名称空间下面的Service信息
controlplane $ kubectl get service -n kube-system 
NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   12d

#进入pod，并通过"Service名称"访问服务
#如果不指定名称空间，就会访问失败
controlplane $ kubectl exec -it nginx-64cc5f8d84-2qnpf -- sh
/ # wget http://kube-dns
wget: bad address 'kube-dns'

#指定名称空间之后，通过"Service名称"访问服务成功
#报错信息为后端服务问题，访问过程是ok的
/ # wget http://kube-dns.kube-system
Connecting to kube-dns.kube-system (10.96.0.10:80)
/ # wget http://kube-dns.kube-system:53
Connecting to kube-dns.kube-system:53 (10.96.0.10:53)
wget: error getting response: Resource temporarily unavailable
/ # wget http://kube-dns.kube-system:9153
Connecting to kube-dns.kube-system:9153 (10.96.0.10:9153)
wget: server returned error: HTTP/1.1 404 Not Found
```



## 2. Service类型

> Kubernetes Service Type（服务类型）主要包括以下几种： 
>
> ➢ ClusterIP：在集群内部使用，默认值，只能从集群内部访问。 
>
> ➢ NodePort：在所有安装了 Kube-Proxy 的节点上打开一个端口，此端口可以代理至后端 Pod，可以通过 NodePort 从集群外部访问集群内的服务，格式为 NodeIP:NodePort。 
>
> ➢ LoadBalancer：使用云提供商的负载均衡器公开服务，成本较高。 
>
> ➢ ExternalName：通过返回定义的 CNAME 别名，没有设置任何类型的代理，需要 1.7 或 更高版本 kube-dns 支持。
>
> NodePort类型是通过服务的IP:Port进行访问的，ExternalName是通过服务的域名进行访问的。

### 2.1 NodePort类型

#### 2.1.1 定义NodePort类型的Service

```yaml
###文件名：service.yaml

kind: Service
apiVersion: v1
metadata:
  name: my-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80   #Service自己的端口号
      targetPort: 80   #容器暴露出来的端口号
  type: NodePort
```

#### 2.1.2 创建NodePort类型的Service

```sh
[node1 ~]$ kubectl create -f service.yaml 
service/my-service created
#NodePort类型的Service会暴露一个端口，给别的服务器访问
[node1 ~]$ kubectl get svc -owide
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE   SELECTOR
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP        63m   <none>
my-service   NodePort    10.103.63.117   <none>        80:31190/TCP   63s   app=nginx
```

#### 2.1.3 查看Service的详细信息

```sh
#ClusterIP类型的Service
controlplane $ kubectl get svc -owide
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE     SELECTOR
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP   12d     <none>
my-service   ClusterIP   10.101.30.157   <none>        80/TCP    6m24s   app=nginx

#NodePort类型的Service
controlplane $ kubectl get svc -owide
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE     SELECTOR
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP        12d     <none>
my-service   NodePort    10.101.30.157   <none>        80:32031/TCP   7m10s   app=nginx
```

#### 2.1.4 查看NodePort类型的Service暴露的端口范围

在 Kubernetes 中，NodePort 类型的 Service 允许外部流量通过每个节点的特定端口访问集群中的服务。NodePort Service 会在每个节点上打开一个静态端口（称为 NodePort），这个端口的范围通常是 30000-32767。

```sh
#好烦，我没查成功，我用的是在线的k8s环境，可能跟实际的不要一样

#二进制安装的k8s集群
grep "service-node-port" /usr/lib/systemd/system/kube-apiserver.service

#kubeadm安装的k8s集群
grep ""--service-node-port-range" /etc/kubernetes/manifests/kube-apiserver.yaml

```

#### 2.1.5 验证端口是否可以正常使用

用电脑的浏览器访问"pod_ip:service_port"，如果出现了nginx页面，则代表正常

```sh
controlplane $ kubectl get pod -o wide
NAME                     READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
nginx-64cc5f8d84-hpxdr   1/1     Running   0          11m   192.168.1.5   node01         <none>           <none>
nginx-64cc5f8d84-nndth   1/1     Running   0          11m   192.168.1.4   node01         <none>           <none>
nginx-64cc5f8d84-nrjhp   1/1     Running   0          11m   192.168.0.4   controlplane   <none>           <none>

controlplane $ kubectl get service 
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP        15d
my-service   NodePort    10.100.123.160   <none>        80:32323/TCP   11m

#本机访问失败
#controlplane $ curl 192.168.1.5:32323
#curl: (7) Failed to connect to 192.168.1.5 port 32323: Connection refused
```



#### 2.2 查看集群中所有的service

如果有其他的service为node-port模式，也可以通过浏览器访问"pod_ip:service_port"试下

```sh
controlplane $ kubectl get service -A
NAMESPACE     NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                  AGE
default       kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP                  15d
default       my-service   NodePort    10.100.123.160   <none>        80:32323/TCP             21m
kube-system   kube-dns     ClusterIP   10.96.0.10       <none>        53/UDP,53/TCP,9153/TCP   15d
```

#### 2.3 修改NodePort模式下正在使用的端口

```sh
controlplane $ kubectl get service
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP        16d
my-service   NodePort    10.105.82.232   <none>        80:30630/TCP   15s
controlplane $ kubectl edit service my-service 
service/my-service edited
#可以看到端口已经倍修改
controlplane $ kubectl get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP        16d
my-service   NodePort    10.105.82.232   <none>        80:30631/TCP   6m21s

#可以通过浏览器访问，查看一下
```

### 2.2 Service的用途

默认情况下，创建service的时候，就会创建一个同名的endoints

```sh
controlplane $ kubectl create -f nginx.yaml 
deployment.apps/nginx created
service/my-service created
controlplane $ kubectl get pods 
NAME                     READY   STATUS    RESTARTS   AGE
nginx-64cc5f8d84-knj6r   1/1     Running   0          12s
nginx-64cc5f8d84-scb8k   1/1     Running   0          12s
nginx-64cc5f8d84-tzg7f   1/1     Running   0          12s

controlplane $ kubectl get svc
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP        16d
my-service   NodePort    10.103.182.193   <none>        80:32199/TCP   37s
controlplane $ kubectl get endpoints
NAME         ENDPOINTS                                      AGE
kubernetes   172.30.1.2:6443                                16d
my-service   192.168.0.4:80,192.168.1.4:80,192.168.1.5:80   47s
```

如果是要代理外部集群中的业务，在service的配置文件中就不需要定义spec.selecter项

#spec.ports与subsets.ports信息要一致

```sh
#准备一个公网IP地址
http://47.97.36.32:4000/

#创建一个service的定义文件
vim service-external-ip.yaml

apiVersion: v1
kind: Service
metadata:
  labels:
    app: service-external-ip
  name: service-external-ip
spec:
  ports:
  - name: http
    port: 4000
    protocol: TCP
    targetPort: 4000
  type: ClusterIP
# cat nginx-ep-external.yaml
---
apiVersion: v1
kind: Endpoints
metadata:
  labels:
    app: nginx-svc-external
  name: nginx-svc-external
subsets:
- addresses:
  - ip: 47.97.36.32
  ports:
  - name: http
    port: 4000
    protocol: TCP
    
#创建deployment、service和endpoint
controlplane $ kubectl create -f base.yaml
controlplane $ kubectl create -f service.yaml
controlplane $ kubectl get service
NAME                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
kubernetes           ClusterIP   10.96.0.1        <none>        443/TCP        17d
my-service           NodePort    10.100.211.223   <none>        80:32210/TCP   2m12s
nginx-svc-external   ClusterIP   10.106.152.51    <none>        4000/TCP       2m5s

#通过curl访问验证service是否可以正常代理外端的服务
controlplane $ curl 10.106.152.51:4000
#pod内部进行验证
controlplane $ kubectl exec -it nginx-64cc5f8d84-7wwgx -- sh
/ # wget nginx-external-service
wget: bad address 'nginx-external-service'
/ # wget nginx-svc-external
Connecting to nginx-svc-external (10.106.152.51:80)
^C
/ # wget nginx-svc-external:4000
Connecting to nginx-svc-external:4000 (10.106.152.51:4000)
index.html           100% |**************************| 79514  0:00:00 ETA
```





### 2.3 External类型

ExternalName类型的Service一般有两种用途，一：通过域名代理外部的后端服务，二：代理其他名称空间下面的Service

#### 2.3.1 定义External类型的Service

```yaml
vim external.yaml

apiVersion: v1
kind: Service
metadata:
  name: external-service
spec:
  type: ExternalName
  externalName: www.baidu.com
  
  
#创建service
controlplane $ kubectl create -f external.yaml 
service/external-service created
controlplane $ kubectl get svc
NAME                 TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)        AGE
external-service     ExternalName   <none>           www.baidu.com   <none>         6s
kubernetes           ClusterIP      10.96.0.1        <none>          443/TCP        17d
my-service           NodePort       10.100.211.223   <none>          80:32210/TCP   14m
nginx-svc-external   ClusterIP      10.106.152.51    <none>          4000/TCP       14m

#进入容器验证
controlplane $ kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
nginx-64cc5f8d84-7wwgx   1/1     Running   0          16m
nginx-64cc5f8d84-rmnrd   1/1     Running   0          16m
nginx-64cc5f8d84-vx6gg   1/1     Running   0          16m
controlplane $ kubectl exec -it nginx-64cc5f8d84-7wwgx -- sh
/ # wget external-service
Connecting to external-service (103.235.46.40:80)
#403为百度的防火墙策略
wget: server returned error: HTTP/1.1 403 Forbidden
```

#### 2.3.2 验证代理系统名称空间下的服务

实验失败，估计是验证的服务不支持通过wget进行访问

解决思路：1. 使用带有curl工具容器进行验证

			2. 使用其他名称空间下面的服务进行验证

```sh
controlplane $ kubectl get svc -A
NAMESPACE     NAME                 TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                  AGE
default       external-service     ExternalName   <none>           www.baidu.com   <none>                   16m
default       kubernetes           ClusterIP      10.96.0.1        <none>          443/TCP                  17d
default       my-service           NodePort       10.100.211.223   <none>          80:32210/TCP             31m
default       nginx-svc-external   ClusterIP      10.106.152.51    <none>          4000/TCP                 31m
kube-system   kube-dns             ClusterIP      10.96.0.10       <none>          53/UDP,53/TCP,9153/TCP   17d

controlplane $ vim external.yaml
apiVersion: v1
kind: Service
metadata:
  name: external-service
spec:
  type: ExternalName
  externalName: kube-dns.kube-system
  
controlplane $ kubectl replace -f external.yaml 
service/external-service replaced
```

#### 2.3.3 验证代理其他名称空间下的服务

1. 创建deployment和service

   ```yaml
   vim base.yaml
   
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: nginx
     labels:
       app: nginx
   spec:
     replicas: 3
     selector:
       matchLabels:
         app: nginx
     template:
       metadata:
         labels:
           app: nginx
       spec:
         containers:
         - name: nginx
           image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12-alpine
           ports:
           - containerPort: 80
   ---
   kind: Service
   apiVersion: v1
   metadata:
     name: my-service
   spec:
     selector:
       app: nginx
     ports:
       - protocol: TCP
         port: 80   #Service自己的端口号
         targetPort: 80   #容器暴露出来的端口号
     type: NodePort
   ```

2. 创建一个测试名称空间(test-namespace)

   ```yaml
   vim test-namespace.yaml
   
   apiVersion: v1
   kind: Namespace
   metadata:
     name: test-namespace
     
   kubectl create -f etst-namespace.yaml
   kubectl get namespaces
   ```

3. 在测试名称空间(test-namespace)下面创建一个deployment，该dp用来提供nginx服务

   ```yaml
   vim test-deployment.yaml
   
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: text-nginx
     namespace: test-namespace
     labels:
       app: nginx
   spec:
     replicas: 3
     selector:
       matchLabels:
         app: nginx
     template:
       metadata:
         labels:
           app: nginx
       spec:
         containers:
         - name: nginx
           image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12-alpine
           ports:
           - containerPort: 80
   
   kubectl apply -f test-deployment.yaml
   kubectl get deployments -n my-namespace
   ```

4. 在test-namespace名称空间下面创建一个待代理的service

   ```yaml
   vim test-nginx.yaml
   
   kind: Service
   apiVersion: v1
   metadata:
     name: test-nginx
     namespace: test-namespace
   spec:
     selector:
       app: nginx
     ports:
       - protocol: TCP
         port: 80   #Service自己的端口号
         targetPort: 80   #容器暴露出来的端口号
     type: NodePort
   ```

5. 将default名称空间下的external_service的配置文件修改为代理新名称空间下的nginx服务

   ```yaml
   controlplane $ vim external.yaml
   apiVersion: v1
   kind: Service
   metadata:
     name: external-service
   spec:
     type: ExternalName
     externalName: test-nginx.test-namespace
   ```

6. 在default名称空间下面的pod验证访问是否正常

   ```sh
   controlplane $ kubectl get pod -o wide
   NAME                     READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
   nginx-64cc5f8d84-86tjf   1/1     Running   0          62s   192.168.0.4   controlplane   <none>           <none>
   nginx-64cc5f8d84-pmw69   1/1     Running   0          62s   192.168.1.5   node01         <none>           <none>
   nginx-64cc5f8d84-xsr4n   1/1     Running   0          62s   192.168.1.4   node01         <none>           <none>
   
   controlplane $ kubectl exec -it nginx-64cc5f8d84-86tjf -- sh
   / # wget test-nginx.test-namespace
   Connecting to test-nginx.test-namespace (10.101.125.40:80)
   index.html           100% |***********************|   612  0:00:00 ETA
   / # cat index.html 
   <!DOCTYPE html>
   <html>
   <head>
   <title>Welcome to nginx!</title>
   <style>
       body {
           width: 35em;
           margin: 0 auto;
           font-family: Tahoma, Verdana, Arial, sans-serif;
       }
   </style>
   </head>
   <body>
   <h1>Welcome to nginx!</h1>
   <p>If you see this page, the nginx web server is successfully installed and
   working. Further configuration is required.</p>
   
   <p>For online documentation and support please refer to
   <a href="http://nginx.org/">nginx.org</a>.<br/>
   Commercial support is available at
   <a href="http://nginx.com/">nginx.com</a>.</p>
   
   <p><em>Thank you for using nginx.</em></p>
   </body>
   </html>
   ```

   ### 2.4 多端口Service

   ```yaml
   #spec.ports为配置多个端口位置
   #name不能写成一样的
   #不能对同一协议下单个端口(不能配置两个TCP协议的53端口，但是可以配置一个TCP协议下的53端口和一个UDP协议的53端口)配置多个规则，
   apiVersion: v1
   kind: Service
   metadata:
     name: my-service
   spec:
     selector:
       app: myapp
     ports:
     - name: http
       protocol: TCP
       port: 80
       targetPort: 9376
     - name: https
       protocol: TCP
       port: 443
       targetPort: 9377
   ```

   例如：

   ```yaml
   controlplane $ kubectl get svc kube-dns -n kube-system -o yaml
   apiVersion: v1
   kind: Service
   metadata:
     annotations:
       prometheus.io/port: "9153"
       prometheus.io/scrape: "true"
     creationTimestamp: "2024-05-11T15:42:53Z"
     labels:
       k8s-app: kube-dns
       kubernetes.io/cluster-service: "true"
       kubernetes.io/name: CoreDNS
     name: kube-dns
     namespace: kube-system
     resourceVersion: "243"
     uid: 6676ccb7-16ed-4c03-924b-fcfb46bc94b4
   spec:
     clusterIP: 10.96.0.10
     clusterIPs:
     - 10.96.0.10
     internalTrafficPolicy: Cluster
     ipFamilies:
     - IPv4
     ipFamilyPolicy: SingleStack
     ports:
     - name: dns
       port: 53
       protocol: UDP
       targetPort: 53
     - name: dns-tcp
       port: 53
       protocol: TCP
       targetPort: 53
     - name: metrics
       port: 9153
       protocol: TCP
       targetPort: 9153
     selector:
       k8s-app: kube-dns
     sessionAffinity: None
     type: ClusterIP
   status:
     loadBalancer: {}
   ```

   