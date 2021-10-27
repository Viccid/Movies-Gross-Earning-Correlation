SELECT *
FROM PortfolioProjectN..['covid-deathcase$']
WHERE continent is not NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProjectN..['covid-vaccinationcase$']
--ORDER BY 3,4

SELECT Location, date, total_cases,new_cases, total_deaths, population
FROM PortfolioProjectN..['covid-deathcase$']
ORDER BY 1,2

--Looking at Total cases vs Total Deaths
--Show likelyhood of dying if you contract Covid in your country

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)* 100 AS DeathPercentage
FROM PortfolioProjectN..['covid-deathcase$']
WHERE location Like '%states%'
ORDER BY 1,2;


--Lookinhg at Total_case vs population
-- Show the percentage that contracted Covid

SELECT Location, date, total_cases, population, (total_cases/population )* 100 AS PercentageInfection
FROM PortfolioProjectN..['covid-deathcase$']
WHERE location Like '%states%'
ORDER BY 1,2;


--Looking at country with High infection rate compared to Population

SELECT Location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population ))* 100 AS PercentageInfection
FROM PortfolioProjectN..['covid-deathcase$']
--WHERE location Like '%states%'
GROUP BY location, population
ORDER BY PercentageInfection DESC


--Showing countries with Highest Death Count Per Population

SELECT Location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProjectN..['covid-deathcase$']
--WHERE location Like '%states%'
WHERE continent is not NULL
GROUP BY location
--ORDER BY TotalDeathCount DESC


--Showing continent with Highest Death Count per Population

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProjectN..['covid-deathcase$']
--WHERE location Like '%states%'
WHERE continent is not NULL
GROUP BY continent
--ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS


SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProjectN..['covid-deathcase$']
--WHERE location Like '%states%'
WHERE continent is not NULL
--GROUP BY date


--Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location 
ORDER BY dea.location, dea.date) AS Totalingpeoplevaccinated
FROM PortfolioProjectN..['covid-deathcase$'] dea
JOIN PortfolioProjectN..['covid-vaccinationcase$'] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 1,2,3



USE OF CTE


With PopulationVSVaccination(continent,date, location,population, new_vaccination, Totalingpeoplevaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location 
ORDER BY dea.location, dea.date) AS Totalingpeoplevaccinated
FROM PortfolioProjectN..['covid-deathcase$'] dea
JOIN PortfolioProjectN..['covid-vaccinationcase$'] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL
)
SELECT *
FROM PopulationVSVaccination



--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent NVARCHAR(255),
location NVARCHAR(225),
Date datetime,
Population numeric,
New_vaccinations numeric,
Totalingpeoplevaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location 
ORDER BY dea.location, dea.date) AS Totalingpeoplevaccinated
FROM PortfolioProjectN..['covid-deathcase$'] dea
JOIN PortfolioProjectN..['covid-vaccinationcase$'] vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent is not NULL

SELECT *, (Totalingpeoplevaccinated /Population)*100
FROM #PercentPopulationVaccinated



--creating views to store data for visualization

CREATE View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location 
ORDER BY dea.location, dea.date) AS Totalingpeoplevaccinated
FROM PortfolioProjectN..['covid-deathcase$'] dea
JOIN PortfolioProjectN..['covid-vaccinationcase$'] vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent is not NULL