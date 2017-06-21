-- Restauration base de donn�es SQL Server / version 2.3 SQL

-- D�claration des variables
DECLARE @utilisateur nvarchar(255);
DECLARE @sql nvarchar(512);
DECLARE @repertoire nvarchar(255);
DECLARE @base nvarchar(255);
DECLARE @base_log nvarchar(255);
DECLARE @nouvelle_base nvarchar(255);
DECLARE @chemin_defaut nvarchar(255);
DECLARE @chemin_bak nvarchar(255);
DECLARE @chemin_mdf nvarchar(255);
DECLARE @chemin_ldf nvarchar(255);

--R�cup�ration du chemin des donn�es par d�faut de SQL Server
SELECT @chemin_defaut = (SELECT SUBSTRING(physical_name, 1, CHARINDEX(N'master.mdf', LOWER(physical_name)) - 1) FROM master.sys.master_files WHERE database_id = 1 AND file_id = 1)

-- Nom de l'utilisateur orphelin (depuis fichier BATCH)
SET @utilisateur = '$(utilisateur_t)';
-- R�pertoire du script (depuis fichier BATCH)
SET @repertoire = $(repertoire_t);
-- Nom de la base de donn�es � restaurer (depuis fichier BATCH)
SET @base = '$(base_t)';
-- Nom de la base avec "_Log" � la suite
SET @base_log = @base + N'_log';

-- Nom de la nouvelle base de donn�es
SET @nouvelle_base = '$(nouvelle_base_t)';

-- Construction du chemin complet du fichier BAK � restaurer
SET @chemin_bak = @repertoire + @base + N'.bak';

-- Construction du chemin complet du fichier .MDF de la nouvelle base de donn�es
SET @chemin_mdf = @chemin_defaut + @nouvelle_base + N'.mdf';

-- Construction du chemin complet du fichier .LDF de la nouvelle base de donn�es
SET @chemin_ldf = @chemin_defaut + @nouvelle_base + N'.ldf';

-- Restauration du fichier .BAK dans une nouvelle base de donn�es
RESTORE DATABASE @nouvelle_base FROM DISK = @chemin_bak WITH FILE = 1,
MOVE @base TO @chemin_mdf,
MOVE @base_log TO @chemin_ldf
--GO

--Fabrication de la requ�te USE [ma base] et execution de la procedure stock� sp_change_users_login update_one
SELECT @sql = 'USE ' + quotename(@nouvelle_base) + '; ALTER USER ' + @utilisateur + ' with login = ' + @utilisateur
--Execution de la requ�te USE + sp_change_users_login update_one
EXEC (@sql)
