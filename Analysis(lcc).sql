start C:\Users\User\Documents\GitHub\DWT-Assignment\Analysis(lcc).sql
-- ------------------------------------ Report 1 --------------------------------------------

SET LINESIZE 100
SET PAGESIZE 140
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
CLEAR BUFFER
TTITLE OFF

SET LINESIZE 100
SET PAGESIZE 140
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
CLEAR BUFFER
TTITLE OFF

ACCEPT year DATE FORMAT 'YYYY'-
PROMPT 'Enter Year (YYYY): '

COLUMN Sales FORMAT $999,999,999,990.90
COLUMN QUARTER_SALES_RATE Heading "Quarter Sales Rate(%)" FORMAT 990.90
COLUMN rest_ID Heading "Restaurant ID" FORMAT 99999
COLUMN rest_city Heading "City" FORMAT A25
COLUMN cal_quarter Heading "Quarter" FORMAT A7

TTITLE CENTER '============================================================' SKIP 1 -
CENTER 'Quarter Sales Rate of Restaurants in the Year ' '&year' SKIP 1 -
CENTER '============================================================' -
RIGHT 'Page: ' FORMAT 999 SQL.PNO SKIP 2

BREAK ON rest_ID ON rest_city SKIP 1
COMPUTE SUM LABEL 'TOTAL' OF Sales ON rest_city SKIP 3

CREATE OR REPLACE VIEW Sales AS
SELECT   R.rest_ID, R.rest_city, SUM(S.LineTotal) AS c_sales
FROM     Sales_Fact S, DIM_Date D, DIM_Restaurant R
WHERE    S.date_key = D.date_key AND 
         S.restaurant_key = R.restaurant_key AND 
         D.cal_Year = '&year'
GROUP BY R.rest_ID, R.rest_city
ORDER BY R.rest_city;

CREATE OR REPLACE VIEW Quater_Sales AS
SELECT   D.cal_quarter, R.rest_ID, R.rest_city, SUM(S.LineTotal) AS o_sales
FROM     Sales_Fact S, DIM_Date D, DIM_Restaurant R
WHERE    S.date_key = D.date_key AND 
         S.restaurant_key = R.restaurant_key AND 
         D.cal_Year = '&year'
GROUP BY R.rest_ID, R.rest_city, D.cal_quarter
ORDER BY R.rest_city;

SELECT   A.rest_city, A.rest_ID, A.cal_quarter, A.o_sales AS Sales, ((A.o_sales/B.c_sales)*100) AS QUARTER_SALES_RATE
FROM     Quater_Sales A, Sales B
WHERE    A.rest_ID = B.rest_ID AND 
         A.rest_city = B.rest_city
ORDER BY A.rest_city, A.rest_ID, A.cal_quarter;

START D:\Text\sql_files\report1.sql

-- ------------------------------------ Report 2 --------------------------------------------

SET linesize 115
SET pagesize 240
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
CLEAR BUFFER
TTITLE OFF

ACCEPT r2_start_year DATE FORMAT 'YYYY'-
PROMPT 'Enter Start Year (YYYY): '

ACCEPT r2_end_year DATE FORMAT 'YYYY'-
PROMPT 'Enter End Year (YYYY)  : '

ACCEPT r2_state CHAR FORMAT A30-
PROMPT 'Enter State            : '

COLUMN state Heading "State" FORMAT A15
COLUMN year Heading "Year"
COLUMN Sales Heading "Current Year Sales" FORMAT $999,999,999.99
COLUMN Previous_year_sales Heading "Previous Year Sales" FORMAT $999,999,999.99
COLUMN Growth (%) FORMAT 99999.99
SET linesize 100
SET pagesize 100

