/* Looking at CovidDeaths
Select the data that I'm going to be using */

SELECT location, continent, date, total_cases, new_cases, total_deaths, population
FROM COVID_Data_Analysis..CovidDeaths
ORDER BY 1,2;

/* Looking at Total Cases VS Total Deaths (Death Percentage) */

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM COVID_Data_Analysis..CovidDeaths
ORDER BY 1, 2;


/* Total Cases VS Total Deaths (Death Percentage) by continent */

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM COVID_Data_Analysis..CovidDeaths
WHERE continent IS NULL
ORDER BY 1, 2;

/* Looking at Death Percentage in specific country */

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM COVID_Data_Analysis..CovidDeaths
WHERE location LIKE '%france%'
ORDER BY date;

/* Looking at Total Cases VS Population (Infection rate) in a specific country */

SELECT location, date, total_cases, population, (total_cases/population)*100 AS Infected_Percentage
FROM COVID_Data_Analysis..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY Infected_Percentage;

/* Maximum Total Cases by country */

SELECT location, MAX(total_cases) AS Maximum_Cases, population
FROM COVID_Data_Analysis..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population;

/* Maximum total cases by continent */

SELECT location, MAX(total_cases) AS MaximumCases, population
FROM COVID_Data_Analysis..CovidDeaths
Where continent IS NULL
GROUP BY location, population;

/* Which country has the highest Infection Rates */

SELECT location, MAX(total_cases) AS Maximum_Cases, population, MAX((total_cases/population))*100 AS Infected_Percentage
FROM COVID_Data_Analysis..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Infected_Percentage DESC;

/* Which continent has the highest Infection Rates */

SELECT location, MAX(total_cases) AS Maximum_Cases, population, MAX((total_cases/population))*100 AS Infected_Percentage
FROM COVID_Data_Analysis..CovidDeaths
WHERE continent IS NULL
GROUP BY location, population
ORDER BY Infected_Percentage DESC;

/* Infection Rates by country (using nested query) */

SELECT location, (Maximum_Cases/population)*100 AS Infection_Rate
FROM (Select location, MAX(total_cases) AS Maximum_Cases, population
		FROM COVID_Data_Analysis..CovidDeaths
		WHERE continent IS NOT NULL
		GROUP BY location, population) AS Max_Total_Cases
ORDER BY Infection_Rate DESC;

/* Total Deaths by countries */

SELECT location, MAX(cast(total_deaths AS INT)) AS Total_Deaths
FROM COVID_Data_Analysis..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Deaths DESC;

/* Total Deaths VS Population (Death Rate) */

SELECT location, MAX(cast(total_deaths AS INT)) AS Total_Deaths, population, MAX(total_deaths/population)*100 AS Death_Rate
FROM COVID_Data_Analysis..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Death_Rate DESC

/* Total Deaths by continent */

SELECT location, MAX(cast(total_deaths AS INT)) AS Total_Deaths
FROM COVID_Data_Analysis..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY Total_Deaths DESC;

/* Continents with Highest Death Count per Population */

SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeaths, population, MAX(total_deaths/population)*100 AS DeathRate
FROM COVID_Data_Analysis..CovidDeaths
WHERE continent IS NULL
GROUP BY location, population
ORDER BY DeathRate DESC

/* GLOBAL NUMBERS */

/* 3Total New Cases and New Deaths by date globaly */

SELECT date, SUM(new_cases) AS New_Cases, SUM(cast(new_deaths AS INT)) AS New_Deaths
FROM COVID_Data_Analysis..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1;

/* Getting Total New Cases and New Deaths from the dataset to check the correctness of the calculations 
(the dataset includes this information clearly) */

SELECT date, location, new_cases, new_deaths
FROM COVID_Data_Analysis..CovidDeaths
WHERE location = 'world'
ORDER BY 1;

/* Getting Total Cases and Total Deaths from the dataset by date globally */

SELECT date, location, total_cases, total_deaths
FROM COVID_Data_Analysis..CovidDeaths
WHERE location = 'world'
ORDER BY 1;

/* Look at the Vaccinations */

SELECT *
FROM COVID_Data_Analysis..CovidVaccinations;

