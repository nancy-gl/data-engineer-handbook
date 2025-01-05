with actors as (
    select actor,
        year,
        --row_number() OVER(PARTITION BY year) as rownum,
        ROW(film, votes, rating, filmid)::films as films,
        avg(rating) over(partition by year) as avg_rating,
        CASE
            WHEN rating IS NOT NULL THEN
                CASE WHEN rating > 8 THEN 'star'
                    WHEN rating > 7 AND rating <= 8 THEN 'good'
                    WHEN rating > 6  AND rating <= 7 THEN 'average'
                    else 'bad'
                END::quality_class
        END AS quality_class,
        CASE 
            WHEN year = DATE_PART('YEAR', CURRENT_DATE) THEN 1 
            ELSE 0
        END AS is_active
    From actor_films
    where actor = 'Jackie Chan' 
)
select 
    actor, year
    , films
   -- , ARRAY_AGG(films) OVER(partition by year) as aggfilms
    , ARRAY_AGG(films) OVER(partition by actor , year) as actoragg
   -- avg_rating
    -- , ARRAY_AGG(quality_class) OVER(partition by year) as quality_class
    -- , is_active
from actors
