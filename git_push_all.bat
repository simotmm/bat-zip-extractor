@echo off
echo git push automatico: il repo verra' aggiornato.

echo aggiunta file in corso:
echo git add .
git add .
echo file aggiunti correttamente.

echo commit in corso:
echo git commit -m "update"
git commit -m "update"
echo commit effettuato correttamente.

echo push in corso:
echo git push
git push
echo push effettuato correttamente.

echo.
echo procedura terminata con successo.
pause