/* Looking at Total Population (from CovidDeaths) VS Accumulating Total Vaccinations (from CovidVaccinations)
Using JOIN tables for practice
Accumulating Total Vaccinations are calculated from the New Vaccinations (rolling sum) */

SELECT dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_total_vaccinations
FROM COVID_Data_Analysis..CovidDeaths dea
JOIN COVID_Data_Analysis..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL -- and vac.new_vaccinations IS NOT NULL
ORDER BY 1,2;

/* Looking at number of Total Vaccinations VS Population */

SELECT dea.location, dea.population, MAX(CAST(vac.total_vaccinations AS BIGINT)) AS total_vacs
FROM COVID_Data_Analysis..CovidDeaths dea
JOIN COVID_Data_Analysis..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.location, dea.population
ORDER BY 1,2;

/* Calculating Vaccination Rate (fully vaccinated people) for each country using nested query */

SELECT location, (total_vacs/population)*100 as vaccination_rate
FROM (SELECT dea.location, dea.population, MAX(CAST(vac.people_fully_vaccinated AS BIGINT)) AS total_vacs
		FROM COVID_Data_Analysis..CovidDeaths dea
		JOIN COVID_Data_Analysis..CovidVaccinations vac
			ON dea.location = vac.location
			AND dea.date = vac.date
		WHERE dea.continent IS NOT NULL
		GROUP BY dea.location, dea.population) AS total_vacs_vs_pop
ORDER BY vaccination_rate DESC;

/* Calculating Vaccination Rate (fully vaccinated people) for each country using CTE (common table expression) */

WITH total_vacs_vs_pop (location, population, total_vacs)
AS
(
SELECT dea.location, dea.population, MAX(CAST(vac.people_fully_vaccinated AS BIGINT)) AS total_vacs
		FROM COVID_Data_Analysis..CovidDeaths dea
		JOIN COVID_Data_Analysis..CovidVaccinations vac
			ON dea.location = vac.location
			AND dea.date = vac.date
		WHERE dea.continent IS NOT NULL
		GROUP BY dea.location, dea.population
)
SELECT location, (total_vacs/population)*100 as vaccination_rate
FROM total_vacs_vs_pop
ORDER BY vaccination_rate DESC;

/* New Cases (from CovidDeaths) VS New Vaccinations (from CovidVaccinations), practicing JOIN tables */

SELECT dea.location, dea.date, dea.new_cases, vac.new_vaccinations
FROM COVID_Data_Analysis..CovidDeaths dea
JOIN COVID_Data_Analysis..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2

/* Countries by Starting Vaccination Date */

SELECT location, MIN(date) as Starting_Date
FROM COVID_Data_Analysis..CovidVaccinations
WHERE new_vaccinations IS NOT NULL AND continent IS NOT NULL
GROUP BY location
ORDER BY Starting_Date;

/* Population Density VS Reproduction Rate using JOIN and aggregate functions */

SELECT dea.location, MAX(vac.population_density) AS PopulationDensity, MAX(dea.reproduction_rate) AS Maximum_Reproduction_Rate
FROM COVID_Data_Analysis..CovidDeaths dea
JOIN COVID_Data_Analysis..CovidVaccinations vac
	ON dea.location = vac.location
WHERE dea.continent IS NOT NULL AND dea.reproduction_rate IS NOT NULL AND vac.population_density IS NOT NULL
GROUP BY dea.location
ORDER BY Maximum_Reproduction_Rate DESC;

/* Population Density by country */

SELECT location, MAX(population_density) AS Population_Density
FROM COVID_Data_Analysis..CovidVaccinations
WHERE continent IS NOT NULL AND population_density IS NOT NULL
GROUP BY location
ORDER  BY Population_Density DESC;

/* Maximum Reproduction Rate by country */

SELECT location, MAX(reproduction_rate) AS Reproduction_Rate
FROM COVID_Data_Analysis..CovidDeaths
WHERE continent IS NOT NULL AND reproduction_rate IS NOT NULL AND ISNUMERIC(reproduction_rate) = 1
GROUP BY location
ORDER  BY Reproduction_Rate	DESC;

/* Population Density VS Maximum Reproduction Rate using nested query */

