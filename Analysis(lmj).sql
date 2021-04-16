-- =============================================== Restaurant_Sales_Performance ===============================================
SET linesize 115
SET pagesize 240
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
CLEAR BUFFER
TTITLE OFF
CLEAR SCREEN

ACCEPT startdate DATE FORMAT 'DD-MON-YY'-
PROMPT 'Enter start date (DD-MON-YY): '
ACCEPT enddate DATE FORMAT 'DD-MON-YY'-
PROMPT 'Enter end date (DD-MON-YY): '

SELECT DISTINCT(R.rest_city) AS City
FROM DIM_Restaurant R, sales_fact S
WHERE S.date_key IN (SELECT date_key FROM dim_date
                     WHERE cal_date >= '&startdate' AND 
                     cal_date <= '&enddate'
                    ) AND R.restaurant_key = S.restaurant_key
ORDER BY R.rest_city;

ACCEPT city CHAR FORMAT A25-
PROMPT 'Select city: '

CREATE OR REPLACE VIEW total_sales1 AS
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

CREATE OR REPLACE VIEW total_sales2 AS
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
COLUMN Total_Sales Heading "Total Sales(RM)" FORMAT 999,999,999,990.90
COLUMN Sales_Percentage Heading "Sales Percentage(%)" FORMAT 990.90
COLUMN rest_ID Heading "Restaurant ID" FORMAT 999999
COLUMN rest_name Heading "Restaurant Name" FORMAT A30
COLUMN rest_city Heading "City" FORMAT A25
CLEAR SCREEN

SELECT R.rest_city, R.rest_ID, R.rest_name,
       (((SELECT Sales FROM total_sales2 WHERE "Restaurant ID" = R.rest_ID) / (SELECT * FROM total_sales1))*100) AS Sales_Percentage,
       (SELECT Sales FROM total_sales2 WHERE "Restaurant ID" = R.rest_ID) AS Total_Sales
FROM sales_fact S, DIM_Restaurant R
WHERE R.rest_city = UPPER('&city') AND R.restaurant_key = S.restaurant_key
GROUP BY R.rest_city, R.rest_ID, R.rest_name
ORDER BY Sales_Percentage DESC;




-- =============================================== Top_5_Restaurant_In_State ===============================================
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
CLEAR BUFFER
TTITLE OFF
CLEAR SCREEN
SET LINESIZE 138
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
COLUMN Sales_in_RM_Before Heading "Sales in RM (Before)" FORMAT 9,999,999,990.90
COLUMN Sales_in_RM_After Heading "Sales in RM (After)" FORMAT 9,999,999,990.90

TTITLE CENTER '================================================================================================================================' SKIP 1 -
CENTER 'Rank of Top 5 Restaurant''s Sales in state ' '&state' ' from ' '&start_date1' ' to ' '&end_date1' ' and from ' '&start_date2' ' to ' '&end_date2' SKIP 1 -
CENTER '================================================================================================================================' SKIP 1 -
RIGHT 'Page: ' FORMAT 999 SQL.PNO SKIP 2

SELECT A.rest_name, A.rest_TypeName, A.Sales AS Sales_in_RM_Before, A.Rank AS "Rank (Before)", B.Sales AS Sales_in_RM_After, B.Rank AS "Rank (After)"
FROM ranked_top5_restaurant A, ranked_all_restaurant B
WHERE A.rest_name = B.rest_name
ORDER BY A.Sales DESC;




-- =============================================== Sales_Comparison_of_Each_Menu ===============================================
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
CLEAR BUFFER
TTITLE OFF
CLEAR SCREEN
SET LINESIZE 140
SET PAGESIZE 100

ACCEPT currentyear DATE FORMAT 'YYYY'-
PROMPT 'Enter current year (YYYY): '

CLEAR SCREEN

CREATE OR REPLACE VIEW currentYear_RestCity AS
SELECT DISTINCT(R.rest_city)
FROM DIM_Restaurant R, Sales_Fact S
WHERE S.date_key IN (SELECT date_key FROM Dim_Date WHERE cal_Year = '&currentyear') AND R.restaurant_key = R.restaurant_key
ORDER BY R.rest_city;

CREATE OR REPLACE VIEW previousYear_RestCity AS
SELECT DISTINCT(R.rest_city)
FROM DIM_Restaurant R, Sales_Fact S
WHERE S.date_key IN (SELECT date_key FROM Dim_Date WHERE cal_Year = ('&currentyear'-'1')) AND R.restaurant_key = R.restaurant_key
ORDER BY R.rest_city;

