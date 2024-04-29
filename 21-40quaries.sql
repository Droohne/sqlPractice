/*
Найдите максимальную цену ПК, выпускаемых каждым производителем, у которого есть модели в таблице PC.
Вывести: maker, максимальная цена.hd
*/

select maker, max(price) from Product
inner join PC on Product.model = PC.model
group by maker

***

/*
Для каждого значения скорости ПК, превышающего 600 МГц, определите среднюю цену ПК с такой же скоростью.
Вывести: speed, средняя цена. */
  
select speed, avg(price) from PC
where speed > 600
group by speed

***

/*
Найдите производителей, которые производили бы как ПК
со скоростью не менее 750 МГц, так и ПК-блокноты со скоростью не менее 750 МГц.
Вывести: Make
*/

select distinct maker from Product
inner join PC on PC.model = Product.Model
where PC.speed >= 750

intersect

select distinct  maker from Product
inner join Laptop on Laptop.model = Product.Model
where speed >= 750

***

/*
Перечислите номера моделей любых типов, имеющих самую высокую цену по всей имеющейся в базе данных продукции. 
*/

with cte as (

select model, price from PC

union all

select model, price from Laptop

union all

select model, price from Printer
)

select model from cte
where price  = (select max(price) from cte)
group by model


***

/*
Найдите производителей принтеров, которые производят ПК с наименьшим объемом RAM и с самым быстрым процессором среди всех ПК,имеющих наименьший объем RAM. Вывести: Maker
*/
  
SELECT maker FROM Product
WHERE model IN (SELECT model FROM PC WHERE speed =
(SELECT MAX(speed) FROM PC WHERE ram = 
(SELECT MIN(ram) FROM PC))
AND ram = (SELECT MIN(ram) FROM PC))
 	AND maker IN (SELECT p.maker FROM Product p WHERE p.type='Printer')
GROUP BY maker

***

/*
Найдите среднюю цену ПК и ПК-блокнотов, выпущенных производителем A (латинская буква). Вывести: одна общая средняя цена. 
*/
  
select avg(price) from (
select price from Laptop inner join Product on Product.model = Laptop.model
where maker = 'A'
union all
select price from PC inner join Product on Product.model = PC.model
where maker = 'A'
) as t

***

/*
Найдите средний размер диска ПК каждого из тех производителей, которые выпускают и принтеры. Вывести: maker, средний размер HD. 
*/

select distinct maker, avg(hd) from Product
inner join PC on Product.Model = PC.model
where maker in (select distinct maker from Product
where type = 'Printer')
group by maker

***

/*
Используя таблицу Product, определить количество производителей, выпускающих по одной модели. 
*/
  
select count(maker)
from product
where maker in
(
  Select maker from product
  group by maker
  having count(model) = 1
)

***

/*
В предположении, что приход и расход денег на каждом пункте приема фиксируется не чаще одного раза в день [т.е. первичный ключ (пункт, дата)],
написать запрос с выходными данными (пункт, дата, приход, расход). Использовать таблицы Income_o и Outcome_o. 
*/

SELECT inc.point, inc.date, inc, out
FROM income_o inc LEFT JOIN outcome_o out ON inc.point = out.point
AND inc.date = out.date
UNION
SELECT out.point, out.date, inc, out
FROM income_o inc RIGHT JOIN outcome_o out ON inc.point = out.point
AND inc.date = out.date

***

/*
В предположении, что приход и расход денег на каждом пункте приема фиксируется произвольное число раз (первичным ключом в таблицах является столбец code), 
  требуется получить таблицу, в которой каждому пункту за каждую дату выполнения операций будет соответствовать одна строка.
Вывод: point, date, суммарный расход пункта за день (out), суммарный приход пункта за день (inc). Отсутствующие значения считать неопределенными (NULL). 
*/
  
select point, date, SUM(sumOut), SUM(sumInc) from (
select point, date, SUM(inc) as sumInc, null as sumOut from Income
group by point, date
Union
select point, date, null as sumInc, SUM(out) as sumOut from Outcome
group by point, date
) as t
group by point, date

***

/*
Для классов кораблей, калибр орудий которых не менее 16 дюймов, укажите класс и страну.
*/ 

select distinct class, country from Classes
where bore >= 16

***

/*
Одной из характеристик корабля является половина куба калибра его главных орудий (mw). 
С точностью до 2 десятичных знаков определите среднее значение mw для кораблей каждой страны, у которой есть корабли в базе данных.
*/
  
Select country, cast(avg((power(bore,3)/2)) as numeric(6,2)) as weight
from (select country, classes.class, bore, name from classes left join ships on classes.class=ships.class
union all
select distinct country, class, bore, ship from classes t1 left join outcomes t2 on t1.class=t2.ship
where ship=class and ship not in (select name from ships) ) a
where name IS NOT NULL group by country

***

/*
Укажите корабли, потопленные в сражениях в Северной Атлантике (North Atlantic). Вывод: ship
*/

Select ship from Outcomes where battle = 'North Atlantic' and result = 'sunk'

***

/*
По Вашингтонскому международному договору от начала 1922 г. запрещалось строить линейные корабли водоизмещением более 35 тыс.тонн. 
Укажите корабли, нарушившие этот договор (учитывать только корабли c известным годом спуска на воду). Вывести названия кораблей.
*/ 

Select name from classes,ships where launched >=1922 and displacement>35000 and type='bb' and
ships.class = classes.class

  
***

/*
В таблице Product найти модели, которые состоят только из цифр или только из латинских букв (A-Z, без учета регистра).
Вывод: номер модели, тип модели. 
*/ 

select distinct model, type from Product
where (model LIKE '%[0-9]%' and model  NOT LIKE '%[^0-9]%') or 
(model LIKE '%[a-z]%' and model  NOT LIKE '%[^a-z]%')

***

/*
Перечислите названия головных кораблей, имеющихся в базе данных (учесть корабли в Outcomes). 
*/ 
  
select name from ships inner join classes on classes.class = ships.class
where ships.name = ships.class
union
select ship as name from Outcomes inner join classes on classes.class = Outcomes.ship
where Outcomes.ship = classes.class

***

/*
Найдите классы, в которые входит только один корабль из базы данных (учесть также корабли в Outcomes).
*/ 
  
Select 
	c.class 
From Classes c
Left Join (Select class, name 
	From Ships
	Union
Select 
	Classes.class as class, Outcomes.ship as name
From Outcomes
Join Classes ON Outcomes.ship = Classes.class) as s On c.class = s.class
Group by c.class
Having count(s.name)=1

***

/*
Найдите страны, имевшие когда-либо классы обычных боевых кораблей ('bb') и имевшие когда-либо классы крейсеров ('bc').
*/ 
  
Select distinct country from Classes
where type = 'bb'
intersect
Select distinct country from Classes
where type = 'bc'


***

/*
Найдите корабли, `сохранившиеся для будущих сражений`;
  т.е. выведенные из строя в одной битве (damaged), они участвовали в другой, произошедшей позже. 
*/ 
Select distinct O.ship
From Outcomes as O 
inner join Battles as B on O.battle=B.name
where O.ship in(
Select O1.ship
From Outcomes O1 inner join Battles as B1 on O1.battle=B1.name
Where O1.result = 'damaged' and B.date>B1.date
)

***

/*
Найти производителей, которые выпускают более одной модели, при этом все выпускаемые производителем модели являются продуктами одного типа.
Вывести: maker, type
*/ 
  
select distinct maker, type from Product
where maker in (
select maker from Product
group by maker
having count(model) > 1 and count(distinct type) = 1
)
