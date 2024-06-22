zsh是一个功能强大的shell解释器

### **安装zsh**

```
 yum -y install zsh
```

检查是否安装成功

```
 cat /etc/shells
 ...
 /bin/zsh
```

### **配置zsh**

1. 配置很复杂，建议使用开源脚本进行配置

```
 这个是配置zsh的开源脚本的链接
 https://github.com/ohmyzsh/ohmyzsh
```

1. 安装git

```
 yum -y install git
```

1. 通过脚本自动配置

```
 sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
 #访问github不顺畅的话，可以用下面的命令，把链接地址替换成了可以正常的访问的网址（这个地址由ohmyzsh项目的作者提供）
 sh -c "$(curl -fsSL https://install.ohmyz.sh)" "" --unattended
```

1. 修改默认的shell解释器

```
 #root字段为用户名，此处给root用户修改shell解释器；如果是其他用户，在此填写该用户的用户名即可。
 chsh -s /bin/zsh root
```

### **修改ZSH主题**

修改提示符为随机主题

修改~/.zshrc中的ZSH_THEME的值为random

```
 vim ~/.zshrc +11
 
 ZSH_THEME="random"
```

通过zsh命令修改主题

```
 zsh
 zsh
 zsh
 zsh
 zsh
 zsh
 jb@localhost:~
 [oh-my-zsh] Random theme 'sammy' loaded
 ~$ 
```

保存自己喜欢的主题

将自己喜欢的主题名替换random即可



### **Q&A：有点小问题**

1. 为什么我使用`chsh`命令的时候，提示命令不存在？

   提示命令不存在

   ```
    #此处代码为伪代码
    命令:chsh -s /bin/zsh
    提示：command not found
   ```

   找到`chsh`命令的安装包

   ```
    #参考链接：https://forums.centos.org/viewtopic.php?t=73864
    #此处代码为论坛上的代码
    [root@centos8 ~]# dnf provides '*/chsh'
    Last metadata expiration check: 0:51:14 ago on Sat Mar 28 14:23:21 2020.
    util-linux-user-2.32.1-17.el8.x86_64 : libuser based util-linux utilities
    Repo : BaseOS
    Matched from:
    Filename : /etc/pam.d/chsh
    Filename : /usr/bin/chsh
    Filename : /usr/share/bash-completion/completions/chsh
   ```

   装包

   ```
    dnf -y install util-linux-user-2.32.1-17.el8.x86_64
   ```

   验证

   ```
    [jbb@localhost ~]$ chsh -s /bin/zsh
    Changing shell for jbb.
   ```

2. 为什么安装完zsh提示没有配置文件？

   ```
    [jbb@localhost]~% zsh
    This is the Z Shell configuration function for new users,
    zsh-newuser-install.
    You are seeing this message because you have no zsh startup files
    (the files .zshenv, .zprofile, .zshrc, .zlogin in the directory
    ~).  This function can help you with a few settings that should
    make your use of the shell easier.
    
    You can:
    
    (q)  Quit and do nothing.  The function will be run again next time.
    
    (0)  Exit, creating the file ~/.zshrc containing just a comment.
         That will prevent this function being run again.
    
    (1)  Continue to the main menu.
    
    --- Type one of the keys in parentheses --- 
    
    q 退出（下次使用zsh还有这个告警）
    0 创建一个空的配置文件（用于取消该告警）
    1 手动配置各种参数
   ```

   出现该告警就是因为没有配置zsh的配置文件，需要自己配置一下。建议用脚本配置`sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended`

3. root安装的zsh，普通用户可以用吗？

   - 普通用户使用zsh

   > 1. 添加用户 useradd 用户名 passwd 密码 密码
   > 2. 切换终端（必须使用新创建的用户重新登录）
   > 3. 更改默认shell解释器 chsh -s /bin/zsh
   > 4. 配置zsh
   >
   > ```shell
   >   #sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
   > 
   >   sh -c "$(curl -fsSL https://install.ohmyz.sh)" "" --unattended
   > ```

