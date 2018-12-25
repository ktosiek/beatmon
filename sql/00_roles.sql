create role "beatmon" NOINHERIT NOLOGIN;  -- samerole for users connecting to the DB
create role "beatmon/graphile" NOINHERIT; -- login role for the GraphQL API
create role "beatmon/admin" NOLOGIN;      -- DB owner, full access
create role "beatmon/anon" NOLOGIN;       -- anonymous user
create role "beatmon/person" NOLOGIN;     -- logged in user

grant "beatmon" to "beatmon/graphile";
grant "beatmon/anon" to "beatmon/graphile";
grant "beatmon/person" to "beatmon/graphile";
