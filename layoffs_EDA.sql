-- EDA

-- when the lay offs started
select min(`date`), max(`date`)
from layoffs_staging2
;

-- max and min layoff
select min(total_laid_off), max(total_laid_off)
from layoffs_staging2
;

-- max and min by year
select year(`date`) as `year`, min(total_laid_off), max(total_laid_off)
from layoffs_staging2
group by year(`date`)
;

-- total a year
select year(`date`) as `year`, sum(total_laid_off) as total_laid_off
from layoffs_staging2
group by year(`date`)
order by 2 desc
;

-- companies shut down per year
select year(`date`), count(*) as amount
from layoffs_staging2
where percentage_laid_off = 1
group by year(`date`)
order by amount
;

-- laid off by industry
select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc
;

-- laid of by country
select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc
;

-- laid off by company
select company, sum(total_laid_off) as total_laid_off
from layoffs_staging2
group by company
order by total_laid_off desc
;

-- both do the same thing
select substring(`date`,1,7) as `month`, sum(total_laid_off) as total_off,
sum(sum(total_laid_off)) over(order by substring(`date`,1,7)) as rolling_total
from layoffs_staging2
where substring(`date`,1,7) is not null
group by substring(`date`,1,7)
order by 1;

with rolling_total as
(select substring(`date`,1,7) as `month`, sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`,1,7) is not null
group by substring(`date`,1,7)
order by 1)
select `month`, total_off, sum(total_off) over(order by `month`) as rolling_total
from rolling_total
;

-- sum by company
select company, sum(total_laid_off) as total_laidoff
from layoffs_staging2
group by company 
order by total_laidoff desc
;

-- top company by year
with company_year (company, years, total_laid_off) as
(select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)), company_year_rank as
(select *, dense_rank() over(partition by years order by total_laid_off desc) as ranking
from company_year
where years is not null)
select *
from company_year_rank
where ranking <= 5;