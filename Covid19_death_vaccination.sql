USE  PortfolioProject;

SELECT location, date, total_cases, new_cases, total_deaths, population, total_deaths/total_cases*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
ORDER BY location, date

-- death percentage in Hong Kong
SELECT location, date, total_cases, total_deaths, population, total_deaths/total_cases*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%hong%'
ORDER BY location, date;

-- infection percentage in Hong Kong
SELECT location, date, population, total_cases, total_cases/population*100 AS infection_rate
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%hong%'
ORDER BY location, date;

-- country with highest infection rate compared to population
SELECT location, population, total_cases, total_cases/ population * 100 AS highest_infection_rate
FROM PortfolioProject..CovidDeaths
WHERE total_cases/ population * 100 = 
	(SELECT MAX (total_cases/ population * 100)
	FROM CovidDeaths)
ORDER BY location, date;

-- country with top infection rate compared to population
SELECT location, population, MAX(total_cases) AS infection_count, MAX(total_cases/ population) * 100 AS infection_rate
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY infection_rate DESC;

-- country with top death count compared 
SELECT location, MAX(CAST (total_deaths AS INT)) AS death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY death_count DESC;

-- continent with top death count compared 
SELECT location, MAX(CAST (total_deaths AS INT)) AS death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY death_count DESC;

-- global number
SELECT date, SUM(new_cases) AS total_case, SUM(CAST (new_deaths AS INT)) AS total_death, SUM(CAST (new_deaths AS INT))/SUM(new_cases) *100 AS case_fatality_rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

-- vacination 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
		SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_vaccination_count
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY d.location, d.date;

-- CTE
WITH pop_vaccination (continent, location, date, population, new_vaccinations, rolling_vaccination_count) AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
		SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_vaccination_count
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
)

SELECT *, rolling_vaccination_count/ population * 100 AS rolling_vac_pct
FROM pop_vaccination;

---- temp table
DROP TABLE IF EXISTS #pop_vaccination;
CREATE TABLE  #pop_vaccination
(
continent VARCHAR(255),
location VARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
rolling_vaccination_count NUMERIC
)
INSERT INTO #pop_vaccination (continent, location, date, population, new_vaccinations, rolling_vaccination_count) 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
		SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_vaccination_count
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL;

-- create view
CREATE VIEW  pop_vaccination AS
--(continent, location, date, population, new_vaccinations, rolling_vaccination_count) 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
		SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_vaccination_count
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL