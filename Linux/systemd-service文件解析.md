# systemd-service文件解析

1. redis-server.service文件

   ```
   root@master01:/usr/local/redis-7.4.0/utils# cat systemd-redis_server.service
   # example systemd service unit file for redis-server
   #
   # In order to use this as a template for providing a redis service in your
   # environment, _at the very least_ make sure to adapt the redis configuration
   # file you intend to use as needed (make sure to set "supervised systemd"), and
   # to set sane TimeoutStartSec and TimeoutStopSec property values in the unit's
   # "[Service]" section to fit your needs.
   #
   # Some properties, such as User= and Group=, are highly desirable for virtually
   # all deployments of redis, but cannot be provided in a manner that fits all
   # expectable environments. Some of these properties have been commented out in
   # this example service unit file, but you are highly encouraged to set them to
   # fit your needs.
   #
   # Please refer to systemd.unit(5), systemd.service(5), and systemd.exec(5) for
   # more information.
   
   [Unit]
   Description=Redis data structure server
   Documentation=https://redis.io/documentation
   #Before=your_application.service another_example_application.service
   #AssertPathExists=/var/lib/redis
   Wants=network-online.target
   After=network-online.target
   
   [Service]
   ExecStart=/usr/local/bin/redis-server --supervised systemd --daemonize no
   ## Alternatively, have redis-server load a configuration file:
   #ExecStart=/usr/local/bin/redis-server /path/to/your/redis.conf
   LimitNOFILE=10032
   NoNewPrivileges=yes
   #OOMScoreAdjust=-900
   #PrivateTmp=yes
   Type=notify
   TimeoutStartSec=infinity
   TimeoutStopSec=infinity
   UMask=0077
   #User=redis
   #Group=redis
   #WorkingDirectory=/var/lib/redis
   
   [Install]
   WantedBy=multi-user.target
   ```

   > 这个文件是一个 Systemd 服务单元文件的模板，用于在 Linux 系统上管理 Redis 服务器的启动和停止。这个文件定义了如何启动 Redis 进程、设置相关资源限制，以及如何在系统引导过程中启动 Redis。以下是对该文件各个部分的解释：
   >
   > ### [Unit] 部分
   >
   > - **Description**: 描述该服务的作用。在这里，它说明这是一个 Redis 数据结构服务器。
   > - **Documentation**: 指向 Redis 官方文档的链接。
   > - Before/After/Wants:
   >   - `Before`：指定该服务在哪些其他服务之前启动。注释掉的部分表明可以在这里列出需要在 Redis 之前启动的服务。
   >   - `Wants` 和 `After`：这些行定义了 Redis 服务的启动顺序。`Wants=network-online.target` 表示 Redis 希望网络服务可用后再启动，而 `After=network-online.target` 确保网络服务在 Redis 之前启动。
   >
   > ### [Service] 部分
   >
   > - **ExecStart**: 定义了启动 Redis 服务器的命令。
   >   - `/usr/local/bin/redis-server --supervised systemd --daemonize no`：启动 Redis 服务器，并指定使用 Systemd 进行进程监控（`--supervised systemd`）以及不以守护进程方式运行（`--daemonize no`）。
   >   - 如果你想让 Redis 加载一个配置文件，可以取消注释并修改 `ExecStart` 的第二行，将其指向你的配置文件路径。
   > - **LimitNOFILE**: 设置 Redis 进程可以打开的最大文件描述符数量，这里设置为 `10032`。
   > - **NoNewPrivileges**: 设置为 `yes`，意味着在此服务的进程及其子进程中，无法再获得新的权限，提升了安全性。
   > - **Type**: 设置为 `notify`，表示服务进程将在准备好接收请求时通知 Systemd。
   > - **TimeoutStartSec/TimeoutStopSec**: 设置服务的启动和停止超时时间。这里设置为 `infinity`，表示没有超时限制。
   > - **UMask**: 设置文件权限掩码为 `0077`，这意味着新创建的文件将只有拥有者有权限访问。
   > - **User/Group**: 注释掉的部分。建议将 Redis 以非 root 用户身份运行。可以取消注释并设置适当的用户和组。
   > - **WorkingDirectory**: 注释掉的部分。如果设置，会将 Redis 的工作目录切换到指定的路径。
   >
   > ### [Install] 部分
   >
   > - **WantedBy**: 指定该服务应该在多用户模式（`multi-user.target`）下启动，这是典型的非图形化系统运行级别。
   >
   > ### 总结
   >
   > 这个 Systemd 服务单元文件模板为 Redis 服务器的管理提供了一个基础框架。你可以根据需要修改文件的某些部分，例如 `ExecStart`、`User`、`Group` 和 `WorkingDirectory` 等，来适应你的系统环境和需求。配置好后，你可以通过以下命令将 Redis 服务安装到 Systemd 并启用它：
   >
   > ```
   > bash复制代码sudo systemctl daemon-reload
   > sudo systemctl enable redis-server
   > sudo systemctl start redis-server
   > ```
   >
   > 这将会使 Redis 在后台以守护进程的方式运行，并且在系统启动时自动启动 Redis 服务。

