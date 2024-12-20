-- Create cumulative table design 
INSERT INTO players
with yesterday AS (
    select *
    from players
    where current_season = 2000 --2000 --1999 --1998 --1997 --1996 --1995
),
today AS (
    SELECT *
    FROM player_seasons
    WHERE season = 2001 --2001 --2000 --1999 --1998 --1997 --1996
)
select COALESCE(t.player_name, y.player_name) AS player_name, 
    COALESCE(t.height, y.height) AS height,
    COALESCE(t.college, y.college) AS college,
    COALESCE(t.country, y.country) AS country,
    COALESCE(t.draft_year, y.draft_year) AS draft_year,
    COALESCE(t.draft_round, y.draft_round) AS draft_round,
    COALESCE(t.draft_number, y.draft_number) AS draft_number,
    CASE
        WHEN y.season_stats IS NULL THEN ARRAY[ROW(t.season, t.gp, t.pts, t.reb, t.ast)::season_stats]
        WHEN t.season IS NOT NULL THEN y.season_stats || ARRAY [ROW(t.season, t.gp, t.pts, t.reb, t.ast)::season_stats]
        ELSE y.season_stats
    END as season_stats,
    CASE
        WHEN t.season IS NOT NULL THEN
        CASE WHEN t.pts > 20 THEN 'star'
            WHEN t.pts > 15 THEN 'good'
            WHEN t.pts > 10 then 'average'
            else 'bad'
        END::scoring_class
        ELSE y.scoring_class
    END AS scoring_class,
    CASE
        WHEN t.season IS NOT NULL THEN 0
        ELSE y.year_since_last_season + 1
    END as year_since_last_season,
    COALESCE(t.season, y.current_season+1) AS current_season
from today t
    FULL OUTER JOIN yesterday y ON t.player_name = y.player_name