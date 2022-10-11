CREATE TABLE `nd_properties` (
	`id` VARCHAR(250) NULL DEFAULT NULL,
	`owner` INT(11) NULL DEFAULT NULL,
	`access` LONGTEXT NULL DEFAULT '[]',
	`sale` INT(11) NULL DEFAULT NULL,
	INDEX `owner` (`owner`) USING BTREE,
	CONSTRAINT `character` FOREIGN KEY (`owner`) REFERENCES `characters` (`character_id`) ON UPDATE CASCADE ON DELETE CASCADE
);