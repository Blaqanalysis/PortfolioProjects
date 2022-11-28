Select*
FROM PortfolioProject..CovidDeaths$
Where continent is not null
Order by 3,4


--Select*
--FROM PortfolioProject..CovidVaccinations$
--Order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
Where continent is not null
order by 1,2

--Looking at total cases vs total deaths

-- Shows likeliehood of daying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
Where Location like '%sweden%'
Where continent is not null
order by 1,2


-- Looking at total cases vs Population
-- Shows what percentage of population got covid
Select location, date, population,total_cases, (total_cases/population)*100 as PercentpopulationInfected
FROM PortfolioProject..CovidDeaths$
Where continent is not null
--Where Location like '%sweden%'
order by 1,2

-- Looking at Countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as highestInfectionCount, MAX((total_cases/population))*100 as PercentpopulationInfected
FROM PortfolioProject..CovidDeaths$
Where continent is not null
--Where Location like '%sweden%'
Group by location, population
order by PercentpopulationInfected desc

-- Showing countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
Where continent is not null
--Where Location like '%sweden%'
Group by location
order by TotalDeathCount desc

-- Lets break down by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
Where continent is not null
--Where Location like '%sweden%'
Group by continent
order by TotalDeathCount desc

-- Showing the continent with highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
Where continent is not null
--Where Location like '%sweden%'
Group by continent
order by TotalDeathCount desc

-- Global Numbers

Select  SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
-- Where Location like '%sweden%'
Where continent is not null
--Group by date
order by 1,2

-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVaccinated/population)*100
From PopvsVac


--Temp Table

Drop table if exists #percentpopulationVaccinated
create table #percentpopulationVaccinated
(
Continent nvarchar(255),
location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #percentpopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select*, (RollingPeopleVaccinated/population)*100
From #percentpopulationVaccinated

-- Creating view to store data for visualizations

Create view percentpopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select*
From percentpopulationVaccinated