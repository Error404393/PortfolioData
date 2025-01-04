SELECT * FROM
PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--SELECT * FROM
--PortfolioProject..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2

-- Looking at Total cases vs Total Deaths
-- shows likelihood of dying if you contract in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%indonesia'
and continent is not null
order by 1, 2

-- looking at total cases vs population
-- shows percentage of population got covid
Select location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
from PortfolioProject..CovidDeaths
order by 1, 2

--looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
Group by location, population
order by PercentPopulationInfected  desc

-- Showing Countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

-- BREAK THINGS DOWN BY CONTINENT

-- Showing the continents with the highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
--Where location like '%indonesia'
where continent is null
Group by location
order by TotalDeathCount desc


-- Global Numbers

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--Where location like '%indonesia'
where continent is not null
--Group by date
order by 1, 2


--Vaccinations
--Looking at total population vs total vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3 

--USE CTE

with PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3 
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac 



-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_Vaccinations numeric,  
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3 

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated 


-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2, 3

Select *
FROM PercentPopulationVaccinated