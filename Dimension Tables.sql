------------------------------------------- DIMENSION USERS --------------------------------
-- Create dimension user sequence
DROP SEQUENCE dim_users_seq;
CREATE SEQUENCE dim_users_seq
START WITH 10001
INCREMENT BY 1;

DROP TABLE DIM_Users;
CREATE TABLE DIM_Users
(users_key       NUMBER      NOT NULL,
 usersID         NUMBER(5)   NOT NULL,
 gender          CHAR(1)     NOT NULL,
 dob             DATE        NOT NULL,
 city            VARCHAR(30) NOT NULL,
 state           VARCHAR(30) NOT NULL,
PRIMARY KEY(users_key)
);

--ETL, consider some transformation of the data
INSERT INTO DIM_Users
SELECT dim_users_seq.nextval, usersID, gender, dob, UPPER(city), UPPER(state)
FROM Users;

-- Select to see the data
SELECT dim_users_seq.nextval, usersID, gender, dob, UPPER(city), UPPER(state)
FROM Users;




------------------------------------------- DIMENSION PROMOTION --------------------------------
-- Create dimension user sequence
DROP SEQUENCE dim_promotion_seq;
CREATE SEQUENCE dim_promotion_seq
START WITH 10001
INCREMENT BY 1;

DROP TABLE DIM_Promotion;
CREATE TABLE DIM_Promotion
(promotion_key  NUMBER      NOT NULL,
 promotionID    NUMBER(5)   NOT NULL,
 promoteCode    VARCHAR(15) NOT NULL,
 discountRate   NUMBER(2)   NOT NULL,
 status         VARCHAR(10) NOT NULL,
PRIMARY KEY(promotion_key)
);

--ETL, consider some transformation of the data
INSERT INTO DIM_Promotion
SELECT dim_promotion_seq.nextval, PromotionId, PromoteCode, DiscountRate, UPPER(Status)
FROM Promotion;

-- Select to see the data
SELECT dim_promotion_seq.nextval, PromotionId, PromoteCode, DiscountRate, UPPER(Status)
FROM Promotion;




------------------------------------------- DIMENSION RESTAURANT --------------------------------
-- Create dimension restaurant sequence
DROP SEQUENCE dim_restaurant_seq;
CREATE SEQUENCE dim_restaurant_seq
START WITH 10001
INCREMENT BY 1;

DROP TABLE DIM_Restaurant;
CREATE TABLE DIM_Restaurant
(restaurant_key     NUMBER        NOT NULL,
 rest_branchID      NUMBER(5)     NOT NULL,
 rest_ID            NUMBER(5)     NOT NULL,
 rest_name          VARCHAR(60)   NOT NULL,
 rest_TypeName      VARCHAR(20)   NOT NULL,
 rest_city          VARCHAR(30)   NOT NULL,
 rest_state          VARCHAR(20)   NOT NULL,
PRIMARY KEY(restaurant_key)
);

--ETL, consider some transformation of the
INSERT INTO DIM_Restaurant
SELECT dim_restaurant_seq.nextval, B.BranchID, A.restaurantID, UPPER(A.name), UPPER(C.typeName), UPPER(B.city), UPPER(B.state)
FROM Restaurant A, Branch B, RestaurantType C
WHERE (A.restaurantID = B.restaurantID) AND (A.restaurantTypeID = C.restaurantTypeID);

--Select to see the data
SELECT B.BranchID, A.restaurantID, A.name, C.typeName, B.city, B.state
FROM Restaurant A, Branch B, RestaurantType C
WHERE (A.restaurantID = B.restaurantID) AND (A.restaurantTypeID = C.restaurantTypeID);

-- To see all branch ID for each Restaurant
SELECT
    CASE WHEN ROW_NUMBER() OVER(PARTITION BY rest_name ORDER BY REST_BRANCHID) = 1 
    THEN rest_name ELSE NULL END AS "Restaurant Name", REST_BRANCHID
    FROM DIM_Restaurant
    ORDER BY rest_name, REST_BRANCHID;




