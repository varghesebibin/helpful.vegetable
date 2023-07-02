/* Part 1: Data Exploration */

SELECT *
FROM Projects..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

--SELECT *
--FROM Projects..CovidVaccinations
--ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Projects..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--1. Total Cases Vs Total Deaths

SELECT location, date, total_cases, total_deaths, ROUND(100.0*(total_deaths/total_cases), 2) AS DeathPercentage
FROM Projects..CovidDeaths
WHERE location LIKE '%states%' and continent IS NOT NULL
ORDER BY 1,2;

--2. Total Cases vs Population

SELECT location, date, population, total_cases, (total_cases/Population)*100.0 AS InfectionRate
FROM CovidDeaths
WHERE location LIKE '%states%' and continent IS NOT NULL
ORDER BY 1,2;

--3. Countries with Highest Infection Rate compared to Population

SELECT location,
		population,
		MAX(total_cases) AS HighestInfectionCount,
		MAX((total_cases/population)*100.0) AS HighestPercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY HighestPercentPopulationInfected DESC;

--3. Showing Countries with Highest Death Count Per Population
--SELECT location,
--		population,
--		MAX(cast(total_deaths AS int)) AS HighestDeathCount,
--		MAX((total_deaths/population)*100.0) AS HighestPercentPopulationDied
--FROM CovidDeaths
--WHERE continent IS NOT NULL
--GROUP BY location,population
--ORDER BY HighestPercentPopulationDied DESC;


-- 3. Showing countries with highest death count

SELECT location,
		MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Breaking Down By Continent
SELECT location,
		MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;
------------------------
SELECT continent,
		MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


--- 4. Global Numbers

SELECT date, 
	SUM(new_cases) AS total_new_cases, 
	SUM(cast(new_deaths as int)) AS tot_new_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases) * 100.0 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

--- 5. Looking at total populations vs vaccinations

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS (
SELECT d.continent, 
		d.location, 
		d.date, 
		d.population, 
		v.new_vaccinations,
		SUM(cast(v.new_vaccinations as int)) OVER (Partition By d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM CovidDeaths d
INNER JOIN CovidVaccinations v ON d.date = v.date and d.location = v.location
WHERE d.continent IS NOT NULL
)

-- Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
( 
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, 
		d.location, 
		d.date, 
		d.population, 
		v.new_vaccinations,
		SUM(cast(v.new_vaccinations as int)) OVER (Partition By d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM CovidDeaths d
INNER JOIN CovidVaccinations v ON d.date = v.date and d.location = v.location
WHERE d.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100.0
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT d.continent, 
		d.location, 
		d.date, 
		d.population, 
		v.new_vaccinations,
		SUM(cast(v.new_vaccinations as int)) OVER (Partition By d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM CovidDeaths d
INNER JOIN CovidVaccinations v ON d.date = v.date and d.location = v.location
WHERE d.continent IS NOT NULL