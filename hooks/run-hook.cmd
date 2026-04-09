:; # ── 多语言脚本：Windows batch + bash 混合 ──
:; # bash 会忽略以 :; 开头的行，Windows 会忽略 bash 部分
:; exec bash "$0" "$@"
:; exit

@echo off
setlocal

rem ── Windows 部分：查找 bash 并执行对应的 hook 脚本 ──

set "HOOK_NAME=%~1"
if "%HOOK_NAME%"=="" (
    exit /b 0
)

set "SCRIPT_DIR=%~dp0"

rem 尝试 Git for Windows 自带的 bash
if exist "C:\Program Files\Git\bin\bash.exe" (
    "C:\Program Files\Git\bin\bash.exe" "%SCRIPT_DIR%%HOOK_NAME%" %*
    exit /b %ERRORLEVEL%
)

rem 回退到 PATH 中的 bash
where bash >nul 2>&1
if %ERRORLEVEL% equ 0 (
    bash "%SCRIPT_DIR%%HOOK_NAME%" %*
    exit /b %ERRORLEVEL%
)

rem 找不到 bash，静默退出
exit /b 0
