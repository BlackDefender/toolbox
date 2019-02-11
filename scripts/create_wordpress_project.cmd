@echo off

REM Ставим кодировку UTF-8
CHCP 65001

REM Получаем название проекта
SET /p projectName="Название проекта: "
SET /p themeName="Название темы (по умолчанию равно названию проекта): "
IF "%themeName%"=="" (
	SET themeName=%projectName%
)

SET /p multiLanguageSupport="Включить поддержку многоязычности? (y/n): "

ECHO Скачиваем и распаковываем WordPress
REM Скачиваем WordPress
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest https://wordpress.org/latest.zip -OutFile wordpress.zip"

REM Распаковываем WordPress
CALL :UNZIP wordpress

REM переименовываем папку с вордпрессом в название проекта
RENAME wordpress %projectName%

REM Удаляем архив WordPress
DEL wordpress.zip

REM Переходим в папку с проектом
CD %projectName%

ECHO Создаем .gitignore
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest https://github.com/BlackDefender/toolbox/raw/master/.gitignore -OutFile .gitignore"
CALL :CONVERT_LINE_ENDINGS_TO_WINDOWS_STYLE .gitignore

ECHO Создаем robots.txt
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest https://github.com/BlackDefender/toolbox/raw/master/robots.txt -OutFile robots.txt"
CALL :CONVERT_LINE_ENDINGS_TO_WINDOWS_STYLE robots.txt

REM Удаляем стандартные темы
ECHO Удаляем стандартные темы
FOR /d %%x IN (wp-content\themes\*) DO @rd /s /q "%%x"

REM Переходим в каталог с темами
CD wp-content\themes

ECHO Устанавливаем пустую тему
REM Скачиваем заготовку пустой темы
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest https://github.com/BlackDefender/empty_wordperss_template/archive/master.zip -OutFile empty_wordperss_template.zip"

REM Распаковываем ее
CALL :UNZIP empty_wordperss_template

REM Переименовываем пустую тему
RENAME empty_wordperss_template-master %themeName%

REM Удаляем архив с пустой темой
DEL empty_wordperss_template.zip

CD %themeName%

REM Подкорректируем манифест
powershell -Command "(Get-Content -Path 'manifest.json' -ReadCount 0) -replace 'THEME_NAME', '"%themeName%"' | Set-Content -Path 'manifest.json'"

REM Запишем название темы в комменты файла стилей. Это название будет отображаться в админке
powershell -Command "(Get-Content -Path 'style.css' -ReadCount 0) -replace 'THEME_NAME', '"%themeName%"' | Set-Content -Path 'style.css'"


ECHO Ствим плагины:
REM Идем в плагины
CD ..\..\plugins
REM Удалим плагин Hello Dolly.
DEL hello.php

FOR %%P IN (disable-emojis,wordpress-seo,cyrlitera,kama-thumbnail,w3-total-cache,svg-support,better-wp-security) DO (
	ECHO %%P
	CALL :DOWNLOAD_PLUGIN %%P
	CALL :UNZIP %%P
	DEL %%P.zip
)

REM Если нужна поддержка многязычности ставми Polylang
IF /I "%multiLanguageSupport%" == "y" (
    ECHO polylang
    CALL :DOWNLOAD_PLUGIN polylang
    CALL :UNZIP polylang
	DEL polylang.zip
    
    ECHO polylang-slug
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;  Invoke-WebRequest https://github.com/grappler/polylang-slug/archive/master.zip -OutFile polylang-slug.zip"
    CALL :UNZIP polylang-slug
    RENAME polylang-slug-master polylang-slug
    DEL polylang-slug.zip
)



REM Сигнализируем о завершении
ECHO.
ECHO - Шеф, готово!
ECHO - Что готово?
ECHO - ПОЛОМАЛ!
ECHO.
PAUSE
EXIT /B 0


:DOWNLOAD_PLUGIN
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest https://downloads.wordpress.org/plugin/%1.latest-stable.zip -OutFile %1.zip"
EXIT /B


:UNZIP
powershell -Command "Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('%1.zip', '"%cd%"')"
EXIT /B

:CONVERT_LINE_ENDINGS_TO_WINDOWS_STYLE
powershell -Command "(Get-Content -Path '%1' -ReadCount 0) -replace '\r', '\n\r' | Set-Content -Path '%1'"
EXIT /B