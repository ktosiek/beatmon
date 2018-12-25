--
-- PostgreSQL database dump
--

-- Dumped from database version 10.6 (Ubuntu 10.6-0ubuntu0.18.10.1)
-- Dumped by pg_dump version 10.6 (Ubuntu 10.6-0ubuntu0.18.10.1)

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
-- Name: beatmon; Type: SCHEMA; Schema: -; Owner: beatmon/admin
--

CREATE SCHEMA beatmon;


ALTER SCHEMA beatmon OWNER TO "beatmon/admin";

--
-- Name: internal; Type: SCHEMA; Schema: -; Owner: beatmon/admin
--

CREATE SCHEMA internal;


ALTER SCHEMA internal OWNER TO "beatmon/admin";

--
-- Name: jwt_token; Type: TYPE; Schema: beatmon; Owner: beatmon/admin
--

CREATE TYPE beatmon.jwt_token AS (
	role text,
	exp integer,
	account_id integer,
	is_admin boolean,
	email text
);


ALTER TYPE beatmon.jwt_token OWNER TO "beatmon/admin";

--
-- Name: authenticate(text, text); Type: FUNCTION; Schema: beatmon; Owner: beatmon/admin
--

CREATE FUNCTION beatmon.authenticate(email text, password text) RETURNS beatmon.jwt_token
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$

declare
  account beatmon.account;
  account_password "internal".account_password;
begin
  select a.* into account
    from beatmon.account as a
    where a.email = authenticate.email;
  select a.* into account_password
  	from internal.account_password a
	where a.account_id = account.account_id;

  if account.is_active and account_password.password_hash = crypt(password, account_password.password_hash) then
    return (
      'beatmon/person',
      extract(epoch from now() + interval '7 days'),
      account.account_id,
      account.is_admin,
	  account.email
    )::beatmon.jwt_token;
  else
    return null;
  end if;
end;

$$;


ALTER FUNCTION beatmon.authenticate(email text, password text) OWNER TO "beatmon/admin";

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: account; Type: TABLE; Schema: beatmon; Owner: beatmon/admin
--

CREATE TABLE beatmon.account (
    account_id bigint NOT NULL,
    email character varying(250) NOT NULL,
    is_admin boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL
);


ALTER TABLE beatmon.account OWNER TO "beatmon/admin";

--
-- Name: current_account(); Type: FUNCTION; Schema: beatmon; Owner: beatmon/admin
--

CREATE FUNCTION beatmon.current_account() RETURNS beatmon.account
    LANGUAGE sql STABLE PARALLEL RESTRICTED
    AS $$
select * from account where account_id = current_account_id();
$$;


ALTER FUNCTION beatmon.current_account() OWNER TO "beatmon/admin";

--
-- Name: current_account_id(); Type: FUNCTION; Schema: beatmon; Owner: beatmon/admin
--

CREATE FUNCTION beatmon.current_account_id() RETURNS bigint
    LANGUAGE sql STABLE
    AS $$
  select nullif(current_setting('jwt.claims.account_id', true), '')::bigint;
$$;


ALTER FUNCTION beatmon.current_account_id() OWNER TO "beatmon/admin";

--
-- Name: heartbeat; Type: TABLE; Schema: beatmon; Owner: beatmon/admin
--

CREATE TABLE beatmon.heartbeat (
    heartbeat_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    account_id bigint DEFAULT beatmon.current_account_id() NOT NULL,
    name text,
    notify_after_seconds integer DEFAULT (5 * 60) NOT NULL,
    CONSTRAINT notify_after_seconds_min CHECK ((notify_after_seconds > 60))
);


ALTER TABLE beatmon.heartbeat OWNER TO "beatmon/admin";

--
-- Name: heartbeat_last_seen(beatmon.heartbeat); Type: FUNCTION; Schema: beatmon; Owner: tomek
--

CREATE FUNCTION beatmon.heartbeat_last_seen(h beatmon.heartbeat) RETURNS timestamp without time zone
    LANGUAGE sql STABLE
    AS $$
  select max(date) from heartbeat_log l where l.heartbeat_id = h.heartbeat_id 
$$;


ALTER FUNCTION beatmon.heartbeat_last_seen(h beatmon.heartbeat) OWNER TO tomek;

