" 脚本局部函数 "{{{
function! s:EchoTypeNotCorrect() abort
    echom ">_<  Failed,type not correct!"
endfunction

" 各种类型文件的运行函数  "{{{
function! s:RunC() abort
    execute "w"
    if(g:isLinux)
        execute g:leader_e_run_prefix."gcc -Wextra -Wall -g  % -o %:r && ./%:r "
    else
        execute g:leader_e_run_prefix."gcc -Wextra -Wall -g % -o %:r.exe  && echo -------- && %:r.exe "
    endif
endfunction

function! s:RunCpp() abort
    "使用cmd作为shell的情况下。(powershell不支持&&)
    execute "w"
    if(g:isLinux)
        execute g:leader_e_run_prefix."g++ -Wextra -Wall -std=c++17  -g  % -o %:r && ./%:r "  
    else
        execute g:leader_e_run_prefix."g++ -Wextra -Wall -std=c++17 -Wfatal-errors -g % -o %:r.exe && echo -------- && %:r.exe "
    endif
endfunction

function! s:RunShell() abort
    execute "w"
    execute g:leader_e_run_prefix."bash %"
endfunction

function! s:RunPython() abort
    execute "w"
    execute g:leader_e_run_prefix."python %"
endfunction

function! s:RunVimwiki() abort
    execute "w"
    execute ":VimwikiAll2HTML"
    let l:curPath=expand("%:p:h") 
    let l:curFile=expand("%:r")

    let l:newPath=l:curPath.'_html/'

    " 切换到html目录, 当前工作目录 变化
    call chdir(l:newPath)

    if filereadable( l:newPath . l:curFile . ".html")   "(当前工作目录)有同名的html

        "开始编辑html, 隐藏当前缓冲区
        execute 'vsplit ' . l:newPath . l:curFile . ".html "

        if filereadable("must.vim")  "有must.vim
            execute 'source ' . "must.vim"
        endif

        if filereadable( l:newPath . l:curFile . ".vim")   "有同名的vim脚本
            execute 'source ' . l:newPath . l:curFile . ".vim" 
        endif

        q "退出窗口

        call feedkeys("\<CR>")

        " 画面中央弹出弹窗，显示消息，移动光标就关闭弹窗
        let options = { 
                    \ 'highlight': 'WarningMsg',
                    \ 'moved':"any",
                    \ 'border':[3,3,3,3],
                    \ }
        let popup_id = popup_create('highlight.js替换成功!', options)

    endif

endfunction

function! s:RunDosBatch() abort
    execute "w"
    execute g:leader_e_run_prefix."%"
endfunction

"}}}

"}}}

"  < 判断是终端还是 Gvim > {{{
" -----------------------------------------------------------------------------
let g:isGUI = 0
if has("gui_running")
    "Gvim下的配置
    let g:isGUI = 1
endif
"}}}
" < Gvim 专用设置 > {{{
" -----------------------------------------------------------------------------
if(g:isGUI)
    "Gvim下的配置 
    "Gvim 安装路径下的 _vimrc文件，优先级比不上 "~/.vimrc文件，
    "但若是 C:/Users/icebg下不存在.vimrc , 那么 echo $MYVIMRC 就会打印出 D:\Program Files（x86）\Vim
    "启用GDB包,然后就能[ :Termdebug + 可执行程序名] .termdebug 是从 Vim 8.1 开始内置的调试插件，仅支持 GDB。
    packadd termdebug 
    nnoremap <F11> :call GDB()<CR>
    function! g:GDB() abort
        execute "Termdebug %:r"
    endfunction
    "Gvim行距 linespace
    set linespace=4
    if !exists("g:myflag_colorscheme")
        " 在这里编写您希望只使用一次的配置
        colorscheme motus
        " 将变量 myflag_colorscheme 设置为已存在，避免重复执行
        let g:myflag_colorscheme = 1
    endif
    "BufNewFile创建新的txt文件的时候， BufReadPost打开已有txt文件之后
    autocmd BufNewFile,BufReadPost *.txt setlocal linespace=10
    autocmd BufLeave *.txt setlocal linespace=4
    set guifont=Cr.DejaVuSansMono.YaHei:h13
else
    "终端vim下的配置
    " 判断变量 myflag 是否存在
    if !exists("g:myflag_colorscheme")
        " 在这里编写您希望只使用一次的配置
        colorscheme monokai "设置配色方案，在~/.vim/colors/目录下提前放置molokai.vim
        " 将变量 myflag_colorscheme 设置为已存在，避免重复执行
        let g:myflag_colorscheme = 1
    endif
endif
"}}}
"  < 判断操作系统是否是 Windows 还是 Linux >  {{{
" -----------------------------------------------------------------------------
let g:isWindows = 0
let g:isLinux = 0
if(has("win32") || has("win64") || has("win95") || has("win16"))
    let g:isWindows = 1
else
    let g:isLinux = 1
endif
"}}}
" < Linux 专用设置 >  {{{
" -----------------------------------------------------------------------------
"
"}}}
" < 编译运行：<leader>e快捷运行---Winows/Linux都行 > {{{
" -----------------------------------------------------------------------------
function! g:CompileRunGcc() abort
    "fucntion('name')把字符串变成函数指针
    let g:leader_e_actions = {
                \ 'c': function('s:RunC'),
                \ 'cpp': function('s:RunCpp'),
                \ 'sh': function('s:RunShell'),
                \ 'python': function('s:RunPython'),
                \ 'vimwiki': function('s:RunVimwiki'),
                \ 'dosbatch': function('s:RunDosBatch'),
                \ }
    " get(list,key,default_value)在list内基于keyname来查找value，如果没找到则使用default_value
    let l:Action = get(g:leader_e_actions, &filetype,function('s:EchoTypeNotCorrect'))

    " 若是vimrc就不做任何事
    if &filetype == 'vim'
        call s:EchoTypeNotCorrect()
        return
    endif

    if exists('g:asyncrun_mode')
        let g:leader_e_run_prefix=":AsyncRun -mode=term -pos=right -col=50 "
    else
        let g:leader_e_run_prefix="! "
    endif

    call l:Action()
endfunction
"}}}


"-------------------以下与gvim和vim无关----------------------------------------
" 目前我的vim个人配置文件
" 一般的映射，都写nore防止递归, 函数则写感叹号function!

" 映射 和 设置
" < Mappings映射(map) > {{{
" -----------------------------------------------------------------------------
" Backspace改为轮换缓冲区
nnoremap <Backspace> :b#<CR>
" jj映射esc
inoremap jj <esc>
" 热键Leader定为'分号'。
let mapleader = ";"
" 设置本地热键 为 "-"
let maplocalleader = "-"
" 设置;a快捷键选中所有内容
nnoremap <Leader>a ggVG
" "B"uffer "D"elete 删除当前缓冲区（而不是仅仅关闭窗口）
nnoremap <leader>bd <esc>:bd<cr>
" 关闭除此缓冲区以外的所有缓冲区
nnoremap <leader>bo :execute "%bd\|e#"<CR>
" checkbox状态切换
nnoremap <leader>cb <Plug>VimwikiToggleListItem
" "C"hange "V"imrc"的首字母,新建tab，打开.vimrc进行编辑
nnoremap <leader>cv :tabnew $MYVIMRC<cr>
" "C"opy 使用 ;c 来对选中的文字进行 赋值到系统粘贴寄存器
vnoremap <leader>c "*y
" "E"xecute 按分号e编译运行代码 (Windows生成exe)
nnoremap <Leader>e :call CompileRunGcc()<CR>
"<leader>m  打开临时文件 main.cpp
nnoremap <leader>m :call OpenTempCpp()<cr>
"分号obj 对源码进行编译，生成目标文件，并且objdump -dS 文件
nnoremap <Leader>obj :call ObjDump()<CR>
function! g:ObjDump() abort
    if &filetype == 'c'
        execute "w"
        execute ":!g++ -g -c % && objdump -dS %:r.o"
    elseif &filetype == 'cpp'
        execute "w"
        execute ":!g++ -std=c++17 -g -c % && objdump -dS %:r.o"
    else
        echom ">_<  Failed,type not correct"
    endif
endfunction
" 使用;p快捷键开启 paste。;;p关闭paste。默认关闭paste模式
set nopaste
nnoremap <Leader>p :set paste<CR>i
nnoremap <Leader><Leader>p :set nopaste<CR>
" 使用;q快捷键退出vim
nnoremap <Leader>q :q<CR>
" 使用;;q强制退出vim
nnoremap <Leader><Leader>q <esc>:q!<CR>
" 窗口切换  
nnoremap <c-h> <c-w>h  
nnoremap <c-l> <c-w>l  
nnoremap <c-j> <c-w>j  
nnoremap <c-k> <c-w>k  
"空格 一次击键选中当前word,两次击键选中WORD。小心：viwc这句话里，不要有任何多余的空格
nnoremap <space> viw
vnoremap <space> vviW
" "S"ource "V"imrc"的首字母，表示重读vimrc配置文件。
nnoremap <leader>sv <esc>:source $MYVIMRC<cr>
"分号sh 进入shell
nnoremap <Leader>sh :call IntoShell()<CR>
function! g:IntoShell() abort
    if &filetype != 'vim'
        execute "w"
    endif
    if exists('g:asyncrun_mode')
        let g:leader_e_run_prefix=":AsyncRun -mode=term -pos=right -col=50 "
        execute g:leader_e_run_prefix."powershell"
    else
        execute "terminal"
    endif
endfunction
"分号tag 生成 并更新tag文件 "有了tag以后，ctrl+] 进入函数定义，ctrl+o 回退。 
"nnoremap <Leader>tag :call Ctag()<CR>
function! g:Ctag() abort
    if &filetype == 'c' || &filetype == 'cpp'
        silent execute ":!ctags -R --c++-kinds=+p+x+d --fields=+liaS --extras=+q --exclude={paralell}" 
    endif
endfunction
" 使用;v快捷键粘贴 `*` 寄存器内容---也就是 Win系统粘贴板
nnoremap <Leader>v "*p 
" 使用;w快捷键保存内容
nnoremap <Leader>w :w<CR>
"H设置为行首，L设置为行尾
nnoremap H ^
nnoremap L $
"两个//搜索选中文本。可 与<space><space>搭配使用。
vnoremap // y/<c-r>"<cr>
" 分割窗口后通过前缀键 "\" 和方向键 调整窗口大小
nnoremap <Leader><Up>    :resize +5<CR>
nnoremap <Leader><Down>  :resize -5<CR>
nnoremap <Leader><Right> :vertical resize +5<CR>
nnoremap <Leader><Left>  :vertical resize -5<CR>

"指定 F2 键来打开Vista或者关闭
nnoremap <silent><F2> :Vista!!<CR>    
" 标签页导航 按键映射。silent 命令（sil[ent][!] {command}）用于安静地执行命令，既不显示正常的消息，也不会把它加进消息历史
nnoremap <Leader>1 1gt
nnoremap <Leader>2 2gt
nnoremap <Leader>3 3gt
nnoremap <Leader>4 4gt
nnoremap <Leader>5 5gt
nnoremap <Leader>6 6gt
nnoremap <Leader>7 7gt
nnoremap <Leader>8 8gt
nnoremap <Leader>9 9gt
"最后一个标签页
nnoremap <Leader>0 :tablast<CR>    
"下一个标签页
nnoremap <silent><Tab>n :tabnext<CR>    
"上一个标签页
nnoremap <silent><s-tab> :tabprevious<CR>    
" }}}
" < Basic Settings基础设置(set) >  {{{
" -----------------------------------------------------------------------------
if(g:isWindows)
    "设置python3的dll路径。可能很多插件依赖它。
    let str = system("python --version")
    let pyVersionId = split(str,'\.')[1]
    if pyVersionId == 9
        set pythonthreedll=python39.dll
    elseif pyVersionId == 10 
        set pythonthreedll=python310.dll
    elseif pyVersionId == 11
        set pythonthreedll=python311.dll
    endif
    " 这是一种 set 选项为变量的方法
    execute 'set pythondll=' . &pythonthreedll


    "另一种方式:依据电脑的主机名特殊设置
    if system("hostname")== "DESKTOP-I5R6VBM\n"
        "教研室电脑
        set pythonthreedll=python311.dll
    elseif system("hostname")== "LAPTOP-QDEH3S4H\n"
        "笔记本电脑
        set pythonthreedll=python39.dll
    endif
endif
"encoding=utf-8 指的是文件翻译成utf-8再呈现在gvim界面。
"encoding=utf-8 也意味着，你做的修改，gvim界面以utf-8的格式流入屏幕
"以fileencoding的格式流入文件
set encoding=utf-8
set nocompatible  "去掉讨厌的有关vi兼容模式，避免以前版本的一些bug和局限
set showcmd    "输入的命令显示出来，看的清楚些"
set showmatch "开启高亮显示匹配括号"
set showmode "显示当前处于哪种模式
set laststatus=2 "显示状态栏
set verbose=0 " 不为0时,将输出调试信息。对于调试 Vim 配置或插件非常有用
set number    "显示行号
set cursorline "突出显示当前行
set ruler      "在状态栏显示光标的当前位置(位于哪一行哪一列)
set autochdir  "自动切换当前目录为当前编辑文件所在的目录(打开多个文件时)
filetype plugin on   "允许载入文件类型插件
filetype indent on   "为特定文件类型载入对应缩进格式
filetype plugin indent on    "打开基于文件类型的插件和缩进
set smartindent  "开启新行时使用智能自动缩进 主要用于 C 语言一族
set hlsearch     "将搜索的关键字高亮处理
set ignorecase   "搜索忽略大小写(不对大小写敏感) 
set incsearch    " 随着键入即时搜索
set smartcase    " 有一个或以上大写字母时仍大小写敏感。如果同时打开了ignorecase，那么对于只有一个大写字母的搜索词，将大小写敏感；其他情况都是大小写不敏感
set confirm     " 在处理未保存或只读文件的时候，弹出确认
set t_Co=256    "设置256色
"去掉输入错误的提示声音和闪屏
set noerrorbells visualbell t_vb=    "其中 t_vb的清空对GUI的vim无效，因为会默认重置。所以开启gvim以后可能仍然闪屏，可以 :set t_vb=
"（’t_vb‘选项，默认是用来让屏幕闪起来的）Starting the GUI (which occurs after vimrc is read) resets ‘t_vb’ to its default value开启GUI是在读入vimrc以后，会把 t_vb设置成闪屏的。
autocmd GUIEnter * set visualbell t_vb=
set wrap    " 自动换行
set history=1000    " 历史记录数
set fileencodings=utf-8,gbk,cp936,gb18030,big5,euc-jp,euc-kr,latin1 "中文编码支持(gbk/cp936/gb18030)---Vim 启动时逐一按顺序使用第一个匹配到的编码方式打开文件
"set encoding=gbk    " Vim 内部 buffer (缓冲区)、菜单文本等使用的编码方式 :告诉Vim 你所用的字符的编码
"禁止生成临时文件
set nobackup    "禁止自动生成 备份文件
set noswapfile    "禁止自动生成 swap文件
set noundofile    "禁止 gvim 在自动生成 undo 文件 *.un~
set tabstop=4    "按下Tab键时,键入的tab字符显示宽度。 统一缩进为4
set shiftwidth=4    "每次>>缩进偏移4个。(自动缩进时，变化的宽度4为单位)
set softtabstop=4 "自动将键入的Tab转化为空格(宽度未达到tabstop)。或者正常输入一个tab(宽度达到tabstop)。对齐tabstop的倍数。
" 设置softtabstop有一个好处是可以用<Backspace>键来一次删除4个空格大小的tab.或者不足4个空格的几个空格。对齐tabstop的倍数。
" softtabstop的值为负数,会使用shiftwidth的值,两者保持一致,方便统一缩进.
set expandtab    "假如是noexpandtab,就是不要将后续键入的制表符tab展开成空格。expandtab 选项把插入的tab字符替换成特定数目的空格。具体空格数目跟 tabstop 选项值有关
"自动补全（字典方式）----使用ctrl+x ctrl+k 进行字典补全
set dictionary+=/usr/share/dict/english.dict
"直接CTRL+n就显示dict其中的列表
set complete-=k complete+=k
set autoread            "打开文件监视。如果在编辑过程中文件发生外部改变（比如被别的编辑器编辑了），就会发出提示。
set timeoutlen=500      "以毫秒计的,等待键码或映射的键序列完成的时间;
set backspace=2         "相当于set backspace=indent,eol,start
"}}}
" < Status Line > {{{
" -----------------------------------------------------------------------------
"set statusline=%F         " 文件的路径
"set statusline+=\ --\      " 分隔符
"set statusline+=FileType: " 标签
"set statusline+=%y        " 文件的类型
"set statusline+=%=        " 切换到右边
"set statusline+=%l        " 当前行
"set statusline+=/         " 分隔符
"set statusline+=%L        " 总行数
" 设置状态行显示常用信息
" %F 完整文件路径名
" %m 当前缓冲被修改标记
" %r 当前缓冲只读标记
" %h 帮助缓冲标记
" %w 预览缓冲标记
" %Y 文件类型
" %b ASCII值
" %B 十六进制值
" %l 行数
" %v 列数
" %p 当前行数占总行数的的百分比
" %L 总行数
" %{...} 评估表达式的值，并用值代替
" %{"[fenc=".(&fenc==""?&enc:&fenc).((exists("+bomb") && &bomb)?"+":"")."]"} 显示文件编码[中间的双引号、空格都需要转义字符。]
set statusline=%F "完整的文件路径名
set statusline+=%m "当前缓冲被修改标记 
set statusline+=%r "当前缓冲只读标记
set statusline+=%h "帮助缓冲标记
set statusline+=%w "预览缓冲标记
set statusline+=%= "切换到右边
set statusline+=\ [filetype=%y] "文件的类型
set statusline+=\ %{\"[fileenc=\".(&fenc==\"\"?&enc:&fenc).((exists(\"+bomb\")\ &&\ &bomb)?\"+\":\"\").\"]\"}
set statusline+=\ [ff=%{&ff}] "fileformat
set statusline+=\ [ASCII=%3.3b=0x%2.2B] "ASCII 的decimal 和 hex
set statusline+=\ [pos=%4l行,%3v列][%p%%] "position
set statusline+=\ [%L\ lines] "total num of lines
" }}}
" < abbreviate缩写替换 > {{{
" -----------------------------------------------------------------------------
"替换内容纠正笔误，如果想取消替换，那么iunabbrev main(即修正后的单词) 
inoreabbrev mian main 
inoreabbrev eixt exit 
inoreabbrev viod void 
inoreabbrev waht what
inoreabbrev tehn then
inoreabbrev tihs this
inoreabbrev cahr char
inoreabbrev pirnt print
inoreabbrev fisrt first
inoreabbrev retuen return
inoreabbrev retrun return
"个人常用信息
inoreabbrev @@ icebggg@qq.com
inoreabbrev @z //@hyf
inoreabbrev z@ //fyh@
inoreabbrev ccopy Copyright 2021 Yufeng Huang, all rights reserved.
"选中当前单词，两边添加双引号
nnoremap <leader>"        ea"<esc>bi"<esc>
nnoremap <localleader>"   Ea"<esc>Bi"<esc>

nnoremap <leader>'        ea'<esc>bi'<esc>
nnoremap <localleader>'   Ea'<esc>Bi'<esc>

nnoremap <leader>]        ea]<esc>bi[<esc>
nnoremap <localleader>]   Ea]<esc>Bi[<esc>

nnoremap <leader>)        ea)<esc>bi(<esc>
nnoremap <localleader>)   Ea)<esc>Bi(<esc>

nnoremap <leader>}        ea}<esc>bi{<esc>
nnoremap <localleader>}   Ea}<esc>Bi{<esc>

nnoremap <leader>`        ea`<esc>bi`<esc>
nnoremap <localleader>`   Ea`<esc>Bi`<esc>
" }}}

" 自动命令组
" < autocmd 命令组 global设置 > {{{
" -----------------------------------------------------------------------------
augroup global__
    autocmd!
    "打开任何类型的文件时，自动缩进。(BufNewFile表示即使这个文件不存在，也创建并保存到硬盘)
    "注释不要写到自动命令后面(尤其是normal关键字后面)。 
    "autocmd BufWritePre,BufRead *.html normal! gg=G 

    "SetTitle()自动插入文件头 
    function! g:SetTitle()                          "定义函数 SetTitle，自动插入文件头
        "如果文件类型为 .sh 文件
        if &filetype == 'sh'
            call setline(1,          "\#########################################################################")
            call append(line("."),   "\# File Name: ".expand("%"))
            call append(line(".")+1, "\# Author: Yufeng Huang <icebggg@qq.com>")
            call append(line(".")+2, "\# Created Time: ".strftime("%c"))
            call append(line(".")+3, "\#########################################################################")
            call append(line(".")+4, "\#! /bin/bash")
            call append(line(".")+5, "")

        elseif &filetype == 'c'
            call setline(1,"#include<stdio.h>")
            call append(line("."), "#include<stdlib.h>")
            call append(line(".")+1, "int main()")
            call append(line(".")+2, "{")
            call append(line(".")+3, "")
            call append(line(".")+4, "    exit(0);")
            call append(line(".")+5, "}")

        elseif &filetype == 'make'
            call setline(1,"CPPFLAGS+=-Wextra -Wall -g")
            call append(line("."), "CFLAGS+=-Wextra -Wall -g")
            call append(line(".")+1, "CXX=g++")
            call append(line(".")+2, "CC=gcc")
            call append(line(".")+3, "%.o: %.c")
            call append(line(".")+4, "    $(CXX) $(CPPFLAGS) $^ -o  $@")
            call append(line(".")+5, "clean:")
            call append(line(".")+6, "    rm  main.exe *.o -rf")

        elseif &filetype == 'python'
            call setline(1,"#!/usr/bin/env python")
            call append(line("."),"# coding=utf-8")
            call append(line(".")+1, "") 

        elseif &filetype == 'java'
            call setline(1,"public class ".expand("%:r"))
            call append(line("."),"")

        elseif &filetype == 'ruby'
            call setline(1,"#!/usr/bin/env ruby")
            call append(line("."),"# encoding: utf-8")
            call append(line(".")+1, "")
        endif
        "如果文件后缀为 .cpp
        if expand("%:e") == 'cpp'
            call setline(1, "#include<iostream>")
            call append(line("."), "using namespace std;")
            call append(line(".")+1, "int main()")
            call append(line(".")+2, "{")
            call append(line(".")+3, "")
            call append(line(".")+4, "    return 0;")
            call append(line(".")+5, "}")
        endif
        "如果文件后缀为 .h 文件
        if expand("%:e") == 'h'
            call setline(1, "#ifndef ".toupper(expand("%:r"))."_H")
            call append(line("."), "#define ".toupper(expand("%:r"))."_H")
            call append(line(".")+1, "#endif")
        endif
    endfunction
    autocmd BufNewFile *.sh,*.java,*.h,*.c,*.cpp,makefile,*.py,*.rb call SetTitle()
    "normal命令中的可选参数 ! 用于指示vim在当前命令中不使用任何vim映射
    autocmd BufNewFile *.c,*.cpp normal! 5gg
    autocmd BufNewFile *.h normal! ggo

    function! s:ReadAllFileType() abort
        "这里面所有的代码，可以在文件完全读入以后生效

        " Vim 重新打开文件时，回到上次历史所编辑文件的位置
        if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif 
    endfunction
    autocmd BufReadPost * call s:ReadAllFileType()
    "call之前，函数体得存在。如果是键位map调用函数的话，倒不介意顺序(不过，需要source一下)。
    "这里是 新建文件之前做的操作
    autocmd BufNewFile * setlocal ff=unix

augroup END
" }}}
" < FileType settings 也就是autocmd命令组的文件类型具体化 > {{{
" -----------------------------------------------------------------------------
augroup c_cpp__
    autocmd!
    function! s:C_CppSettings() abort
        "设置所有的操作都是4个空格为基数对齐。依次为：一个tab的显示宽度, >> 和 == 移动的宽度，键入或者<Backspace>的tab宽度，键入的tab展开为空格。
        setlocal tabstop=4|setlocal shiftwidth=4|setlocal softtabstop=4|setlocal expandtab
        "makeprg参数设置以后，:make将执行这个语句，且可以用:cw打开错误信息、:cn跳转到下一个错误、:cp跳转到上一个
        if(g:isWindows)
            setlocal makeprg=g++\ %\ -Wextra\ -Wall\ -std=c++17\ -g\ -o\ %:r.exe\ 
        else
            setlocal makeprg=g++\ %\ -Wextra\ -Wall\ -std=c++17\ -g\ -o\ %:r\ 
        endif
        setlocal cindent
        "打开c,cpp文件时（前）全部折叠
        setlocal foldlevelstart=0
        "设定 手动折叠的标记
        setlocal foldmethod=marker | setlocal foldmarker=//<,//>
        "c,cpp注释(comment)快捷键：-c
        nnoremap <buffer> <localleader>c I//<space><esc>
        "设置c,c++文件的 帮助程序。(不然Windows默认是:help,Linux默认是man)

        "setlocal keywordprg=:MyKey
        "定义自己的 底线命令
        " command!  -nargs=* MyKey :call MyK(<f-args>)
        " function! MyK(keywd) abort
        "     if exists('g:asyncrun_mode')
        "         let l:cmd=':call HyfEchoFunc("'.a:keywd.'")'
        "         call asyncrun#run('', {}, l:cmd)
        "     endif
        " endfunction

        "弄一弄Linux下tag路径 (仅限C++和C语言)
        setlocal tags+=/usr/include/tags
        if (g:isWindows)
            "弄一弄windows下tag路径 (仅限C++和C语言)
            setlocal tags+=D:/MinGW/mingw64/lib/gcc/x86_64-w64-mingw32/8.1.0/include/tags
            setlocal tags+=D:/MinGW/mingw64/x86_64-w64-mingw32/include/tags
        endif
        "snippets
        inoreabbrev <buffer>        yfc #include<stdio.h><cr>#include<stdlib.h><cr>int main()<cr>{<cr>exit(0);<cr>}<esc>kO<esc>i   
        inoreabbrev <buffer>        yfpp #include<iostream><cr>using namespace std;<cr>int main()<cr>{<cr>return 0;<cr>}<esc>kO<esc>i   
        inoreabbrev <buffer>        ifndef #ifndef<cr>#define<cr>#endif

        inoreabbrev <buffer>        fori for(int i=0;i<m;++i)<cr>{<cr>}<esc>O
        inoreabbrev <buffer>        forj for(int j=0;j<n;++j)<cr>{<cr>}<esc>O

        inoreabbrev <buffer>        whilee while(n--)<cr>{<cr>}<esc>O
        inoreabbrev <buffer>        printt printf("",);<left><left><left>
        inoreabbrev <buffer>        structt struct<cr>{<cr>};<esc>O<esc>i   
        inoreabbrev <buffer>        classs class<cr>{<cr>public:<cr>};<esc>O<esc>i       
        inoreabbrev <buffer>        scann scanf("",);
        inoreabbrev <buffer>        switchh switch(VALUE)<cr>{<cr>case 0:<cr>break;<cr>case 1:<cr>case 2:<cr>break;<cr>default:<cr>break;<cr>}
        inoreabbrev <buffer>        iff if( )<left><left>
        inoreabbrev <buffer>        coutt cout<<<cr><cr><<endl;<esc>ki<tab>   

        inoreabbrev <buffer>        vecvec vector<vector<int>>
        inoreabbrev <buffer>        vec vector<int>
        inoreabbrev <buffer>        dfs dfs(arr,startX,startY,oneAns,ans)
        inoreabbrev <buffer>        bfs m_que.push(pRoot);<cr>while(m_que.empty()==false)<cr>{<cr>int cnt = m_que.size();<cr>for(int i=0;i<cnt;++i)<cr>{<cr>TreeNode * curNode = m_que.front();<cr>m_que.pop();<cr>if( curNode->left )<cr>m_que.push(curNode->left);<cr>if( curNode->right )<cr>m_que.push(curNode->right);<cr>}<cr>}
        inoreabbrev <buffer>        lamda [&](int a,int b)->bool {return a<b;}
        "call OpenTagList()
    endfunction
    autocmd FileType c,cpp call s:C_CppSettings()
augroup END
augroup python__
    autocmd!
    autocmd FileType python inoreabbrev <buffer> iff if:<left>
    autocmd FileType python inoreabbrev <buffer> else else:
    autocmd FileType python inoreabbrev <buffer> fori for i in range(n):
    autocmd FileType python inoreabbrev <buffer> printt print("")<left><left>
    "在编辑python类型的文件时 务必展开所有输入的tab为空格
    autocmd FileType python setlocal tabstop=4|setlocal shiftwidth=4|setlocal softtabstop=4|setlocal expandtab
    "python、shell注释(comment)快捷键：-c
    autocmd FileType python,sh nnoremap <buffer> <localleader>c I#<space><esc>
    "设定 手动折叠的标记
    autocmd FileType python setlocal foldmethod=marker | setlocal foldmarker=#<,#>
augroup END
augroup javascript__
    autocmd!
    autocmd BufReadPre *.js setlocal foldlevelstart=0
    function! s:JsSettings() abort
        inoreabbrev <buffer> iff if()<left>
        "javascript注释(comment)快捷键：-c
        nnoremap <buffer> <localleader>c I//<space><esc>
        "设定 手动折叠的标记
        setlocal foldmethod=marker | setlocal foldmarker=//<,//>
    endfunction
    autocmd FileType javascript call s:JsSettings()
augroup END
augroup html__
  autocmd!
  " autocmd BufReadPost *.html  if filereadable(expand("%:r") . ".vim") | execute 'source ' . expand("%:r") . ".vim" | elseif filereadable("must.vim") | execute "source must.vim" | endif
augroup END
augroup shell_
    autocmd!
    autocmd FileType sh inoreabbrev <buffer> yfsh #! /bin/bash<cr>
    autocmd FileType sh inoreabbrev <buffer> iff if []; then<cr><cr>fi<esc>2kf]i
