什么是有状态应用，什么是无状态应用？

```
 应用的无状态和有状态!
 什么是有状态和无状态 ?
 场景:
 
 当用户登录时,将session或者token传给应用服务器管理,应用服务器里持有用户的上下文信息，这时应用服务器是有状态的 .
 
 同样用户登陆时,我们将session或token存储在第三方的一些服务或者中间件上，比如存储在redis上。此时应用服务器不保存上下文信息，只负责对用户的每次请求进行处理,然后返回处理的结果即可,这时应用服务器是无状态的.
 
 无状态和有状态的优缺点:
 有状态
 缺点：服务间数据需要同步 主从同步 副本同步等 扩容复杂 双机热备等 宕机容易丢失数据
 优点: 不需要额外的持久存储；通常，为低延时优化。
 无状态
 优点：服务间数据不需要同步 扩容快速 热备冷备切换容易 容易水平扩展。
 缺点: 需要额外的持久存储
```

如何构建有状态和无状态?

```
 关于构建可伸缩的有状态服务，可以看下这篇文章的介绍
 http://www.infoq.com/cn/news/2015/12/scaling-stateful-services
 构建无状态:
 
 将内存中的会话数据,如session,存放在第三方的一些服务或者中间件上,如使用redis做缓存
 
 将业务数据放在统一的数据库中,如mysql数据库,如果性能扛不住,可以进行系统拆分,功能拆分,读写拆分,aop拆分,模块拆分,使用分布式数据库
 
 对于文件，照片之类的数据，存放在统一的对象存储里面，通过CDN进行预加载
 
 对于非结构化数据，可以存在在统一的搜索引擎里面，例如solr
```



## **部署一个deployment**

- 生成部署deploymeny的yaml文件

--image指定拉取的镜像，建议使用国内的网址，或者通过vpn进行获取国外镜像

--replicas是副本的个数

--dry-run=client是空跑，不会真的生成pod

-o yaml 会真的生成yaml，就根据这个yaml文件修修改改就是一个最基本的deployment部署文件了

```
 [root@k8s-master01 dp]# kubectl create deployment nginx --image=registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12-alpine --replicas=3 -o yaml --dry-run=client > nginx-deployment.yaml
 
 [root@k8s-master01 dp]# cat nginx-deployment.yaml 
 apiVersion: apps/v1
 kind: Deployment
 metadata:
 #  creationTimestamp: null
   labels:
     app: nginx
   name: nginx
 spec:
   replicas: 3
   selector:
     matchLabels:
       app: nginx
 #  strategy: {}
   template:
     metadata:
 #      creationTimestamp: null
       labels:
         app: nginx
     spec:
       containers:
       - image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12-alpine
         name: nginx
 #        resources: {}
 #status: {}
 
```

- 创建一个deployment

注意这里镜像地址要写国内的地址，如果写国外的地址，有可能会拉取不下来镜像，产生镜像路拉取失败的报错

```
 [root@k8s-master01 dp]# vim nginx-dp.yaml
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
 
 [root@k8s-master01 dp]# kubectl create -f nginx-dp.yaml
 [root@k8s-master01 ~]# kubectl get deployment
 NAME    READY   UP-TO-DATE   AVAILABLE   AGE
 nginx   3/3     3            3           3m6s
 [root@k8s-master01 dp]# kubectl delete -f nginx-dp.yaml
```

## **查看deployment**

查看通过deployment创建的资源

