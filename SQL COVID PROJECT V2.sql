

select *
 from PortfolioProject..CovidDeaths
 where continent is not null
 order by 3,4


--select *
-- from PortfolioProject..CovidVaccinations
-- order by 3,4



select location, date, total_cases, new_cases, total_deaths, population
 from PortfolioProject..CovidDeaths
 order by 1,2


 --showing the likelihood of dying if you contract Covid in your country by looking at total_cases Vs total_deaths
 select location, date, total_cases, total_deaths, (total_deaths/total_cases)
 from PortfolioProject..CovidDeaths
 order by 1,2

 select location, date, total_cases, total_deaths, (CAST (total_deaths AS FLOAT)/ NULLIF(total_cases,0))*100 AS DeathPercentage 
 from PortfolioProject..CovidDeaths
 where location like '%states%'
 order by 1,2

 --showing what percentage of population got Covid
select location, date, population, total_cases, (CAST(total_cases AS FLOAT) / NULLIF(CAST(population AS FLOAT), 0))*100 AS PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2


--showing countries with the highest infection rate compared to population
select location, population, MAX(total_cases) AS HighestInfectionCount, MAX(CAST(total_cases AS FLOAT) / NULLIF(CAST(population AS FLOAT), 0))*100 AS PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc


--showing countries with the highest death count per population
select location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc


--showing the continents with the highest death count per population
select continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc 


--GLOBAL NUMBERS

 select location, date, total_cases, total_deaths, (CAST (total_deaths AS FLOAT)/ NULLIF(total_cases,0))*100 AS DeathPercentage 
 from PortfolioProject..CovidDeaths
 --where location like '%states%'
 where continent is not null
 order by 1,2


  select date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as FLOAT)) AS total_deaths , COALESCE(SUM(CAST(new_deaths AS FLOAT))/NULLIF(SUM(new_cases),0)*100, 0) AS DeathPercentage 
 from PortfolioProject..CovidDeaths
 --where location like '%states%'
 where continent is not null
 Group by date
 order by 1,2


 select SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as FLOAT)) AS total_deaths,
 CASE
    WHEN SUM(new_cases) = 0 THEN 0
    ELSE SUM(CAST(new_deaths AS FLOAT))/NULLIF(SUM(new_cases),0)*100 
END AS DeathPercentage 
 from PortfolioProject..CovidDeaths
 --where location like '%states%'
 where continent is not null
-- Group by date
 order by 1,2



select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,  SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3





--USING CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,  SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
select*, (CASE WHEN population > 0 THEN (RollingPeopleVaccinated * 1.0 / population)*100 ELSE NULL END) as vaccinationpercentage
from PopvsVac





--TEMP TABLE

DROP Table if exists #percentpopulationvaccinated
create Table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,  SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
select*, (CASE WHEN population > 0 THEN (RollingPeopleVaccinated * 1.0 / population)*100 ELSE NULL END) as vaccinationpercentage
from #percentpopulationvaccinated


--creating view to store data for visualization

drop view if exists percentpopulationvaccinated
go
create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,  SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
, (SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date)/dea.population)*100 as PercentPopulationVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

SELECT * FROM PortfolioProject..percentpopulationvaccinated;


USE PortfolioProject;
GO

SELECT * FROM sys.views WHERE name = 'percentpopulationvaccinated';

USE PortfolioProject;
GO
drop view if exists percentpopulationvaccinated;
go
create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,  SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
, (SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date)/dea.population)*100 as PercentPopulationVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

select*
from percentpopulationvaccinated


