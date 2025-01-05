--DROP TABLE IF EXISTS players_scd;

--TRUNCATE TABLE players_scd;

-- CREATE TABLE players_scd (
--     player_name text,
--     scoring_class scoring_class,
--     is_active BOOLEAN,
--     current_season INTEGER,
--     start_season INTEGER,
--     end_season INTEGER,
--     primary key (player_name, start_season)
-- )


-- not the best way to query table as below as LAG/window function
-- is slicing the data too many times and that can be expensive
-- and then an aggregation makes it more expensive query, prone to 
-- out of memory exception or skew, can be done still for dimensional data 
--INSERT into players_scd
with with_previous AS(
    select player_name,
        current_season,
        scoring_class,
        is_active,
        LAG(scoring_class, 1) OVER(
            PARTITION BY player_name
            ORDER BY current_season
        ) as previous_scoring_class,
        LAG(is_active, 1) OVER(
            PARTITION BY player_name
            ORDER BY current_season
        ) as previous_is_active
    from players
    where current_season <= 2021
),
change_indicator AS(
    SELECT *,
        CASE
            WHEN scoring_class <> previous_scoring_class THEN 1
            WHEN is_active <> previous_is_active THEN 1
            ELSE 0
        END as change_indicator
    FROM with_previous
),
with_streaks AS(
    select *,
        sum(change_indicator) OVER(
            PARTITION BY player_name
            ORDER BY current_season
        ) AS streak_identifier
    from change_indicator
)
SELECT player_name,
    scoring_class,
    is_active,
    2021 as current_season,
    min(current_season) as start_season,
    max(current_season) as end_season    
FROM with_streaks
GROUP BY player_name,
    streak_identifier,
    is_active,
    scoring_class
ORDER BY player_name