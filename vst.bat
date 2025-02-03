@echo off
cd /d %~dp0Backend
call env\Scripts\activate
cd vst
python manage.py runserver 0.0.0.0:8000
pause
