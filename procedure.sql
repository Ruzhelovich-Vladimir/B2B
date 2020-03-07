DROP PROCEDURE IF EXISTS b2b.proc_invoice;

DELIMITER $$
$$
/*
 * Получить счёт на оплату заказа
 * Входной параметр номер счёта, возвращает таблицу, и вторым пораметром сумму счёта
 */
CREATE DEFINER=`root`@`%` PROCEDURE `b2b`.`proc_invoice`(IN order_id int, OUT summ FLOAT)
BEGIN
	 
	drop table if exists `tmp_table`;

	CREATE TEMPORARY TABLE `tmp_table` 
		select 
		oh.id `Номер счёта`
		,CAST(oh.created_at as DATE) `Дата заказа`
		,g.name as `Наименование товара`
		,round(od.price,2) as `Цена`
		,od.qry as `Количество`
		,round(od.price,2)*od.qry `Сумма`
		from b2b.orders_head oh 
		inner join b2b.orders_details od on od.orders_head_id = oh.id 
		inner join b2b.goods g on od.good_id = g.id
		where oh.id = order_id;
	
	set summ=(select sum(`Сумма`) from `tmp_table`); #Расчёт итоговой суммы
	
	select * from `tmp_table`;

	drop table if exists `tmp_table`;
	
END$$
DELIMITER ;

/*
 * Демонстрация работы
 */

SET @SUMM=0;

{ CALL b2b.proc_invoice(954,@SUMM) };

select @SUMM as `Сумма счёта`
