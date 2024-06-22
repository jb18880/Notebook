# Ingress



### 安装ingress

> 官方安装文档地址：
>
> ```
> https://kubernetes.github.io/ingress-nginx/deploy/#bare-metal-clusters
> ```

安装

```sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/baremetal/deploy.yaml
```

检查

```sh
controlplane $ kubectl get pod -n ingress-nginx 
NAME                                       READY   STATUS      RESTARTS   AGE
ingress-nginx-admission-create-ksb86       0/1     Completed   0          34s
ingress-nginx-admission-patch-w52b5        0/1     Completed   0          34s
ingress-nginx-controller-5cdfb74dc-rb86r   1/1     Running     0          34s
```



### 使用域名发布 K8s 的服务

1. 创建一个 web 服务

   ```sh
   kubectl create deploy nginx --image=registry.cn-beijing.aliyuncs.com/dotbalo/nginx:1.15.12-alpine
   ```

2. 暴露服务

   ```sh
   kubectl expose deploy nginx --port 80
   ```

3. 创建 Ingress

   ```yaml
   #定义ingress配置文件
   vim web-ingress.yaml
   apiVersion: networking.k8s.io/v1 # k8s版本 >= 1.22 必须写 v1
   kind: Ingress
   metadata:
     name: nginx-ingress   #Ingress的名称，见名知意
   spec:					#spec中写的是关于Ingress资源的定义
     ingressClassName: nginx	#ingressclass指定ingress controller为nginx；因为同一个集群中可能会存在不同的ingress controller，该参数可以用来指定该ingress配置具体由哪个ingress controller来解析
     rules:
     - host: nginx.test.com   #配置域名代理到后端的service上，
     #service的名称由spec.rules.http.paths.backend.service.name来定义；
     #service的端口由spec.rules.http.paths.backend.service.port来定义
     #如果通过ingress代理多个域名，只需要将"host一直到number之间的内容复制即可"
       http:
         paths:
           - path: /	#如果需要配置多个路径的话，只需要将"path到number之间的内容复制多份即可"
             pathType: ImplementationSpecific
             backend:	
               service:
                 name: nginx    #service的名称
                 port:
                   number: 80   #service的端口号，是pod的端口号，不是target的端口号
             
   #创建ingress
   controlplane $ kubectl create -f web-ingress.yaml 
   ingress.networking.k8s.io/nginx-ingress created
   
   #查看当前ingress
   controlplane $ kubectl get ingress
   NAME            CLASS   HOSTS            ADDRESS   PORTS   AGE
   nginx-ingress   nginx   nginx.test.com             80      42s
   ```

   Ingress中定义的路径规则会使用`pathType`来指定路由的匹配方式。`pathType`的值可以是以下几种之一：

   1. **Exact**: 精确匹配。请求的URL路径必须与Ingress规则中定义的路径完全相同，才会被路由到对应的后端服务。
   2. **Prefix**: 前缀匹配。请求的URL路径必须以Ingress规则中定义的路径作为前缀，才会被路由到对应的后端服务。
   3. **ImplementationSpecific**: 由Ingress控制器具体实现。这种类型允许Ingress控制器根据自己的逻辑来决定如何匹配路径。
   4. **PathTypeUnspecified**: 未指定路径类型。在Kubernetes 1.18之前，这是默认的路径类型，它的行为与`Prefix`相同。从1.18版本开始，如果`pathType`没有明确指定，它将默认为`ImplementationSpecific`。

4. 验证服务

   > 通过外部浏览器访问域名+Service的端口号来访问服务
   >
   > 1. 配置DNS解析
   >
   >    C:\Windows\System32\drivers\etc\hosts
   >
   >    配置"IP 域名"
   >
   >    IP地址为集群中Node节点的IP地址
   >
   >    域名为创建ingress时使用的域名
   >
   > 2. 访问域名+service_port