augroup END
augroup asm__
    autocmd!
    "设定 手动折叠的标记
    autocmd FileType asm setlocal foldmethod=marker | setlocal foldmarker=;<,;>
augroup END

" }}}
" < Vimscript file settings > {{{
" -----------------------------------------------------------------------------
augroup vim__
    autocmd!
    "打开文件时全部折叠
    autocmd BufReadPost .vimrc setlocal foldlevelstart=0 
    autocmd filetype vim call s:VimSettings()
    function! s:VimSettings() abort
        "设置折叠方式为手动标记
        setlocal foldmethod=marker
        "vimrc 注释一行快捷键
        nnoremap <buffer> <localleader>c I"<space><esc>
    endfunction
augroup END
"}}}


" 特殊功能的函数
" < 画图：画一个栈帧的内存模型 > {{{
" -----------------------------------------------------------------------------
function! g:DrawStack()                          "画一个示例  func(string x,string y) {...char aaa=1;char bbb=2;}
    call append(line("."),     "     rbp-0 _____________ ")
    call append(line(".")+1,   "          |             |")
    call append(line(".")+2,   "          |             |")
    call append(line(".")+3,   "          |             |")
    call append(line(".")+4,   "  rbp-0x08|_____________|")
    call append(line(".")+5,   "          |             |")
    call append(line(".")+6,   "          |             |")
    call append(line(".")+7,   "          |             |")
    call append(line(".")+8,   "  rbp-0x10|_____________|")
    call append(line(".")+9,   "          |             |")
    call append(line(".")+10,  "          |             |")
    call append(line(".")+11,  "          |             |")
    call append(line(".")+12,  "  rbp-0x18|_____________|")
    call append(line(".")+13,  "  rbp-0x19|_local aaa:1_|")
    call append(line(".")+14,  "  rbp-0x1a|_local bbb:2_|")
    call append(line(".")+15,  "  rbp-0x1b|_par x(非基type) |")
    call append(line(".")+16,  "  rbp-0x1c|_par y(非基type) |")