```
 [root@k8s-master01 ~]# kubectl get deployment
 NAME    READY   UP-TO-DATE   AVAILABLE   AGE
 nginx   3/3     3            3           3m6s
 
 [root@k8s-master01 ~]# kubectl get replicaset
 NAME              DESIRED   CURRENT   READY   AGE
 nginx-bf75b99b6   3         3         3       5m18s
 
 [root@k8s-master01 ~]# kubectl get pod
 NAME                    READY   STATUS    RESTARTS   AGE
 nginx-bf75b99b6-56cp9   1/1     Running   0          5m25s
 nginx-bf75b99b6-bcdgl   1/1     Running   0          5m25s
 nginx-bf75b99b6-l8hpk   1/1     Running   0          5m25s
 
 [root@k8s-master01 ~]# kubectl get pod -o wide
 NAME                    READY   STATUS    RESTARTS   AGE     IP               NODE         NOMINATED NODE   READINESS GATES
 nginx-bf75b99b6-56cp9   1/1     Running   0          5m29s   192.168.58.194   k8s-node02   <none>           <none>
 nginx-bf75b99b6-bcdgl   1/1     Running   0          5m29s   192.168.85.199   k8s-node01   <none>           <none>
 nginx-bf75b99b6-l8hpk   1/1     Running   0          5m29s   192.168.58.193   k8s-node02   <none>           <none>
 
```



通过deployment创建的pod是由deployment进行维护的，当集群中有pod故障时，delopyment会自动的删除该pod，并创建一个新的健康的pod

```
 [root@k8s-master01 ~]# kubectl get pod
 NAME                    READY   STATUS    RESTARTS   AGE
 nginx-bf75b99b6-56cp9   1/1     Running   0          5m25s
 nginx-bf75b99b6-bcdgl   1/1     Running   0          5m25s
 nginx-bf75b99b6-l8hpk   1/1     Running   0          5m25s
 
 [root@k8s-master01 ~]# kubectl delete pod nginx-bf75b99b6-56cp9
 pod "nginx-bf75b99b6-56cp9" deleted
 
 [root@k8s-master01 ~]# kubectl get pod
 NAME                    READY   STATUS    RESTARTS   AGE
 nginx-bf75b99b6-bcdgl   1/1     Running   0          9m12s
 nginx-bf75b99b6-l8hpk   1/1     Running   0          9m12s
 nginx-bf75b99b6-ln6ck   1/1     Running   0          5s
 
```



- 查看deployment创建过程

1. 修改deployment配置文件

   修改副本数量为6

   ```
    [root@k8s-master01 ~]# vim nginx-deployment.yaml 
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      labels:
        app: nginx
      name: nginx
    spec:
      replicas: 6
      selector:
        matchLabels:
          app: nginx
      template:
        metadata:
          labels:
            app: nginx
        spec:
          containers:
          - image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12-alpine
            name: nginx
    
   ```

2. 将配置文件生效

   ```
    [root@k8s-master01 ~]# kubectl replace -f nginx-deployment.yaml 
    deployment.apps/nginx replaced
    
   ```

3. 可以使用 rollout 命令查看整个 Deployment 创建的状态

   ```
   [root@k8s-master01 ~]# kubectl rollout status deployment/nginx
   deployment "nginx" successfully rolled out
   [root@k8s-master01 ~]# kubectl get pod
   NAME                    READY   STATUS    RESTARTS   AGE
   nginx-bf75b99b6-bcdgl   1/1     Running   0          18m
   nginx-bf75b99b6-gfg46   1/1     Running   0          10s
   nginx-bf75b99b6-gwc7b   1/1     Running   0          10s
   nginx-bf75b99b6-l8hpk   1/1     Running   0          18m
   nginx-bf75b99b6-ln6ck   1/1     Running   0          9m9s
   nginx-bf75b99b6-lvzxz   1/1     Running   0          10s
   ```



查看当前名称空间下面所有的Replicaset

```
[root@k8s-master01 ~]# kubectl get rs
NAME              DESIRED   CURRENT   READY   AGE
nginx-bf75b99b6   6         6         6       20m
```

查看当前名称空间下所有labels为app=nginx标签的Replicas

```
[root@k8s-master01 ~]# kubectl get rs -l app=nginx
NAME              DESIRED   CURRENT   READY   AGE
nginx-bf75b99b6   6         6         6       21m
```

