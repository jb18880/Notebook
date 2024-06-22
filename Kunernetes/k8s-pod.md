## **1.1创建pod**

linux理念：一切皆文件

k8s理念：基础设施即代码

- 创建pod的两种方式

  - 命令行方式创建 `kubectl run nginx-run --image=nginx:1.15.12`

    run后面接pod的名称

    --image后面接镜像名称

  - 通过配置文件进行创建

    ```
     配置文件可以通过\-\-dry-run选项配合重定向生生成。
    ```

    ```
     root@k8s-master01:~/test# kubectl run nginx-yaml --image=nginx:1.15.12 -oyaml --dry-run > nginx_yaml.yaml
     W1115 02:23:50.996509  201390 helpers.go:663] --dry-run is deprecated and can be replaced with --dry-run=client.
     
    ```

    创建pod

    ```
     root@k8s-master01:~/test# cat nginx.yaml 
     apiVersion: v1
     kind: Pod
     metadata: 
       labels: 
         run: nginx
       name: nginx
     spec: 
       containers: 
       - image: nginx:1.15.12
         name: nginx
         
     root@k8s-master01:~/test# kubectl create -f nginx.yaml 
     pod/nginx created
    ```

- 查看pod状态

  - 查看默认名称空间内的pod

    ```
     root@k8s-master01:~/test# kubectl get pod 
     NAME    READY   STATUS    RESTARTS   AGE
     nginx   1/1     Running   0          21s
     
    ```

  - 查看其他名称空间内的pod

    -n 指定名称空间

    NAME为pod的名称

    READY为容器启动数量，前面的数字为“已启动的容器的数量”，后面的数字为pod中包含的容器的总数

    STATUS为pod的状态

    RESTARTS为pod重启的次数

    ```
     root@k8s-master01:~/test# kubectl get pod -n kube-system
     NAME                                   READY   STATUS    RESTARTS       AGE
     coredns-7bdc4cb885-bmgqk               1/1     Running   1 (6d5h ago)   6d6h
     coredns-7bdc4cb885-t4qcs               1/1     Running   1 (6d5h ago)   6d6h
     etcd-k8s-master01                      1/1     Running   1 (6d5h ago)   6d6h
     kube-apiserver-k8s-master01            1/1     Running   1 (6d5h ago)   6d6h
     kube-controller-manager-k8s-master01   1/1     Running   1 (6d5h ago)   6d6h
     kube-proxy-5bkbw                       1/1     Running   1 (6d5h ago)   6d6h
     kube-proxy-9czkc                       1/1     Running   1 (6d5h ago)   6d6h
     kube-proxy-hlml9                       1/1     Running   1 (6d5h ago)   6d6h
     kube-proxy-vtccs                       1/1     Running   1 (6d5h ago)   6d6h
     kube-scheduler-k8s-master01            1/1     Running   1 (6d5h ago)   6d6h
     
    ```

  - 查看所有名称空间中的pod

    ```
     root@k8s-master01:~/test# kubectl get pod -A
     NAMESPACE      NAME                                   READY   STATUS    RESTARTS        AGE
     default        nginx                                  1/1     Running   0               38m
     kube-flannel   kube-flannel-ds-d2qjm                  1/1     Running   1 (6d5h ago)    6d5h
     kube-flannel   kube-flannel-ds-dqn8h                  1/1     Running   1 (6d5h ago)    6d5h
     kube-flannel   kube-flannel-ds-p9k7g                  1/1     Running   1 (6d5h ago)    6d5h
     kube-flannel   kube-flannel-ds-xjqj6                  1/1     Running   2 (4h25m ago)   6d5h
     
    ```

  ## **1.2 修改容器默认启动命令**

  更改容器的启动命令的操作也在创建pod时发生，只需要在创建的容器最后面加上一个command参数覆盖容器启动时的entrypoint即可，可选加args参数，entrypoint和args参数的作用待补充

  ps:查看参数，如果不记得容器里面的spec有哪些参数可以通过explain命令进行查询

  ```
   root@k8s-master01:~/test# kubectl explain pod.spec.containers
  ```

  ps：k8s调用集群的最小单位是pod，所以比pod中的配置是无法被k8s感知的，如果想要修改pod中的配置，只能将pod删除掉，再重新部署新的pod

  - 删除pod 的两种方法

    通过配置文件中的配置进行删除

    通过pod的名称进行删除

    ```
     root@k8s-master01:~/test# kubectl delete -f nginx.yaml 
     pod "nginx" deleted
     root@k8s-master01:~/test# kubectl delete pod nginx
     pod "nginx" deleted
     root@k8s-master01:~/test# kubectl create -f nginx.yaml 
     pod/nginx created
    ```

  - 修改容器启动是默认执行的命令

    ```
     root@k8s-master01:~/test# vim nginx.yaml 
     apiVersion: v1
     kind: Pod
     metadata: 
       labels:
         run: nginx
       name: nginx
     spec:
       containers:
       - image: nginx:1.15.12
         name: nginx
         command: [ "sleep", "10" ]
     
    ```

    创建pod

    ```
     root@k8s-master01:~/test# kubectl create -f nginx.yaml 
     pod/nginx created
     
    ```

    稍等一会，查看该容器状态

    发现容器已经变成了completed状态，是因为容器执行的命令不是前台程序，执行完该命令之后容器就退出了

    ```
     root@k8s-master01:~/test# kubectl get pod -o wide
     NAME    READY   STATUS      RESTARTS      AGE   IP           NODE         NOMINATED NODE   READINESS GATES
     nginx   0/1     Completed   2 (33s ago)   55s   10.244.2.3   k8s-node01   <none>           <none>
     
    ```



