CREATE DATABASE Project

USE Project


--טבלת מדינות, מכילה את מזהה המדינה, שמה והמטבע שלה
--קשרים: 
-- קשר 1-ל-רבים מול Central_Banks (לכל מדינה יכול להיות בנק מרכזי אחד או יותר).
--קשר 1-ל-רבים מול Inflation_Data (לכל מדינה סדרת נתוני אינפלציה).
--קשר 1-ל-רבים מול Economic_Events עבור אירועים מקומיים (אירועים גלובליים מסומנים עם country_id = NULL).

Create table Countries
(country_id INT IDENTITY (1,1) CONSTRAINT country_id_pk PRIMARY KEY,
country_name VARCHAR(20) NOT NULL UNIQUE,
currency VARCHAR(3) NOT NULL)


--טבלת בנקים מרכזיים המקשרת כל בנק למדינה בה הוא פועל. לכל בנק יש מזהה, שם ואת המדינה בה פועל מטבלת המדינות
--קשרים:
--קשר רבים-ל-אחד מול Countries באמצעות country_id.
--קשר 1-ל-רבים מול Interest_Rates (לכל בנק מרכזי סדרת פרסומי ריבית).

CREATE table Central_Banks
(bank_id INT IDENTITY (1,1) CONSTRAINT bank_id_pk PRIMARY KEY,
country_id INT NOT NULL CONSTRAINT bank_country_id_fk FOREIGN KEY REFERENCES Countries(country_id),
bank_name VARCHAR(50) NOT NULL)


-- טבלת שיעורי ריבית מדיניות שפורסמו ע״י בנקים מרכזיים בתקופה 01/2023–12/2024.
-- כל רשומה מייצגת תאריך פרסום ושיעור ריבית (ייתכנו חודשים ללא שינוי).
--קשרים:
--קשר רבים-ל-אחד מול Central_Banks באמצעות bank_id.

CREATE table Interest_Rates
(interest_id INT IDENTITY (1,1) CONSTRAINT interest_id_pk PRIMARY KEY,
bank_id INT CONSTRAINT rate_bank_id_fk FOREIGN KEY REFERENCES Central_Banks(bank_id),
rate_date DATE NOT NULL,
interest_rate DECIMAL(5,2) NOT NULL)


--טבלת שיעורי אינפלציה למדינה בתאריכי פרסום בתקופה 01/2023–12/2024. 
--הנתונים מייצגים שינוי חודשי באחוזים בהתאם לערכים המוזנים.
--קשרים:
--קשר רבים-ל-אחד מול Countries באמצעות country_id.

CREATE table Inflation_Data
(inflation_id INT IDENTITY (1,1) CONSTRAINT inflation_id_pk PRIMARY KEY,
country_id INT NOT NULL CONSTRAINT inflation_country_id_fk FOREIGN KEY REFERENCES Countries(country_id),
inflation_date DATE NOT NULL,
inflation_rate DECIMAL(5,2) NOT NULL)


--טבלת אירועים משמעותיים התורמים לניתוח שינויים במדדים (אינפלציה/ריבית) בתקופה הנבדקת. כוללת את סוג האירוע, תאריך ותיאור.
--קשרים:
--קשר רבים-ל-אחד מול Countries עבור אירועים מקומיים.
--אירועים גלובליים נשמרים עם country_id = NULL, ומאפשרים הצמדה לניתוח של כל המדינות לפי חודש/שנה.

CREATE table Economic_Events
--טבלת אירועים משמעותיים הכוללת את קוד האירוע, קוד המדינה בה האירוע התקיים, תאריך האירוע,תיאור האירוע וסוג
(event_id INT IDENTITY (1,1) CONSTRAINT event_id_pk PRIMARY KEY,
country_id INT NULL CONSTRAINT event_country_id_fk FOREIGN KEY REFERENCES Countries(country_id),
event_date DATE NOT NULL,
event_description VARCHAR (200) NOT NULL,
event_type VARCHAR(200) NOT NULL)

INSERT INTO Countries (country_name,currency)
VALUES ('Israel', 'ILS'),
       ('USA', 'USD')

INSERT INTO Central_Banks (country_id,bank_name)
VALUES (1,'Bank of Israel'),
       (2,'Federal Reserve System')