查看各个pod以及他们对应的labels

```
[root@k8s-master01 ~]# kubectl get pod --show-labels
NAME                    READY   STATUS    RESTARTS   AGE    LABELS
nginx-bf75b99b6-bcdgl   1/1     Running   0          22m    app=nginx,pod-template-hash=bf75b99b6
nginx-bf75b99b6-gfg46   1/1     Running   0          4m6s   app=nginx,pod-template-hash=bf75b99b6
nginx-bf75b99b6-gwc7b   1/1     Running   0          4m6s   app=nginx,pod-template-hash=bf75b99b6
nginx-bf75b99b6-l8hpk   1/1     Running   0          22m    app=nginx,pod-template-hash=bf75b99b6
nginx-bf75b99b6-ln6ck   1/1     Running   0          13m    app=nginx,pod-template-hash=bf75b99b6
nginx-bf75b99b6-lvzxz   1/1     Running   0          4m6s   app=nginx,pod-template-hash=bf75b99b6
```





## **Deployment滚动更新**

滚动更新的过程，先生成一个副本数为1的新的rs，再将旧的rs副本数减1，待新的pod启动之后，再将新的rs的副本数再加1，旧的rs副本数再减1，直到旧的副本数为0。在通过set命令或者edit命令更新完deployment之后，可以通过describe deployment 的命令看到这个过程

```
[root@k8s-master01 deployment]# kubectl describe deployment nginx
```



只有修改了templete 的spec参数，才会触发deployment的更新

更新deployment的三种方式

在更新deployment的过程中，注意yaml的版本和当前正在运行的deployment的版本的区别（有可能当前的yaml的版本并不是最新的，因为在操作deployment时，可能并不是通过修改yaml文件进行操作的，如果直接通过命令进行操作的话，就会只更新了deployment，而不会去更新yaml文件，就会导致yaml文件有滞后性，如果此时再通过yaml文件进行配置deployment，就会导致未被记录到yaml文件中的配置信息丢失）



1. set命令

   ```
   kubectl set image deployment nginx nginx=registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12 --record
   ```

   ```
   kubectl rollout status deployment nginx
   ```

2. edit命令

   修改完配置文件之后，可以通过`:wq`或者`shift+zz`进行保存操作

   保存完之后，配置文件立即生效

   ```
    kubectl edit deployment nginx
    kubectl get pod
   ```

3. vim 修改deployment的yaml文件

   

   通过直接修改yaml文件的方式进行更新deployment时，需要注意两点

   1. 需要根据deployment重新导出yaml文件，再对新生成的配置文件进行修改

      同样的，自己手动生成的yaml文件需要将状态信息删除掉，才能进行使用

      ```
      [root@k8s-master01 deployment]# kubectl get deployment nginx -o yaml > new.yaml
      [root@k8s-master01 deployment]# cat new.yaml 
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        labels:
          app: nginx
        name: nginx-manual
      spec:
        replicas: 6
        selector:
          matchLabels:
            app: nginx
        strategy:
          rollingUpdate:
            maxSurge: 25%
            maxUnavailable: 25%
          type: RollingUpdate
        template:
          metadata:
            labels:
              app: nginx
          spec:
            containers:
            - image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12-alpine
              imagePullPolicy: IfNotPresent
              name: nginx
            restartPolicy: Always
            schedulerName: default-scheduler
            securityContext: {}
            terminationGracePeriodSeconds: 30
      ```

      生成完yaml文件之后，还需要手动对该文件进行配置，后续更新才能生效（总得改点什么东西才叫更新吧）

   2. 修改yaml文件之后，需要对yaml文件进行手动生效

      可以通过apply命令，或者replace命令

      ```
      [root@k8s-master01 deployment]# kubectl replace -f new.yaml·
      ```





## **Deployment回滚**



先通过record记录几个更改的记录

再通过history查看历史记录

再进行恢复



