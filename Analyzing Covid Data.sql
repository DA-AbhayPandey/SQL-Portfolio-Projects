select* 
from CovidDeaths$
order by 3,4

select*
from CovidVaccination
order by 3,4

select location, date, population, total_cases, new_cases, total_deaths
from CovidDeaths$
order by 1,2

--Looking for total cases vs Total Deaths perccentaeg
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
order by 1,2

--Looking for total cases vs Total Deaths perccentaeg in India
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
where location like '%India%'
order by 1,2

--Looking for total cases vs Population perccentaeg in India
select location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
from CovidDeaths$
where location like '%India%'
order by 1,2

--Looking for country with highest infection rate compare to population
select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as InfectedPercentage
from CovidDeaths$
--where location like '%India%'
group by location, population
order by InfectedPercentage desc

--Looking for India's highest infection count compare to population 
select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as InfectedPercentage
from CovidDeaths$
where location like '%India%'
group by location, population

--Show countries with highest death count compare to population 
select location, population, Max(cast(total_deaths as int)) as HighestDeathCount, Max((total_deaths/population))*100 as DeathPercentage
from CovidDeaths$
where continent is not null
group by location, population
order by HighestDeathCount desc

--Global number
select date, Sum(new_cases) as TotalNewCases, Sum(cast(new_deaths as int)) as TotalNewDeaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from Portfolio..CovidDeaths$
where continent is not null
group by date
order by 1,2

select dea.location, dea.date, dea.new_cases, dea.new_deaths, vac.new_tests, vac.new_vaccinations
from Portfolio..CovidDeaths$ dea
join Portfolio..CovidVaccination vac
 on dea.location = vac.location
 and dea.date = vac.date
 order by 1

 --Looking at total population vs Vaccinated
 select dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as TotalCases
from Portfolio..CovidDeaths$ dea
join Portfolio..CovidVaccination vac
 on dea.location = vac.location
 and dea.date = vac.date 
 where dea.continent is not null
 order by 1,2

 --USE CTE
 With PopVsVacc as 
 (select dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as TotalCases
from Portfolio..CovidDeaths$ dea
join Portfolio..CovidVaccination vac
 on dea.location = vac.location
 and dea.date = vac.date 
 where dea.continent is not null
-- order by 1,2
)

Select* , TotalCases/population*100 as VaccinationPercentage
from PopVsVacc

--Temp Table

drop table if exists #VacPer
create table #VacPer
(location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalCases numeric)


insert into #VacPer
select dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as TotalCases
from Portfolio..CovidDeaths$ dea
join Portfolio..CovidVaccination vac
 on dea.location = vac.location
 and dea.date = vac.date 
-- where dea.continent is not null
-- order by 1,2

select*, (TotalCases/population)*100
from #VacPer


--creating view to store data for later visualiztions

create view VaccinationPercentage as
select dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as TotalCases
from Portfolio..CovidDeaths$ dea
join Portfolio..CovidVaccination vac
 on dea.location = vac.location
 and dea.date = vac.date 
where dea.continent is not null
-- order by 1,2

select*
from VaccinationPercentage
