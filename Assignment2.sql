CREATE SCHEMA IF NOT EXISTS blood_bank;

CREATE TABLE donor(
    cpr CHAR(10) PRIMARY KEY,
    name VARCHAR(40),
    house_number INT,
    street VARCHAR(40),
    city VARCHAR (40),
    postal_code INT,
    phone VARCHAR(12),
    blood_type VARCHAR(3) CHECK(blood_type IN ('O-', 'O+', 'B-', 'B+', 'A-', 'A+', 'AB-', 'AB+')),
    last_reminder DATE
);

CREATE TABLE next_appointment(
    date DATE PRIMARY KEY,
    time TIME,
    donor_cpr CHAR(10) references donor(cpr)
);

CREATE TABLE blood_donations(
    id SERIAL PRIMARY KEY,
    date DATE,
    amount DECIMAL(3) CHECK (amount BETWEEN 300 AND 600),
    blood_percent DECIMAL (3,1) CHECK (blood_percent BETWEEN 8.0 AND 11.0),
    donor_id CHAR(10) references donor(cpr)
);

CREATE TABLE staff(
    initials VARCHAR(20) PRIMARY KEY,
    cpr CHAR(10),
    name VARCHAR(40),
    house_number INT,
    street VARCHAR(40),
    city VARCHAR (40),
    postal_code INT,
    phone VARCHAR(12),
    hire_date DATE,
    position VARCHAR(11) CHECK(position IN ('nurse', 'bioanalytic', 'intern'))
);

CREATE TABLE managed_by(
    collected_by_nurse_id VARCHAR(20) REFERENCES staff(initials),
    donation_id INT references blood_donations(id),
    verified_by_nurse_initials VARCHAR(20) REFERENCES staff(initials),
    PRIMARY KEY (donation_id)
);

SET SCHEMA 'blood_bank';

-- Ensure donor table has correct values
INSERT INTO donor VALUES ('0000000000', 'alice', 2, 'baker street', 'london', 10001, '+44791122344', 'A+', '2025-02-15'),
                         ('1111111111', 'john', 1, 'europes avenue', 'new york', 1, '+8698798798', 'O-', '2025-01-01');

-- Ensure foreign keys in next_appointment match donor CPRs
INSERT INTO next_appointment (date, time, donor_cpr)
VALUES
    ('2025-04-01', '10:30:00', '1234567890'),
    ('2025-04-02', '11:00:00', '0987654321');

-- Ensure amount is within the CHECK constraint (300-600)
INSERT INTO blood_donations (date, amount, blood_percent, donor_id)
VALUES
    ('2025-03-01', 500, 9.5, '1234567890'),
    ('2025-03-05', 450, 10.2, '0987654321');

-- Ensure initials are unique and match the managed_by foreign key references
INSERT INTO staff (initials, cpr, name, house_number, street, city, postal_code, phone, hire_date, position)
VALUES
    ('JN001', '3333333333', 'Julia Nurse', 5, 'hospital street', 'new york', 30003, '+12345678901', '2020-06-15', 'nurse'),
    ('BA002', '4444444444', 'Ben Analyst', 9, 'lab street', 'boston', 40004, '+19876543222', '2019-08-20', 'bioanalytic');

-- Ensure donation_id references an existing blood donation ID
INSERT INTO managed_by (collected_by_nurse_id, donation_id, verified_by_nurse_initials)
VALUES
    ('JN001', 1, 'BA002'),
    ('JN001', 2, 'BA002');