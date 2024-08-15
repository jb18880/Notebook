# SHELL脚本小技巧

### ${VARIABLE:-default_value}

> DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
>
> $HOME前面的-是什么意思

> 在 Bash 脚本中,`${VARIABLE:-default_value}` 这种形式的语法称为"parameter expansion"(参数展开)。它用于设置一个变量的值,如果该变量未定义或为空,则使用默认值。
>
> 在这个例子中:
>
> `DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}`
>
> - 首先检查 `DOCKER_CONFIG` 环境变量是否已定义。
> - 如果 `DOCKER_CONFIG` 已定义且不为空,则使用它的值。
> - 如果 `DOCKER_CONFIG` 未定义或为空,则使用默认值 `$HOME/.docker`。
>
> `$HOME` 是一个常用的环境变量,它代表当前用户的主目录路径。
>
> 所以这行代码的作用是:
>
> 1. 首先尝试使用 `DOCKER_CONFIG` 环境变量的值。
> 2. 如果 `DOCKER_CONFIG` 未定义或为空,则使用默认值 `$HOME/.docker`。
>
> 这种用法可以让脚本更加灵活和健壮,因为它可以处理环境变量未定义的情况。