endfunction
function! g:DrawStack2()                          "画一个均等大小的,空的格子们
    call append(line("."),     "     rbp-0 _____________ ")
    call append(line(".")+1,   "          |             |")
    call append(line(".")+2,   "          |             |")
    call append(line(".")+3,   "          |             |")
    call append(line(".")+4,   "  rbp-0x08|_____________|")
    call append(line(".")+5,   "          |             |")
    call append(line(".")+6,   "          |             |")
    call append(line(".")+7,   "          |             |")
    call append(line(".")+8,   "  rbp-0x10|_____________|")
    call append(line(".")+9,   "          |             |")
    call append(line(".")+10,  "          |             |")
    call append(line(".")+11,  "          |             |")
    call append(line(".")+12,  "  rbp-0x18|_____________|")
    call append(line(".")+13,  "          |             |")
    call append(line(".")+14,  "          |             |")
    call append(line(".")+15,  "          |             |")
    call append(line(".")+16,  "  rbp-0x20|_____________|")
    call append(line(".")+17,  "          |             |")
    call append(line(".")+18,  "          |             |")
    call append(line(".")+19,  "          |             |")
    call append(line(".")+20,  "  rbp-0x28|_____________|")
endfunction
"}}}
" < 画图：画一个横着排列的矩形表格 > {{{
" -----------------------------------------------------------------------------
function! g:DrawTable()                          "画一个表格
    call append(line("."),     "      _____________ _____________ _____________ _____________ _____________ _____________ ")
    call append(line(".")+1,   "     |             |             |             |             |             |             |")
    call append(line(".")+2,   "     |             |             |             |             |             |             |")
    call append(line(".")+3,   "     |_____________|_____________|_____________|_____________|_____________|_____________|")
    call append(line(".")+4,   "     |             |             |             |             |             |             |")
    call append(line(".")+5,   "     |             |             |             |             |             |             |")
    call append(line(".")+6,   "     |_____________|_____________|_____________|_____________|_____________|_____________|")
    call append(line(".")+7,   "     |             |             |             |             |             |             |")
    call append(line(".")+8,   "     |             |             |             |             |             |             |")
    call append(line(".")+9,   "     |_____________|_____________|_____________|_____________|_____________|_____________|")
