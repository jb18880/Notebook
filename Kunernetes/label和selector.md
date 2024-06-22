# label和selector

- 创建一个带标签的pod

1. 给node节点打标签

   ```
    [root@k8s-master01 ~]# kubectl label node k8s-node01 subnet=7
    node/k8s-node01 labeled
    [root@k8s-master01 ~]# kubectl get node -l subnet=7
   ```

2. 修改创建deployment的spec.template.spec.nodeSelector选项

   ```
        spec:
          nodeSelector:
            subnet: "7"
    
   ```

3. 创建deployment

   ```
    [root@k8s-master01 ~]# kubectl create -f nginx.yaml
   ```

4. 查看是否都创建在同一个标签的node节点上

   ```
    [root@k8s-master01 ~]# kubectl get pod -o wide
   ```

   

## selector标签选择器