INSERT INTO Interest_Rates (bank_id,rate_date,interest_rate)
VALUES (1,'2023-01-02',3.75),
       (1,'2023-02-20',4.25),
       (1,'2023-04-03',4.5),
       (1,'2023-05-22',4.75),
       (1,'2023-07-10',4.75),
       (1,'2023-09-04',4.75),
       (1,'2023-10-23',4.75),
       (1,'2023-11-27',4.75),
       (1,'2024-01-01',4.5),
       (1,'2024-02-26',4.5),
       (1,'2024-05-28',4.5),
       (1,'2024-06-27',4.5),
       (1,'2024-07-08',4.5),
       (1,'2024-08-28',4.5),
       (1,'2024-10-09',4.5),
       (1,'2024-11-25',4.5)
       
 INSERT INTO Interest_Rates (bank_id,rate_date,interest_rate)
VALUES (2,'2023-02-01',4.75),
       (2,'2023-03-22',5),
       (2,'2023-05-03',5.25),
       (2,'2023-06-14',5.25),
       (2,'2023-07-26',5.5),
       (2,'2023-09-20',5.5),
       (2,'2023-11-01',5.5),
       (2,'2023-12-13',5.5),
       (2,'2024-01-31',5.5),
       (2,'2024-03-20',5.5),
       (2,'2024-05-01',5.5),
       (2,'2024-06-12',5.5),
       (2,'2024-07-31',5.5),
       (2,'2024-09-18',5),
       (2,'2024-11-07',4.75),
       (2,'2024-12-18',4.5)      

INSERT INTO Inflation_Data (country_id,inflation_date, inflation_rate)
VALUES (1,'2023-01-15',0.3),
       (1,'2023-02-15',0.3),
       (1,'2023-03-15',0.5),
       (1,'2023-04-14',0.4),
       (1,'2023-05-15',0.8),
       (1,'2023-06-15',0.2),
       (1,'2023-07-14',0),
       (1,'2023-08-15',0.3),
       (1,'2023-09-15',0.5),
       (1,'2023-10-15',-0.1),
       (1,'2023-11-15',0.5),
       (1,'2023-12-15',-0.3),
       (1,'2024-01-15',-0.1),
       (1,'2024-02-15',0),
       (1,'2024-03-15',0.4),
       (1,'2024-04-15',0.6),
       (1,'2024-05-15',0.8),
       (1,'2024-06-14',0.2),
       (1,'2024-07-15',0.1),
       (1,'2024-08-15',0.6),
       (1,'2024-09-15',0.9),
       (1,'2024-10-15',-0.2),
       (1,'2024-11-15',0.5),
       (1,'2024-12-15',-0.4),
       (2,'2023-01-12',-0.1),
       (2,'2023-02-14',0.5),
       (2,'2023-03-14',0.4),
       (2,'2023-04-12',0.1),
       (2,'2023-05-10',0.4),
       (2,'2023-06-13',0.1),
       (2,'2023-07-12',0.2),
       (2,'2023-08-10',0.2),
       (2,'2023-09-13',0.6),
       (2,'2023-10-12',0.4),
       (2,'2023-11-14',0),
       (2,'2023-12-12',0.1),
       (2,'2024-01-11',0.3),
       (2,'2024-02-13',0.3),
       (2,'2024-03-12',0.4),
       (2,'2024-04-10',0.4),
       (2,'2024-05-15',0.3),
       (2,'2024-06-12',0),
       (2,'2024-07-11',-0.1),
       (2,'2024-08-14',0.2),
       (2,'2024-09-11',0.2),
       (2,'2024-10-10',0.2),
       (2,'2024-11-13',0.2),
       (2,'2024-12-11',0.3)

INSERT INTO Economic_Events (country_id, event_date, event_description, event_type)
VALUES
(NULL, '2023-02-01', 'Residual global supply chain disruptions affecting goods prices', 'Supply Chain'),
(NULL, '2023-06-01', 'Volatility in global energy prices impacting inflation', 'Energy Prices'),
(NULL, '2024-03-01', 'Prolonged period of tight global monetary conditions', 'Global Monetary Policy'),

(2, '2023-03-01', 'Federal Reserve continues interest rate increases', 'Interest Rate Hike'),
(2, '2023-07-01', 'Federal Reserve interest rate reaches peak level', 'Interest Rate Peak'),
(2, '2024-01-01', 'Federal Reserve pauses further rate hikes', 'Monetary Policy Pause'),

(1, '2023-01-01', 'Bank of Israel raises policy interest rate', 'Interest Rate Hike'),
(1, '2023-05-01', 'Elevated inflation levels persist in Israel', 'High Inflation'),
(1, '2023-10-01', 'Outbreak of war and increased domestic economic uncertainty', 'Geopolitical Shock'),
(1, '2024-04-01', 'Gradual moderation of inflation observed in Israel', 'Inflation Moderation');

