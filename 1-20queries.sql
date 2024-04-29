/*
Найдите номер модели, скорость и размер жесткого диска для всех ПК стоимостью менее 500 дол. Вывести: model, speed и hd
*/

select model, speed, hd from PC where price < 500

***

/*
Найдите производителей принтеров. Вывести: maker 
*/

select distinct maker from Product
where type = 'Printer'

***

/*
Найдите номер модели, объем памяти и размеры экранов ПК-блокнотов, цена которых превышает 1000 дол.
*/

Select model, ram, screen from Laptop
where price > 1000

***

/*
Найдите все записи таблицы Printer для цветных принтеров
*/

Select * from Printer
where color = 'y'

***

/*
Найдите номер модели, скорость и размер жесткого диска ПК, имеющих 12x или 24x CD и цену менее 600 дол. 
*/
  
select model, speed, hd from PC
where price < 600 and (cd = '12x' or cd = '24x')

***

/*
Для каждого производителя, выпускающего ПК-блокноты c объёмом жесткого диска не менее 10 Гбайт, найти скорости таких ПК-блокнотов. Вывод: производитель, скорость. 
*/
  
select distinct maker, speed from product
left join Laptop on Laptop.Model = Product.Model
where hd >= 10

***

/*
Найдите номера моделей и цены всех имеющихся в продаже продуктов (любого типа) производителя B (латинская буква).
*/

select distinct Laptop.model, price from Laptop
left join Product on Laptop.Model = Product.Model
where maker = 'B'

union all

select distinct  PC.model, price from PC
left join Product on PC.Model = Product.Model
where maker = 'B'

union all

select distinct  Printer.model, price from Printer
left join Product on printer.Model = Product.Model
where maker = 'B'

***

/*
Найдите производителя, выпускающего ПК, но не ПК-блокноты. 
*/

select distinct maker from Product
where type = 'PC' and maker not in (
  select distinct maker from Product
  where type = 'Laptop'
)

***

/*
Найдите производителей ПК с процессором не менее 450 Мгц. Вывести: Maker
*/

select distinct maker from Product
inner join PC on Product.Model = PC.Model
where speed >= 450

***

/*
Найдите модели принтеров, имеющих самую высокую цену. Вывести: model, price 
*/

select model, price from Printer
where price = (select max(price) from Printer)

***

/*
Найдите среднюю скорость ПК.
*/ 
  
Select avg(speed) from PC

***

/*
Найдите среднюю скорость ПК-блокнотов, цена которых превышает 1000 дол.
*/ 

Select avg(speed) from Laptop
where price > 1000

***

/*
Найдите среднюю скорость ПК, выпущенных производителем A.
*/ 

select avg(speed) from PC
inner join Product on PC.Model = Product.Model
where maker = 'A'

***

/*
Найдите класс, имя и страну для кораблей из таблицы Ships, имеющих не менее 10 орудий. 
*/

select Ships.class, Ships.name, Classes.country from Ships
inner join Classes on Ships.class = Classes.class
where numGuns >= 10

***

/*
Найдите размеры жестких дисков, совпадающих у двух и более PC. Вывести: HD 
*/
  
select hd from PC
group by hd
having count(hd) > 1

***

/*
Найдите пары моделей PC, имеющих одинаковые скорость и RAM. 
В результате каждая пара указывается только один раз, т.е. (i,j), но не (j,i).
Порядок вывода: модель с большим номером, модель с меньшим номером, скорость и RAM.
*/

Select distinct PC1.model, PC2.model, PC1.speed, PC1.ram from PC as PC1, PC as PC2
where PC1.speed = PC2.speed and PC1.Ram = PC2.Ram and PC1.model > PC2.Model


***

/*
Найдите модели ПК-блокнотов, скорость которых меньше скорости каждого из ПК.
Вывести: type, model, speed
*/ 

select distinct type, Laptop.model, speed from Laptop
inner join Product on Laptop.model = Product.model
where speed < (select min(speed) from PC)
  
***

/*
Найдите производителей самых дешевых цветных принтеров. Вывести: maker, price 
*/ 

Select distinct maker, price from Product 
inner join Printer on Product.Model = Printer.Model
where color = 'y' and price = (
  select min(price) from Printer
  where color = 'y'
)

***

/*
Для каждого производителя, имеющего модели в таблице Laptop, найдите средний размер экрана выпускаемых им ПК-блокнотов.
Вывести: maker, средний размер экрана.
*/ 
  
select distinct maker, avg(screen) from Laptop
inner join Product on Laptop.model = Product.model
group by maker

***

/*
Найдите производителей, выпускающих по меньшей мере три различных модели ПК. Вывести: Maker, число моделей ПК
*/ 
  
select maker, count(model) from Product
where type = 'pc'
group by maker
having count(*) > 2
