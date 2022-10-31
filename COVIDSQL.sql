--SELECT * From PortfolioProject..COVIDDeaths
--order by 3,4

--SELECT * From PortfolioProject..COVIDVaccinations
--order by 3,4

--Select Location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject..COVIDDeaths
--order by 1,2


-- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..COVIDDeaths
Where location like '%states'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulation
FROM PortfolioProject..COVIDDeaths
Where location like '%states'
order by 1,2

-- Looking at Countries with highest infection rate compared to population

Select Location, MAX(total_cases) as HighestInfectionCount, population, Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..COVIDDeaths
Group by population, location 
order by PercentPopulationInfected desc

-- Showing countries with the highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..COVIDDeaths
where continent is not null 
Group by location 
order by TotalDeathCount desc


-- Continents with the highest death count


Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..COVIDDeaths
where continent is not null 
Group by continent
order by TotalDeathCount desc


-- Global numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..COVIDDeaths
Where continent is not null	
group by date
order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated

From PortfolioProject..COVIDDeaths dea
JOIN PortfolioProject..COVIDVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated

From PortfolioProject..COVIDDeaths dea
JOIN PortfolioProject..COVIDVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select * , (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated

From PortfolioProject..COVIDDeaths dea
JOIN PortfolioProject..COVIDVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select * , (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



Select dea.location, dea.population, vac.people_fully_vaccinated
, MAX((vac.people_fully_vaccinated/dea.population)*100) as PercentFullyVaccinated
From PortfolioProject..COVIDDeaths dea
JOIN PortfolioProject..COVIDVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
group by dea.location, dea.population, vac.people_fully_vaccinated
order by 4


--Percent of each country fully vaccinated

SELECT location, max(population) as Population, max(cast(people_fully_vaccinated as bigint)) as PeopleVaccinated
, MAX(Cast(people_fully_vaccinated as bigint))/max(Population)*100 as PercentFullyVaccinated
FROM PortfolioProject..COVIDVaccinations
Where Continent is not null
Group by location
Order by PercentFullyVaccinated desc


-- Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
SELECT location, max(population) as Population, max(cast(people_fully_vaccinated as bigint)) as PeopleVaccinated
, MAX(Cast(people_fully_vaccinated as bigint))/max(Population)*100 as PercentFullyVaccinated
FROM PortfolioProject..COVIDVaccinations
Where Continent is not null
Group by location



Create view GlobalCasesAndDeaths as

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..COVIDDeaths
Where continent is not null	
group by date


create view InfectionRates as
Select Location, MAX(total_cases) as HighestInfectionCount, population, Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..COVIDDeaths
Group by population, location 
