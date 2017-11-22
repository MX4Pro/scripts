#!/bin/bash
#Description:oh-my-zsh + autojump 一键脚本
#Author:Owen
#Tested with Ubuntu 14.04/16.04,CentOS6.x/CentOS7.x


#定义通知颜色
Red(){
    echo -e "\033[31m$*\033[0m\n"
}

Green(){
    echo -e "\033[32m$*\033[0m\n"
}

#
Ubuntu_install(){
	ping -c2 www.baidu.com >/dev/null
    if [ $? -eq 0 ] 
	then
		pgrep apt >/dev/null && { Red "apt正在运行,请稍候再试";exit; } || { sudo apt-get update -q;sudo apt-get install -y autojump git ncurses-base wget zsh; }
		git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/zsh-syntax-highlighting
		sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)" &&\
		cat >>~/.zshrc<<EOF
[ -e /lib/terminfo/x/xterm-256color ] && export TERM='xterm-256color'
source ~/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
HOSTNAME=$HOSTNAME
if [ $UID -eq 0 ];then
PROMPT='%{\$fg_bold[red]%}%n@%m:%{\$fg_bold[red]%}%p%{\$fg[cyan]%}%~%{\$fg_bold[blue]%}\$(git_prompt_info)%{\$fg_bold[blue]%}% %{\$reset_color%}\$ '
else
PROMPT='%{\$fg_bold[green]%}%n@%m:%{\$fg_bold[green]%}%p%{\$fg[cyan]%}%~%{\$fg_bold[blue]%}\$(git_prompt_info)%{\$fg_bold[blue]%}% %{\$reset_color%}\$ '
fi
[[ -s /usr/share/autojump/autojump.zsh ]] && source /usr/share/autojump/autojump.zsh
EOF
	else
		Red "无法连接外网,请检查网络设置."
        exit 1
	fi
}

#
CentOS_install(){
	ping -c2 www.baidu.com >/dev/null
    if [ $? -eq 0 ]
	then
		pgrep yum >/dev/null && { Red "apt正在运行,请稍候再试";exit; } || sudo yum install -y epel-release
		sudo yum install -y autojump autojump-zsh git ncurses wget zsh 
		git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/zsh-syntax-highlighting
		sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)" &&\
		cat >>~/.zshrc<<EOF
[ -e /usr/share/terminfo/x/xterm-256color ] && export TERM='xterm-256color'
source ~/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
HOSTNAME=$HOSTNAME
if [ $UID -eq 0 ];then
PROMPT='%{\$fg_bold[red]%}%n@%m:%{\$fg_bold[red]%}%p%{\$fg[cyan]%}%~%{\$fg_bold[blue]%}\$(git_prompt_info)%{\$fg_bold[blue]%}% %{\$reset_color%}\$ '
else
PROMPT='%{\$fg_bold[green]%}%n@%m:%{\$fg_bold[green]%}%p%{\$fg[cyan]%}%~%{\$fg_bold[blue]%}\$(git_prompt_info)%{\$fg_bold[blue]%}% %{\$reset_color%}\$ '
fi
[[ -s /etc/profile.d/autojump.zsh ]] && source /etc/profile.d/autojump.zsh
EOF
	else
		Red "无法连接外网,请检查网络设置."
        exit 1
	fi
}

#
Check_system_version(){
if grep -sq 'Ubuntu' /proc/version
then
    Ubuntu_install
elif grep -sq 'centos' /proc/version 
then
	CentOS_install
fi
}


Main(){
	Check_system_version
}

Main && Green "安装成功,请重新登录终端开始享受zsh之旅."
