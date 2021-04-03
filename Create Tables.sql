/* DROP TABLE SEQUENCE */

/*
 !!!You are advised to run these commented queries first then only continue with uncommented queries!!!
 
DROP TABLE OrderDetails;
DROP TABLE ItemCombo;
DROP TABLE MenuList;
DROP TABLE Orders;
DROP TABLE Branch;
DROP TABLE Restaurant;
DROP TABLE Promotion;
DROP TABLE Food;
DROP TABLE TimeMeal;
DROP TABLE Category;
DROP TABLE Rider;
DROP TABLE RestaurantType;
DROP TABLE Users;

*/

CREATE TABLE Users
(UsersId      VARCHAR(6)  NOT NULL,
 Name         VARCHAR(20) NOT NULL,
 Gender       CHAR(1)     NOT NULL,
 DOB          DATE,
 PhoneNum     VARCHAR(11) NOT NULL,
 Email        VARCHAR(40) NOT NULL,
 StreetName   VARCHAR(40) NOT NULL,
 PostCode     NUMBER(5)   NOT NULL,
 City         VARCHAR(20) NOT NULL,
 State        VARCHAR(15) NOT NULL,
 PRIMARY KEY(UsersId),
 CONSTRAINT chk_users_id CHECK (SUBSTR(UsersId, 1, 1) = 'U'),
 CONSTRAINT chk_gender CHECK (UPPER(gender) IN ('M','F')),
 CONSTRAINT chk_email CHECK (REGEXP_LIKE(email,'^[a-zA-Z]\w+@(\S+)$'))
);

CREATE TABLE RestaurantType
(RestaurantTypeId  VARCHAR(7)    NOT NULL,
 TypeName          VARCHAR(20)   NOT NULL,
 Description       VARCHAR(100)  NOT NULL,
 PRIMARY KEY(RestaurantTypeId),
 CONSTRAINT chk_restaurant_type_id CHECK (SUBSTR(RestaurantTypeId, 1, 2) = 'RT')
);

CREATE TABLE Rider
(RiderId     VARCHAR(6)    NOT NULL,
 Name        VARCHAR(20)   NOT NULL,
 DOB         DATE,
 PhoneNum    VARCHAR(11)   NOT NULL,
 VehicleNo   VARCHAR(7)    NOT NULL,
 VehicleYear NUMBER(4)     NOT NULL,
 LateNo      VARCHAR(7)    NOT NULL,
 Status      VARCHAR(25)   NOT NULL,
 PRIMARY KEY(RiderId),
 CONSTRAINT chk_rider_id CHECK (SUBSTR(RiderId, 1, 1) = 'R')
);

CREATE TABLE Category
(CategoryId  VARCHAR(6)    NOT NULL,
 Name        VARCHAR(20)   NOT NULL,
 Description VARCHAR(100)  NOT NULL,
 PRIMARY KEY(CategoryId),
 CONSTRAINT chk_category_id CHECK (SUBSTR(CategoryId, 1, 1) = 'C')
);

CREATE TABLE TimeMeal
(TimeMealId  VARCHAR(7)    NOT NULL,
 Section     VARCHAR(20)   NOT NULL,
 StartTime   TIMESTAMP     NOT NULL,
 EndTime     TIMESTAMP     NOT NULL,
 PRIMARY KEY(TimeMealId),
 CONSTRAINT chk_time_meal_id CHECK (SUBSTR(TimeMealId, 1, 1) = 'T')
);

CREATE TABLE Food
(FoodId      VARCHAR(6)    NOT NULL,
 Name        VARCHAR(20)   NOT NULL,
 Description VARCHAR(100)  NOT NULL,
 Status      VARCHAR(25)   NOT NULL,
 PRIMARY KEY(FoodId),
 CONSTRAINT chk_food_id CHECK (SUBSTR(FoodId, 1, 1) = 'F')
);

CREATE TABLE Promotion
(PromotionId   VARCHAR(6)   NOT NULL,
 UsersId       VARCHAR(6)   NOT NULL,
 PromoCode     VARCHAR(10)  NOT NULL,
 DiscountRate  NUMBER(2),
 Status        VARCHAR(7)  DEFAULT 'Active' NOT NULL, --Either store 'Active' or 'Claimed' only
 PRIMARY KEY(PromotionId),
 FOREIGN KEY(UsersId) REFERENCES Users(UsersId),
 CONSTRAINTS Promotion_Status CHECK(Status IN ('Active','Claimed'))
);

