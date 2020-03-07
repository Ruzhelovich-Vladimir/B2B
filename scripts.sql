/*
 *Итоговая информация по заказам за период
 */
SET @START_DATE='1990-01-01';
SET @FINISH_DATE='1999-12-31';

SELECT 
oh.id as `Номер заказа`
,
CASE 
	WHEN customer.short_name is NULL THEN ""
	ELSE CONCAT(customer.short_name,' ','(',customer.tin,')')  
END `Заказчик`
, NULLIF(customer.phone,'') as `Телефон`
, NULLIF(customer.addr,'') as `Адрес`
, CONCAT(u.surname ,' ',u.first_name) as `Доверенное лицо`
, CONCAT(distributor.short_name,' ','(',distributor.tin,')') as `Дистрибьютор`
, w.name as `Склад`
, pr.name as `Тип цен`
, ROUND(SUM(od.price * od.qry ),2)  as `Сумма`
, ROUND(SUM(g.total_weight * od.qry ),2)  as `Вес`
, ROUND(SUM(g.volume * od.qry ),2)  as `Объём`
, COUNT('x')  as `Количество SKU`

FROM 
b2b.orders_head oh 
inner join orders_details od ON od.orders_head_id = oh.id
inner join trust t ON oh.trust_id = t.id 
inner join users u ON t.id_user = u.id 
left join partners customer ON t.id_partner = customer.id #Оргнизация заказчика не обязательно поле, может заказывать и физ. лицо, поэтому и левое соединение
inner join warehouse w on oh.werehouse_id = w.id 
inner join partners distributor on w.id_partner = distributor.id
inner join prices pr on oh.price_id = pr.id 
inner join goods g on od.good_id = g.id 
WHERE 
oh.created_at between @START_DATE AND @FINISH_DATE
group by 
`Номер заказа`
,`Заказчик`
,`Телефон`
,`Адрес`
,`Доверенное лицо`
,`Дистрибьютор`
,`Склад`
,`Тип цен`;

/*
 *Колличество пустых заказов  в системе
 */

select count(1) as `Пустых заказов в системе`
from orders_head oh 
where not exists(
select 1 from orders_details od where oh.id = od.orders_head_id 
);

/*
 *По складу вывести средний объём проданного товара за день и объёмы остатков, расчитать оборачиваемость товара на складе
 *Вообще считаю вложенные запросы - это "зло", исключая предыдущий пример, но хотелось продимонстрировать сложный запрос, 
 *я понимаю, что он не опримален, особенно первая его чать.
 */

SET @YEARS=10;
SET @START_DATE= DATE_ADD(CURDATE(),INTERVAL -@YEARS*365 DAY);
SET @FINISH_DATE=CURDATE();


select 
`Дистрибьютор`
,`Склад`
,SUM(`Объёмы остатков`) as `Объёмы остатков`
,SUM(`Средний объём продаж/день`) as `Средний объём продаж/день`
,CASE 
	WHEN SUM(`Объёмы остатков`) = 0 THEN -1
	ELSE ROUND(SUM(`Средний объём продаж/день`)/SUM(`Объёмы остатков`),3)*100
END as 'Оборачиваемость склада/%'
from 
(
select  #Расчёт объёмов остатков
p.full_name as `Дистрибьютор`
,w.name as `Склад`
,IFNULL((
	select round(sum(s.qty*g.volume),0) 
	from 
		stocks s 
		inner join goods g on s.good_id = g.id
	where 
		s.warehouse_id = w.id
),0) as `Объёмы остатков`
,0 `Средний объём продаж/день`
from 
warehouse w  
inner join partners p on w.id_partner = p.id
UNION 
select #Расчёт среднего объёма продаж в день
`Дистрибьютор`
,`Склад`
, 0 as `Объёмы остатков`
,ROUND(AVG(`Объём/день`),0) as `Средний объём продаж/день`
from 
(select 
p.full_name as `Дистрибьютор`
,w.name as `Склад`
,CAST(oh.created_at as DATE) as `День`
,ROUND(sum(g.volume*od.qry),0) as `Объём/день`
from 
warehouse w  
inner join partners p on w.id_partner = p.id
inner join orders_head oh on oh.werehouse_id = w.id 
inner join orders_details od on od.orders_head_id = oh.id 
inner join goods g on od.good_id = g.id 
where 
oh.created_at between @START_DATE AND @FINISH_DATE
group by `Дистрибьютор`,`Склад`,`День`) as tmp
group by `Дистрибьютор`,`Склад`
) tmp_main
group by `Дистрибьютор`,`Склад`