--
-- Name: refresh_token(); Type: FUNCTION; Schema: beatmon; Owner: beatmon/admin
--

CREATE FUNCTION beatmon.refresh_token() RETURNS beatmon.jwt_token
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$

declare
  account beatmon.account;
begin
  select a.* into account
    from beatmon.account as a
    where a.account_id = beatmon.current_account_id();

  if account.is_active then
    return (
      'beatmon/person',
      extract(epoch from now() + interval '7 days'),
      account.account_id,
      account.is_admin,
	  account.email
    )::beatmon.jwt_token;
  else
    return null;
  end if;
end;

$$;


ALTER FUNCTION beatmon.refresh_token() OWNER TO "beatmon/admin";

--
-- Name: set_password(bigint, text); Type: FUNCTION; Schema: internal; Owner: tomek
--

CREATE FUNCTION internal.set_password(account bigint, password text) RETURNS void
    LANGUAGE plpgsql
    AS $$
  DECLARE
    hashed constant text := crypt(password, gen_salt('bf', 10));
  BEGIN
    insert into internal.account_password (account_id, password_hash)
    values (account, hashed)
    ON CONFLICT (account_id) DO UPDATE SET password_hash = hashed;
  END $$;


ALTER FUNCTION internal.set_password(account bigint, password text) OWNER TO tomek;

--
-- Name: account_account_id_seq; Type: SEQUENCE; Schema: beatmon; Owner: beatmon/admin
--

CREATE SEQUENCE beatmon.account_account_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE beatmon.account_account_id_seq OWNER TO "beatmon/admin";

--
-- Name: account_account_id_seq; Type: SEQUENCE OWNED BY; Schema: beatmon; Owner: beatmon/admin
--

ALTER SEQUENCE beatmon.account_account_id_seq OWNED BY beatmon.account.account_id;


--
-- Name: devices; Type: TABLE; Schema: beatmon; Owner: beatmon/admin
--

CREATE TABLE beatmon.devices (
    device_id bigint NOT NULL,
    webpush_registration jsonb NOT NULL,
    account_id bigint DEFAULT beatmon.current_account_id() NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    name character varying(100) DEFAULT 'Unnamed device'::character varying NOT NULL,
    CONSTRAINT subscription_is_valid CHECK ((webpush_registration ? 'endpoint'::text))
);


ALTER TABLE beatmon.devices OWNER TO "beatmon/admin";

--
-- Name: devices_device_id_seq; Type: SEQUENCE; Schema: beatmon; Owner: beatmon/admin
--

CREATE SEQUENCE beatmon.devices_device_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE beatmon.devices_device_id_seq OWNER TO "beatmon/admin";

--
-- Name: devices_device_id_seq; Type: SEQUENCE OWNED BY; Schema: beatmon; Owner: beatmon/admin
--

ALTER SEQUENCE beatmon.devices_device_id_seq OWNED BY beatmon.devices.device_id;


--
-- Name: heartbeat_log; Type: TABLE; Schema: beatmon; Owner: beatmon/admin
--

CREATE TABLE beatmon.heartbeat_log (
    date timestamp without time zone DEFAULT now() NOT NULL,
    heartbeat_id uuid NOT NULL,
    account_id bigint DEFAULT beatmon.current_account_id() NOT NULL
);


ALTER TABLE beatmon.heartbeat_log OWNER TO "beatmon/admin";

--
-- Name: account_password; Type: TABLE; Schema: internal; Owner: beatmon/admin
--

CREATE TABLE internal.account_password (
    account_id bigint NOT NULL,
    password_hash text NOT NULL
);


ALTER TABLE internal.account_password OWNER TO "beatmon/admin";

--
-- Name: account account_id; Type: DEFAULT; Schema: beatmon; Owner: beatmon/admin
--

ALTER TABLE ONLY beatmon.account ALTER COLUMN account_id SET DEFAULT nextval('beatmon.account_account_id_seq'::regclass);


--
-- Name: devices device_id; Type: DEFAULT; Schema: beatmon; Owner: beatmon/admin
--

ALTER TABLE ONLY beatmon.devices ALTER COLUMN device_id SET DEFAULT nextval('beatmon.devices_device_id_seq'::regclass);


