CREATE DATABASE CENSUS

USE DATABASE CENSUS;

CREATE OR REPLACE TABLE DATA1
(
District VARCHAR(40),
State VARCHAR(40),
Growth NUMBER(5,2),
Sex_Ratio INT,
Literacy FLOAT
)


CREATE OR REPLACE TABLE DATA2
(
District VARCHAR(60),
State VARCHAR(60),
Area INT,
Population INT
);


SELECT * FROM DATA1;

SELECT * FROM DATA2;

SELECT COUNT(*) FROM DATA1;

SELECT COUNT(*) FROM DATA2;


-----****dataset for jharkhand and bihar*******-------

SELECT * FROM DATA1
WHERE STATE IN ('Jharkhand', 'Bihar');


----***** population of India*********-------

SELECT SUM(POPULATION) AS TOTAL_POPULATION FROM DATA2;


----***** avg growth********---------

SELECT ROUND(AVG(GROWTH),2) AS AVERAGE_GROWTH FROM DATA1;


----******* avg sex ratio***********----------


SELECT STATE, ROUND(AVG(SEX_RATIO),0) AS AVERAGE_SEX_RATIO FROM DATA1
GROUP BY 1
ORDER BY 2 DESC;


------*******avg literacy rate*********----------


SELECT * FROM DATA1;

SELECT STATE,ROUND(AVG(LITERACY),0) AS AVERAGE_LITERACY FROM DATA1
GROUP BY 1
HAVING AVERAGE_LITERACY>90
ORDER BY 2 DESC;


----******** top 3 state showing highest growth ratio********----------


SELECT STATE,ROUND(AVG(GROWTH),2) AS AVERAGE_GROWTH FROM DATA1
GROUP BY 1
ORDER BY 2 DESC LIMIT 3;


----********bottom 3 state showing lowest sex ratio**********---------


SELECT STATE,ROUND(AVG(SEX_RATIO),2) AS AVERAGE_SEX_RATIO FROM DATA1
GROUP BY 1
ORDER BY 2 LIMIT 3;



--------******top and bottom 3 states in literacy state*********-----------

-------*******insert into #TOPtates**********--------


CREATE OR REPLACE TABLE TOPSTATES
(
STATE VARCHAR(50),
RATE FLOAT
);


INSERT INTO TOPSTATES
(
SELECT STATE,ROUND(AVG(LITERACY),2) AS AVERAGE_LITERACY FROM DATA1
GROUP BY 1
ORDER BY 2 DESC
);

SELECT TOP 3 * FROM TOPSTATES;


-------*******insert into #bottomstates**********--------


CREATE OR REPLACE TABLE BOTTOMSTATES
(
STATE VARCHAR(50),
RATE FLOAT
);


INSERT INTO BOTTOMSTATES
(
SELECT STATE,ROUND(AVG(LITERACY),2) AS AVERAGE_LITERACY FROM DATA1
GROUP BY 1
ORDER BY 2
);


-------*******union**********--------


SELECT TOP 3 * FROM BOTTOMSTATES

SELECT * FROM 
(SELECT TOP 3 * FROM TOPSTATES)
UNION
SELECT * FROM 
(SELECT TOP 3 * FROM BOTTOMSTATES);



----****** states starting with letter a**********--------


SELECT * FROM DATA1;

SELECT DISTINCT STATE FROM DATA1
WHERE STATE LIKE 'A%'

SELECT DISTINCT STATE FROM DATA1
WHERE STATE LIKE 'A%' OR STATE LIKE 'B%'

SELECT DISTINCT STATE FROM DATA1
WHERE STATE LIKE 'A%' and STATE LIKE '%m'


SELECT * FROM DATA1;
SELECT * FROM DATA2;


SELECT DISTRICT, STATE, ROUND(POPULATION/(SEX_RATIO+1),0) AS MALES, ROUND(POPULATION*((SEX_RATIO)/(SEX_RATIO+1)),0) AS FEMALES FROM
(
SELECT D1.DISTRICT, D1.STATE,D1.SEX_RATIO/1000 AS SEX_RATIO, D2.POPULATION FROM DATA1 AS D1
INNER JOIN DATA2 AS D2
ON D1.DISTRICT = D2.DISTRICT
)



----********** joining both table***********---------

-------*********total males and females***********-----------


WITH POP(DISTRICT,STATE,MALES,FEMALES)
AS
(SELECT DISTRICT, STATE, ROUND(POPULATION/(SEX_RATIO+1),0) AS MALES, ROUND(POPULATION*((SEX_RATIO)/(SEX_RATIO+1)),0) AS FEMALES FROM
(
SELECT D1.DISTRICT, D1.STATE,D1.SEX_RATIO/1000 AS SEX_RATIO, D2.POPULATION FROM DATA1 AS D1
INNER JOIN DATA2 AS D2
ON D1.DISTRICT = D2.DISTRICT
))
SELECT STATE,SUM(MALES),SUM(FEMALES) FROM POP
GROUP BY 1
ORDER BY 1;


-----**************** total literacy rate***********------------


SELECT STATE,SUM(LITERATE_PEOPLE) AS TOTAL_LITERATE_PEOPLE, SUM(ILLITERATE_PEOPLE) AS TOTAL_ILLITERATE_PEOPLE FROM
(SELECT DISTRICT,STATE, ROUND(LITERACY*POPULATION,0) AS LITERATE_PEOPLE, ROUND((1-LITERACY)*POPULATION,0) AS ILLITERATE_PEOPLE, POPULATION FROM
(SELECT D1.DISTRICT, D1.STATE,D1.LITERACY/100 AS LITERACY, D2.POPULATION FROM DATA1 AS D1
INNER JOIN DATA2 AS D2
ON D1.DISTRICT = D2.DISTRICT))
GROUP BY STATE
ORDER BY 1;


-- ---******population in previous census***********-----------------


with AT (state,pervious_census_population,current_census_population) AS
(select state,sum(pervious_census_population),sum(current_census_population) from
(select district, state,round(population/(1+growth),0) as pervious_census_population, population as current_census_population from
(SELECT D1.DISTRICT, D1.STATE,D1.growth/100 as growth, D2.POPULATION FROM DATA1 AS D1
INNER JOIN DATA2 AS D2
ON D1.DISTRICT = D2.DISTRICT))
group by 1)
SELECT SUM(pervious_census_population) AS pervious_census_population,SUM(current_census_population)AS current_census_population
FROM AT;



----*****window*****----------- 

---*****output top 3 districts from each state with highest literacy rate*******_____________



SELECT * FROM
(SELECT DISTRICT, STATE, LITERACY, RANK() OVER (PARTITION BY STATE ORDER BY LITERACY DESC ) AS RNK FROM DATA1)
WHERE RNK IN(1,2,3)
ORDER BY STATE;
