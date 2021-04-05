--C:\Users\User\Documents\GitHub\DWT-Assignment\Analysis(lyw).sql
-- CLEAR COLUMNS
-- CLEAR BREAKS
-- CLEAR COMPUTES
-- TTITLE OFF
-- ACCEPT v1_top_n NUMBER FORMAT '99'-
-- PROMPT 'Enter top N record :'
-- ACCEPT v1_cal_Year DATE FORMAT 'YYYY'-
-- PROMPT 'Enter the year :'
-- ACCEPT v1_rest_city CHAR FORMAT A20-
-- PROMPT 'Enter the restaurant city :'
-- TTITLE CENTER ' Top '&v1_top_n' '&v1_rest_city' order Sales Analysis In Year '&v1_cal_Year''skip 2 -
-- RIGHT 'Page:' FORMAT 99 SQL.PNO CENTER ============================================================================ skip 2 -
  

-- BREAK ON rest_city ON cal_Year ON orderID
-- COLUMN rest_city Heading "rest_city" FORMAT A15
-- COLUMN cal_Year Heading "cal_Year"
-- COLUMN quantity Heading "Quantity"
-- COLUMN orderID Heading "orderID"
-- COLUMN Sales Heading "Sales" FORMAT $999,999,999.99
-- COLUMN Contri_current_city(%) FORMAT 99.9999999
-- COLUMN Contri_all_City(%) FORMAT 999.999999
-- COLUMN totalCityYear_Sales Heading "TotalCityYear_Sales" FORMAT $999,999,999.99
-- COLUMN totalYear_Sales Heading "TotalYear_Sales" FORMAT $999,999,999.99
-- SET linesize 180
-- SET pagesize 100

-- CREATE OR REPLACE VIEW TOP_N AS
-- SELECT *
-- FROM(SELECT A.cal_Year,
-- B.rest_city,
-- D.orderID,
-- SUM(D.quantity) AS quantity,
-- SUM(amount) AS sales
-- FROM dim_date A,DIM_Restaurant B,sales_fact D
-- WHERE A.date_key = D.date_key AND
-- B.restaurant_key = D.restaurant_key
-- GROUP BY B.rest_city, A.cal_Year, D.orderID
-- ORDER BY sales DESC)
-- WHERE cal_Year = &v1_cal_Year AND
-- rest_city = UPPER('&v1_rest_city') AND
-- ROWNUM <= &v1_top_n;

-- CREATE OR REPLACE VIEW totalCityYearSales AS
-- select * from(
-- select sum(amount) AS totalCityYear_Sales
-- from sales_fact SF,dim_date D ,DIM_Restaurant R
-- where D.date_key = SF.date_key and
-- SF.restaurant_key = R.restaurant_key
-- and R.rest_city = UPPER('&v1_rest_city') and
-- D.cal_Year = &v1_cal_Year) WHERE
-- ROWNUM <= &v1_top_n;

-- CREATE OR REPLACE VIEW totalYearSales AS
-- select * from(
-- select sum(amount) AS totalYear_Sales
-- from sales_fact SF,dim_date D
-- where D.date_key = SF.date_key and
-- D.cal_Year = &v1_cal_Year) WHERE
-- ROWNUM <= &v1_top_n;

-- SELECT A.*,
-- C.totalCityYear_Sales,B.totalYear_Sales,
-- A.sales/C.totalCityYear_Sales*100 AS "Contri_current_city(%)",
-- A.sales/B.totalYear_Sales*100 AS "Contri_all_City(%)"
-- FROM TOP_N A, totalYearSales B, totalCityYearSales C;

--=============================================================================================

-- CLEAR COLUMNS
-- CLEAR BREAKS
-- CLEAR COMPUTES
-- TTITLE OFF

-- ACCEPT v1_cal_Year DATE FORMAT 'YYYY'-
-- PROMPT 'Enter the year :'
-- ACCEPT v1_rest_state CHAR FORMAT A15-
-- PROMPT 'Enter the restaurant state:'
-- TTITLE left '                                                  Branch Monthly Sales Analysis In Year '&v1_cal_Year' In '&v1_rest_state''skip 2 -
-- RIGHT 'Page:' FORMAT 99 SQL.PNO left '                                           ============================================================================'skip 2 -
  

-- BREAK ON cal_Year ON rest_state ON rest_branchID
-- COLUMN rest_state  Heading "rest_state " FORMAT A15
-- COLUMN cal_Year Heading "Year"
-- column CALMONTH_NUMYEAR Heading "Month"
-- COLUMN rest_branchID Heading "Restaurant Branch ID"
-- column TotalMonthlyBranch_Sales Heading "Total_Monthly_Branch_Sales" FORMAT $999,999,999.99
-- COLUMN Monthly_sales Heading "Monthly Order Sales"  FORMAT $999,999,999.99
-- COLUMN Growth(%) FORMAT 99999.9999999
-- COLUMN branch(%) FORMAT 999.9999999
-- COLUMN state(%) FORMAT 999.9999999
-- COLUMN year(%) FORMAT 999.9999999
-- SET linesize 200
-- SET pagesize 100

