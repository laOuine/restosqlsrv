-- Restauration base de données SQL Server / version 2.3 SQL

-- Déclaration des variables
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

--Récupération du chemin des données par défaut de SQL Server
SELECT @chemin_defaut = (SELECT SUBSTRING(physical_name, 1, CHARINDEX(N'master.mdf', LOWER(physical_name)) - 1) FROM master.sys.master_files WHERE database_id = 1 AND file_id = 1)

-- Nom de l'utilisateur orphelin (depuis fichier BATCH)
SET @utilisateur = '$(utilisateur_t)';
-- Répertoire du script (depuis fichier BATCH)
SET @repertoire = $(repertoire_t);
-- Nom de la base de données à restaurer (depuis fichier BATCH)
SET @base = '$(base_t)';
-- Nom de la base avec "_Log" à la suite
SET @base_log = @base + N'_log';

-- Nom de la nouvelle base de données
SET @nouvelle_base = '$(nouvelle_base_t)';

-- Construction du chemin complet du fichier BAK à restaurer
SET @chemin_bak = @repertoire + @base + N'.bak';

-- Construction du chemin complet du fichier .MDF de la nouvelle base de données
SET @chemin_mdf = @chemin_defaut + @nouvelle_base + N'.mdf';

-- Construction du chemin complet du fichier .LDF de la nouvelle base de données
SET @chemin_ldf = @chemin_defaut + @nouvelle_base + N'.ldf';

-- Restauration du fichier .BAK dans une nouvelle base de données
RESTORE DATABASE @nouvelle_base FROM DISK = @chemin_bak WITH FILE = 1,
MOVE @base TO @chemin_mdf,
MOVE @base_log TO @chemin_ldf
--GO

--Fabrication de la requète USE [ma base] et execution de la procedure stocké sp_change_users_login update_one
SELECT @sql = 'USE ' + quotename(@nouvelle_base) + '; ALTER USER ' + @utilisateur + ' with login = ' + @utilisateur
--Execution de la requète USE + sp_change_users_login update_one
EXEC (@sql)
