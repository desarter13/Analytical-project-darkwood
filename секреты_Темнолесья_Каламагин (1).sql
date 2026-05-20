/* Проект «Секреты Тёмнолесья»
 * Цель проекта: изучить влияние характеристик игроков и их игровых персонажей 
 * на покупку внутриигровой валюты «райские лепестки», а также оценить 
 * активность игроков при совершении внутриигровых покупок
 * 
 * Автор: Каламагин Евгений
 * Дата: 02.04.2026
*/

-- Часть 1. Исследовательский анализ данных
-- Задача 1. Исследование доли платящих игроков

-- 1.1. Доля платящих пользователей по всем данным:
-- Напишите ваш запрос здесь
SELECT
    COUNT(*) AS total_players,                  -- общее число игроков
    SUM(payer) AS paying_players,               -- сумма payer (1 = платящий, 0 = нет)
    AVG(payer) AS paying_part                 -- среднее = доля платящих
FROM fantasy.users;

/*
  Статистика игроков:
  total_players | paying_players | paying_part
  -------------------------------------------
  22214         | 3929           | 0.17687044206356351850
*/

-- 1.2. Доля платящих пользователей в разрезе расы персонажа:
-- Напишите ваш запрос здесь
SELECT
    r.race,                                     -- название расы
    SUM(u.payer) AS paying_players,              -- платящие игроки
    COUNT(*) AS total_players,                   -- все игроки
    AVG(u.payer) AS paying_share                -- доля платящих
FROM fantasy.users u
LEFT JOIN fantasy.race r ON u.race_id = r.race_id
GROUP BY r.race
ORDER BY paying_share DESC;
/*
  Таблица с данными о расах, платных и общих игроках, доле платных игроков:
  
  race           | paying_players | total_players | paying_share
  ------------------------------------------------------------
  Demon         | 238           | 1 229         | 0,1936533767
  Hobbit        | 659           | 3 648         | 0,1806469298
  Human         | 1 114         | 6 328         | 0,1760429836
  Northman      | 626           | 3 562         | 0,1757439641
  Orc           | 636           | 3 619         | 0,1757391545
  Angel         | 229           | 1 327         | 0,1725697061
  Elf           | 427           | 2 501         | 0,1707317073
*/
-- Задача 2. Исследование внутриигровых покупок
-- 2.1. Статистические показатели по полю amount:
-- Напишите ваш запрос здесь
SELECT
    COUNT(*) AS total_purchases,                 -- количество покупок
    SUM(amount) AS total_amount,                 -- сумма
    MIN(amount) AS min_amount,                   -- минимум
    MAX(amount) AS max_amount,                   -- максимум
    AVG(amount) AS avg_amount,                   -- среднее
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY amount) AS median_amount, -- медиана
    STDDEV(amount) AS stddev_amount              -- стандартное отклонение
FROM fantasy.events;
/*
  Статистика покупок:
  -----------------------------------------
  Показатель              | Значение
  -----------------------------------------
  total_purchases         | 1 307 678
  total_amount            | 686 615 040
  min_amount              | 0
  max_amount              | 486 615,1
  avg_amount              | 525,691 966 359
  median_amount           | 74,860 000 6104
  stddev_amount           | 2 517,345 444 4278
  -----------------------------------------
*/
-- 2.2: Аномальные нулевые покупки:
-- Напишите ваш запрос здесь
SELECT
    COUNT(*) FILTER (WHERE amount = 0) AS zero_purchases,  -- сколько нулевых
    COUNT(*) AS total_purchases,                           -- всего покупок
    COUNT(*) FILTER (WHERE amount = 0) * 1.0 / COUNT(*) AS zero_share -- доля
FROM fantasy.events;

/*
  Статистика покупок:
  -----------------------------------------
  Метрика               | Значение
  -----------------------------------------
  zero_purchases        | 907
  total_purchases       | 1 307 678
  zero_share            | 0,0006935958 (0,06935958%)
*/
-- 2.3: Популярные эпические предметы:
-- Напишите ваш запрос здесь
-- Сначала считаем общее количество уникальных покупателей
WITH total_buyers AS (
    SELECT COUNT(DISTINCT id) AS total
    FROM fantasy.events
    WHERE amount > 0
)
SELECT
    i.game_items,
    COUNT(*) AS total_sales,
    COUNT(*) * 1.0 / SUM(COUNT(*)) OVER () AS sales_share,
    COUNT(DISTINCT e.id) * 1.0 / tb.total AS buyers_share
