#!/bin/bash
# By viagram <viagram.yang@gmail.com>

PATH=${PATH}:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

MY_SCRIPT="$(dirname $(readlink -f $0))/$(basename $0)"

function Check_OS(){
    Text=$(cat /etc/*-release)
    if echo ${Text} | egrep -io "(centos[a-z ]*5|red[a-z ]*hat[a-z ]*5)" >/dev/null 2>&1; then echo centos5
    elif echo ${Text} | egrep -io "(centos[a-z ]*6|red[a-z ]*hat[a-z ]*6)" >/dev/null 2>&1; then echo centos6
    elif echo ${Text} | egrep -io "(centos[a-z ]*7|red[a-z ]*hat[a-z ]*7)" >/dev/null 2>&1; then echo centos7
    elif echo ${Text} | egrep -io "Fedora[a-z ]*[0-9]{1,2}" >/dev/null 2>&1; then echo fedora
    elif echo ${Text} | egrep -io "debian[a-z /]*[0-9]{1,2}" >/dev/null 2>&1; then echo debian
    elif echo ${Text} | egrep -io "ubuntu" >/dev/null 2>&1; then echo ubuntu
   fi
}

function printnew(){
    typeset -l CHK
    WENZHI=""
    COLOUR=""
    HUANHANG=0
    for PARSTR in "${@}"; do
        CHK="${PARSTR}"
        if echo "${CHK}" | egrep -io "^\-[[:graph:]]*" >/dev/null 2>&1; then
            case "${CHK}" in
                -black) COLOUR="\033[30m";;
                -red) COLOUR="\033[31m";;
                -green) COLOUR="\033[32m";;
                -yellow) COLOUR="\033[33m";;
                -blue) COLOUR="\033[34m";;
                -purple) COLOUR="\033[35m";;
                -cyan) COLOUR="\033[36m";;
                -white) COLOUR="\033[37m";;
                -a) HUANHANG=1 ;;
                *) COLOUR="\033[37m";;
            esac
        else
            WENZHI+="${PARSTR}"
        fi
    done
    if [[ ${HUANHANG} -eq 1 ]]; then
        printf "${COLOUR}%b%s\033[0m" "${WENZHI}"
    else
        printf "${COLOUR}%b%s\033[0m\n" "${WENZHI}"
    fi
}

function Checkcommand(){
    local name=""
    for name in $(echo "$1" | sed 's/,/\n/g' | sed '/^$/d' | sed 's/^[ \t]*//g' | sed 's/[ \t]*$//g'); do
        if ! command -v ${name} >/dev/null 2>&1; then
            [[ "${name}" == "pip" ]] && name="python-pip"
            [[ "${name}" == "setsid" || "${name}" == "ipcs" ]] && name="util-linux"
            [[ "${name}" == "crontab" ]] && name="vixie-cron"
            printnew -a -green "    正在安装: "
            printnew -yellow ${name}
            [[ "$(Check_OS)" == "centos6" || "$(Check_OS)" == "centos7" ]] && yum install -y ${name} >/dev/null 2>&1
            [[ "$(Check_OS)" == "fedora" ]] && dnf install -y ${name} >/dev/null 2>&1
            [[ "$(Check_OS)" == "ubuntu" ]] && apt install -y ${name} >/dev/null 2>&1
        fi
    done
}

function doNet(){
    # 以前优化设置来自于网络, 具体用处嘛~~~我也不知道^_^.
    sysctl=/etc/sysctl.conf
    limits=/etc/security/limits.conf
    sed -i '/* soft nofile/d' $limits;echo '* soft nofile 1024000'>>$limits
    sed -i '/* hard nofile/d' $limits;echo '* hard nofile 1024000'>>$limits
    echo "ulimit -SHn 1024000">>/etc/profile
    ulimit -n 1024000
    sed -i '/net.ipv4.ip_forward/d' $sysctl;echo 'net.ipv4.ip_forward=1'>>$sysctl
    sed -i '/net.ipv4.conf.default.rp_filter/d' $sysctl;echo 'net.ipv4.conf.default.rp_filter=1'>>$sysctl
    sed -i '/net.ipv4.conf.default.accept_source_route/d' $sysctl;echo 'net.ipv4.conf.default.accept_source_route=0'>>$sysctl
    sed -i '/kernel.sysrq/d' $sysctl;echo 'kernel.sysrq=0'>>$sysctl
    sed -i '/kernel.core_uses_pid/d' $sysctl;echo 'kernel.core_uses_pid=1'>>$sysctl
    sed -i '/kernel.msgmnb/d' $sysctl;echo 'kernel.msgmnb=65536'>>$sysctl
    sed -i '/kernel.msgmax/d' $sysctl;echo 'kernel.msgmax=65536'>>$sysctl
    sed -i '/kernel.shmmax/d' $sysctl;echo 'kernel.shmmax=68719476736'>>$sysctl
    sed -i '/kernel.shmall/d' $sysctl;echo 'kernel.shmall=4294967296'>>$sysctl
    sed -i '/net.ipv4.tcp_timestamps/d' $sysctl;echo 'net.ipv4.tcp_timestamps=0'>>$sysctl
    sed -i '/net.ipv4.tcp_retrans_collapse/d' $sysctl;echo 'net.ipv4.tcp_retrans_collapse=0'>>$sysctl
    sed -i '/net.ipv4.icmp_echo_ignore_broadcasts/d' $sysctl;echo 'net.ipv4.icmp_echo_ignore_broadcasts=1'>>$sysctl
    sed -i '/net.ipv4.conf.all.rp_filter/d' $sysctl;echo 'net.ipv4.conf.all.rp_filter=1'>>$sysctl
    sed -i '/fs.inotify.max_user_watches/d' $sysctl;echo 'fs.inotify.max_user_watches=65536'>>$sysctl
    sed -i '/net.ipv4.conf.default.promote_secondaries/d' $sysctl;echo 'net.ipv4.conf.default.promote_secondaries=1'>>$sysctl
    sed -i '/net.ipv4.conf.all.promote_secondaries/d' $sysctl;echo 'net.ipv4.conf.all.promote_secondaries=1'>>$sysctl
    sed -i '/kernel.hung_task_timeout_secs=0/d' $sysctl;echo 'kernel.hung_task_timeout_secs=0'>>$sysctl
    sed -i '/fs.file-max/d' $sysctl;echo 'fs.file-max=1024000'>>$sysctl
    sed -i '/net.core.wmem_max/d' $sysctl;echo 'net.core.wmem_max=67108864'>>$sysctl
    sed -i '/net.core.netdev_max_backlog/d' $sysctl;echo 'net.core.netdev_max_backlog=32768'>>$sysctl
    sed -i '/net.core.somaxconn/d' $sysctl;echo 'net.core.somaxconn=32768'>>$sysctl
    sed -i '/net.ipv4.tcp_syncookies/d' $sysctl;echo 'net.ipv4.tcp_syncookies=1'>>$sysctl
    sed -i '/net.ipv4.tcp_tw_reuse/d' $sysctl;echo 'net.ipv4.tcp_tw_reuse=1'>>$sysctl
    sed -i '/net.ipv4.tcp_fin_timeout/d' $sysctl;echo 'net.ipv4.tcp_fin_timeout=30'>>$sysctl
    sed -i '/net.ipv4.tcp_keepalive_time/d' $sysctl;echo 'net.ipv4.tcp_keepalive_time=1200'>>$sysctl
    sed -i '/net.ipv4.ip_local_port_range/d' $sysctl;echo 'net.ipv4.ip_local_port_range=1024 65500'>>$sysctl
    sed -i '/net.ipv4.tcp_max_syn_backlog/d' $sysctl;echo 'net.ipv4.tcp_max_syn_backlog=8192'>>$sysctl
    sed -i '/net.ipv4.tcp_max_tw_buckets/d' $sysctl;echo 'net.ipv4.tcp_max_tw_buckets=6000'>>$sysctl
    sed -i '/net.ipv4.tcp_fastopen/d' $sysctl;echo 'net.ipv4.tcp_fastopen=3'>>$sysctl
    sed -i '/net.ipv4.tcp_rmem/d' $sysctl;echo 'net.ipv4.tcp_rmem=4096'>>$sysctl
    sed -i '/net.ipv4.tcp_wmem/d' $sysctl;echo 'net.ipv4.tcp_wmem=4096'>>$sysctl
    sed -i '/net.ipv4.tcp_mtu_probing/d' $sysctl;echo 'net.ipv4.tcp_mtu_probing=1'>>$sysctl
    sysctl -p >/dev/null 2>&1
    sleep 1
}

function pause(){
    read -n 1 -p "按任意键继续..." INPUT
    [[ -n "$INPUT" ]] && echo -ne "\b\033[K" && echo
}

function set_autorun() {
    ln -sf /appex/bin/serverSpeeder.sh /etc/rc.d/init.d/serverSpeeder
    if which chkconfig >/dev/null 2>&1; then
        chkconfig --add serverSpeeder >/dev/null
    else
        ln -sf /etc/rc.d/init.d/serverSpeeder /etc/rc.d/rc2.d/S20serverSpeeder
        ln -sf /etc/rc.d/init.d/serverSpeeder /etc/rc.d/rc3.d/S20serverSpeeder
        ln -sf /etc/rc.d/init.d/serverSpeeder /etc/rc.d/rc4.d/S20serverSpeeder
        ln -sf /etc/rc.d/init.d/serverSpeeder /etc/rc.d/rc5.d/S20serverSpeeder
    fi
}

function check_kernel(){
    printnew -green -a '检测系统内核: '
    if [[ $(uname -r) != "3.10.0-327.el7.x86_64" ]]; then
        printnew -red "失败."
        printnew -green -a "锐速加速提示: "
        printnew -red "暂不支持当前内核."
        printnew -green -a "系统当前内核: "
        printnew -yellow $(uname -r)
        printnew -green -a "尝试安装内核: "
        printnew -yellow "3.10.0-327.el7.x86_64."
        pause
        if ! wget -N --no-check-certificate -c ${down_url}/kernel-3.10.0-327.el7.x86_64.zip; then
            printnew -red "下载 kernel-3.10.0-327.el7.x86_64.zip 失败."
            exit 1
        fi
		if ! unzip -o kernel-3.10.0-327.el7.x86_64.zip; then
            printnew -red "解压 kernel-3.10.0-327.el7.x86_64.zip 失败."
            exit 1
        fi
        yum remove -y kernel-firmware kernel-headers
        if ! yum install -y kernel-3.10.0-327.el7.x86_64.rpm kernel-headers-3.10.0-327.el7.x86_64.rpm kernel-devel-3.10.0-327.el7.x86_64.rpm; then
            printnew -red "安装内核失败."
            rm -rf kernel-*.rpm
            exit 1
        fi
        rm -rf kernel-*.rpm
        printnew -green -a "设置新内核默认启动: "
        kernel_name='CentOS Linux \(3.10.0-327.el7.x86_64\) 7 \(Core\)'
        if [[ -f /boot/grub/grub.conf ]]; then
            kernel_default=$(egrep '^title ' /boot/grub/grub.conf | awk -F'title ' '{print i++ " : " $2}' | egrep  -i "${kernel_set_name}" | egrep -v debug | awk '{print $1}' | head -n 1)
            sed -i "s/^default.*/default=${kernel_default}/" /boot/grub/grub.conf >/dev/null 2>&1
            printnew -yellow "成功. "
        else
            if ! command -v grub2-mkconfig >/dev/null 2>&1; then
                yum remove -y grub2-tools-minimal
                yum install -y grub2-tools
            fi
            grub2-mkconfig -o /boot/grub2/grub.cfg >/dev/null 2>&1
            boot_kernel=$(echo ${kernel_name} | sed 's/\\//g')
            grub2-set-default "${boot_kernel}"
            kernel_now=$(grub2-editenv list | awk -F '=' '{print $2}')
            if test "${boot_kernel}" == "${kernel_now}"; then
                printnew -yellow "成功. "
                printnew -green "最新内核: ${boot_kernel}"
                printnew -green "默认内核: ${kernel_now}"
            else
                printnew -red "失败. "
                exit 1
            fi
        fi
        doNet
        \cp -f /etc/yum.conf /etc/yum.conf_bak
        sed -i 's/^#.*//g;/^[[:space:]]*$/d;' /etc/yum.conf
        if ! egrep -io 'exclude=kernel*' /etc/yum.conf >/dev/null 2>&1; then
            echo 'exclude=kernel*' >>/etc/yum.conf
        fi
        printnew -green "升级完成, 将重启系统后继续安装."
        read -p "输入 [y/n] 选择是否重启(默认为y): " is_reboot
        [[ -z "${is_reboot}" ]] && is_reboot='y'
        if [[ ${is_reboot} =~ ^[Yy]$ ]]; then
            if ! egrep -i "${MY_SCRIPT}" ~/.bashrc >/dev/null 2>&1; then
                echo "bash ${MY_SCRIPT} reinstall">>~/.bashrc
            fi
            reboot
        fi
    else
        printnew -green "成功."
    fi
}

function Make_Lic(){
    MAC=$(ifconfig "$Eth" |awk '/HWaddr/{ print $5}')
    [ -z "$MAC" ] && MAC=$(ifconfig "$Eth" |awk '/ether/{ print $2}')
    [ -z "$MAC" ] && Uninstall && echo "没有找到有效的 MAC 地址! " && exit 1
    if ! curl -skL --connect-timeout 8 -m 12 "https://w3.zuzb.com/api/apxkey.php?mac=${MAC}" -o "/appex/etc/apx.lic"; then
        printnew -red "获取授权文件失败."
        exit 1
    fi
    if [[ "$(du -b /appex/etc/apx.lic | awk '{ print $1}')" -ne '152' ]]; then
        printnew -red "获取授权文件错误."
        exit 1
    fi
}

function install(){
    printnew -green "是否需要开启对PPTP,L2TP等传统VPN的加速服务?"
    read -p "输入 [y/n] 选择(默认为n): " is_vpn
    [[ -z "${is_vpn}" ]] && is_vpn='n'
    printnew -green "安装锐速..."
    \rm -rf /tmp/appex.zip
    if ! wget -N --no-check-certificate -c ${down_url}/appex.zip; then
        printnew -red "下载锐速安装包失败."
        exit 1
    fi
    [[ -f /tmp/appex ]] && rm -rf /tmp/appex
    mkdir -p /tmp/appex
    if ! unzip -o -d /tmp/appex /tmp/appex.zip && printnew -red "解压锐速安装包失败."; then
        exit 1
    fi
    APXEXE=$(ls /tmp/appex/apxfiles/bin/ | awk '/^acce-/{print}')
    sed -i "s/^accif=.*/accif=\"${Eth}\"/g" /tmp/appex/apxfiles/etc/config
    sed -i "s#^apxexe=.*#apxexe=\"/appex/bin/${APXEXE}\"#g" /tmp/appex/apxfiles/etc/config
    sed -i "s/^installerID=.*/installerID=\"Yangwei.Work\"/g" /tmp/appex/apxfiles/etc/config
    
    [[ -d /appex/bin ]] || mkdir -p /appex/bin
    [[ -d /appex/etc ]] || mkdir -p /appex/etc
    [[ -d /appex/log ]] || mkdir -p /appex/log
    \cp -f /tmp/appex/apxfiles/bin/* /appex/bin/
    \cp -f /tmp/appex/apxfiles/etc/* /appex/etc/
    which ethtool >/dev/null 2>&1 && (rm -rf /appex/bin/ethtool && \cp -f $(which ethtool) /appex/bin/)
    chmod +x /appex/bin/*
    Make_Lic
    if [[ ${is_vpn} =~ ^[Yy]$ ]]; then
        sed -i "s/^accppp=.*/accppp=\"1\"/" /appex/etc/config
    fi
    set_autorun
    bash /appex/bin/serverSpeeder.sh stop >/dev/null 2>&1
    bash /appex/bin/serverSpeeder.sh start 
    \rm -rf /tmp/appex* >/dev/null 2>&1
    if egrep -i "${MY_SCRIPT}" ~/.bashrc >/dev/null 2>&1; then
        sed -i "/$(echo ${MY_SCRIPT} | sed 's#/#\\/#g')/d" ~/.bashrc
    fi
    bash /appex/bin/serverSpeeder.sh status
    printnew -green "锐速安装完成."
    exit 0
}

function check_sharemem(){
    maxSegSize=$(ipcs -l | awk -F= '/max seg size/ {print $2}' | sed "s/^[[:space:]]//g")
    [[ -z ${maxSegSize} ]] && maxSegSize=$(ipcs -l | awk -F= '/最大段大小/ {print $2}' | sed "s/^[[:space:]]//g")
    maxTotalSharedMem=$(ipcs -l | awk -F= '/max total shared memory/ {print $2}' | sed "s/^[[:space:]]//g")
    [[ -z ${maxTotalSharedMem} ]] && maxTotalSharedMem=$(ipcs -l | awk -F= '/最大总共享内存/ {print $2}' | sed "s/^[[:space:]]//g")
    if [[ $maxSegSize -eq 0 || $maxTotalSharedMem -eq 0 ]]; then
        printnew -red "锐速需要使用共享内存, 请配置系统共享内存."
        exit 1
    fi
}

function check_speeder(){
    if [[ ! -f /appex/bin/serverSpeeder.sh ]]; then
        [[ $1 -eq 1 ]] && printnew -red "检测到你尚未安装锐速." && exit 1
    else
        [[ $1 -ne 1 ]] && printnew -yellow "检测到你已安装锐速, 即将再次覆盖安装." && pause
    fi
}

#################################################################################################################
echo -ne "\033[33m"
cat <<'EOF'
###################################################################
#                     _                                           #
#              __   _(_) __ _  __ _ _ __ __ _ _ __ ___            #
#              \ \ / / |/ _` |/ _` | '__/ _` | '_ ` _ \           #
#               \ V /| | (_| | (_| | | | (_| | | | | | |          #
#                \_/ |_|\__,_|\__, |_|  \__,_|_| |_| |_|          #
#                             |___/                               #
#                                                                 #
###################################################################
EOF
echo -e "\033[0m"
[[ ${EUID} -ne 0 ]] && printnew -red "错误: 请以root权限运行此脚本." && exit 1
[[ "$(Check_OS)" != "centos7" ]] && printnew -red "仅支持CentOS 7." && exit 1

[[ ! -d /tmp ]] && mkdir -p /tmp
cd /tmp
down_url="https://raw.githubusercontent.com/viagram/CentOS-NetSpeed/master"
Eth=$(ip route show |grep -o 'default via [0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.*' |head -n1 | sed 's/proto.*\|onlink.*//g' |awk '{print $NF}')
[[ -z "${Eth}" ]] && Eth=$(ls /sys/class/net | awk '/^e/{print}')

if [[ ${1} == "reinstall" ]]; then
    check_speeder
    check_kernel
    install
else
    printnew -yellow "1. \033[32m安装锐速"
    printnew -yellow "2. \033[32m卸载锐速"
    printnew -yellow "3. \033[32m启用锐速"
    printnew -yellow "4. \033[32m停止锐速"
    printnew -yellow "5. \033[32m重启锐速"
    printnew -yellow "6. \033[32m更新授权"
    printnew -yellow "7. \033[32m查看状态"
    printnew -yellow "0. \033[32m退出脚本"
    printnew
    while true; do
        read -p "请输入数字选择(默认为1):" num
        [[ -z "${num}" ]] && num=1
        if echo ${num} | egrep -i '^[01234567]$' >/dev/null 2>&1; then
            break
        else
            printnew -red "    输入错误, 请输入0-7间的数字!"
        fi
    done
    case "$num" in
        1)
            printnew -green '检测依懒程序...'
            Checkcommand which,wget,unzip,ethtool,ipcs,chkconfig
            check_sharemem
            check_speeder
            check_kernel
            install
        ;;
        2)
            check_speeder 1
            printnew -green "即将卸载锐速,请确认!"
            pause
            bash /appex/bin/serverSpeeder.sh uninstall
        ;;
        3)
            check_speeder 1
            bash /appex/bin/serverSpeeder.sh start
        ;;
        4)
            check_speeder 1
            bash /appex/bin/serverSpeeder.sh stop
        ;;
        5)
            check_speeder 1
            bash /appex/bin/serverSpeeder.sh restart
        ;;
        6)
            check_speeder 1
            bash /appex/bin/serverSpeeder.sh renew
        ;;
        7)
            check_speeder 1
            bash /appex/bin/serverSpeeder.sh status
        ;;
        0)
            exit 1
        ;;
        *)
            printnew -red "    Error."
        ;;
    esac
fi