2. 什么是文件描述符；解释下NoNewPrivileges；如何创建合适的redis用户和组；redis的工作目录有什么用？

   > ### 1. **什么是文件描述符？**
   >
   > 文件描述符（File Descriptor, FD）是操作系统中用于表示打开的文件、网络连接或其他 I/O 资源的一个非负整数标识符。每个进程都有自己的文件描述符表，其中保存了它所打开的所有文件或资源的引用。文件描述符主要用于以下场景：
   >
   > - **文件读写**：当你打开一个文件时，操作系统返回一个文件描述符，你可以通过这个文件描述符对文件进行读写操作。
   > - **网络连接**：套接字也是通过文件描述符来管理的，每个打开的网络连接都会占用一个文件描述符。
   > - **标准输入/输出**：在 Unix 和 Linux 系统中，标准输入、输出和错误通常被映射为文件描述符 `0`、`1` 和 `2`。
   >
   > Redis 作为一个高并发的服务器，通常会打开大量的文件描述符来处理客户端连接、日志文件、数据文件等。因此，在 Redis 配置中需要设置合适的 `LimitNOFILE` 值，以确保系统为 Redis 分配足够的文件描述符。
   >
   > ### 2. **解释 NoNewPrivileges**
   >
   > `NoNewPrivileges` 是 Systemd 服务单元文件中的一个选项，用于提高服务的安全性。
   >
   > - **作用**：当 `NoNewPrivileges` 设置为 `yes` 时，服务进程及其子进程将不能获取新的特权。这意味着即使进程在运行时尝试通过执行具有 `setuid` 或 `setgid` 位的程序来提升权限，也不会生效。
   > - **应用场景**：该选项通常用于限制服务的权限，确保服务不会在运行过程中获取超出初始设置的权限，从而减少安全风险。
   >
   > ### 3. **如何创建合适的 Redis 用户和组**
   >
   > 为了安全性考虑，建议不要以 root 用户身份运行 Redis，而是创建一个专用的 Redis 用户和组，并将 Redis 进程运行在这个非特权用户下。
   >
   > **步骤如下：**
   >
   > 1. **创建 Redis 用户和组**：
   >
   >    - 创建一个名为 `redis` 的用户，同时创建同名组：
   >
   >      ```
   >      bash
   >      复制代码
   >      sudo adduser --system --group --no-create-home redis
   >      ```
   >
   >    - 这条命令解释：
   >
   >      - `--system`：创建一个系统用户，通常不允许登录。
   >      - `--group`：创建一个与用户同名的组。
   >      - `--no-create-home`：不为用户创建主目录。
   >
   > 2. **设置目录权限**：
   >
   >    - 将 Redis 的数据目录和日志目录的所有权设置为 `redis` 用户和组：
   >
   >      ```
   >      bash 复制代码 sudo chown -R redis:redis /var/lib/redis
   >      sudo chown -R redis:redis /var/log/redis
   >      ```
   >
   >    - 如果 Redis 安装在其他目录，也要确保这些目录的所有权和权限正确。 
   >
   > 3. **修改 Systemd 配置**： 
   >
   >    - 编辑 `redis-server.service` 文件，将 `User` 和 `Group` 选项设置为 `redis`
   >
   >      ```
   >      [Service]
   >      User=redis
   >      Group=redis
   >      ```
   >
   > ### 4. **Redis 的工作目录有什么用？** 
   >
   > Redis 的工作目录是指 Redis 进程运行时的当前目录，通常用于存储数据文件、持久化文件、日志文件等。工作目录可以在 `redis.conf` 配置文件中通过 `dir` 选项指定。
   >
   > **工作目录的主要用途：** 
   >
   > - **数据存储**：持久化文件如 RDB 文件和 AOF 文件会存储在工作目录中。 
   > - **临时文件**：Redis 可能会在工作目录中创建一些临时文件。 
   > - **日志文件**：如果没有在配置文件中指定日志文件的绝对路径，日志文件也可能会写入工作目录。 
   >
   > 确保工作目录的权限正确，并且指定的路径有足够的磁盘空间，以避免 Redis 在运行中遇到文件写入错误。

   