------------------------------------------- DIMENSION DATE --------------------------------
-- Create dimension date sequence
DROP SEQUENCE date_seq;
CREATE SEQUENCE date_seq
START WITH 100001
INCREMENT BY 1;

DROP TABLE DIM_Date;
CREATE TABLE DIM_Date
(Date_key             number    NOT NULL,  -- surrogate key
 cal_date             date      NOT NULL,  -- every date of the date range
 dayOfWeek            number(1), -- 1 to 7
 dayNum_calMonth      number(2), -- 1 to 31
 dayNum_calYear       number(3), -- 1 to 366
 calWeek_endDate      date,
 calWeek_numYear      number(2),  -- 1 to 53 weeks
 calMonth_name        varchar(9), -- JANUARY to DECEMBER
 calMonth_numYear     number(2),  -- 01 to 12
 cal_year_month       char(7),    -- 'YYYY-MM'
 cal_quarter          char(2),    -- 'Q1' to 'Q4'
 cal_Year             number(4),
 holiday_ind          char(1),    -- 'Y' or 'N'
 weekday_ind          char(1),    -- 'Y' or 'N'
PRIMARY KEY(Date_key)
);

DECLARE
   start_date      date; -- start of analysis date
   end_date        date; -- end of analysis date 
   v_dayOfWeek     number(1);
   v_dayNumCalMth  number(2);
   v_dayNumCalYr   number(3);
   v_weekEndDate   date;
   v_weekYear      number(2);
   v_calMonthName  varchar(9);
   v_calMonthNo    number(2);
   v_calYear_month char(7);
   v_quarter       char(2);
   v_calYear       number(4);
   v_weekDay_ind   char(1);
   v_holiday_ind   char(1);
   
BEGIN
-- set the start and end date e.g. date from 1 Jan 2015 to 01 Mar 2021
   start_date := TO_DATE('01/01/2015','dd/mm/yyyy');
   end_date   := TO_DATE('24/03/2021','dd/mm/yyyy');
   v_holiday_ind := 'N';

   WHILE (start_date <= end_date) LOOP
      v_dayOfWeek    := TO_CHAR(start_date,'D');
      v_dayNumCalMth := EXTRACT (day FROM start_date);
      v_dayNumCalYr  := TO_CHAR(start_date,'ddd');
      v_weekEndDate  := start_date+(7 - TO_CHAR(start_date,'d'));
      v_weekYear     := TO_CHAR(start_date,'ww');
      v_calMonthName := TO_CHAR(start_date,'MONTH');     
      v_calMonthNo   := EXTRACT (MONTH FROM start_date);
      v_calYear_month:= TO_CHAR(start_date,'YYYY-MM');
      v_calYear      := EXTRACT (year FROM start_date);

      IF (v_calMonthNo <=3) THEN
         v_quarter :='Q1';
      ELSIF (v_calMonthNo <=6) THEN
         v_quarter :='Q2';
      ELSIF (v_calMonthNo <=9) THEN
         v_quarter :='Q3';
      ELSE
         v_quarter :='Q4';
      END IF;

      IF (v_dayOfWeek BETWEEN 2 AND 6) THEN
          v_weekDay_ind := 'Y';  
      ELSE
          v_weekDay_ind := 'N';
      END IF;

 INSERT INTO DIM_Date VALUES(
             date_seq.nextval, start_date, v_dayOfWeek,
             v_dayNumCalMth,v_dayNumCalYr, v_weekEndDate, v_weekYear,
             v_calMonthName, v_calMonthNo, v_calYear_month, v_quarter,
             v_calYear, v_holiday_ind, v_weekDay_ind);
/*
      dbms_output.put_line(date_seq.nextval||' date is : '||TO_CHAR(start_date,'dd-mm-yyyy')||
      ' '||v_dayOfWeek||' '||v_dayNumCalMth||' '||v_dayNumCalYr||' '||v_weekDay_ind);
*/
      start_date := start_date+1;
   END LOOP;
END;
/