1. 修改deployment

   ```
   [root@k8s-master01 deployment]# kubectl set image deployment nginx nginx=dotbalo/canary:v1 --record
   Flag --record has been deprecated, --record will be removed in the future
   deployment.apps/nginx image updated
   You have new mail in /var/spool/mail/root
   [root@k8s-master01 deployment]# kubectl set image deployment nginx nginx=dotbalo/canary:v2 --record
   Flag --record has been deprecated, --record will be removed in the future
   deployment.apps/nginx image updated
   ```

2. 查看deployment历史记录

   ```
   [root@k8s-master01 deployment]# kubectl rollout history deployment nginx
   deployment.apps/nginx 
   REVISION  CHANGE-CAUSE
   2         kubectl set image deployment nginx nginx=nginx:1.9.1 --record=true
   8         kubectl set image deployment nginx nginx=registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12 --record=true
   9         kubectl set image deployment nginx nginx=registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12 --record=true
   10        kubectl set image deployment nginx nginx=dotbalo/canary:v1 --record=true
   11        kubectl set image deployment nginx nginx=dotbalo/canary:v2 --record=true
   ```

3. 查看某个版本的具体信息

   ```
   [root@k8s-master01 deployment]# kubectl rollout history deployment nginx --revision=8
   deployment.apps/nginx with revision #8
   Pod Template:
     Labels:	app=nginx
   	pod-template-hash=bf75b99b6
     Annotations:	kubernetes.io/change-cause: kubectl set image deployment nginx nginx=registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12 --record=true
     Containers:
      nginx:
       Image:	registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12-alpine
       Port:	<none>
       Host Port:	<none>
       Environment:	<none>
       Mounts:	<none>
     Volumes:	<none>
   ```

4. deployment回滚

   - 回滚到上个版本

     ```
     [root@k8s-master01 deployment]# kubectl rollout undo deployment nginx
     deployment.apps/nginx rolled back
     ```

   - 回滚到指定版本

     ```
     [root@k8s-master01 deployment]# kubectl rollout undo deployment nginx --to-revision=8
     deployment.apps/nginx rolled back
     ```





## **Deployment的手动扩缩容**



无论什么情况下，都是不建议缩容，如果必须要缩容，请小心谨慎

扩容的两种方式：通过edit命令，或者通过scale命令

1. edit命令

   将副本数改成7

   ```
   [root@k8s-master01 deployment]# kubectl rollout undo deployment nginx --to-revision=8
   deployment.apps/nginx rolled back
   You have new mail in /var/spool/mail/root
   [root@k8s-master01 deployment]# kubectl edit deployment nginx
   # Please edit the object below. Lines beginning with a '#' will be ignored,
   # and an empty file will abort the edit. If an error occurs while saving this file will be
   # reopened with the relevant failures.
   #
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     annotations:
       deployment.kubernetes.io/revision: "13"
       kubernetes.io/change-cause: kubectl set image deployment nginx nginx=registry.cn-beijing.aliyuncs.com/dotbalo/ngin
   x:1.15.12
         --record=true
     creationTimestamp: "2023-06-18T10:20:19Z"
     generation: 18
     labels:
       app: nginx
     name: nginx
     namespace: default
     resourceVersion: "36774"
     uid: 56697ece-6767-4a73-9116-76dd3df7c131
   spec:
     progressDeadlineSeconds: 600
     replicas: 7
     revisionHistoryLimit: 10
     selector:
       matchLabels:
         app: nginx
     strategy:
   "/tmp/kubectl-edit-3836223243.yaml" 68L, 1985C written
   deployment.apps/nginx edited
   
   [root@k8s-master01 deployment]# kubectl get pod
   NAME                    READY   STATUS    RESTARTS   AGE
   nginx-bf75b99b6-69lg8   1/1     Running   0          14m
   nginx-bf75b99b6-f8z2r   1/1     Running   0          14m
   nginx-bf75b99b6-h97hg   1/1     Running   0          14m
   nginx-bf75b99b6-klmlm   1/1     Running   0          70s
   nginx-bf75b99b6-rs5hm   1/1     Running   0          14m
   nginx-bf75b99b6-tbch8   1/1     Running   0          14m
   nginx-bf75b99b6-wclld   1/1     Running   0          14m
   ```

