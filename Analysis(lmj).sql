-- =======================================================================================================================
SET linesize 115
SET pagesize 240
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
CLEAR BUFFER
TTITLE OFF
CLEAR SCREEN

ACCEPT startdate DATE FORMAT 'DD-MON-YY'-
PROMPT 'Enter start date: '
ACCEPT enddate DATE FORMAT 'DD-MON-YY'-
PROMPT 'Enter end date: '

SELECT DISTINCT(R.rest_city) AS City
FROM DIM_Restaurant R, sales_fact S
WHERE S.date_key IN (SELECT date_key FROM dim_date
                     WHERE cal_date >= '&startdate' AND 
                     cal_date <= '&enddate'
                    ) AND R.restaurant_key = S.restaurant_key
ORDER BY R.rest_city;

ACCEPT city CHAR FORMAT A25-
PROMPT 'Select city: '

CREATE OR REPLACE VIEW q2a AS
SELECT SUM(S.LineTotal) AS Sales
FROM sales_fact S
WHERE S.date_key IN (SELECT date_key
                     FROM dim_date
                     WHERE cal_date >= '&startdate' AND
                     cal_date <= '&enddate'
                    ) AND S.restaurant_key IN (SELECT restaurant_key 
                                               FROM DIM_Restaurant 
                                               WHERE rest_city = UPPER('&city')
                                              );

CREATE OR REPLACE VIEW q2b AS
SELECT R.rest_ID AS "Restaurant ID", R.rest_name AS "Restaurant Name", SUM(S.LineTotal) AS Sales
FROM sales_fact S, DIM_Restaurant R
WHERE S.date_key IN (SELECT date_key
                     FROM dim_date 
                     WHERE cal_date >= '&startdate' AND cal_date <= '&enddate'
                    ) AND R.rest_city = UPPER('&city') AND R.restaurant_key = S.restaurant_key
GROUP BY R.rest_ID, R.rest_name
ORDER BY R.rest_ID;

TTITLE CENTER '===================================================================================' SKIP 1 -
CENTER 'Sales Performance of Restaurant in ' '&city' ' from ' '&startdate' ' to ' '&enddate' SKIP 1 -
CENTER '===================================================================================' -
RIGHT 'Page: ' FORMAT 999 SQL.PNO SKIP 2
BREAK ON rest_city SKIP 1;
COMPUTE SUM LABEL 'TOTAL' OF Total_Sales ON rest_city;
COLUMN Total_Sales Heading "Total Sales" FORMAT $999,999,999,990.90
COLUMN Sales_Percentage Heading "Sales Percentage" FORMAT 990.90
COLUMN rest_ID Heading "Restaurant ID" FORMAT 999999
COLUMN rest_name Heading "Restaurant Name" FORMAT A30
COLUMN rest_city Heading "City" FORMAT A25
CLEAR SCREEN

SELECT R.rest_city, R.rest_ID, R.rest_name,
       (((SELECT Sales FROM q2b WHERE "Restaurant ID" = R.rest_ID) / (SELECT * FROM q2a))*100) AS Sales_Percentage,
       (SELECT Sales FROM q2b WHERE "Restaurant ID" = R.rest_ID) AS Total_Sales
FROM sales_fact S, DIM_Restaurant R
WHERE R.rest_city = UPPER('&city') AND R.restaurant_key = S.restaurant_key
GROUP BY R.rest_city, R.rest_ID, R.rest_name
ORDER BY Sales_Percentage DESC;




-- =======================================================================================================================
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
CLEAR BUFFER
TTITLE OFF
CLEAR SCREEN
SET LINESIZE 100
SET PAGESIZE 140

ACCEPT year DATE FORMAT 'YYYY'-
PROMPT 'Enter year: '

CREATE OR REPLACE VIEW q1a AS
SELECT R.rest_ID, R.rest_city, SUM(S.LineTotal) AS c_sales
FROM sales_fact S, dim_date D, DIM_Restaurant R
WHERE S.date_key = D.date_key AND S.restaurant_key = R.restaurant_key AND D.cal_Year = '&year'
GROUP BY R.rest_ID, R.rest_city
ORDER BY R.rest_city;

CREATE OR REPLACE VIEW q1b AS
SELECT D.cal_quarter, R.rest_ID, R.rest_city, SUM(S.LineTotal) AS o_sales
FROM sales_fact S, dim_date D, DIM_Restaurant R
WHERE S.date_key = D.date_key AND S.restaurant_key = R.restaurant_key AND D.cal_Year = '&year'
GROUP BY R.rest_ID, R.rest_city, D.cal_quarter
ORDER BY R.rest_city;


TTITLE CENTER '============================================================' SKIP 1 -
CENTER 'Quarter Sales Rate of Restaurants in the Year ' '&year' SKIP 1 -
CENTER '============================================================' -
RIGHT 'Page: ' FORMAT 999 SQL.PNO SKIP 2

BREAK ON rest_ID ON rest_city SKIP 1
COMPUTE SUM LABEL 'TOTAL' OF Sales ON rest_city SKIP 3

