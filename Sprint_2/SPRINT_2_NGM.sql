-- ************** SPRINT 2 **************
-- ************** Nivel 1  **************

/* Ejercicio 1 ***********************
Explicado en .pdf */

/* Ejercicio 2 ***********************
	Utilitzant JOIN realitzaràs les següents consultes:*/

-- Llistat dels països que estan fent compres:
USE transactions;

SELECT DISTINCT country   
FROM company
JOIN transaction ON company.id = transaction.company_id;

-- Des de quants països es realitzen les compres:
SELECT COUNT(DISTINCT company.country) AS total_countries
FROM transactions.company
INNER JOIN transactions.transaction ON transaction.company_id = company.id
WHERE transaction.declined = 0;

-- Identifica la companyia amb la mitjana més gran de vendes:

SELECT company_name, AVG(amount) AS ventas_promedio
FROM transaction
JOIN company ON transaction.company_id = company.id
WHERE declined=0
GROUP BY company_name
ORDER BY ventas_promedio DESC
LIMIT 1;

/* Ejercicio 3 ***********************
	Utilitzant només subconsultes (sense utilitzar JOIN):*/
    
-- Mostra totes les transaccions realitzades per empreses d'Alemanya:
SELECT id, company_id FROM transaction
WHERE company_id IN (
	SELECT id FROM company
	WHERE country = 'Germany');
    
-- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions:
SELECT * 
FROM company 
WHERE id IN (SELECT company_id 
             FROM transaction 
             WHERE amount > (SELECT AVG(amount) 
                            FROM transaction));

-- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses:
SELECT company_name, id
FROM company
WHERE NOT EXISTS (SELECT company_id FROM transaction);

-- ************** Nivel 2  **************

/* Ejercicio 1 ***********************
Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes.
Mostra la data de cada transacció juntament amb el total de les vendes.*/
SELECT DATE(timestamp) AS Fecha,
			SUM(amount) AS Ventas_total
FROM transaction
GROUP BY Fecha
ORDER BY Ventas_total DESC
LIMIT 5;

/* Ejercicio 2 ***********************
Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.*/
SELECT company_name, round(AVG(amount), 2) AS Ventas_promedio
FROM transaction
JOIN company ON transaction.company_id = company.id
		GROUP BY company_name
		ORDER BY Ventas_promedio DESC;
        
/* Ejercicio 3 ***********************
En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la 
companyia "Non Institute". Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades
 en el mateix país que aquesta companyia.*/

-- Mostra el llistat aplicant JOIN i subconsultes:
SELECT * 
FROM transactions.transaction
JOIN company ON transaction.company_id = company.id
WHERE company.country = (
	SELECT country
    FROM company
    WHERE company_name = 'Non Institute');
    
-- Mostra el llistat aplicant solament subconsultes:
SELECT *
FROM transaction
WHERE company_id IN (
	SELECT id
    FROM company
    WHERE country = (
		SELECT country
        FROM company
        WHERE company_name = "Non Institute"));

-- ************** Nivel 3  **************

/* Ejercicio 1 ***********************
Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès 
entre 100 i 200 euros i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. 
Ordena els resultats de major a menor quantitat.*/
SELECT company_name, phone, country, timestamp, amount
FROM transaction
JOIN company ON transaction.company_id = company.id
    WHERE amount BETWEEN 100 AND 200
		AND DATE(timestamp) IN ('2021-04-29', '2021-07-20', '2022-03-13')
		ORDER BY amount DESC;

/* Ejercicio 2 ***********************
Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, per la qual cosa et demanen 
la informació sobre la quantitat de transaccions que realitzen les empreses, però el departament de recursos humans és exigent 
i vol un llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys.*/
SELECT company_name, COUNT(amount) AS Numero_transacciones
FROM transaction
JOIN company ON transaction.company_id = company.id
GROUP BY company_name
HAVING COUNT(transaction.amount) <> 4
ORDER BY Numero_transacciones DESC;