2. scale命令

   ```
   [root@k8s-master01 deployment]# kubectl scale deployment nginx --replicas=9
   deployment.apps/nginx scaled
   [root@k8s-master01 deployment]# kubectl get pod
   NAME                    READY   STATUS    RESTARTS   AGE
   nginx-bf75b99b6-69lg8   1/1     Running   0          15m
   nginx-bf75b99b6-7zz52   1/1     Running   0          4s
   nginx-bf75b99b6-f8z2r   1/1     Running   0          15m
   nginx-bf75b99b6-h97hg   1/1     Running   0          15m
   nginx-bf75b99b6-klmlm   1/1     Running   0          2m17s
   nginx-bf75b99b6-rs5hm   1/1     Running   0          15m
   nginx-bf75b99b6-sbl4l   1/1     Running   0          4s
   nginx-bf75b99b6-tbch8   1/1     Running   0          15m
   nginx-bf75b99b6-wclld   1/1     Running   0          15m
   ```

   

## **Deployment的暂停和恢复**

在更新deployment的过程中，有时候不能用edit进行编辑，就会需要通过多个命令进行修改deployment，这种情况下，每次执行命令都会进行pod的删除和重建，这会消耗系统大量的资源，所以该更新过程中可以通过pause进行暂停deployment，待所有更新项都完成之后，再通过resume恢复deployment，这样做的效果就是多次配置更改，只触发一次pod重建



1. 查看当前deployment的pod状态

   ```
   [root@k8s-master01 deployment]# kubectl get pod
   NAME                    READY   STATUS    RESTARTS   AGE
   nginx-bf75b99b6-69lg8   1/1     Running   0          30m
   nginx-bf75b99b6-7zz52   1/1     Running   0          14m
   nginx-bf75b99b6-f8z2r   1/1     Running   0          30m
   nginx-bf75b99b6-h97hg   1/1     Running   0          30m
   nginx-bf75b99b6-klmlm   1/1     Running   0          16m
   nginx-bf75b99b6-rs5hm   1/1     Running   0          30m
   nginx-bf75b99b6-sbl4l   1/1     Running   0          14m
   nginx-bf75b99b6-tbch8   1/1     Running   0          30m
   nginx-bf75b99b6-wclld   1/1     Running   0          30m
   ```

   

2. 暂停deployment

   暂停deployment之后，再对deployment进行修改就不会触发pod的删除和重建了

   ```
   [root@k8s-master01 deployment]# kubectl rollout pause deployment nginx
   deployment.apps/nginx paused
   ```

3. 修改一下deployment的配置

   修改nginx容器的镜像版本为`nginx:1.9.1`

   ```
   [root@k8s-master01 deployment]# kubectl set image deployment nginx nginx=nginx:1.9.1
   deployment.apps/nginx image updated
   [root@k8s-master01 deployment]# kubectl get pod
   NAME                    READY   STATUS    RESTARTS   AGE
   nginx-bf75b99b6-69lg8   1/1     Running   0          38m
   nginx-bf75b99b6-7zz52   1/1     Running   0          22m
   nginx-bf75b99b6-f8z2r   1/1     Running   0          38m
   nginx-bf75b99b6-h97hg   1/1     Running   0          38m
   nginx-bf75b99b6-klmlm   1/1     Running   0          24m
   nginx-bf75b99b6-rs5hm   1/1     Running   0          38m
   nginx-bf75b99b6-sbl4l   1/1     Running   0          22m
   nginx-bf75b99b6-tbch8   1/1     Running   0          38m
   nginx-bf75b99b6-wclld   1/1     Running   0          38m
   ```

   调整容器的资源配置

   ```
   [root@k8s-master01 deployment]# kubectl set resources deployment nginx -c=nginx --limits=cpu=200m,memory=512Mi
   deployment.apps/nginx resource requirements updated
   ```

