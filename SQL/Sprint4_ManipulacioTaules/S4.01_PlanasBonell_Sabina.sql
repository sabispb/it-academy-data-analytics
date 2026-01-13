
/*
Descàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui, almenys 4 taules de les quals puguis realitzar les següents consultes:

Exercici 1
Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions utilitzant almenys 2 taules.

Exercici 2
Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.
*/

-- DROP DATABASE transactions2;
CREATE DATABASE s4_transactions;
USE s4_transactions;

/*
Tables to import values

american_users
id,name,surname,phone,email,birth_date,country,city,postal_code,address

european_users
id,name,surname,phone,email,birth_date,country,city,postal_code,address

credit_cards
id,user_id,iban,pan,pin,cvv,track1,track2,expiring_date

transactions -- decided to be main table as it has all the ids for the other tables
id;card_id;business_id;timestamp;amount;declined;product_ids;user_id;lat;longitude


No user_id, both with different names in transactions

companies
company_id,company_name,phone,email,country,website

products
id,product_name,price,colour,weight,warehouse_id
*/

CREATE TABLE american_users (
	id VARCHAR (200),
    name VARCHAR (200),
    surname VARCHAR (200),
    phone VARCHAR (200),
    email VARCHAR (200),
    birth_date VARCHAR (200),
    country VARCHAR (200),
    city VARCHAR (200),
    postal_code VARCHAR (200),
    address VARCHAR (200)
    );
    
CREATE TABLE european_users (
	id VARCHAR (200),
    name VARCHAR (200),
    surname VARCHAR (200),
    phone VARCHAR (200),
    email VARCHAR (200),
    birth_date VARCHAR (200),
    country VARCHAR (200),
    city VARCHAR (200),
    postal_code VARCHAR (200),
    address VARCHAR (200)
    );

CREATE TABLE credit_cards (
	id VARCHAR (200),
    user_id VARCHAR (200),
    iban VARCHAR (200),
    pan VARCHAR (200),
    pin VARCHAR (200),
    cvv VARCHAR (200),
    track1 VARCHAR (200),
    track2 VARCHAR (200),
    expiring_date VARCHAR (200)
    );
    
    CREATE TABLE transactions (
	id VARCHAR (200),
    card_id VARCHAR (200),
    business_id VARCHAR (200),
    timestamp VARCHAR (200),
    amount VARCHAR (200),
    declined VARCHAR (200),
    product_ids VARCHAR (200),
    user_id VARCHAR (200),
    lat VARCHAR (200),
    longitude VARCHAR (200)
    );
    
    CREATE TABLE companies (
	company_id VARCHAR (200),
    company_name VARCHAR (200),
    phone VARCHAR (200),
    email VARCHAR (200),
    country VARCHAR (200),
    website VARCHAR (200)
    );
    
    CREATE TABLE products (
	id VARCHAR (200),
    product_name VARCHAR (200),
    price VARCHAR (200),
    colour VARCHAR (200),
    weight VARCHAR (200),
    warehouse_id VARCHAR (200)
    );

/*
-- Activate local_infile so we can add csv from local
SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = ON;
SET PERSIST local_infile = ON;
SHOW GLOBAL VARIABLES LIKE 'local_infile';

-- Insert data from csv files
SHOW VARIABLES LIKE 'secure_file_priv';
It gaves me an error when I tried to load data. I followed the following advice and htne it worked:
2068 no és del servidor: és el client (MySQL Workbench / driver) que rebutja enviar el fitxer local.
Solució a Workbench (la que acostuma a arreglar-ho)
Database → Manage Connections…
Selecciones la connexió → Edit
Pestanya Advanced
A Others afegeix:
OPT_LOCAL_INFILE=1
*/

LOAD DATA LOCAL INFILE 'PATH/american_users.csv' -- PATH has been manually removed to upload to GitHub for security reasons
INTO TABLE american_users
FIELDS TERMINATED BY ','
ENCLOSED BY '"' -- birth_date is enclosed by "", it gave a warning since it divided its info by 2 (column1: "Nov 17 column2: 1985"), I did select * from the table. I used TRUNCATE TALE to delete the info within the table and then do it again wih the eclosed line of code
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- TRUNCATE TABLE american_users;

SELECT * from american_users
LIMIT 2;


LOAD DATA LOCAL INFILE 'PATH/companies.csv'-- PATH has been manually removed to upload to GitHub for security reasons
INTO TABLE companies
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- TRUNCATE TABLE companies

