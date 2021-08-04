Select * From [Portofolio Project]..CovidDeaths
order by 3,4
--Select * From [Portofolio Project]..CovidVacinations
--order by 3,4

--Select data that we are going to be using

SELECT	Location,date, total_cases, new_cases, total_deaths, population
From [Portofolio Project]..CovidDeaths
order by 1,2

-- Looking at the total cases vs total deaths
SELECT	Location,date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portofolio Project]..CovidDeaths
Where Location like '%akistan%'
order by 1,2


--Looking at Total cases vs Poppultation  
SELECT	Location,date, total_cases, Population,(total_cases/population)*100 as InfectionPercentage
From [Portofolio Project]..CovidDeaths
Where Location like '%akistan%'
order by 1,2

-- Looking at countries with Highest infection rate compared to the poppulation

SELECT	Location, Population, max(total_cases) as HighestInfectionCount ,max((total_cases)/population)*100 as 
	InfectionPercentage
From [Portofolio Project]..CovidDeaths
--Where Location like '%akistan%'
Group by Location, Population
order by InfectionPercentage desc

-- Showing the countries with Highest deaths
SELECT	Location, max(cast(total_deaths as int)) as TotalDeathCount  
From [Portofolio Project]..CovidDeaths
--Where Location like '%akistan%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--- Breaking things down by continent 

-- Showing the continents with Highest deaths
SELECT	location, max(cast(total_deaths as int)) as TotalDeathCount  
From [Portofolio Project]..CovidDeaths
--Where Location like '%akistan%'
Where continent is null
Group by location
order by TotalDeathCount desc


--GLOBAL numbers

-- Looking at the total cases vs total deaths per date
SELECT	date, Sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From [Portofolio Project]..CovidDeaths
--Where Location like '%akistan%'
Where continent is not null
Group by date
order by 1,2

-- Looking at the total cases vs total deaths total
SELECT Sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From [Portofolio Project]..CovidDeaths
--Where Location like '%akistan%'
Where continent is not null
--Group by date
order by 1,2

--Looking at rolling total of Vaccination by country
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.Location Order by dea.location, dea.date) as RollingTotalofVaccinations
From [Portofolio Project]..CovidDeaths dea
join [Portofolio Project]..CovidVacinations vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac(Continent, Location, Date, Population,New_vaccination, RollingTotalofVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.Location Order by dea.location, dea.date) as RollingTotalofVaccinations
From [Portofolio Project]..CovidDeaths dea
join [Portofolio Project]..CovidVacinations vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--order by 2,3
)
Select *,(RollingTotalofVaccinations/Population)*100 as RollingPercentofVaccinations
From PopvsVac


--Temp Table
Drop Table if exists #PercentTotalvaccinations
Create Table #PercentTotalvaccinations
(
Continent nvarchar(255),
Location nvarchar(255),
Data datetime,
Population numeric,
New_vaccinations numeric,
RollingTotalofVaccinations numeric
)

Insert Into #PercentTotalvaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.Location Order by dea.location, dea.date) as RollingTotalofVaccinations
From [Portofolio Project]..CovidDeaths dea
join [Portofolio Project]..CovidVacinations vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--order by 2,3

Select *,(RollingTotalofVaccinations/Population)*100 as RollingPercentofVaccinations
From #PercentTotalvaccinations


--Creating view too store data for later visualiztaions
Create View PercentTotalVaccinations as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.Location Order by dea.location, dea.date) as RollingTotalofVaccinations
From [Portofolio Project]..CovidDeaths dea
join [Portofolio Project]..CovidVacinations vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--order by 2,3