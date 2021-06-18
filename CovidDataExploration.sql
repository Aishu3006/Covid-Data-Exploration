SELECT *
FROM CovidDataExploration..CovidDeaths
ORDER BY 3,4

---SELECT *
---FROM CovidDataExploration..CovidVaccinations
---ORDER BY 3,4

--- Select Data to be used
SELECT Location, date, new_cases, total_deaths, population
FROM CovidDataExploration..CovidDeaths
ORDER BY 1,2

--- Total Cases vs Total Deaths in India
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDataExploration..CovidDeaths
WHERE Location = 'India'
ORDER BY 1,2

--- Total Cases vs Population
SELECT Location, date, Population, total_cases, (total_cases/Population)*100 AS CovidPercentage
FROM CovidDataExploration..CovidDeaths
WHERE Location = 'India'
ORDER BY 1,2

--- Countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/Population)*100)  AS HighestCovidPercentage
FROM CovidDataExploration..CovidDeaths
--- WHERE Location like 'I%' (Check for India)
GROUP BY Location, Population 
ORDER BY HighestCovidPercentage DESC

--- Countires with Highest Death Count per Population
SELECT Location, Population, MAX(cast(total_deaths as int)) AS TotalDeathCount 
FROM CovidDataExploration..CovidDeaths
--- WHERE Location like 'I%' (Check for India)
WHERE continent IS NOT NULL
GROUP BY Location, Population 
ORDER BY TotalDeathCount DESC

--- Breaking things down by Continent
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount 
FROM CovidDataExploration..CovidDeaths
--- WHERE Location like 'I%' (Check for India)
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--- Death Percentage Per DAY
SELECT date, SUM(new_cases) AS TotalCasesThatDay, 
SUM(cast(new_deaths as int)) AS TotalDeathsThatDay, 
---(TotalDeathsThatDay/TotalCasesThatDay)*100 AS DeathPercentageThatDay  ---total_cases, total_deaths, (total_deaths/total_cases)*100  AS DeathPercentage
SUM(cast(new_deaths as int))/SUM(new_cases)*100  AS DeathPercentage
FROM CovidDataExploration..CovidDeaths
--- WHERE Location like 'I%' (Check for India)
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--- Coming to Covid Vaccination Data
SELECT *
FROM CovidDataExploration..CovidVaccinations


--- Join these 2 tables
SELECT * ---dea.date, dea.location, vac.new_vaccinations
FROM CovidDataExploration..CovidDeaths dea
JOIN CovidDataExploration..CovidVaccinations vac 
    ON dea.location = vac.location
	and dea.date = vac.date
---WHERE dea.location = 'India'

--- Total Population VS Vaccinations
WITH PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location 
ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
---(RollingPeopleVaccinated/population)*100
FROM CovidDataExploration..CovidDeaths dea
JOIN CovidDataExploration..CovidVaccinations vac 
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
---ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100 AS VaccinatedPercentage
FROM PopvsVac
--- To find the country with highest vaccination percentage
--SELECT Location, MAX(RollingPeopleVaccinated/population)*100 AS VaccinatedPercentagePerLoc
--FROM PopvsVac
--GROUP BY Location
--ORDER BY 2 DESC

--- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopVaccinated -- To be able to make changes to the table
CREATE TABLE #PercentPopVaccinated
(Continent varchar(255),
Location varchar(255),
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location 
ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
---(RollingPeopleVaccinated/population)*100
FROM CovidDataExploration..CovidDeaths dea
JOIN CovidDataExploration..CovidVaccinations vac 
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
---ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 AS VaccinatedPercentage
FROM #PercentPopVaccinated


--- Creating View to store data for later visualization
CREATE VIEW PercentPopVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location 
ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
---(RollingPeopleVaccinated/population)*100
FROM CovidDataExploration..CovidDeaths dea
JOIN CovidDataExploration..CovidVaccinations vac 
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
---ORDER BY 2,3


-- Now we can use that table
Select *
FROM PercentPopVaccinated





