## **1.3 Pod 状态及 Pod 故障排查命令**

pod状态表

| **状态**                      | **说明**                                                     | **补充**                                                     |
| ----------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Pending（挂起）               | Pod 已被 Kubernetes 系统接收，但仍有一个或多个容器未被创建，如果pod长时间处于pending状态，可以通过 kubectl describe 查看处于 Pending 状态的原因 | 1.请求的资源太大，暂时无机器可供调度；2.挂载的文件不存在；3.节点状态都是异常导致集群内部无可用节点 |
| Running（运行中）             | Pod 已经被绑定到一个节点上，并且所有的容器都已经被创建，而且至少有一个是运行状态，或者是正在启动或者重启，可以通过 kubectl logs 查看 Pod 的日志 | 节点可用的标志：需要同时满足以下三点：1.pod状态为Running；2.容器全部启动（READY1/1）;3.RESTART次数没有一直增加 |
| Succeeded（成功）             | 所有容器执行成功并终止，并且不会再次重启，可以通过 kubectl logs 查看 Pod 日志 | 这个在job任务中经常出现，pod为一次性的，无报错执行完之后就会显示成功了（重启策略为never） |
| Failed（失败）                | 所有容器都已终止，并且至少有一个容器以失败的方式终止，也就是说这个容器 要么以非零状态退出，要么被系统终止，可以通过 logs 和 describe 查看 Pod 日 志和状态 | 跟上面一样，不过执行结果是失败                               |
| Unknown（未知）               | 通常是由于通信问题造成的无法获得 Pod 的状态                  | 一般是node节点挂了会有这个报错                               |
| ImagePullBackOff ErrImagePull | 镜像拉取失败，一般是由于1.镜像不存在、2.网络不通或者3.需要登录认证引起的，可 以使用 describe 命令查看具体原因 | 疑难杂症1.镜像的tag正确，镜像的拉取失败，操作节点的网络情况正常，仓库也是公开仓库，但是镜像拉取失败。像这种情况有可能是执行任务的那个node节点的服务器网络有问题。（因为主节点网络好不能代表从节点网络好，主节点上虽然能正常拉取镜像，但是实际的操作还是在从节点上）2.只要镜像仓库是私有的，就必须在yaml中配置认证相关的内容 |
| CrashLoopBackOff              | 容器启动失败，可以通过 logs 命令查看具体原因，一般为启动命令不正确，健 康检查不通过等 | 也有可能是因为容器中没有一个前台运行的进程导致的             |
| OOMKilled                     | 容器内存溢出，一般是容器的内存 Limit 设置的过小，或者程序本身有内存溢出， 可以通过 logs 查看程序启动日志 |                                                              |
| Terminating                   | Pod 正在被删除，可以通过 describe 查看状态                   | 一般来说pod一下子就回被删除的，如果在执行过程中pod一直处于Terminating状态，多半是因为由于别的资源在调用该pod导致，也有可能是节点出了问题，可以通过describe查看 |
| SysctlForbidden               | Pod 自定义了内核配置，但 kubelet 没有添加内核配置或配置的内核参数不支持， 可以通过 describe 查看具体原因 |                                                              |
| Completed                     | 容器内部主进程退出，一般计划任务执行结束会显示该状态，此时可以通过 logs 查看容器日志 | 容器生成时的命令不是前台的命令，执行结束之后，pod就会显示completed状态 |
| ContainerCreating             | Pod 正在创建，一般为正在下载镜像，或者有配置不当的地方，可以通过 describe 查看具体原因 |                                                              |



- 查看pod的详细状态信息

  ```
   root@k8s-master01:~/test# kubectl describe pod nginx
  ```

- 查看pod的日志

  `-f`后面接上pod的名称

  ```
   root@k8s-master01:~/test# kubectl logs -f kube-proxy-5bkbw -n kube-system
  ```



## **1.4 容器镜像拉取策略**

通过 spec.containers[].imagePullPolicy 参数可以指定容器的镜像拉取策略，目前支持的策略如下：

