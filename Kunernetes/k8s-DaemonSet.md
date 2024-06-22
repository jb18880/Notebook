### **DaemonSet的定义**

```
 什么是DaemonSet？
 
 在Kubernetes中，DaemonSet是一种资源对象，用于确保集群中的每个节点上都运行一个或多个Pod副本。它与其他类型的控制器（如Deployment或ReplicaSet）不同，这些控制器在整个集群中运行指定数量的Pod副本。
 
 DaemonSet是一个适用于需要在每个节点上运行的任务的理想选择。常见的用例包括日志收集、监控代理、网络代理等。通过使用DaemonSet，您可以确保在每个节点上都有一个Pod实例，而无论集群的规模如何变化。
 
 当您创建一个DaemonSet时，Kubernetes会自动在每个节点上调度Pod副本。如果有新节点加入集群，Kubernetes会自动在新节点上创建新的Pod实例。同样，如果有节点从集群中删除，相关的Pod副本也会被自动删除。
 
 需要注意的是，DaemonSet不会自动扩展或收缩Pod副本数量，它只会确保在每个节点上运行指定数量的Pod实例。如果您希望自动进行扩展或收缩，可以考虑使用其他类型的控制器，如Deployment或HPA（Horizontal Pod Autoscaler）。
 
 总结来说，DaemonSet在Kubernetes中用于确保每个节点上都运行指定数量的Pod副本，适用于需要在每个节点上运行特定任务的情况。
```



### **创建一个daemonset**

```
 [root@k8s-master01 ds]# vim nginx-ds.yaml 
 apiVersion: apps/v1
 kind: DaemonSet
 metadata: 
   labels: 
     app: nginx
   name: nginx
 spec: 
   selector: 
     matchLabels: 
       app: nginx
   template: 
     metadata: 
       labels: 
         app: nginx
     spec: 
       containers: 
       - image: nginx:1.15.12
         imagePullPolicy: IfNotPresent
         name: nginx
 
```



### **apply与create的区别**

kubectl apply -f nginx-ds.yaml与kubectl create -f nginx-ds.yaml有什么不同？

`kubectl apply -f nginx-ds.yaml` 和 `kubectl create -f nginx-ds.yaml` 实际上在功能上没有太大的区别，它们都用于创建或更新 Kubernetes 资源。

主要的区别在于 `kubectl create` 只能用于创建一个全新的资源，而 `kubectl apply` 则可以用于创建新资源或更新已存在的资源。

当使用 `kubectl create` 时，如果资源已经存在，会返回一个错误并拒绝创建。因此，如果要更新已经存在的资源，必须先删除该资源，然后再使用 `kubectl create` 创建新的资源。

然而，使用 `kubectl apply` 时， `Kubernetes`会根据给定的配置文件内容自动检测到资源的状态，并根据需要进行创建或更新。如果资源已经存在，将执行更新，否则将执行创建。这种方式可以更方便地管理资源状态的变化。

所以，如果您希望能够灵活地创建或更新资源，可以使用 `kubectl apply`。如果您只需创建全新的资源，可以使用 `kubectl create`。







### **label**

daemonset的标签是可以用来选择特定的节点来进行部署daemonset服务

如果指定了.spec.template.spec.nodeSelector，DaemonSet Controller 将在与 Node Selector（节 点选择器）匹配的节点上创建 Pod，比如部署在磁盘类型为 ssd 的节点上（需要提前给节点定义 标签 Label）：

```
 spec:
       nodeSelector:
         disktype: ssd
 
```

给节点加标签

```
 [root@k8s-master01 ds]# kubectl label node k8s-node01 k8s-node02 disktype=ssd
 node/k8s-node01 labeled
 node/k8s-node02 labeled
 
 [root@k8s-master01 ds]# kubectl get pod
 NAME          READY   STATUS    RESTARTS   AGE
 nginx-4lj9d   1/1     Running   0          6s
 nginx-kdpch   1/1     Running   0          6s
 
```

删除节点的标签

```
 [root@k8s-master01 ds]# kubectl label node k8s-node01 disktype-
 node/k8s-node01 unlabeled
 
 [root@k8s-master01 ds]# kubectl get pod
 NAME          READY   STATUS    RESTARTS   AGE
 nginx-4lj9d   1/1     Running   0          88s
 
```





### **DaemonSet的更新**

更新策略有两种，OnDelete和RolliingUpdate（这个跟deployment的配置一样）

查看更新策略

```
 [root@k8s-master01 ds]# kubectl get daemonset nginx -o yaml | grep -A 4 updateStrategy
   updateStrategy:
     rollingUpdate:
       maxSurge: 0
       maxUnavailable: 1
     type: RollingUpdate
 
```

更新配置

```
 [root@k8s-master01 ds]# kubectl edit daemonset nginx
 set
 patch
 vim
```

查看pod

```
 [root@k8s-master01 ds]# kubectl get pod
 NAME          READY   STATUS    RESTARTS   AGE
 nginx-gmpdd   1/1     Running   0          5m2s
 
```



### **DaemonSet的回滚**

列出所有修订记录版本

```
[root@k8s-master01 ds]# kubectl rollout history daemonset nginx
daemonset.apps/nginx 
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
```

回滚到指定版本

```
[root@k8s-master01 ds]# kubectl rollout undo daemonset nginx --to-revision=1
daemonset.apps/nginx rolled back
```