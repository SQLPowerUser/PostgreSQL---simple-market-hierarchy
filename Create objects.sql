CREATE SCHEMA if not exists sales;

DROP table if exists sales.order_product;

DROP TABLE if exists sales.orders;

DROP TABLE if exists sales.product;

DROP TABLE if exists sales.categories;

DROP TABLE if exists sales.customers;

CREATE TABLE sales.categories (
	id int primary key,
	parent_id int,
	name varchar(512) CHECK (char_length(name) > 1)
);

CREATE TABLE sales.product (
	id serial primary key,
	category_id int references sales.categories (id),
	name varchar(512) not null,
	amount int not null,
	price money CONSTRAINT valid_price CHECK (price > 0.00::money)
);

CREATE TABLE sales.customers (
	id serial primary key,
	name varchar(512) not null,
	address varchar(4096) not null
);

CREATE TABLE sales.orders (
	id serial primary key,
	customer_id int references sales.customers (id),
	name varchar(64) not null,
	order_date date not null,
	order_time time not null
);

CREATE TABLE sales.order_product (
	order_id int references sales.orders (id),
	product_id int references sales.product (id),
	quantity int not null CHECK (quantity > 0)
);

CREATE OR REPLACE FUNCTION verify_quantity () RETURNS TRIGGER LANGUAGE PLPGSQL AS $$
declare
	current_amount int;
	current_product varchar(512);
BEGIN
	select name, amount
	into current_product, current_amount
	from sales.product where id = NEW.product_id;

	IF NEW.quantity > current_amount THEN
		RAISE EXCEPTION 'Для товара "%" превышено максимальное количество: %', current_product, current_amount;
	END IF;

	RETURN NEW;
END;
$$;

CREATE TRIGGER check_quantity BEFORE INSERT on sales.order_product FOR EACH ROW
EXECUTE FUNCTION verify_quantity ();

INSERT INTO
	sales.categories (id, parent_id, name)
VALUES
	(1, null, 'Бытовая техника'),
	(2, 1, 'Стиральные машины'),
	(3, 2, 'Инверторные'),
	(4, 2, 'С паром'),
	(5, 2, 'Узкие'),
	(6, 1, 'Холодильники'),
	(7, 6, 'Однокамерные'),
	(8, 6, 'Двухкамерные'),
	(9, 6, 'Трёхкамерные'),
	(10, 1, 'Телевизоры'),
	(11, 10, 'FULL HD'),
	(12, 10, '8K Ultra HD'),
	(13, null, 'Ноутбуки и компьютеры'),
	(14, 13, 'Серверы'),
	(15, 14, 'Башенные'),
	(16, 14, 'Стоечные'),
	(17, 14, 'Модульные'),
	(18, 13, 'Ноутбуки'),
	(19, 18, 'Для офиса'),
	(20, 19, 'Без операционной системы'),
	(21, 19, 'Windows'),
	(22, 19, 'Linux'),
	(23, 19, 'macOS'),
	(24, 18, 'Игровые'),
	(25, 24, 'На базе процессора AMD'),
	(26, 24, 'На базе процессора Intel'),
	(27, 13, 'Моноблоки'),
	(28, 27, 'До 19 дюймов'),
	(29, 27, 'От 23 до 24 дюймов'),
	(30, 27, 'Больше 24 дюймов');

INSERT INTO
	sales.product (category_id, name, price, amount)
