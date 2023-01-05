
set @@global.sql_mode := replace(@@global.sql_mode, 'ONLY_FULL_GROUP_BY', '');

SELECT location, date, total_cases, new_cases, total_deaths, population  
from CovidDeaths cd 
order by 1, 2; 

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if COVID-19 is contracted in your country 

SELECT 
location, 
date, 
total_cases, 
total_deaths, 
total_deaths/total_cases *100 as DeathsPercentage 
from CovidDeaths cd 
-- where location like '%Kingdom%'
order by 1, 2 desc;


-- LOOKING AT TOTAL CASE VS POPULATION 
-- Shows what percentage of population has COVID-19 on a given day

SELECT 
location, 
date, 
population,
total_cases,
total_cases /population *100 as Population_infection_Percentage 
from CovidDeaths cd 
-- where location like '%Kingdom%'
order by 1, 2 desc;

-- Looking at Countries/Continents with the Highest Infection Rate Compared to Population

SELECT 
continent,
MAX(total_cases) as HighestInfectionCount,
MAX(total_cases /population) *100 as Population_infection_Percentage 
from CovidDeaths cd 
WHERE continent !=''
group by continent
ORDER BY population_infection_Percentage DESC ;


-- Looking at Continents with Highest COVID-19 Deaths
  
SELECT 
location,
MAX(total_deaths) as TotalDeathCount
from CovidDeaths cd 
WHERE continent =''
AND location not in ('World', 'European Union', 'International')
group by location 
ORDER BY TotalDeathCount DESC ;




-- 	COVID-19 Numbers from a Global Perspective 

SELECT MAX(total_cases), MAX(total_deaths), MAX(total_deaths)/ MAX(total_cases) *100 as DeathsPercentage
FROM CovidDeaths cd 
WHERE location  = 'World'
 

-- Looking at Total Population Versus Covid-19 Vaccination Numbers 



SELECT 
cd.continent, 
cd.location, 
cd.date, 
cd.population, 
cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as RollingTotalVaccinations
FROM CovidDeaths cd 
JOIN CovidVaccinations cv ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent != ''
order by 2,3


-- USING A COMMON TABLE EXPRESSION (CTE)

WITH PopVac 
AS 
(
SELECT 
cd.continent, 
cd.location, 
cd.date, 
cd.population, 
cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as RollingTotalVaccinations
FROM CovidDeaths cd 
JOIN CovidVaccinations cv ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent != ''
order by 2,3
)
SELECT location, population, max(RollingTotalVaccinations), max(RollingTotalVaccinations/ population) * 100 as Vacc_population
FROM PopVac
GROUP BY location, population 


-- CREATING VIEW TO STORE DATA FOR SUBSEQUENT VISUALISATIONS

--   VIEW 1 
Drop view if exists DeathsFromCases;
Create View DeathsFromCases as
SELECT 
SUM(new_cases) as total_cases, 
SUM(new_deaths) as total_deaths, 
SUM(new_cases)/ SUM(new_deaths) *100 as DeathsPercentage
FROM CovidDeaths cd 
WHERE continent != ''
-- GROUP BY date 
order by 1, 2;  



-- VIEW 2 
-- Drop view  if exists CovidDeathsbyContinent;
Create view CovidDeathsbyContinent as 
SELECT 
location,
MAX(total_deaths) as TotalDeathCount
from CovidDeaths cd 
WHERE continent =''
AND location not in ('World', 'European Union', 'International')
group by location 
ORDER BY TotalDeathCount DESC ;



-- VIEW 3 
-- Drop view  if exists CovidDeathsbyLocation;
Create View CovidDeathsbyLocation as
SELECT 
location,
population,
MAX(total_cases) as HighestInfectionCount,
MAX(total_cases /population) *100 as Population_infection_Percentage 
from CovidDeaths cd 
WHERE continent !=''
group by location, population
ORDER BY population_infection_Percentage DESC ;


-- VIEW 4 
-- Drop view  if exists CovidDeathsbyLocationandDate;
Create View CovidDeathsbyLocationandDate as
SELECT 
location,
population,
date,
MAX(total_cases) as HighestInfectionCount,
MAX(total_cases /population) *100 as Population_infection_Percentage 
from CovidDeaths cd 
WHERE continent !=''
group by location, population, date
ORDER BY population_infection_Percentage DESC ;
