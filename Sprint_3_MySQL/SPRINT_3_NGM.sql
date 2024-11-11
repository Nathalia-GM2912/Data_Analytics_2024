-- ************** SPRINT 3 **************
-- ************** Nivel 1  **************

/* Ejercicio 1 ***********************
La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials sobre les targetes de crèdit.
La nova taula ha de ser capaç d'identificar de manera única cada targeta i establir una relació adequada amb les altres dues taules 
("transaction" i "company"). Després de crear la taula serà necessari que ingressis la informació del document denominat "dades_introduir_credit".
 Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.
 
 Diagrama y descripción en .pdf */
 
CREATE TABLE IF NOT EXISTS credit_card ( -- Crear la nueva tabla y que chequee que no existe antes.
    id VARCHAR(15) PRIMARY KEY, -- ID único de la tarjeta de crédito. Tiene que ser igual credit_card_id de transaction.
	iban VARCHAR(50),
    pan VARCHAR(25),
    pin INT,
    cvv INT,
    expiring_date VARCHAR(10)
); 

ALTER TABLE transaction
ADD CONSTRAINT fk_credit_card
FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);

/* Ejercicio 2 ***********************
El departament de Recursos Humans ha identificat un error en el número de compte de l'usuari amb ID CcU-2938.
La informació que ha de mostrar-se per a aquest registre és: R323456312213576817699999. Recorda mostrar que el canvi es va realitzar.*/
UPDATE credit_card
SET iban = 'R323456312213576817699999'
WHERE id = 'CcU-2938';

SELECT * FROM credit_card WHERE id = 'CcU-2938';

/* Ejercicio 3 ***********************
En la taula "transaction" ingressa un nou usuari amb la següent informació:

	Id	108B1D1D-5B23-A76C-55EF-C568E49A99DD
	credit_card_id	CcU-9999
	company_id	b-9999
	user_id	9999
	lat	829.999
	longitude	-117.999
	amount	111.11
	declined	0 */
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, timestamp, amount, declined) VALUES (
'108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', '829.999', '-117.999', '2022-03-13 00:27:34', '111.11', '0');

SELECT * FROM company WHERE id = 'b-9999';

/*Cuando he intentado insertar la fila, me ha salido un error:
Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails 
(`transactions`.`transaction`, CONSTRAINT `transaction_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `company` (`id`))

Esto quiere decir que hay un fallo, que se está intentado actualizar una fila en transaction pero no tiene relación con la tabla company.
Entonces hay que crear el registro en la tabla company con id = b-9999 y crear un registro en la tabla credit_card para el id CcU-9999*/

INSERT INTO company (id, company_name, phone, email, country, website) 
VALUES ('b-9999', 'NombreSprint3 Nivel1_ejercicio 3', '123456789', 'info@empresaSprint3_1_3.com', 'Sprint3_1_3', 'www.empresa_Sprint3_1_3.com');

SELECT * FROM credit_card WHERE id = 'CcU-9999';

INSERT INTO credit_card (id, iban, pan, pin, cvv, expiring_date) VALUES (
'CcU-9999', 'IBAN-9999', 'PAN-9999', 1234, 987, '2024-12-29');

SELECT * FROM transaction WHERE company_id = 'b-9999';

/* Ejercicio 4 ***********************
Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_*card. Recorda mostrar el canvi realitzat.*/
ALTER TABLE credit_card DROP COLUMN pan;

SHOW COLUMNS FROM credit_card;

-- ************** Nivel 2  **************

/* Ejercicio 1 ***********************
Elimina de la taula transaction el registre amb ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la base de dades. */

SELECT * FROM transaction WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

DELETE FROM transaction WHERE id =  '02C6201E-D90A-1859-B4EE-88D2986D3B02';

/* Ejercicio 2 ***********************
La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives. 
S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions. 
erà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: Nom de la companyia. 
Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. Presenta la vista creada, 
ordenant les dades de major a menor mitjana de compra.*/
CREATE VIEW VistaMarketing AS
SELECT company_name,
    phone,
    country,
    ROUND(AVG(amount),2) AS promedio_compra
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE declined = '0'
GROUP BY company_id;