| **操作方式** | **说明**                                                     |
| ------------ | ------------------------------------------------------------ |
| Always       | 不管本地有没有镜像总是拉取。当镜像 tag 为 latest ，且 imagePullPolicy 未配置时，默认为 Always |
| Never        | 不管本地（当前node节点上）有没有镜像都不会从镜像仓库拉取镜像 |
| IfNotPresent | 本地无该镜像时会拉取镜像，本地有镜像时则不去仓库拉取。如果 tag 为非 latest，且 imagePullPolicy 未配置，默认为 IfNotPresent |

当镜像 tag 为 latest ，且 imagePullPolicy 未配置时，默认为 Always

本地有镜像时则不去仓库拉取。如果 tag 为非 latest，且 imagePullPolicy 未配置，默认为IfNotPresent

更改镜像拉取策略为IfNotPresent

```
 root@k8s-master01:~/test# vim nginx.yaml
 apiVersion: v1
 kind: Pod
 metadata:
   labels:
     run: nginx
   name: nginx
 spec:
   containers:
   - image: nginx:1.15.12
     name: nginx
     command: [ "sleep", "10" ]
     imagePullPolicy: IfNotPresent
 
```

查看创建容器过程中，是否拉取镜像

看event的部分

```
 root@k8s-master01:~/test# kubectl describe pod nginx
   Normal   Pulled     9m55s (x5 over 12m)  kubelet            Container image "nginx:1.15.12" already present on machine
 
```

查看创建pod过程中采用的拉取镜像的策略

```
 root@k8s-master01:~/test# kubectl get pod nginx -oyaml
 imagePullPolicy: IfNotPresent
 
```



## **1.5 Pod 重启策略**

可以使用 `spec.restartPolicy` 指定容器的重启策略，`restartPolicy`是pod级别的，与容器同级别

生产环境中用的最多的就是`Always`的pod重启策略。

`OnFailure`一般用于计划任务等不需要重启的策略。

`Never`一般不用。

| **操作方式** | **说明**                                  |
| ------------ | ----------------------------------------- |
| Always       | 默认策略。容器失效时，自动重启该容器      |
| OnFailure    | 容器以不为 0 的状态码终止，自动重启该容器 |
| Never        | 无论何种状态，都不会重启                  |

设置pod重启策略为`Never`

```
 root@k8s-master01:~/test# vim nginx.yaml 
 apiVersion: v1
 kind: Pod
 metadata: 
   labels:
     run: nginx
   name: nginx
 spec:
   restartPolicy: Never
   containers:
   - image: nginx
     name: nginx
     command: [ "sleep", "3" ]
 #   imagePullPolicy: IfNotPresent
 
```

检查pod是否重启过（`RESTARTS`的数值就是重启次数）

```
 root@k8s-master01:~/test# kubectl get pod  -o wide
 NAME    READY   STATUS      RESTARTS   AGE    IP           NODE         NOMINATED NODE   READINESS GATES
 nginx   0/1     Completed   0          107s   10.244.2.7   k8s-node01   <none>           <none>
 
```



## **1.6 Pod 的三种探针**

`startupProbe`只会在容器刚创建的时候探测一次，之后就不会探测了，`startupProbe`探测成功之后，就交给`livenessProbe`和`readinessProbe`循环探测了；如果`startupProbe`探测失败了，就会根据`startupProbe`的策略执行相应的重启策略。

| **种类**       | **说明**                                                     |
| -------------- | ------------------------------------------------------------ |
| startupProbe   | Kubernetes1.16 新加的探测方式，用于判断容器内的应用程序是否已经启动。如果 配置了 startupProbe，就会先禁用其他探测，直到它成功为止。如果探测失败，Kubelet 会杀死容器，之后根据重启策略进行处理，如果探测成功，或没有配置 startupProbe， 则状态为成功，之后就不再探测。 |
| livenessProbe  | 存活探针：用于探测容器是否在运行，如果探测失败，kubelet 会“杀死”容器并根据重启策略 进行相应的处理。如果未指定该探针，将默认为 Success |
| readinessProbe | 就绪探针：一般用于探测容器内的程序是否健康，即判断容器是否为就绪（Ready）状态。如果健康，Endpoints Controller会将该容器提供服务的Endpoints添加到所有的Service中，那么我们可以处理请求（只有该检查通过了。才会有流量接进来），反之 Endpoints Controller 将从所有的 Service 的 Endpoints 中删除此容器所在 Pod 的 IP 地址。如果未指定，将默认为 Success |

`startupProbe`一般用于启动时间非常长的应用，比如java应用。

## **1.7 Pod 探针的实现方式**

`HTTPGetAction`是最可靠的检测方法，但是也是最复杂的，需要开发人员结合代码进行配置。

| **实现方式**    | **说明**                                                     |
| --------------- | ------------------------------------------------------------ |
| ExecAction      | 在容器内执行一个指定的命令，如果命令返回值为 0，则认为容器健康 |
| TCPSocketAction | 通过 TCP 连接检查容器指定的端口，如果端口开放，则认为容器健康 |
| HTTPGetAction   | 对指定的 URL 进行 Get 请求，如果状态码在 200~400 之间，则认为容器健康 |