endfunction
"}}}
" < 新建cpp文件并且打开编辑：E:\temp\main5683.cpp > {{{
" -----------------------------------------------------------------------------
if (g:isWindows)
    function! g:OpenTempCpp() "加载临时文件 main5683.cpp
        let l:snippet = ["//main.cpp"]  "只在函数内使用的local变量
        let l:filename = "\\temp\\main5683.cpp"
        if bufname("*main5683.cpp") == ""
            "未加载 main5683.cpp这个buffer的时候，才重置且tabnew
            execute " cd C:\\temp"
            let l:snippet += ["#include<iostream>","#include<vector>","#include<string>","#include<algorithm>"]
            let l:snippet += ["using namespace std;"]
            let l:snippet += ["int main()","{","    return 0;","}"]
            call writefile(l:snippet, l:filename)
            execute "tabnew ".l:filename
        else
            echo "main5683.cpp has been opened already!"."(Buffer No: ".bufnr("*main5683.cpp").")."
        endif
    endfunction
endif
"}}}

" 这下面是笔记，或者是教程
" # < vim 基本知识> 
"{{{
"         系统 vimrc 文件: "$VIM\vimrc"
"         用户 vimrc 文件: "$HOME\_vimrc"
"     第二用户 vimrc 文件: "$HOME\vimfiles\vimrc"
"     第三用户 vimrc 文件: "$VIM\_vimrc"
"          用户 exrc 文件: "$HOME\_exrc"
"      第二用户 exrc 文件: "$VIM\_exrc"
"        系统 gvimrc 文件: "$VIM\gvimrc"
"        用户 gvimrc 文件: "$HOME\_gvimrc"
"    第二用户 gvimrc 文件: "$HOME\vimfiles\gvimrc"
"    第三用户 gvimrc 文件: "$VIM\_gvimrc"
"           defaults file: "$VIMRUNTIME\defaults.vim"
"            系统菜单文件: "$VIMRUNTIME\menu.vim"
"
" # <Variable prefixes >
"{{{
" -----------------------------------------------------------------------------
"举例let g:ack_options = '-s -H'    " g: global 全局有效
"举例let s:ack_program = 'ack'      " s: local (to script)  脚本中有效
"举例let l:foo = 'bar'              " l: local (to function) 函数中有效
"   Other prefixes
"       let w:foo = 'bar'    " w: window
"       let b:state = 'on'   " b: buffer
"       let t:state = 'off'  " t: tab
"       echo v:var           " v: vim special
"       let @/ = ''          " @  register (this clears last search pattern)
"       echo $PATH           " $  env环境变量加美元符号做前缀
"   Vim options
"       echo 'tabstop is ' . &tabstop
"       if &insertmode
"       echo &g:option
"       echo &l:option
"       --------------
"       Prefix Vim options with &  选项用&符号做前缀
"}}}
" # <vimdiff 快捷操作 >
"{{{
" -----------------------------------------------------------------------------
"    二、光标移动
"       跳转到下一个差异点：]c    命令前加上数字的话，可以跳过一个或数个差异点比如 2]c
"       反向跳转是：[c
"    三、文件合并
"       dp //意思是"d"iff "p"ut  这个是 从当前复制到另一个
"       do(diff "obtain") //从另一个复制到当前
"}}}
" # <vim中常用折叠命令 za zM zR ...>   https://www.cnblogs.com/litifeng/p/11675547.html
"{{{
" -----------------------------------------------------------------------------
"    za 反复打开关闭折叠：za (意思就是，当光标处折叠处于打开状态，za关闭之，当光标处折叠关闭状态，打开之）
"    :set fdm=marker  在vim中执行该命令
"    5G  将光标跳转到第5行
"    zf10G  折叠第5行到第10行的代码，vim会在折叠的开始和结束自动添加三个连续的花括号作为标记
"    zR 展开全部折叠
"    zM 收起全部折叠
"    zE 删除所有的折叠标签(有点危险，哈哈哈，注意防范弄丢所有{{{和}}}标签)
"    zo  打开open光标下的折叠。
"    zc  收起close光标下的折叠。
"    zO  打开Open光标下的折叠，以及嵌套的折叠。
"    zC  收起Close光标下的折叠，以及嵌套的折叠。
"}}}
" # <终端的vim 配色方案笔记> 
"{{{
" -----------------------------------------------------------------------------
"    lucius.vim     亮 txt
"    molokai.vim    暗
"    herald.vim     暗
"}}}
" # < vim ctags cheatsheet > 
"{{{
" -----------------------------------------------------------------------------
"利用C:\Windows\ctags.exe在当前目录下生成详细tag文件的命令：ctags -R --languages=c++ --langmap=c++:+.inl -h +.inl --c++-kinds=+p+x-d --fields=+liaS --extras=+q
"各个参数的解析，请看这个中文网站：https://www.cnblogs.com/coolworld/p/5602589.html
" 以及这里 有中文帮助: https://blog.easwy.com/archives/exuberant-ctags-chinese-manual/
"
"            Command                    Function
"-----------------------------------------------------------------------------
"            Ctrl + ]                   Go to definition 跳转到定义
"            Ctrl + t                   Jump back from the definition "           直接从定义中走出来。( Ctrl + o 只是回到上次缓冲区位置 )
"            Ctrl + W Ctrl + ]          Open the definition in a horizontal split 水平分屏打开定义
"            :ts <tag_name>             List the [t]ag[s] that match <tag_name> 罗列所有匹配这个名字的tag
"            :tn                        Jump to the  [t]ag [n]ext matching      下一个匹配
"            :tp                        Jump to the  [t]ag [p]revious matching  上一个匹配
"}}}