SELECT * from companies
LIMIT 2;


LOAD DATA LOCAL INFILE 'PATH/credit_cards.csv'-- PATH has been manually removed to upload to GitHub for security reasons
INTO TABLE credit_cards
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- TRUNCATE TABLE credit_cards

SELECT * from credit_cards
LIMIT 2;


LOAD DATA LOCAL INFILE 'PATH/european_users.csv'-- PATH has been manually removed to upload to GitHub for security reasons
INTO TABLE european_users
FIELDS TERMINATED BY ','
ENCLOSED BY '"' -- birth_date is enclosed by "", it gave a warning since it divided its info by 2 (column1: "Nov 17 column2: 1985"), I did select * from the table. I used TRUNCATE TALE to delete the info within the table and then do it again wih the eclosed line of code
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- TRUNCATE TABLE european_users

SELECT * from european_users
LIMIT 2;


LOAD DATA LOCAL INFILE 'PATH/products.csv'-- PATH has been manually removed to upload to GitHub for security reasons
INTO TABLE products
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- TRUNCATE TABLE products

SELECT * from products
LIMIT 2;


LOAD DATA LOCAL INFILE 'PATH/transactions.csv'-- PATH has been manually removed to upload to GitHub for security reasons
INTO TABLE transactions
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- TRUNCATE TABLE transactions

SELECT * from transactions
LIMIT 2;

-- JOIN Users table, check they are ok and remove the previous ones.

CREATE TABLE all_users AS
SELECT *, 'america' AS region
FROM american_users
UNION
SELECT *, 'europe' AS region
FROM european_users;

-- DROP TABLE all_users;

SELECT *
FROM american_users;

SELECT *
FROM european_users;

SELECT *
FROM all_users;

DROP TABLE american_users;
DROP TABLE european_users;



SELECT *
FROM transactions
LIMIT 2;


-- Add Primary and foreign keys
ALTER TABLE transactions
MODIFY COLUMN id VARCHAR(100) NOT NULL,
ADD CONSTRAINT pk_transactions_id
PRIMARY KEY (id);

ALTER TABLE all_users
MODIFY COLUMN id VARCHAR(100) NOT NULL,
ADD CONSTRAINT pk_users_id
PRIMARY KEY (id);

ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_users_id
FOREIGN KEY (user_id) REFERENCES all_users(id);

SELECT *
FROM transactions;

SELECT *
FROM companies;

SELECT *
FROM credit_cards;


ALTER TABLE companies
MODIFY COLUMN company_id VARCHAR(10) NOT NULL,
ADD CONSTRAINT pk_company_id
PRIMARY KEY (company_id);

ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_business_id
FOREIGN KEY (business_id) REFERENCES companies(company_id);

ALTER TABLE credit_cards
MODIFY COLUMN id VARCHAR(10) NOT NULL,
ADD CONSTRAINT pk_credit_cards_id
PRIMARY KEY (id);

ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_credit_cards_id
FOREIGN KEY (card_id) REFERENCES credit_cards(id);

/*Exercici 1
Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions utilitzant almenys 2 taules.*/

SELECT *
FROM all_users
WHERE EXISTS (
SELECT user_id, COUNT(id) AS number_transactions
FROM transactions
WHERE all_users.id = transactions.user_id
GROUP BY user_id
HAVING number_transactions > 80);

/* Sense subconsulta, amb JOIN
SELECT u.id, u.name, u.surname, COUNT(t.id) AS number_transactions
FROM all_users u
JOIN transactions t ON u.id = t.user_id
GROUP BY t.user_id
HAVING number_transactions > 80;
*/


/*Exercici 2
Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.*/

SELECT iban, ROUND(AVG(amount),2) AS average_amount
FROM transactions t
JOIN companies c ON t.business_id = c.company_id
JOIN credit_cards cc ON t.card_id = cc.id
WHERE company_name LIKE '%Donec%'
GROUP BY cc.iban;


/*Nivell 2
Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les tres últimes transaccions han estat declinades
aleshores és inactiu, si almenys una no és rebutjada aleshores és actiu. Partint d’aquesta taula respon:

Exercici 1
Quantes targetes estan actives?*/

-- Creació taula
SELECT *
FROM transactions;

SELECT card_id, declined, timestamp
FROM transactions
ORDER BY card_id, timestamp;

