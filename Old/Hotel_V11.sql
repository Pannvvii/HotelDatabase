DROP VIEW IF EXISTS available_rooms CASCADE;
DROP VIEW IF EXISTS hotel_capacity CASCADE;
DROP TABLE IF EXISTS manager CASCADE;
DROP TABLE IF EXISTS rents CASCADE;
DROP TABLE IF EXISTS works_for CASCADE;
DROP TABLE IF EXISTS owns CASCADE;
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
	address varchar(30),
	number_of_hotels int,
	contact_email varchar(40),
	PRIMARY KEY (hotel_chainID)
);

CREATE TABLE hotel (
	hotelID int,
	hotel_chainID int,
	rating int CHECK (rating < 6 AND rating > 0),
	contact_email varchar(40),
	address varchar(30) UNIQUE,
	area varchar(20),
	PRIMARY KEY (hotelID),
	FOREIGN KEY (hotel_chainID)
		REFERENCES hotel_chain(hotel_chainID) ON DELETE CASCADE
);

CREATE TABLE phone_numbers_chain (
	phone_numberID int,
	phone_number bigint UNIQUE CHECK (10000000000 > phone_number AND phone_number> 1000000000) UNIQUE,
	PRIMARY KEY(phone_number),
	FOREIGN KEY (phone_numberID)
		REFERENCES hotel_chain(hotel_chainID)
			ON DELETE CASCADE
);

CREATE TABLE phone_numbers_hotel (
	phone_numberID int,
	phone_number bigint UNIQUE CHECK (10000000000 > phone_number AND phone_number> 1000000000) UNIQUE,
	PRIMARY KEY(phone_number),
	CONSTRAINT fk_phone_numberID
		FOREIGN KEY (phone_numberID)
			REFERENCES hotel(hotelID) ON DELETE CASCADE
);


CREATE TABLE room (
	hotelID int,
	room_number int,
	price money,
	amenities varchar(50),
	capacity int,
	sea_view varchar(5) CHECK (sea_view in ('true','false')) DEFAULT 'false',
	mountain_view varchar(5) CHECK (mountain_view in ('true','false')) DEFAULT 'false',
	PRIMARY KEY (hotelID, room_number)
	--FOREIGN KEY (hotelID) REFERENCES hotel(hotelID)
);

CREATE TABLE archived_room (
	hotelID int,
	room_number int,
	price money,
	amenities varchar(50),
	capacity int,
	sea_view varchar(5) CHECK (sea_view in ('true','false')),
	mountain_view varchar(5) CHECK (mountain_view in ('true','false')),
	date_booked date CHECK (date_booked > '2023-01-01'),
	PRIMARY KEY (hotelID, room_number)
	--FOREIGN KEY (hotelID) REFERENCES hotel(hotelID) ON DELETE CASCADE
);

CREATE TABLE customer (
	SSN_SIN int CHECK (0 <= SSN_SIN AND  1000000000 > SSN_SIN),
	first_name varchar(30),
	last_name varchar(30),
	address varchar(30),
	PRIMARY KEY (SSN_SIN)
);

CREATE TABLE employee (
	SSN_SIN int CHECK (0 <= SSN_SIN AND  1000000000 > SSN_SIN),
	address varchar(30),
	roles_positions varchar(40),
	first_name varchar(20),
	last_name varchar(20),
	PRIMARY KEY (SSN_SIN)
);

CREATE TABLE owns (
	hotel_chainID int,
	hotelID int UNIQUE,
	CONSTRAINT fk_chain_name
		FOREIGN KEY (hotel_chainID)
			REFERENCES hotel_chain(hotel_chainID) ON DELETE CASCADE,
	CONSTRAINT fk_hotelID
		FOREIGN KEY (hotelID)
			REFERENCES hotel(hotelID) ON DELETE CASCADE
);

