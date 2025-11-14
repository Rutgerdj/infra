gunzip --stdout "/mnt/personal_media/picture_data/backups/immich-db-backup-20251114T020000-v2.2.1-pg14.19.sql.gz" \
| sed "s/SELECT pg_catalog.set_config('search_path', '', false);/SELECT pg_catalog.set_config('search_path', 'public, pg_catalog', true);/g" \
| docker exec -i immich_postgres psql --dbname=postgres --username=postgres