TTITLE LEFT ' ===========================================================================' SKIP 1 -
LEFT '      Growth of Sales Analysis Between Year ' '&r2_start_year' ' And Year ' '&r2_end_year' ' in ' '&r2_state' SKIP 1 -
LEFT ' ===========================================================================' SKIP 2-
LEFT 'Page: ' FORMAT 999 SQL.PNO SKIP 2
BREAK ON state SKIP 2

CREATE OR REPLACE VIEW Growth AS
SELECT *
FROM   (SELECT   B.state, A.cal_year AS year, SUM(C.LineTotal) AS sales
        FROM     DIM_Date A, DIM_Users B, Sales_Fact C
        WHERE    A.date_key = C.date_key AND
                 B.users_key = C.users_key
        GROUP BY B.state, A.cal_year)
WHERE   year BETWEEN '&r2_start_year' AND '&r2_end_year' AND state = UPPER('&r2_state');

SELECT Growth.*,
       LAG(Growth.Sales, 1) OVER (ORDER BY Growth.year) AS Previous_year_sales, 
       (Growth.Sales - LAG(Growth.Sales, 1) OVER (ORDER BY Growth.year)) * 100 / LAG(Growth.Sales,1) OVER
       (ORDER BY Growth.year) AS "Growth (%)"
FROM Growth;

START D:\Text\sql_files\report2.sql

-- ------------------------------------ Report 3 --------------------------------------------

SET linesize 115
SET pagesize 240
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
CLEAR BUFFER
TTITLE OFF

ACCEPT r3_start_year DATE FORMAT 'YYYY'- 
PROMPT 'Enter Start Year (YYYY): '

ACCEPT r3_end_year DATE FORMAT 'YYYY'-
PROMPT 'Enter End Year (YYYY)  : '

ACCEPT r3_state CHAR FORMAT 'A70'-
PROMPT 'Enter State            : '

COLUMN city FORMAT HEADING "City" A20
COLUMN "Total Sales" FORMAT $999,999,999.99
COLUMN Contribution HEADING "Contribution (%)" FORMAT 90.9999
COLUMN user_id HEADING "Customer No."

TTITLE LEFT ' =========================================================================================' SKIP 1 -
LEFT ' Top 5 Domestic Users in '&r3_state' with High Sales Contribution' ' from Year '&r3_start_year' to Year '&r3_end_year''SKIP 1 -
LEFT ' =========================================================================================' SKIP 2-
LEFT 'Page: ' FORMAT 999 SQL.PNO SKIP 2

BREAK ON user_id ON Contribution ON report
COMPUTE SUM LABEL 'TOTAL' OF Contribution ON report

CREATE OR REPLACE VIEW Sales_Fact_Date AS
SELECT *
FROM   Sales_Fact
WHERE  Date_key IN (SELECT Date_key
                    FROM   DIM_Date
                    WHERE  cal_Year >= '&r3_start_year' AND
                           cal_Year <= '&r3_end_year');

CREATE OR REPLACE VIEW All_User_Sales AS
SELECT SUM(S.LineTotal) AS "Total Sales"
FROM   Sales_Fact_Date S;

CREATE OR REPLACE VIEW Top5_User_Sales AS
SELECT   * 
FROM     (SELECT A.usersID, A.City, SUM(S.LineTotal) AS "Total Sales"
          FROM   Dim_Users A, Sales_Fact_Date S
          WHERE  A.Users_key = S.Users_key AND
                 S.Users_key IN (SELECT Users_key
                                 FROM   Dim_Users
                                 WHERE  state LIKE UPPER('%&r3_state%'))
          GROUP BY A.usersID, A.City
          ORDER BY "Total Sales" DESC
          )
WHERE ROWNUM <= 5;

SELECT   B.usersID, B.City, B."Total Sales", 
         B."Total Sales" / A."Total Sales" * 100 AS Contribution
FROM     All_User_Sales A, Top5_User_Sales B
GROUP BY B.usersID, B.City, B."Total Sales", A."Total Sales"
ORDER BY Contribution DESC;

START D:\Text\sql_files\report3.sql
