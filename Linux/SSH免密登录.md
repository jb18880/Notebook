# SSH免密登录

A通过SSH连接B

1. 在A上生成秘钥对

   ```shell
   ssh-keygen
   ```

2. 将A的公钥传到B服务器上

   - 同个局域网，且可以直接访问

     ```
     ssh-copy-id -i /root/.ssh/id_rsa.pub root@10.0.0.111
     ```

   - 不同网络

     1. 复制A的公钥信息

        ```shell
        vim /root/.ssh/id_rsa.pub
        ```

     2. 在B上创建授权key文件

        ```shell
        vim /root/.ssh/authorized_keys
        ```

     3. 向授权key文件中写入A的公钥信息

        

     