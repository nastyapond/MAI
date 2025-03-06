-- Сортировка покемонов по уровню у выбранного тренера
SELECT
    id AS pokemon_id,
    name AS pokemon_name,
    trainer AS trainer_id,
    level,
    HP,
    attack,
    defense,
    sp_atk,
    sp_def,
    speed
FROM pokemon
WHERE trainer = 1
ORDER BY
    level DESC;

-- Сортировка по имени
SELECT
    id AS pokemon_id,
    name AS pokemon_name,
    level
FROM pokemon
ORDER BY name ASC;

-- Группировка с количеством покемонов в каждом типе
SELECT
    pd.type1 AS primary_type,
    t1.name AS type_name,
    COUNT(p.id) AS pokemon_count
FROM pokemon p
JOIN pokedex pd ON p.pokedex_id = pd.id
JOIN types t1 ON pd.type1 = t1.id
GROUP BY pd.type1, t1.name
ORDER BY t1.name ASC;

-- Использование представлений для анализа боевых характеристик
SELECT
    pokemon_id,
    pokemon_name,
    level,
    HP,
    attack,
    defense,
    sp_atk,
    sp_def,
    speed
FROM skills_view
WHERE level > 30 -- Покемоны с уровнем выше 30
ORDER BY level DESC; -- Сортировка по уровню

-- Обновление имени
UPDATE pokemon
SET name = 'Molniya x2'
WHERE id = 10;

-- Ранжирование в порядке ранга по общей силе
SELECT
    id AS pokemon_id,
    name AS pokemon_name,
    level,
    HP + attack + defense + sp_atk + sp_def + speed AS total_stats, -- Сумма характеристик
    RANK() OVER (ORDER BY total_stats DESC) AS rank -- Ранг по сумме характеристик
FROM pokemon
ORDER BY rank ASC;

SELECT * FROM battle_view;


WITH trainer_pokemon_counts AS (
    SELECT
        t.id AS trainer_id,
        t.name AS trainer_name,
        COUNT(DISTINCT p.pokedex_id) AS unique_pokemon_species_count
    FROM trainers t
    LEFT JOIN pokemon p ON t.id = p.trainer
    GROUP BY t.id, t.name
)
SELECT
    trainer_name,
    unique_pokemon_species_count
FROM trainer_pokemon_counts
ORDER BY unique_pokemon_species_count DESC;

