#!/bin/bash
#Author:owen
#Description:系统安装后的初始优化
#Version:1.0

#定义变量
Vim_autoload=/usr/share/vim/vim74/autoload/
Vim_bundle=/usr/share/vim/vim74/bundle/

#检查用户
Check_user(){
    if [ $UID -ne 0 ]
    then
        echo "请使用root或加sudo执行"
        exit 1
    fi
}

#安装软件包
Install_soft(){
    if [[ "$(lsb_release -d 2>/dev/null|awk '{print $2}')" == "CentOS" || -x /usr/bin/yum ]]
    then
        yum update -y -q
        yum install -y -q epel-release
        yum install -y -q bash-completion bash-completion-extras ctags dstat gcc gcc-c++ git htop iptables links lrzsz lsof mlocate nc net-tools nmap ntp ntpdate ntsy  sv openssh-clients openssh-devel redhat-lsb rsync sysstat tcpdump tmux tree unzip vim vim-enhanced wget  
        #禁用selinux
        sed -i 's@SELINUX=enforcing@SELINUX=disabled@' /etc/selinux/config

    elif [[ "$(lsb_release -d 2>/dev/null|awk '{print $2}')" == "Ubuntu" || -x /usr/bin/apt ]]
    then
        apt-get update -qq
        apt-get install -y -qq autoconf atop acl cmake curl dstat exuberant-ctags gcc g++ git glances htop lrzsz make nmap sysstat tree unzip wget zip 
        sed -i '/ENABLED/s/false/true/g' /etc/default/sysstat && service sysstat start &>/dev/null
        ln -sf /usr/bin/vim.basic /etc/alternatives/editor
    fi
}

#安装基础包和系统优化
Base_install(){
    #同步时间
    echo "*/30 * * * * ntpdate ntp.ubuntu.com    >/dev/null 2>&1" >> /etc/crontab
    #更改命令提示符颜色
    PS1='\[\e[40;31;1m\]\u@\h\[\033[00m\]:\[\033[40;34;1m\]\w\[\033[00m\]$ '

    #优化文件描述符
cat >> /etc/security/limits.conf << EOF
*                     soft     nofile             65534
*                     hard     nofile             65534
EOF

    #优化系统内核
    cat >> /etc/sysctl.conf << EOF
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 1
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 36000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 16384
net.core.netdev_max_backlog = 16384
net.ipv4.tcp_max_orphans = 16384
EOF
    /sbin/sysctl -p


    #优化命令别名
cat >> /etc/profile <<EOF
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias vi=vim
alias sudo='sudo '
export EDITOR=vim
EOF
}

#下载VIM插件
Download_vim_plug(){
    #插件管理器
    wget https://tpo.pe/pathogen.vim -P /usr/share/vim/vim74/autoload/
    [ ! -e $Vim_bundle ] && mkdir -p $Vim_bundle
    cd $Vim_bundle
    #下载molokai配色
    wget https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim -P /usr/share/vim/vim74/colors
    #下载配色calmar256-dark
    wget  https://gitshell.com/Lawrence-zxc/vimfile/raw/blob/master/colors/calmar256-dark.vim -P /usr/share/vim/vim74/colors
    #下载状态栏插件
    git clone https://github.com/vim-airline/vim-airline
    #符号自动补全
    git clone git://github.com/Raimondi/delimitMate.git
    #语法检查
    git clone https://github.com/scrooloose/syntastic.git
    #快速切换符号/标签,快捷键dst,ysiw",cst等
    git clone git://github.com/tpope/vim-surround.git
    #快速替换字符串:%S{abc,123}/{123,abc}/g
    git clone https://github.com/tpope/vim-abolish.git
    #使用按键.重复插件操作
    git clone git://github.com/tpope/vim-repeat.git
    #目录树,快捷键ctrl+n
    git clone https://github.com/scrooloose/nerdtree
    #文件搜索
    git clone https://github.com/kien/ctrlp.vim.git
    #格式对齐
    git clone https://github.com/godlygeek/tabular.git
    #文件名补全
    git clone https://github.com/vim-scripts/AutoComplPop.git
    #快速跳转,快捷键,,w,,b,,k,,j
    git clone https://github.com/easymotion/vim-easymotion.git
    #代码片断补全,快捷键ctrl+\
    git clone https://github.com/drmingdrmer/xptemplate
    #函数列表,快捷键F12
    git clone https://github.com/int3/vim-taglist-plus.git
    #快速注释,快捷键,cc ,cA,cu,cm,cy,c$,cs
    git clone https://github.com/scrooloose/nerdcommenter.git
    #html代码补全,快捷键ctrl+y+,
    git clone https://github.com/mattn/emmet-vim.git
}

#优化vim
Vim_config(){
    [ -d ~/.vim ] || mkdir ~/.vim
    cat >>/usr/share/vim/vimfiles/template.py <<EOF
#!/usr/bin/python
#Author:owen
#Version:1.0
EOF

    cat >>/usr/share/vim/vimfiles/template.sh <<EOF
#!/bin/bash
#Author:owen
#Version:1.0
EOF

    cat >>~/.vimrc <<EOF
"显示行号
set number
"高亮显示当前行
set cursorline
"括号匹配
set showmatch
"忽略大小写
set ignorecase
"自动缩进
set autoindent
"c语言自动缩进
set cindent
"取消查找高亮匹配
set nohlsearch
"查找时实时匹配
set incsearch
"查找时关键字如果为大写则禁用ignorecase
set smartcase
"语法高亮
syntax on
"显示标尺
set ruler
"设定tab宽度为4个字符
set tabstop=4
"设定退格键退回缩进长度
set softtabstop=4
"设定自动缩进为4个字符
set shiftwidth=4
"用space替代tab的输入
set expandtab
"启用文件类型检测
filetype indent on
filetype plugin on
"不兼容vi模式
set nocompatible
"开启256色
set t_Co=256
"设置背景颜色
set background=dark
"启用molokai配色
colorscheme molokai
"始终显示最后一个状态行
set laststatus=2
"设置快捷键映射
inoremap <C-l> <Right>
inoremap <C-f> <Right>
inoremap <C-h> <Left>  #如果安装有AutoComplPop插件，将导致映射无法生效
inoremap <C-b> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap<C-e> <End>
inoremap<C-a> <Home>
"启动插件管理器
call pathogen#infect()
call pathogen#helptags()
"加载shell和python模板
autocmd BufNewFile *.sh 0r /usr/share/vim/vimfiles/template.sh
autocmd BufNewFile *.py 0r /usr/share/vim/vimfiles/template.py
autocmd BufNewFile * normal G
map <F3> :tabnew .<CR>
let g:syntastic_check_on_open = 1
"使用 "mapleader" 变量的映射
let mapleader = "," 
let g:mapleader = "," 
"映射F12键打开函数列表
noremap <F12> :TlistToggle<CR>
let Tlist_Exit_OnlyWindow = 1
let Tlist_Use_Right_Window=1 "在右侧显示窗口
"映射Ctrl+n打开目录列表
map <C-n> :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
let g:airline#extensions#tabline#enabled = 1
EOF
}

Main(){
    echo "正在优化系统,请耐心等候..."
    Check_user && \
    Install_soft && \
    Base_install && \
    Download_vim_plug && \
    Vim_config
}

Main
echo "优化已完成,需要重启系统才能完全生效!"