--
-- Name: account account_email_uniq; Type: CONSTRAINT; Schema: beatmon; Owner: beatmon/admin
--

ALTER TABLE ONLY beatmon.account
    ADD CONSTRAINT account_email_uniq UNIQUE (email);


--
-- Name: account account_pkey; Type: CONSTRAINT; Schema: beatmon; Owner: beatmon/admin
--

ALTER TABLE ONLY beatmon.account
    ADD CONSTRAINT account_pkey PRIMARY KEY (account_id);


--
-- Name: devices devices_pkey; Type: CONSTRAINT; Schema: beatmon; Owner: beatmon/admin
--

ALTER TABLE ONLY beatmon.devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (device_id);


--
-- Name: heartbeat heartbeat_account_uniq; Type: CONSTRAINT; Schema: beatmon; Owner: beatmon/admin
--

ALTER TABLE ONLY beatmon.heartbeat
    ADD CONSTRAINT heartbeat_account_uniq UNIQUE (heartbeat_id, account_id);


--
-- Name: heartbeat_log heartbeat_log_pkey; Type: CONSTRAINT; Schema: beatmon; Owner: beatmon/admin
--

ALTER TABLE ONLY beatmon.heartbeat_log
    ADD CONSTRAINT heartbeat_log_pkey PRIMARY KEY (date, heartbeat_id);


--
-- Name: heartbeat heartbeat_pkey; Type: CONSTRAINT; Schema: beatmon; Owner: beatmon/admin
--

ALTER TABLE ONLY beatmon.heartbeat
    ADD CONSTRAINT heartbeat_pkey PRIMARY KEY (heartbeat_id);


--
-- Name: account_password account_password_pkey; Type: CONSTRAINT; Schema: internal; Owner: beatmon/admin
--

ALTER TABLE ONLY internal.account_password
    ADD CONSTRAINT account_password_pkey PRIMARY KEY (account_id);


--
-- Name: fki_heartbeat_log_fk_heartbeat; Type: INDEX; Schema: beatmon; Owner: beatmon/admin
--

CREATE INDEX fki_heartbeat_log_fk_heartbeat ON beatmon.heartbeat_log USING btree (heartbeat_id, account_id);


--
-- Name: fki_heartbeat_log_fk_heartbeat_id; Type: INDEX; Schema: beatmon; Owner: beatmon/admin
--

CREATE INDEX fki_heartbeat_log_fk_heartbeat_id ON beatmon.heartbeat_log USING btree (heartbeat_id);


--
-- Name: devices device_account_fk; Type: FK CONSTRAINT; Schema: beatmon; Owner: beatmon/admin
--

ALTER TABLE ONLY beatmon.devices
    ADD CONSTRAINT device_account_fk FOREIGN KEY (account_id) REFERENCES beatmon.account(account_id);


--
-- Name: heartbeat heartbeat_fk_account_Id; Type: FK CONSTRAINT; Schema: beatmon; Owner: beatmon/admin
--

ALTER TABLE ONLY beatmon.heartbeat
    ADD CONSTRAINT "heartbeat_fk_account_Id" FOREIGN KEY (account_id) REFERENCES beatmon.account(account_id);


--
-- Name: heartbeat_log heartbeat_log_fk_heartbeat; Type: FK CONSTRAINT; Schema: beatmon; Owner: beatmon/admin
--

ALTER TABLE ONLY beatmon.heartbeat_log
    ADD CONSTRAINT heartbeat_log_fk_heartbeat FOREIGN KEY (heartbeat_id, account_id) REFERENCES beatmon.heartbeat(heartbeat_id, account_id);


--
-- Name: account; Type: ROW SECURITY; Schema: beatmon; Owner: beatmon/admin
--

ALTER TABLE beatmon.account ENABLE ROW LEVEL SECURITY;

--
-- Name: account account_self; Type: POLICY; Schema: beatmon; Owner: beatmon/admin
--

CREATE POLICY account_self ON beatmon.account TO "beatmon/person" USING ((account_id = beatmon.current_account_id()));


--
-- Name: devices device_owner; Type: POLICY; Schema: beatmon; Owner: beatmon/admin
--

CREATE POLICY device_owner ON beatmon.devices TO "beatmon/person" USING ((account_id = beatmon.current_account_id()));


