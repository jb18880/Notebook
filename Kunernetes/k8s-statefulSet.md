什么是statefulset

```
 StatefulSet是用于在Kubernetes集群中管理有状态应用的一种资源对象。有状态应用是指依赖持久性存储并且在集群重启后仍然保持状态的应用。StatefulSet可以确保有状态应用在集群中的唯一性和稳定性。
 
 StatefulSet通过为每个Pod分配一个唯一的网络标识符和持久性存储卷来管理有状态应用。每个Pod在创建和销毁时，都会保留相同的标识符和存储卷，以便保持应用状态的连续性。
 
 与Deployment资源对象相比，StatefulSet具有以下特点： 1. 稳定的唯一标识符：每个Pod都有一个稳定的网络标识符，以便于进行有状态应用的服务发现和网络访问。 2. 有序的部署和扩展：根据定义的顺序，StatefulSet会逐个创建和删除Pod，确保有状态应用的顺序部署和扩展。 3. 稳定的持久化存储：每个Pod都会被分配一个独立的持久化存储卷，并且在Pod删除后存储卷不会被立即删除，以便于保留应用的数据。
 
 在使用StatefulSet时，还可以配合其他Kubernetes资源对象如Service对象和VolumeClaimTemplates来实现对有状态应用的服务发现和存储管理。
 
 总之，StatefulSet使得在Kubernetes集群中管理有状态应用变得更容易和可靠，为有状态应用的部署、伸缩和更新提供了便利。
```



什么是headless service/

```
 Headless Service是Kubernetes中的一种特殊类型的服务。它与普通的Service不同，不提供负载均衡或服务发现功能。相反，它允许直接访问Pod的网络标识符。
 
 普通的Service会为其后端Pod提供一个虚拟的集群IP和DNS记录，通过这个IP和DNS记录可以进行负载均衡和服务发现。而Headless Service不会为后端Pod提供这样的虚拟IP和DNS记录。相反，它会为每个后端Pod创建一个DNS记录，可以通过Pod的名称直接访问该Pod的网络标识符。这种直接的访问方式对于一些特定场景非常有用，例如数据库集群或分布式系统。
 
 通过使用Headless Service，可以实现以下优势： 1. 直接访问Pod：可以直接使用Pod的网络标识符进行通信，而不需要经过Service的负载均衡。 2. 自定义服务发现：可以自定义实现服务发现的逻辑，灵活适应不同的需求和场景。 3. 多个副本的Pod：对于有多个副本的Pod，可以通过DNS记录直接访问特定的副本。
 
 在创建Headless Service时，只需要将Service的spec.type设置为"ClusterIP"（或不设置，因为默认值就是"ClusterIP"），并且在spec.clusterIP字段设置空字符串。这样就可以创建一个Headless Service，它会为每个Pod创建相应的DNS记录。
 
 总之，Headless Service提供了一种直接访问Pod网络标识符的方式，适用于需要绕过Service负载均衡和直接与特定Pod通信的场景。
```



创建statefulSet时是按顺序创建的，缩容的时候是按照倒序进行删除的

deployment创建的pod是根据随机字符串命名的，statefulSet是按照[0..N-1]顺序命名的

创建一个statefulSet

```
 [root@k8s-master01 test]# cat statefulset.yaml 
 apiVersion: v1
 kind: Service
 metadata: 
   name: nginx
   labels:       
     app: nginx
 spec: 
   ports: 
   - port: 80
     name: web
   clusterIP: None
   selector: 
     app: nginx
 ---
 apiVersion: apps/v1
 kind: StatefulSet
 metadata: 
   name: web
 spec: 
   serviceName: "nginx"
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
           name: web
 
```

创建statefulset

```
 [root@k8s-master01 sts]# kubectl create -f statefulset.yaml 
 service/nginx created
 statefulset.apps/web created
 [root@k8s-master01 sts]# kubectl get pod
 NAME    READY   STATUS    RESTARTS   AGE
 web-0   1/1     Running   0          81s
 web-1   1/1     Running   0          79s
 web-2   1/1     Running   0          78s
 pps/web created
 
```



## **statefulSet中pod的通信**

statefulSet中的pod的通信是通过Headles Service实现的，该serveice会给每一个pod分配一个qfdn域名，pod之间通过域名进行通信

