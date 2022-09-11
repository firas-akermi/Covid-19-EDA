SELECT *
FROM
Portfolio..CovidDeaths  
WHERE continent is not null

SELECT     
date,location, total_cases,new_cases,total_deaths,population
FROM
Portfolio..CovidDeaths
WHERE continent is not null
ORDER BY location

-- Looking at total cases vs total deaths in France
SELECT     
date,location, total_cases,total_deaths,(total_deaths/total_cases) as cases_death_ratio
FROM
Portfolio..CovidDeaths
WHERE location = 'France' AND total_deaths is not NULL and continent is not null
ORDER BY date

-- Looking at death percentage in France caused by covid19 in the overall population

SELECT     
date,continent,location,total_deaths,population,(total_deaths/population)*100 as death_percentage
FROM
Portfolio..CovidDeaths
WHERE location = 'France' AND total_deaths is not NULL AND continent is not null
ORDER BY date DESC

--Looking at total cases percentage in the overall popoulation 
SELECT     
date,location,cast(total_cases as int)as total_cases,population,(cast(total_cases as int)/population)*100 as infection_percentage
FROM
Portfolio..CovidDeaths
WHERE continent is not null
ORDER BY location

--Looking at countries with highest infection rate

SELECT 
date,location,Max(total_cases) as HighestInfectionNumber,population,Max(total_cases/population)*100 as Maximum_infection_rate
FROM
Portfolio..CovidDeaths
WHERE continent is not null
GROUP BY location, population, date
ORDER BY  Maximum_infection_rate DESC
--France is number 17 in the list

--Looking at countries with highest death rate

SELECT 
location,Max(cast (total_deaths as int)) as HighestDeathNumber,population,Max(cast (total_deaths as int)/population)*100 as Maximum_death_rate
FROM
Portfolio..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY  Maximum_death_rate DESC
--France is number 22 in the list

-- Looking at Death count by continent
SELECT 
continent,Max(cast (total_deaths as int)) as MaximumDeathCountPerContinent
FROM
Portfolio..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY   MaximumDeathCountPerContinent DESC

--Looking at global number
SELECT 
SUM(new_cases) as total_cases_in_the_world,SUM(cast(new_deaths as int)) as total_deaths_in_the_world,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage_in_the_world
FROM
Portfolio..CovidDeaths
WHERE continent is not null

--Looking at total populations vs vacctination
WITH VACCIN_POP (continent,location,date,population,new_vaccinations,RollingVaccinationNumber)
as
 (
 SELECT death.continent, death.location, death.date, death.population, vaccin.new_vaccinations,
 SUM(CONVERT(int,vaccin.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location,death.date)
 as RollingVaccinationNumber
 FROM Portfolio..CovidDeaths death
	 INNER JOIN Portfolio..CovidVaccinations vaccin
	 ON death.location=vaccin.location
	 AND death.date = vaccin.date
WHERE death.continent is not null
)
SELECT *, (RollingVaccinationNumber/population)*100 as PercentageOfVaccinatedPopulation
FROM VACCIN_POP

-- Looking at deaths vs hospital beds per thousand people
DROP TABLE if exists BedsVsDeaths
CREATE TABLE BedsVsDeaths(
					location nvarchar(255),
					total_deaths numeric,
					hospital_beds_per_thousand numeric)
INSERT INTO BedsVsDeaths
SELECT location, SUM(CAST(new_deaths as int)) AS total_deaths, hospital_beds_per_thousand
FROM Portfolio..CovidDeaths
WHERE continent is not null
Group by location,hospital_beds_per_thousand
ORDER BY total_deaths desc
Select * From BedsVsDeaths