SELECT *                   
FROM VistaMarketing
ORDER BY promedio_compra DESC;

/* Ejercicio 3 ***********************
Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"*/
SELECT *                   
FROM VistaMarketing
WHERE country = 'Germany'
ORDER BY promedio_compra DESC;

-- ************** Nivel 3  **************

/* Ejercicio 1 ***********************
La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. Un company del teu equip va realitzar modificacions en la 
base de dades, però no recorda com les va realitzar. Et demana que l'ajudis a deixar els comandos executats per a obtenir 
el següent diagrama:*/

-- En tabla credit_card añadir nueva columna fecha_actual con tipo de dato DATE
ALTER TABLE credit_card
ADD fecha_actual DATE;

/*En tabla credit_card cambiamos el tipo de datos de los campos:
id a VARCHAR(20)
pin VARCHAR(4) */
ALTER TABLE credit_card
MODIFY id VARCHAR(20) not null,
MODIFY pin VARCHAR(4) null default null;

-- En tabla company eliminar la columna website:
ALTER TABLE company
DROP COLUMN website;

-- Cambiar el nombre de la tabla user a data_user
RENAME TABLE user to data_user;

-- En tabla data_user cambiar columna de email a personal_email:
ALTER TABLE data_user
CHANGE email personal_email VARCHAR(150);

-- Crear el foreign key para cambiar la relación con la tabla transaction:

ALTER TABLE transactions.credit_card
ADD CONSTRAINT fk_credit_card_transaction
FOREIGN KEY (id) REFERENCES transactions.transaction (credit_card_id)
ON DELETE RESTRICT -- No permite eliminar una tarjeta de crédito si hay transacciones relacionadas.
ON UPDATE CASCADE; -- Si el id de una tarjeta de crédito cambia, ese cambio se hace automáticamente a la tabla transaction.

ALTER TABLE data_user
DROP FOREIGN KEY data_user_ibfk_1;

ALTER TABLE transaction
ADD FOREIGN KEY (user_id) REFERENCES data_user(id);

/* Ejercicio 2 ***********************
L'empresa també et sol·licita crear una vista anomenada "InformeTecnico" que contingui la següent informació:

ID de la transacció
Nom de l'usuari/ària
Cognom de l'usuari/ària
IBAN de la targeta de crèdit usada.
Nom de la companyia de la transacció realitzada.
Assegura't d'incloure informació rellevant de totes dues taules i utilitza àlies per a canviar de nom columnes segons sigui necessari.
Mostra els resultats de la vista, ordena els resultats de manera descendent en funció de la variable ID de transaction.

-- Reparar error == Error Code: 1452*/

SELECT user_id 
FROM transaction 
WHERE user_id NOT IN (SELECT id FROM data_user);

-- Creamos el registro
INSERT INTO data_user (id)
VALUES ('9999');

-- y comprobamos
SELECT * FROM data_user WHERE id = '9999';

-- Creamos la tabla

CREATE OR REPLACE VIEW InformeTecnico AS
SELECT transaction.id AS ID_Transaccion,
		CONCAT(data_user.name, " " , data_user.surname) AS 'Nombre Completo',
        data_user.personal_email AS email_contacto,
		credit_card.iban AS 'Numero Tarjeta',
		transaction.amount AS 'Importe transaccion',
		transaction.timestamp AS Fecha,
		CASE 
			WHEN transaction.declined = 0 THEN 'Aprobada'
			WHEN transaction.declined = 1 THEN 'Declinada'
		END AS Estado,
		company.company_name AS 'Nombre Empresa',
		company.country AS 'Pais Empresa'
FROM transaction
LEFT JOIN data_user ON transaction.user_id = data_user.id
RIGHT JOIN credit_card ON transaction.credit_card_id = credit_card.id
LEFT JOIN company ON transaction.company_id = company.id;

--  Visualizamos
SELECT *
FROM InformeTecnico
ORDER BY ID_Transaccion DESC;
