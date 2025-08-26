--
-- PostgreSQL database dump
--
-- Dumped from database version 14.19
-- Dumped by pg_dump version 14.19

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: predicted_battery_percentage_cat; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.predicted_battery_percentage_cat (
    battery_percentage double precision,
    "timestamp" timestamp without time zone,
    vehicle bigint
);


--
-- Name: predicted_w4_building_consumption_cat; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.predicted_w4_building_consumption_cat (
    w4_building_consumption double precision,
    "timestamp" timestamp without time zone
);


--
-- Name: predicted_w4_production_cat; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.predicted_w4_production_cat (
    w4_production double precision,
    "timestamp" timestamp without time zone
);


--
-- Name: prophet_forecast_w4_building_consumption; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prophet_forecast_w4_building_consumption (
    "timestamp" timestamp without time zone,
    w4_building_consumption double precision,
    trend double precision,
    daily double precision,
    hourly double precision,
    weekly double precision
);


--
-- Name: tower; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tower (
    tower bigint,
    charge_id integer[]
);


--
-- Name: tower_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tower_states (
    id bigint,
    plugs_state text,
    "timestamp" timestamp without time zone,
    ac_max_current double precision,
    dc_modules_number text,
    dc_min_voltage text,
    dc_max_voltage text,
    dc_max_current double precision,
    tower bigint
);


--
-- Name: vehicle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vehicle (
    vehicle bigint,
    charge_id integer[]
);


--
-- Name: vehicle_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vehicle_states (
    id bigint,
    battery_percentage double precision,
    velocity double precision,
    "timestamp" timestamp without time zone,
    in_charge boolean,
    efficiency text,
    charges_count bigint,
    km_tot double precision,
    kwh_charged double precision,
    vehicle bigint
);


--
-- Name: w4_calc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.w4_calc (
    "timestamp" timestamp without time zone,
    w4_production double precision,
    w4_building_consumption double precision
);


--
-- PostgreSQL database dump complete
--

