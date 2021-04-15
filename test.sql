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

CREATE OR REPLACE VIEW q4a AS
SELECT DISTINCT(R.rest_city)
FROM DIM_Restaurant R, Sales_Fact S
WHERE S.date_key IN (SELECT date_key FROM Dim_Date WHERE cal_Year = '&currentyear') AND R.restaurant_key = R.restaurant_key
ORDER BY R.rest_city;

CREATE OR REPLACE VIEW q4b AS
SELECT DISTINCT(R.rest_city)
FROM DIM_Restaurant R, Sales_Fact S
WHERE S.date_key IN (SELECT date_key FROM Dim_Date WHERE cal_Year = ('&currentyear'-'1')) AND R.restaurant_key = R.restaurant_key
ORDER BY R.rest_city;

SELECT A.rest_city
FROM q4a A INNER JOIN q4b B ON A.rest_city = B.rest_city;

ACCEPT city CHAR FORMAT A30-
PROMPT 'Select city: '

CLEAR SCREEN

SELECT DISTINCT(R.rest_ID), R.rest_name
FROM DIM_Restaurant R, Sales_Fact S
WHERE S.date_key IN (SELECT date_key FROM Dim_Date WHERE cal_Year = '&currentyear') 
      AND R.rest_city = UPPER('&city') 
      AND R.restaurant_key = S.restaurant_key
ORDER BY R.rest_ID;

ACCEPT restaurant_id_input NUMBER FORMAT 99999-
PROMPT 'Enter restaurant ID to select: '

CLEAR SCREEN

-- SELECT DISTINCT(M.categoryID), M.categoryName
-- FROM DIM_menulist M, Sales_Fact S
-- WHERE S.date_key IN (SELECT date_key FROM Dim_Date WHERE cal_Year = '&currentyear')
--       AND S.restaurant_key IN (SELECT restaurant_key FROM DIM_Restaurant WHERE rest_ID = '&restaurant_id_input') 
--       AND M.menulist_key = S.menulist_key
-- ORDER BY M.categoryID;

-- ACCEPT menu_category NUMBER FORMAT 99999-
-- PROMPT 'Enter the categoryID to select: '

-- CLEAR SCREEN

CREATE OR REPLACE VIEW q4c AS
SELECT DISTINCT(M.menulistID), M.menuName, M.categoryName, SUM(S.LineTotal) AS totalCurrent
FROM Sales_Fact S, DIM_menulist M
WHERE S.date_key IN (SELECT date_key FROM Dim_Date WHERE cal_Year = '&currentyear')
      AND S.restaurant_key IN (SELECT restaurant_key FROM DIM_Restaurant WHERE rest_ID = '&restaurant_id_input')
      AND S.menulist_key IN (SELECT menulist_key FROM DIM_menulist)-- WHERE categoryID = '&menu_category')
      AND S.menulist_key = M.menulist_key
GROUP BY M.menulistID, M.menuName, M.categoryName;

CREATE OR REPLACE VIEW q4d AS
SELECT DISTINCT(M.menulistID), M.menuName, M.categoryName, SUM(S.LineTotal) AS totalPrevious
FROM Sales_Fact S, DIM_menulist M
WHERE S.date_key IN (SELECT date_key FROM Dim_Date WHERE cal_Year = ('&currentyear'-'1'))
      AND S.restaurant_key IN (SELECT restaurant_key FROM DIM_Restaurant WHERE rest_ID = '&restaurant_id_input')
      AND S.menulist_key IN (SELECT menulist_key FROM DIM_menulist)-- WHERE categoryID = '&menu_category')
      AND S.menulist_key = M.menulist_key
GROUP BY M.menulistID, M.menuName, M.categoryName;

CREATE OR REPLACE VIEW q4e AS
SELECT A.menulistID, A.menuName, A.categoryName, A.totalCurrent, B.totalPrevious, (A.totalCurrent - B.totalPrevious) AS Difference, (((A.totalCurrent - B.totalPrevious)/(B.totalPrevious))*100) AS Growth_Rate_P
FROM q4c A INNER JOIN q4d B ON A.menulistID = B.menulistID;

COLUMN current_year HEADING "Current Year" FORMAT $9,999,999,990.90
COLUMN previous_year HEADING "Previous Year" FORMAT $9,999,999,990.90
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
ORDER BY categoryName DESC;