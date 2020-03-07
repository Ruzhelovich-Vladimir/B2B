/*
 * Представление остатков на складе без обновления
 */

CREATE OR REPLACE
ALGORITHM = UNDEFINED VIEW `b2b`.`view_stocks` AS
select
    `p`.`full_name` AS `Владелец склада`,
    `w`.`name` AS `Наименование склада`,
    `g`.`name` AS `Наименование товара`,
    `s`.`qty` AS `Количество товара`
from
    (((`b2b`.`stocks` `s`
join `b2b`.`warehouse` `w` on
    ((`s`.`warehouse_id` = `w`.`id`)))
join `b2b`.`partners` `p` on
    ((`w`.`id_partner` = `p`.`id`)))
join `b2b`.`goods` `g` on
    ((`s`.`good_id` = `g`.`id`)));
   

/*
 * Демонстрация  представление в выборке
 * 
*/

select * from b2b.view_stocks vs where vs.`Владелец склада` like 'ib%';
   

/*
 * Представление владельца склада
 */

CREATE OR REPLACE
ALGORITHM = UNDEFINED VIEW `b2b`.`view_owner_warehouse` AS
select
    `p`.`id` AS `partner_id`,
    `p`.`full_name` as `full_name`,
    `p`.`short_name` AS `short_name`,
    `p`.`addr` AS `addr`,
    `p`.`phone` AS `phone`,
    `p`.`tin` AS `tin`,
    `w`.`id` AS `warehouse_id`,
    `w`.`name` AS `warehouse_name`
from
    (`b2b`.`partners` `p`
join `b2b`.`warehouse` `w`) WITH CASCADED CHECK OPTION;

/*
 * Демонстрация обновления через представление
 * 
*/
update b2b.view_owner_warehouse 
set warehouse_name="Обновил склад"
where partner_id = 1