VALUES
	(3, 'LG F1296NDS0', 34990, 25),
	(3, 'Samsung WW65AG4S20CXLP', 38900, 20),
	(4, 'Beko WSPE7612W', 23620, 19),
	(4, 'LG F2Y1WS6W', 33570, 42),
	(5, 'Indesit EWUC 4105', 21440, 17),
	(5, 'Candy Smart Pro CSO34 106TB1/2-07', 23999, 51),
	(5, 'HAIER HW70-BP12919', 35002, 8),
	(7, 'Hyundai CO1003', 14490, 44),
	(7, 'Бирюса Б-M50', 9200, 50),
	(8, 'LG GA-B509CQSL Total No Frost', 54990, 11),
	(8, 'STINOL STS 167', 24800, 32),
	(9, 'HAIER HTF-425DM7RU Side by Side', 119999, 5),
	(11, 'Xiaomi MI TV A 43 FHD 2025', 21780, 60),
	(11, 'Digma DM-LED40SBB36', 13990, 27),
	(12, 'Samsung QE55QN700CUXRU Ultra HD', 148330, 6),
	(15, 'HPE ProLiant MicroServer Gen10+', 62779, 11),
	(15, 'LENOVO ST550 8SFF', 218199, 4),
	(16, 'DELL R640 8SFF', 86363, 17),
	(17, 'HP Proliant BL460с Gen9', 201150, 2),
	(20, 'ASUS Vivobook 15', 41540, 35),
	(20, 'Huawei MateBook D 16 MCLG-X', 56000, 41),
	(21, 'Digma EVE C5801', 19240, 54),
	(21, 'Huawei MateBook D 16 MCLG-X', 61999, 36),
	(22, 'MAIBENBEN M645', 34800, 70),
	(23, 'Apple MacBook Air A3240', 96900, 22),
	(25, 'ASUS TUF Gaming A16 FA608UM-RV097', 139970, 20),
	(26, 'Gigabyte G6 16", 2023, IPS, Intel Core i7', 99900, 17),
	(26, 'MSI Thin 15 B12UC-2632XRU', 64510, 23),
	(28, 'MSI Pro AP162T ADL-014XRU Full HD', 38020, 96),
	(29, 'CHUWI Unitech 24 Full HD, Intel N150', 27790, 2),
	(29, 'DIGMA PRO Unity Full HD, Intel Core i5 1235U', 49500, 120),
	(30, 'iRU 27IM Full HD, Intel Core i5', 52220, 38);

INSERT INTO
	sales.customers (name, address)
VALUES
	('Пьер Кириллович Безухов', 'Санкт-Петербург, набережная реки Мойки, дом 1'),
	('Наталья Ильинична Ростова', 'Москва, улица Поварская, дом 20'),
	('ИП Андрей Иванович Штольц', 'Симбирская губерния, село Верхлёво, дом 3'),
	('ООО Цифровые Бизнес Процессы', 'мун. округ Можайский, ул. Луговая, д.4');

INSERT INTO
	sales.orders (customer_id, name, order_date, order_time)
values
	(1, 'V047381122', '2022-11-30', '09:05:38'),
	(1, 'A042750333', '2022-11-30', '09:12:03'),
	(1, 'L1317224', '2024-05-14', '16:20:11'),
	(2, 'U5117384', '2023-03-08', '10:08:59'),
	(2, 'Y9927070', '2023-07-31', '08:45:22'),
	(2, 'Y6289975', '2023-08-01', '11:19:02'),
	(2, 'R8552906', '2025-06-02', '21:59:47'),
	(3, 'M8406925', '2024-02-29', '15:02:55'),
	(3, 'P874625491', '2025-04-30', '19:51:06'),
	(4, 'B77409231705', '2025-09-18', '14:20:35');

INSERT INTO
	sales.order_product (order_id, product_id, quantity)
values
	(1, 9, 5),
	(1, 25, 7),
	(1, 8, 12),
	(2, 14, 3),
	(2, 1, 6),
	(3, 17, 1),
	(4, 12, 4),
	(4, 31, 2),
	(5, 29, 8),
	(5, 30, 1),
	(6, 5, 9),
	(7, 19, 2),
	(7, 32, 24),
	(8, 31, 3),
	(8, 15, 1),
	(8, 11, 22),
	(9, 3, 5),
	(9, 12, 3),
	(10, 30, 2),
	(10, 17, 4);
