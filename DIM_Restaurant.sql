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
 rst_state          VARCHAR(20)   NOT NULL,
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