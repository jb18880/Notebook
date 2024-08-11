### 配置DNS解析

```shell
sudo tee /etc/resolv.conf << EOF
nameserver 114.114.114.114
nameserver 223.5.5.5
nameserver 180.76.76.76
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF
```



