/*
Для каждого производителя, у которого присутствуют модели хотя бы в одной из таблиц PC, Laptop или Printer,
определить максимальную цену на его продукцию.
Вывод: имя производителя, если среди цен на продукцию данного производителя присутствует NULL, то выводить для этого производителя NULL,
иначе максимальную цену.
*/

with cte as (
select model, price from PC
union
select model, price from Laptop
union
select model, price from Printer
)
Select distinct maker,
CASE 
WHEN MAX(CASE WHEN CTE.price IS NULL THEN 1 ELSE 0 END) = 0 THEN MAX(CTE.price) 
END
from Product
inner join cte on Product.model=cte.model
group by maker

***

/*
Найдите названия кораблей, потопленных в сражениях, и название сражения, в котором они были потоплены.
*/

select ship, battle from Outcomes
where result = 'sunk'

***

/*
Укажите сражения, которые произошли в годы, не совпадающие ни с одним из годов спуска кораблей на воду. 
*/

select distinct Battles.name from Battles
Where year(Battles.date) not in (
	Select launched From Ships
	Where launched is not null
)

***

/*
Найдите названия всех кораблей в базе данных, начинающихся с буквы R. 
*/
  
select name from Ships
where name like 'R%'
union
select ship from Outcomes
where ship like 'R%'


***

/*
Найдите названия всех кораблей в базе данных, состоящие из трех и более слов (например, King George V).
Считать, что слова в названиях разделяются единичными пробелами, и нет концевых пробелов. 
*/
  
select name from Ships
where name like '% % %'
union
select ship from Outcomes
where ship like '% % %'


***

/*
Для каждого корабля, участвовавшего в сражении при Гвадалканале (Guadalcanal), вывести название, водоизмещение и число орудий.
*/
  
SELECT Outcomes.ship, displacement, numGuns 
FROM (
	SELECT name AS ship, displacement, numGuns 
	FROM Ships JOIN Classes ON Classes.class=Ships.class 
	UNION 
	SELECT class AS ship, displacement, numGuns 
	FROM Classes
) AS a RIGHT JOIN Outcomes  ON Outcomes.ship=a.ship 
WHERE battle = 'Guadalcanal'

***

/*
Определить страны, которые потеряли в сражениях все свои корабли.
*/

WITH out AS (SELECT *
FROM outcomes JOIN (SELECT ships.name s_name, classes.class s_class, classes.country s_country
FROM ships FULL JOIN classes
ON ships.class = classes.class
) u
ON outcomes.ship=u.s_class
UNION
SELECT *
FROM outcomes JOIN (SELECT ships.name s_name, classes.class s_class, classes.country s_country
FROM ships FULL JOIN classes
ON ships.class = classes.class
) u
ON outcomes.ship=u.s_name)

SELECT fin.country
FROM (
SELECT DISTINCT t.country, COUNT(t.name) AS num_ships
FROM (
select distinct c.country, s.name
from classes c
inner join Ships s on s.class= c.class
union
select distinct c.country, o.ship
from classes c
inner join Outcomes o on o.ship= c.class) t
GROUP BY t.country

INTERSECT

SELECT out.s_country, COUNT(out.ship) AS num_ships
FROM out
WHERE out.result='sunk'
GROUP BY out.s_country) fin


***

/*
Найдите названия кораблей с орудиями калибра 16 дюймов (учесть корабли из таблицы Outcomes). 
*/

select name from(
    select name, class from ships
    union
    select ship, ship from outcomes
  ) as fullShips
inner join classes C on fullShips.class=C.class
where bore=16


***

/*
Найдите сражения, в которых участвовали корабли класса Kongo из таблицы Ships. 
*/

Select distinct battle from Outcomes
inner join Ships on Outcomes.Ship = Ships.name
where class = 'Kongo'

***

/*
Определить названия всех кораблей из таблицы Ships, которые могут быть линейным японским кораблем,
имеющим число главных орудий не менее девяти, калибр орудий менее 19 дюймов и водоизмещение не более 65 тыс.тонн 
*/
  
with FullShips as (
  select name, class from ships
  union
  select ship, ship from outcomes
)
select
  s.name
  from FullShips s
  inner join classes c on c.class=s.class
  where country='Japan' and type='bb' 
  and isnull(numguns, 9) >= 9
  and isnull(bore, 9) < 19
  and isnull(displacement, 9) <= 65000

***

/*
Определите среднее число орудий для классов линейных кораблей.
Получить результат с точностью до 2-х десятичных знаков. 
*/ 
  
select
  cast(avg(numguns*1.0) as decimal(6,2)) as 'Avg-numGuns' from classes
  where type='bb'


