@echo off
REM Restauration base de données SQL Server / version 2.3 BAT

REM *********************
REM **** PARAMETRAGE ****
REM *********************

REM Nom ou IP du serveur \ Nom instance
set serveur=127.0.0.1\SQL2014

REM Nom de la base et du fichier de la sauvegarde
set base=Winstar

REM Nom de l'utilisateur de la base
set utilisateur=masterk

REM ****************************
REM **** FIN DU PARAMETRAGE ****
REM ****************************

REM Construction du fichier de sauvegarde .BAK
set fichier=%base%.bak

REM Repertoire du script
set repertoire=%~dp0

REM Message d'avertissement
echo ***** ATTENTION *****
echo SI VOUS SAISISSEZ LE NOM D'UNE BASE EXISTANTE
echo VOUS ALLEZ l'ECRASER !

REM Saisie de la nouvelle base de données par l'utilisateur
set /p nouvelle_base="Entrez le nom de la nouvelle base de données : "

REM Test la présence du fichier de sauvegarde .BAK
if exist %fichier% (goto SQLCMD) else (goto FICERR)

:SQLCMD
REM Lancement du script SQL de restauration et écriture d'un fichier de journalisation
sqlcmd -E -S %serveur% -v repertoire_t="'%repertoire%'" base_t=%base% nouvelle_base_t=%nouvelle_base% utilisateur_t=%utilisateur% -i %repertoire%restauration_diffsrvplus.sql -o %repertoire%restauration_diffsrvplus_log.txt
goto END

:FICERR
cls
echo Le fichier %fichier% n'existe pas dans le repertoire:
echo %repertoire%
pause
goto END

:END
REM Fin du script