"}}}
" # < 插件、笔记和一些设置> 
"{{{
"    < 插件plug-vim > {{{
" -----------------------------------------------------------------------------
"Download plug.vim and put it in ~/.vim/autoload
"在windows平台下这个名称是vimfiles，在unix类平台下是~/.vim
"   curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
if(g:isWindows)
    call plug#begin('~/vimfiles/plugged') "这里规定安装目录,中间各行代表获取的插件
else
    call plug#begin('~/.vim/plugged') "这里规定安装目录,中间各行代表获取的插件
endif
"NERDTree "放opt里了Plug 'preservim/nerdtree'
"objdump.vim  将后缀为.objdump的文件进行 语法高亮。 "放opt里了Plug 'HE7086/objdump.vim'
"Python PEP8规范自动格式化插件
Plug 'tell-k/vim-autopep8'
"taglist 用于便捷查看各种tag : 函数名 变量名 宏定义 结构体名 "放opt里了Plug 'yegappan/taglist'
"Vista相当于 高级版taglist 用于便捷查看各种 tag/LSP符号 : 函数名 变量名 宏定义 结构体名
Plug 'liuchengxu/vista.vim'
"ale动态检查语法 "放opt里了Plug 'dense-analysis/ale'
"可以在vim 中 把光标快速移动 到你的可视区域 "放opt里了Plug 'easymotion/vim-easymotion' 
"auto-pairs 括号自动补全
Plug 'jiangmiao/auto-pairs'
let g:AutoPairsMapCR = 0
let g:AutoPairs = {'(':')','[':']', '{':'}',"'":"'",'"':'"'}
"tagbar用来在右侧展示 文件的整体结构视图 "放opt里了Plug 'preservim/tagbar'
"indentLine添加一些分割线 比如你写python的时候 格式对齐 就可以通过这个分割线
Plug 'Yggdroot/indentLine'
let g:indentLine_fileType = ["c","cpp","python","html"]
"vim-commentary 用于多行注释：选中再gc。单行注释：gcgc 或者 gcc。 段落注释：gcap
Plug 'tpope/vim-commentary'
"snippets插件
Plug 'honza/vim-snippets'
"snippets引擎
Plug 'SirVer/ultisnips'

"使用vim的时候快捷翻译
Plug 'voldikss/vim-translator'
let g:translator_default_engines=['haici', 'google'] "不写youdao和bing
"在窗口中回显翻译
nmap <silent> <Leader>t <Plug>TranslateW
vmap <silent> <Leader>t <Plug>TranslateWV
"替换为翻译后的文字Replace the text with translation
nmap <silent> <Leader>r <Plug>TranslateR
vmap <silent> <Leader>r <Plug>TranslateRV
"css的颜色直接渲染在文本上
Plug 'ap/vim-css-color'
"复制（yanked）的文本高亮一下
Plug 'machakann/vim-highlightedyank'
let g:highlightedyank_highlight_duration = 500 "设置为负一的话则是持续高亮"
let g:highlightedyank_highlight_in_visual = 0 "可视模式下不搞这花里胡哨的
" vim-clap 模糊搜索
Plug 'liuchengxu/vim-clap', { 'do': ':Clap install-binary!' }
"-----------------------------
"    用于配合vim-lsp的插件
Plug 'thomasfaingnaert/vim-lsp-ultisnips'

