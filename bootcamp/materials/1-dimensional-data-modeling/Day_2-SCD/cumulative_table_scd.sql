-- next way of doing the same from players_scd to see the changed data
-- CREATE type scd_type as(
--     scoring_class scoring_class,
--     is_active BOOLEAN,
--     start_season INTEGER,
--     end_season INTEGER
-- );
WITH last_season_scd AS (
    SELECT *
    FROM players_scd
    WHERE current_season = 2021
        AND end_season = 2021
),
historical_scd AS(
    SELECT player_name,
        scoring_class,
        is_active,
        start_season,
        end_season
    FROM players_scd
    WHERE current_season = 2021
        AND end_season < 2021
),
this_season_data AS (
    SELECT *
    FROM players
    WHERE current_season = 2022
),
unchanged_records AS(
    SELECT ts.player_name,
        ts.scoring_class,
        ts.is_active,
        ls.start_season,
        ts.current_season as end_season
    FROM this_season_data ts
        JOIN last_season_scd ls ON ls.player_name = ts.player_name
    WHERE ts.scoring_class = ls.scoring_class
        AND ts.is_active = ls.is_active
),
changed_records AS(
    SELECT ts.player_name,
        unnest(
            ARRAY [
            row(
                ls.scoring_class,
                ls.is_active,
                ls.start_season,
                ls.end_season
            )::scd_type,
            row(
                ts.scoring_class,
                ts.is_active,
                ts.current_season,
                ts.current_season
            )::scd_type
               ]
        ) as records
    FROM this_season_data ts
        LEFT JOIN last_season_scd ls ON ls.player_name = ts.player_name
    WHERE (
            ts.scoring_class <> ls.scoring_class -- assumption is that scoring_class and is_active is not null
            OR ts.is_active <> ls.is_active   
        )
),
unnested_changed_records AS( 
    SELECT player_name,
    (records::scd_type).scoring_class,
    (records::scd_type).is_active,
    (records::scd_type).start_season,
    (records::scd_type).end_season
    FROM changed_records
),
new_records AS( 
    SELECT ts.player_name,
        ts.scoring_class,
        ts.is_active,
        ts.current_season as start_season,
        ts.current_season as end_season 
    FROM this_season_data ts
    LEFT JOIN last_season_scd ls 
    ON ts.player_name = ls.player_name
    WHERE ls.player_name is null
)
SELECT * FROM historical_scd
union all
SELECT * FROM unchanged_records
union all
SELECT * FROM unnested_changed_records
union all
SELECT * FROM new_records
