USE transactions;
/*Exercici 2
Utilitzant JOIN realitzaràs les següents consultes:

Llistat dels països que estan generant vendes.*/
SELECT DISTINCT country
FROM company c
INNER JOIN transaction t
	ON c.id = t.company_id;

-- Des de quants països es generen les vendes
SELECT COUNT(DISTINCT country) AS paisos_vendes
FROM company c
INNER JOIN transaction t
	ON c.id = t.company_id;

-- Identifica la companyia amb la mitjana més gran de vendes.
SELECT company_name, ROUND(AVG(amount), 2) AS mitjana_vendes
FROM transaction t
JOIN company c
	ON c.id = t.company_id
GROUP BY company_name
ORDER BY mitjana_vendes DESC
LIMIT 1;

/* Exercici 3
Utilitzant només subconsultes (sense utilitzar JOIN):
Mostra totes les transaccions realitzades per empreses d'Alemanya.*/
SELECT id AS transaction_id
FROM transaction
WHERE company_id IN
	(SELECT id
	FROM company
	WHERE country = 'Germany');

-- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.

SELECT company_name
FROM company
WHERE id IN (SELECT company_id
			FROM transaction
			WHERE amount >
				(SELECT AVG(amount)
				FROM transaction));

-- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
SELECT company_name
FROM company
WHERE id NOT IN (SELECT company_id
				FROM transaction
                WHERE company_id IS NOT NULL);
-- https://community.snowflake.com/s/article/Behaviour-of-NOT-IN-with-NULL-values


/*Nivell 2

Exercici 1
Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes.
Mostra la data de cada transacció juntament amb el total de les vendes.*/
SELECT DATE(timestamp) AS data, SUM(amount) AS ingressos
FROM transaction
GROUP BY DATE(timestamp)
ORDER BY ingressos DESC
LIMIT 5;


/*Exercici 2
Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.*/
SELECT AVG(amount) AS mitjana, country
FROM transaction t
JOIN company c
	ON c.id = t.company_id
GROUP BY country
ORDER BY mitjana DESC;


/*Exercici 3
En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia "Non Institute".
Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.

Mostra el llistat aplicant JOIN i subconsultes.*/
                    
SELECT t.id
FROM transaction t
JOIN company c
	ON c.id = t.company_id
WHERE country IN (SELECT country
					FROM company
					WHERE company_name = 'Non Institute');

                    
-- Mostra el llistat aplicant solament subconsultes.
SELECT id AS transaction_id
FROM transaction
WHERE company_id IN (
	SELECT id
	FROM company
	WHERE country IN (SELECT country
						FROM company
						WHERE company_name = 'Non Institute'));
                        
/*Nivell 3
Exercici 1
Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 350 i 400 euros
i en alguna d'aquestes dates: 29 d'abril del 2015, 20 de juliol del 2018 i 13 de març del 2024. Ordena els resultats de major a menor quantitat.*/

SELECT company_name, phone, country, DATE(timestamp) AS data, amount
FROM transaction t
JOIN company c
	ON c.id = t.company_id
WHERE amount BETWEEN 350 AND 400
	AND DATE(timestamp) IN ('2015-04-29','2018-07-20','2024-03-13');
    
    
/*Exercici 2
Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi,
per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses,
però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més de 400 transaccions o menys.*/

SELECT company_name,
	CASE WHEN COUNT(t.id) >= 400 THEN '>= 400'
    ELSE '<400'
    END AS '400'
FROM transaction t
JOIN company c
	ON c.id = t.company_id
GROUP BY company_name;

