# 配置Personal Access Token (PAT)



> 背景：通过github账号密码登录，提示不安全，不允许登录
>
> ```shell
> root@localhost:~# git push
> Username for 'https://github.com': zhangsan@163.com@github.com
> Password for 'https://zhangsan@163.com@github.com': 
> remote: Support for password authentication was removed on August 13, 2021.
> remote: Please see https://docs.github.com/get-started/getting-started-with-git/about-remote-repositories#cloning-with-https-urls for information on currently recommended modes of authentication.
> fatal: Authentication failed for 'https://github.com/zhangsan/xxx.git/'
> ```

## 使用 Personal Access Token (PAT) 来解决 Git 推送时的身份验证问题

### 生成Personal Access Token

1. 登录到你的 GitHub 账号。
2. 进入账号设置页面,找到 "Developer settings" 选项。
3. 在 "Developer settings" 页面,选择 "Personal access tokens" 选项。
4. 点击 "Generate new token" 按钮,创建一个新的 PAT。
5. 在 "Note" 字段中为 PAT 添加一个描述性的名称,比如 "Git push authentication"。
6. 勾选 "repo" 选项,这样 PAT 就拥有仓库相关的权限。
7. 点击 "Generate token" 按钮,GitHub 会为你生成一个新的 PAT。
8. 将生成的 PAT 复制下来,这个 token 就是你未来推送时使用的"密码"。

### 命令行登录

之后在执行 `git push` 命令时,当提示输入密码时,请输入刚刚生成的 `PAT`,而不是你的 GitHub 账号密码。

这样做的好处是:

1. 不需要在本地保存你的 GitHub 账号密码。
2. 如果你需要撤销 PAT 的权限,只需要在 GitHub 上删除这个 PAT 即可,而不用更改你的账号密码。
3. 对于需要 2FA (双因素认证)的账号,使用 PAT 可以方便地进行身份验证。

