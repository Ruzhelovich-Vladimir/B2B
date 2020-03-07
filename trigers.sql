/*
Сдалел простые тригеры заполнения полей дата и время создания и обновления.

К сожалению не смог разобраться как сделать тригер, который бы запрещал удалять записи, но помечал записи на удаление в отдельном поле, 
не сообщая об ошибке, просто помечая или разотмечая запись на удаление.

Т.е. если она помечены на удаление, то снимал признак, если снята, то ставил.
Продожу эксперементировать.

*/


DELIMITER $$
$$

CREATE DEFINER=`root`@`%` TRIGGER triger_good_before_insert
BEFORE INSERT
ON goods FOR EACH ROW 
BEGIN 
	SET NEW.created_at=NOW();	
	SET NEW.changed_at=NOW();
END $$

CREATE DEFINER=`root`@`%` TRIGGER triger_good_before_update
BEFORE UPDATE
ON goods FOR EACH ROW 
BEGIN 
	SET NEW.changed_at=NOW();
END $$
$$
DELIMITER ;