`ExecAction`：可以通过`echo $?`获取返回值，返回值为`0` ，则代表容器健康。

`TCPSocketAction`：查看端口是否存在，存在则代表容器健康。

`HTTPGetAction`：查看状态码是否在`200-400`之间，在此区间，则容器正常。通过`curl -I` 可以查看到网站返回的状态码。

```
 root@k8s-master01:~# curl -I baidu.com
 HTTP/1.1 200 OK
 Date: Wed, 15 Nov 2023 10:42:54 GMT
```

## **1.8 livenessProbe 和 readinessProbe**

健康检查的重要性：如果不加健康性检查，那么pod一旦被创建，就会被置为Running状态，该状态对于service来说就是代表容器正常运行，此时，如果有请求访问该服务，service就会将流量调度到该pod上。但是，此时有可能pod并没有准备好。第一类情况，该pod中的服务启动时间很短，pod马上就能提供正常服务；第二类情况，该pod中的服务启动时间很长，虽然pod的状态是Runing状态，但是，pod中的服务实际并没有正常运行，如果流量现在被分发到该pod上，这个pod是无法提供正常的服务的。没懂，没关系，请看VCR:

1. 创建一个没有探针的 Pod： 创建一个名为nginx 的pod，该pod执行的命令为睡眠30s，之后再启动nginx

```
 [root@k8s-master01 test]# vim pod.yaml 
 apiVersion: v1
 kind: Pod
 metadata:
   labels:
     run: nginx
   name: nginx
 spec:
   containers:
   - image: nginx
     name: nginx
     command:
     - sh
     - -c
     - sleep 30; nginx -g "daemon off;"
   restartPolicy: OnFailure
```

1. 通过curl命令访问nginx服务 curl这个nginx网址的动作一定要在30s之内完成，因为在30s之内，nginx服务还未启动，所以此时curl网页会失败（看到访问失败的提示，就是我们要看到的效果）

```
 [root@k8s-master01 test]# kubectl create -f pod.yaml 
 [root@k8s-master01 test]# kubectl get pod -owide
 NAME    READY   STATUS    RESTARTS   AGE     IP               NODE         NOMINATED NODE   READINESS GATES
 nginx   1/1     Running   0          7m12s   192.168.58.196   k8s-node02   <none>           <none>
 [root@k8s-master01 test]# curl 192.168.58.196
 [root@k8s-master01 test]# curl 192.168.58.196
 curl: (7) Failed connect to 192.168.58.196:80; Connection refused
 
```

结论：当未配置健康性检查时，对于启动时间过长的应用而言，pod存在无法正常提供服务的风险。

### **配置**`readinessProbe`和`LivenessProbe`探针

- 只有`readinessProbe`探测成功，`service`才会将服务的请求流量发送到该pod

- 探针要配置在容器层面，因为同一个pod中可能会有多个容器，但是每个容器的启动过程是不一样，所以探针是需要为容器单独配置的。

