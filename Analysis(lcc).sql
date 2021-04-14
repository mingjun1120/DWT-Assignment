SET linesize 115
SET pagesize 240
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
CLEAR BUFFER
TTITLE OFF

ACCEPT yearInput DATE FORMAT 'YYYY'-
PROMPT 'Enter year: '

ACCEPT city CHAR FORMAT A25-
PROMPT 'Select city: '

SELECT DISTINCT(R.rest_city) AS City
FROM DIM_Restaurant R, sales_fact S
WHERE S.date_key IN (SELECT date_key FROM dim_date
                     WHERE cal_Year = '&yearInput'
                    ) AND R.restaurant_key = S.restaurant_key
ORDER BY R.rest_city;
