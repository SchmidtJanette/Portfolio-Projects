Select *
From PortfolioProject..CovidDeaths2
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations

-- Select Data that we are going to be using

Select location, date, total_cases, total_deaths, population
From PortfolioProject..CovidDeaths2
order by 1,2 


-- Looking at Total Cases vs Total Deaths
-- Shows liklihood of you contracting covid in your country

Select Location, date, total_cases,total_deaths, CAST(total_deaths as float)/total_cases *100 as DeathPercentage
From PortfolioProject..CovidDeaths2
order by 1,2 

--- Looking at Total Cases vs Population
--- Shows what percentage of population got covid

Select Location, date, total_cases, population, CAST(total_cases as float)/population *100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths2
Where location like '%states%'
order by 1,2 

-- Looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(CAST(total_cases as float))/population *100 as 
	PercentPopulationInfected
From PortfolioProject..CovidDeaths2


--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--- Showing countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths2
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Breaking things down by continent

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths2
--Where location like '%states%'
Where continent is null
Group by location
order by TotalDeathCount desc


-- Showing the continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths2
--Where location like '%states%'
Where continent is null
Group by continent
order by TotalDeathCount desc

--- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as float)) as total_deaths,
	SUM(cast(new_deaths as float))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths2
--Where location like '%states%'
where continent is not null
Group By date
order by 1,2 

--- Total Deaths and death percentage Throughout the world

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as float)) as total_deaths,
	SUM(cast(new_deaths as float))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths2
--Where location like '%states%'
where continent is not null
---Group By date
order by 1,2 


Select *
From PortfolioProject..CovidVaccinations2

--- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
---, (RollingPeopleVaccinated/
From PortfolioProject..CovidDeaths2 dea
Join PortfolioProject..CovidVaccinations2 vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
---, (RollingPeopleVaccinated/
From PortfolioProject..CovidDeaths2 dea
Join PortfolioProject..CovidVaccinations2 vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
---, (RollingPeopleVaccinated/
From PortfolioProject..CovidDeaths2 dea
Join PortfolioProject..CovidVaccinations2 vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
---, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths2 dea
Join PortfolioProject..CovidVaccinations2 vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3