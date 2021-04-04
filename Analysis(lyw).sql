CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
TTITLE OFF
ACCEPT v1_top_n NUMBER FORMAT '99'-
PROMPT 'Enter top N record :'
ACCEPT v1_cal_Year DATE FORMAT 'YYYY'-
PROMPT 'Enter the year :'
ACCEPT v1_rest_city CHAR FORMAT A20-
PROMPT 'Enter the restaurant city :'
TTITLE CENTER ' Top '&v1_top_n' '&v1_rest_city' order Sales Analysis In Year '&v1_cal_Year''skip 2 -
RIGHT 'Page:' FORMAT 99 SQL.PNO CENTER ============================================================================ skip 2 -
  

BREAK ON rest_city ON cal_Year ON orderID
COLUMN rest_city Heading "rest_city" FORMAT A15
COLUMN cal_Year Heading "cal_Year"
COLUMN quantity Heading "Quantity"
COLUMN orderID Heading "orderID"
COLUMN Sales Heading "Sales" FORMAT $999,999,999.99
COLUMN Contri_current_city(%) FORMAT 99.9999999
COLUMN Contri_all_City(%) FORMAT 999.999999
COLUMN totalCityYear_Sales Heading "TotalCityYear_Sales" FORMAT $999,999,999.99
COLUMN totalYear_Sales Heading "TotalYear_Sales" FORMAT $999,999,999.99
SET linesize 180
SET pagesize 100

CREATE OR REPLACE VIEW TOP_N AS
SELECT *
FROM(SELECT A.cal_Year,
B.rest_city,
D.orderID,
SUM(D.quantity) AS quantity,
SUM(amount) AS sales
FROM dim_date A,DIM_Restaurant B,sales_fact D
WHERE A.date_key = D.date_key AND
B.restaurant_key = D.restaurant_key
GROUP BY B.rest_city, A.cal_Year, D.orderID
ORDER BY sales DESC)
WHERE cal_Year = &v1_cal_Year AND
rest_city = UPPER('&v1_rest_city') AND
ROWNUM <= &v1_top_n;

CREATE OR REPLACE VIEW totalCityYearSales AS
select * from(
select sum(amount) AS totalCityYear_Sales
from sales_fact SF,dim_date D ,DIM_Restaurant R
where D.date_key = SF.date_key and
SF.restaurant_key = R.restaurant_key
and R.rest_city = UPPER('&v1_rest_city') and
D.cal_Year = &v1_cal_Year) WHERE
ROWNUM <= &v1_top_n;

CREATE OR REPLACE VIEW totalYearSales AS
select * from(
select sum(amount) AS totalYear_Sales
from sales_fact SF,dim_date D
where D.date_key = SF.date_key and
D.cal_Year = &v1_cal_Year) WHERE
ROWNUM <= &v1_top_n;

SELECT A.*,
C.totalCityYear_Sales,B.totalYear_Sales,
A.sales/C.totalCityYear_Sales*100 AS "Contri_current_city(%)",
A.sales/B.totalYear_Sales*100 AS "Contri_all_City(%)"
FROM TOP_N A, totalYearSales B, totalCityYearSales C;