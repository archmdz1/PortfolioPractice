Select *
From [dbo].[Covid Deaths] death
Where continent is not null
Order by 1, 2


----Select *
----From [dbo].[Covid Vaxxed] vax
----Order by 1, 2

-- Select data that are going to be used.

Select location, date, total_cases, new_cases, total_deaths, population
From [Covid Deaths] death
Where continent is not null
Order by 1, 2

-- Looking at Total Cases vs. Total Deaths
-- Likelihood of dying from covid per country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Covid Deaths] death
Where continent is not null
--Where location like '%philippines%'
Order by 1, 2

-- Looking at Total Cases vs. Population

Select location, date, total_cases, population, (total_cases/population)*100 as CasesPerPop
From [Covid Deaths]
--Where location like '%Philippines%'
Where continent is not null
Order by 1, 2

-- Highest Infection Rate per Population

Select location, MAX(total_cases) as HighestInfectionCount, population, MAX(total_cases/population)*100 as PercentPopInfection
From [Covid Deaths] 
Where continent is not null
Group by population, location
Order by PercentPopInfection desc

-- Highest Death Rate per Population

Select location, MAX(cast(total_deaths as int)) as HighestDeathCount
from [Covid Deaths]
Where continent is not null
Group by location
Order by HighestDeathCount desc

-- Breaking things down by continent

Select location, MAX(cast(total_deaths as int)) as HighestDeathCount
from [Covid Deaths]
Group by location
Order by HighestDeathCount desc

Select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
from [Covid Deaths]
Where continent is not null
Group by continent
Order by HighestDeathCount desc

-- Showing Continent with highest death count per population.

Select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
from [Covid Deaths]
Where continent is not null
Group by continent
Order by HighestDeathCount desc

-- Global Numbers

Select date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, 
SUM(cast(new_deaths as int))/SuM(new_cases)*100 as GlobalDeathPercent
From [Covid Deaths] death
Where continent is not null
Group by date
Order by 1, 2

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, 
SUM(cast(new_deaths as int))/SuM(new_cases)*100 as GlobalDeathPercent
From [Covid Deaths] death
Where continent is not null
Order by 1, 2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Covid Deaths] dea
Join [Covid Vaxxed] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Covid Deaths] dea
Join [Covid Vaxxed] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp Table


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Covid Deaths] dea
Join [Covid Vaxxed] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaxxed as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Covid Deaths] dea
Join [Covid Vaxxed] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

  Select *
  From PercentPopulationVaxxed