ALTER TABLE transactions
MODIFY COLUMN timestamp TIMESTAMP;

ALTER TABLE transactions
RENAME COLUMN timestamp to transaction_date;

-- Create table with WITH statements: https://www.baeldung.com/sql/with-clause-table-creation
-- DROP TABLE active_credit_cards;
CREATE TABLE active_credit_cards AS
	WITH ranked_transactions AS
		(SELECT card_id, declined, transaction_date,
			ROW_NUMBER() OVER(PARTITION BY card_id ORDER BY transaction_date DESC) AS rn
		FROM transactions
		),
		last3_transactions AS (
			SELECT *
			FROM ranked_transactions
			WHERE rn<= 3
			)
	SELECT card_id,
		CASE WHEN SUM(declined) = 3 THEN 'inactive'
		ELSE 'active'
		END AS state
	FROM last3_transactions
	GROUP BY card_id;

SELECT *
FROM active_credit_cards;

SELECT COUNT(card_id) AS active_cards
FROM active_credit_cards
WHERE state = 'active';


    /* Proves:
    	WITH ranked_transactions AS
		(SELECT card_id, declined, transaction_date,
			ROW_NUMBER() OVER(PARTITION BY card_id ORDER BY transaction_date DESC) AS rn
		FROM transactions
		),
		
		last3_transactions AS (
			SELECT *
			FROM ranked_transactions
			WHERE rn<= 3
			),
		grouped_transactions AS (
			SELECT card_id, GROUP_CONCAT(DISTINCT declined) AS declined_group
			FROM last3_transactions
			GROUP BY card_id)
			
		SELECT card_id,
			CASE WHEN declined_group LIKE '%1%' THEN 'inactive'
			ELSE 'active'
			END AS state
		FROM grouped_transactions
		GROUP BY card_id;
*/

/*
Nivell 3
Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada,
tenint en compte que des de transaction tens product_ids. Genera la següent consulta:

Exercici 1
Necessitem conèixer el nombre de vegades que s'ha venut cada producte.
*/
SELECT * FROM transactions;
SELECT * FROM all_users;
SELECT * FROM companies;
SELECT * FROM credit_cards;
SELECT * FROM products;


/* Proves:

Càlcul nombre de comes:
SELECT *, LENGTH(product_id) - LENGTH(REPLACE(product_id, ',', '')) AS number_commas
FROM transaction_product;

Separar amb substring_index, però només un
SELECT *, SUBSTRING_INDEX(product_id, ",", 1) AS substring_1
FROM transaction_product
LIMIT 2;

-- https://www.geeksforgeeks.org/sql-server/recursive-cte-in-sql-server/
En realitat es pot fer de diverses formes (CTE recursive, JSON table, PROCEDURES):
https://five.co/blog/split-a-string-in-mysql/
Les he provat i la més ràpida i millor és transformar el csv a JSON i aleshores aplicar la funció JSON_TABLE.
1. converteix csv en un array de JSON perquè el pugui processar (CONCAT, REPLACE). FORMAT ARRAY: ["16", "32"]
2. Amb JSON table li diem que per a cadascuna de les files de transaction_product ha de fer explode de products_id i després ho ajunta (no és un JOIN real) amb la fila inicial.
*/

-- DROP TABLE transaction_product;

CREATE TABLE transaction_product AS
	SELECT
	  t.id AS transaction_id,
	  jt.product_id
	FROM transactions t
	CROSS JOIN JSON_TABLE(
	  CONCAT(
		'["',
		REPLACE(t.product_ids, ',', '","'),
		'"]'
	  ),
	  '$[*]' COLUMNS (
		product_id INT PATH '$'
	  )
	) jt;
    
SELECT *
FROM transaction_product;

ALTER TABLE products
MODIFY COLUMN id INT NOT NULL, -- needs to be the same datatype as intermediate table
ADD CONSTRAINT pk_products_id PRIMARY KEY (id);

-- ALTER TABLE products
-- DROP PRIMARY KEY;


ALTER TABLE transaction_product
ADD CONSTRAINT fk_int_transaction_id
FOREIGN KEY (transaction_id) REFERENCES transactions(id),
ADD CONSTRAINT fk_int_product_id
FOREIGN KEY (product_id) REFERENCES products(id);


SELECT product_id, COUNT(transaction_id) AS number_sold
FROM transaction_product
GROUP BY product_id
ORDER BY product_id;

SELECT *
FROM products;