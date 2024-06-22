k8s资源文件示例

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

`apiVersion：v1`各个资源的apiVersion都可以通过`kubectl api-resources`命令去查看，只要你清楚自己需要创建的资源类型，就可以找到对应的apiVerison

```
 root@k8s-master01:~/test# kubectl api-resources | grep pod
 pods                              po           v1                                     true         Pod
 podtemplates                                   v1                                     true         PodTemplate
 horizontalpodautoscalers          hpa          autoscaling/v2                         true         HorizontalPodAutoscaler
 poddisruptionbudgets              pdb          policy/v1                              true         PodDisruptionBudget
 
```

`kind`：资源类型，示例中的资源类型为pod，还有deployment，statefulSet，service，job

`metadata`：该资源具有的元数据信息，例如：`labels`标签，是k-v形式的键值对，本例中的标签为`run: nginx`；`name`用于指定pod的名称。

`spec`：用于定义该资源的声明文件。该资源是一个定义pod的资源文件，pod中会管理许多容器，该实例中`containers`就是配置容器的位置，其中`image`用于指定容器的镜像，`name`用于指定容器名称。如果要在pod中管理多个容器的话，只需要添加多组`image`和`name`就行。

注意：在同一个pod中部署的容器是共享网络资源的。当你在同一个pod中部署多个容器时，要注意开启的端口不能一样。比如：在同一个pod中部署了两个nginx的容器，一个是80端口，另外一个就不能是80端口，需要指定为其他端口。

注意：同一个pod中的多个容器，可以指定相同的镜像，但是不能指定相同的容器名称。