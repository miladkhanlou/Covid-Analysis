Select * from CovidDeaths$ where continent is not null
Select continent from CovidDeaths$ group by continent

--select Data that we are going to be using
select location, date, total_cases, new_cases,total_deaths, population
from CovidDeaths$
where continent is not null
order by 1,2

--looking at total cases Vs Total Deaths
--Showing Likehood of Dying In the US
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
from CovidDeaths$
where location like '%states'
and continent is not null
order by 1,2

--looking at the total Cases VS population
select location, date,population,total_cases, (total_cases/population)*100 as Infected_Percentage
from CovidDeaths$
where continent is not null
--and location like '%states'
order by 1,2

--looking at countries with Highest infection rate compaired to population
select location,population,max(total_cases) as maxtotalCases, max((total_cases/population))*100 as Highest_Infected_Percentage
from CovidDeaths$
where continent is not null
--and location like '%states'
group by population, location
order by Highest_Infected_Percentage Desc

--showing countries with highest death count per population
select location,max(cast(total_deaths as int)) Highest_death
from CovidDeaths$
where continent is not null
--and location like '%states'
group by population, location
order by Highest_death Desc

--showing continents with highest death count per population
select location,sum(population) as Population_In_Continent, max(cast(total_deaths as int)) as Highest_death
from CovidDeaths$
where continent is null
--and location like '%states'
group by location
order by Highest_death Desc

--showing the continents with highest death count
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where continent is not null
--and location like '%states'
group by continent
order by TotalDeathCount Desc

--Global numbers
select date, sum(new_cases) totalCases, sum(cast(new_deaths as int)) as totalDeaths, sum(cast(new_deaths as int))/ sum(new_cases) * 100 as GlobalDeaths_percentage
from CovidDeaths$
-- where location like '%states'
where continent is not null
group by date
order by 1,2

select sum(new_cases) totalCases, sum(cast(new_deaths as int)) as totalDeaths, sum(cast(new_deaths as int))/ sum(new_cases) * 100 as GlobalDeaths_percentage
from CovidDeaths$
-- where location like '%states'
where continent is not null
order by 1,2

--Number of cases and deaths Globally
select sum(new_cases) totalCases, sum(cast(new_deaths as int)) as totalDeaths, sum(cast(new_deaths as int))/ sum(new_cases) * 100 as GlobalDeaths_percentage
from CovidDeaths$
where continent is not null
order by 1,2

--joining two tables
select * 
from CovidDeaths$ dea
join CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date


--looking at total Population VS Vaccination
select dea.continent, dea.population, dea.location, dea.date, vac.new_vaccinations, sum(CONVERT(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.Date, dea.location) as RollingPeopleVaccinated  --showing sum of new vaccination on the locations and then ordered it by date and location to show the currect number of summed 
from CovidDeaths$ dea
join CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 1,2,3;


--Using CTE
with PopvsVac (continent,population,location,date,new_vaccinations,RollingPeopleVaccinated) -- Order should be exactly like our query inside the CTE
as
(
select dea.continent, dea.population, dea.location, dea.date, vac.new_vaccinations, sum(CONVERT(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.Date, dea.location) as RollingPeopleVaccinated
--showing sum of new vaccination on the locations and then ordered it by date and location to show the currect number of summed 
from CovidDeaths$ dea
join CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	)
	select *, (RollingPeopleVaccinated/population)*100 as PercOfVaccinated from PopvsVac

--TEMP TABLE
Drop table if exists PercentPopulationVaccinated --adding this for future alterations to the table of PercentPopulationVaccinated!
Create table PercentPopulationVaccinated(
continent nvarchar(255),population numeric, location nvarchar(255), date datetime, new_vaccinations numeric,RollingPeopleVaccinated numeric)

insert into PercentPopulationVaccinated
select dea.continent, dea.population, dea.location, dea.date, vac.new_vaccinations, sum(CONVERT(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.Date, dea.location) as RollingPeopleVaccinated  --showing sum of new vaccination on the locations and then ordered it by date and location to show the currect number of summed 
from CovidDeaths$ dea
join CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null 
	order by 1,2,3;

		--showing what's above
	select *, (RollingPeopleVaccinated/population)*100 as PercOfVaccinated from PercentPopulationVaccinated




--Creating View For VISUALIZATIONS:

	--Creating View For Likehood of Dying In the US
Create view LikehoodOfDyingInUS as
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
from CovidDeaths$
where location like '%states'
and continent is not null

	--Creating View For total Cases VS population
Create view CasesVsPopulation as
select location, date,population,total_cases, (total_cases/population)*100 as Infected_Percentage
from CovidDeaths$
where continent is not null

	--Creating View For Countries with Highest infection rate compaired to population
Create view HighestInfectionVsPopulation as
select location,population,max(total_cases) as maxtotalCases, max((total_cases/population))*100 as Highest_Infected_Percentage
from CovidDeaths$
where continent is not null
group by population, location

	--Creating View For countries with highest death count per population
create view HighestDeathVsPopulation as
select location,max(cast(total_deaths as int)) as Highest_death
from CovidDeaths$
where continent is not null
group by population, location

	--Creating View For countries with highest count
create view HighestDeathCount as
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where continent is not null
group by continent

	--Creating View For Global Death count and percentage
create view GlobalDeaths as 
select location, sum(new_cases) totalCases, sum(cast(new_deaths as int)) as totalDeaths, sum(cast(new_deaths as int))/ sum(new_cases) * 100 as GlobalDeaths_percentage
from CovidDeaths$
-- where location like '%states'
where continent is not null
group by location

	--Creating View For Percentages of total Population VS Vaccination
create view PercPopuvsVac as
with PopvsVac (continent,population,location,date,new_vaccinations,RollingPeopleVaccinated) -- Order should be exactly like our query inside the CTE
as
(
select dea.continent, dea.population, dea.location, dea.date, vac.new_vaccinations, sum(CONVERT(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.Date, dea.location) as RollingPeopleVaccinated
--showing sum of new vaccination on the locations and then ordered it by date and location to show the currect number of summed 
from CovidDeaths$ dea
join CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	)
	select *, (RollingPeopleVaccinated/population)*100 as PercOfVaccinated from PopvsVac



	select * from PercPopuvsVac
	select * from CasesVsPopulation
	select * from GlobalDeaths
	select * from HighestDeathCount
	select * from  HighestInfectionVsPopulation
	select * from LikehoodOfDyingInUS

/*	--Creating View For total Population VS Vaccination
create view PopulationvsVaccination as
select dea.continent, dea.population, dea.location, dea.date, vac.new_vaccinations, sum(CONVERT(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.Date, dea.location) as RollingPeopleVaccinated  --showing sum of new vaccination on the locations and then ordered it by date and location to show the currect number of summed 
from CovidDeaths$ dea
join CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	select * from PopulationvsVaccination*/

--table1
select sum(new_cases) totalCases, sum(cast(new_deaths as int)) as totalDeaths, sum(cast(new_deaths as int))/ sum(new_cases) * 100 as GlobalDeaths_percentage
from CovidDeaths$
-- where location like '%states'
where continent is not null
order by 1,2

--Table2
Select location, SUM(cast(new_deaths as int)) as totalDeaths
from CovidDeaths$
Where continent is null 
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'Lower middle income', 'Low income','High income')
Group by location
order by totalDeaths desc

--table3
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths$
Group by Location, Population
order by PercentPopulationInfected desc

--table4
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths$
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc
