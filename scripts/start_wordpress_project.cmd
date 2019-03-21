@echo off

REM Ставим кодировку UTF-8
CHCP 65001

powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest https://github.com/BlackDefender/toolbox/raw/master/scripts/create_wordpress_project.cmd -OutFile create_wordpress_project.cmd"
CALL create_wordpress_project.cmd
DEL create_wordpress_project.cmd

PAUSE
EXIT /B 0