- 每个探针只能用四种探测方式(`ExecAction`,`TCPSocketAction`,`HTTPGetAction`,`gRPC`)中的一种，本例采用的探测方式为`HTTPGet``

- `path`路径是针对根路径写的

- `initialDelaySeconds`: 10 # 健康性检查延迟执行时间，就是当服务启动10s钟之后，再进行探测的延时时间。建议将该延时时间配置为服务启动的时间，例如：该服务启动需要40s，你可以将`initialDelaySeconds`配置为40，那么上面的`readinessProbe`就会在创建容器40s之后才开始工作。

- `timeoutSeconds`: 2 # 超时时间

- `periodSeconds`: 5 # 检测间隔

- successThreshold: 1 # 检查成功为 2 次表示就绪

- failureThreshold: 2 # 检测失败 1 次表示未就绪

  此例表示：当用户在访问容器中的nginx服务提供的index网页超过2s，而服务端未返回信息时，`readinessProbe`会间隔5s之后，再次对该资源进行探测，如果连续探测失败2次则认为该pod故障，就会让`service`切断该pod的流量，不对外提供服务；如果探测成功1次，`readinessProbe`就会认为该pod正常。只有容器的Ready个数为1/1，`readinessProbe`才会任务该pod正常。

- `tcpSocket`: # 端口检测方式 `port`: 80 该探测方式就是探测容器的端口是否可以正常启动，如果正常启动，则代表该容器正常；如果端口故障，则该容器会指定对应的重启策略。

注意：`readinessProbe`和`livenessProbe`的区别： `readiness`探测失败会导致流量被切断，`livenessProbe`探测失败会导致pod被重启。



#### **测试readinessProbe探针**

##### **pod正常情况下**

1. 配置readinessProbe探针

   ```
    [root@k8s-master01 test]# vim pod.yaml 
    apiVersion: v1
    kind: Pod
    metadata:
      labels:
        run: nginx
      name: nginx
    spec:
      containers:
      - image: nginx
      containers:
      - image: nginx
        name: nginx
        readinessProbe: # 可选，健康检查。若成功，则接入流量；若失败，则切断流量。
            httpGet: # 接口检测方式，注意三种检查方式同时只能使用一种。
              path: /index.html # 检查路径
              port: 80
              scheme: HTTP # HTTP or HTTPS
             #httpHeaders: # 可选, 检查的请求头
             #- name: end-user
             # value: Jason
            initialDelaySeconds: 10 # 初始化时间, 健康检查延迟执行时间
            timeoutSeconds: 2 # 超时时间
            periodSeconds: 5 # 检测间隔
            successThreshold: 1 # 检查成功为 1 次表示就绪，可以接入流量
            failureThreshold: 2 # 检测失败 2 次表示未就绪，开始切断流量
        command:
        - sh
        - -c
        - sleep 30; nginx -g "daemon off;"
      restartPolicy: OnFailure
   ```

2. 检查容器是否可以正常访问

   该检查操作需要在容器未启动完成之前进行操作

   ```
    root@k8s-master01:~/test# kubectl get pod -o wide
    NAME    READY   STATUS    RESTARTS   AGE   IP            NODE         NOMINATED NODE   READINESS GATES
    nginx   0/1     Running   0          10s   10.244.2.10   k8s-node02   <none>           <none>
    root@k8s-master01:~/test# curl 10.244.2.10
    curl: (7) Failed to connect to 10.244.2.10 port 80: Connection refused
    root@k8s-master01:~/test# curl 10.244.2.10
   ```

3. 检查容器是否可以正常访问

   该检查操作需要在容器未启动完成之前进行操作

   ```
    root@k8s-master01:~/test# kubectl get pod -o wide
    NAME    READY   STATUS    RESTARTS   AGE   IP            NODE         NOMINATED NODE   READINESS GATES
    nginx   1/1     Running   0          40s   10.244.2.10   k8s-node02   <none>           <none>
    root@k8s-master01:~/test# curl 10.244.2.10
    <!DOCTYPE html>
    <html>
    <head>
    <title>Welcome to nginx!</title>
    <style>
    html { color-scheme: light dark; }
    body { width: 35em; margin: 0 auto;
    font-family: Tahoma, Verdana, Arial, sans-serif; }
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

结论：readinessProbe探针可以待容器完全启动，应用都正常的情况下，再将pod暴露到网络中，供service进行调用。



##### **pod异常情况下**

1. 配置readinessProbe探针

   在该示例中，我们将readinessProbe探针的检测方式设置为HTTPGet，检测的端口为8080，众所周知啊，nginx的默认启动的端口为80，此处我们将检测的端口设置为8080，所以readinessProbe的探测一定是会失败的。失败的情况下我们再去观察pod是否会被重启。

   先说结论啊：不会重启的，这辈子都不会了，因为我们仅仅只配置了readinessProbe，再强调一遍，readinessProbe探针只会影响service的流量分发，不管pod重启啊，所以，只要readinessProbe探针探测失败，service就不会讲流量分发过来，但是并不会影响pod的重启，不过readinessProbe探针还是会一直对pod进行7*24小时的循环探测（不论readinessProbe的探测是成功还是失败）。

   ```
    root@k8s-master01:~/test# cat pod.yaml 
    apiVersion: v1
    kind: Pod
    metadata:
      labels:
        run: nginx
      name: nginx
    spec:
      containers:
      - image: nginx
      containers:
      - image: nginx
        name: nginx
        readinessProbe: # 可选，健康检查。若成功，则接入流量；若失败，则切断流量。
            httpGet: # 接口检测方式，注意三种检查方式同时只能使用一种。
              path: /index.html # 检查路径
              port: 8080
              scheme: HTTP # HTTP or HTTPS
             #httpHeaders: # 可选, 检查的请求头
             #- name: end-user
             # value: Jason
            initialDelaySeconds: 10 # 初始化时间, 健康检查延迟执行时间
            timeoutSeconds: 2 # 超时时间
            periodSeconds: 5 # 检测间隔
            successThreshold: 1 # 检查成功为 1 次表示就绪，可以接入流量
            failureThreshold: 2 # 检测失败 2 次表示未就绪，开始切断流量
        command:
        - sh
        - -c
        - sleep 30; nginx -g "daemon off;"
      restartPolicy: OnFailure
    
   ```

   备用啊

   ```
    [root@k8s-master01 test]# vim pod.yaml 
    apiVersion: v1
    kind: Pod
    metadata:
      labels:
        run: nginx
      name: nginx
    spec:
      containers:
      - image: nginx
      containers:
      - image: nginx
        name: nginx
        readinessProbe: # 可选，健康检查。若成功，则接入流量；若失败，则切断流量。
            httpGet: # 接口检测方式，注意三种检查方式同时只能使用一种。
              path: /index.html # 检查路径
              port: 8080    #把端口号改成8080
              scheme: HTTP # HTTP or HTTPS
             #httpHeaders: # 可选, 检查的请求头
             #- name: end-user
             # value: Jason
            initialDelaySeconds: 10 # 初始化时间, 健康检查延迟执行时间
            timeoutSeconds: 2 # 超时时间
            periodSeconds: 5 # 检测间隔
            successThreshold: 1 # 检查成功为 1 次表示就绪，可以接入流量
            failureThreshold: 2 # 检测失败 2 次表示未就绪，开始切断流量
        livenessProbe: # 可选，健康检查。若成功，则无动作；若失败，则根据下面的重启策略（restartPolicy）重启pod。
            tcpSocket: # 端口检测方式
              port: 80
            initialDelaySeconds: 10 # 初始化时间
            timeoutSeconds: 2 # 超时时间
            periodSeconds: 5 # 检测间隔
            successThreshold: 1 # 检查成功为 2 次表示就绪
            failureThreshold: 2 # 检测失败 1 次表示未就绪
        command:
        - sh
        - -c
        - sleep 30; nginx -g "daemon off;"
      restartPolicy: OnFailure
   ```

