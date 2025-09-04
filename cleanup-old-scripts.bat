@echo off
echo 清理旧的初始化脚本文件...

REM 删除旧的初始化脚本文件
del mysql\init.sql
del mysql\init_complex_tables.sql
del mysql\init_financial_tables.sql
del mysql\init_admin_user.sql

echo 旧的初始化脚本文件已删除
echo 现在只使用 mysql\init_complete.sql 作为唯一的初始化脚本
pause