- 测试pod间的通信

  1. 查看pod

     ```
      [root@k8s-master01 test]# kubectl get pod
      NAME                     READY   STATUS    RESTARTS      AGE
      web-0                    1/1     Running   0             20m
      web-1                    1/1     Running   0             20m
      web-2                    1/1     Running   0             20m
      
     ```

  2. 进到某个pod里面

     ```
      [root@k8s-master01 test]# kubectl exec -it web-1 -- sh
     ```

  3. 解析域名

     解析一下baidu.com的IP地址

     ```
      / # nslookup baidu.com
      nslookup: can't resolve '(null)': Name does not resolve
      
      Name:      baidu.com
      Address 1: 110.242.68.66
      Address 2: 39.156.66.10
     ```

  4. 解析一下通statefulSet中其他pod的IP地址

     qfdn全称域名：web-0.nginx.default.svc.cluster.local

     web-0是pod名

     nginx是service名（注意：不是statefulSet名）

     default是名称空间（不建议跨名称空间进行访问）

     svc.cluster.local为系统自带的

     ```
      / # nslookup web-0.nginx.default.svc.cluster.local
      nslookup: can't resolve '(null)': Name does not resolve
      
      Name:      web-0.nginx.default.svc.cluster.local
      Address 1: 192.168.58.202 web-0.nginx.default.svc.cluster.local
     ```

     ```
     / # nslookup web-1.nginx.default.svc.cluster.local
     nslookup: can't resolve '(null)': Name does not resolve
     
     Name:      web-1.nginx.default.svc.cluster.local
     Address 1: 192.168.85.211 web-1.nginx.default.svc.cluster.local
     ```

     ```
     / # nslookup web-2.nginx.default.svc.cluster.local
     nslookup: can't resolve '(null)': Name does not resolve
     
     Name:      web-2.nginx.default.svc.cluster.local
     Address 1: 192.168.58.203 web-2.nginx.default.svc.cluster.local
     ```

  5. 同一个`名称空间`下面的域名可以省略default.svc.cluster.local（名称空间及后面的高级域名）

     ```
     / # nslookup baidu.com
     nslookup: can't resolve '(null)': Name does not resolve
     
     Name:      baidu.com
     Address 1: 110.242.68.66
     Address 2: 39.156.66.10
     ```

     

## **statefulSet的扩容和缩容**

不推荐缩容

更改statefulSet的replicas的三种方法

```
[root@k8s-master01 test]# kubectl scale sts web --replicas=5
statefulset.apps/web scaled
[root@k8s-master01 test]# kubectl edit statefulset web 
[root@k8s-master01 test]# kubectl patch sts web -p  '{"spec":{"replicas":3}}'
statefulset.apps/web patched
```





## **statefulSet的更新策略**

```
statefulset的更新策略有几种?

statefulset有三种更新策略：

RollingUpdate（默认）：按顺序逐个更新Pod。新的Pod会在更新前先启动，待新Pod运行正常后，再删除旧的Pod。这种策略适用于需要保证应用持续可用性的情况。

OnDelete：只有在旧的Pod被手动删除时才会启动新的Pod进行更新。这种策略适用于需要手动控制更新时机的情况，例如应用需要完成一些特定操作后才能进行更新。

Partition：将每个Pod分成多个更新分区。每个分区内的Pod会按RollingUpdate策略进行更新，而不同分区的Pod则可以并行更新。这种策略适用于需要控制并行度的情况，例如更新影响范围较大时，可以将Pod分成多个分区以减轻更新对应用的影响。

总之，Partition更新策略可以与RollingUpdate策略结合使用，通过划分多个更新分区并逐个更新Pods，以控制并行度和确保应用的稳定运行。其他更新策略，如OnDelete策略，不能与Partition更新策略一起使用。
```



OnDelete：更新完statefulSet的配置之后，不会自动更新 pod，需要将pod删除，待pod重建之后，配置才会更新

RollingUpdate：更新完statefulSet的配置之后，会自动更新pod



- OnDelete

1. 配置statefulSet的更新策略为OnDelete

```
[root@k8s-master01 test]# cat statefulset.yaml 
apiVersion: v1
kind: Service
metadata: 
  name: nginx
  labels: 
    app: nginx
spec: 
  ports: 
  - port: 80
    name: web
  clusterIP: None
  selector: 
    app: nginx
---
apiVersion: apps/v1
kind: StatefulSet
metadata: 
  name: web
spec:
  updateStrategy:
    #rollingUpdate:
    #  partition: 0
    #type: RollingUpdate
    type: OnDelete 
  serviceName: "nginx"
  replicas: 8
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
       # image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12
        ports: 
        - containerPort: 80
          name: web
```

1. 查看pod

   ```
   [root@k8s-master01 test]# kubectl get pod
   NAME    READY   STATUS    RESTARTS   AGE
   web-0   1/1     Running   0          16m
   web-1   1/1     Running   0          16m
   web-2   1/1     Running   0          16m
   web-3   1/1     Running   0          15m
   web-4   1/1     Running   0          15m
   web-5   1/1     Running   0          15m
   web-6   1/1     Running   0          15m
   web-7   1/1     Running   0          15m
   ```

