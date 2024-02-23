SELECT *
FROM PortfolioProject..CovidData
where continent is not null
ORDER BY 3,4


SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidData
ORDER BY 1,2



SELECT location, date, total_cases, total_deaths
FROM PortfolioProject..CovidData
WHERE location like '%India%'
ORDER BY 1,2





--Cases Percentage in India

SELECT location, date, population, total_cases, (total_cases/population)*100 AS CasesPercentage
FROM PortfolioProject..CovidData
WHERE location like '%India%'
ORDER BY 1,2



--Countries with highest infection rate vs Population

SELECT location,population, max(total_cases) AS HighestCaseCount, MAX((total_cases/population))*100 AS PercentPopulationCases
FROM PortfolioProject..CovidData
GROUP BY location, population
ORDER BY PercentPopulationCases DESC


--Countries with highest death count per population

SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidData
where continent is not null
Group by location
order by TotalDeathCount desc



--Continents with highest death count

SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidData
where continent is not null
Group by continent
order by TotalDeathCount desc



--Global Numbers

SELECT sum(new_cases) as TotalCases, sum (new_deaths) AS TotalDeaths, sum(new_deaths)/sum(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidData
where continent is not null
Order By 1,2


--Vaccinations

SELECT *
FROM PortfolioProject..CovidData da
Join PortfolioProject..CovidVaccinations vac
ON da.location = vac.location
and da.date = vac.date



--Total population vs Vaccinations


SELECT da.continent, da.location, da.date, da.population, vac.new_vaccinations, SUM(cast(new_vaccinations as bigint)) OVER (Partition by da.location ORDER BY da.location,
da.date) AS NewVaccinationsCounter
FROM PortfolioProject..CovidData da
Join PortfolioProject..CovidVaccinations vac
ON da.location = vac.location
and da.date = vac.date
where da.continent is not null
ORDER BY 2,3


--Total Population vs Vaccinations

-- 1.Using CTE

With PopVsVac (continent, location, date, population, new_vaccinations, NewVaccinationsCounter)
as
(
SELECT da.continent, da.location, da.date, da.population, vac.new_vaccinations, SUM(cast(new_vaccinations as bigint)) OVER (Partition by da.location ORDER BY da.location,
da.date) AS NewVaccinationsCounter
FROM PortfolioProject..CovidData da
Join PortfolioProject..CovidVaccinations vac
ON da.location = vac.location
and da.date = vac.date
where da.continent is not null
)
SELECT*, (NewVaccinationsCounter/population)*100 AS PercentageVaccinated
FROM PopVsVac




-- 2.Using Temp Table


DROP TABLE if exists #PercentageVaccinated

Create Table #PercentageVaccinated
(
continent nvarchar(200), 
location nvarchar(200),
date datetime,
population numeric,
new_vaccinations numeric,
NewVaccinationsCounter numeric
)
INSERT INTO #PercentageVaccinated

SELECT da.continent, da.location, da.date, da.population, vac.new_vaccinations, SUM(cast(new_vaccinations as bigint)) OVER (Partition by da.location ORDER BY da.location,
da.date) AS NewVaccinationsCounter
FROM PortfolioProject..CovidData da
Join PortfolioProject..CovidVaccinations vac
ON da.location = vac.location
and da.date = vac.date
where da.continent is not null


SELECT*, (NewVaccinationsCounter/population)*100 AS PercentageVaccinated
FROM #PercentageVaccinated



--Creating View for Visualisation

CREATE VIEW PercentageVaccinated AS 
SELECT da.continent, da.location, da.date, da.population, vac.new_vaccinations, SUM(cast(new_vaccinations as bigint)) OVER (Partition by da.location ORDER BY da.location,
da.date) AS NewVaccinationsCounter
FROM PortfolioProject..CovidData da
Join PortfolioProject..CovidVaccinations vac
ON da.location = vac.location
and da.date = vac.date
where da.continent is not null