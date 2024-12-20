/*
 Cumulative table generation query: Write a query that populates the actors table one year at a time.
 */
INSERT INTO actors
WITH lastyear AS (
    select *
    from actors
    where current_year = 2000
       --and actor_name =  'Jackie Chan'  
),
thisyear AS (
    select *
    from actor_films
    where year = 2001
      --and actor = 'Jackie Chan' 
)
SELECT DISTINCT
    COALESCE(ty.actor, ly.actor_name) as actor,
    CASE
        WHEN ly.film IS NULL THEN ARRAY_AGG(
            ROW(ty.film, ty.votes, ty.rating, ty.filmid)::films
        ) OVER(
            partition by actor, year
        )
        WHEN ty.film IS NOT NULL THEN ly.film || ARRAY_AGG(
            ROW(ty.film, ty.votes, ty.rating, ty.filmid)::films
        ) OVER(
            partition by actor, year
        )
        ELSE ly.film
    END as film,
    CASE
        WHEN ty.rating IS NOT NULL THEN 
            CASE
                WHEN avg(ty.rating) over(partition by actor, year) > 8 THEN 'star'
                WHEN avg(ty.rating) over(partition by actor, year) > 7 AND avg(ty.rating) over(partition by actor, year) <= 8 THEN 'good'
                WHEN avg(ty.rating) over(partition by actor, year) > 6 AND avg(ty.rating) over(partition by actor, year) <= 7 THEN 'average'
                else 'bad'
            END::quality_class
        ELSE ly.quality_class
    END AS quality_class,
    COALESCE(ty.year, ly.current_year + 1) as current_year,
    CASE
        WHEN ty.year is not null THEN True
        ELSE False
    END AS is_active
   -- , *
FROM thisyear ty
    FULL OUTER JOIN lastyear ly ON ty.actor = ly.actor_name