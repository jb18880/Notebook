zsh是一个功能强大的shell解释器

### **安装zsh**

```
 apt -y install zsh
```

检查是否安装成功

```
 cat /etc/shells
 ...
 /bin/zsh  
```

### **配置zsh**

> ohmyzsh脚本链接： https://github.com/ohmyzsh/ohmyzsh

1. 配置代理

   ```shell
   export http_proxy=http://10.0.0.1:10809
   export https_proxy=http://10.0.0.1:10809
   ```

2. 通过脚本自动配置

   ```shell
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
   ```

3. 修改默认的shell解释器

   ```shell
    #root字段为用户名，此处给root用户修改shell解释器；如果是其他用户，在此填写该用户的用户名即可。
    chsh -s /bin/zsh root
   ```

4. 启用zsh
   ```shell
    zsh
   ```

### 安装插件

#### 主题插件-p10k

> [!NOTE]
>
> 需要先安装字体：终端在哪里就在哪里安装字体，例如我是在windows上面通过ssh远程连接到ubuntu_server上，所以我就需要在windows主机上安装字体

1. 终端主机-安装字体

   > p10k项目地址

   a) 在p10k项目地址里面下载p10k需要用到的字体

   - [MesloLGS NF Regular.ttf](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf)

   - [MesloLGS NF Bold.ttf](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf)

   - [MesloLGS NF Italic.ttf](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf)

   - [MesloLGS NF Bold Italic.ttf](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf)



![下载文件示例](https://telegraph-image-67p.pages.dev/file/cc31ae6dad6026c7e6ea7.png)

   b) 将下载的字体字体文件放置在`C:\Windows\Fonts`目录下，系统询问是否安装，选择是

   ![fonts安装路径](https://telegraph-image-67p.pages.dev/file/d17b783e07a7d6dfa8bff.png)

   c) terminal修改字体

   `MesloLGS NF` 字体在系统上安装好之后，需要把该字体应用到windows terminal(win11自带，win10请在windows商店下载)中

   windows terminal - 设置 - 配置文件 - 默认值 - 其他设置 - 外观 - 字体 - `MesloLGS NF` 

   ![字体字体到windows terminal](https://telegraph-image-67p.pages.dev/file/1b52f3a1e8ecce7c783bf.png)

2. server下载p10k插件

   ```
   git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
   ```

3. 启用p10k插件

   ```shell
   vim ~/.zshrc +11
   ZSH_THEME="powerlevel10k/powerlevel10k"
   ```

4. 自定义prompt显示效果

   - 安装`p10k`后，通过`source ~/.zshrc`加载zsh配置文件，首次启用p10k会提示配置`prompt`
   - 后续想要修改`prompt`可以通过`p10k configure`命令重新进入到prompt的配置界面

#### 自动补全插件

1. 下载插件

   ```
   git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
   ```

#### 关键字高亮插件

1. 下载插件

   ```
   git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
   ```

2. 启用插件

   ```shell
   vim ~/.zshrc
   plugins=(git zsh-syntax-highlighting zsh-autosuggestions)
   ```





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