4. 查看修改之后的deployment

   ```
   [root@k8s-master01 deployment]# kubectl get deployment nginx -o yaml
   
   ...
    template:
       metadata:
         creationTimestamp: null
         labels:
           app: nginx
       spec:
         containers:
         - image: nginx:1.9.1
           imagePullPolicy: IfNotPresent
           name: nginx
           resources:
             limits:
               cpu: 200m
               memory: 512Mi
           terminationMessagePath: /dev/termination-log
           terminationMessagePolicy: File
         dnsPolicy: ClusterFirst
         restartPolicy: Always
         schedulerName: default-scheduler
         securityContext: {}
         terminationGracePeriodSeconds: 30
   ```

   查看pod状态

   发现虽然deployment的配置更新了，但是pod还是之前的pod，pod并未发生更新

   ```
   [root@k8s-master01 deployment]# kubectl get pod
   NAME                    READY   STATUS    RESTARTS   AGE
   nginx-bf75b99b6-69lg8   1/1     Running   0          43m
   nginx-bf75b99b6-7zz52   1/1     Running   0          27m
   nginx-bf75b99b6-f8z2r   1/1     Running   0          43m
   nginx-bf75b99b6-h97hg   1/1     Running   0          43m
   nginx-bf75b99b6-klmlm   1/1     Running   0          29m
   nginx-bf75b99b6-rs5hm   1/1     Running   0          43m
   nginx-bf75b99b6-sbl4l   1/1     Running   0          27m
   nginx-bf75b99b6-tbch8   1/1     Running   0          43m
   nginx-bf75b99b6-wclld   1/1     Running   0          43m
   ```

5. 恢复deployment

   ```
   [root@k8s-master01 deployment]# kubectl rollout resume deployment nginx
   deployment.apps/nginx resumed
   ```

6. 查看replicas

   deployment更新之后，会创建新的rs

   ```
   [root@k8s-master01 deployment]# kubectl get rs
   NAME               DESIRED   CURRENT   READY   AGE
   nginx-6cdd578898   5         5         0       3s
   nginx-6f9794749d   0         0         0       175m
   nginx-78d49d7468   0         0         0       171m
   nginx-7cf6b8c5bc   0         0         0       58m
   nginx-bf75b99b6    7         7         7       3h26m
   nginx-dc46f4976    0         0         0       60m
   ```

   





## **Deployment更新策略**

更新策略有两种：RollinigUpdate和ReCreate

RollingUpdate是自动更新

ReCreate是删除pod，再新建pod之后才会更新，当你使用replace -f之后，之前的pod会立即删除并新建pod



### **RollingUpdate**

在Kubernetes中，RollingUpdate是一种滚动更新策略，用于更新Deployment或StatefulSet中的Pod。滚动更新可以确保在更新期间保持应用程序的可用性和稳定性。

RollingUpdate的工作原理是逐步替换现有的Pod副本，而不是立即替换所有的Pod。具体步骤如下：

1. 创建一个新的Pod副本，并将其添加到副本集。
2. 等待新的Pod副本变为“就绪”状态，确认它可以接收流量。
3. 逐渐停止并删除当前副本集中的旧Pod副本。每次删除一个Pod副本之前，都会先创建一个新的Pod副本来替代它。
4. 重复步骤1-3，直到所有的旧Pod副本都被替换为止。

滚动更新通过逐步替换Pod副本的方式，使得在更新过程中可以保持部分副本的可用性。这种方式可防止应用程序完全不可用或出现大量错误请求，从而确保系统的稳定运行。

