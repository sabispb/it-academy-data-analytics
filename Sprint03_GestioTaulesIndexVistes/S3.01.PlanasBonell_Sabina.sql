/*
Nivell 1
Exercici 1
La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials sobre les targetes de crèdit.
La nova taula ha de ser capaç d'identificar de manera única cada targeta i establir una relació adequada amb les altres dues taules
("transaction" i "company"). Després de crear la taula serà necessari que ingressis la informació del document denominat "dades_introduir_credit".
Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.
*/

USE transactions;
-- DROP DATABASE transactions;
-- DROP TABLE credit_card;

CREATE TABLE credit_card (
id VARCHAR(200) NOT NULL, -- char?
iban VARCHAR(200),
pan VARCHAR(200),
pin VARCHAR(200),
cvv VARCHAR(200),
expiring_date VARCHAR(200),
PRIMARY KEY (id)
);

-- INSERT INTO VALUES from doc 'datos_introducir_sprint3_user'

ALTER TABLE credit_card ADD COLUMN new_date DATE;
SET SQL_SAFE_UPDATES = 0;
UPDATE credit_card
set new_date = str_to_date(expiring_date, '%m/%d/%Y');
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE credit_card DROP COLUMN expiring_date;
ALTER TABLE credit_card RENAME COLUMN new_date TO expiring_date;

-- CREATE INDEX idx_credit_card_id
-- ON transaction (credit_card_id); -- not needed since when creating the foreign key then it will be created 

-- ALTER TABLE transaction
-- DROP FOREIGN KEY fk_credit_card_id;

ALTER TABLE transaction
ADD CONSTRAINT fk_credit_card_id
FOREIGN KEY (credit_card_id) REFERENCES credit_card(id)
ON UPDATE CASCADE; -- whenever the primary key will be updated in the parent, the value in the child would also be updated.

/*
Exercici 2
El departament de Recursos Humans ha identificat un error en el número de compte associat a la targeta de crèdit amb ID CcU-2938.
La informació que ha de mostrar-se per a aquest registre és: TR323456312213576817699999. Recorda mostrar que el canvi es va realitzar.*/

UPDATE credit_card
SET iban = 'TR323456312213576817699999'
WHERE id = 'CcU-2938';

SELECT id, iban
FROM credit_card
WHERE id = 'CcU-2938';


/*Exercici 3
En la taula "transaction" ingressa una nova transacció amb la següent informació:

Id	108B1D1D-5B23-A76C-55EF-C568E49A99DD
credit_card_id	CcU-9999
company_id		b-9999
user_id	9999
lat	829.999
longitude	-117.999
amount	111.11
declined	0
*/

INSERT INTO credit_card (id) -- If a value is defined as a foreign key, it first needs to be inserted into the parent table  
VALUES
('CcU-9999');

INSERT INTO company (id)
VALUES
('b-9999');

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES
('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', '829.999', '-117.999', 111.11, 0);

SELECT *
FROM transaction
WHERE credit_card_id = 'CcU-9999';

/* Exercici 4
Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card. Recorda mostrar el canvi realitzat.
*/

ALTER TABLE credit_card
DROP COLUMN pan;

SELECT *
FROM credit_card
LIMIT 1;


/*Nivell 2
Exercici 1
Elimina de la taula transaction el registre amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de dades.*/

SELECT id
FROM transaction
WHERE id='000447FE-B650-4DCF-85DE-C7ED0EE1CAAD'; -- to check that it exists

DELETE from transaction
WHERE id='000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

SELECT id
FROM transaction
WHERE id='000447FE-B650-4DCF-85DE-C7ED0EE1CAAD'; -- to check that it was deleted


/*Exercici 2
La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives.
S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions.
Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació:
Nom de la companyia. Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia.
Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.*/

-- DROP VIEW VistaMarketing;

CREATE VIEW VistaMarketing AS
	SELECT company_id, company_name, phone, country, ROUND(AVG(amount),2) AS mitjana_compra
	FROM company c
	JOIN transaction t
		ON c.id = t.company_id
	GROUP BY company_id
	ORDER BY mitjana_compra DESC;

