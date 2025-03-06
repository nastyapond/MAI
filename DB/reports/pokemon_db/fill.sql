INSERT INTO types (id, name) VALUES
(1, 'Bug'),
(2, 'Dark'),
(3, 'Dragon'),
(4, 'Electric'),
(5, 'Fairy'),
(6, 'Fighting'),
(7, 'Fire'),
(8, 'Flying'),
(9, 'Ghost'),
(10, 'Grass'),
(11, 'Ground'),
(12, 'Ice'),
(13, 'Normal'),
(14, 'Poison'),
(15, 'Psychic'),
(16, 'Rock'),
(17, 'Steel'),
(18, 'Water');

INSERT INTO contest_types (id, name) VALUES
(1, 'Beauty'),
(2, 'Cool'),
(3, 'Cute'),
(4, 'Smart'),
(5, 'Tough');

INSERT INTO abilities (id, name, description) VALUES
(1, 'Overgrow', 'Boosts the power of Grass-type moves when the Pokémon is in trouble.'),
(2, 'Blaze', 'Boosts the power of Fire-type moves when the Pokémon is in trouble.'),
(3, 'Torrent', 'Boosts the power of Water-type moves when the Pokémon is in trouble.'),
(4, 'Static', 'May cause paralysis if hit.'),
(5, 'Levitate', 'Gives full immunity to all Ground-type moves.');

INSERT INTO pokedex (id, name, type1, type2, ability) VALUES
(1, 'Bulbasaur', 10, 14, 1),
(2, 'Ivysaur', 10, 14, 1),
(3, 'Venusaur', 10, 14, 1),
(4, 'Charmander', 7, NULL, 2),
(5, 'Charmeleon', 7, NULL, 2),
(6, 'Charizard', 7, 8, 2),
(7, 'Squirtle', 18, NULL, 3),
(8, 'Wartortle', 18, NULL, 3),
(9, 'Blastoise', 18, NULL, 3),
(25, 'Pikachu', 4, NULL, 4),
(26, 'Raichu', 4, NULL, 4);


INSERT INTO trainers (id, name) VALUES
(1, 'Ash'),
(2, 'Misty'),
(3, 'Brock'),
(4, 'May'),
(5, 'Max'),
(6, 'Professor Oak'),
(7, 'Team Rocket');

INSERT INTO moves (id, name, type, contest_type, power, accuracy, pp_cost, description) VALUES
(1, 'Tackle', 13, 5, 40, 100, 35, 'A physical attack in which the user charges and slams into the target.'),
(2, 'Thunder Shock', 4, 2, 40, 100, 30, 'A jolt of electricity is hurled at the target. This may also leave the target with paralysis.'),
(3, 'Ember', 7, 1, 40, 100, 25, 'The target is attacked with small flames. This may also leave the target with a burn.'),
(4, 'Water Gun', 18, 4, 40, 100, 25, 'The target is blasted with a forceful shot of water.'),
(5, 'Vine Whip', 10, 5, 45, 100, 25, 'The target is struck with slender, whiplike vines to inflict damage.'),
(6, 'Quick Attack', 13, 2, 40, 100, 30, 'The user lunges at the target at a speed that makes it almost invisible. This move always goes first.'),
(7, 'Growl', 13, 3, NULL, 100, 40, 'The user growls in an endearing way, making opposing Pokémon less wary.'),
(8, 'Tail Whip', 13, 3, NULL, 100, 30, 'The user wags its tail cutely, making opposing Pokémon less wary and lowering their Defense stat.'),
(9, 'Scratch', 13, 2, 40, 100, 35, 'Hard, pointed, and sharp claws rake the target to inflict damage.'),
(10, 'Bubble', 18, 4, 40, 100, 30, 'A spray of bubbles is forcefully ejected at the opposing Pokémon. This may also lower their Speed stat.');

INSERT INTO pokemon (id, name, pokedex_id, gender, level, move1, move2, move3, move4, trainer, original_trainer, item, HP, attack, defense, sp_atk, sp_def, speed) VALUES
(1, 'Bulbasaur', 1, 'male', 5, 5, 7, NULL, NULL, 1, 6, NULL, 45, 49, 49, 65, 65, 45),
(2, 'Ivysaur', 2, 'male', 16, 5, 7, 8, NULL, 1, 6, NULL, 60, 62, 63, 80, 80, 60),
(3, 'Venusaur', 3, 'male', 32, 5, 7, 8, 6, 1, 6, NULL, 80, 82, 83, 100, 100, 80),
(4, 'Charmander', 4, 'male', 5, 3, 9, NULL, NULL, 3, 6, NULL, 39, 52, 43, 60, 50, 65),
(5, 'Charmeleon', 5, 'male', 16, 3, 9, 7, NULL, 3, 6, NULL, 58, 64, 58, 80, 65, 80),
(6, 'Charizard', 6, 'male', 36, 3, 9, 7, 1, 1, 6, NULL, 78, 84, 78, 109, 85, 100),
(7, 'Squirtle', 7, 'female', 5, 4, 10, NULL, NULL, 2, 6, NULL, 44, 48, 65, 50, 64, 43),
(8, 'Wartortle', 8, 'female', 16, 4, 10, 7, NULL, 2, 6, NULL, 59, 63, 80, 65, 80, 58),
(9, 'Blastoise', 9, 'female', 36, 4, 10, 7, 8, 1, 6, NULL, 79, 83, 100, 85, 105, 78),
(10, 'Pikachu', 25, 'male', 10, 2, 6, 8, NULL, 1, 6, NULL, 35, 55, 40, 50, 50, 90),
(11, 'Raichu', 26, 'male', 25, 2, 6, 8, NULL, 1, 6, NULL, 60, 90, 55, 90, 80, 110);

INSERT INTO trades (id, trainer_from, trainer_to, pokemon_id, trade_date) VALUES
(1, 1, 2, 10, '2024-11-01 14:30:00'), -- Ash передал Pikachu тренеру Misty
(2, 2, 3, 7, '2024-11-03 10:15:00'), -- Misty передала Squirtle тренеру Brock
(3, 3, 1, 4, '2024-11-05 17:45:00'), -- Brock передал Charmander обратно Ash
(4, 1, 4, 6, '2024-11-07 09:00:00'), -- Ash передал Charizard тренеру May
(5, 4, 5, 11, '2024-11-10 13:20:00'); -- May передала Raichu тренеру Dawn
