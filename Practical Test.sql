-------------------------------------------------- PRACTICAL TEST --------------------------------------------
CREATE TABLE productlines(
 productLine     VARCHAR(50)   NOT NULL,
 textDescription VARCHAR(4000) DEFAULT NULL,
 htmlDescription VARCHAR(1000),
 image           BLOB,
 PRIMARY KEY (productLine),
 CONSTRAINT chk_productLine CHECK (REGEXP_LIKE(productLine,'^[a-zA-Z ]+$'))
);

CREATE TABLE products(
 productCode        VARCHAR(15)   NOT NULL,
 productName        VARCHAR(70)   NOT NULL,
 productLine        VARCHAR(50)   NOT NULL,
 productScale       VARCHAR(10)   NOT NULL,
 productVendor      VARCHAR(50)   NOT NULL,
 productDescription VARCHAR(4000) NOT NULL,
 quantityInStock    NUMBER(4)     NOT NULL,
 buyPrice           NUMBER(7,2)   NOT NULL,
 MSRP               NUMBER(7,2)   NOT NULL,
 PRIMARY KEY (productCode),
 CONSTRAINT chk_productCode CHECK (REGEXP_LIKE(productCode,'^[S][0-9]+[_]{1}[0-9]{3,4}$')),
 CONSTRAINT chk_quantityInStock CHECK (REGEXP_LIKE(quantityInStock, '^[[:digit:]]+$') AND quantityInStock > 0),
 CONSTRAINT chk_buyPrice CHECK (REGEXP_LIKE(quantityInStock,'^\d*\.?\d+$') AND buyPrice > 0),
 CONSTRAINT chk_MSRP CHECK (REGEXP_LIKE(quantityInStock,'^\d*\.?\d+$') AND MSRP > 0)
);

CREATE TABLE offices(
 officeCode   VARCHAR(10) NOT NULL,
 city         VARCHAR(50) NOT NULL,
 phone        VARCHAR(50) NOT NULL,
 addressLine1 VARCHAR(50) NOT NULL,
 addressLine2 VARCHAR(50) DEFAULT NULL,
 state        VARCHAR(50) DEFAULT NULL,
 country      VARCHAR(50) NOT NULL,
 postalCode   VARCHAR(15) NOT NULL,
 territory    VARCHAR(10) NOT NULL,
 PRIMARY KEY (officeCode),
 CONSTRAINT chk_officeCode CHECK (REGEXP_LIKE(officeCode,'^[0-9]$')),
 CONSTRAINT chk_city CHECK (REGEXP_LIKE(city,'^[a-zA-Z ]+$')),
 CONSTRAINT chk_phone CHECK (REGEXP_LIKE(phone,'^[+][0-9 ]+$')),
 CONSTRAINT chk_country CHECK (REGEXP_LIKE(country,'^[a-zA-Z ]+$'))
);

CREATE TABLE employees(
 employeeNumber NUMBER(11)    NOT NULL,
 lastName       VARCHAR(50)   NOT NULL,
 firstName      VARCHAR(50)   NOT NULL,
 extension      VARCHAR(10),
 email          VARCHAR(100),
 officeCode     VARCHAR(10),
 reportsTo      NUMBER(11)    DEFAULT NULL,
 jobTitle       VARCHAR(50),
 PRIMARY KEY (employeeNumber),
 CONSTRAINT chk_employeeNumber CHECK (REGEXP_LIKE(employeeNumber,'^[[:digit:]]+$') AND employeeNumber >= 1000),
 CONSTRAINT chk_lastName CHECK (REGEXP_LIKE(lastName,'^[a-zA-Z ]+$')),
 CONSTRAINT chk_firstName CHECK (REGEXP_LIKE(firstName,'^[a-zA-Z ]+$')),
 CONSTRAINT chk_email CHECK (REGEXP_LIKE(email,'^[a-zA-Z]\w+@(\S+)$'))
);

