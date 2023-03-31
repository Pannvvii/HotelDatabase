DROP VIEW IF EXISTS available_rooms CASCADE;
DROP VIEW IF EXISTS hotel_capacity CASCADE;
DROP TABLE IF EXISTS manager CASCADE;
DROP TABLE IF EXISTS rents CASCADE;
DROP TABLE IF EXISTS works_for CASCADE;
DROP TABLE IF EXISTS employee CASCADE;
DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS archived_room CASCADE;
DROP TABLE IF EXISTS hotel CASCADE;
DROP TABLE IF EXISTS room CASCADE;
DROP TABLE IF EXISTS phone_numbers_chain CASCADE;
DROP TABLE IF EXISTS phone_numbers_hotel CASCADE;
DROP TABLE IF EXISTS hotel_chain;

CREATE TABLE hotel_chain (
	hotel_chainID int,
	chain_name varchar(30) UNIQUE,
	address varchar(30) UNIQUE,
	number_of_hotels int,
	contact_email varchar(50) UNIQUE,
	PRIMARY KEY (hotel_chainID)
);

CREATE TABLE hotel (
	hotelID int,
	hotel_chainID int,
	rating int CHECK (rating < 6 AND rating > 0),
	contact_email varchar(50) UNIQUE,
	address varchar(30) UNIQUE,
	area varchar(20) NOT NULL,
	PRIMARY KEY (hotelID),
	FOREIGN KEY (hotel_chainID)
		REFERENCES hotel_chain(hotel_chainID) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE phone_numbers_chain (
	phone_numberID int,
	phone_number bigint UNIQUE CHECK (10000000000 > phone_number AND phone_number> 1000000000) UNIQUE,
	PRIMARY KEY(phone_number),
	FOREIGN KEY (phone_numberID)
		REFERENCES hotel_chain(hotel_chainID)
			ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE phone_numbers_hotel (
	phone_numberID int,
	phone_number bigint UNIQUE CHECK (10000000000 > phone_number AND phone_number> 1000000000) UNIQUE,
	PRIMARY KEY(phone_number),
	CONSTRAINT fk_phone_numberID
		FOREIGN KEY (phone_numberID)
			REFERENCES hotel(hotelID) ON UPDATE CASCADE ON DELETE CASCADE
);


CREATE TABLE room (
	hotelID int,
	room_number int,
	price money NOT NULL,
	amenities varchar(50),
	capacity int NOT NULL,
	sea_view varchar(5) CHECK (sea_view in ('true','false')) DEFAULT 'false',
	mountain_view varchar(5) CHECK (mountain_view in ('true','false')) DEFAULT 'false',
	FOREIGN KEY (hotelID) REFERENCES hotel(hotelID) ON UPDATE CASCADE ON DELETE CASCADE,
	PRIMARY KEY (hotelID, room_number)
);

CREATE TABLE archived_room (
	hotelID int,
	room_number int,
	price money NOT NULL,
	amenities varchar(50),
	capacity int NOT NULL,
	sea_view varchar(5) CHECK (sea_view in ('true','false')),
	mountain_view varchar(5) CHECK (mountain_view in ('true','false')),
	date_booked date NOT NULL CHECK (date_booked > '2023-01-01'),
	availability varchar(6) CHECK (availability in ('booked','rented')) DEFAULT 'booked',
	FOREIGN KEY (hotelID) REFERENCES hotel(hotelID) ON UPDATE CASCADE ON DELETE CASCADE,
	PRIMARY KEY (hotelID, room_number,date_booked)
);

CREATE TABLE customer (
	SSN_SIN int CHECK (99999999 < SSN_SIN AND  1000000000 > SSN_SIN),
	first_name varchar(30) NOT NULL,
	last_name varchar(30) NOT NULL,
	address varchar(30) NOT NULL,
	PRIMARY KEY (SSN_SIN)
);

CREATE TABLE employee (
	SSN_SIN int CHECK (99999999 < SSN_SIN AND  1000000000 > SSN_SIN),
	address varchar(30) NOT NULL,
	roles_positions varchar(40)NOT NULL,
	first_name varchar(20) NOT NULL,
	last_name varchar(20) NOT NULL,
	PRIMARY KEY (SSN_SIN)
);

CREATE TABLE works_for (
	hotelID int,
	SSN_SIN int CHECK (99999999 < SSN_SIN AND  1000000000 > SSN_SIN),
	CONSTRAINT fk_hotelID
		FOREIGN KEY (hotelID)
			REFERENCES hotel(hotelID) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_SSN_SIN
		FOREIGN KEY (SSN_SIN)
			REFERENCES employee(SSN_SIN) ON UPDATE CASCADE ON DELETE CASCADE,
	PRIMARY KEY(hotelID,SSN_SIN)
);

CREATE TABLE rents (
	SSN_SIN int CHECK (99999999 < SSN_SIN AND  1000000000 > SSN_SIN),
	hotelID int,
	room_number int,
	date_booked date,
	FOREIGN KEY (SSN_SIN) REFERENCES customer(SSN_SIN) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (hotelID) REFERENCES hotel(hotelID) ON UPDATE CASCADE ON DELETE CASCADE,
	UNIQUE(hotelID,room_number,date_booked)
);

CREATE TABLE manager (
	hotelID int,
	manager_SSN int CHECK (99999999 < manager_SSN AND  1000000000 > manager_SSN),
	employee_SSN int CHECK (99999999 < employee_SSN AND  1000000000 > employee_SSN) UNIQUE,
	CONSTRAINT fk_hotelID
		FOREIGN KEY (hotelID)
			REFERENCES hotel(hotelID) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_manager_SSN
		FOREIGN KEY (manager_SSN)
			REFERENCES employee(SSN_SIN) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_employee_SSN
		FOREIGN KEY (employee_SSN)
			REFERENCES employee(SSN_SIN) ON UPDATE CASCADE ON DELETE CASCADE,
	PRIMARY KEY(hotelID,manager_SSN,employee_SSN)
);

 
--Views
DROP VIEW IF EXISTS available_room CASCADE;
DROP VIEW IF EXISTS hotel_capacity CASCADE;
	
CREATE VIEW available_room as
	SELECT hotel.area, COUNT(room.room_number)
		FROM hotel join room on hotel.hotelId = room.hotelId
		WHERE NOT EXISTS(
		SELECT hotel.area, hotel.hotelid, archived_room.room_number
		FROM hotel join archived_room on hotel.hotelId = archived_room.hotelId
		WHERE archived_room.date_booked = current_date AND room.room_number = archived_room.room_number AND room.hotelid = archived_room.hotelid
			)
		GROUP BY hotel.area;

CREATE VIEW hotel_room_capacity as
	SELECT hotel.hotelID, SUM(room.capacity)
	FROM hotel join room on hotel.hotelId = room.hotelId
	GROUP BY hotel.hotelID;

SELECT * FROM available_room;
SELECT * FROM hotel_room_capacity;

--SELECT * FROM hotel join room on hotel.hotelID = room.hotelID join hotel_chain on hotel.hotel_chainID = hotel_chain.hotel_chainID;
SELECT * FROM archived_room;

--Triggers______________________________________________________________________________________

--default current date for archived_room and limit creation of booking a past date
DROP TRIGGER IF EXISTS default_time_archive ON archived_room;
DROP FUNCTION IF EXISTS  set_current_time();

CREATE FUNCTION set_current_time() RETURNS trigger as $$
	BEGIN
		if NEW.date_booked IS NULL THEN
			NEW.date_booked := current_timestamp;
			RETURN NEW;
		ELSIF NEW.date_booked >= current_date THEN
			RETURN NEW;
		END IF;
		RAISE EXCEPTION 'Can not book a room in the past.';
	END;
$$ LANGUAGE plpgsql;

--Quickly add archived_room with no date
--INSERT INTO archived_room(hotelID, room_number, price, amenities, capacity, sea_view,date_booked) VALUES (0,105,57,'tv',3,true,null);


--Increament hotel_chain number on hotel creation
DROP TRIGGER IF EXISTS increment_hotel_chain ON hotel;
DROP FUNCTION IF EXISTS  increment_hotel_chain();

CREATE FUNCTION increment_hotel_chain() RETURNS trigger as $$
	BEGIN
		UPDATE hotel_chain
		SET number_of_hotels = number_of_hotels + 1
		WHERE new.hotel_chainID = hotel_chain.hotel_chainID;
		RETURN NEW;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER increment_hotel_chain after insert on hotel FOR EACH ROW
EXECUTE FUNCTION increment_hotel_chain();

--Decrement hotel_chain number on hotel deletion
DROP TRIGGER IF EXISTS decrement_hotel_chain ON hotel;
DROP FUNCTION IF EXISTS  decrement_hotel_chain();

CREATE FUNCTION decrement_hotel_chain() RETURNS trigger as $$
	BEGIN
		UPDATE hotel_chain
		SET number_of_hotels = number_of_hotels - 1
		WHERE old.hotel_chainID = hotel_chain.hotel_chainID;
		RETURN NEW;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER decrement_hotel_chain after delete on hotel FOR EACH ROW
EXECUTE FUNCTION decrement_hotel_chain();

--Set number of hotel to zero one creation
DROP TRIGGER IF EXISTS set_num_hotel_zero ON hotel_chain;
DROP FUNCTION IF EXISTS set_num_hotel_zero();

CREATE FUNCTION set_num_hotel_zero() RETURNS trigger as $$
	BEGIN
		NEW.number_of_hotels := 0;
		RETURN NEW;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_num_hotel_zero before insert on hotel_chain FOR EACH ROW
EXECUTE FUNCTION set_num_hotel_zero();

--Making sure there is only one manager
DROP TRIGGER IF EXISTS one_manager ON employee;
DROP FUNCTION IF EXISTS one_manager();

CREATE FUNCTION one_manager() RETURNS trigger as $$
	DECLARE
		hotelIDNum int;
		result int;

	BEGIN
		SELECT works_for.hotelID FROM employee natural join works_for WHERE employee.SSN_SIN = new.SSN_SIN into hotelIDNum;
		
		/*SELECT COUNT(roles_positions) 
			FROM (SELECT * FROM employee natural join works_for 
			) as x WHERE (roles_positions = 'manager' AND hotelID = 1)
			GROUP BY roles_positions;*/
		--select * from employee natural join works_for where employee.roles_positions = 'manager';

		SELECT COUNT(roles_positions) 
			FROM (SELECT * FROM employee natural join works_for 
			) as x WHERE (roles_positions = 'manager' AND hotelID = hotelIDNum)
			GROUP BY roles_positions into result;

		IF (result = 1) THEN
			RAISE EXCEPTION 'Can only have one manager per hotel.';
		ELSE
			RETURN NEW;
		END IF;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER one_manager before update on employee FOR EACH ROW
EXECUTE FUNCTION one_manager();

--Set manager
DROP TRIGGER IF EXISTS set_manager ON works_for;
DROP FUNCTION IF EXISTS set_manager();

CREATE FUNCTION set_manager() RETURNS trigger as $$
	BEGIN
		INSERT INTO manager(hotelID, manager_SSN, employee_SSN) VALUES (new.hotelID, 
																		(SELECT SSN_SIN 
																	  	FROM employee natural join works_for
																		WHERE works_for.SSN_SIN=NEW.SSN_SIN),
																		new.SSN_SIN);
		
		UPDATE manager
		SET manager_SSN = (SELECT SSN_SIN 
						   FROM employee natural join works_for natural join 
						   (SELECT works_for.hotelID FROM employee natural join works_for where SSN_SIN=employee.SSN_SIN 
							GROUP BY works_for.hotelID) as x 
						   WHERE employee.roles_positions = 'manager' AND works_for.hotelID = new.hotelID)
		WHERE NEW.hotelID = manager.hotelID;
		
		RETURN NEW;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_manager after insert on works_for FOR EACH ROW
EXECUTE FUNCTION set_manager();

--SELECT * FROM manager;
--SELECT * FROM employee;
--SELECT * FROM employee natural join works_for;
--INSERT INTO employee(SSN_SIN, first_name, last_name, address, roles_positions) VALUES (999284343,'Joe','Biden','White House','something');
--INSERT INTO works_for(hotelID, SSN_SIN) VALUES(1,999284343);

--SELECT SSN_SIN FROM employee natural join works_for natural join (SELECT works_for.hotelID FROM employee natural join works_for where SSN_SIN=9992381) as x WHERE employee.roles_positions = 'manager';
--want manager_SSN from employee

--Stored Procedures___________________________________________________________________________________


DROP FUNCTION IF EXISTS add_works_for(hotelID int, SSN_SIN int);
CREATE FUNCTION add_works_for(hotelID int, SSN_SIN int) RETURNS void LANGUAGE plpgsql as 
$$
declare
	BEGIN
		INSERT INTO works_for(hotelID, SSN_SIN) VALUES(hotelID,SSN_SIN);
	END;
$$;

DROP FUNCTION IF EXISTS add_rents(hotelID int, SSN_SIN int, room_number int, date_booked date);
CREATE FUNCTION add_rents(hotelID int, SSN_SIN int, room_number int, date_booked date) RETURNS void LANGUAGE plpgsql as 
$$
declare
	BEGIN
		INSERT INTO rents(hotelID, SSN_SIN, room_number, date_booked) VALUES(hotelID,SSN_SIN,room_number,date_booked);
	END;
$$;

DROP FUNCTION IF EXISTS add_manager(hotelID int, manager_SIN int, employee_SSN int);
CREATE FUNCTION add_manager(chainID int, SSN_SIN int, employee_SSN int) RETURNS void LANGUAGE plpgsql as 
$$
declare
	BEGIN
		INSERT INTO manager(hotelID, SSN_SIN, employee_SSN) VALUES(hotelID, SSN_SIN, employee_SSN);
	END;
$$;

--Creating indexes
DROP INDEX IF EXISTS room_capacity_index;
DROP INDEX IF EXISTS phone_number_info_chain;
DROP INDEX IF EXISTS phone_number_info_hotel;

CREATE INDEX room_capacity_index ON room(capacity);
CREATE INDEX phone_number_info_chain ON phone_numbers_chain(phone_numberID,phone_number);
CREATE INDEX phone_number_info_hotel ON phone_numbers_hotel(phone_numberID,phone_number);

DROP INDEX IF EXISTS employee_index;
CREATE INDEX employee_index ON employee(first_name,last_name) WHERE roles_positions='manager';

--For unique conditions
DROP INDEX IF EXISTS rents_uni;
CREATE INDEX rents_uni ON rents(SSN_SIN,hotelID,room_number,date_booked);

--hotel chains
INSERT INTO hotel_chain(hotel_chainid, chain_name, address, number_of_hotels, contact_email) VALUES 
(0, 'McDonaldHotel','123 Bank St', 2, 'McDonaldHotel@gmail.com'),
(1, 'SleepWell','126 Bank St', 2, 'SleepWell@gmail.com'),
(2, 'DontSleepAsWell','13 SomewhereElse St', 2, 'DontSleepAsWell@gmail.com'),
(3, 'Uncounscious','86 AlleyWay St', 2, 'Uncounscious@gmail.com'),
(4, 'TimeTravel','967 Wall St', 2, 'TimeTravel@gmail.com'),
(5, 'GoneOneNight','5 Albert St', 2, 'GoneOneNight@gmail.com');

INSERT INTO phone_numbers_chain(phone_numberID, phone_number) VALUES 
(0,6135421244),(1,6135443234),(1,6685421234),(2,6171421234),(3,6135429484),(4,6905421234),(5,6135421237),(5,6135421254);

--hotels
INSERT INTO hotel(hotelID, hotel_chainID, rating, contact_email, address, area) VALUES
(0,0,4,'McDonaldHotel1@gmail.com','547 Lake St','Ottawa'),(1,0,4,'McDonaldHotel2@gmail.com','1 Willow St','Ottawa'),(2,0,1,'McDonaldHotel3@gmail.com','90 Sparrow St','London'),(3,0,2,'McDonaldHotel4@gmail.com','97 Sparrow St','London'),
(4,0,2,'McDonaldHotel5@gmail.com','95 ScareCrow St','London'),(5,0,2,'McDonaldHotel6@gmail.com','95 Leafblower St','London'),(6,0,2,'McDonaldHotel7@gmail.com','12 Lily St','London'),(7,0,1,'McDonaldHotel8@gmail.com','3 CurvyRoad St','London'),
(8,1,5,'SleepWell1@gmail.com','81 Field St','Vancouver'),(9,1,5,'SleepWell2@gmail.com','854 Gravel St','Vancouver'),
(10,1,5,'SleepWell3@gmail.com','8 Down St','London'),(11,1,5,'SleepWell4@gmail.com','7 Up St','Ottawa'),
(12,1,4,'SleepWell5@gmail.com','848 Tilted St','Toronto'),(13,1,1,'SleepWell6@gmail.com','24 Potato St','London'),
(14,1,2,'SleepWell7@gmail.com','90 Somewhere St','London'),(15,1,3,'SleepWell8@gmail.com','4 Carrot St','Toronto'),
(16,2,2,'DontSleepAsWell1@gmail.com','7 Side St','Quebec'),(17,2,1,'DontSleepAsWell2@gmail.com','456 Utah St','Toronto'),
(18,2,2,'DontSleepAsWell3@gmail.com','87 Rectangle St','London'),(19,2,5,'DontSleepAsWell4@gmail.com','2 Waldo St','Toronto'),
(20,2,2,'DontSleepAsWell5@gmail.com','1 Staff St','Vancouver'),(21,2,4,'DontSleepAsWell6@gmail.com','67 Health St','Toronto'),
(22,2,3,'DontSleepAsWell7@gmail.com','92 Care St','Quebec'),(23,2,1,'DontSleepAsWell68@DontSleepAsWell8.com','132 Finish St','London'),
(24,3,2,'Uncounscious1@gmail.com','233 Willow St','London'),(25,3,4,'Uncounscious2@DontSleepAsWell8.com','3 Hallow St','Vancouver'),
(26,3,1,'Uncounscious3@gmail.com','1 Pillow St','Ottawa'),(27,3,1,'Uncounscious4@DontSleepAsWell8.com','54 Fallout St','New York'),
(28,3,5,'Uncounscious5@gmail.com','235 Snow St','Ottawa'),(29,3,5,'Uncounscious6@DontSleepAsWell8.com','94 White St','New York'),
(30,3,4,'Uncounscious7@gmail.com','65 Yellow St','Quebec'),(31,3,2,'Uncounscious8@DontSleepAsWell8.com','45 Black St','London'),
(32,4,3,'TimeTravel1@gmail.com','65 Care St','Quebec'),(33,4,1,'TimeTravel2@DontSleepAsWell8.com','76 Finish St','London'),
(34,4,2,'TimeTravel3@gmail.com','2 Willow St','London'),(35,4,2,'TimeTravel4@DontSleepAsWell8.com','656 Hallow St','Vancouver'),
(36,4,5,'TimeTravel5@gmail.com','432 Pillow St','Ottawa'),(37,4,2,'TimeTravel6@DontSleepAsWell8.com','76 Fallout St','New York'),
(38,4,5,'TimeTravel7@gmail.com','5435 Snow St','Ottawa'),(39,4,1,'TimeTravel8v@DontSleepAsWell8.com','765 White St','New York'),
(40,5,4,'GoneOneNight1@gmail.com','87 Ullah St','Quebec'),(41,5,2,'GoneOneNight2@DontSleepAsWell8.com','14 Sena St','London'),
(42,5,1,'GoneOneNight3@gmail.com','6 Kitone St','Quebec'),(43,5,3,'GoneOneNight4@DontSleepAsWell8.com','87 Dia St','Vancouver'),
(44,5,2,'GoneOneNight5@gmail.com','345 Filla St','London'),(45,5,5,'GoneOneNight6@DontSleepAsWell8.com','654 Pila St','Ottawa'),
(46,5,2,'GoneOneNight7@gmail.com','65 Sparrow St','Quebec'),(47,5,5,'GoneOneNight8@DontSleepAsWell8.com','34 Garbage St','London');

INSERT INTO phone_numbers_hotel(phone_numberID, phone_number) VALUES 
(0,6463377798),(1,6345938965),(2,6065628511),(3,6803714363),(4,6384811626),(5,6157373046),
(6,6705701796),(7,6404412948),(8,6676777075),(9,6797776186),(10,6947164683),(11,6655215136),
(12,6455206049),(13,6727785651),(14,6272874699),(15,6467746614),(16,6953685349),(17,6582191868),
(18,6559134189),(19,6680779671),(20,6629685920),(21,6497973531),(22,6962742295),(23,6902303039),
(24,6477535864),(25,6713181318),(26,6507653692),(27,6621789194),(28,6179393868),(29,6203027145),
(30,6712126491),(31,6680602873),(32,6431012116),(33,6851303489),(34,6578569410),(35,6957565112),
(36,6030481438),(37,6384410340),(38,6031045525),(39,6264081926),(40,6730817789),(41,6821035308),
(42,6121581110),(43,6930458779),(44,6345562572),(45,6686926288),(46,6455532949),(47,6186817290);

--rooms
INSERT INTO room(hotelID, room_number, price, amenities, capacity, sea_view, mountain_view) VALUES
(0,100,77,'tv',3,true,false),(0,101,72,'tv',3,true,false),(0,102,99,'tv',1,true,false),(0,103,103,'tv',1,true,false),
(0,104,70,'tv',2,true,false),(0,105,103,'couch, tv, fridge',5,false,true),(0,106,76,'couch, tv, fridge',5,false,true),
(0,107,68,'couch, tv, fridge',3,false,true),(1,100,64,'tv',6,true,false),(1,101,65,'tv',3,true,false),(1,102,71,'tv',2,true,false),
(1,103,76,'tv',1,true,false),(1,104,109,'tv',4,true,false),(1,105,71,'couch, tv, fridge',6,false,true),(1,106,61,'couch, tv, fridge',1,false,true),
(1,107,63,'couch, tv, fridge',2,false,true),(2,100,72,'tv',6,true,false),(2,101,79,'tv',4,true,false),(2,102,94,'tv',2,true,false),(2,103,97,'tv',3,true,false),
(2,104,68,'tv',2,true,false),(2,105,106,'couch, tv, fridge',3,false,true),(2,106,82,'couch, tv, fridge',3,false,true),(2,107,88,'couch, tv, fridge',6,false,true),
(3,100,77,'tv',4,true,false),(3,101,87,'tv',6,true,false),(3,102,82,'tv',6,true,false),(3,103,107,'tv',6,true,false),(3,104,75,'tv',6,true,false),
(3,105,84,'couch, tv, fridge',5,false,true),(3,106,113,'couch, tv, fridge',3,false,true),(3,107,112,'couch, tv, fridge',5,false,true),
(4,100,82,'tv',1,true,false),(4,101,98,'tv',4,true,false),(4,102,82,'tv',6,true,false),(4,103,67,'tv',3,true,false),(4,104,74,'tv',4,true,false),
(4,105,79,'couch, tv, fridge',2,false,true),(4,106,112,'couch, tv, fridge',4,false,true),(4,107,84,'couch, tv, fridge',6,false,true),(5,100,73,'tv',6,true,false),
(5,101,89,'tv',6,true,false),(5,102,111,'tv',5,true,false),(5,103,94,'tv',1,true,false),(5,104,84,'tv',6,true,false),(5,105,66,'couch, tv, fridge',6,false,true),
(5,106,104,'couch, tv, fridge',4,false,true),(5,107,82,'couch, tv, fridge',3,false,true),(6,100,62,'tv',6,true,false),(6,101,91,'tv',3,true,false),(6,102,64,'tv',5,true,false),
(6,103,80,'tv',2,true,false),(6,104,73,'tv',2,true,false),(6,105,79,'couch, tv, fridge',1,false,true),(6,106,88,'couch, tv, fridge',4,false,true),
(6,107,107,'couch, tv, fridge',5,false,true),(7,100,60,'tv',3,true,false),(7,101,72,'tv',5,true,false),(7,102,101,'tv',4,true,false),(7,103,105,'tv',1,true,false),
(7,104,70,'tv',1,true,false),(7,105,94,'couch, tv, fridge',2,false,true),(7,106,70,'couch, tv, fridge',1,false,true),(7,107,113,'couch, tv, fridge',4,false,true),
(8,100,63,'tv',2,true,false),(8,101,94,'tv',3,true,false),(8,102,86,'tv',3,true,false),(8,103,100,'tv',1,true,false),(8,104,83,'tv',4,true,false),
(8,105,64,'couch, tv, fridge',3,false,true),(8,106,71,'couch, tv, fridge',2,false,true),(8,107,104,'couch, tv, fridge',2,false,true),(9,100,73,'tv',6,true,false),
(9,101,75,'tv',6,true,false),(9,102,60,'tv',6,true,false),(9,103,113,'tv',3,true,false),(9,104,99,'tv',4,true,false),(9,105,103,'couch, tv, fridge',6,false,true),
(9,106,114,'couch, tv, fridge',6,false,true),(9,107,86,'couch, tv, fridge',3,false,true),(10,100,100,'tv',6,true,false),(10,101,88,'tv',5,true,false),
(10,102,99,'tv',2,true,false),(10,103,97,'tv',1,true,false),(10,104,68,'tv',3,true,false),(10,105,111,'couch, tv, fridge',6,false,true),(10,106,78,'couch, tv, fridge',6,false,true),
(10,107,99,'couch, tv, fridge',3,false,true),(11,100,90,'tv',3,true,false),(11,101,102,'tv',6,true,false),(11,102,108,'tv',2,true,false),(11,103,64,'tv',4,true,false),
(11,104,106,'tv',3,true,false),(11,105,77,'couch, tv, fridge',4,false,true),(11,106,111,'couch, tv, fridge',6,false,true),(11,107,74,'couch, tv, fridge',3,false,true),
(12,100,67,'tv',3,true,false),(12,101,101,'tv',4,true,false),(12,102,65,'tv',4,true,false),(12,103,109,'tv',5,true,false),(12,104,62,'tv',2,true,false),
(12,105,92,'couch, tv, fridge',5,false,true),(12,106,110,'couch, tv, fridge',3,false,true),(12,107,80,'couch, tv, fridge',1,false,true),(13,100,72,'tv',4,true,false),
(13,101,101,'tv',3,true,false),(13,102,75,'tv',2,true,false),(13,103,71,'tv',6,true,false),(13,104,113,'tv',4,true,false),(13,105,89,'couch, tv, fridge',5,false,true),
(13,106,71,'couch, tv, fridge',3,false,true),(13,107,70,'couch, tv, fridge',1,false,true),(14,100,99,'tv',1,true,false),(14,101,101,'tv',1,true,false),(14,102,93,'tv',4,true,false),
(14,103,84,'tv',4,true,false),(14,104,90,'tv',6,true,false),(14,105,75,'couch, tv, fridge',3,false,true),(14,106,109,'couch, tv, fridge',4,false,true),
(14,107,100,'couch, tv, fridge',2,false,true),(15,100,76,'tv',3,true,false),(15,101,86,'tv',6,true,false),(15,102,82,'tv',6,true,false),(15,103,84,'tv',1,true,false),
(15,104,111,'tv',6,true,false),(15,105,77,'couch, tv, fridge',3,false,true),(15,106,88,'couch, tv, fridge',6,false,true),(15,107,88,'couch, tv, fridge',6,false,true),
(16,100,74,'tv',3,true,false),(16,101,62,'tv',2,true,false),(16,102,97,'tv',5,true,false),(16,103,97,'tv',2,true,false),(16,104,98,'tv',4,true,false),
(16,105,78,'couch, tv, fridge',4,false,true),(16,106,105,'couch, tv, fridge',2,false,true),(16,107,66,'couch, tv, fridge',2,false,true),(17,100,102,'tv',1,true,false),
(17,101,101,'tv',5,true,false),(17,102,83,'tv',4,true,false),(17,103,97,'tv',2,true,false),(17,104,90,'tv',2,true,false),(17,105,106,'couch, tv, fridge',5,false,true),
(17,106,71,'couch, tv, fridge',2,false,true),(17,107,86,'couch, tv, fridge',3,false,true),(18,100,81,'tv',3,true,false),(18,101,77,'tv',6,true,false),(18,102,74,'tv',5,true,false),
(18,103,83,'tv',2,true,false),(18,104,110,'tv',2,true,false),(18,105,71,'couch, tv, fridge',3,false,true),(18,106,82,'couch, tv, fridge',5,false,true),
(18,107,78,'couch, tv, fridge',1,false,true),(19,100,101,'tv',3,true,false),(19,101,105,'tv',5,true,false),(19,102,101,'tv',4,true,false),(19,103,108,'tv',2,true,false),
(19,104,81,'tv',5,true,false),(19,105,67,'couch, tv, fridge',4,false,true),(19,106,63,'couch, tv, fridge',4,false,true),(19,107,110,'couch, tv, fridge',5,false,true),
(20,100,97,'tv',2,true,false),(20,101,104,'tv',6,true,false),(20,102,110,'tv',5,true,false),(20,103,89,'tv',2,true,false),(20,104,82,'tv',2,true,false),
(20,105,63,'couch, tv, fridge',6,false,true),(20,106,98,'couch, tv, fridge',1,false,true),(20,107,107,'couch, tv, fridge',2,false,true),(21,100,115,'tv',3,true,false),
(21,101,72,'tv',4,true,false),(21,102,95,'tv',1,true,false),(21,103,94,'tv',1,true,false),(21,104,65,'tv',2,true,false),(21,105,95,'couch, tv, fridge',6,false,true),
(21,106,102,'couch, tv, fridge',1,false,true),(21,107,91,'couch, tv, fridge',1,false,true),(22,100,60,'tv',4,true,false),(22,101,63,'tv',5,true,false),(22,102,108,'tv',6,true,false),
(22,103,87,'tv',4,true,false),(22,104,109,'tv',4,true,false),(22,105,80,'couch, tv, fridge',2,false,true),(22,106,63,'couch, tv, fridge',5,false,true),
(22,107,66,'couch, tv, fridge',2,false,true),(23,100,86,'tv',5,true,false),(23,101,115,'tv',3,true,false),(23,102,74,'tv',5,true,false),(23,103,93,'tv',1,true,false),
(23,104,93,'tv',3,true,false),(23,105,86,'couch, tv, fridge',6,false,true),(23,106,103,'couch, tv, fridge',4,false,true),(23,107,103,'couch, tv, fridge',3,false,true),
(24,100,77,'tv',4,true,false),(24,101,105,'tv',3,true,false),(24,102,104,'tv',3,true,false),(24,103,103,'tv',4,true,false),(24,104,62,'tv',5,true,false),
(24,105,87,'couch, tv, fridge',5,false,true),(24,106,113,'couch, tv, fridge',3,false,true),(24,107,94,'couch, tv, fridge',4,false,true),(25,100,100,'tv',3,true,false),
(25,101,83,'tv',3,true,false),(25,102,72,'tv',5,true,false),(25,103,86,'tv',4,true,false),(25,104,108,'tv',6,true,false),(25,105,69,'couch, tv, fridge',3,false,true),
(25,106,106,'couch, tv, fridge',1,false,true),(25,107,103,'couch, tv, fridge',4,false,true),(26,100,101,'tv',2,true,false),(26,101,99,'tv',4,true,false),
(26,102,108,'tv',5,true,false),(26,103,90,'tv',6,true,false),(26,104,79,'tv',4,true,false),(26,105,98,'couch, tv, fridge',1,false,true),(26,106,96,'couch, tv, fridge',5,false,true),
(26,107,93,'couch, tv, fridge',5,false,true),(27,100,103,'tv',4,true,false),(27,101,108,'tv',1,true,false),(27,102,84,'tv',6,true,false),(27,103,102,'tv',1,true,false),
(27,104,67,'tv',1,true,false),(27,105,88,'couch, tv, fridge',4,false,true),(27,106,114,'couch, tv, fridge',4,false,true),(27,107,102,'couch, tv, fridge',1,false,true),
(28,100,114,'tv',2,true,false),(28,101,91,'tv',2,true,false),(28,102,106,'tv',3,true,false),(28,103,77,'tv',4,true,false),(28,104,100,'tv',6,true,false),
(28,105,82,'couch, tv, fridge',4,false,true),(28,106,80,'couch, tv, fridge',3,false,true),(28,107,114,'couch, tv, fridge',2,false,true),(29,100,99,'tv',5,true,false),
(29,101,88,'tv',2,true,false),(29,102,79,'tv',2,true,false),(29,103,108,'tv',2,true,false),(29,104,83,'tv',6,true,false),(29,105,76,'couch, tv, fridge',3,false,true),
(29,106,98,'couch, tv, fridge',5,false,true),(29,107,93,'couch, tv, fridge',3,false,true),(30,100,101,'tv',6,true,false),(30,101,65,'tv',4,true,false),(30,102,85,'tv',3,true,false),
(30,103,79,'tv',6,true,false),(30,104,65,'tv',2,true,false),(30,105,82,'couch, tv, fridge',3,false,true),(30,106,93,'couch, tv, fridge',1,false,true),
(30,107,63,'couch, tv, fridge',1,false,true),(31,100,80,'tv',2,true,false),(31,101,63,'tv',2,true,false),(31,102,113,'tv',4,true,false),(31,103,114,'tv',3,true,false),
(31,104,77,'tv',5,true,false),(31,105,71,'couch, tv, fridge',5,false,true),(31,106,68,'couch, tv, fridge',4,false,true),(31,107,71,'couch, tv, fridge',3,false,true),
(32,100,66,'tv',3,true,false),(32,101,68,'tv',6,true,false),(32,102,96,'tv',2,true,false),(32,103,74,'tv',5,true,false),(32,104,100,'tv',4,true,false),
(32,105,87,'couch, tv, fridge',6,false,true),(32,106,102,'couch, tv, fridge',5,false,true),(32,107,103,'couch, tv, fridge',3,false,true),(33,100,84,'tv',3,true,false),
(33,101,64,'tv',5,true,false),(33,102,60,'tv',5,true,false),(33,103,115,'tv',6,true,false),(33,104,76,'tv',6,true,false),(33,105,105,'couch, tv, fridge',5,false,true),
(33,106,72,'couch, tv, fridge',1,false,true),(33,107,63,'couch, tv, fridge',3,false,true),(34,100,69,'tv',6,true,false),(34,101,68,'tv',6,true,false),(34,102,66,'tv',1,true,false),
(34,103,94,'tv',3,true,false),(34,104,95,'tv',2,true,false),(34,105,79,'couch, tv, fridge',6,false,true),(34,106,108,'couch, tv, fridge',1,false,true),
(34,107,109,'couch, tv, fridge',2,false,true),(35,100,63,'tv',2,true,false),(35,101,99,'tv',3,true,false),(35,102,74,'tv',4,true,false),(35,103,81,'tv',4,true,false),
(35,104,66,'tv',2,true,false),(35,105,107,'couch, tv, fridge',2,false,true),(35,106,78,'couch, tv, fridge',1,false,true),(35,107,82,'couch, tv, fridge',6,false,true),
(36,100,82,'tv',6,true,false),(36,101,109,'tv',3,true,false),(36,102,102,'tv',6,true,false),(36,103,77,'tv',5,true,false),(36,104,82,'tv',4,true,false),
(36,105,93,'couch, tv, fridge',1,false,true),(36,106,87,'couch, tv, fridge',1,false,true),(36,107,100,'couch, tv, fridge',4,false,true),(37,100,103,'tv',2,true,false),
(37,101,82,'tv',4,true,false),(37,102,97,'tv',5,true,false),(37,103,79,'tv',2,true,false),(37,104,94,'tv',2,true,false),(37,105,110,'couch, tv, fridge',4,false,true),
(37,106,88,'couch, tv, fridge',3,false,true),(37,107,103,'couch, tv, fridge',2,false,true),(38,100,82,'tv',3,true,false),(38,101,84,'tv',1,true,false),(38,102,109,'tv',2,true,false),
(38,103,63,'tv',1,true,false),(38,104,92,'tv',1,true,false),(38,105,115,'couch, tv, fridge',5,false,true),(38,106,74,'couch, tv, fridge',5,false,true),
(38,107,73,'couch, tv, fridge',4,false,true),(39,100,114,'tv',4,true,false),(39,101,91,'tv',4,true,false),(39,102,61,'tv',3,true,false),(39,103,80,'tv',2,true,false),
(39,104,65,'tv',4,true,false),(39,105,65,'couch, tv, fridge',5,false,true),(39,106,77,'couch, tv, fridge',1,false,true),(39,107,105,'couch, tv, fridge',1,false,true),
(40,100,84,'tv',6,true,false),(40,101,106,'tv',2,true,false),(40,102,74,'tv',2,true,false),(40,103,91,'tv',3,true,false),(40,104,89,'tv',4,true,false),
(40,105,103,'couch, tv, fridge',4,false,true),(40,106,79,'couch, tv, fridge',6,false,true),(40,107,60,'couch, tv, fridge',3,false,true),(41,100,111,'tv',2,true,false),
(41,101,113,'tv',3,true,false),(41,102,110,'tv',3,true,false),(41,103,72,'tv',1,true,false),(41,104,106,'tv',3,true,false),(41,105,98,'couch, tv, fridge',5,false,true),
(41,106,99,'couch, tv, fridge',5,false,true),(41,107,65,'couch, tv, fridge',5,false,true),(42,100,98,'tv',4,true,false),(42,101,88,'tv',4,true,false),(42,102,66,'tv',1,true,false),
(42,103,96,'tv',5,true,false),(42,104,88,'tv',5,true,false),(42,105,61,'couch, tv, fridge',5,false,true),(42,106,79,'couch, tv, fridge',3,false,true),
(42,107,104,'couch, tv, fridge',1,false,true),(43,100,94,'tv',6,true,false),(43,101,103,'tv',5,true,false),(43,102,110,'tv',3,true,false),(43,103,103,'tv',2,true,false),
(43,104,68,'tv',1,true,false),(43,105,73,'couch, tv, fridge',1,false,true),(43,106,76,'couch, tv, fridge',1,false,true),(43,107,83,'couch, tv, fridge',6,false,true),
(44,100,115,'tv',1,true,false),(44,101,112,'tv',5,true,false),(44,102,66,'tv',3,true,false),(44,103,94,'tv',5,true,false),(44,104,107,'tv',6,true,false),
(44,105,73,'couch, tv, fridge',4,false,true),(44,106,88,'couch, tv, fridge',2,false,true),(44,107,85,'couch, tv, fridge',4,false,true),(45,100,64,'tv',2,true,false),
(45,101,104,'tv',2,true,false),(45,102,70,'tv',1,true,false),(45,103,61,'tv',3,true,false),(45,104,76,'tv',1,true,false),(45,105,114,'couch, tv, fridge',5,false,true),
(45,106,93,'couch, tv, fridge',3,false,true),(45,107,63,'couch, tv, fridge',5,false,true),(46,100,80,'tv',3,true,false),(46,101,72,'tv',2,true,false),(46,102,112,'tv',3,true,false),
(46,103,109,'tv',2,true,false),(46,104,101,'tv',2,true,false),(46,105,89,'couch, tv, fridge',5,false,true),(46,106,82,'couch, tv, fridge',1,false,true),
(46,107,64,'couch, tv, fridge',1,false,true),(47,100,93,'tv',4,true,false),(47,101,84,'tv',4,true,false),(47,102,76,'tv',1,true,false),(47,103,115,'tv',2,true,false),
(47,104,95,'tv',3,true,false),(47,105,71,'couch, tv, fridge',3,false,true),(47,106,98,'couch, tv, fridge',6,false,true),(47,107,102,'couch, tv, fridge',4,false,true);

INSERT INTO archived_room(hotelID, room_number, price, amenities, capacity, sea_view,mountain_view,date_booked) VALUES
(0,100,66,'tv',4,true,false,'2023-10-19'),(0,101,90,'tv',5,true,false,'2023-6-25'),(0,102,75,'tv',2,true,false,'2023-3-27'),(0,105,100,'couch, tv, fridge',4,false,true,'2023-11-27'),
(0,106,100,'couch, tv, fridge',2,false,true,'2023-9-7'),(0,107,108,'couch, tv, fridge',2,false,true,'2023-1-3'),(1,100,61,'tv',5,true,false,'2023-3-28'),
(1,101,111,'tv',6,true,false,'2023-5-25'),(1,102,103,'tv',1,true,false,'2023-4-30'),(1,105,106,'couch, tv, fridge',6,false,true,'2023-10-16'),
(1,106,91,'couch, tv, fridge',6,false,true,'2023-7-2'),(1,107,73,'couch, tv, fridge',2,false,true,'2023-10-11'),(2,100,115,'tv',5,true,false,'2023-7-20'),
(2,101,62,'tv',6,true,false,'2023-7-24'),(2,102,106,'tv',1,true,false,'2023-2-26'),(2,105,88,'couch, tv, fridge',4,false,true,'2023-10-23'),
(2,106,115,'couch, tv, fridge',6,false,true,'2023-10-4'),(2,107,78,'couch, tv, fridge',2,false,true,'2023-10-7'),(3,100,82,'tv',4,true,false,'2023-2-28'),
(3,101,73,'tv',1,true,false,'2023-12-29'),(3,102,91,'tv',4,true,false,'2023-5-12'),(3,105,114,'couch, tv, fridge',5,false,true,'2023-1-4'),
(3,106,77,'couch, tv, fridge',5,false,true,'2023-1-15'),(3,107,79,'couch, tv, fridge',4,false,true,'2023-7-25'),(4,100,82,'tv',1,true,false,'2023-4-23'),
(4,101,103,'tv',4,true,false,'2023-7-7'),(4,102,66,'tv',6,true,false,'2023-6-22'),(4,105,112,'couch, tv, fridge',2,false,true,'2023-4-21'),
(4,106,101,'couch, tv, fridge',4,false,true,'2023-6-12'),(4,107,97,'couch, tv, fridge',5,false,true,'2023-3-11'),(5,100,108,'tv',4,true,false,'2023-7-11'),
(5,101,106,'tv',5,true,false,'2023-2-18'),(5,102,73,'tv',6,true,false,'2023-12-20'),(5,105,93,'couch, tv, fridge',1,false,true,'2023-10-8'),
(5,106,88,'couch, tv, fridge',2,false,true,'2023-6-9'),(5,107,108,'couch, tv, fridge',3,false,true,'2023-5-6'),(6,100,81,'tv',5,true,false,'2023-4-14'),
(6,101,74,'tv',6,true,false,'2023-1-19'),(6,102,78,'tv',4,true,false,'2023-10-29'),(6,105,105,'couch, tv, fridge',5,false,true,'2023-12-28'),
(6,106,109,'couch, tv, fridge',3,false,true,'2023-5-7'),(6,107,68,'couch, tv, fridge',1,false,true,'2023-3-2'),(7,100,82,'tv',3,true,false,'2023-11-29'),
(7,101,115,'tv',4,true,false,'2023-11-5'),(7,102,68,'tv',3,true,false,'2023-2-17'),(7,105,113,'couch, tv, fridge',1,false,true,'2023-10-9'),
(7,106,78,'couch, tv, fridge',6,false,true,'2023-12-4'),(7,107,77,'couch, tv, fridge',1,false,true,'2023-6-16'),(8,100,91,'tv',6,true,false,'2023-6-16'),
(8,101,68,'tv',6,true,false,'2023-1-6'),(8,102,62,'tv',2,true,false,'2023-11-29'),(8,105,103,'couch, tv, fridge',6,false,true,'2023-4-28'),
(8,106,92,'couch, tv, fridge',2,false,true,'2023-8-23'),(8,107,79,'couch, tv, fridge',2,false,true,'2023-10-10'),(9,100,97,'tv',3,true,false,'2023-5-24'),
(9,101,105,'tv',1,true,false,'2023-2-9'),(9,102,113,'tv',1,true,false,'2023-12-8'),(9,105,91,'couch, tv, fridge',3,false,true,'2023-4-18'),
(9,106,111,'couch, tv, fridge',3,false,true,'2023-2-10'),(9,107,110,'couch, tv, fridge',5,false,true,'2023-10-11'),(10,100,97,'tv',5,true,false,'2023-8-12'),
(10,101,109,'tv',1,true,false,'2023-1-18'),(10,102,60,'tv',1,true,false,'2023-6-25'),(10,105,110,'couch, tv, fridge',3,false,true,'2023-9-15'),
(10,106,100,'couch, tv, fridge',6,false,true,'2023-7-10'),(10,107,62,'couch, tv, fridge',5,false,true,'2023-11-26'),(11,100,114,'tv',3,true,false,'2023-11-20'),
(11,101,114,'tv',4,true,false,'2023-6-3'),(11,102,102,'tv',6,true,false,'2023-5-8'),(11,105,60,'couch, tv, fridge',6,false,true,'2023-9-20'),
(11,106,91,'couch, tv, fridge',6,false,true,'2023-3-21'),(11,107,104,'couch, tv, fridge',1,false,true,'2023-3-5'),(12,100,63,'tv',5,true,false,'2023-3-14'),
(12,101,108,'tv',3,true,false,'2023-4-7'),(12,102,109,'tv',6,true,false,'2023-10-19'),(12,105,74,'couch, tv, fridge',1,false,true,'2023-11-30'),
(12,106,78,'couch, tv, fridge',3,false,true,'2023-4-26'),(12,107,74,'couch, tv, fridge',4,false,true,'2023-3-29'),(13,100,64,'tv',3,true,false,'2023-10-6'),
(13,101,86,'tv',3,true,false,'2023-10-5'),(13,102,107,'tv',4,true,false,'2023-4-20'),(13,105,74,'couch, tv, fridge',2,false,true,'2023-3-27'),
(13,106,98,'couch, tv, fridge',6,false,true,'2023-3-29'),(13,107,100,'couch, tv, fridge',2,false,true,'2023-12-9'),(14,100,91,'tv',5,true,false,'2023-3-3'),
(14,101,79,'tv',2,true,false,'2023-6-6'),(14,102,103,'tv',4,true,false,'2023-11-24'),(14,105,60,'couch, tv, fridge',2,false,true,'2023-2-9'),
(14,106,84,'couch, tv, fridge',4,false,true,'2023-9-11'),(14,107,99,'couch, tv, fridge',6,false,true,'2023-1-2'),(15,100,91,'tv',4,true,false,'2023-6-5'),
(15,101,73,'tv',5,true,false,'2023-3-4'),(15,102,60,'tv',6,true,false,'2023-4-24'),(15,105,69,'couch, tv, fridge',2,false,true,'2023-10-6'),
(15,106,85,'couch, tv, fridge',2,false,true,'2023-3-22'),(15,107,98,'couch, tv, fridge',2,false,true,'2023-3-4'),(16,100,70,'tv',1,true,false,'2023-9-16'),
(16,101,76,'tv',4,true,false,'2023-7-9'),(16,102,80,'tv',1,true,false,'2023-3-30'),(16,105,114,'couch, tv, fridge',2,false,true,'2023-9-23'),
(16,106,76,'couch, tv, fridge',2,false,true,'2023-11-30'),(16,107,109,'couch, tv, fridge',2,false,true,'2023-7-13'),(17,100,82,'tv',6,true,false,'2023-10-13'),
(17,101,113,'tv',5,true,false,'2023-5-12'),(17,102,86,'tv',3,true,false,'2023-4-3'),(17,105,63,'couch, tv, fridge',5,false,true,'2023-4-22'),
(17,106,113,'couch, tv, fridge',5,false,true,'2023-2-4'),(17,107,94,'couch, tv, fridge',1,false,true,'2023-6-24'),(18,100,64,'tv',2,true,false,'2023-2-24'),
(18,101,82,'tv',3,true,false,'2023-3-29'),(18,102,103,'tv',2,true,false,'2023-6-11'),(18,105,109,'couch, tv, fridge',2,false,true,'2023-10-9'),
(18,106,102,'couch, tv, fridge',6,false,true,'2023-10-21'),(18,107,113,'couch, tv, fridge',4,false,true,'2023-9-6'),(19,100,111,'tv',3,true,false,'2023-8-25'),
(19,101,101,'tv',4,true,false,'2023-2-27'),(19,102,105,'tv',6,true,false,'2023-10-4'),(19,105,109,'couch, tv, fridge',1,false,true,'2023-3-17'),
(19,106,60,'couch, tv, fridge',4,false,true,'2023-4-25'),(19,107,63,'couch, tv, fridge',3,false,true,'2023-4-17'),(20,100,81,'tv',3,true,false,'2023-3-29'),
(20,101,91,'tv',3,true,false,'2023-8-23'),(20,102,101,'tv',3,true,false,'2023-3-22'),(20,105,109,'couch, tv, fridge',4,false,true,'2023-2-20'),
(20,106,110,'couch, tv, fridge',4,false,true,'2023-5-9'),(20,107,107,'couch, tv, fridge',1,false,true,'2023-10-28'),(21,100,102,'tv',2,true,false,'2023-5-24'),
(21,101,99,'tv',1,true,false,'2023-4-24'),(21,102,66,'tv',1,true,false,'2023-11-30'),(21,105,65,'couch, tv, fridge',3,false,true,'2023-11-5'),
(21,106,81,'couch, tv, fridge',5,false,true,'2023-9-21'),(21,107,99,'couch, tv, fridge',4,false,true,'2023-3-10'),(22,100,79,'tv',1,true,false,'2023-5-26'),
(22,101,93,'tv',3,true,false,'2023-6-17'),(22,102,65,'tv',5,true,false,'2023-11-11'),(22,105,103,'couch, tv, fridge',5,false,true,'2023-7-6'),
(22,106,89,'couch, tv, fridge',4,false,true,'2023-11-12'),(22,107,115,'couch, tv, fridge',4,false,true,'2023-12-25'),(23,100,60,'tv',4,true,false,'2023-5-15'),
(23,101,96,'tv',5,true,false,'2023-12-5'),(23,102,92,'tv',2,true,false,'2023-3-4'),(23,105,113,'couch, tv, fridge',2,false,true,'2023-1-30'),
(23,106,60,'couch, tv, fridge',4,false,true,'2023-9-8'),(23,107,68,'couch, tv, fridge',3,false,true,'2023-9-14'),(24,100,82,'tv',2,true,false,'2023-2-17'),
(24,101,97,'tv',1,true,false,'2023-8-9'),(24,102,86,'tv',2,true,false,'2023-4-20'),(24,105,63,'couch, tv, fridge',5,false,true,'2023-10-21'),
(24,106,72,'couch, tv, fridge',1,false,true,'2023-1-2'),(24,107,82,'couch, tv, fridge',4,false,true,'2023-3-14'),(25,100,86,'tv',1,true,false,'2023-2-19'),
(25,101,85,'tv',6,true,false,'2023-8-18'),(25,102,75,'tv',4,true,false,'2023-2-7'),(25,105,103,'couch, tv, fridge',5,false,true,'2023-11-2'),
(25,106,97,'couch, tv, fridge',5,false,true,'2023-10-8'),(25,107,105,'couch, tv, fridge',4,false,true,'2023-8-17'),(26,100,76,'tv',6,true,false,'2023-9-25'),
(26,101,111,'tv',2,true,false,'2023-1-27'),(26,102,105,'tv',1,true,false,'2023-4-25'),(26,105,76,'couch, tv, fridge',3,false,true,'2023-11-26'),
(26,106,77,'couch, tv, fridge',3,false,true,'2023-7-15'),(26,107,86,'couch, tv, fridge',3,false,true,'2023-8-6'),(27,100,95,'tv',4,true,false,'2023-2-23'),
(27,101,72,'tv',6,true,false,'2023-12-25'),(27,102,115,'tv',4,true,false,'2023-12-3'),(27,105,115,'couch, tv, fridge',4,false,true,'2023-4-26'),
(27,106,93,'couch, tv, fridge',3,false,true,'2023-5-23'),(27,107,111,'couch, tv, fridge',3,false,true,'2023-4-28'),(28,100,93,'tv',3,true,false,'2023-9-14'),
(28,101,92,'tv',2,true,false,'2023-12-16'),(28,102,107,'tv',2,true,false,'2023-7-25'),(28,105,65,'couch, tv, fridge',2,false,true,'2023-1-16'),
(28,106,89,'couch, tv, fridge',4,false,true,'2023-2-9'),(28,107,60,'couch, tv, fridge',5,false,true,'2023-8-26'),(29,100,83,'tv',3,true,false,'2023-10-20'),
(29,101,65,'tv',5,true,false,'2023-8-13'),(29,102,101,'tv',1,true,false,'2023-6-13'),(29,105,90,'couch, tv, fridge',1,false,true,'2023-11-28'),
(29,106,91,'couch, tv, fridge',2,false,true,'2023-11-30'),(29,107,61,'couch, tv, fridge',6,false,true,'2023-12-4'),(30,100,103,'tv',3,true,false,'2023-10-2'),
(30,101,77,'tv',3,true,false,'2023-5-2'),(30,102,68,'tv',5,true,false,'2023-2-19'),(30,105,107,'couch, tv, fridge',5,false,true,'2023-8-14'),
(30,106,82,'couch, tv, fridge',3,false,true,'2023-10-24'),(30,107,95,'couch, tv, fridge',4,false,true,'2023-12-27'),(31,100,90,'tv',5,true,false,'2023-12-26'),
(31,101,90,'tv',2,true,false,'2023-12-17'),(31,102,107,'tv',3,true,false,'2023-1-23'),(31,105,75,'couch, tv, fridge',3,false,true,'2023-10-27'),
(31,106,114,'couch, tv, fridge',2,false,true,'2023-7-24'),(31,107,95,'couch, tv, fridge',6,false,true,'2023-8-3'),(32,100,64,'tv',6,true,false,'2023-9-16'),
(32,101,70,'tv',4,true,false,'2023-2-9'),(32,102,69,'tv',5,true,false,'2023-2-18'),(32,105,99,'couch, tv, fridge',3,false,true,'2023-1-22'),
(32,106,92,'couch, tv, fridge',2,false,true,'2023-8-22'),(32,107,107,'couch, tv, fridge',6,false,true,'2023-7-25'),(33,100,110,'tv',3,true,false,'2023-7-26'),
(33,101,60,'tv',2,true,false,'2023-3-10'),(33,102,102,'tv',3,true,false,'2023-1-29'),(33,105,104,'couch, tv, fridge',3,false,true,'2023-5-3'),
(33,106,66,'couch, tv, fridge',4,false,true,'2023-4-7'),(33,107,97,'couch, tv, fridge',3,false,true,'2023-10-21'),(34,100,95,'tv',2,true,false,'2023-12-25'),
(34,101,86,'tv',1,true,false,'2023-11-11'),(34,102,72,'tv',1,true,false,'2023-6-18'),(34,105,103,'couch, tv, fridge',3,false,true,'2023-6-20'),
(34,106,115,'couch, tv, fridge',4,false,true,'2023-4-6'),(34,107,82,'couch, tv, fridge',4,false,true,'2023-11-24'),(35,100,79,'tv',1,true,false,'2023-10-13'),
(35,101,79,'tv',2,true,false,'2023-1-24'),(35,102,107,'tv',6,true,false,'2023-11-8'),(35,105,101,'couch, tv, fridge',5,false,true,'2023-4-16'),
(35,106,62,'couch, tv, fridge',2,false,true,'2023-6-28'),(35,107,74,'couch, tv, fridge',5,false,true,'2023-7-19'),(36,100,79,'tv',4,true,false,'2023-11-14'),
(36,101,80,'tv',6,true,false,'2023-1-4'),(36,102,112,'tv',2,true,false,'2023-3-16'),(36,105,114,'couch, tv, fridge',6,false,true,'2023-10-22'),
(36,106,70,'couch, tv, fridge',5,false,true,'2023-11-17'),(36,107,98,'couch, tv, fridge',1,false,true,'2023-6-2'),(37,100,82,'tv',1,true,false,'2023-5-26'),
(37,101,66,'tv',3,true,false,'2023-12-29'),(37,102,86,'tv',3,true,false,'2023-8-13'),(37,105,110,'couch, tv, fridge',2,false,true,'2023-1-26'),
(37,106,61,'couch, tv, fridge',6,false,true,'2023-5-10'),(37,107,71,'couch, tv, fridge',3,false,true,'2023-11-14'),(38,100,114,'tv',1,true,false,'2023-9-15'),
(38,101,115,'tv',5,true,false,'2023-11-21'),(38,102,90,'tv',3,true,false,'2023-11-18'),(38,105,87,'couch, tv, fridge',4,false,true,'2023-8-21'),
(38,106,103,'couch, tv, fridge',6,false,true,'2023-3-16'),(38,107,81,'couch, tv, fridge',1,false,true,'2023-9-11'),(39,100,100,'tv',5,true,false,'2023-4-5'),
(39,101,71,'tv',5,true,false,'2023-6-29'),(39,102,104,'tv',4,true,false,'2023-8-15'),(39,105,89,'couch, tv, fridge',4,false,true,'2023-12-10'),
(39,106,98,'couch, tv, fridge',4,false,true,'2023-1-6'),(39,107,103,'couch, tv, fridge',1,false,true,'2023-9-24'),(40,100,108,'tv',6,true,false,'2023-8-10'),
(40,101,93,'tv',1,true,false,'2023-6-25'),(40,102,94,'tv',2,true,false,'2023-7-6'),(40,105,102,'couch, tv, fridge',3,false,true,'2023-3-22'),
(40,106,106,'couch, tv, fridge',4,false,true,'2023-7-4'),(40,107,77,'couch, tv, fridge',2,false,true,'2023-10-6'),(41,100,65,'tv',2,true,false,'2023-9-22'),
(41,101,86,'tv',3,true,false,'2023-7-21'),(41,102,70,'tv',2,true,false,'2023-8-22'),(41,105,82,'couch, tv, fridge',4,false,true,'2023-12-29'),
(41,106,63,'couch, tv, fridge',5,false,true,'2023-3-6'),(41,107,106,'couch, tv, fridge',4,false,true,'2023-12-30'),(42,100,87,'tv',2,true,false,'2023-3-29'),
(42,101,104,'tv',3,true,false,'2023-12-6'),(42,102,63,'tv',3,true,false,'2023-12-5'),(42,105,105,'couch, tv, fridge',2,false,true,'2023-2-4'),
(42,106,76,'couch, tv, fridge',3,false,true,'2023-5-8'),(42,107,84,'couch, tv, fridge',1,false,true,'2023-11-6'),(43,100,67,'tv',3,true,false,'2023-4-23'),
(43,101,60,'tv',1,true,false,'2023-4-24'),(43,102,68,'tv',3,true,false,'2023-12-3'),(43,105,74,'couch, tv, fridge',2,false,true,'2023-4-17'),
(43,106,81,'couch, tv, fridge',1,false,true,'2023-4-9'),(43,107,68,'couch, tv, fridge',4,false,true,'2023-5-15'),(44,100,76,'tv',2,true,false,'2023-9-28'),
(44,101,90,'tv',1,true,false,'2023-8-6'),(44,102,64,'tv',4,true,false,'2023-3-2'),(44,105,114,'couch, tv, fridge',1,false,true,'2023-8-11'),
(44,106,114,'couch, tv, fridge',2,false,true,'2023-5-8'),(44,107,67,'couch, tv, fridge',1,false,true,'2023-1-24'),(45,100,74,'tv',3,true,false,'2023-4-21'),
(45,101,108,'tv',3,true,false,'2023-9-21'),(45,102,98,'tv',6,true,false,'2023-8-8'),(45,105,101,'couch, tv, fridge',3,false,true,'2023-1-26'),
(45,106,86,'couch, tv, fridge',5,false,true,'2023-10-12'),(45,107,114,'couch, tv, fridge',3,false,true,'2023-3-18'),(46,100,74,'tv',6,true,false,'2023-1-11'),
(46,101,63,'tv',4,true,false,'2023-12-23'),(46,102,92,'tv',5,true,false,'2023-12-24'),(46,105,92,'couch, tv, fridge',6,false,true,'2023-7-15'),
(46,106,95,'couch, tv, fridge',5,false,true,'2023-1-15'),(46,107,85,'couch, tv, fridge',2,false,true,'2023-10-18'),(47,100,95,'tv',2,true,false,'2023-1-10'),
(47,101,101,'tv',3,true,false,'2023-11-19'),(47,102,103,'tv',2,true,false,'2023-2-16'),(47,105,93,'couch, tv, fridge',6,false,true,'2023-8-11'),
(47,106,68,'couch, tv, fridge',5,false,true,'2023-10-18'),(47,107,113,'couch, tv, fridge',6,false,true,'2023-8-20');

INSERT INTO customer(SSN_SIN, first_name, last_name, address) VALUES
(899238512,'Barack','Obama','Not the White House'),
(999238443,'Joe','Biden','White House'),
(799238229,'Justin','Trudeau','Parliment'),
(929238916,'John','Doe','Generic St'),
(864176157,'Lisa','Wilson','l91 Back St'),(788398456,'Stephan','Allen','284 Pillow St'),
(973030122,'James','Wilson','294 Sparrow St'),(836546932,'Lisa','Miller','284 Pillow St'),
(964264062,'Stephanie','Johnson','164 Bank St'),(912982591,'Stephanie','Allen','284 Pillow St'),
(748105080,'Janette','Williams','l91 Back St'),(740141012,'Joseph','Anderson','164 Bank St'),
(925848419,'Stephan','Allen','72 Willow St'),(815063382,'Candy','Anderson','164 Bank St'),
(845776721,'George','Brown','72 Willow St'),(899507748,'Britney','Davis','72 Middle'),
(917152035,'Stephanie','Rodriguez','72 Middle'),(955592690,'Stephan','Jackson','164 Bank St'),
(771323095,'Robert','Hernandez','164 Bank St'),(762224917,'Stephanie','Jackson','72 Middle'),
(791084973,'Robert','Green','l91 Back St'),(935414906,'Stephanie','Jackson','72 Willow St'),
(763270575,'Britney','Anderson','284 Pillow St'),(754644685,'Janette','Brown','294 Sparrow St'),
(972023207,'Joseph','Gonzalez','l91 Back St'),(755553682,'Joseph','Martinez','284 Pillow St'),
(969081076,'Sarah','Green','l91 Back St'),(904212934,'George','Lee','72 Middle'),(799327747,'Candy','Baker','72 Middle'),
(855102948,'Sarah','Gonzalez','l91 Back St'),(898877818,'Lisa','Hernandez','164 Bank St'),
(910136179,'Stephanie','Brown','284 Pillow St'),(745842956,'Britney','Baker','l91 Back St'),(910406648,'Britney','Jones','72 Middle');

INSERT INTO employee(SSN_SIN, first_name, last_name, address, roles_positions) VALUES
(999238443,'Joe','Biden','White House','manager'),
(899238512,'Jeremy','Clark','734 Alberto St', 'receptionist'),
(799238229,'Allison','Winnin','32 Creaksdan', 'manager'),
(929238916,'Wings','Johnson','Generic St','butler'),
(895537715,'Lisa','Rodriguez','164 Bank St','cook'),
(878920755,'Janette','Jackson','72 Middle','concierge'),
(908786911,'Stephan','Lopez','72 Middle','cook'),
(721924997,'Stephan','Hernandez','284 Pillow St','concierge'),
(910809216,'Sarah','Williams','284 Pillow St','receptionist'),
(935676859,'Stephanie','Lee','72 Willow St','cook'),
(933372269,'Britney','Robinson','164 Bank St','receptionist'),
(854689858,'Lisa','Rodriguez','294 Sparrow St','butler'),
(749091185,'Allison','Baker','72 Willow St','butler'),
(925206606,'Allison','Hill','72 Middle','receptionist'),
(987025925,'Stephan','Jones','284 Pillow St','parking attendant'),
(926976282,'George','Garcia','72 Willow St','parking attendant'),
(988224006,'Lisa','Hernandez','164 Bank St','receptionist'),
(955553442,'Joseph','Miller','l91 Back St','receptionist'),(792553730,'Candy','Rivera','294 Sparrow St','concierge'),
(887586957,'Stephanie','Jones','164 Bank St','parking attendant'),(983464977,'James','Anderson','l91 Back St','cook'),
(994321602,'Sarah','Robinson','l91 Back St','receptionist'),(737396618,'Lisa','Hernandez','164 Bank St','receptionist'),
(957278855,'Candy','Parker','294 Sparrow St','receptionist'),(759828858,'George','Rivera','72 Middle','cook'),
(789301563,'Stephan','Jackson','l91 Back St','parking attendant'),(861066683,'Joseph','Green','284 Pillow St','parking attendant'),
(985712320,'Sarah','Garcia','72 Middle','cook'),(754732550,'Sarah','Lopez','294 Sparrow St','parking attendant'),
(718803976,'Stephan','Hill','164 Bank St','butler'),(979240711,'Stephan','Anderson','l91 Back St','concierge'),
(731528042,'Stephanie','Wilson','284 Pillow St','butler'),(952897162,'Robert','Brown','l91 Back St','parking attendant'),
(729834239,'Robert','Hernandez','72 Willow St','receptionist'),(764281402,'Stephan','Robinson','294 Sparrow St','receptionist'),
(776423654,'James','Gonzalez','l91 Back St','butler'),(818611796,'Allison','Brown','164 Bank St','receptionist'),
(961316476,'Stephanie','Hill','284 Pillow St','concierge'),(702829085,'Janette','Rivera','284 Pillow St','receptionist'),
(969531086,'Sarah','Rodriguez','164 Bank St','receptionist'),(876589559,'Lisa','Hernandez','72 Willow St','butler'),
(764933040,'Joseph','Hernandez','72 Middle','cook'),(968001228,'Allison','Williams','l91 Back St','receptionist'),
(927092644,'Britney','Rodriguez','294 Sparrow St','cook'),(910816391,'Janette','Garcia','72 Willow St','cook'),
(850130404,'Lisa','Perez','l91 Back St','butler'),(850457356,'Joseph','Allen','72 Middle','butler'),
(866807318,'Stephanie','Rodriguez','l91 Back St','cook'),(919950878,'Stephan','Gonzalez','164 Bank St','concierge'),
(986047467,'Sarah','Anderson','l91 Back St','concierge'),(740286310,'Joseph','Lopez','72 Middle','parking attendant'),
(833356635,'Sarah','Rivera','294 Sparrow St','butler'),(734534031,'Stephan','Hill','294 Sparrow St','parking attendant'),
(904143024,'James','Scott','164 Bank St','parking attendant'),(788447372,'James','Jones','72 Willow St','concierge'),
(879519492,'Candy','Martinez','284 Pillow St','concierge'),(742878455,'Stephanie','Hernandez','294 Sparrow St','parking attendant'),
(765748000,'Allison','Jackson','l91 Back St','parking attendant'),(861526230,'George','Hall','164 Bank St','parking attendant'),
(841498227,'George','Jones','72 Willow St','concierge'),(854405762,'Allison','Jones','284 Pillow St','parking attendant'),
(844852174,'Stephan','Jackson','72 Middle','butler'),(961486320,'Candy','Davis','294 Sparrow St','parking attendant'),
(742045319,'Allison','Brown','72 Willow St','concierge'),(721855745,'Joseph','Green','294 Sparrow St','concierge'),
(769436328,'Candy','Brown','164 Bank St','butler'),(709448457,'James','Parker','164 Bank St','butler'),
(979884919,'Janette','Garcia','284 Pillow St','manager'),(927534768,'Stephanie','Lopez','284 Pillow St','manager'),
(767898227,'George','Brown','72 Willow St','manager'),(955216990,'Allison','Lee','l91 Back St','manager'),
(969413958,'Allison','Lopez','164 Bank St','manager'),(841420540,'Joseph','Garcia','284 Pillow St','manager'),
(956437983,'Lisa','Hill','164 Bank St','manager'),(860042016,'Stephan','Martinez','l91 Back St','manager'),
(825004219,'Lisa','Rodriguez','284 Pillow St','manager'),(961786124,'Allison','Brown','72 Willow St','manager'),
(971794352,'George','Hernandez','72 Willow St','manager'),(759890187,'Candy','Rivera','164 Bank St','manager'),
(841703710,'Lisa','Perez','l91 Back St','manager'),(892531465,'James','Williams','284 Pillow St','manager'),
(701582371,'Janette','Johnson','72 Middle','manager'),(868781632,'Joseph','Baker','284 Pillow St','manager'),
(749527227,'Britney','Martinez','72 Willow St','manager'),(746717576,'George','Allen','l91 Back St','manager'),
(740616454,'Britney','Garcia','164 Bank St','manager'),(897846047,'Lisa','Robinson','72 Willow St','manager'),
(729174389,'Britney','Rodriguez','l91 Back St','manager'),(924507678,'James','Gonzalez','164 Bank St','manager'),
(821246376,'Stephan','Robinson','l91 Back St','manager'),(758615635,'Robert','Hernandez','72 Willow St','manager'),
(864940977,'Joseph','Parker','164 Bank St','manager'),(899845184,'Stephanie','Baker','284 Pillow St','manager'),
(734422633,'Sarah','Allen','72 Middle','manager'),(897894713,'George','Lopez','294 Sparrow St','manager'),
(888343494,'Janette','Allen','284 Pillow St','manager'),(919116053,'George','Wilson','72 Middle','manager'),
(757468580,'Stephanie','Miller','284 Pillow St','manager'),(732891583,'Lisa','Gonzalez','72 Willow St','manager'),
(999135997,'Candy','Parker','294 Sparrow St','manager'),(847946011,'Sarah','Rivera','284 Pillow St','manager'),
(779041851,'Janette','Brown','284 Pillow St','manager'),(837894053,'Stephan','Gonzalez','164 Bank St','manager'),
(786857455,'Joseph','Williams','72 Middle','manager'),(846371639,'Robert','Green','l91 Back St','manager'),
(816474224,'Joseph','Jones','l91 Back St','manager'),(923370270,'Robert','Robinson','72 Willow St','manager'),
(992095383,'Robert','Green','164 Bank St','manager'),(783748644,'Lisa','Smith','l91 Back St','manager'),
(902788540,'Stephan','Baker','284 Pillow St','manager'),(971583770,'Stephan','Green','294 Sparrow St','manager'),
(877825246,'Robert','Miller','72 Willow St','manager'),(803466014,'Candy','Lee','72 Willow St','manager'),
(848812425,'James','Hernandez','294 Sparrow St','manager'),(993846142,'Lisa','Rivera','72 Willow St','manager'),
(863899621,'Robert','Miller','164 Bank St','manager'),(995535538,'Candy','Davis','294 Sparrow St','manager');

INSERT INTO works_for(hotelID, SSN_SIN) VALUES
(0,999238443),
(0,899238512),
(1,799238229),
(1,929238916),
(0,955553442),(1,792553730),(2,887586957),(3,983464977),(4,994321602),
(5,737396618),(6,957278855),(7,759828858),(8,789301563),(9,861066683),
(10,985712320),(11,754732550),(12,718803976),(13,979240711),(14,731528042),
(15,952897162),(16,729834239),(17,764281402),(18,776423654),(19,818611796),
(20,961316476),(21,702829085),(22,969531086),(23,876589559),(24,764933040),
(25,968001228),(26,927092644),(27,910816391),(28,850130404),(29,850457356),
(30,866807318),(31,919950878),(32,986047467),(33,740286310),(34,833356635),
(35,734534031),(36,904143024),(37,788447372),(38,879519492),(39,742878455),
(40,765748000),(41,861526230),(42,841498227),(43,854405762),(44,844852174),
(45,961486320),(46,742045319),(47,721855745),(3,769436328),(3,709448457),
(2,767898227),(3,955216990),(4,969413958),(5,841420540),(6,956437983),(7,860042016),
(8,825004219),(9,961786124),(10,971794352),(11,759890187),(12,841703710),(13,892531465),
(14,701582371),(15,868781632),(16,749527227),(17,746717576),(18,740616454),(19,897846047),
(20,729174389),(21,924507678),(22,821246376),(23,758615635),(24,864940977),(25,899845184),
(26,734422633),(27,897894713),(28,888343494),(29,919116053),(30,757468580),(31,732891583),
(32,999135997),(33,847946011),(34,779041851),(35,837894053),(36,786857455),(37,846371639),
(38,816474224),(39,923370270),(40,992095383),(41,783748644),(42,902788540),(43,971583770),
(44,877825246),(45,803466014),(46,848812425),(47,993846142);

INSERT INTO rents(hotelID, SSN_SIN,room_number,date_booked) VALUES
(0,899238512,104,'2023-03-31'),
(1,999238443,104,'2023-03-31'),
(1,799238229,104,'2023-03-30'),
(1,929238916,104,'2023-03-29'),
(0,755553682,100,'2023-10-19'),(0,763270575,101,'2023-6-25'),(0,754644685,102,'2023-3-27'),(0,748105080,105,'2023-11-27'),
(0,964264062,106,'2023-9-7'),(0,836546932,107,'2023-1-3'),(1,972023207,100,'2023-3-28'),(1,740141012,101,'2023-5-25'),
(1,935414906,102,'2023-4-30'),(1,836546932,105,'2023-10-16'),(1,755553682,106,'2023-7-2'),(1,912982591,107,'2023-10-11'),
(2,904212934,100,'2023-7-20'),(2,791084973,101,'2023-7-24'),(2,745842956,102,'2023-2-26'),(2,740141012,105,'2023-10-23'),
(2,910406648,106,'2023-10-4'),(2,745842956,107,'2023-10-7'),(3,845776721,100,'2023-2-28'),(3,955592690,101,'2023-12-29'),
(3,925848419,102,'2023-5-12'),(3,799327747,105,'2023-1-4'),(3,771323095,106,'2023-1-15'),(3,864176157,107,'2023-7-25'),(4,791084973,100,'2023-4-23'),
(4,925848419,101,'2023-7-7'),(4,755553682,102,'2023-6-22'),(4,898877818,105,'2023-4-21'),(4,748105080,106,'2023-6-12'),(4,917152035,107,'2023-3-11'),
(5,864176157,100,'2023-7-11'),(5,910136179,101,'2023-2-18'),(5,910406648,102,'2023-12-20'),(5,899507748,105,'2023-10-8'),(5,899507748,106,'2023-6-9'),
(5,964264062,107,'2023-5-6'),(6,904212934,100,'2023-4-14'),(6,910406648,101,'2023-1-19'),(6,917152035,102,'2023-10-29'),(6,748105080,105,'2023-12-28'),
(6,771323095,106,'2023-5-7'),(6,972023207,107,'2023-3-2'),(7,845776721,100,'2023-11-29'),(7,836546932,101,'2023-11-5'),(7,799327747,102,'2023-2-17'),
(7,955592690,105,'2023-10-9'),(7,762224917,106,'2023-12-4'),(7,917152035,107,'2023-6-16'),(8,898877818,100,'2023-6-16'),(8,799327747,101,'2023-1-6'),
(8,754644685,102,'2023-11-29'),(8,917152035,105,'2023-4-28'),(8,925848419,106,'2023-8-23'),(8,898877818,107,'2023-10-10'),(9,912982591,100,'2023-5-24'),
(9,788398456,101,'2023-2-9'),(9,815063382,102,'2023-12-8'),(9,748105080,105,'2023-4-18'),(9,898877818,106,'2023-2-10'),(9,955592690,107,'2023-10-11'),
(10,864176157,100,'2023-8-12'),(10,910406648,101,'2023-1-18'),(10,740141012,102,'2023-6-25'),(10,964264062,105,'2023-9-15'),(10,898877818,106,'2023-7-10'),
(10,898877818,107,'2023-11-26'),(11,973030122,100,'2023-11-20'),(11,836546932,101,'2023-6-3'),(11,925848419,102,'2023-5-8'),(11,910406648,105,'2023-9-20'),
(11,788398456,106,'2023-3-21'),(11,904212934,107,'2023-3-5'),(12,855102948,100,'2023-3-14'),(12,791084973,101,'2023-4-7'),(12,836546932,102,'2023-10-19'),
(12,754644685,105,'2023-11-30'),(12,904212934,106,'2023-4-26'),(12,791084973,107,'2023-3-29'),(13,904212934,100,'2023-10-6'),(13,771323095,101,'2023-10-5'),
(13,925848419,102,'2023-4-20'),(13,815063382,105,'2023-3-27'),(13,748105080,106,'2023-3-29'),(13,973030122,107,'2023-12-9'),(14,815063382,100,'2023-3-3'),
(14,763270575,101,'2023-6-6'),(14,864176157,102,'2023-11-24'),(14,973030122,105,'2023-2-9'),(14,748105080,106,'2023-9-11'),(14,910136179,107,'2023-1-2'),
(15,972023207,100,'2023-6-5'),(15,917152035,101,'2023-3-4'),(15,755553682,102,'2023-4-24'),(15,899507748,105,'2023-10-6'),(15,917152035,106,'2023-3-22'),
(15,799327747,107,'2023-3-4'),(16,864176157,100,'2023-9-16'),(16,969081076,101,'2023-7-9'),(16,815063382,102,'2023-3-30'),(16,972023207,105,'2023-9-23'),
(16,791084973,106,'2023-11-30'),(16,845776721,107,'2023-7-13'),(17,748105080,100,'2023-10-13'),(17,973030122,101,'2023-5-12'),(17,899507748,102,'2023-4-3'),
(17,845776721,105,'2023-4-22'),(17,748105080,106,'2023-2-4'),(17,755553682,107,'2023-6-24'),(18,972023207,100,'2023-2-24'),(18,864176157,101,'2023-3-29'),
(18,740141012,102,'2023-6-11'),(18,754644685,105,'2023-10-9'),(18,855102948,106,'2023-10-21'),(18,955592690,107,'2023-9-6'),(19,855102948,100,'2023-8-25'),
(19,904212934,101,'2023-2-27'),(19,955592690,102,'2023-10-4'),(19,898877818,105,'2023-3-17'),(19,910136179,106,'2023-4-25'),(19,762224917,107,'2023-4-17'),
(20,845776721,100,'2023-3-29'),(20,740141012,101,'2023-8-23'),(20,964264062,102,'2023-3-22'),(20,799327747,105,'2023-2-20'),(20,969081076,106,'2023-5-9'),
(20,799327747,107,'2023-10-28'),(21,815063382,100,'2023-5-24'),(21,910406648,101,'2023-4-24'),(21,935414906,102,'2023-11-30'),(21,964264062,105,'2023-11-5'),
(21,964264062,106,'2023-9-21'),(21,910406648,107,'2023-3-10'),(22,788398456,100,'2023-5-26'),(22,771323095,101,'2023-6-17'),(22,788398456,102,'2023-11-11'),
(22,910136179,105,'2023-7-6'),(22,791084973,106,'2023-11-12'),(22,740141012,107,'2023-12-25'),(23,864176157,100,'2023-5-15'),(23,969081076,101,'2023-12-5'),
(23,748105080,102,'2023-3-4'),(23,799327747,105,'2023-1-30'),(23,788398456,106,'2023-9-8'),(23,740141012,107,'2023-9-14'),(24,899507748,100,'2023-2-17'),
(24,969081076,101,'2023-8-9'),(24,754644685,102,'2023-4-20'),(24,899507748,105,'2023-10-21'),(24,972023207,106,'2023-1-2'),(24,762224917,107,'2023-3-14'),
(25,972023207,100,'2023-2-19'),(25,791084973,101,'2023-8-18'),(25,799327747,102,'2023-2-7'),(25,754644685,105,'2023-11-2'),(25,973030122,106,'2023-10-8'),
(25,973030122,107,'2023-8-17'),(26,799327747,100,'2023-9-25'),(26,864176157,101,'2023-1-27'),(26,788398456,102,'2023-4-25'),(26,836546932,105,'2023-11-26'),
(26,972023207,106,'2023-7-15'),(26,964264062,107,'2023-8-6'),(27,740141012,100,'2023-2-23'),(27,910136179,101,'2023-12-25'),(27,935414906,102,'2023-12-3'),
(27,799327747,105,'2023-4-26'),(27,864176157,106,'2023-5-23'),(27,935414906,107,'2023-4-28'),(28,771323095,100,'2023-9-14'),(28,912982591,101,'2023-12-16'),
(28,864176157,102,'2023-7-25'),(28,745842956,105,'2023-1-16'),(28,904212934,106,'2023-2-9'),(28,969081076,107,'2023-8-26'),(29,836546932,100,'2023-10-20'),
(29,836546932,101,'2023-8-13'),(29,935414906,102,'2023-6-13'),(29,973030122,105,'2023-11-28'),(29,910136179,106,'2023-11-30'),(29,964264062,107,'2023-12-4'),
(30,740141012,100,'2023-10-2'),(30,762224917,101,'2023-5-2'),(30,815063382,102,'2023-2-19'),(30,763270575,105,'2023-8-14'),(30,754644685,106,'2023-10-24'),
(30,917152035,107,'2023-12-27'),(31,898877818,100,'2023-12-26'),(31,740141012,101,'2023-12-17'),(31,864176157,102,'2023-1-23'),(31,925848419,105,'2023-10-27'),
(31,755553682,106,'2023-7-24'),(31,762224917,107,'2023-8-3'),(32,855102948,100,'2023-9-16'),(32,972023207,101,'2023-2-9'),(32,855102948,102,'2023-2-18'),
(32,748105080,105,'2023-1-22'),(32,864176157,106,'2023-8-22'),(32,972023207,107,'2023-7-25'),(33,910136179,100,'2023-7-26'),(33,910136179,101,'2023-3-10'),
(33,904212934,102,'2023-1-29'),(33,964264062,105,'2023-5-3'),(33,754644685,106,'2023-4-7'),(33,910136179,107,'2023-10-21'),(34,791084973,100,'2023-12-25'),
(34,762224917,101,'2023-11-11'),(34,740141012,102,'2023-6-18'),(34,910406648,105,'2023-6-20'),(34,973030122,106,'2023-4-6'),(34,791084973,107,'2023-11-24'),
(35,904212934,100,'2023-10-13'),(35,855102948,101,'2023-1-24'),(35,845776721,102,'2023-11-8'),(35,788398456,105,'2023-4-16'),(35,791084973,106,'2023-6-28'),
(35,972023207,107,'2023-7-19'),(36,791084973,100,'2023-11-14'),(36,912982591,101,'2023-1-4'),(36,917152035,102,'2023-3-16'),(36,899507748,105,'2023-10-22'),
(36,763270575,106,'2023-11-17'),(36,836546932,107,'2023-6-2'),(37,845776721,100,'2023-5-26'),(37,912982591,101,'2023-12-29'),(37,935414906,102,'2023-8-13'),
(37,904212934,105,'2023-1-26'),(37,973030122,106,'2023-5-10'),(37,788398456,107,'2023-11-14'),(38,972023207,100,'2023-9-15'),(38,799327747,101,'2023-11-21'),
(38,898877818,102,'2023-11-18'),(38,791084973,105,'2023-8-21'),(38,917152035,106,'2023-3-16'),(38,904212934,107,'2023-9-11'),(39,972023207,100,'2023-4-5'),
(39,935414906,101,'2023-6-29'),(39,845776721,102,'2023-8-15'),(39,925848419,105,'2023-12-10'),(39,925848419,106,'2023-1-6'),(39,763270575,107,'2023-9-24'),
(40,910406648,100,'2023-8-10'),(40,955592690,101,'2023-6-25'),(40,910406648,102,'2023-7-6'),(40,964264062,105,'2023-3-22'),(40,771323095,106,'2023-7-4'),
(40,740141012,107,'2023-10-6'),(41,762224917,100,'2023-9-22'),(41,740141012,101,'2023-7-21'),(41,925848419,102,'2023-8-22'),(41,912982591,105,'2023-12-29'),
(41,763270575,106,'2023-3-6'),(41,815063382,107,'2023-12-30'),(42,799327747,100,'2023-3-29'),(42,771323095,101,'2023-12-6'),(42,815063382,102,'2023-12-5'),
(42,836546932,105,'2023-2-4'),(42,898877818,106,'2023-5-8'),(42,904212934,107,'2023-11-6'),(43,969081076,100,'2023-4-23'),(43,845776721,101,'2023-4-24'),
(43,788398456,102,'2023-12-3'),(43,899507748,105,'2023-4-17'),(43,910406648,106,'2023-4-9'),(43,904212934,107,'2023-5-15'),(44,763270575,100,'2023-9-28'),
(44,955592690,101,'2023-8-6'),(44,899507748,102,'2023-3-2'),(44,864176157,105,'2023-8-11'),(44,969081076,106,'2023-5-8'),(44,917152035,107,'2023-1-24'),
(45,935414906,100,'2023-4-21'),(45,973030122,101,'2023-9-21'),(45,771323095,102,'2023-8-8'),(45,969081076,105,'2023-1-26'),(45,910406648,106,'2023-10-12'),
(45,864176157,107,'2023-3-18'),(46,955592690,100,'2023-1-11'),(46,925848419,101,'2023-12-23'),(46,836546932,102,'2023-12-24'),(46,904212934,105,'2023-7-15'),
(46,899507748,106,'2023-1-15'),(46,771323095,107,'2023-10-18'),(47,763270575,100,'2023-1-10'),(47,745842956,101,'2023-11-19'),(47,910406648,102,'2023-2-16'),
(47,955592690,105,'2023-8-11'),(47,917152035,106,'2023-10-18'),(47,969081076,107,'2023-8-20');

CREATE TRIGGER default_time_archive before insert on archived_room FOR EACH ROW
EXECUTE FUNCTION set_current_time();