SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3, 4

SELECT * 
FROM PortfolioProject..CovidVaccinations
ORDER BY 3, 4

--Select data we are going to use -- 

SELECT location, date, total_cases, new_cases, total_deaths, population, 
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1, 2

--Looking at Total Cases vs Total Deaths--


SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1, 2


Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where location = 'romania'
WHERE continent is not NULL
ORDER BY 1, 2


--Look at Total Cases vs Population--

Select location, date, population, total_cases, (total_cases/population)*100 as CasesPercent
FROM PortfolioProject..CovidDeaths
where location = 'romania'and continent is not NULL
ORDER BY 1, 2


--Look at Highest Infection Rate compared to Population--

Select location, population, max(total_cases) as MaxInfectionCount, max(total_cases/population)*100 as PercentofPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
Group by location, population
ORDER BY 4 desc

--Showing coruntries with Highest Percentage of Deaths per Population--


SELECT location, max(cast(total_deaths as int)) as TotalDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathsCount desc

--Highest Percentage of Deaths per Continent--

SELECT continent, max(cast(total_deaths as int)) as TotalDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathsCount desc

--Showing continents with Highest Death Count per population--



Select location, population, max(cast(total_deaths as int)) as MaxDeathsCount, max(total_deaths/population)*100 as MaxPercentageDeathPopulation 
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
Group by location, population
ORDER BY MaxPercentageDeathPopulation desc

--Showing continents with Highest Death Count per population--

SELECT continent, max(cast(total_deaths as int)) as TotalDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathsCount desc

--GLOBAL --

SELECT --date,--
SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, SUM(CAST(new_deaths as int))/SUM (new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1, 2


--Checking Total Population vs Vaccinated--

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) 
as RollingVaccinated, 
--(RollingVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
  WHERE dea.continent is not NULL --and dea.location = 'romania'--
  ORDER BY 1, 2, 3 --5 desc


  --USE CTE

  WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinated)
  as
  (
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) 
as RollingVaccinated
--(RollingVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
  WHERE dea.continent is not NULL
  -- ORDER BY 1, 2, 3 --5 desc--
)

Select *, (RollingVaccinated/population)*100
FROM PopvsVac


--TEMP table


CREATE TABLE #PercentPopulationVaccinated

(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinated numeric
)


insert into #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) 
as RollingVaccinated
--(RollingVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
  WHERE dea.continent is not NULL
  -- ORDER BY 1, 2, 3 --5 desc--
  
  Select *, (RollingVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Create view for Later Visualisation

CREATE VIEW PercentPopulationVaccinated as

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) 
as RollingVaccinated
--(RollingVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
  WHERE dea.continent is not NULL
  --ORDER BY 1, 2, 3 --5 desc--
  
  Select * 
  from PercentPopulationVaccinated