COLUMN Sales FORMAT $999,999,999,990.90
COLUMN QUARTER_SALES_RATE Heading "Quarter Sales Rate(%)" FORMAT 990.90
COLUMN rest_ID Heading "Restaurant ID" FORMAT 99999
COLUMN rest_city Heading "City" FORMAT A25
COLUMN cal_quarter Heading "Quarter" FORMAT A7
CLEAR SCREEN
SELECT A.rest_city, A.rest_ID, A.cal_quarter, A.o_sales AS Sales, ((A.o_sales/B.c_sales)*100) AS QUARTER_SALES_RATE
FROM q1b A, q1a B
WHERE A.rest_ID = B.rest_ID AND A.rest_city = B.rest_city;
-- WHERE A.rest_ID = B.rest_ID AND A.rest_city = 'AMPANG' AND B.rest_city = 'AMPANG'
-- ORDER BY A.rest_city, A.rest_ID, A.cal_quarter;


-- =======================================================================================================================
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
CLEAR BUFFER
TTITLE OFF
CLEAR SCREEN
SET LINESIZE 130
SET PAGESIZE 100

ACCEPT start_date1 DATE FORMAT 'DD-MON-YY'-
PROMPT 'Enter 1st start date (DD-MON-YY): '

ACCEPT end_date1 DATE FORMAT 'DD-MON-YY'-
PROMPT 'Enter 1st end date (DD-MON-YY): '

ACCEPT start_date2 DATE FORMAT 'DD-MON-YY'-
PROMPT 'Enter 2nd start date (DD-MON-YY): '

ACCEPT end_date2 DATE FORMAT 'DD-MON-YY'-
PROMPT 'Enter 2nd end date (DD-MON-YY): '

ACCEPT state CHAR FORMAT A35-
PROMPT 'Enter state name: '

CREATE OR REPLACE VIEW top5_restaurant AS
SELECT * FROM (SELECT R.rest_name, R.rest_TypeName, SUM(SF.LineTotal) as Sales
               FROM DIM_Restaurant R, Sales_Fact SF
               WHERE R.restaurant_key = SF.restaurant_key
                     AND SF.date_key IN (SELECT date_key FROM Dim_Date WHERE cal_date BETWEEN '&start_date1' AND '&end_date1')
                     AND SF.restaurant_key IN (SELECT restaurant_key FROM DIM_Restaurant WHERE rest_state = UPPER('&state'))
               GROUP BY R.rest_name, R.rest_TypeName
               ORDER BY Sales DESC
              )
WHERE ROWNUM <= 5;

CREATE OR REPLACE VIEW ranked_top5_restaurant AS
SELECT rest_name, rest_TypeName, Sales, ROWNUM as Rank
FROM top5_restaurant;

CREATE OR REPLACE VIEW all_restaurant AS
SELECT R.rest_name, R.rest_TypeName, SUM(SF.LineTotal) AS Sales
FROM DIM_Restaurant R, Sales_Fact SF
WHERE R.restaurant_key = SF.restaurant_key
      AND SF.date_key IN (SELECT date_key FROM Dim_Date WHERE cal_date BETWEEN '&start_date2' AND '&end_date2') 
      AND SF.restaurant_key IN (SELECT restaurant_key FROM DIM_Restaurant WHERE rest_state = UPPER('&state'))
GROUP BY R.rest_name, R.rest_TypeName
ORDER BY Sales DESC;

CREATE OR REPLACE VIEW rank_all_restaurant AS
SELECT rest_name, rest_TypeName, Sales, ROWNUM AS Rank
FROM all_restaurant;

DROP TABLE restaurant_list;
CREATE TABLE restaurant_list
(rest_name     VARCHAR(50),
 rest_TypeName VARCHAR(20),
 Sales         NUMBER(3,2),
 Rank          NUMBER(1)
);

INSERT INTO restaurant_list
SELECT rest_name, rest_TypeName, 0, 0
FROM DIM_Restaurant
WHERE rest_name NOT IN (SELECT rest_name FROM all_restaurant);

CREATE OR REPLACE VIEW ranked_all_restaurant AS
SELECT * FROM restaurant_list UNION
SELECT * FROM rank_all_restaurant;

COLUMN rest_name Heading "Restaurant Name" FORMAT A50
COLUMN rest_TypeName Heading "Restaurant Type" FORMAT A20
COLUMN "Sales (Before)" FORMAT 999999990.90
COLUMN "Sales (After)" FORMAT 999999990.90

TTITLE CENTER '===================================================================================' SKIP 1 -
CENTER 'Rank of Top 5 Restaurant''s Sales in state ' '&state' ' from ' '&start_date1' ' to ' '&end_date1' SKIP 1 -
CENTER '===================================================================================' -
RIGHT 'Page: ' FORMAT 999 SQL.PNO SKIP 2

SELECT A.rest_name, A.rest_TypeName, A.Sales AS "Sales (Before)", A.Rank AS "Rank (Before)", B.Sales AS "Sales (After)", B.Rank AS "Rank (After)"
FROM ranked_top5_restaurant A, ranked_all_restaurant B
WHERE A.rest_name = B.rest_name
ORDER BY A.Sales desc;