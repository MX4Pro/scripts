#!/bin/bash
#Author:owen
#Description:vim扩展及个性化脚本,适用于vim7.4
#Version:1.0

#定义变量
Vim_autoload=/usr/share/vim/vim74/autoload/
Vim_bundle=/usr/share/vim/vim74/bundle/

#定义消息显示颜色
Red(){
    echo -e "\033[31m$*\033[0m"
}

Green(){
    echo -e "\033[32m$*\033[0m"
}

#检查用户
Check_user(){
    if [ $UID -ne 0 ]
    then
        Red "请使用root或加sudo执行!"
        exit 1
    fi
}

#安装软件包
Install_soft(){
    if [[ "$(lsb_release -d 2>/dev/null|awk '{print $2}')" == "CentOS" || -x /usr/bin/yum ]]
    then
        ps aux|grep [y]um && { Red "已有yum进程,请稍候再运行此脚本!";exit 1;}
        yum install -y -q ctags git vim vim-enhanced wget  || \
        { Red "无法安装软件,请检查网络是否正常或另有yum安装进程!";exit 1;}

    elif [[ "$(lsb_release -d 2>/dev/null|awk '{print $2}')" == "Ubuntu" || -x /usr/bin/apt ]]
    then
        ps aux|grep [a]pt && { Red "已有apt进程,请稍候再运行此脚本!";exit 1;} || apt-get update -qq
        apt-get install -y -qq exuberant-ctags git wget || \
        { Red "无法安装软件,请检查网络是否正常或另有apt安装进程!";exit 1;}
        ln -sf /usr/bin/vim.basic /etc/alternatives/editor
    fi
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
inoremap <C-h> <Left>  "如果安装有AutoComplPop插件，将导致映射无法生效
inoremap <C-b> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap<C-e> <End>
inoremap<C-a> <Home>

"启用插件管理器
call pathogen#infect()
call pathogen#helptags()

"加载shell和python模板
autocmd BufNewFile *.sh 0r /usr/share/vim/vimfiles/template.sh
autocmd BufNewFile *.py 0r /usr/share/vim/vimfiles/template.py
autocmd BufNewFile * normal G

"映射F3键打开标签窗口
map <F3> :tabnew .<CR>

"打开buffer时就执行语法检查
let g:syntastic_check_on_open = 1

"mapleader快捷键由\更改为, 
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
    clear
    Check_user && \
    Green "正在个性化vim,请耐心等候..."
    Install_soft && \
    Download_vim_plug && \
    Vim_config && \
    grep 'alias vi=vim' /etc/profile &>/dev/null || echo "alias vi=vim" >>/etc/profile
}

Main
Green "vim个性化已完成!最好执行source /etc/profile加载别名以便生效"