CREATE TABLE Restaurant
(RestaurantId       VARCHAR(6)  NOT NULL,
 RestaurantTypeId   VARCHAR(6)  NOT NULL,
 Name               VARCHAR(30) NOT NULL,
 Status             VARCHAR(25) NOT NULL,
 PRIMARY KEY(RestaurantId),
 FOREIGN KEY(RestaurantTypeId) REFERENCES RestaurantType(RestaurantTypeId),
 CONSTRAINT chk_restaurant_id CHECK (SUBSTR(RestaurantId, 1, 1) = 'R')
);

CREATE TABLE Branch
(BranchId     VARCHAR(6)  NOT NULL,
 RestaurantId VARCHAR(6)  NOT NULL,
 StreetName   VARCHAR(40) NOT NULL,
 PostCode     NUMBER(5)   NOT NULL,
 City         VARCHAR(15) NOT NULL,
 State        VARCHAR(15) NOT NULL,
 TelNo        NUMBER(11)  NOT NULL,
 Email        VARCHAR(40) NOT NULL,
 Status       VARCHAR(25) NOT NULL,
 PRIMARY KEY(BranchId),
 FOREIGN KEY(RestaurantId) REFERENCES Restaurant(RestaurantId),
 CONSTRAINT chk_branch_id CHECK (SUBSTR(BranchId, 1, 1) = 'B')
);

CREATE TABLE Orders
(OrderId          VARCHAR(6)   NOT NULL,
 UsersId          VARCHAR(6)   NOT NULL,
 BranchId         VARCHAR(6)   NOT NULL,
 RiderId          VARCHAR(6)   NOT NULL,
 PromotionId      VARCHAR(6)   NOT NULL,
 OrderDateTime    TIMESTAMP,
 DispatchDateTime TIMESTAMP,
 PaymentType      VARCHAR(15)  NOT NULL,
 Amount           NUMBER(8,2)  NOT NULL,
 Discount         NUMBER(8,2)  NOT NULL,
 Incentives       NUMBER(5,2)  NOT NULL,
 Rating           NUMBER(2)    NOT NULL,
 Comments         VARCHAR(100) NOT NULL,
 PRIMARY KEY(OrderId),
 FOREIGN KEY(UsersId) REFERENCES Users(UsersId),
 FOREIGN KEY(BranchId) REFERENCES Branch(BranchId),
 FOREIGN KEY(RiderId) REFERENCES Rider(RiderId),
 FOREIGN KEY(PromotionId) REFERENCES Promotion(PromotionId),
 CONSTRAINTS Orders_PaymentType CHECK(PaymentType IN ('Credit Card')),
 CONSTRAINT chk_order_id CHECK (SUBSTR(OrderId, 1, 1) = 'O')
);

CREATE TABLE MenuList
(MenuListId     VARCHAR(6)    NOT NULL,
 RestaurantId   VARCHAR(6)    NOT NULL,
 CategoryId     VARCHAR(6)    NOT NULL,
 TimeMealId     VARCHAR(6)    NOT NULL,
 Name           VARCHAR(30)   NOT NULL,
 Description    VARCHAR(100)  NOT NULL,
 PricePerUnit   NUMBER(5,2)   NOT NULL,
 UnitSold       NUMBER(4)     NOT NULL,
 Status         VARCHAR(25)  NOT NULL,
 PRIMARY KEY(MenuListId),
 FOREIGN KEY(RestaurantId) REFERENCES Restaurant(RestaurantId),
 FOREIGN KEY(CategoryId) REFERENCES Category(CategoryId),
 FOREIGN KEY(TimeMealId) REFERENCES TimeMeal(TimeMealId),
 CONSTRAINT chk_menu_list_id CHECK (SUBSTR(MenuListId, 1, 1) = 'M')
);

CREATE TABLE ItemCombo
(MenuListId     VARCHAR(6)    NOT NULL,
 FoodId         VARCHAR(6)    NOT NULL,
 Quantity       NUMBER(5)     NOT NULL,
 Status         VARCHAR(25)   NOT NULL,
 PRIMARY KEY(MenuListId, FoodId),
 FOREIGN KEY(MenuListId) REFERENCES MenuList(MenuListId),
 FOREIGN KEY(FoodId) REFERENCES Food(FoodId)
);

CREATE TABLE OrderDetails
(OrderId        VARCHAR(6)    NOT NULL,
 MenuListId     VARCHAR(6)    NOT NULL,
 Quantity       NUMBER(5)     NOT NULL,
 PRIMARY KEY(OrderId, MenuListId),
 FOREIGN KEY(OrderId) REFERENCES Orders(OrderId),
 FOREIGN KEY(MenuListId) REFERENCES MenuList(MenuListId)
);