2. 检查pod状态 在pod创建完成后的30s之内，发现pod的状态虽然是Running状态，但是容器的数量一直都是0/1，代表该pod目前还不能对外提供服务

```
 [root@k8s-master01 test]# kubectl delete -f pod.yaml
 [root@k8s-master01 test]# kubectl create -f pod.yaml
 root@k8s-master01:~/test# kubectl get pod
 NAME    READY   STATUS    RESTARTS   AGE
 nginx   0/1     Running   0          113s
 root@k8s-master01:~/test# kubectl get pod
 NAME    READY   STATUS    RESTARTS   AGE
 nginx   0/1     Running   0          115s
 
```

1. 查看pod的内部发生了什么 探针探测失败时才会在event中打印日志，成功是不打印日志的。（所以在上个实验中，使用describe命令时，在输出结果中的Events中是无法看见readinessProbe的异常情况的）

   `S`tarted container nginx` Warning Unhealthy 107s (x21 over 3m22s) kubelet`由此可见：在3分22秒之内，readinessProbe已经探测失败了21次了，但是容器依然没有重启。

```
 root@k8s-master01:~/test# kubectl describe pod nginx
 ---
 Events:
   Type     Reason     Age                    From               Message
   ----     ------     ----                   ----               -------
   Normal   Scheduled  3m37s                  default-scheduler  Successfully assigned default/nginx to k8s-node02
   Normal   Pulling    3m37s                  kubelet            Pulling image "nginx"
   Normal   Pulled     3m32s                  kubelet            Successfully pulled image "nginx" in 4.195205549s (4.195212157s including waiting)
   Normal   Created    3m32s                  kubelet            Created container nginx
   Normal   Started    3m32s                  kubelet            Started container nginx
   Warning  Unhealthy  107s (x21 over 3m22s)  kubelet            Readiness probe failed: Get "http://10.244.2.11:8080/index.html": dial tcp 10.244.2.11:8080: connect: connection refused
 
```

1. 查看pod状态

已经经过好久了，但是pod只是探测失败，并未重启，这就是readinessProbe的作用，是用来切断service的流量的。

```
 root@k8s-master01:~/test# kubectl get pod
 NAME    READY   STATUS    RESTARTS   AGE
 nginx   0/1     Running   0          5m16s
 
```

#### **测试livenessProbe探针**

##### **pod正常情况下**

1. 配置livenessProbe

   本实例中，我们模拟启动耗时较长的应用，再使用livenessProbe对pod进行循环探测端口以确保pod正常。

   实验条件：

   假设nginx应用启动耗时30s（sleep 30）

   检测延时时间设置为30s（initialDelaySeconds: 30）

   检测方式：tcpSocket（用于检测端口的tcpSocket:）

   监测对象是80端口（port: 80）

   ```
    [root@k8s-master01 test]# vim pod.yaml 
    apiVersion: v1
    kind: Pod
    metadata:
      labels:
        run: nginx
      name: nginx
    spec:
      containers:
      - image: nginx
      containers:
      - image: nginx
        name: nginx
        livenessProbe: # 可选，健康检查。若成功，则无动作；若失败，则根据下面的重启策略（restartPolicy）重启pod。
          tcpSocket: # 端口检测方式
            port: 80
          initialDelaySeconds: 30 # 初始化时间
          timeoutSeconds: 2 # 超时时间
          periodSeconds: 5 # 检测间隔
          successThreshold: 1 # 检查成功为 2 次表示就绪
          failureThreshold: 2 # 检测失败 1 次表示未就绪
        command:
        - sh
        - -c
        - sleep 30; nginx -g "daemon off;"
      restartPolicy: OnFailure
   ```

2. 启动pod

   ```
    root@k8s-master01:~/test# kubectl delete -f pod.yaml 
    pod "nginx" deleted
    root@k8s-master01:~/test# kubectl create -f pod.yaml 
    pod/nginx created
   ```