--
-- Name: devices; Type: ROW SECURITY; Schema: beatmon; Owner: beatmon/admin
--

ALTER TABLE beatmon.devices ENABLE ROW LEVEL SECURITY;

--
-- Name: heartbeat; Type: ROW SECURITY; Schema: beatmon; Owner: beatmon/admin
--

ALTER TABLE beatmon.heartbeat ENABLE ROW LEVEL SECURITY;

--
-- Name: heartbeat_log; Type: ROW SECURITY; Schema: beatmon; Owner: beatmon/admin
--

ALTER TABLE beatmon.heartbeat_log ENABLE ROW LEVEL SECURITY;

--
-- Name: heartbeat heartbeat_owner; Type: POLICY; Schema: beatmon; Owner: beatmon/admin
--

CREATE POLICY heartbeat_owner ON beatmon.heartbeat TO "beatmon/person" USING ((account_id = beatmon.current_account_id()));


--
-- Name: heartbeat_log heartbeat_owner; Type: POLICY; Schema: beatmon; Owner: beatmon/admin
--

CREATE POLICY heartbeat_owner ON beatmon.heartbeat_log TO "beatmon/person" USING ((account_id = beatmon.current_account_id()));


--
-- Name: SCHEMA beatmon; Type: ACL; Schema: -; Owner: beatmon/admin
--

GRANT USAGE ON SCHEMA beatmon TO "beatmon/anon";
GRANT USAGE ON SCHEMA beatmon TO "beatmon/person";


--
-- Name: TABLE account; Type: ACL; Schema: beatmon; Owner: beatmon/admin
--

GRANT SELECT ON TABLE beatmon.account TO "beatmon/person";


--
-- Name: FUNCTION current_account(); Type: ACL; Schema: beatmon; Owner: beatmon/admin
--

REVOKE ALL ON FUNCTION beatmon.current_account() FROM PUBLIC;
GRANT ALL ON FUNCTION beatmon.current_account() TO "beatmon/anon";
GRANT ALL ON FUNCTION beatmon.current_account() TO "beatmon/person";


--
-- Name: TABLE heartbeat; Type: ACL; Schema: beatmon; Owner: beatmon/admin
--

GRANT SELECT ON TABLE beatmon.heartbeat TO "beatmon/person";


--
-- Name: COLUMN heartbeat.name; Type: ACL; Schema: beatmon; Owner: beatmon/admin
--

GRANT INSERT(name),UPDATE(name) ON TABLE beatmon.heartbeat TO "beatmon/person";


--
-- Name: COLUMN heartbeat.notify_after_seconds; Type: ACL; Schema: beatmon; Owner: beatmon/admin
--

GRANT INSERT(notify_after_seconds),UPDATE(notify_after_seconds) ON TABLE beatmon.heartbeat TO "beatmon/person";


--
-- Name: TABLE devices; Type: ACL; Schema: beatmon; Owner: beatmon/admin
--

GRANT SELECT,DELETE ON TABLE beatmon.devices TO "beatmon/person";


--
-- Name: COLUMN devices.webpush_registration; Type: ACL; Schema: beatmon; Owner: beatmon/admin
--

GRANT INSERT(webpush_registration) ON TABLE beatmon.devices TO "beatmon/person";


--
-- Name: COLUMN devices.enabled; Type: ACL; Schema: beatmon; Owner: beatmon/admin
--

GRANT INSERT(enabled),UPDATE(enabled) ON TABLE beatmon.devices TO "beatmon/person";


--
-- Name: COLUMN devices.name; Type: ACL; Schema: beatmon; Owner: beatmon/admin
--

GRANT INSERT(name),UPDATE(name) ON TABLE beatmon.devices TO "beatmon/person";


--
-- Name: TABLE heartbeat_log; Type: ACL; Schema: beatmon; Owner: beatmon/admin
--

GRANT SELECT ON TABLE beatmon.heartbeat_log TO "beatmon/person";


--
-- Name: COLUMN heartbeat_log.heartbeat_id; Type: ACL; Schema: beatmon; Owner: beatmon/admin
--

GRANT INSERT(heartbeat_id) ON TABLE beatmon.heartbeat_log TO "beatmon/person";


--
-- PostgreSQL database dump complete
--