-- GRANT SELECT ON vistamarketing TO analyst_user;

SELECT *
FROM VistaMarketing;

/* Exercici 3
Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"*/
SELECT *
FROM vistamarketing
WHERE LOWER(country) = 'germany';


/*Nivell 3
Exercici 1
La setmana vinent tindràs una nova reunió amb els gerents de màrqueting.
Un company del teu equip va realitzar modificacions en la base de dades, però no recorda com les va realitzar.
Et demana que l'ajudis a deixar els comandos executats per a obtenir el següent diagrama:*/

-- 1. Canviar tipus dada taula user
ALTER TABLE user
MODIFY COLUMN id INT;

-- 2. Afegir a user l'id 9999, taula user
-- Error 1452 when trying to define FK, then: which user_id in transaction is not in id in user
SELECT t.user_id
FROM user u
RIGHT JOIN transaction t
	ON u.id = t.user_id
WHERE u.id IS NULL;

SELECT *
FROM user
WHERE id = 9999;

INSERT INTO user (id)
VALUES ('9999');

SELECT *
FROM user
WHERE id = 9999;

-- 3. Definir fk, taula transaction amb pk a user
ALTER TABLE transaction
ADD CONSTRAINT fk_user_id
FOREIGN KEY (user_id) REFERENCES user(id)
ON UPDATE CASCADE; -- whenever the primary key will be updated in the parent, the value in the child would also be updated.

-- 4. Canviar nom taula user
ALTER TABLE user RENAME TO data_user;

-- 5. De la taula ‘company’ eliminar la columna ‘website’
ALTER TABLE company
DROP COLUMN website;

SELECT *
FROM company
LIMIT 1;


-- 6. De la taula credit_card, modificar tipus de dades i afegir columna fecha_actual
-- Primer he d'eliminar la fk_credit_card_id per a canviar el tipus d'id perquè sinó dóna error.

ALTER TABLE transaction
DROP CONSTRAINT fk_credit_card_id;

ALTER TABLE credit_card
	MODIFY COLUMN id VARCHAR(20),
	MODIFY COLUMN pin VARCHAR(4),
	MODIFY COLUMN cvv INT,
	MODIFY COLUMN expiring_date VARCHAR(20),
    MODIFY COLUMN iban VARCHAR(50),
	ADD COLUMN fecha_actual DATE;

SELECT *
FROM credit_card
LIMIT 1;

ALTER TABLE transaction
ADD CONSTRAINT fk_credit_card_id
FOREIGN KEY (credit_card_id) REFERENCES credit_card(id)
ON UPDATE CASCADE; 

-- 7. De la taula ‘transaction’ modificar el nombre de caràcters disponibles a la columna credit_card_id.
ALTER TABLE transaction MODIFY COLUMN credit_card_id VARCHAR(20);


/* Exercici 2
L'empresa també us demana crear una vista anomenada "InformeTecnico" que contingui la següent informació:

ID de la transacció
Nom de l'usuari/ària
Cognom de l'usuari/ària
IBAN de la targeta de crèdit usada.
Nom de la companyia de la transacció realitzada.
Assegureu-vos d'incloure informació rellevant de les taules que coneixereu i utilitzeu àlies per canviar de nom columnes segons calgui.
Mostra els resultats de la vista, ordena els resultats de forma descendent en funció de la variable ID de transacció.*/

-- DROP VIEW informetecnico;

CREATE VIEW InformeTecnico AS
SELECT t.id AS id_transaccio,
	du.name AS nom_usuari,
	du.surname AS cognom_usuari,
	cc.iban,
    cc.expiring_date AS data_caducitat_targeta, -- afegit com a informació rellevant
	c.company_name AS nom_empresa,
	t.declined AS estat_compra -- afegit com a informació rellevant
FROM transaction t
JOIN data_user du
	ON t.user_id = du.id
JOIN credit_card cc
	ON cc.id = t.credit_card_id
JOIN company c
	ON c.id = t.company_id;
    
SELECT *
FROM informetecnico
ORDER BY id_transaccio DESC;

