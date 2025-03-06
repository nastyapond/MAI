SET datestyle TO 'ISO, DMY';

-- ТАБЛИЦЫ
-- Типы
DROP TABLE IF EXISTS types CASCADE;
CREATE TABLE types (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL CHECK (trim(name) <> '')
);

-- Типы 2
DROP TABLE IF EXISTS contest_types CASCADE;
CREATE TABLE contest_types (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL CHECK (trim(name) <> '')
);

-- Способности
DROP TABLE IF EXISTS abilities CASCADE;
CREATE TABLE abilities (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL CHECK (trim(name) <> ''),
    description TEXT
);

-- Движения
DROP TABLE IF EXISTS moves CASCADE;
CREATE TABLE moves (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL CHECK (trim(name) <> ''),
    type BIGINT REFERENCES types(id),
    contest_type BIGINT REFERENCES contest_types(id),
    power BIGINT,
    accuracy BIGINT,
    pp_cost BIGINT,
    description TEXT
);

-- Предметы
DROP TABLE IF EXISTS items CASCADE;
CREATE TABLE items (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL CHECK (trim(name) <> ''),
    description TEXT
);

-- Тренеры
DROP TABLE IF EXISTS trainers CASCADE;
CREATE TABLE trainers (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL CHECK (trim(name) <> '')
);

-- Покедекс
DROP TABLE IF EXISTS pokedex CASCADE;
CREATE TABLE pokedex (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL CHECK (trim(name) <> ''),
    type1 BIGINT REFERENCES types(id) NOT NULL,
    type2 BIGINT REFERENCES types(id),
    ability BIGINT REFERENCES abilities(id) NOT NULL
);

-- Покемоны
DROP TABLE IF EXISTS pokemon CASCADE;
CREATE TABLE pokemon (
    id SERIAL PRIMARY KEY,
    name TEXT,
    pokedex_id BIGINT REFERENCES pokedex(id),
    gender TEXT CHECK (gender IN ('male', 'female') OR gender IS NULL),
    level NUMERIC( 3 ) NOT NULL CHECK ( level >= 0 AND level <= 100 ),

    move1 BIGINT REFERENCES moves(id) NOT NULL,
    move2 BIGINT REFERENCES moves(id),
    move3 BIGINT REFERENCES moves(id),
    move4 BIGINT REFERENCES moves(id),

    trainer BIGINT REFERENCES trainers(id),
    original_trainer BIGINT REFERENCES trainers(id),

    item BIGINT REFERENCES items(id),

    HP BIGINT NOT NULL DEFAULT 1,
    attack BIGINT NOT NULL DEFAULT 1,
    defense BIGINT NOT NULL DEFAULT 1,
    sp_atk BIGINT NOT NULL DEFAULT 1,
    sp_def BIGINT NOT NULL DEFAULT 1,
    speed BIGINT NOT NULL DEFAULT 1
);

ALTER TABLE pokemon
ADD CONSTRAINT unique_moves CHECK (
    move1 <> move2 AND
    move1 <> move3 AND
    move1 <> move4 AND
    move2 <> move3 AND
    move2 <> move4 AND
    move3 <> move4
);

