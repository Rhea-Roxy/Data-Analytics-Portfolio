select *
from PortfolioProject..CovidDeaths
where continent is not null -- add that to every query since it clears out the places that have a continent as location
order by 3,4


--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

select Location, date,total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


-- total cases vs total deaths
-- Shows liklihood of death if you contract covid
select Location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- looking at the total cases vs population
-- Shows the population of people who got covid
select Location, date, Population,total_cases, (total_cases/Population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at countries with highest interest rates
select Location, Population, MAX(total_cases) as HighestInfectionCount, max((total_cases/Population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--WHERE location LIKE '%india'
Group by location, population
order by PercentPopulationInfected desc


-- Showing the countries with the highest death rates per person
select Location, MAX(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

-- Breaking it down by continent

select location, MAX(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc

-- GLOBAL NUMBERS (Across the world per day and if the date is removed we get the total)
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/SUM(new_Cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2


-- Total population vs vaccination
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as RollingCountofPeopleVaxed 
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE (finding the percentage of people vs population vaccinated)
-- works just not orgranized

with PopvsVac(Continent, Location,Date,Population,new_vaccinations,RollingCountofPeopleVaxed)
as
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as RollingCountofPeopleVaxed
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingCountofPeopleVaxed/Population)*100 as columnb
from PopvsVac


-- TEMP TABLE
DROP table if exists #percentpopvaccinated
create Table #percentpopvaccinated
(
Continent nvarchar(255),Location nvarchar(255), Date datetime, Population numeric,
new_vaccinations numeric,
RollingCountofPeopleVaxed numeric
)

insert into #percentpopvaccinated
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as RollingCountofPeopleVaxed 
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *, (RollingCountofPeopleVaxed/Population)*100 as columnb
from #percentpopvaccinated


-- Creating a view to store data for later

create view percentpopulationVaccinated as 
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as RollingCountofPeopleVaxed 
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

-- displaying the data from the view
select*
from percentpopulationVaccinated