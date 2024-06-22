创建一个nginx的deployment，再创建一个NodePort类型的service

```yaml
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

