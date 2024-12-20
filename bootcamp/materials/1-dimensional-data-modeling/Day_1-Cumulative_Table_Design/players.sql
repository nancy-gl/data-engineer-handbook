
--DROP TABLE IF EXISTS players;

CREATE TABLE players (
    player_name text,
    height text,
    college text,
    country text,
    draft_year text,
    draft_round text,
    draft_number text,
    season_stats SEASON_STATS[],
    scoring_class scoring_class,
    year_since_last_season INTEGER,
    current_season INTEGER,
    primary key (player_name, current_season)
)