CREATE TABLE works_for (
	hotelID int,
	SSN_SIN int CHECK (0 <= SSN_SIN AND  1000000000 > SSN_SIN),
	CONSTRAINT fk_hotelID
		FOREIGN KEY (hotelID)
			REFERENCES hotel(hotelID) ON DELETE CASCADE,
	CONSTRAINT fk_SSN_SIN
		FOREIGN KEY (SSN_SIN)
			REFERENCES employee(SSN_SIN) ON DELETE CASCADE
);

CREATE TABLE rents (
	SSN_SIN int CHECK (0 <= SSN_SIN AND  1000000000 > SSN_SIN),
	hotelID int,
	CONSTRAINT fk_SSN_SIN
		FOREIGN KEY (SSN_SIN)
			REFERENCES customer(SSN_SIN) ON DELETE CASCADE,
	CONSTRAINT fk_hotelID
		FOREIGN KEY (hotelID)
			REFERENCES hotel(hotelID) ON DELETE CASCADE
);

CREATE TABLE manager (
	hotelID int,
	manager_SSN int CHECK (0 <= manager_SSN AND  1000000000 > manager_SSN),
	employee_SSN int CHECK (0 <= employee_SSN AND  1000000000 > employee_SSN) UNIQUE,
	CONSTRAINT fk_hotelID
		FOREIGN KEY (hotelID)
			REFERENCES hotel(hotelID) ON DELETE CASCADE,
	CONSTRAINT fk_manager_SSN
		FOREIGN KEY (manager_SSN)
			REFERENCES employee(SSN_SIN) ON DELETE CASCADE,
	CONSTRAINT fk_employee_SSN
		FOREIGN KEY (employee_SSN)
			REFERENCES employee(SSN_SIN) ON DELETE CASCADE
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

--default current date for archived_room
DROP TRIGGER IF EXISTS default_time_archive ON archived_room;
DROP FUNCTION IF EXISTS  set_current_time();

CREATE FUNCTION set_current_time() RETURNS trigger as $$
	BEGIN
		if NEW.date_booked IS NULL THEN
			NEW.date_booked := current_timestamp;
			RETURN NEW;
		ELSE 
			RETURN NEW;
	END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER default_time_archive before insert on archived_room FOR EACH ROW
EXECUTE FUNCTION set_current_time();

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

SELECT * FROM ARCHIVED_ROOM;

CREATE FUNCTION set_num_hotel_zero() RETURNS trigger as $$
	BEGIN
		NEW.number_of_hotels := 0;
		RETURN NEW;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_num_hotel_zero before insert on hotel_chain FOR EACH ROW
EXECUTE FUNCTION set_num_hotel_zero();

--hotel chains
INSERT INTO hotel_chain(hotel_chainid, chain_name, address, number_of_hotels, contact_email) VALUES 
(0, 'McDonaldHotel','123 Bank St', 2, 'something@gmail.com'),
(1, 'SleepWell','126 Bank St', 2, 'something@gmail.com'),
(2, 'DontSleepAsWell','13 SomewhereElse St', 2, 'something@gmail.com'),
(3, 'Uncounscious','86 AlleyWay St', 2, 'something@gmail.com'),
(4, 'TimeTravel','967 Wall St', 2, 'something@gmail.com'),
(5, 'GoneOneNight','5 Albert St', 2, 'something@gmail.com');


INSERT INTO phone_numbers_chain(phone_numberID, phone_number) VALUES 
(0,6135421244),
(1,6135443234),
(1,6685421234),
(3,6135429484),
(2,6171421234),
(4,6905421234),
(5,6135421237),
(5,6135421254);

--hotels
INSERT INTO hotel(hotelID, hotel_chainID, rating, contact_email, address, area) VALUES
(0,0,4,'hotel1@gmail.com','547 Lake St','Ottawa'),
(1,0,4,'hotel2@gmail.com','1 Willow St','Ottawa'),
(2,0,2,'hotel3@gmail.com','90 Sparrow St','London'),
(3,1,2,'hotel4@gmail.com','95 Sparrow St','London'),
(4,1,5,'hotel5@gmail.com','87 Field St','London'),
(5,2,4,'hotel6@gmail.com','90 SpringField St','London');

INSERT INTO phone_numbers_hotel(phone_numberID, phone_number) VALUES 
(0,6135421244),
(1,6135443234),
(1,6685421234),
(2,6171421234);

--rooms
INSERT INTO room(hotelID, room_number, price, amenities, capacity, sea_view) VALUES
(0,100,57,'tv',3,true),(0,101,57,'tv',9,true),(0,102,57,'tv',3,false),(0,103,57,'tv',8,true),(0,104,57,'tv',3,true),
(1,100,57,'tv',4,true),(1,101,57,'tv',2,true),(1,102,57,'tv',3,false),(1,103,57,'tv',5,true),(1,104,57,'tv',1,true),
(1,105,57,'tv',4,true),(1,106,57,'tv',2,true),(1,107,57,'tv',3,false),
(2,100,57,'tv',3,true),(2,101,57,'tv',2,true),(2,102,57,'tv',3,false),(2,103,57,'tv',3,true),(2,104,57,'tv',3,true),
(3,100,57,'tv',3,true),(3,101,57,'tv',2,true),(3,102,57,'tv',3,false),(3,103,57,'tv',3,true),(3,104,57,'tv',3,true),
(4,100,57,'tv',3,true),(4,101,57,'tv',2,true),(4,102,57,'tv',3,false),(4,103,57,'tv',1,true),(4,104,57,'tv',3,true),
(5,100,57,'tv',3,true),(5,101,57,'tv',2,true),(5,102,57,'tv',3,false),(5,103,57,'tv',3,true),(5,104,57,'tv',3,true);

INSERT INTO archived_room(hotelID, room_number, price, amenities, capacity, sea_view,date_booked) VALUES
(0,100,57,'tv',3,true,'2023-05-23'),
(1,103,57,'tv',3,true,'2023-03-30'),(1,104,57,'tv',3,true,'2023-07-23'),
(2,102,57,'tv',3,false,'2023-05-27'),(2,103,57,'tv',3,true,'2023-02-10'),
(3,100,57,'tv',3,true,'2023-05-23'),(3,103,57,'tv',3,true,'2023-05-23'),(3,104,57,'tv',3,true,'2023-05-23'),
(4,100,57,'tv',3,true,'2023-05-23'),(4,103,57,'tv',3,true,'2023-05-23'),(4,104,57,'tv',3,true,'2023-05-23'),
(5,100,57,'tv',3,true,'2023-05-23'),(5,101,57,'tv',2,true,'2023-03-30');

INSERT INTO customer(SSN_SIN, first_name, last_name, address) VALUES
(9992384,'Joe','Biden','White House'),
(9992385,'Barack','Obama','Not the White House'),
(9992382,'Justin','Trudeau','Parliment'),
(9992389,'John','Doe','Generic St');

INSERT INTO employee(SSN_SIN, first_name, last_name, address, roles_positions) VALUES
(9992384,'Joe','Biden','White House','manager'),
(9992381,'Jeremy','Clark','734 Alberto St', 'receptionist'),
(9992386,'Allison','Winnin','32 Creaksdan', 'branch manager'),
(99923769,'Wings','Johnson','Generic St','servant');

INSERT INTO owns(hotel_chainID, hotelID) VALUES
(0,0),
(1,1),
(1,2);

INSERT INTO works_for(hotelID, SSN_SIN) VALUES
(0,9992384),
(0,9992381),
(1,9992386),
(1,99923769);

INSERT INTO rents(hotelID, SSN_SIN) VALUES
(0,9992384),
(1,9992385),
(1,9992382),
(1,9992389);

INSERT INTO manager(hotelID, manager_SSN, employee_SSN) VALUES
(0,9992384,9992384),
(0,9992384,9992381),
(1,9992386,9992386),
(1,9992386,99923769);