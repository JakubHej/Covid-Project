USE PortfolioProjectCovid;

SELECT location,date, total_cases,new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY location, date;

-- Total Cases vs Total Deaths in Poland

SELECT location,date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 2) AS DeathPercentage
FROM CovidDeaths
WHERE location like 'Poland'
ORDER BY location, date;

-- Total Cases vs Population in Poland
SELECT location,date, total_cases, population, ROUND((total_cases/population)*100, 2) AS Population_Infected_Percent
FROM CovidDeaths
WHERE location = 'Poland'
ORDER BY location, date;

-- Total Cases vs Population 
SELECT location,date, total_cases, population, ROUND((total_cases/population)*100, 2) AS  Population_Infected_Percent
FROM CovidDeaths
ORDER BY location, date;

--Death Count Worldwide

SELECT location, SUM(CAST(new_deaths AS INT)) AS Total_death_Count
FROM CovidDeaths
WHERE continent IS NULL
AND location NOT IN ('World', 'International', 'Europen Union')
GROUP BY location
ORDER BY Total_death_Count;

-- Countries with highest infection rate
SELECT location,date,population
,MAX(total_cases) AS Highest_Infection_Count
,ROUND(MAX((total_cases/population)*100), 2) AS  Population_Infected_Percent
FROM CovidDeaths
GROUP BY location,population,date
ORDER BY Population_Infected_Percent DESC;

-- Countries with highest death count per population

SELECT location
,MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count DESC;

-- Death count by continent
SELECT continent
,MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC;




--GLOBAL NUMBERS

-- Total New Stats month by month 

SELECT DATEPART(YEAR, date) AS Year
	,DATEPART(MONTH, date) AS Month
	,SUM(new_cases) AS Total_Cases
	,SUM(CAST (new_deaths AS INT)) AS Total_Deaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY DATEPART(MONTH, date),DATEPART(YEAR, date) 
ORDER BY Year, Month;


--CREATE VIEW TotalStaticMonthbyMonth FOR VISUALS

CREATE VIEW Total_Stats_Month 
AS SELECT DATEPART(YEAR, date) AS Year
	,DATEPART(MONTH, date) AS Month
	,SUM(new_cases) AS Total_Cases
	,SUM(CAST (new_deaths AS INT)) AS Total_Deaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY DATEPART(MONTH, date),DATEPART(YEAR, date) 
;





--  Number Cases, Deaths, Death_Percentage

SELECT  
		SUM(new_cases) AS Total_Cases
		, SUM(CAST(new_deaths AS INT)) AS Total_Deaths
		,ROUND(SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100, 2) AS Death_Percentage
		FROM CovidDeaths
WHERE continent IS NOT NULL
;

-- Total Population vs Total Vaccinations

WITH PvsVac(Continent,location,date,population,new_vaccinations,People_Vaccinated)
AS 
(
SELECT   dea.continent
		,dea.location
		,dea.date
		,dea.population
		,vac.new_vaccinations
		,SUM(CONVERT(INT,vac.new_vaccinations )) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS People_Vaccinated
		
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *
,ROUND((People_Vaccinated/population)*100, 2) AS Percentge_Vaccinated
FROM PvsVAC;

--CREATING VIEW FOR VISUAL PercentPopVacc
CREATE VIEW PercentPopVacc AS
SELECT   dea.continent
		,dea.location
		,dea.date
		,dea.population
		,vac.new_vaccinations
		,SUM(CONVERT(INT,vac.new_vaccinations )) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS People_Vaccinated
		
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL;

SELECT * 
FROM  PercentPopVacc

-- TEMP TABLE
DROP TABLE IF EXISTS PercentPopulationVacc;
 
CREATE TABLE PercentPopulationVacc
(Continent nvarchar(255)
,location nvarchar(255)
,date DATETIME
,population NUMERIC
,new_vaccinations NUMERIC
,People_Vaccinated NUMERIC
);

INSERT INTO PercentPopulationVacc
SELECT   dea.continent
		,dea.location
		,dea.date
		,dea.population
		,vac.new_vaccinations
		,SUM(CONVERT(INT,vac.new_vaccinations )) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS People_Vaccinated
		
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL


SELECT *
,(People_Vaccinated/population)*100 AS Percentge_Vaccinated
FROM PercentPopulationVacc;

