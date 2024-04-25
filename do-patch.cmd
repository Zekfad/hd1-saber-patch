@echo off
setlocal
set tool=tools\hd-tool.exe
set compiler=%cd%\tools\luajit\luajit.exe
set orig_package=packages\9e13b2414b41b842.orig
set patched_package=packages\9e13b2414b41b842
set pacth_dir=patch
set hash_db=hash-db\file.db
%tool% repack --hash-db "%hash_db%" --compiler "%compiler%" "%orig_package%" "%patched_package%" "%pacth_dir%"
endlocal