SELECT A.rest_city AS "City"
FROM currentYear_RestCity A INNER JOIN previousYear_RestCity B ON A.rest_city = B.rest_city;

ACCEPT city CHAR FORMAT A30-
PROMPT 'Select a city: '

CLEAR SCREEN

SELECT DISTINCT(R.rest_ID) AS "Restaurant ID", R.rest_name AS "Restaurant Name"
FROM DIM_Restaurant R, Sales_Fact S
WHERE S.date_key IN (SELECT date_key FROM Dim_Date WHERE cal_Year = '&currentyear') 
      AND R.rest_city = UPPER('&city') 
      AND R.restaurant_key = S.restaurant_key
ORDER BY R.rest_ID;

ACCEPT restaurant_id_input NUMBER FORMAT 99999-
PROMPT 'Enter restaurant ID to select: '

CLEAR SCREEN

CREATE OR REPLACE VIEW currentYear_Total AS
SELECT DISTINCT(M.menulistID), M.menuName, M.categoryName, SUM(S.LineTotal) AS totalCurrent
FROM Sales_Fact S, DIM_menulist M
WHERE S.date_key IN (SELECT date_key FROM Dim_Date WHERE cal_Year = '&currentyear')
      AND S.restaurant_key IN (SELECT restaurant_key FROM DIM_Restaurant WHERE rest_ID = '&restaurant_id_input')
      AND S.menulist_key IN (SELECT menulist_key FROM DIM_menulist)
      AND S.menulist_key = M.menulist_key
GROUP BY M.menulistID, M.menuName, M.categoryName;

CREATE OR REPLACE VIEW previousYear_Total AS
SELECT DISTINCT(M.menulistID), M.menuName, M.categoryName, SUM(S.LineTotal) AS totalPrevious
FROM Sales_Fact S, DIM_menulist M
WHERE S.date_key IN (SELECT date_key FROM Dim_Date WHERE cal_Year = ('&currentyear'-'1'))
      AND S.restaurant_key IN (SELECT restaurant_key FROM DIM_Restaurant WHERE rest_ID = '&restaurant_id_input')
      AND S.menulist_key IN (SELECT menulist_key FROM DIM_menulist)
      AND S.menulist_key = M.menulist_key
GROUP BY M.menulistID, M.menuName, M.categoryName;

CREATE OR REPLACE VIEW q4e AS
SELECT A.menulistID, A.menuName, A.categoryName, A.totalCurrent, B.totalPrevious, (A.totalCurrent - B.totalPrevious) AS Difference, (((A.totalCurrent - B.totalPrevious)/(B.totalPrevious))*100) AS Growth_Rate_P
FROM currentYear_Total A INNER JOIN previousYear_Total B ON A.menulistID = B.menulistID;

CLEAR SCREEN

COLUMN current_year HEADING "Current Year(RM)" FORMAT 9,999,999,990.90
COLUMN previous_year HEADING "Previous Year(RM)" FORMAT 9,999,999,990.90
COLUMN grwoth_rate HEADING "Growth(%)" FORMAT 990.90
COLUMN categoryName HEADING "Category" FORMAT A10
COLUMN menuName HEADING "Menu Name" FORMAT A40
COLUMN menulistID HEADING "Menu ID" FORMAT 99999
COLUMN Sales_Performance_Status HEADING "Performance Status" FORMAT A30

TTITLE CENTER '===================================================================================' SKIP 1 -
CENTER 'Menu Sales Comparison of Restaurant '&restaurant_id_input'('&city') of Year '&currentyear' and Previous Year' SKIP 1 -
CENTER '===================================================================================' -
RIGHT 'Page: ' FORMAT 999 SQL.PNO SKIP 2

BREAK ON categoryName SKIP 1;
COMPUTE SUM LABEL 'TOTAL' OF current_year ON categoryName;
COMPUTE SUM LABEL 'TOTAL' OF previous_year ON categoryName;
COMPUTE SUM LABEL 'TOTAL' OF grwoth_rate ON categoryName;

SELECT categoryName, menulistID, menuName,
       totalCurrent AS current_year, totalPrevious AS previous_year, 
       Growth_Rate_P AS grwoth_rate,
       CASE
           WHEN Growth_Rate_P < 0 THEN 'Decrease'
           WHEN Growth_Rate_P > 0 THEN 'Increase'
           ELSE 'No Change'
       END Sales_Performance_Status
FROM q4e
ORDER BY categoryName ASC;