2. 查看当前镜像版本

   ```
   [root@k8s-master01 test]# kubectl get pod -o yaml  | grep ' image:'
       - image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12-alpine
         image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12-alpine
   ```

3. 修改配置文件的镜像版本

   ```
   [root@k8s-master01 test]# cat statefulset.yaml 
   apiVersion: v1
   kind: Service
   metadata: 
     name: nginx
     labels: 
       app: nginx
   spec: 
     ports: 
     - port: 80
       name: web
     clusterIP: None
     selector: 
       app: nginx
   ---
   apiVersion: apps/v1
   kind: StatefulSet
   metadata: 
     name: web
   spec:
     updateStrategy:
       #rollingUpdate:
       #  partition: 0
       #type: RollingUpdate
       type: OnDelete 
     serviceName: "nginx"
     replicas: 8
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
         #  image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12-alpine
           image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12
           ports: 
           - containerPort: 80
             name: web
   ```

4. 将配置文件生效

   ```
   [root@k8s-master01 test]# kubectl replace -f statefulset.yaml 
   service/nginx replaced
   statefulset.apps/web replaced
   ```

5. 查看pod

   因为更新策略是OnDelete，所以即使替换了配置文件，k8s也不会更新这些pod，只有当pod重建的时候，这些配置才会更新

   ```
   [root@k8s-master01 test]# kubectl get pod
   NAME    READY   STATUS    RESTARTS   AGE
   web-0   1/1     Running   0          16m
   web-1   1/1     Running   0          16m
   web-2   1/1     Running   0          16m
   web-3   1/1     Running   0          15m
   web-4   1/1     Running   0          15m
   web-5   1/1     Running   0          15m
   web-6   1/1     Running   0          15m
   web-7   1/1     Running   0          15m
   ```

6. 删除某个pod

   ```
   [root@k8s-master01 test]# kubectl delete pod web-5
   pod "web-5" deleted
   ```

7. 再查看镜像版本

   发现web-5的镜像版本已经发生更改

   ```
   [root@k8s-master01 test]# kubectl get pod -l app=nginx | grep image:
   
       - image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12-alpine
         image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12-alpine
       - image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12-alpine
         image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12-alpine
       - image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12-alpine
         image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12-alpine
       - image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12-alpine
         image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12-alpine
       - image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12-alpine
         image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12-alpine
       - image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12
         image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12
       - image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12-alpine
         image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12-alpine
       - image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12-alpine
         image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12-alpine
   ```



- RollingUpdate

1. 修改statefulSet的配置文件更新策略为RollingUpdate

   ```
   [root@k8s-master01 test]# cat statefulset.yaml 
   apiVersion: v1
   kind: Service
   metadata: 
     name: nginx
     labels: 
       app: nginx
   spec: 
     ports: 
     - port: 80
       name: web
     clusterIP: None
     selector: 
       app: nginx
   ---
   apiVersion: apps/v1
   kind: StatefulSet
   metadata: 
     name: web
   spec:
     updateStrategy:
       rollingUpdate:
         partition: 0
       type: RollingUpdate
     serviceName: "nginx"
     replicas: 8
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
          # image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12-alpine
           image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12
           ports: 
           - containerPort: 80
             name: web
   ```

2. 生效配置文件

   ```
   [root@k8s-master01 test]# kubectl replace -f statefulset.yaml 
   service/nginx replaced
   statefulset.apps/web replaced
   ```

3. 查看pod状态

   因为是RollingUpdate，所以pod立即就更新了

   ```
   [root@k8s-master01 test]# kubectl get pod
   NAME    READY   STATUS    RESTARTS   AGE
   web-0   1/1     Running   0          4s
   web-1   1/1     Running   0          7s
   web-2   1/1     Running   0          10s
   web-3   1/1     Running   0          14s
   web-4   1/1     Running   0          15s
   web-5   1/1     Running   0          16m
   web-6   1/1     Running   0          18s
   web-7   1/1     Running   0          21s
   ```

4. 查看镜像版本

   ```
   [root@k8s-master01 test]# kubectl get pod -l app=nginx -o yaml | grep image:
       - image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12
         image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12
       - image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12
         image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12
       - image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12
         image: registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12
   ```









### **级联删除和非级联删除**

statefulset 的级联删除和非级联删除

默认就是级联删除，删除sts的时候，默认就会把相关的pod都删除掉；

加上--cascade=orphan就是非级联删除，删除sts时会把pod留下，只删除sts，留下的pod就像孤儿一样，不受调度器的控制，该配置很少见