***

/*
С точностью до 2-х десятичных знаков определите среднее число орудий всех линейных кораблей (учесть корабли из таблицы Outcomes). 
*/ 
  
with FullShips as (
  select name, class from ships
  union
  select ship, ship from outcomes
)
select Cast(AVG(NumGuns*1.0) as DECIMAL(6,2)) as 'Avg-numGuns'
from FullShips inner join Classes on Classes.Class = FullSHips.class
where type = 'bb'


***

/*
Найдите среднюю скорость ПК, выпущенных производителем A.
*/ 

select avg(speed) from PC
inner join Product on PC.Model = Product.Model
where maker = 'A'

***

/*
Для каждого класса определите год, когда был спущен на воду первый корабль этого класса. Если год спуска на воду головного корабля неизвестен, 
определите минимальный год спуска на воду кораблей этого класса. Вывести: класс, год
*/
  
select
  c.class, min(launched) "launch year"
  from classes c
  full outer join ships s on c.class=s.class
  group by c.class


***

/*
Для каждого класса определите число кораблей этого класса, потопленных в сражениях. Вывести: класс и число потопленных кораблей. */
  
select
  class, 
  SUM(CASE WHEN result='sunk' THEN 1 ELSE 0 END) as sunks
  from (
    select c.class, name from classes c
      left join ships s on c.class=s.class
    union
    select class, ship from classes
      join outcomes on class=ship
  ) as FullShips
  left join outcomes on FullShips.name=Outcomes.ship
  group by class

***

/*
Для классов, имеющих потери в виде потопленных кораблей и не менее 3 кораблей в базе данных,
вывести имя класса и число потопленных кораблей. 
*/

SELECT c.class, SUM(sh.sunked)
FROM classes c
  LEFT JOIN (
     SELECT t.name AS name, t.class AS class,
           CASE WHEN o.result = 'sunk' THEN 1 ELSE 0 END AS sunked
     FROM
     (
      SELECT name, class
      FROM ships
       UNION
      SELECT ship, ship
      FROM outcomes
     )
     AS t
    LEFT JOIN outcomes o ON t.name = o.ship
  ) sh ON sh.class = c.class
GROUP BY c.class
HAVING COUNT(DISTINCT sh.name) >= 3 AND SUM(sh.sunked) > 0



***

/*
Для каждого типа продукции и каждого производителя из таблицы Product c точностью до двух десятичных знаков найти процентное отношение числа моделей данного типа данного производителя к общему числу моделей этого производителя.
Вывод: maker, type, процентное отношение числа моделей данного типа к общему числу моделей производителя
*/ 

with cteN as (
select distinct maker, Product.type as type, count(distinct Product.model) as c from Product
left join PC on Pc.model = Product.Model
left join Printer on Printer.Model = Product.Model
left join Laptop on Laptop.model = Product.model
group by maker, Product.type
)
select distinct 
	P1.maker,
	P2.type, CAST(100.0*ISNULL((select c from CteN where CteN.maker = P1.maker and CteN.type = P2.type),0) / 
	(select sum(c) from CteN where CteN.maker = P1.maker) as DECIMAL (6,2)) as 'percent' 
from Product P1, Product P2, CteN

  
***

/*
Посчитать остаток денежных средств на каждом пункте приема для базы данных с отчетностью не чаще одного раза в день. Вывод: пункт, остаток. 
*/ 

with cte AS
(
  SELECT pointI, sumI, sumO FROM (SELECT i.point as pointI, SUM(i.inc) as sumI FROM Income_o as i
  GROUP BY i.point) as inc
  LEFT JOIN
  (SELECT o.point as pointO, SUM(o.out) as sumO FROM Outcome_o as o
  GROUP BY o.point) as out
  on pointI = pointO
)
select pointI, sumI - sumO as Remain from cte
)

***

/*
Посчитать остаток денежных средств на начало дня 15/04/01 на каждом пункте приема для базы данных с отчетностью не чаще одного раза в день. Вывод: пункт, остаток.
Замечание. Не учитывать пункты, информации о которых нет до указанной даты.
*/ 
  
with cte AS
(
  SELECT pointI, sumI, sumO FROM (
  SELECT i.point as pointI, SUM(i.inc) as sumI FROM Income_o as i
  WHERE i.date < '15/04/01'
  GROUP BY i.point) as inc
  LEFT JOIN
  (SELECT o.point as pointO, SUM(o.out) as sumO FROM Outcome_o as o
   WHERE o.date < '15/04/01'
   GROUP BY o.point
  ) as out
  on pointI = pointO
)
select pointI, sumI - sumO as Remain from cte
