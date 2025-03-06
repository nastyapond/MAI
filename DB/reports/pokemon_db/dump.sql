--
-- PostgreSQL database dump
--

-- Dumped from database version 15.5 (Debian 15.5-1.pgdg120+1)
-- Dumped by pg_dump version 15.5 (Debian 15.5-1.pgdg120+1)

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

--
-- Name: count_pokemon_for_trainer(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.count_pokemon_for_trainer(trainer_id bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
    pokemon_count BIGINT;
BEGIN
    SELECT COUNT(*) INTO pokemon_count
    FROM pokemon
    WHERE trainer = trainer_id;

    RETURN pokemon_count;
END;
$$;


ALTER FUNCTION public.count_pokemon_for_trainer(trainer_id bigint) OWNER TO postgres;

--
-- Name: delete_unowned_pokemon(); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.delete_unowned_pokemon()
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM pokemon
    WHERE trainer IS NULL;
END;
$$;


ALTER PROCEDURE public.delete_unowned_pokemon() OWNER TO postgres;

--
-- Name: increase_stats_on_level_up(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.increase_stats_on_level_up() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Увеличиваем каждую характеристику в 1.2 раза и округляем
    NEW.HP = CEIL(NEW.HP * 1.1);
    NEW.attack = CEIL(NEW.attack * 1.1);
    NEW.defense = CEIL(NEW.defense * 1.1);
    NEW.sp_atk = CEIL(NEW.sp_atk * 1.1);
    NEW.sp_def = CEIL(NEW.sp_def * 1.1);
    NEW.speed = CEIL(NEW.speed * 1.1);

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.increase_stats_on_level_up() OWNER TO postgres;

--
-- Name: reset_pokemon_stats(bigint); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.reset_pokemon_stats(IN pokemon_id bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE pokemon
    SET
        HP = 1,
        attack = 1,
        defense = 1,
        sp_atk = 1,
        sp_def = 1,
        speed = 1
    WHERE id = pokemon_id;
END;
$$;


ALTER PROCEDURE public.reset_pokemon_stats(IN pokemon_id bigint) OWNER TO postgres;

--
-- Name: update_pokemon_trainer(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_pokemon_trainer() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE pokemon
    SET trainer = NEW.trainer_to
    WHERE id = NEW.pokemon_id;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_pokemon_trainer() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: abilities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.abilities (
    id integer NOT NULL,
    name text NOT NULL,
    description text,
    CONSTRAINT abilities_name_check CHECK ((TRIM(BOTH FROM name) <> ''::text))
);


ALTER TABLE public.abilities OWNER TO postgres;

--
-- Name: abilities_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.abilities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.abilities_id_seq OWNER TO postgres;

--
-- Name: abilities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.abilities_id_seq OWNED BY public.abilities.id;


--
-- Name: moves; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.moves (
    id integer NOT NULL,
    name text NOT NULL,
    type bigint,
    contest_type bigint,
    power bigint,
    accuracy bigint,
    pp_cost bigint,
    description text,
    CONSTRAINT moves_name_check CHECK ((TRIM(BOTH FROM name) <> ''::text))
);


ALTER TABLE public.moves OWNER TO postgres;

--
-- Name: pokemon; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pokemon (
    id integer NOT NULL,
    name text,
    pokedex_id bigint,
    gender text,
    level numeric(3,0) NOT NULL,
    move1 bigint NOT NULL,
    move2 bigint,
    move3 bigint,
    move4 bigint,
    trainer bigint,
    original_trainer bigint,
    item bigint,
    hp bigint DEFAULT 1 NOT NULL,
    attack bigint DEFAULT 1 NOT NULL,
    defense bigint DEFAULT 1 NOT NULL,
    sp_atk bigint DEFAULT 1 NOT NULL,
    sp_def bigint DEFAULT 1 NOT NULL,
    speed bigint DEFAULT 1 NOT NULL,
    CONSTRAINT pokemon_gender_check CHECK (((gender = ANY (ARRAY['male'::text, 'female'::text])) OR (gender IS NULL))),
    CONSTRAINT pokemon_level_check CHECK (((level >= (0)::numeric) AND (level <= (100)::numeric))),
    CONSTRAINT unique_moves CHECK (((move1 <> move2) AND (move1 <> move3) AND (move1 <> move4) AND (move2 <> move3) AND (move2 <> move4) AND (move3 <> move4)))
);


ALTER TABLE public.pokemon OWNER TO postgres;

--
-- Name: types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.types (
    id integer NOT NULL,
    name text NOT NULL,
    CONSTRAINT types_name_check CHECK ((TRIM(BOTH FROM name) <> ''::text))
);


ALTER TABLE public.types OWNER TO postgres;

--
-- Name: battle_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.battle_view AS
 SELECT p.id AS pokemon_id,
    p.name AS pokemon_name,
    m1.name AS move1,
    t1.name AS move1_type,
    m1.pp_cost AS move1_pp,
    m2.name AS move2,
    t2.name AS move2_type,
    m2.pp_cost AS move2_pp,
    m3.name AS move3,
    t3.name AS move3_type,
    m3.pp_cost AS move3_pp,
    m4.name AS move4,
    t4.name AS move4_type,
    m4.pp_cost AS move4_pp
   FROM ((((((((public.pokemon p
     LEFT JOIN public.moves m1 ON ((p.move1 = m1.id)))
     LEFT JOIN public.types t1 ON ((m1.type = t1.id)))
     LEFT JOIN public.moves m2 ON ((p.move2 = m2.id)))
     LEFT JOIN public.types t2 ON ((m2.type = t2.id)))
     LEFT JOIN public.moves m3 ON ((p.move3 = m3.id)))
     LEFT JOIN public.types t3 ON ((m3.type = t3.id)))
     LEFT JOIN public.moves m4 ON ((p.move4 = m4.id)))
     LEFT JOIN public.types t4 ON ((m4.type = t4.id)));


ALTER TABLE public.battle_view OWNER TO postgres;

--
-- Name: contest_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contest_types (
    id integer NOT NULL,
    name text NOT NULL,
    CONSTRAINT contest_types_name_check CHECK ((TRIM(BOTH FROM name) <> ''::text))
);


ALTER TABLE public.contest_types OWNER TO postgres;

--
-- Name: contest_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.contest_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.contest_types_id_seq OWNER TO postgres;

--
-- Name: contest_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.contest_types_id_seq OWNED BY public.contest_types.id;


--
-- Name: contest_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.contest_view AS
 SELECT p.id AS pokemon_id,
    p.name AS pokemon_name,
    m1.name AS move1,
    ct1.name AS move1_contest_type,
    m2.name AS move2,
    ct2.name AS move2_contest_type,
    m3.name AS move3,
    ct3.name AS move3_contest_type,
    m4.name AS move4,
    ct4.name AS move4_contest_type
   FROM ((((((((public.pokemon p
     LEFT JOIN public.moves m1 ON ((p.move1 = m1.id)))
     LEFT JOIN public.contest_types ct1 ON ((m1.contest_type = ct1.id)))
     LEFT JOIN public.moves m2 ON ((p.move2 = m2.id)))
     LEFT JOIN public.contest_types ct2 ON ((m2.contest_type = ct2.id)))
     LEFT JOIN public.moves m3 ON ((p.move3 = m3.id)))
     LEFT JOIN public.contest_types ct3 ON ((m3.contest_type = ct3.id)))
     LEFT JOIN public.moves m4 ON ((p.move4 = m4.id)))
     LEFT JOIN public.contest_types ct4 ON ((m4.contest_type = ct4.id)));


ALTER TABLE public.contest_view OWNER TO postgres;

--
-- Name: items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.items (
    id integer NOT NULL,
    name text NOT NULL,
    description text,
    CONSTRAINT items_name_check CHECK ((TRIM(BOTH FROM name) <> ''::text))
);


ALTER TABLE public.items OWNER TO postgres;

--
-- Name: items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.items_id_seq OWNER TO postgres;

--
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.items_id_seq OWNED BY public.items.id;


--
-- Name: moves_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.moves_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.moves_id_seq OWNER TO postgres;

--
-- Name: moves_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.moves_id_seq OWNED BY public.moves.id;


--
-- Name: pokedex; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pokedex (
    id integer NOT NULL,
    name text NOT NULL,
    type1 bigint NOT NULL,
    type2 bigint,
    ability bigint NOT NULL,
    CONSTRAINT pokedex_name_check CHECK ((TRIM(BOTH FROM name) <> ''::text))
);


ALTER TABLE public.pokedex OWNER TO postgres;

--
-- Name: pokedex_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pokedex_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pokedex_id_seq OWNER TO postgres;

--
-- Name: pokedex_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pokedex_id_seq OWNED BY public.pokedex.id;


--
-- Name: pokemon_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pokemon_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pokemon_id_seq OWNER TO postgres;

--
-- Name: pokemon_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pokemon_id_seq OWNED BY public.pokemon.id;


--
-- Name: trainers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.trainers (
    id integer NOT NULL,
    name text NOT NULL,
    CONSTRAINT trainers_name_check CHECK ((TRIM(BOTH FROM name) <> ''::text))
);


ALTER TABLE public.trainers OWNER TO postgres;

--
-- Name: pokemon_info_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.pokemon_info_view AS
 SELECT p.id AS pokemon_id,
    p.name AS pokemon_name,
    pd.name AS species_name,
        CASE
            WHEN (p.gender = 'male'::text) THEN 'Male'::text
            WHEN (p.gender = 'female'::text) THEN 'Female'::text
            ELSE 'None'::text
        END AS gender,
    p.level AS current_level,
    t1.name AS type1,
    t2.name AS type2,
    ot.name AS original_trainer_name,
    p.original_trainer AS original_trainer_id,
    ct.name AS current_trainer_name,
    p.trainer AS current_trainer_id
   FROM (((((public.pokemon p
     JOIN public.pokedex pd ON ((p.pokedex_id = pd.id)))
     LEFT JOIN public.types t1 ON ((pd.type1 = t1.id)))
     LEFT JOIN public.types t2 ON ((pd.type2 = t2.id)))
     LEFT JOIN public.trainers ot ON ((p.original_trainer = ot.id)))
     LEFT JOIN public.trainers ct ON ((p.trainer = ct.id)));


ALTER TABLE public.pokemon_info_view OWNER TO postgres;

--
-- Name: skills_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.skills_view AS
 SELECT p.id AS pokemon_id,
    p.name AS pokemon_name,
    pd.name AS species_name,
    t1.name AS type1,
    t2.name AS type2,
    a.name AS ability,
    i.name AS held_item,
    p.level,
    p.hp,
    p.attack,
    p.defense,
    p.sp_atk,
    p.sp_def,
    p.speed
   FROM (((((public.pokemon p
     JOIN public.pokedex pd ON ((p.pokedex_id = pd.id)))
     LEFT JOIN public.types t1 ON ((pd.type1 = t1.id)))
     LEFT JOIN public.types t2 ON ((pd.type2 = t2.id)))
     JOIN public.abilities a ON ((pd.ability = a.id)))
     LEFT JOIN public.items i ON ((p.item = i.id)));


ALTER TABLE public.skills_view OWNER TO postgres;

--
-- Name: trades; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.trades (
    id integer NOT NULL,
    trainer_from bigint,
    trainer_to bigint,
    pokemon_id bigint,
    trade_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.trades OWNER TO postgres;

--
-- Name: trades_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.trades_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.trades_id_seq OWNER TO postgres;

--
-- Name: trades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.trades_id_seq OWNED BY public.trades.id;


--
-- Name: trainers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.trainers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.trainers_id_seq OWNER TO postgres;

--
-- Name: trainers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.trainers_id_seq OWNED BY public.trainers.id;


--
-- Name: types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.types_id_seq OWNER TO postgres;

--
-- Name: types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.types_id_seq OWNED BY public.types.id;


--
-- Name: abilities id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.abilities ALTER COLUMN id SET DEFAULT nextval('public.abilities_id_seq'::regclass);


--
-- Name: contest_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contest_types ALTER COLUMN id SET DEFAULT nextval('public.contest_types_id_seq'::regclass);


--
-- Name: items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items ALTER COLUMN id SET DEFAULT nextval('public.items_id_seq'::regclass);


--
-- Name: moves id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moves ALTER COLUMN id SET DEFAULT nextval('public.moves_id_seq'::regclass);


--
-- Name: pokedex id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pokedex ALTER COLUMN id SET DEFAULT nextval('public.pokedex_id_seq'::regclass);


--
-- Name: pokemon id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pokemon ALTER COLUMN id SET DEFAULT nextval('public.pokemon_id_seq'::regclass);


--
-- Name: trades id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trades ALTER COLUMN id SET DEFAULT nextval('public.trades_id_seq'::regclass);


--
-- Name: trainers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trainers ALTER COLUMN id SET DEFAULT nextval('public.trainers_id_seq'::regclass);


--
-- Name: types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.types ALTER COLUMN id SET DEFAULT nextval('public.types_id_seq'::regclass);


--
-- Data for Name: abilities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.abilities (id, name, description) FROM stdin;
1	Overgrow	Boosts the power of Grass-type moves when the Pokémon is in trouble.
2	Blaze	Boosts the power of Fire-type moves when the Pokémon is in trouble.
3	Torrent	Boosts the power of Water-type moves when the Pokémon is in trouble.
4	Static	May cause paralysis if hit.
5	Levitate	Gives full immunity to all Ground-type moves.
\.


--
-- Data for Name: contest_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.contest_types (id, name) FROM stdin;
1	Beauty
2	Cool
3	Cute
4	Smart
5	Tough
\.


--
-- Data for Name: items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.items (id, name, description) FROM stdin;
\.


--
-- Data for Name: moves; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.moves (id, name, type, contest_type, power, accuracy, pp_cost, description) FROM stdin;
1	Tackle	13	5	40	100	35	A physical attack in which the user charges and slams into the target.
2	Thunder Shock	4	2	40	100	30	A jolt of electricity is hurled at the target. This may also leave the target with paralysis.
3	Ember	7	1	40	100	25	The target is attacked with small flames. This may also leave the target with a burn.
4	Water Gun	18	4	40	100	25	The target is blasted with a forceful shot of water.
5	Vine Whip	10	5	45	100	25	The target is struck with slender, whiplike vines to inflict damage.
6	Quick Attack	13	2	40	100	30	The user lunges at the target at a speed that makes it almost invisible. This move always goes first.
7	Growl	13	3	\N	100	40	The user growls in an endearing way, making opposing Pokémon less wary.
8	Tail Whip	13	3	\N	100	30	The user wags its tail cutely, making opposing Pokémon less wary and lowering their Defense stat.
9	Scratch	13	2	40	100	35	Hard, pointed, and sharp claws rake the target to inflict damage.
10	Bubble	18	4	40	100	30	A spray of bubbles is forcefully ejected at the opposing Pokémon. This may also lower their Speed stat.
\.


--
-- Data for Name: pokedex; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pokedex (id, name, type1, type2, ability) FROM stdin;
1	Bulbasaur	10	14	1
2	Ivysaur	10	14	1
3	Venusaur	10	14	1
4	Charmander	7	\N	2
5	Charmeleon	7	\N	2
6	Charizard	7	8	2
7	Squirtle	18	\N	3
8	Wartortle	18	\N	3
9	Blastoise	18	\N	3
25	Pikachu	4	\N	4
26	Raichu	4	\N	4
\.


--
-- Data for Name: pokemon; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pokemon (id, name, pokedex_id, gender, level, move1, move2, move3, move4, trainer, original_trainer, item, hp, attack, defense, sp_atk, sp_def, speed) FROM stdin;
1	Bulbasaur	1	male	5	5	7	\N	\N	1	6	\N	45	49	49	65	65	45
2	Ivysaur	2	male	16	5	7	8	\N	1	6	\N	60	62	63	80	80	60
3	Venusaur	3	male	32	5	7	8	6	1	6	\N	80	82	83	100	100	80
5	Charmeleon	5	male	16	3	9	7	\N	3	6	\N	58	64	58	80	65	80
8	Wartortle	8	female	16	4	10	7	\N	2	6	\N	59	63	80	65	80	58
9	Blastoise	9	female	36	4	10	7	8	1	6	\N	79	83	100	85	105	78
10	Pikachu	25	male	10	2	6	8	\N	2	6	\N	35	55	40	50	50	90
7	Squirtle	7	female	5	4	10	\N	\N	3	6	\N	44	48	65	50	64	43
4	Charmander	4	male	5	3	9	\N	\N	1	6	\N	39	52	43	60	50	65
6	Charizard	6	male	36	3	9	7	1	4	6	\N	78	84	78	109	85	100
11	Raichu	26	male	25	2	6	8	\N	5	6	\N	60	90	55	90	80	110
\.


--
-- Data for Name: trades; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.trades (id, trainer_from, trainer_to, pokemon_id, trade_date) FROM stdin;
1	1	2	10	2024-11-01 14:30:00
2	2	3	7	2024-11-03 10:15:00
3	3	1	4	2024-11-05 17:45:00
4	1	4	6	2024-11-07 09:00:00
5	4	5	11	2024-11-10 13:20:00
\.


--
-- Data for Name: trainers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.trainers (id, name) FROM stdin;
1	Ash
2	Misty
3	Brock
4	May
5	Max
6	Professor Oak
7	Team Rocket
\.


--
-- Data for Name: types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.types (id, name) FROM stdin;
1	Bug
2	Dark
3	Dragon
4	Electric
5	Fairy
6	Fighting
7	Fire
8	Flying
9	Ghost
10	Grass
11	Ground
12	Ice
13	Normal
14	Poison
15	Psychic
16	Rock
17	Steel
18	Water
\.


--
-- Name: abilities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.abilities_id_seq', 1, false);


--
-- Name: contest_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.contest_types_id_seq', 1, false);


--
-- Name: items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.items_id_seq', 1, false);


--
-- Name: moves_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.moves_id_seq', 1, false);


--
-- Name: pokedex_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pokedex_id_seq', 1, false);


--
-- Name: pokemon_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pokemon_id_seq', 1, false);


--
-- Name: trades_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.trades_id_seq', 1, false);


--
-- Name: trainers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.trainers_id_seq', 1, false);


--
-- Name: types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.types_id_seq', 1, false);


--
-- Name: abilities abilities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.abilities
    ADD CONSTRAINT abilities_pkey PRIMARY KEY (id);


--
-- Name: contest_types contest_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contest_types
    ADD CONSTRAINT contest_types_pkey PRIMARY KEY (id);


--
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: moves moves_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moves
    ADD CONSTRAINT moves_pkey PRIMARY KEY (id);


--
-- Name: pokedex pokedex_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pokedex
    ADD CONSTRAINT pokedex_pkey PRIMARY KEY (id);


--
-- Name: pokemon pokemon_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pokemon
    ADD CONSTRAINT pokemon_pkey PRIMARY KEY (id);


--
-- Name: trades trades_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trades
    ADD CONSTRAINT trades_pkey PRIMARY KEY (id);


--
-- Name: trainers trainers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trainers
    ADD CONSTRAINT trainers_pkey PRIMARY KEY (id);


--
-- Name: types types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.types
    ADD CONSTRAINT types_pkey PRIMARY KEY (id);


--
-- Name: pokemon stats_on_level_up; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER stats_on_level_up BEFORE UPDATE OF level ON public.pokemon FOR EACH ROW WHEN ((old.level < new.level)) EXECUTE FUNCTION public.increase_stats_on_level_up();


--
-- Name: trades trade_update_pokemon_trainer; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trade_update_pokemon_trainer AFTER INSERT ON public.trades FOR EACH ROW EXECUTE FUNCTION public.update_pokemon_trainer();


--
-- Name: moves moves_contest_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moves
    ADD CONSTRAINT moves_contest_type_fkey FOREIGN KEY (contest_type) REFERENCES public.contest_types(id);


--
-- Name: moves moves_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moves
    ADD CONSTRAINT moves_type_fkey FOREIGN KEY (type) REFERENCES public.types(id);


--
-- Name: pokedex pokedex_ability_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pokedex
    ADD CONSTRAINT pokedex_ability_fkey FOREIGN KEY (ability) REFERENCES public.abilities(id);


--
-- Name: pokedex pokedex_type1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pokedex
    ADD CONSTRAINT pokedex_type1_fkey FOREIGN KEY (type1) REFERENCES public.types(id);


--
-- Name: pokedex pokedex_type2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pokedex
    ADD CONSTRAINT pokedex_type2_fkey FOREIGN KEY (type2) REFERENCES public.types(id);


--
-- Name: pokemon pokemon_item_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pokemon
    ADD CONSTRAINT pokemon_item_fkey FOREIGN KEY (item) REFERENCES public.items(id);


--
-- Name: pokemon pokemon_move1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pokemon
    ADD CONSTRAINT pokemon_move1_fkey FOREIGN KEY (move1) REFERENCES public.moves(id);


--
-- Name: pokemon pokemon_move2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pokemon
    ADD CONSTRAINT pokemon_move2_fkey FOREIGN KEY (move2) REFERENCES public.moves(id);


--
-- Name: pokemon pokemon_move3_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pokemon
    ADD CONSTRAINT pokemon_move3_fkey FOREIGN KEY (move3) REFERENCES public.moves(id);


--
-- Name: pokemon pokemon_move4_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pokemon
    ADD CONSTRAINT pokemon_move4_fkey FOREIGN KEY (move4) REFERENCES public.moves(id);


--
-- Name: pokemon pokemon_original_trainer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pokemon
    ADD CONSTRAINT pokemon_original_trainer_fkey FOREIGN KEY (original_trainer) REFERENCES public.trainers(id);


--
-- Name: pokemon pokemon_pokedex_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pokemon
    ADD CONSTRAINT pokemon_pokedex_id_fkey FOREIGN KEY (pokedex_id) REFERENCES public.pokedex(id);


--
-- Name: pokemon pokemon_trainer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pokemon
    ADD CONSTRAINT pokemon_trainer_fkey FOREIGN KEY (trainer) REFERENCES public.trainers(id);


--
-- Name: trades trades_pokemon_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trades
    ADD CONSTRAINT trades_pokemon_id_fkey FOREIGN KEY (pokemon_id) REFERENCES public.pokemon(id);


--
-- Name: trades trades_trainer_from_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trades
    ADD CONSTRAINT trades_trainer_from_fkey FOREIGN KEY (trainer_from) REFERENCES public.trainers(id);


--
-- Name: trades trades_trainer_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trades
    ADD CONSTRAINT trades_trainer_to_fkey FOREIGN KEY (trainer_to) REFERENCES public.trainers(id);


--
-- PostgreSQL database dump complete
--

