select * from Indian_Census..data1;

select * from Indian_Census..data2;

--Total Number of rows present into dataset

select count(*) from Indian_Census..Data1;

select count(*) from Indian_Census..Data2;

--Dataset for Jharkhand and Bihar

select * from Indian_Census..data1
where State in ('Jharkhand','Bihar');

select * from Indian_Census..data2
where State in ('Jharkhand','Bihar');

--population of India

select sum(population) as Total_Population from Indian_Census..Data2;


--Average growth of India

select round(AVG(growth)*100,2) as [Average Growth] from Indian_Census..Data1;

--average growth by state

select state, round(AVG(growth)*100,2) as [Average Growth] 
from Indian_Census..Data1
group by State;

--average sex ratio per state

select state, round(avg(sex_ratio),2) as [Average Sex Ratio]
from Indian_Census..Data1
group by State
order by [Average Sex Ratio] desc;


--Average literacy rate per state

select state, round(avg(Literacy),2) as [Average Literacy Rate]
from Indian_Census..Data1
group by State
order by [Average Literacy Rate] desc;

--average literacy rate > 90

select state, round(avg(Literacy),2) as [Average Literacy Rate]
from Indian_Census..Data1
group by State
having round(avg(Literacy),2) > 90
order by [Average Literacy Rate] desc;

-- top 3 states with highest growth ratio

select top 3 state, round(AVG(growth)*100,2) as [Average Growth] 
from Indian_Census..Data1
group by State
order by [Average Growth] desc;

-- bottom 3 states with lowest sex ratio

select top 3 state, round(avg(sex_ratio),2) as [Average Sex Ratio]
from Indian_Census..Data1
group by State
order by [Average Sex Ratio] asc;

--Display top 3 and bottom 3 states with literacy rate

drop table if exists #topstates;
create table #topstates
( state nvarchar(255),
topstates float
)

insert into #topstates 
select state, round(AVG(literacy),2) as [Average Literacy] 
from Indian_Census..Data1
group by State
order by [Average Literacy] desc;

select top 3 * from #topstates
order by topstates desc;



drop table if exists #bottomstates;
create table #bottomstates
( state nvarchar(255),
bottomstates float
)

insert into #bottomstates 
select state, round(AVG(literacy),2) as [Average Literacy] 
from Indian_Census..Data1
group by State
order by [Average Literacy] desc;

select top 3 * from #bottomstates
order by bottomstates asc;

select * from(
select top 3 * from #topstates
order by topstates desc) a
Union
select * from (
select top 3 * from #bottomstates
order by bottomstates asc) b

or 


select * from (
select top 3 state, round(avg(Literacy),2) as [Average Literacy Rate]
from Indian_Census..Data1
group by State
order by [Average Literacy Rate] desc) a
union
select * from (
select top 3 state, round(avg(Literacy),2) as [Average Literacy Rate]
from Indian_Census..Data1
group by State
order by [Average Literacy Rate] asc) b;

--states starting with letter a

select distinct state from Indian_Census..Data1
where lower(state) like 'a%';

--states starting with letter a or b

select distinct state from Indian_Census..Data1
where lower(state) like 'a%' or lower(state) like 'b%';

--states starting with letter a or ending with letter d

select distinct state from Indian_Census..Data1
where lower(state) like 'a%' or lower(state) like '%d'

--states starting with letter a and ending with letter m

select distinct state from Indian_Census..Data1
where lower(state) like 'a%' and lower(state) like '%m'

-- No. of males and no. of females

select d.state,sum(d.males) as total_males,sum(d.females) as total_females from 
(select district,state, round(population/(sex_Ratio + 1),0) as males, round((population*Sex_Ratio)/(Sex_Ratio+1),0) as females from
(select a.district, a.state,round(cast(a.sex_ratio as float)/1000,2) as sex_ratio, b.population
from Indian_Census..Data1 a
inner join Indian_Census..Data2 b on a.District = b.District) c) d
group by state;

-- total literacy rate

select state, sum(literate_people) as total_literate_people, sum(illiterate_people) as total_illiterate_people from
(select district,state,round(literacy_ratio*population,0) as Literate_people, round((1-literacy_ratio)*population,0) as Illiterate_people from
(select a.district, a.state,round(a.Literacy/100,2) as literacy_ratio, b.population
from Indian_Census..Data1 a
inner join Indian_Census..Data2 b on a.District = b.District)c)d
group by State

--population in previous census

select state, sum(previous_census_population) as previous_census_population, sum(current_census_population) as current_census_population from 
(select district, state, round(population/(1+growth),0) as previous_census_population,population as current_census_population from
(select a.district, a.state,a.growth, b.population
from Indian_Census..Data1 a
inner join Indian_Census..Data2 b on a.District = b.District) c) d
group by state;

--total population in previous and current census

select sum(previous_census_population) as total_previous_census_population, sum(current_census_population) as total_current_census_population from 
(select state, sum(previous_census_population) as previous_census_population, sum(current_census_population) as current_census_population from 
(select district, state, round(population/(1+growth),0) as previous_census_population,population as current_census_population from
(select a.district, a.state,a.growth, b.population
from Indian_Census..Data1 a
inner join Indian_Census..Data2 b on a.District = b.District) c) d
group by state)e;

--window: output top 3 district from each state with highest literacy rate.

select a.* from
(select district, state, literacy, rank() over (partition by state order by literacy desc) as rank
from Indian_Census..Data1) a
where a.rank in (1,2,3)
order by a.State;



