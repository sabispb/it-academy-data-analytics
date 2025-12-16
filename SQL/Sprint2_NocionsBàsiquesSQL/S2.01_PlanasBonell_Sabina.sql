USE transactions;

/* NIVELL 1
- Exercici 1
A partir dels documents adjunts (estructura_dades i dades_introduir), importa les dues taules.
Mostra les característiques principals de l'esquema creat i explica les diferents taules i variables que existeixen.
Assegura't d'incloure un diagrama que il·lustri la relació entre les diferents taules i variables.

https://medium.com/@tushar0618/how-to-create-er-diagram-of-a-database-in-mysql-workbench-209fbf63fd03


- Exercici 2
Utilitzant JOIN realitzaràs les següents consultes:*/

-- Llistat dels països que estan fent compres.

SELECT DISTINCT c.country
FROM transaction t
JOIN company c
	ON c.id = t.company_id;
    
-- Des de quants països es realitzen les compres.
SELECT COUNT(DISTINCT c.country) AS nombre_paisos
FROM transaction t
JOIN company c
	ON c.id = t.company_id;

-- Identifica la companyia amb la mitjana més gran de vendes.

SELECT AVG(amount) AS mitjana_vendes, company_name
FROM transaction t
JOIN company c
	ON c.id = t.company_id
GROUP BY t.company_id
ORDER BY mitjana_vendes DESC
LIMIT 1;

/*SELECT company_name, mitjana_vendes
FROM (
    SELECT c.company_name,
           AVG(t.amount) AS mitjana_vendes
    FROM transaction t
    JOIN company c ON c.id = t.company_id
    GROUP BY c.id, c.company_name
) AS sub
WHERE mitjana_vendes = (
    SELECT MAX(mitjana_vendes)
    FROM (
        SELECT AVG(amount) AS mitjana_vendes
        FROM transaction
        GROUP BY company_id
    ) AS m
);*/

/*- Exercici 3
Utilitzant només subconsultes (sense utilitzar JOIN):*/

-- Mostra totes les transaccions realitzades per empreses d'Alemanya.

SELECT id AS transactions
FROM transaction
WHERE company_id IN (SELECT id AS company_id
FROM company
WHERE country = 'Germany');

-- Optimització amb EXISTS
SELECT id AS transactions
FROM transaction t
WHERE EXISTS (
	SELECT 1
    FROM company c
    WHERE country = 'Germany'
		AND t.company_id = c.id);

-- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.

SELECT id, company_name
FROM company
WHERE id IN
(SELECT company_id
FROM transaction
WHERE amount >
(SELECT AVG(amount) AS mitjana_transaccions
FROM transaction));

-- Optimització EXISTS
SELECT id, company_name
FROM company c
WHERE EXISTS (
		SELECT 1
        FROM transaction t
        WHERE amount > (SELECT AVG(amount) AS mitjana_transaccions
						FROM transaction)
			AND t.company_id = c.id);

-- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.

SELECT id, company_name
FROM company
WHERE id NOT IN
	(SELECT DISTINCT company_id
	FROM transaction
    WHERE company_id IS NOT NULL);
-- https://community.snowflake.com/s/article/Behaviour-of-NOT-IN-with-NULL-values

-- Optimització NOT EXISTS
SELECT id, company_name
FROM company c
WHERE NOT EXISTS (
	SELECT 1
    FROM transaction t
    WHERE c.id = t.company_id);


/*Nivell 2
Exercici 1
Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes.
Mostra la data de cada transacció juntament amb el total de les vendes.*/

-- https://five.co/blog/sql-timestamp-to-date-conversion/

SELECT DATE(timestamp) AS data, SUM(amount) AS total_ingressos
FROM transaction
GROUP BY data
ORDER BY total_ingressos DESC
LIMIT 5;

/*
SELECT data, total_ingressos
FROM
(SELECT data, total_ingressos, row_number() OVER (ORDER BY total_ingressos DESC) AS rn
FROM
(SELECT DATE(timestamp) AS data, SUM(amount) AS total_ingressos
FROM transaction
GROUP BY data) AS suma_ingressos) AS row_numbers
WHERE rn <= 5;
*/

/*Exercici 2
Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.*/
SELECT AVG(amount) AS mitjana_vendes, country
FROM transaction t
JOIN company c
	ON 	c.id = t.company_id
GROUP BY country
ORDER BY mitjana_vendes DESC;


/*Exercici 3
En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia "Non Institute".
Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.

Mostra el llistat aplicant JOIN i subconsultes.*/
-- Corrección: Añadir más info, el departamento de marketing la necesitará!

SELECT t.id AS transactions
FROM transaction t
JOIN company c
	ON 	c.id = t.company_id
WHERE country IN (SELECT country
					FROM company
					WHERE company_name = 'Non Institute')
	-- AND company_name != 'Non Institute'
    ;

-- Mostra el llistat aplicant solament subconsultes.
-- Corrección: Añadir más info, el departamento de marketing la necesitará!
SELECT id AS transactions
FROM transaction
WHERE company_id IN (SELECT id
					FROM company
					WHERE country IN (SELECT country
										FROM company
										WHERE company_name = 'Non Institute')
						-- AND company_name != 'Non Institute'
                        );


/*Nivell 3
Exercici 1
Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 100 i 200 euros
i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. Ordena els resultats de major a menor quantitat.*/

SELECT company_name, phone, country, DATE(timestamp) AS data, amount
FROM transaction t
JOIN company c
	ON 	c.id = t.company_id
WHERE amount BETWEEN 100 AND 200
	AND DATE(timestamp) IN ('2021-04-29', '2021-07-20', '2022-03-13')
ORDER BY amount DESC;


/*Exercici 2
Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi,
per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses,
però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys.*/

-- https://www.datacamp.com/tutorial/case-statement-sql?utm_cid=19589720821&utm_aid=157156375591&utm_campaign=230119_1-ps-other~dsa~tofu_2-b2c_3-emea_4-prc_5-na_6-na_7-le_8-pdsh-go_9-nb-e_10-na_11-na&utm_loc=9198606-&utm_mtd=-c&utm_kw=&utm_source=google&utm_medium=paid_search&utm_content=ps-other~emea-en~dsa~tofu~tutorial~sql&gad_source=1&gad_campaignid=19589720821&gbraid=0AAAAADQ9WsFUJ0g-PMLDIwvZV-qOwulgD&gclid=Cj0KCQiA_8TJBhDNARIsAPX5qxRDGIdvfm1n62XYJIYXTSn7-tdjgbdCNqW0UI8_tAoUIGUbZexnmgAaAgTXEALw_wcB

SELECT company_name,
CASE
	WHEN nombre_transaccions >= 4 THEN '>= 4'
    ELSE '< 4'
END as nombre_transaccions
FROM (SELECT COUNT(t.id) AS nombre_transaccions, company_name
FROM transaction t
JOIN company c
	ON 	c.id = t.company_id
GROUP BY company_id) as count_transactions;

/*
SELECT 
    c.company_name,
    CASE
        WHEN COUNT(t.id) >= 4 THEN '>= 4'
        ELSE '< 4'
    END AS categoria
FROM transaction t
JOIN company c 
    ON c.id = t.company_id
GROUP BY c.id, c.company_name;


SELECT DISTINCT
    c.company_name,
    CASE 
        WHEN COUNT(t.id) OVER (PARTITION BY c.id) >= 4 THEN '>= 4'
        ELSE '< 4'
    END AS categoria
FROM transaction t
JOIN company c 
    ON c.id = t.company_id;
*/