-- Обмены
DROP TABLE IF EXISTS trades CASCADE;
CREATE TABLE trades (
    id SERIAL PRIMARY KEY,
    trainer_from BIGINT REFERENCES trainers(id),
    trainer_to BIGINT REFERENCES trainers(id),
    pokemon_id BIGINT REFERENCES pokemon(id),
    trade_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ТРИГГЕРЫ
-- Триггер+функция на таблицу trades
CREATE OR REPLACE FUNCTION update_pokemon_trainer()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE pokemon
    SET trainer = NEW.trainer_to
    WHERE id = NEW.pokemon_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trade_update_pokemon_trainer ON trades;
CREATE TRIGGER trade_update_pokemon_trainer
    AFTER INSERT ON trades
    FOR EACH ROW
    EXECUTE FUNCTION update_pokemon_trainer();

-- Триггер+функция для изменения статистик при увеличении уровня
CREATE OR REPLACE FUNCTION increase_stats_on_level_up()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS stats_on_level_up ON pokemon;
CREATE TRIGGER stats_on_level_up
    BEFORE UPDATE OF level ON pokemon
    FOR EACH ROW
    WHEN (OLD.level < NEW.level) -- Увеличение уровня
    EXECUTE FUNCTION increase_stats_on_level_up();

-- ПРОЦЕДУРЫ БЕЗ ТРИГГЕРОВ
-- Процедура для удаления покемонов без тренера
CREATE OR REPLACE PROCEDURE delete_unowned_pokemon()
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM pokemon
    WHERE trainer IS NULL;
END;
$$;

-- Процедура для подсчёта покемонов у определённого тренера
CREATE OR REPLACE FUNCTION count_pokemon_for_trainer(trainer_id BIGINT)
RETURNS BIGINT
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

-- Процедура для сброса всех характеристик покемона
CREATE OR REPLACE PROCEDURE reset_pokemon_stats(pokemon_id BIGINT)
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

-- ПРЕДСТАВЛЕНИЯ
-- Представление базовой информации о покемоне
CREATE OR REPLACE VIEW pokemon_info_view AS
SELECT
    p.id AS pokemon_id,
    p.name AS pokemon_name,
    pd.name AS species_name,
    CASE
        WHEN p.gender = 'male' THEN 'Male'
        WHEN p.gender = 'female' THEN 'Female'
        ELSE 'None'
    END AS gender,
    p.level AS current_level,
    t1.name AS type1,
    t2.name AS type2,
    ot.name AS original_trainer_name,
    p.original_trainer AS original_trainer_id,
    ct.name AS current_trainer_name,
    p.trainer AS current_trainer_id
FROM
    pokemon p
    JOIN pokedex pd ON p.pokedex_id = pd.id
    LEFT JOIN types t1 ON pd.type1 = t1.id
    LEFT JOIN types t2 ON pd.type2 = t2.id
    LEFT JOIN trainers ot ON p.original_trainer = ot.id
    LEFT JOIN trainers ct ON p.trainer = ct.id;


-- Представление навыков
CREATE OR REPLACE VIEW skills_view AS
SELECT
    p.id AS pokemon_id,
    p.name AS pokemon_name,
    pd.name AS species_name,
    t1.name AS type1,
    t2.name AS type2,
    a.name AS ability,
    i.name AS held_item,
    p.level,
    p.HP,
    p.attack,
    p.defense,
    p.sp_atk,
    p.sp_def,
    p.speed
FROM
    pokemon p
    JOIN pokedex pd ON p.pokedex_id = pd.id
    LEFT JOIN types t1 ON pd.type1 = t1.id
    LEFT JOIN types t2 ON pd.type2 = t2.id
    JOIN abilities a ON pd.ability = a.id
    LEFT JOIN items i ON p.item = i.id;

-- Представление движений в битвах
CREATE OR REPLACE VIEW battle_view AS
SELECT
    p.id AS pokemon_id,
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
FROM
    pokemon p
    LEFT JOIN moves m1 ON p.move1 = m1.id
    LEFT JOIN types t1 ON m1.type = t1.id
    LEFT JOIN moves m2 ON p.move2 = m2.id
    LEFT JOIN types t2 ON m2.type = t2.id
    LEFT JOIN moves m3 ON p.move3 = m3.id
    LEFT JOIN types t3 ON m3.type = t3.id
    LEFT JOIN moves m4 ON p.move4 = m4.id
    LEFT JOIN types t4 ON m4.type = t4.id;

-- Представление движений в контестах
CREATE OR REPLACE VIEW contest_view AS
SELECT
    p.id AS pokemon_id,
    p.name AS pokemon_name,
    m1.name AS move1,
    ct1.name AS move1_contest_type,
    m2.name AS move2,
    ct2.name AS move2_contest_type,
    m3.name AS move3,
    ct3.name AS move3_contest_type,
    m4.name AS move4,
    ct4.name AS move4_contest_type
FROM
    pokemon p
    LEFT JOIN moves m1 ON p.move1 = m1.id
    LEFT JOIN contest_types ct1 ON m1.contest_type = ct1.id
    LEFT JOIN moves m2 ON p.move2 = m2.id
    LEFT JOIN contest_types ct2 ON m2.contest_type = ct2.id
    LEFT JOIN moves m3 ON p.move3 = m3.id
    LEFT JOIN contest_types ct3 ON m3.contest_type = ct3.id
    LEFT JOIN moves m4 ON p.move4 = m4.id
    LEFT JOIN contest_types ct4 ON m4.contest_type = ct4.id;
