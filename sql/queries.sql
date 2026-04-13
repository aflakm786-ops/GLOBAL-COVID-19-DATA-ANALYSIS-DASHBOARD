
create database covid;
use  covid;

## TOP 10 AFFECTED COUNTRIES
select country ,max(confirmed) as total_cases
from covid group by country 
order by total_cases  desc
limit 10;


## TOP 10 RECOVERED COUNTRY
select country ,max(reacovery_rate) as recovered
from covid group by country 
order by recovered desc limit 10;

## TOP 10 DEATH MARKED COUNTRY
select country ,max(death_rate) as total_death
from covid group by country
order by total_death  desc limit 10;

## DAILY NEW CASES
select country ,date,confirmed,confirmed - lag(confirmed) over(partition by country order by date)
as  new_cases from covid;

##7-DAY MOVING AVG
select country ,date, avg(new_cases) over(partition by country order by date rows between 6 preceding and 
current row) as avg_cases_of_7days from covid;

##RANK COUNTRIES
select country, max(confirmed) as total_cases,
dense_rank() over( order by max(confirmed) desc) as rank_numb
from covid  group by country ;


##PEAK DAY PER COUNTRY
WITH daily_cases AS (
    SELECT country,date,
        confirmed - LAG(confirmed) OVER (PARTITION BY country ORDER BY date) AS peak_day
    FROM covid
)

SELECT country, date, peak_day
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY country ORDER BY peak_day DESC) AS rnk
    FROM daily_cases
) t
WHERE rnk = 1;


## GROWTH RATE
SELECT country,date,new_cases,
    (new_cases / LAG(new_cases) OVER (PARTITION BY country ORDER BY date)) * 100 AS growth_rate
FROM covid;

##RUNNING TOTAL
SELECT country,date,
SUM(new_cases) OVER (PARTITION BY country ORDER BY date) AS cumulative_cases
FROM covid;

## CONTINENT LEVEL ANALYSIS
select continent,max(totalcases)/max(population)*100 as total_case_rate
from world group by continent order by max(totalcases)/max(population)*100 desc limit 10;



select continent,max(totaldeaths) 
from world
group by continent order by  max(totaldeaths) desc limit 10;

ALTER table world rename COLUMN  `WHO Region` to who_region ;

select who_region ,max(totalrecovered) as recoverd
from world group by who_region  order by max(totalrecovered)  desc limit 10;


## CREATED SOME VIEWS
CREATE VIEW v_daily_cases AS
SELECT country,date,confirmed,
confirmed - LAG(confirmed) OVER (PARTITION BY country ORDER BY date) AS new_cases
FROM covid;


CREATE VIEW vw_country_summary AS
SELECT country,MAX(confirmed) AS total_cases,
MAX(deaths) AS total_deaths,
MAX(recovered) AS total_recovered
FROM covid
GROUP BY country;

select * from v_daily_cases;
select * from vw_country_summary;
