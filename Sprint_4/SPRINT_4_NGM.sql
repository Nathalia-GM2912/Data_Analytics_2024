-- ************** SPRINT 3 **************
-- ************** Nivel 1  **************

/*Descàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui, 
almenys 4 taules de les quals puguis realitzar les següents consultes:*/

-- Creamos la base de datos // He cambiado el nombre de la base de datos ya que me parecía redundante.
-- He vuelto a ejecturar el script y he eliminado la base de datos anterior. 
CREATE DATABASE BBDD_Sprint4;
-- CREATE DATABASE Sprint4;

USE BBDD_Sprint4;
-- USE Sprint4;

-- Creamos la tabla company
CREATE TABLE IF NOT EXISTS companies (
	id VARCHAR(15) PRIMARY KEY,
    company_name VARCHAR(255),
    phone VARCHAR(15),
    email VARCHAR(100),
    country VARCHAR(100),
    website VARCHAR(255)
);
-- Creamos la tabla credit_cards
CREATE TABLE IF NOT EXISTS credit_cards ( 
	id VARCHAR(20) PRIMARY KEY,
	user_id VARCHAR(20),
	iban VARCHAR(255),
	pan VARCHAR(45),
	pin CHAR(4),
	cvv CHAR(3),
	track1 VARCHAR(255),
	track2 VARCHAR(255),
	expiring_date varchar(255)
);

-- Creamos la tabla products
CREATE TABLE IF NOT EXISTS products (
	id INT PRIMARY KEY,
	product_name VARCHAR(100),
	price VARCHAR(10),
	colour VARCHAR(100),
	weight VARCHAR(100),
	warehouse_id VARCHAR(100)
);

-- Creamos tabla transactions
CREATE TABLE IF NOT EXISTS transactions (
	id VARCHAR(255) PRIMARY KEY,
	card_id VARCHAR(20),
	bussiness_id VARCHAR(20),
	timestamp TIMESTAMP, 
	amount DECIMAL(10,2),
	declined BOOLEAN,
	product_ids VARCHAR(20),
	user_id INT,
	lat FLOAT,
	longitude FLOAT
);

-- Creamos la tabla users
CREATE TABLE IF NOT EXISTS users (
	id INT PRIMARY KEY,
	name VARCHAR(100),
	surname VARCHAR(100),
	phone VARCHAR(150),
	email VARCHAR(150),
	birth_date VARCHAR(100),
	country VARCHAR(150),
	city VARCHAR (150),
	postal_code VARCHAR(100),
	address VARCHAR(255)
);

-- SET GLOBAL local_infile = 1;

-- SHOW GLOBAL VARIABLES LIKE 'local_infile';

-- No he cargado los archivos csv en las tablas por comando
/*LOAD DATA LOCAL INFILE      
'C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE      
'C:\Users\Nathalia\OneDrive\Escritorio\BootCamp\Proporcionados\Sprint_4_csv\credit_cards.csv'
INTO TABLE companies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;*/

/*Error Code: 3948. Loading local data is disabled; this must be enabled on both the client and server sides
Error Code: 2068. LOAD DATA LOCAL INFILE file request rejected due to restrictions on access.-- 
Error Code: 1064. You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'this must be enabled on both the client and server sides Error Code: 2068. LOAD ' at line 1
Error Code: 1046. No database selected Select the default DB to be used by double-clicking its name in the SCHEMAS list in the sidebar.*/

-- Cargar datos con “Table Data Import Wizard” ==> mostrado en .pdf

-- Se crean los indices para mejorar el rendimiento

alter table transactions change bussiness_id business_id varchar(20);

CREATE INDEX idx_companies ON transactions(business_id);
CREATE INDEX idx_credit_cards ON transactions(card_id);
CREATE INDEX idx_users ON transactions(user_id);

-- Se crean las relaciones entre las tablas con sus respectivos foreign key

-- Relación entre transactions y companies
ALTER TABLE transactions
	ADD CONSTRAINT fk_company
	FOREIGN KEY (business_id) REFERENCES companies(id);

-- Relación entre transactions y credit_cards
ALTER TABLE transactions
	ADD CONSTRAINT fk_credit_card
	FOREIGN KEY (card_id) REFERENCES credit_cards(id);
    
-- Relación entre transactions y users
ALTER TABLE transactions
	ADD CONSTRAINT fk_user
	FOREIGN KEY (user_id) REFERENCES users(id);

-- Relación entre transactions y products
/*ALTER TABLE transactions
	ADD CONSTRAINT fk_product
	FOREIGN KEY (products_ids) REFERENCES products(id);*/

/* Ejercicio 1 ***********************
Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.*/

SELECT CONCAT(u.name, " " , u.surname) AS 'Nombre Completo'
	FROM users u
  	WHERE (SELECT COUNT(t.id) FROM transactions t WHERE t.user_id = u.id) > 30;

-- Con esta consulta me faltaba información y la subconsulta y quería añadirle más.
    
SELECT CONCAT(u.name, " " , u.surname) AS 'Nombre Completo', country, city,                          
		(SELECT COUNT(t.id)
		FROM transactions t
		WHERE u.id = t.user_id) AS Numero_transacciones
	FROM users u
	GROUP BY u.id
	HAVING Numero_transacciones > 30
    ORDER BY Numero_transacciones DESC;

/* Ejercicio 2 ***********************
Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.*/

-- Definir alias diferente a credit_cards
SELECT co.company_name, cc.iban AS Tarjeta, ROUND(AVG(t.amount),2) AS promedio_importe 
	FROM companies co                                           -- alias companies = co
JOIN transactions t ON co.id = t.business_id
JOIN credit_cards cc ON cc.id = t.card_id						-- alias credit_cards = cc
	WHERE co.company_name = 'Donec Ltd'
	GROUP BY cc.iban;

-- ************** Nivel 2  **************

/*Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions van ser declinades
 i genera la següent consulta:	*/
 
-- Creamos la tabla Estado_Tarjeta
CREATE TABLE IF NOT EXISTS Card_Status (
	card_id VARCHAR(20) PRIMARY KEY,
    Status VARCHAR(30)
);

-- Se introducen los datos con filtros según la petición

INSERT INTO card_status (card_id, status)
WITH transacciones_tarjeta AS (
    SELECT card_id, 
           declined, 
           ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY timestamp DESC) AS row_transaction
    FROM transactions
)
SELECT card_id,
       CASE 
           WHEN SUM(declined) <= 2 THEN 'tarjeta activa'
           ELSE 'tarjeta inactiva'
       END AS estado_tarjeta
FROM transacciones_tarjeta
WHERE row_transaction <= 3
GROUP BY card_id;

-- Chequeamos como ha qeudado la tabla con los registros ingresados con el filtro efectuado con la tabla temporal.
SELECT * FROM card_status;

/* Ejercicio 2 ***********************
Quantes targetes estan actives?*/

SELECT COUNT(*) AS 'tarjetas activas'
FROM card_status
WHERE status ='tarjeta activa';