SELECT PopDens.location, PopDens.Population_Density, RepRate.Reproduction_Rate
FROM (SELECT location, MAX(population_density) AS Population_Density
		FROM COVID_Data_Analysis..CovidVaccinations
		WHERE continent IS NOT NULL AND population_density IS NOT NULL
		GROUP BY location) AS PopDens
			JOIN (SELECT location, MAX(reproduction_rate) AS Reproduction_Rate
		FROM COVID_Data_Analysis..CovidDeaths
		WHERE continent IS NOT NULL AND reproduction_rate IS NOT NULL
		GROUP BY location) AS RepRate
	ON PopDens.location = RepRate.location
GROUP BY PopDens.location, PopDens.Population_Density, RepRate.Reproduction_Rate
ORDER BY RepRate.Reproduction_Rate DESC;

/* See the whole datasets */

SELECT *
FROM COVID_Data_Analysis..CovidVaccinations;

SELECT *
FROM COVID_Data_Analysis..CovidDeaths;

/* Creating View to store data for later visualisations */

CREATE VIEW Vaccination_Percentage AS
SELECT location, (total_vacs/population)*100 as vaccination_rate
FROM (SELECT dea.location, dea.population, MAX(CAST(vac.people_fully_vaccinated AS BIGINT)) AS total_vacs
		FROM COVID_Data_Analysis..CovidDeaths dea
		JOIN COVID_Data_Analysis..CovidVaccinations vac
			ON dea.location = vac.location
			AND dea.date = vac.date
		WHERE dea.continent IS NOT NULL
		GROUP BY dea.location, dea.population) AS total_vacs_vs_pop;

/*

Queries used for Tableau visualizations

Tableau Dashboard: https://public.tableau.com/app/profile/george3027/viz/COVID_Data_Analysis/COVIDDataDashboard

*/

/* Total Cases, Total Deaths and Average Death Percentage GLOBALLY */

SELECT MAX(total_cases) AS Total_Cases, MAX(CAST(total_deaths AS FLOAT)) AS Total_Deaths, (MAX(CAST(total_deaths AS FLOAT))/MAX(total_cases))*100 AS Avg_Death_Percentage
FROM COVID_Data_Analysis..CovidDeaths
WHERE location = 'world';

/* Total Deaths by continent by the end of the survey */

SELECT location, MAX(CAST(total_deaths AS BIGINT)) AS Total_Deaths
FROM COVID_Data_Analysis..CovidDeaths
WHERE continent IS NULL AND location NOT IN ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY Total_Deaths DESC;

/* Final Total Cases VS Total Deaths (Death Percentage) by the end of the survey period */

SELECT location, MAX(total_cases) AS Total_Cases, MAX(CAST(total_deaths AS BIGINT)) AS Total_Deaths, MAX(CAST(total_deaths AS BIGINT))/MAX(total_cases)*100 AS Final_Death_Percentage
FROM COVID_Data_Analysis..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Final_Death_Percentage DESC;

/* Total Percent of Population Infected by country */

SELECT location, population, MAX(total_cases) as Total_Infected_People, (MAX(total_cases)/population)*100 as Percent_Population_Infected
FROM COVID_Data_Analysis..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Percent_Population_Infected DESC;

/* Maximum Reproduction Rate by country */

SELECT location, MAX(reproduction_rate) AS Reproduction_Rate
FROM COVID_Data_Analysis..CovidDeaths
WHERE continent IS NOT NULL AND reproduction_rate IS NOT NULL AND ISNUMERIC(reproduction_rate) = 1
GROUP BY location
ORDER  BY Reproduction_Rate	DESC;

/* Infection Rate by date in each country */

SELECT location, date, population, total_cases, (total_cases/population)*100 AS Percent_Of_Population_Infected
FROM COVID_Data_Analysis..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

/* People Fully Vaccinated by date in each country */

SELECT location, date, people_fully_vaccinated
FROM COVID_Data_Analysis..CovidVaccinations
WHERE continent IS NOT NULL AND people_fully_vaccinated IS NOT NULL
ORDER BY 1,2;

/* Death Percentage (Cases VS Deaths) by date in each country */

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM COVID_Data_Analysis..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

