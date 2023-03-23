CREATE TABLE `tsbanking_ibans` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `identifier` longtext DEFAULT NULL,
    `name` longtext NOT NULL,
    `accountnumber` longtext NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;