3. 检查pod状态

   ```
    root@k8s-master01:~/test# kubectl get pod -o wide
    NAME    READY   STATUS    RESTARTS   AGE   IP            NODE         NOMINATED NODE   READINESS GATES
    nginx   1/1     Running   0          11s   10.244.2.12   k8s-node02   <none>           <none>
    
   ```

4. 监测服务是否可以正常访问

   在30s内，nginx服务是无法正常提供服务的

   ```
    root@k8s-master01:~/test# kubectl get pod -o wide
    NAME    READY   STATUS    RESTARTS   AGE   IP            NODE         NOMINATED NODE   READINESS GATES
    nginx   1/1     Running   0          13s   10.244.2.14   k8s-node02   <none>           <none>
    root@k8s-master01:~/test# curl 10.244.2.14
    curl: (7) Failed to connect to 10.244.2.14 port 80: Connection refused
    
   ```

5. 检查pod详细状态

   pod正常启动，没有发现异常

   ```
    root@k8s-master01:~/test# kubectl descrivbe pod nginx
    ---
    Events:
      Type    Reason     Age    From               Message
      ----    ------     ----   ----               -------
      Normal  Scheduled  2m12s  default-scheduler  Successfully assigned default/nginx to k8s-node02
      Normal  Pulling    2m11s  kubelet            Pulling image "nginx"
      Normal  Pulled     2m6s   kubelet            Successfully pulled image "nginx" in 5.634722374s (5.634726784s including waiting)
      Normal  Created    2m6s   kubelet            Created container nginx
      Normal  Started    2m5s   kubelet            Started container nginx
    
   ```

##### **pod异常情况下**

pod在异常情况下，会被livenessProbe探测为失败，就会导致pod一直被重启。

1. 配置livenessProbe

   ```
    root@k8s-master01:~/test# vim pod.yaml 
    apiVersion: v1
    kind: Pod
    metadata:
      labels:
        run: nginx
      name: nginx
    spec:
      containers:
      - image: nginx
      containers:
      - image: nginx
        name: nginx
        livenessProbe: # 可选，健康检查。若成功，则无动作；若失败，则根据下面的重启策略（restartPolicy）重启pod。
          tcpSocket: # 端口检测方式
            port: 8080
          initialDelaySeconds: 30 # 初始化时间
          timeoutSeconds: 2 # 超时时间
          periodSeconds: 5 # 检测间隔
          successThreshold: 1 # 检查成功为 2 次表示就绪
          failureThreshold: 2 # 检测失败 1 次表示未就绪
        command:
        - sh
        - -c
        - sleep 30; nginx -g "daemon off;"
      restartPolicy: OnFailure
    
   ```

2. 启动pod

   ```
    root@k8s-master01:~/test# kubectl delete -f pod.yaml 
    pod "nginx" deleted
    root@k8s-master01:~/test# kubectl create -f pod.yaml 
    pod/nginx created
   ```

3. 检查pod状态

   因为livenessProbe一直在探测8080端口，但是探测不到，就导致了探测失败，然后就一直重启。

   ```
    root@k8s-master01:~/test# kubectl get pod -o wide
    NAME    READY   STATUS             RESTARTS      AGE     IP            NODE         NOMINATED NODE   READINESS GATES
    nginx   0/1     CrashLoopBackOff   5 (76s ago)   8m16s   10.244.2.16   k8s-node02   <none>           <none>
    
   ```

4. 查看pod日志

   ```
    root@k8s-master01:~/test# kubectl describe pod nginx
    ---
    Events:
      Type     Reason     Age                    From               Message
      ----     ------     ----                   ----               -------
      Normal   Scheduled  8m44s                  default-scheduler  Successfully assigned default/nginx to k8s-node02
      Normal   Pulled     8m39s                  kubelet            Successfully pulled image "nginx" in 4.215320758s (4.215339705s including waiting)
      Normal   Pulled     7m31s                  kubelet            Successfully pulled image "nginx" in 3.010210738s (3.01021607s including waiting)
      Normal   Pulled     6m20s                  kubelet            Successfully pulled image "nginx" in 3.055648235s (3.055652158s including waiting)
      Normal   Killing    5m44s (x3 over 8m4s)   kubelet            Container nginx failed liveness probe, will be restarted
      Normal   Pulling    5m14s (x4 over 8m43s)  kubelet            Pulling image "nginx"
      Normal   Created    5m10s (x4 over 8m39s)  kubelet            Created container nginx
      Normal   Started    5m10s (x4 over 8m39s)  kubelet            Started container nginx
      Normal   Pulled     5m10s                  kubelet            Successfully pulled image "nginx" in 3.1806318s (3.180656536s including waiting)
      Warning  Unhealthy  3m29s (x9 over 8m9s)   kubelet            Liveness probe failed: dial tcp 10.244.2.16:8080: connect: connection refused
    
   ```

   

## **1.9 配置 StartupProbe**