-- CREATE OR REPLACE VIEW MonthlySales AS
-- SELECT *
-- FROM(SELECT B.cal_Year,
-- A.rest_branchID,
-- B.CALMONTH_NUMYEAR,
-- SUM(amount) AS Monthly_sales
-- FROM DIM_Restaurant A, dim_date B,sales_fact C
-- WHERE A.restaurant_key = C.restaurant_key AND
-- B.date_key = C.date_key AND
-- A.rest_state = upper('&v1_rest_state')
-- GROUP BY A.rest_branchID, B.cal_Year, B.CALMONTH_NUMYEAR
-- ORDER BY A.rest_branchID)
-- WHERE cal_Year = '&v1_cal_Year';

-- CREATE OR REPLACE VIEW YearSales AS
-- select cal_year ,Year_Sales
-- from(
-- select D.cal_year,sum(amount) AS Year_Sales
-- from sales_fact SF,dim_date D
-- where D.date_key = SF.date_key AND D.cal_Year = '&v1_cal_Year'
-- GROUP by D.cal_Year);

-- CREATE OR REPLACE VIEW MonthlyBranchSales AS
-- select sum(Monthly_sales) AS MonthlyBranch_Sales
-- from MonthlySales;

-- CREATE OR REPLACE VIEW TotalMonthlyBranchSales AS
-- select rest_branchID,TotalMonthlyBranch_Sales
-- from(
-- select B.cal_Year, C.rest_branchID,
-- sum(amount) AS TotalMonthlyBranch_Sales
-- from sales_fact A, dim_date B, DIM_Restaurant C
-- where A.restaurant_key = C.restaurant_key and 
--       B.date_key = A.date_key and 
--       C.rest_branchID IN (select rest_branchID from MonthlySales)
--       group by C.rest_branchID,B.cal_Year )
-- where cal_Year = '&v1_cal_year';

-- SELECT A.*,TotalMonthlyBranch_Sales,
-- (monthly_sales - LAG(monthly_sales,1) OVER(ORDER BY
-- A.cal_Year))*100/ LAG(monthly_sales,1) OVER(ORDER BY
-- A.cal_Year) AS "Growth(%)",
-- A.monthly_sales/B.MonthlyBranch_sales*100 AS "ALL Branch(%)",
-- A.monthly_sales/C.year_sales*100 AS "Year(%)",
-- A.monthly_sales/D.TotalMonthlyBranch_Sales*100 AS "Current Branch(%)"
-- FROM MonthlySales A, MonthlyBranchSales B, YearSales C,TotalMonthlyBranchSales D
-- WHERE A.cal_year = C.cal_year AND A.REST_BRANCHID = D.REST_BRANCHID
-- ORDER BY A.cal_year;

--========================================================================================

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
TTITLE OFF
ACCEPT v1_cal_year DATE FORMAT 'YYYY'-
PROMPT 'Enter the start year:'
ACCEPT v2_cal_year DATE FORMAT 'YYYY'-
PROMPT 'Enter the end year :'
COLUMN Sales Heading "Sales" FORMAT $999,999,999.99
COLUMN cal_year Heading "Year"
COLUMN quarter Heading "Quarter" FORMAT A10
COLUMN quarter_rank Heading "Quarter Rank"
COLUMN year_rank Heading "Year Rank"
SET linesize 80
SET pagesize 100
TTITLE LEFT '    Quarter And Annual Sales Report Between Year '&v1_cal_year' And Year '&v2_cal_year''SKIP 1 -
LEFT '  =================================================================== 'SKIP 2 RIGHT 'Page:' FORMAT 99 SQL.PNO SKIP 2

BREAK ON year_rank ON cal_year SKIP 1
COMPUTE SUM LABEL TOTAL OF sales ON cal_year SKIP 2

CREATE OR REPLACE VIEW RankView AS
SELECT *
FROM(SELECT A.cal_Year,
A.cal_quarter AS quarter,
SUM(amount) AS sales
FROM dim_date A, sales_fact B
WHERE A.date_key = B.date_key
GROUP BY A.cal_Year,A.cal_quarter
ORDER BY 1,2)
WHERE cal_Year BETWEEN '&v1_cal_Year' AND '&v2_cal_Year';

CREATE OR REPLACE VIEW TotalQuaSales AS
SELECT cal_Year,
TotalQua_Sales
FROM(SELECT A.cal_Year,
SUM(amount) AS TotalQua_Sales
FROM dim_date A, sales_fact B
WHERE A.date_key = B.date_key AND
A.cal_Year BETWEEN '&v1_cal_Year' AND '&v2_cal_Year'
GROUP BY A.cal_Year
ORDER BY A.cal_Year);

SELECT A.*,
RANK() OVER (PARTITION BY A.cal_year ORDER BY A.Sales DESC) AS
quarter_rank,
DENSE_RANK() OVER (ORDER BY B.TotalQua_Sales DESC) AS year_rank
FROM RankView A, TotalQuaSales B
WHERE A.cal_year = B.cal_year
ORDER BY A.cal_year;