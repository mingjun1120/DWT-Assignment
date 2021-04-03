-- Create dimension user sequence
DROP SEQUENCE dim_users_seq;
CREATE SEQUENCE dim_users_seq
START WITH 10001
INCREMENT BY 1;

DROP TABLE DIM_Users;
CREATE TABLE DIM_Users
(users_key     NUMBER      NOT NULL,
 usersID       NUMBER(5)   NOT NULL,
 gender        CHAR(1)     NOT NULL,
 dob           DATE        NOT NULL,
 city          VARCHAR(30) NOT NULL,
 state         VARCHAR(30) NOT NULL,
PRIMARY KEY(users_key)
);

--ETL, consider some transformation of the data
INSERT INTO DIM_Users
SELECT dim_users_seq.nextval, usersID, gender, dob, UPPER(city), UPPER(state)
FROM Users;

-- Select to see the data
SELECT dim_users_seq.nextval, usersID, gender, dob, UPPER(city), UPPER(state)
FROM Users;

-- Generate more users/customers
DROP TABLE orderdetails;
DROP TABLE orders;
DROP TABLE test_ord;
DROP TABLE promotion;
DROP TABLE users;
START C:\plsql2\0_Users.txt
START C:\plsql2\1_promotion.txt

SELECT usersID, months_between(sysdate, dob)/12 AS AGE
FROM users
ORDER BY AGE;

-- Update users' age who are below 18
UPDATE users
SET dob = add_months(dob, -72)
WHERE (months_between(sysdate, dob)/12) < 18;
COMMIT; 
-- update table must commit to save the data


SELECT MIN(usersID), MAX(usersID) FROM users;

DROP SEQUENCE temp_users_seq;
CREATE SEQUENCE temp_users_seq
START WITH 10301
INCREMENT BY 1;

DROP TABLE temp_users;
CREATE TABLE temp_users AS
SELECT * FROM users;

DECLARE
   CURSOR cur_users IS
      SELECT * FROM temp_users;

   rec_users cur_users%ROWTYPE;
   
   v_gender CHAR(1);
   v_dob    DATE;
   v_city   VARCHAR(30);
   v_state  VARCHAR(30);

BEGIN
   FOR rec_users IN cur_users LOOP
      IF (MOD(TRUNC(DBMS_RANDOM.value(0,1000)),3)) < 2 THEN
         v_gender := 'M';
      ELSE
         v_gender := 'F';
      END IF;
	  v_dob := rec_users.dob + (TRUNC(DBMS_RANDOM.value(-150,1001)));
      
      SELECT city, state INTO v_city, v_state
      FROM StateAndCity
      WHERE StateAndCityID = TRUNC(DBMS_RANDOM.value(10001,10042));

      INSERT INTO users VALUES(
          temp_users_seq.nextval, rec_users.name||temp_users_seq.currval,
          v_gender, v_dob, rec_users.phonenum,
          rec_users.email, rec_users.streetname,
          rec_users.postcode, v_city, v_state);	  
   END LOOP;
END;
/



TRUNC(DBMS_RANDOM.value(10,61)) -- generate numbers from 10 to 60

SELECT name||temp_users_seq.nextval FROM users;

SELECT MIN((months_between(sysdate,dob)/12)) Youngest,
       MAX((months_between(sysdate,dob)/12)) Oldest
FROM users;

SELECT MIN(usersID), MAX(usersID) FROM users;

-- Transaction per year and Total 6 years
SELECT SUM(No_of_Rows) AS Trans_Per_Year, SUM(No_of_Rows)*6 AS Total_6_Years
FROM
(
   SELECT Num_Gen, Num_Gen*Occurence AS No_of_Rows
   FROM(
      SELECT Num_Gen, COUNT(*) AS Occurence 
      FROM(
         SELECT TRUNC(DBMS_RANDOM.value(90,450)) AS Num_Gen 
         FROM orders)
      GROUP BY Num_Gen
      ORDER BY 1
   )    
);
