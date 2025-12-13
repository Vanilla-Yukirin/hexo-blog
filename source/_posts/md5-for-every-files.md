---
title: 为文件一键命名为其md5值
mathjax: false
date: 2024-01-18 16:48:32
tags: Script
description: 不知道怎么给文件命名？一键命名为其md5不就是了！
---

# 为文件一键命名为其md5值

不知道怎么给文件命名？一键命名为其md5不就是了！

## 单文件拖拽版

无需启动，直接将文件拖拽到`.bat`文件上

```cmd
@echo off
setlocal enabledelayedexpansion

:: 获取文件完整路径
set "file_path=%~1"

:: 检查文件是否存在
if not exist "!file_path!" (
    echo File not found: !file_path!
    exit /b 1
)

:: 使用CertUtil计算MD5
for /f "delims=" %%a in ('certutil -hashfile "!file_path!" MD5 ^| find /v ":" ^| find /v "CertUtil"') do (
    set "file_md5=%%a"
)

:: 替换MD5字符串中的空格
set "file_md5=!file_md5: =!"

:: 获取文件目录、文件名和扩展名
for %%i in ("!file_path!") do (
    set "file_dir=%%~dpi"
    set "file_name=%%~ni"
    set "file_ext=%%~xi"
)

:: 重命名文件
set "new_file_path=!file_dir!!file_md5!!file_ext!"
echo Renaming "!file_path!" to "!new_file_path!"
rename "!file_path!" "!file_md5!!file_ext!"

:: 结束
endlocal
```

## 多文件拖拽版

可能一次需要处理多个文件吧。那么将它们全选中，一并拖拽即可

```cmd
@echo off
setlocal enabledelayedexpansion

:: 遍历所有提供的文件路径
:next
if "%~1"=="" goto end
set "file_path=%~1"

:: 检查文件是否存在
if not exist "!file_path!" (
    echo File not found: !file_path!
    goto shiftArgs
)

:: 使用CertUtil计算MD5
for /f "delims=" %%a in ('certutil -hashfile "!file_path!" MD5 ^| find /v ":" ^| find /v "CertUtil"') do (
    set "file_md5=%%a"
)

:: 替换MD5字符串中的空格
set "file_md5=!file_md5: =!"

:: 获取文件目录、文件名和扩展名
for %%i in ("!file_path!") do (
    set "file_dir=%%~dpi"
    set "file_name=%%~ni"
    set "file_ext=%%~xi"
)

:: 重命名文件
set "new_file_path=!file_dir!!file_md5!!file_ext!"
echo Renaming "!file_path!" to "!new_file_path!"
rename "!file_path!" "!file_md5!!file_ext!"

:: 移动到下一个参数
:shiftArgs
shift
goto next

:: 结束
:end
endlocal

```

## Attention

请注意，在实际使用之前在安全的环境中测试此脚本，以确保它满足你的要求并且没有意外的行为。