DROP TABLE customers;
CREATE TABLE customers(
 customerNumber         NUMBER(11)   NOT NULL,
 customerName           VARCHAR(50)  NOT NULL,
 contactLastName        VARCHAR(50)  NOT NULL,
 contactFirstName       VARCHAR(50)  NOT NULL,
 phone                  VARCHAR(50)  NOT NULL,
 addressLine1           VARCHAR(50)  NOT NULL,
 addressLine2           VARCHAR(50)  DEFAULT NULL,
 city                   VARCHAR(50)  NOT NULL,
 state                  VARCHAR(50)  DEFAULT NULL,
 postalCode             VARCHAR(15)  DEFAULT NULL,
 country                VARCHAR(50)  NOT NULL,
 salesRepEmployeeNumber NUMBER(11)   DEFAULT NULL,
 creditLimit            NUMBER(9,2)  DEFAULT NULL,
 PRIMARY KEY (customerNumber),
 CONSTRAINT chk_customerNumber CHECK (REGEXP_LIKE(customerNumber,'^[[:digit:]]+$') AND customerNumber >= 100),
 CONSTRAINT chk_cust_phone CHECK (REGEXP_LIKE(phone,'[0-9\(\)\+\-\. ]+$')),
 CONSTRAINT chk_salesRepEmployeeNumber CHECK (REGEXP_LIKE(salesRepEmployeeNUMBER, '^[[:digit:]]+$') AND salesRepEmployeeNUMBER > 0),
 CONSTRAINT chk_creditLimit CHECK (REGEXP_LIKE(creditLimit,'^[[:digit:]]+$'))
);

DROP TABLE orders;
CREATE TABLE orders(
 orderNumber    NUMBER(11)    NOT NULL,
 orderDate      DATE          NOT NULL,
 requiredDate   DATE          NOT NULL,
 shippedDate    DATE          DEFAULT NULL,
 status         VARCHAR(15)   NOT NULL,
 comments       VARCHAR(500),
 customerNumber NUMBER(11)    NOT NULL,
 PRIMARY KEY (orderNumber),
 CONSTRAINT chk_orderNumber CHECK (REGEXP_LIKE(orderNumber,'^[[:digit:]]+$') AND orderNumber >= 10000),
 CONSTRAINT chk_requiredDate CHECK (requiredDate > orderDate),
 CONSTRAINT chk_ship CHECK (shippedDate > orderDate),
 CONSTRAINT chk_status CHECK (UPPER(status) IN ('SHIPPED','RESOLVED', 'ON HOLD', 'DISPUTED', 'IN PROCESS', 'CANCELLED'))
);

CREATE TABLE orderdetails(
 orderNumber     NUMBER(11)  NOT NULL,
 productCode     VARCHAR(15) NOT NULL,
 quantityOrdered NUMBER(4)   NOT NULL,
 priceEach       NUMBER(7,2) NOT NULL,
 orderLineNumber NUMBER(3)   NOT NULL,
 PRIMARY KEY (orderNumber, productCode),
 CONSTRAINT chk_quantityOrdered CHECK (REGEXP_LIKE(quantityOrdered,'^[[:digit:]]+$') AND quantityOrdered > 0),
 CONSTRAINT chk_priceEach CHECK (REGEXP_LIKE(priceEach,'^\d*\.?\d+$') AND priceEach > 0),
 CONSTRAINT chk_orderLineNumber CHECK (REGEXP_LIKE(orderLineNumber,'^[[:digit:]]+$') AND orderLineNumber > 0)
);


------------------------------------------------------ SPOOL --------------------------------------------------------
spool C:\Users\Jun\Downloads\Sample_Run.txt

host hostname

SET linesize 190
SET pagesize 50

column machine FORMAT a30
column username FORMAT a30
SELECT sid, serial#, user#, username, ownerid, server, machine
FROM   v$session;

DESC productLines
DESC products
DESC offices
DESC employees
DESC customers
DESC orders
DESC orderdetails

column table_name FORMAT a20

SELECT table_name, tablespace_name 
FROM   user_tables;

column OWNER FORMAT a15
column constraint_name FORMAT a27
column search_condition FORMAT a89
column column_name FORMAT a25

SELECT   A.OWNER, A.CONSTRAINT_NAME, A.CONSTRAINT_TYPE,
         A.TABLE_NAME, B.COLUMN_NAME, A.SEARCH_CONDITION
FROM     user_constraints A
JOIN     user_cons_columns B
ON       A.CONSTRAINT_NAME=B.CONSTRAINT_NAME
WHERE    A.table_name IN (SELECT table_name FROM user_tables)
ORDER BY table_name;

spool off;