为了使用RollingUpdate策略进行更新，可以在Deployment或StatefulSet的定义中明确指定相关参数，例如：

```
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
 
```

其中，`maxSurge`和`maxUnavailable`是控制滚动更新期间的扩容和缩容的参数，可以根据需求进行调整。

通过RollingUpdate策略，Kubernetes能够平滑地进行应用程序的更新，避免中断服务和降低用户体验。



- 查看Deployment的更新策略

  默认的更新策略就是RollingUpdate

  maxSurge: 25%

  maxUnavailable: 25%

  ```
  maxSurge: 25% 和 maxUnavailable: 25% 是用于控制 Pod 在滚动更新期间的扩容和缩容策略的参数。
  
  maxSurge 定义了在滚动更新期间允许超出所需副本数量的最大增加比例。以百分比表示，即指定的比例乘以当前副本数量。例如，如果当前副本数为 10，而 maxSurge: 25%，则滚动更新期间可以达到的最大副本数为 10 * (1 + 0.25) = 12.5，可取整为 13。（向上取整）
  
  maxUnavailable 定义了在滚动更新期间允许同时不可用的最大副本数量的比例。以百分比表示，即指定的比例乘以当前副本数量。例如，如果当前副本数为 10，而 maxUnavailable: 25%，则滚动更新期间允许同时不可用的最大副本数量为 10 * 0.25 = 2.5，可取整为 2。（向下取整）
  
  这两个参数常用于滚动更新策略，利用它们可以平滑地进行应用程序的版本升级或回滚。maxSurge 控制了在每个滚动更新步骤中可创建新Pod的最大数量，而maxUnavailable 控制了在每个滚动更新步骤中可同时不可用的最大 Pod 数量。
  
  通过设置适当的值，可确保在滚动更新过程中保持足够的可用性和稳定性。这些值可以根据实际需求进行调整，以满足应用程序的需求和容量规划。
  ```

  ```
  [root@k8s-master01 dp]# kubectl get deployment -o yaml | grep -A 4 strategy
      strategy:
        rollingUpdate:
          maxSurge: 25%
          maxUnavailable: 25%
        type: RollingUpdate
  ```



### **revisionHistoryLimit**

k8s中revisionHistoryLimit: 10是什么意思？

revisionHistoryLimit: 10用于指定最大的修订历史记录数量。

```
在Kubernetes（k8s）中，revisionHistoryLimit: 10是指部署（Deployment）资源的配置选项之一。Deployment定义了Kubernetes中应用程序的部署和更新策略。

revisionHistoryLimit: 10用于指定最大的修订历史记录数量。当进行部署更新时，Kubernetes会自动创建新的修订版本，并保留最近的若干个修订版本历史记录。通过设置revisionHistoryLimit: 10，你可以限制保留的修订历史记录数量为10个。当超过这个限制时，最旧的修订版本将被删除。

这个参数可用于控制部署的版本历史记录，避免无限增长的修订历史记录，并节省存储空间。另外，当需要回滚到先前的版本时，可以通过修订历史记录进行回滚操作
[root@k8s-master01 dp]# kubectl get deployment -o yaml | grep revisionHistoryLimit
    revisionHistoryLimit: 10
```



- 查询修订历史

如果按照上面的设置，将最大修订历史记录数改成10，那么这里最多只能看到10条记录

```
 [root@k8s-master01 dp]# kubectl rollout history deployment nginx
 deployment.apps/nginx 
 REVISION  CHANGE-CAUSE
 5         kubectl set image deployment nginx nignx=dotbalo/canary:v1 --record=true
 8         kubectl set image deployment nginx nginx=dotbalo/canary:v1 --record=true
 9         kubectl set image deployment nginx nginx=dotbalo/canary:v2 --record=true
 10        kubectl set image deployment nginx nginx=dotbalo/canary:v2 --record=true
 11        kubectl set image deployment nginx nginx=dotbalo/canary:v2 --record=true
 
```