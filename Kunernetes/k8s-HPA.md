## **HPA定义**

什么是HPA?

```
 在 Kubernetes 中，HPA (Horizontal Pod Autoscaler) 是一种自动调整 Pod 副本数量的资源扩展机制。它基于 CPU 使用率或自定义指标来自动扩展或缩减 Pod 副本数量，以确保应用程序具有适当的资源供应。
 
 HPA 通过监测 Pod 的 CPU 使用率或应用程序自定义指标，并与目标平均使用率进行比较，以确定是否需要调整 Pod 副本数量。它可以根据配置的最小和最大副本数自动扩展或缩减 Pod。
```



## **HPA实验**

步骤：

1. 安装metrics server

   这个是配置文件链接，按照这个文件，创建一个comp.yaml文件

   ```
    root@k8s-master01:~# cat comp.yaml
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      labels:
        k8s-app: metrics-server
      name: metrics-server
      namespace: kube-system
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      labels:
        k8s-app: metrics-server
        rbac.authorization.k8s.io/aggregate-to-admin: "true"
        rbac.authorization.k8s.io/aggregate-to-edit: "true"
        rbac.authorization.k8s.io/aggregate-to-view: "true"
      name: system:aggregated-metrics-reader
    rules:
    - apiGroups:
      - metrics.k8s.io
      resources:
      - pods
      - nodes
      verbs:
      - get
      - list
      - watch
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      labels:
        k8s-app: metrics-server
      name: system:metrics-server
    rules:
    - apiGroups:
      - ""
      resources:
      - nodes/metrics
      verbs:
      - get
    - apiGroups:
      - ""
      resources:
      - pods
      - nodes
      verbs:
      - get
      - list
      - watch
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      labels:
        k8s-app: metrics-server
      name: metrics-server-auth-reader
      namespace: kube-system
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: Role
      name: extension-apiserver-authentication-reader
    subjects:
    - kind: ServiceAccount
      name: metrics-server
      namespace: kube-system
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      labels:
        k8s-app: metrics-server
      name: metrics-server:system:auth-delegator
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: system:auth-delegator
    subjects:
    - kind: ServiceAccount
      name: metrics-server
      namespace: kube-system
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      labels:
        k8s-app: metrics-server
      name: system:metrics-server
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: system:metrics-server
    subjects:
    - kind: ServiceAccount
      name: metrics-server
      namespace: kube-system
    ---
    apiVersion: v1
    kind: Service
    metadata:
      labels:
        k8s-app: metrics-server
      name: metrics-server
      namespace: kube-system
    spec:
      ports:
      - name: https
        port: 443
        protocol: TCP
        targetPort: https
      selector:
        k8s-app: metrics-server
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      labels:
        k8s-app: metrics-server
      name: metrics-server
      namespace: kube-system
    spec:
      selector:
        matchLabels:
          k8s-app: metrics-server
      strategy:
        rollingUpdate:
          maxUnavailable: 0
      template:
        metadata:
          labels:
            k8s-app: metrics-server
        spec:
          containers:
          - args:
            - --cert-dir=/tmp
            - --secure-port=4443
            - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
            - --kubelet-use-node-status-port
            - --metric-resolution=15s
            - --kubelet-insecure-tls
            - --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt # change to front-proxy-ca.crt for kubeadm
            - --requestheader-username-headers=X-Remote-User
            - --requestheader-group-headers=X-Remote-Group
            - --requestheader-extra-headers-prefix=X-Remote-Extra-
            image: registry.cn-beijing.aliyuncs.com/dotbalo/metrics-server:v0.7.0
            imagePullPolicy: IfNotPresent
            livenessProbe:
              failureThreshold: 3
              httpGet:
                path: /livez
                port: https
                scheme: HTTPS
              periodSeconds: 10
            name: metrics-server
            ports:
            - containerPort: 4443
              name: https
              protocol: TCP
            readinessProbe:
              failureThreshold: 3
              httpGet:
                path: /readyz
                port: https
                scheme: HTTPS
              initialDelaySeconds: 20
              periodSeconds: 10
            resources:
              requests:
                cpu: 100m
                memory: 200Mi
            securityContext:
              allowPrivilegeEscalation: false
              readOnlyRootFilesystem: true
              runAsNonRoot: true
              runAsUser: 1000
            volumeMounts:
            - mountPath: /tmp
              name: tmp-dir
            - mountPath: /etc/kubernetes/pki/front-proxy-ca.crt
              name: pki
          nodeSelector:
            kubernetes.io/os: linux
          priorityClassName: system-cluster-critical
          serviceAccountName: metrics-server
          volumes:
          - emptyDir: {}
            name: tmp-dir
          - hostPath:
              path: /etc/kubernetes/pki/front-proxy-ca.crt
            name: pki
    ---
    apiVersion: apiregistration.k8s.io/v1
    kind: APIService
    metadata:
      labels:
        k8s-app: metrics-server
      name: v1beta1.metrics.k8s.io
    spec:
      group: metrics.k8s.io
      groupPriorityMinimum: 100
      insecureSkipTLSVerify: true
      service:
        name: metrics-server
        namespace: kube-system
      version: v1beta1
      versionPriority: 100
    
   ```

   ```
    kubectl create -f comp.yaml
   ```