"vim异步执行的插件 (终端执行命令)
Plug 'skywind3000/asyncrun.vim'

"async.vim 封装了两个 Vim Async 相关的接口
Plug 'prabirshrestha/async.vim'
"vim-lsp是一个与 LSP 交互的插件，类似于一个 Vim 的 SDK。只依赖async.vim
Plug 'prabirshrestha/vim-lsp'
"asyncomplete 是利用 async.vim 做的补全引擎
Plug 'prabirshrestha/asyncomplete.vim'
"asyncomplete-lsp 将 lsp 中的内容交给 asyncomplete 做补全。---没有文档
Plug 'prabirshrestha/asyncomplete-lsp.vim'
"----------------------------------------
" 大名鼎鼎的vimwiki
Plug 'vimwiki/vimwiki'
set runtimepath+=~\vimfiles\plugged\vimwiki\
let g:vimwiki_list = [
            \ {'path': '~\vimwiki\my-personal-wiki\', 'css_name': 'style.css'},
            \ {'path': '~\vimwiki\my-thesis\', 'css_name': 'style.css'},
            \ {'path': '~\vimwiki\cpp-programming-style-guidelines\', 'css_name': 'style.css'},
            \ {'path': '~\vimwiki\cpp-annotation\', 'css_name': 'style.css'}
            \ ]
autocmd FileType vimwiki setlocal shiftwidth=4 tabstop=4 noexpandtab
" codeium 代码智能提示，Copilot 替代品
"Plug 'Exafunction/codeium.vim'

" 设置开启codeium的文件类型,未写进去的默认关闭
 let g:codeium_filetypes = {
    \ "vim": v:false,
    \ "bash": v:false,
    \ "typescript": v:true,
    \ "cpp": v:true,
    \ }

" 启动的时候 提供的一些辅助功能，比如显示最近打开文件,以及一个好看的图标。
Plug 'mhinz/vim-startify'

" 您正在编辑的文件是否受版本控制？Signify 只显示对版本控制文件的更改。显示实时diff
if has('nvim') || has('patch-8.0.902')
  Plug 'mhinz/vim-signify'
else
  Plug 'mhinz/vim-signify', { 'tag': 'legacy' }
endif

" default updatetime 4000ms is not good for async update
set updatetime=100

call plug#end()

"----------------------------------------
"状态 :PlugStatus 检查现在 plug 负责的插件状态
"安装 :PlugInstall 将写入vimrc配置的插件进行安装
"更新 :PlugUpdate 更新已安装的插件
"清理 :PlugClean 清理插件，需要先在 .vimrc 里面删除或注释掉
"升级 :PlugUpgrade 升级plug.vim自身
nnoremap <F5> :call PlugUpdate()<CR>
function! g:PlugUpdate()
    execute "PlugUpdate"
endfunction
"}}}
"    < 插件 在taglist窗口中，可以使用下面的快捷键> "{{{
" -----------------------------------------------------------------------------
"    <CR>           跳到光标下tag所定义的位置，用鼠标双击此tag功能也一样
"    o              在一个新打开的窗口中显示光标下tag
"    p              预览tag的定义:光标仍留在当前位置')
"    <Space>        显示光标下tag的原型定义
"    u              更新taglist窗口中的tag
"    s              更改排序方式，在按名字排序和按出现顺序排序间切换
"    x              taglist窗口放大和缩小，方便查看较长的tag
"    +              打开一个折叠，同zo
"    -              将tag折叠起来，同zc
"    *              打开所有的折叠，同zR
"    =              将所有tag折叠起来，同zM
"    [[             跳到前一个文件
"    ]]             跳到后一个文件
"    q              关闭taglist窗口
"    <F1>           显示帮助 

"let Tlist_Use_Right_Window = 1         "在右侧窗口中显示taglist窗口 
"let g:Tlist_Auto_Open = 1               "vim启动时 自动打开Taglist
let Tlist_File_Fold_Auto_Close = 1      "当同时显示多个文件中的tag时，可使taglist只显示当前正在编辑的文件tag，其它文件的tag都被折叠起来
let Tlist_Exit_OnlyWindow = 1           "如果 taglist 窗口是最后一个窗口，则退出 vim

"这个函数就是打开Taglist。
function! g:OpenTagList() abort
    "窗口号
    let l:winNum = bufwinnr('__Tag_List__')
    if l:winNum == -1  "为负一说明未打开__Tag_List__
        execute 'Tlist'
        "打开TagList窗口
        "call taglist#Tlist_Window_Open()
    else
        return
    endif
    "call s:Execute_Cmd_WithNo_Autocmds(targert_winnr.'wincmd w')
endfunction

" Execute the specified Ex command after disabling autocommands
function! s:Execute_Cmd_WithNo_Autocmds(cmd) abort
    let old_eventignore = &eventignore
    "暂时禁止所有自动命令
    silent set eventignore = all
    execute a:cmd
    "还原自动命令的许可设置
    let &eventignore = old_eventignore
endfunction
"}}}
"    < 插件 在tagbar使用下面的设置> "{{{
" -----------------------------------------------------------------------------
let g:tagbar_width=35
let g:tagbar_left=1
let g:tagbar_autofocus=1
if isWindows
    let g:tagbar_ctags_bin='E:\ExcutableFiles\ctags.exe'
endif
nnoremap <F1> :TagbarToggle<cr>
"}}}
"    < 插件vim-cpp-enhanced-highlight >   :给cpp语法上色 "{{{
" -----------------------------------------------------------------------------
let g:cpp_class_scope_highlight = 1 "类作用域的突出显示
let g:cpp_member_variable_highlight = 1 "类的成员变量的突出显示
let g:cpp_concepts_highlight = 1  "标准库的关键字 高亮
"}}}
"    < 插件NERDTree > "{{{
" -----------------------------------------------------------------------------
"    o       在已有窗口中打开文件、目录或书签，并跳到该窗口
"    go      在已有窗口 中打开文件、目录或书签，但不跳到该窗口
"    t       在新 Tab 中打开选中文件/书签，并跳到新 Tab
"    T       在新 Tab 中打开选中文件/书签，但不跳到新 Tab
"    i       split 一个新窗口打开选中文件，并跳到该窗口
"    gi      split 一个新窗口打开选中文件，但不跳到该窗口
"    s       vsplit 一个新窗口打开选中文件，并跳到该窗口
"    gs      vsplit 一个新 窗口打开选中文件，但不跳到该窗口
"    !       执行当前文件
"    O       递归打开选中 结点下的所有目录
"    x       合拢选中结点的父目录
"    X       递归 合拢选中结点下的所有目录
"    e       explore selected dir
let NERDTreeShowHidden=1 "NERDTree资源管理器窗口中 显示隐藏文件。
"}}}
"    < 插件dense-analysis/ale >"{{{
" -----------------------------------------------------------------------------
let g:ale_enabled = 0  "设置全局是否启用ale
"let b:ale_enabled = 0  "设置当前buffer不启用ale
let g:ale_completion_delay = 500
let g:ale_echo_delay = 20
let g:ale_lint_delay = 500
"字典中未指定的所有语言，将为这些语言运行所有可能的 linter
"指定特定语言的linters
let g:ale_linters = {
            \   'c':['cppcheck'],
            \   'cpp':['cppcheck'],
            \}
let g:ale_cpp_cc_executable = 'g++'
"     ALE will try to use `clang++` if Clang++ is available, otherwise ALE will default to checking C++ code with `gcc`.
let g:ale_c_cc_executable = 'gcc'
"     ALE will try to use `clang` if Clang is available, otherwise ALE will default to checking C code with `gcc`.
"允许自定义回显消息
let g:ale_echo_msg_format = '[%linter%]%  code:% %s'  
"       %s is the error message itself
"       %...code...% is an optional error code, and most characters can be written between the characters.%
"       %linter% is the linter name
"       %severity% is the severity type
"默认是实时检测代码，那样可能比较占用CPU
"如果希望只在保存文件时才运行，可以设置...on_text_changed为'never'，还有...on_insert_leave为0
let g:ale_lint_on_insert_leave = 0          "离开insert模式时 运行linter
let g:ale_lint_on_text_changed = 'never'  
"let g:ale_lint_on_text_changed = 'normal'  "normal模式下文字改变时 运行linter
let g:ale_lint_on_enter = 0  "if you don't want linters to run on opening a file

"有错误和警告时 打开quickfix窗口
let g:ale_set_quickfix = 1
let g:ale_open_list = 1

let g:ale_sign_error = '>>'
let g:ale_sign_warning = '--'

"如果不希望 ALE 运行任何内容, 只运行您明确要求的内容，则可以设置为1
let g:ale_linters_explicit = 1  
"     When set to `1`, only the linters from |g:ale_linters| and |b:ale_linters|
"     will be enabled. The default behavior for ALE is to enable as many linters
"     as possible, unless otherwise specified.

let g:airline#extensions#ale#enabled = 0
" cc 这个linter，可能是clang++ 也可能是 gcc
let g:ale_c_cc_options = '-Wall -O2 -std=c11'
let g:ale_cpp_cc_options = '-Wall -O2 -std=c++17 -D _CRT_SECURE_NO_WARNINGS'
let g:ale_c_cppcheck_options = ''
let g:ale_cpp_cppcheck_options = ''
" Show 7 lines of errors (default: 10) 配置错误显示行数
let g:ale_list_window_size = 7
"快捷键 跳转
nmap <silent> <Leader>cn <Plug>(ale_previous_wrap)
nmap <silent> <Leader>cp <Plug>(ale_next_wrap)
"警告：cc1plus.exe|1 warning| [cc]  is shorter than expected
"正确处理：set ff=unix
"或者 <leader>sv一下，再保存。
"}}}
"    < ---插件 OmniCppComplete 设置 >"{{{
" -----------------------------------------------------------------------------
let OmniCpp_NamespaceSearch = 1
" 0 : 禁止查找命名空间
" 1 : 查找当前文件缓冲区内的命名空间(缺省)
" 2 : 查找当前文件缓冲区和包含文件中的命名空间
"如果下拉菜单弹出，回车映射为接受当前所选项目，否则，仍映射为回车
let OmniCpp_GlobalScopeSearch = 1
let OmniCpp_ShowAccess = 1       "显示访问控制信息(公开是'+',私有是'-',保护是'#')
let OmniCpp_ShowPrototypeInAbbr = 1 "显示函数参数列表
let OmniCpp_MayCompleteDot = 1   " 输入 .  后自动补全
let OmniCpp_MayCompleteArrow = 1 " 输入 -> 后自动补全
let OmniCpp_MayCompleteScope = 1 " 输入 :: 后自动补全
let OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD"] "默认命名空间列表
"自动关闭补全窗口
au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
set completeopt=menuone,menu,longest
"设置弹出菜单高亮颜色: 普通项目
highlight Pmenu  guibg=#343434  guifg=Grey
"{from-group} {to-group}
"设置弹出菜单高亮颜色: 选中的项目
highlight PmenuSel guibg=lightgreen guifg=black 
"}}}

"    < ---插件 clang_complete 设置 >"{{{
" -----------------------------------------------------------------------------
let g:clang_complete_loaded= 0
"设定clang库路径
let g:clang_library_path='D:\Program Files\LLVM\bin'
"在->. ., ::后自动补全
let g:clang_auto_select = 1
"插入第一个补全后关闭预览窗口
"let g:clang_close_preview = 1
"-std=c++17 开启对C++17的编译支持, -xc++ 把所有文件全视为c++类型
let g:clang_user_options = '-Wall -std=c++17 -D_CRT_SECURE_NO_WARNINGS --target=x86_64-w64--windows-gnu'
"    如果没有 设置target, 那么默认是 x86_64-pc-windows-msvc，会插入和链接MSVC的头文件和库文件
"补全预处理指令，宏和常数，默认为不补全
let g:clang_complete_macros = 1
"补全代码模式，比如循环等，默认为不补全
let g:clang_complete_patterns = 1
"<C-]>跳转到声明,好像lsp的更快,这个慢一点。
"   let g:clang_jumpto_declaration_key = "<C-]>"
"<C-w>]在预览窗口中打开声明
let g:clang_jumpto_declaration_in_preview_key = "<C-w>]"
"<C-t>回跳
let g:clang_jumpto_back_key = "<C-t>"
"使用UltiSnips进行代码片段补全
let g:clang_snippets = 1
let g:clang_snippets_engine = 'ultisnips'
"}}}

"    < 插件 asyncomplete 设置 >"{{{
" -----------------------------------------------------------------------------
"Automatically show the autocomplete popup menu as you start typing
let g:asyncomplete_auto_popup = 1
"    判断补全窗口有没有打开，有打开的话就将tab键映射为补全选择键 <C-n>。
"    如果是没有补全窗口，那么就不映射下面三个键盘。
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr> pumvisible() ? "\<C-y>\<cr>" : "\<cr>"
"允许预览窗口
let g:asyncomplete_auto_completeopt = 0
set completeopt=menuone,noinsert,noselect,preview
"一旦补全完成，自动关闭preview window
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif
"}}}

"    < 插件 vim-lsp 设置 >"{{{
" -----------------------------------------------------------------------------
" call lsp#enable()
" call lsp#disable()
"虚文本的领头标记
let g:lsp_diagnostics_virtual_text_prefix = " ‣ "
"语法诊断 自动开启选项
let g:lsp_diagnostics_enabled = 1
"教研室电脑先不开启这个 lsp语法错误着色的功能
if system("hostname")== "DESKTOP-I5R6VBM\n"
    let g:lsp_diagnostics_enabled = 0
endif
"允许echo 光标下的语法诊断错误
if g:lsp_diagnostics_enabled == 1
    "消息行 显示错误
    let g:lsp_diagnostics_echo_cursor = 1
    "浮窗显示错误
    let g:lsp_diagnostics_float_cursor = 0
    "possible to set custom text or icon that will be used for sign
    let g:lsp_document_code_action_signs_enabled = 0

    "标记错误和警告。尽管ale里也会显示标记(但是我设置了只有保存的时候才语法检查)，而vim-lsp里的是实时的
    let g:lsp_diagnostics_signs_enabled = 1
    "    错误标记符号
    let g:lsp_diagnostics_signs_error = {'text': 'er'}
    "    警告标记符号
    let g:lsp_diagnostics_signs_warning = {'text': 'wa'}
    "    建议标记符号
    let g:lsp_diagnostics_signs_hint = {'text': 'ad'}
endif
"(嵌入) 详细的代码提示信息,默认绿底红字。（主要是函数参数提示）
"需要版本Vim 9.0以上
let g:lsp_inlay_hints_enabled = 1

"注册Python的LSP  (具体的Wiki见：https://github.com/prabirshrestha/vim-lsp/wiki/)
if executable('pyls')
    "需要提前 pip install python-language-server 注意将pyls.exe的路径加入PATH环境变量(找不到可以用everything找目录)
    autocmd User lsp_setup call lsp#register_server({
                \ 'name': 'pyls',
                \ 'cmd': {server_info->['pyls']},
                \ 'allowlist': ['python'],
                \ 'blocklist': [],
                \ })
endif
" 黑名单（blacklist）和白名单（whitelist）这些单词存在一些潜在的种族主义或歧视性的问题,所以换成了
" 换成其他语言的话，只要将 cmd 换成 LSP 的启动命令，然后通过 allowlist 或者 blocklist 设置生效的文件类型就好了。

"注册 JavaScript 的 LSP
"需要提前安装Node.js
"然后命令行执行npm install -g typescript typescript-language-server
if executable('typescript-language-server')
    autocmd User lsp_setup call lsp#register_server({
                \ 'name': 'javascript support using typescript-language-server',
                \ 'cmd': { server_info->[&shell, &shellcmdflag, 'typescript-language-server --stdio']},
                \ 'root_uri': { server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_directory(lsp#utils#get_buffer_path(), '.git/..'))},
                \ 'allowlist': ['javascript', 'javascript.jsx', 'javascriptreact'],
                \ 'blocklist': [],
                \ })
endif

" 注册Vim的LSP server
" npm install -g vim-language-server
if executable('vim-language-server')
    augroup LspVim
        autocmd!
        autocmd User lsp_setup call lsp#register_server({
                    \ 'name': 'vim-language-server',
                    \ 'cmd': {server_info->['vim-language-server', '--stdio']},
                    \ 'allowlist': [],
                    \ 'blocklist': ['help'],
                    \ 'initialization_options': {
                    \   'vimruntime': $VIMRUNTIME,
                    \   'runtimepath': &rtp,
                    \ }})
    augroup END
endif

" 注册HTML的LSP server
" npm install --global vscode-html-languageserver-bin
if executable('html-languageserver')
    au User lsp_setup call lsp#register_server({
                \ 'name': 'html-languageserver',
                \ 'cmd': {server_info->[&shell, &shellcmdflag, 'html-languageserver --stdio']},
                \ 'allowlist': ['html'],
                \ 'blocklist': []
                \ })
endif

"注册C/CPP的LSP， 这里使用的是Windows的clangd
"全局设置clang的编译器选项请看 https://clangd.llvm.org/config#compileflags。
"配置文件在 %LocalAppData%\clangd\config.yaml
"let s:gcc_path='D:\MinGW\mingw64\bin\g++.exe'
            "\       '--query-driver='.s:gcc_path,
if executable('clangd')
    autocmd User lsp_setup call lsp#register_server({
                \ 'name': 'clangd',
                \ 'cmd': {server_info->  
                \       [
                \       'clangd',
                \       '--all-scopes-completion',
                \       '--completion-style=detailed',
                \       '--header-insertion=iwyu',
                \       '--log=verbose',
                \       '--pretty',
                \       '--cross-file-rename',
                \       '--header-insertion-decorators',
                \       '-j=2',
                \       '--function-arg-placeholders=false',
                \       ]
                \ },
                \ 'allowlist': ['c','cpp'],
                \ 'blocklist': [],
                \ })
endif
"clangd的配置参数
if 0
    "让 Clangd 生成更详细的日志
                \'--log=verbose'
    "输出的 JSON 文件更美观
                \'--pretty'
    "全局补全(输入时弹出的建议将会提供 CMakeLists.txt "里配置的所有文件中可能的符号，会自动补充头文件) --- 当前文本中生效的所有作用域吧
                \'--all-scopes-completion'
    "建议风格：打包(重载函数只会给出一个建议）
    "相反可以设置为detailed
                \'--completion-style=bundled'
    "跨文件重命名变量
                \'--cross-file-rename'
    "允许补充头文件
                \'--header-insertion=iwyu'
    "输入建议中，已包含头文件的项与还未包含头文件的项会以圆点加以区分
                \'--header-insertion-decorators'
    "在后台自动分析文件(基于 complie_commands，我们用CMake生成)
                \'--background-index'
    "启用 Clang-Tidy 以提供「静态检查」
                \'--clang-tidy'
    "Clang-Tidy 静态检查的参数，指出按照哪些规则进行静态检查，详情见「与按照官方文档配置好的 VSCode 相比拥有的优势」
    "参数后部分的*表示通配符
    "在参数前加入-，如-modernize-use-trailing-return-type，将会禁用某一规则
                \'--clang-tidy-checks=cppcoreguidelines-*,performance-*,bugprone-*,portability-*,modernize-*,google-*'
    "默认格式化风格: 谷歌开源项目代码指南
    "'--fallback-style=file'
    "同时开启的任务数量
                \'-j=2'
    "pch优化的位置(memory 或 disk，选择memory会增加内存开销，但会提升性能) 推荐在板子上使用disk
                \'--pch-storage=disk'
    "启用这项时，补全函数时，将会给参数提供占位符，键入后按 Tab 可以切换到下一占位符，乃至函数末
    "我选择禁用
                \'--function-arg-placeholders=false'
    "compelie_commands.json 文件的目录位置(相对于工作区，由于 CMake 生成的该文件默认在 build 文件夹中，故设置为 build)
                \'--compile-commands-dir=build'
endif
"
function! s:on_lsp_buffer_enabled() abort
    "使用vim-lsp插件的补全功能，vim-lsp会有接口提供给 asyncomplete.vim插件配合使用。
    "For additional configuration refer to asyncomplete.vim docs.
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    "if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
    "前去定义处 go definition
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> <c-]> <plug>(lsp-definition)
    " ctr+. 快速展示 修复建议的列表。被输入法快捷键占用
    nmap <buffer> <c-.> <plug>(lsp-code-action)
    "模糊搜索当前文本中的有效符号 go symbol
    nmap <buffer> gs <plug>(lsp-document-symbol-search)
    "模糊搜索本程序能访问的工作区(包含头文件啊，头文件中的头文件啊)中的有效符号
    nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
    "引用了几处，在窗口中展示, 方便快速跳转 go reference
    nmap <buffer> gr <plug>(lsp-references)
    "同一符号批量重命名, 巨有用(不会影响 不同语义不同域的同名符号)。
    nmap <buffer> <leader>rn <plug>(lsp-rename)

    "上一个错误处
    nmap <buffer> [g <plug>(lsp-previous-diagnostic)
    "下一个错误处
    nmap <buffer> ]g <plug>(lsp-next-diagnostic)
    "    nmap <buffer> gi <plug>(lsp-implementation)
    "    nmap <buffer> gt <plug>(lsp-type-definition)
    "K 召唤浮窗, 显示函数说明/或者变量原型/函数原型
    nmap <buffer> K <plug>(lsp-hover)
    "浮窗中的翻页 往后4行
    nnoremap <buffer> <expr><c-f> lsp#scroll(+4)
    "浮窗中的翻页 往前4行
    nnoremap <buffer> <expr><c-b> lsp#scroll(-4)

    let g:lsp_format_sync_timeout = 1000
    "保存*.rs 和 *.go 之前把文档 进行格式调整(可能会让vim 变慢)，于是设置1秒钟时限
    autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
    " refer to doc to add more commands
endfunction

augroup lsp_install
    autocmd!
    " 只在注册过server的语言中启用 call s:on_lsp_buffer_enabled()
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

"}}}

"    < 插件 UltiSnips >"{{{
" -----------------------------------------------------------------------------
" snippet for "for loop" b
" for (int ${1:i} = $2; $1 < $3; $1++){
"     $4
" }
" endsnippet
"------------
" snippet 触发字符 ["代码片段说明" [参数]]
" 代码片段内容
" endsnippet
" 设定的选项有介绍以下几种：
"       b 这个关键词只有出现在行首的时候，才能被展开。
"       A 代表自动展开,不需要按 tab，类似于 VIM 中的 abbr
"       i 表示触发字符可以在单词内（连续展开会使用这个选项）
"       $1, $2, $3代表了不同的变量，按照变量顺序，我们可以实现在变量之间的自动跳转。$0代表最后一个变量。
"           <c-j> 向后跳转， <c-k> 向前跳转。
" 添加自定的代码仓库目录 ~/.vimfiles/hyf-snippets/
let UltiSnipsSnippetDirectories = ["UltiSnips","hyf-snippets"]
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"
"}}}

"}}}

" # <localleader>映射已经使用的快捷键说明
"{{{ " -----------------------------------------------------------------------------
"    + c                                                "C"omment 注释
"}}}

" # <Leader>映射已经使用的快捷键说明(a-z) 
"{{{
" -----------------------------------------------------------------------------
"    + 1 2 3 4 5 6 7 8 9 0              访问第几个tab标签页
"    + a                                "A"ll selected
"    + bd                               "B"uffer "D"elete
"    + bo                               "B"uffer "O"nly 
"    + cb                               "C"heck "B"ox
"    + cv                               "C"hange "V"imrc
"    + 
"    + e                                "E"xecute (编译执行) 函数
"    +
"    +
"    +
"    +
"    +
"    +
"    +
"    + m                                "M"ain程序，临时文件,固定在E:\Temp\main.cpp。
"    +
"    +
"    + 
"    +
"    +
"    +
"    + obj                              "Obj"Dump
"    + p                                "P"aste mode
"    + <leader>p                        no "P"aste mode
"    + q                                "Q"uit vim
"    + <leader>q                        force "Q"uit
"    + r                                "R"eplace translation
"    +
"    + sh                               "Sh"ell 函数
"    + sv                               "S"oure "V"imrc
"    + t                                "T"ranslation
"    + tag(弃)                          "Ctag" 函数
"    +
"    + v                                以 ;v 完成类似Ctrl+ "V" 的粘贴操作
"    + w                                "W"rite
"    + <up>                             竖直方向增大窗口
"    + <down>                                            
"    + <left>                                        
"    + <right>                          水平方向增大窗口
"}}}

"   highlight link 配色组汇总
"{{{
" -----------------------------------------------------------------------------
"文本中的 引用高亮
highlight lspReference ctermfg=red guifg=#000000 ctermbg=green guibg=Grey
"文本中的错误高亮，不是左侧边栏的
highlight link LspErrorHighlight Error
highlight link LspErrorVirtualText Error
"文本中的警告高亮，不是左侧边栏的
highlight link LspWarningHighlight TODO
highlight link LspWarningVirtualText TODO
"文本中的inlay提示（函数参数）
highlight lspInlayHintsParameter ctermfg=red guifg=#666666
            \ ctermbg=green guibg=Black
"文本中的inlay提示（类型）
highlight lspInlayHintsType ctermfg=red guifg=#006666
            \ ctermbg=green guibg=Black
"}}}
"
augroup reload_vimrc_once
    autocmd!  

    "autocmd!这一句将会清除之前的 事件和响应动作
    "保存vimrc文件之时，先把文件拷贝覆盖一份给my-vimrc-file目录， 执行vim脚本
    autocmd BufWritePost $MYVIMRC source $MYVIMRC
    "只能这样写(source vimrc命令必须放进一个依赖保存事件触发的自动命令，不然就无穷递归了)
augroup END
