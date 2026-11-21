SELECT pg_advisory_xact_lock(314159, 17) AS locked \gset
SELECT NOT EXISTS (
    SELECT FROM pg_namespace WHERE nspname = 'catdb'
) AS needs_install \gset
\if :needs_install
\ir sql/01_schema.sql
\ir sql/02_seed.sql
\endif