2. 检查metrics server是否安装成功

   ```
    kubectl get pod -n kube-system
   ```

   使用top命令有效果就代表metrics安装成功了

   ```
    kubectl top pod -A
   ```

3. 复制front-proxy-ca.crt文件到各个从节点

   ```
    scp /etc/kubernetes/pki/front-proxy-ca.crt k8s-node01:/etc/kubernetes/pki/front-proxy-ca.crt
    scp /etc/kubernetes/pki/front-proxy-ca.crt k8s-node02:/etc/kubernetes/pki/front-proxy-ca.crt
    scp /etc/kubernetes/pki/front-proxy-ca.crt k8s-node03:/etc/kubernetes/pki/front-proxy-ca.crt
   ```

4. 创建一个deployment

   - 生成yaml文件

   ```
    kubectl create deployment hpa-nginx --image=nginx --dry-run=client -o yaml > hpa-nginx.yaml
   ```

   修改yaml配置：修改spec.template.spec.containers.resources.requests.的参数配置为`cpu: 10`

   这条参数的意思是，当cpu的核数超过10核的时候，就会触发HPA自动扩容

   ```
    hpa-nginx.yaml
    root@k8s-master01:~# cat hpa-nginx.yaml 
    ...
    spec:
      template:
        spec:
          containers:
            resources: 
              requests: 
                cpu: 10m
    status: {}
   ```

   ```
    kubectl create -f hpa-nginx.yaml
   ```

5. 检查deployment

   用curl命令检查创建的deployment中的nginx是否可以正常访问

   ```
    kubectl get pod  -owide
    curl 10.244.2.2    #这是hpa-nginx pod的ip地址
   ```

6. 暴露出deployment的监测接口

   ```
    kubectl expose deployment hpa-nginx --port=80
   ```

7. 检查service是否可以正常访问

   ```
    kubectl get service
    curl 10.108.60.58  #这是serveice的ip地址
   ```

8. 配置HPA的策略

   ```
    kubectl autoscale deployment hpa-nginx --cpu-percent=10 --min=1 --max=10
   ```

9. 触发HPA

   触发之前，先看下pod的资源使用情况

   ```
    kubectl top po
   ```

   写个死循环一直访问刚刚的pod，这个ip是刚刚的serviece的ip地址

   ```
    while true;do wget -q -O- http://10.108.60.58 > /dev/null; done
   ```

10. 观测pod数量

    ```
     kubectl get hpa
     kubectl get pod
    ```

    

要点：

1. 必须安装metrics-server，或者安装其他自定义的metrics-server
2. 启动deployment的时候，必须指定requests参数
3. 不能扩容无法缩放的对象，例如DaemonSet