FROM fantasy.events e
LEFT JOIN fantasy.items i ON e.item_code = i.item_code
CROSS JOIN total_buyers tb
WHERE e.amount > 0
GROUP BY i.game_items, tb.total
ORDER BY total_sales DESC;
/*
  Статистика продаж игровых предметов
  ------------------------------------------------------------
  game_items               | total_sales | sales_share     | buyers_share
  ------------------------------------------------------------
  Book of Legends          | 1 004 516   | 0,7687008665    | 0,8841357309
  Bag of Holding           | 271 875     | 0,2080509898    | 0,86774942
  Necklace of Wisdom       | 13 828      | 0,0105818081    | 0,1179669374
  Gems of Insight          | 3 833       | 0,0029331842    | 0,0671403712
  Treasure Map             | 3 183       | 0,0024357749    | 0,0593822506
  Amulet of Protection     | 1 078       | 0,0008249341    | 0,0322650812
  Silver Flask             | 795         | 0,0006083698    | 0,0458961717
  Strength Elixir          | 580         | 0,0004438421    | 0,02399942
  Glowing Pendant         | 563         | 0,0004308329    | 0,0256670534
  Gauntlets of Might       | 514         | 0,0003933359    | 0,0203741299
  Sea Serpent Scale        | 458         | 0,0003504822    | 0,0042778422
  Ring of Wisdom           | 379         | 0,0002900279    | 0,0224767981
  Potion of Speed         | 375         | 0,0002869669    | 0,0167488399
  Magic Ornament          | 282         | 0,0002157991    | 0,0081931555
  Ring of Invisibility    | 252         | 0,0001928417    | 0,0133410673
  Magical Lantern         | 247         | 0,0001890155    | 0,0073955916
  Herbs for Potions       | 241         | 0,000184424     | 0,0107308585
  Potion of Acceleration  | 230         | 0,0001760064    | 0,0130510441
  Feather of Writing      | 222         | 0,0001698844    | 0,0111658933
  Enemy Traps             | 168         | 0,0001285612    | 0,0068155452
  Time Artifact           | 168         | 0,0001285612    | 0,0107308585
  Scroll of Magic         | 162         | 0,0001239697    | 0,0084831787
  Monster Compendium      | 151         | 0,000115552     | 0,0100058005
  Water of Life           | 142         | 0,0001086648    | 0,0088457077
  Pegasus Feather         | 138         | 0,0001056038    | 0,0018851508
  Trap Chest             | 137         | 0,0001048386    | 0,0087006961
  Magic Key              | 127         | 0,0000971861    | 0,0058729698
  Dungeon Map            | 108         | 0,0000826465    | 0,0053654292
  Runes of Power          | 106         | 0,000081116     | 0,0052929234
  ------------------------------------------------------------
*/

-- Часть 2. Решение ad hoc-задачи
-- Задача: Зависимость активности игроков от расы персонажа:
-- Напишите ваш запрос здесь
-- 1. Сколько всего игроков по расам
WITH total_players AS (
    SELECT
        r.race,
        COUNT(*) AS total_players
    FROM fantasy.users u
    LEFT JOIN fantasy.race r ON u.race_id = r.race_id
    GROUP BY r.race
),
-- 2. Игроки, которые совершали покупки (amount > 0)
buyers AS (
    SELECT DISTINCT
        u.id,
        r.race,
        u.payer
    FROM fantasy.users u
    LEFT JOIN fantasy.race r ON u.race_id = r.race_id
    JOIN fantasy.events e ON u.id = e.id
    WHERE e.amount > 0
),
-- 3. Статистика по покупкам на игрока
WITH gamers_stat AS (
    SELECT race_id, COUNT(*) AS total_gamers
    FROM fantasy.users
    GROUP BY race_id
),
buyers_stat AS (
    SELECT 
        race_id, 
        COUNT(*) AS total_buyers, 
        AVG(payer::int) AS payer_buyers_share
    FROM fantasy.users u
    WHERE EXISTS (
        SELECT 1 
        FROM fantasy.events e 
        WHERE e.id = u.id AND e.amount > 0
    )
    GROUP BY race_id
),
orders_stat AS (
    SELECT 
        race_id, 
        COUNT(*) AS total_orders, 
        SUM(amount) AS total_amount
    FROM fantasy.events 
    JOIN fantasy.users USING(id)
    WHERE amount > 0
    GROUP BY race_id
)
SELECT
    race,
    total_gamers,
    total_buyers,
    total_buyers::real / NULLIF(total_gamers, 0) AS buyers_share,
    payer_buyers_share,
    total_orders::real / NULLIF(total_buyers, 0) AS orders_per_buyer,
    total_amount::real / NULLIF(total_buyers, 0) AS total_amount_per_buyer,
    total_amount::real / NULLIF(total_orders, 0) AS avg_amount_per_buyer
FROM gamers_stat
LEFT JOIN buyers_stat USING(race_id)
LEFT JOIN orders_stat USING(race_id)
JOIN fantasy.race USING(race_id);

/*
  Статистика по расам игроков:
  
 race       | total_gamers | total_buyers | buyers_share | payer_buyers_share | orders_per_buyer | total_amount_per_buyer | avg_amount_per_order
-----------+--------------+--------------+--------------+--------------------+------------------+------------------------+----------------------
Elf        | 2501         | 1543         | 0.61695      | 0.16267            | 78.79            | 53761.21               | 682.33
Northman   | 3562         | 2229         | 0.62577      | 0.18214            | 82.10            | 62519.03               | 761.48
Angel      | 1327         | 820          | 0.61794      | 0.16707            | 106.80           | 48664.66               | 455.64
Orc        | 3619         | 2276         | 0.62890      | 0.17399            | 81.74            | 41761.70               | 510.92
Hobbit     | 3648         | 2266         | 0.62116      | 0.17696            | 86.13            | 47621.58               | 552.91
Human      | 6328         | 3921         | 0.61963      | 0.18006            | 121.40           | 48933.71               | 403.07
Demon      | 1229         | 737          | 0.59967      | 0.19946            | 77.87            | 41194.50               | 529.02
*/