对于启动时间很长的应用，需要使用startupProbe。 如果没有startupProbe，对于启动时间较长的应用（假设该应用需要启动200s）只有两种办法：1. 增加initialDelaySeconds，比如设置为220，这个操作会影响新pod生效的时间，当故障pod被探测失败后，系统会创建一个新的pod，但是由于initialDelaySeconds被设置为220，所以新的pod会在220s之后才能提供服务，这在生产中是不被允许的。2. 增加探测间隔periodSeconds和判定失败的次数failureThreshold，这个会导致pod内部错误无法被及时发现，及时处理。所以，k8s增加了启动探针startupProbe来应对启动时间长的应用。

- 配置startupProbe 配置接口级的探测方式，就是检测index文件是否存在。

```
 apiVersion: v1 # 必选，API 的版本号
 kind: Pod # 必选，类型 Pod
 metadata: # 必选，元数据
  name: nginx # 必选，符合 RFC 1035 规范的 Pod 名称
 spec: # 必选，用于定义 Pod 的详细信息
  containers: # 必选，容器列表
  - name: nginx # 必选，符合 RFC 1035 规范的容器名称
  image: nginx:1.15.12 # 必选，容器所用的镜像的地址
  imagePullPolicy: IfNotPresent
  command: # 可选，容器启动执行的命令
  - sh
  - -c
  - sleep 30; nginx -g "daemon off;"
  startupProbe:
  tcpSocket: # 端口检测方式
  port: 80
  initialDelaySeconds: 10 # 初始化时间
  timeoutSeconds: 2 # 超时时间
  periodSeconds: 5 # 检测间隔
  successThreshold: 1 # 检查成功为 2 次表示就绪
  failureThreshold: 5 # 检测失败 1 次表示未就绪
  readinessProbe: # 可选，健康检查。注意三种检查方式同时只能使用一种。
  httpGet: # 接口检测方式
  path: /index.html # 检查路径
  port: 80
  scheme: HTTP # HTTP or HTTPS
  #httpHeaders: # 可选, 检查的请求头
  #- name: end-user
  # value: Jason
  initialDelaySeconds: 10 # 初始化时间, 健康检查延迟执行时间
  timeoutSeconds: 2 # 超时时间
  periodSeconds: 5 # 检测间隔
  successThreshold: 1 # 检查成功为 2 次表示就绪
  failureThreshold: 2 # 检测失败 1 次表示未就绪
  livenessProbe: # 可选，健康检查
  exec: # 端口检测方式
  command:
  - sh
  - -c
  - pgrep nginx
  initialDelaySeconds: 10 # 初始化时间
  timeoutSeconds: 2 # 超时时间
  periodSeconds: 5 # 检测间隔
  successThreshold: 1 # 检查成功为 2 次表示就绪
  failureThreshold: 2 # 检测失败 1 次表示未就绪
  ports: # 可选，容器需要暴露的端口号列表
  - containerPort: 80 # 端口号
  restartPolicy: Never
```

检查pod是否正常运行

```
 [root@k8s-master01 test]# kubectl get pod
```

模拟容器故障 进入容器，删除index文件

```
 [root@k8s-master01 test]# kubectl exec -it nginx -- sh
 / # cd /usr/share/nginx/html
 / # rm -rf index.html
```

再次查看pod状态

```
 [root@k8s-master01 test]# kubectl get pod
```

此时可以看到pod还不会被重启，因为

## **1.10 preStop 和 postStart**



```
 apiVersion: v1 # 必选，API 的版本号
 kind: Pod # 必选，类型 Pod
 metadata: # 必选，元数据
  name: nginx # 必选，符合 RFC 1035 规范的 Pod 名称
 spec: # 必选，用于定义 Pod 的详细信息
  containers: # 必选，容器列表
  - name: nginx # 必选，符合 RFC 1035 规范的容器名称
  image: nginx:1.15.12 # 必选，容器所用的镜像的地址
  imagePullPolicy: IfNotPresent
  lifecycle:
  postStart: # 容器创建完成后执行的指令, 可以是 exec httpGet TCPSocket
  exec:
  command:
  - sh
  - -c
  - 'mkdir /data/'
  preStop:
  exec:
  command:
  - sh
  - -c
  - sleep 10
  ports: # 可选，容器需要暴露的端口号列表
  - containerPort: 80 # 端口号
  restartPolicy: Never
```





## **1.11 gRPC 探测（1.24 默认开启）**



```
 apiVersion: v1
 kind: Pod
 metadata:
  name: etcd-with-grpc
 spec:
  containers:
  - name: etcd
  image: registry.cnhangzhou.aliyuncs.com/google_containers/etcd:3.5.1-0
  command: [ "/usr/local/bin/etcd", "--data-dir", "/var/lib/etcd", "--
 listen-client-urls", "http://0.0.0.0:2379", "--advertise-client-urls",
 "http://127.0.0.1:2379", "--log-level", "debug"]
  ports:
  - containerPort: 2379
  livenessProbe:
  grpc:
  port: 2379
  initialDelaySeconds: 10
```