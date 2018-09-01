--
-- PostgreSQL database dump
--

-- Dumped from database version 10.5 (Ubuntu 10.5-1.pgdg18.04+1)
-- Dumped by pg_dump version 10.5 (Ubuntu 10.5-1.pgdg18.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: internal; Type: SCHEMA; Schema: -; Owner: beatmon/admin
--

CREATE SCHEMA internal;


ALTER SCHEMA internal OWNER TO "beatmon/admin";

--
-- Name: postgraphile_watch; Type: SCHEMA; Schema: -; Owner: tomek
--

CREATE SCHEMA postgraphile_watch;


ALTER SCHEMA postgraphile_watch OWNER TO tomek;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: jwt_token; Type: TYPE; Schema: public; Owner: beatmon/admin
--

CREATE TYPE public.jwt_token AS (
	role text,
	exp integer,
	account_id integer,
	is_admin boolean,
	email text
);


ALTER TYPE public.jwt_token OWNER TO "beatmon/admin";

--
-- Name: notify_watchers_ddl(); Type: FUNCTION; Schema: postgraphile_watch; Owner: tomek
--

CREATE FUNCTION postgraphile_watch.notify_watchers_ddl() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
begin
  perform pg_notify(
    'postgraphile_watch',
    json_build_object(
      'type',
      'ddl',
      'payload',
      (select json_agg(json_build_object('schema', schema_name, 'command', command_tag)) from pg_event_trigger_ddl_commands() as x)
    )::text
  );
end;
$$;


ALTER FUNCTION postgraphile_watch.notify_watchers_ddl() OWNER TO tomek;

--
-- Name: notify_watchers_drop(); Type: FUNCTION; Schema: postgraphile_watch; Owner: tomek
--

CREATE FUNCTION postgraphile_watch.notify_watchers_drop() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
begin
  perform pg_notify(
    'postgraphile_watch',
    json_build_object(
      'type',
      'drop',
      'payload',
      (select json_agg(distinct x.schema_name) from pg_event_trigger_dropped_objects() as x)
    )::text
  );
end;
$$;


ALTER FUNCTION postgraphile_watch.notify_watchers_drop() OWNER TO tomek;

--
-- Name: authenticate(text, text); Type: FUNCTION; Schema: public; Owner: beatmon/admin
--

CREATE FUNCTION public.authenticate(email text, password text) RETURNS public.jwt_token
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$

declare
  account public.account;
  account_password internal.account_password;
begin
  select a.* into account
    from public.account as a
    where a.email = authenticate.email;
  select a.* into account_password
  	from internal.account_password a
	where a.account_id = account.account_id;

  if account_password.password_hash = crypt(password, account_password.password_hash) then
    return (
      'beatmon/person',
      extract(epoch from now() + interval '7 days'),
      account.account_id,
      account.is_admin,
	  account.email
    )::public.jwt_token;
  else
    return null;
  end if;
end;

$$;


ALTER FUNCTION public.authenticate(email text, password text) OWNER TO "beatmon/admin";

--
-- Name: current_account_id(); Type: FUNCTION; Schema: public; Owner: beatmon
--

CREATE FUNCTION public.current_account_id() RETURNS bigint
    LANGUAGE sql STABLE
    AS $$
  select nullif(current_setting('jwt.claims.account_id', true), '')::bigint;
$$;


ALTER FUNCTION public.current_account_id() OWNER TO beatmon;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: heartbeat; Type: TABLE; Schema: public; Owner: beatmon/admin
--

CREATE TABLE public.heartbeat (
    heartbeat_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    account_id bigint DEFAULT public.current_account_id() NOT NULL,
    name text
);


ALTER TABLE public.heartbeat OWNER TO "beatmon/admin";

--
-- Name: heartbeat_last_seen(public.heartbeat); Type: FUNCTION; Schema: public; Owner: tomek
--

CREATE FUNCTION public.heartbeat_last_seen(h public.heartbeat) RETURNS timestamp without time zone
    LANGUAGE sql STABLE
    AS $$
  select max(date) from heartbeat_log l where l.heartbeat_id = h.heartbeat_id 
$$;


ALTER FUNCTION public.heartbeat_last_seen(h public.heartbeat) OWNER TO tomek;

--
-- Name: refresh_token(); Type: FUNCTION; Schema: public; Owner: beatmon/admin
--

CREATE FUNCTION public.refresh_token() RETURNS public.jwt_token
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$

declare
  account public.account;
begin
  select a.* into account
    from public.account as a
    where a.account_id = current_account_id();

  if account.is_active then
    return (
      'beatmon/person',
      extract(epoch from now() + interval '7 days'),
      account.account_id,
      account.is_admin,
	  account.email
    )::public.jwt_token;
  else
    return null;
  end if;
end;

$$;


ALTER FUNCTION public.refresh_token() OWNER TO "beatmon/admin";

--
-- Name: account_password; Type: TABLE; Schema: internal; Owner: beatmon/admin
--

CREATE TABLE internal.account_password (
    account_id bigint NOT NULL,
    password_hash text NOT NULL
);


ALTER TABLE internal.account_password OWNER TO "beatmon/admin";

--
-- Name: account; Type: TABLE; Schema: public; Owner: beatmon/admin
--

CREATE TABLE public.account (
    account_id bigint NOT NULL,
    email character varying(250) NOT NULL,
    is_admin boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.account OWNER TO "beatmon/admin";

--
-- Name: account_account_id_seq; Type: SEQUENCE; Schema: public; Owner: beatmon/admin
--

CREATE SEQUENCE public.account_account_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_account_id_seq OWNER TO "beatmon/admin";

--
-- Name: account_account_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: beatmon/admin
--

ALTER SEQUENCE public.account_account_id_seq OWNED BY public.account.account_id;


--
-- Name: heartbeat_log; Type: TABLE; Schema: public; Owner: beatmon/admin
--

CREATE TABLE public.heartbeat_log (
    date timestamp without time zone DEFAULT now() NOT NULL,
    heartbeat_id uuid NOT NULL,
    account_id bigint DEFAULT public.current_account_id() NOT NULL
);


ALTER TABLE public.heartbeat_log OWNER TO "beatmon/admin";

--
-- Name: account account_id; Type: DEFAULT; Schema: public; Owner: beatmon/admin
--

ALTER TABLE ONLY public.account ALTER COLUMN account_id SET DEFAULT nextval('public.account_account_id_seq'::regclass);


--
-- Name: account_password account_password_pkey; Type: CONSTRAINT; Schema: internal; Owner: beatmon/admin
--

ALTER TABLE ONLY internal.account_password
    ADD CONSTRAINT account_password_pkey PRIMARY KEY (account_id);


--
-- Name: account account_email_uniq; Type: CONSTRAINT; Schema: public; Owner: beatmon/admin
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_email_uniq UNIQUE (email);


--
-- Name: account account_pkey; Type: CONSTRAINT; Schema: public; Owner: beatmon/admin
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_pkey PRIMARY KEY (account_id);


--
-- Name: heartbeat heartbeat_account_uniq; Type: CONSTRAINT; Schema: public; Owner: beatmon/admin
--

ALTER TABLE ONLY public.heartbeat
    ADD CONSTRAINT heartbeat_account_uniq UNIQUE (heartbeat_id, account_id);


--
-- Name: heartbeat_log heartbeat_log_pkey; Type: CONSTRAINT; Schema: public; Owner: beatmon/admin
--

ALTER TABLE ONLY public.heartbeat_log
    ADD CONSTRAINT heartbeat_log_pkey PRIMARY KEY (date, heartbeat_id);


--
-- Name: heartbeat heartbeat_pkey; Type: CONSTRAINT; Schema: public; Owner: beatmon/admin
--

ALTER TABLE ONLY public.heartbeat
    ADD CONSTRAINT heartbeat_pkey PRIMARY KEY (heartbeat_id);


--
-- Name: fki_heartbeat_log_fk_heartbeat; Type: INDEX; Schema: public; Owner: beatmon/admin
--

CREATE INDEX fki_heartbeat_log_fk_heartbeat ON public.heartbeat_log USING btree (heartbeat_id, account_id);


--
-- Name: fki_heartbeat_log_fk_heartbeat_id; Type: INDEX; Schema: public; Owner: beatmon/admin
--

CREATE INDEX fki_heartbeat_log_fk_heartbeat_id ON public.heartbeat_log USING btree (heartbeat_id);


--
-- Name: heartbeat heartbeat_fk_account_Id; Type: FK CONSTRAINT; Schema: public; Owner: beatmon/admin
--

ALTER TABLE ONLY public.heartbeat
    ADD CONSTRAINT "heartbeat_fk_account_Id" FOREIGN KEY (account_id) REFERENCES public.account(account_id);


--
-- Name: heartbeat_log heartbeat_log_fk_heartbeat; Type: FK CONSTRAINT; Schema: public; Owner: beatmon/admin
--

ALTER TABLE ONLY public.heartbeat_log
    ADD CONSTRAINT heartbeat_log_fk_heartbeat FOREIGN KEY (heartbeat_id, account_id) REFERENCES public.heartbeat(heartbeat_id, account_id);


--
-- Name: postgraphile_watch_ddl; Type: EVENT TRIGGER; Schema: -; Owner: tomek
--

CREATE EVENT TRIGGER postgraphile_watch_ddl ON ddl_command_end
         WHEN TAG IN ('ALTER AGGREGATE', 'ALTER DOMAIN', 'ALTER EXTENSION', 'ALTER FOREIGN TABLE', 'ALTER FUNCTION', 'ALTER POLICY', 'ALTER SCHEMA', 'ALTER TABLE', 'ALTER TYPE', 'ALTER VIEW', 'COMMENT', 'CREATE AGGREGATE', 'CREATE DOMAIN', 'CREATE EXTENSION', 'CREATE FOREIGN TABLE', 'CREATE FUNCTION', 'CREATE INDEX', 'CREATE POLICY', 'CREATE RULE', 'CREATE SCHEMA', 'CREATE TABLE', 'CREATE TABLE AS', 'CREATE VIEW', 'DROP AGGREGATE', 'DROP DOMAIN', 'DROP EXTENSION', 'DROP FOREIGN TABLE', 'DROP FUNCTION', 'DROP INDEX', 'DROP OWNED', 'DROP POLICY', 'DROP RULE', 'DROP SCHEMA', 'DROP TABLE', 'DROP TYPE', 'DROP VIEW', 'GRANT', 'REVOKE', 'SELECT INTO')
   EXECUTE PROCEDURE postgraphile_watch.notify_watchers_ddl();


ALTER EVENT TRIGGER postgraphile_watch_ddl OWNER TO tomek;

--
-- Name: postgraphile_watch_drop; Type: EVENT TRIGGER; Schema: -; Owner: tomek
--

CREATE EVENT TRIGGER postgraphile_watch_drop ON sql_drop
   EXECUTE PROCEDURE postgraphile_watch.notify_watchers_drop();


ALTER EVENT TRIGGER postgraphile_watch_drop OWNER TO tomek;

--
-- Name: account; Type: ROW SECURITY; Schema: public; Owner: beatmon/admin
--

ALTER TABLE public.account ENABLE ROW LEVEL SECURITY;

--
-- Name: account account_self; Type: POLICY; Schema: public; Owner: beatmon/admin
--

CREATE POLICY account_self ON public.account TO beatmon USING ((account_id = public.current_account_id()));


--
-- Name: heartbeat; Type: ROW SECURITY; Schema: public; Owner: beatmon/admin
--

ALTER TABLE public.heartbeat ENABLE ROW LEVEL SECURITY;

--
-- Name: heartbeat_log; Type: ROW SECURITY; Schema: public; Owner: beatmon/admin
--

ALTER TABLE public.heartbeat_log ENABLE ROW LEVEL SECURITY;

--
-- Name: heartbeat heartbeat_owner; Type: POLICY; Schema: public; Owner: beatmon/admin
--

CREATE POLICY heartbeat_owner ON public.heartbeat TO beatmon USING ((account_id = public.current_account_id()));


--
-- Name: heartbeat_log heartbeat_owner; Type: POLICY; Schema: public; Owner: beatmon/admin
--

CREATE POLICY heartbeat_owner ON public.heartbeat_log TO beatmon USING ((account_id = public.current_account_id()));


--
-- Name: TABLE heartbeat; Type: ACL; Schema: public; Owner: beatmon/admin
--

GRANT SELECT ON TABLE public.heartbeat TO "beatmon/person";


--
-- Name: COLUMN heartbeat.name; Type: ACL; Schema: public; Owner: beatmon/admin
--

GRANT INSERT(name),UPDATE(name) ON TABLE public.heartbeat TO "beatmon/person";


--
-- Name: TABLE account; Type: ACL; Schema: public; Owner: beatmon/admin
--

GRANT SELECT ON TABLE public.account TO "beatmon/person";


--
-- Name: TABLE heartbeat_log; Type: ACL; Schema: public; Owner: beatmon/admin
--

GRANT SELECT ON TABLE public.heartbeat_log TO "beatmon/person";


--
-- Name: COLUMN heartbeat_log.heartbeat_id; Type: ACL; Schema: public; Owner: beatmon/admin
--

GRANT INSERT(heartbeat_id) ON TABLE public.heartbeat_log TO "beatmon/person";


--
-- PostgreSQL database dump complete
--

