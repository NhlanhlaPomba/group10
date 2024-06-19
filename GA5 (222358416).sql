CREATE DATABASE group102;
use group102;
-- Patients TAble
CREATE TABLE pomba_patient(
    patientID INT(5) PRIMARY KEY,
    patientName VARCHAR(150),
    patientDOB DATE,
    patientPhone VARCHAR(13),
    patientAddress VARCHAR(255)
);
-- Doctors Table
CREATE TABLE zano_doctor(
    doctorsMedicalLicense INT(5) PRIMARY KEY,
    doctorsName VARCHAR(150),
    doctorsGender ENUM('M','F'),
    doctorsPhone VARCHAR(13),
    doctorsQualification VARCHAR(150)
);

-- Rooms table
CREATE TABLE hubert_room ( 
    roomNumber VARCHAR(5) PRIMARY KEY,
    bedCount INT,
    currentOccupancy INT DEFAULT 0,
    availabilityStatus ENUM('Available', 'Full', 'UnderMaintenance') DEFAULT 'Available',
    roomType ENUM('General', 'Private', 'ICU')
);

-- Admissions table
CREATE TABLE moyikwa_admission(
    patientID INT(5),
    doctorsID INT(5),
    roomNumber VARCHAR(5),
    severityOfCondition ENUM('Mild', 'Moderate', 'Severe', 'Critical'),
    admissionDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 

    PRIMARY KEY (patientID, doctorsID),
    FOREIGN KEY (patientID) REFERENCES pomba_patient(patientID),
    FOREIGN KEY (doctorsID) REFERENCES zano_doctor(doctorsMedicalLicense),
    FOREIGN KEY (roomNumber) REFERENCES hubert_room(roomNumber)
);
-- Prescription table which we had said Medication table last time;
CREATE TABLE g10_prescription ( 
    prescriptionID INT(5) PRIMARY KEY,
    patientID INT(5),
    doctorsID INT(5),
    medicationName VARCHAR(150),
    startDate DATE,

    FOREIGN KEY (patientID) REFERENCES pomba_patient(patientID),
    FOREIGN KEY (doctorsID) REFERENCES zano_doctor(doctorsMedicalLicense)
);

INSERT INTO pomba_patient (patientID, patientName, patientDOB, patientPhone, patientAddress) VALUES
(1001, 'Sakhile Ntombela', '1980-01-15', '073-456-5487', '1205 Mhlanga Str, Johannesburg'),
(1002, 'Lerato Ntodini', '1990-07-22', '067-567-8901', '1805 Orande Farm, Johannesburg'),
(1003, 'Nokwazi Nceba', '1975-05-30', '041-678-9012', '789 Pine Road, Johannesburg'),
(1004, 'Phiwe Mhlongo', '1985-11-10', '087-789-0123', '101 Maple Drive, Johannesburg');

INSERT INTO zano_doctor (doctorsMedicalLicense, doctorsName, doctorsGender, doctorsPhone, doctorsQualification) VALUES
(2001, 'Dr. Dikeledi Lietsiso', 'F', '098-567-7887', 'MD Cardiology'),
(2002, 'Dr. Kwanele Pomba', 'M', '081-498-7501', 'MD Neurology'),
(2003, 'Dr. Busisiwe Mnisi', 'F', '076-398-9012', 'MD Oncology'),
(2004, 'Dr. Mncedisi Pomba', 'M', '062-495-0123', 'MD Pediatrics');

INSERT INTO hubert_room (roomNumber, bedCount, currentOccupancy, availabilityStatus, roomType) VALUES
('R101', 2, 1, 'Available', 'General'),
('R102', 1, 1, 'Full', 'Private'),
('R103', 3, 0, 'Available', 'ICU'),
('R104', 2, 0, 'UnderMaintenance', 'General');

INSERT INTO moyikwa_admission (patientID, doctorsID, roomNumber, severityOfCondition, admissionDate) VALUES
(1001, 2001, 'R101', 'Moderate', '2024-06-01 10:00:00'),
(1002, 2002, 'R102', 'Severe', '2024-06-05 12:00:00'),
(1003, 2003, 'R103', 'Critical', '2024-06-10 14:00:00'),
(1004, 2004, 'R101', 'Mild', '2024-06-15 16:00:00');

INSERT INTO g10_prescription (prescriptionID, patientID, doctorsID, medicationName, startDate) VALUES
(3001, 1001, 2001, 'Aspirin', '2024-06-01'),
(3002, 1002, 2002, 'Ibuprofen', '2024-06-05'),
(3003, 1003, 2003, 'Paracetamol', '2024-06-10'),
(3004, 1004, 2004, 'Amoxicillin', '2024-06-15');

select*from pomba_patient;
select*from zano_doctor;
select*from hubert_room;
select*from moyikwa_admission;
select*from g10_prescription;

--Stored procedure
--Add new patient 
DELIMITER //
CREATE PROCEDURE AddNewPatient(
    IN p_patientID INT,
    IN p_patientName VARCHAR(150),
    IN p_patientDOB DATE,
    IN p_patientPhone VARCHAR(13),
    IN p_patientAddress VARCHAR(255)
)
BEGIN
    INSERT INTO pomba_patient (patientID, patientName, patientDOB, patientPhone, patientAddress)
    VALUES (p_patientID, p_patientName, p_patientDOB, p_patientPhone, p_patientAddress);
END //
DELIMITER ;
INSERT INTO pomba_patient (patientID, patientName, patientDOB, patientPhone, patientAddress)
VALUES (1005, 'Nomfundo Mthembu', '1992-03-20', '079-890-4987', '321 Cedar Avenue, Johannesburg');

--Assigning a Patient to a Room
DELIMITER //
CREATE PROCEDURE AssignPatientToRoom(
    IN p_patientID INT,
    IN p_doctorsID INT,
    IN p_roomNumber VARCHAR(5),
    IN p_severityOfCondition ENUM('Mild', 'Moderate', 'Severe', 'Critical')
)
BEGIN
    DECLARE occupancy INT;
    DECLARE bedCount INT;
    
    SELECT currentOccupancy, bedCount INTO occupancy, bedCount FROM room WHERE roomNumber = p_roomNumber;
    
    IF occupancy < bedCount THEN
        UPDATE room SET currentOccupancy = currentOccupancy + 1 WHERE roomNumber = p_roomNumber;
        IF currentOccupancy + 1 = bedCount THEN
            UPDATE room SET availabilityStatus = 'Full' WHERE roomNumber = p_roomNumber;
        END IF;
        INSERT INTO admission (patientID, doctorsID, roomNumber, severityOfCondition)
        VALUES (p_patientID, p_doctorsID, p_roomNumber, p_severityOfCondition);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Room is already full';
    END IF;
END //
DELIMITER ;
UPDATE room
SET currentOccupancy = currentOccupancy + 1
WHERE roomNumber = 'R103';

--Discharging a Patient
DELIMITER //
CREATE PROCEDURE DischargePatient(
    IN p_patientID INT,
    IN p_doctorsID INT
)
BEGIN
    DECLARE roomNum VARCHAR(5);
    
    SELECT roomNumber INTO roomNum FROM admission WHERE patientID = p_patientID AND doctorsID = p_doctorsID;
    
    IF roomNum IS NOT NULL THEN
        UPDATE room SET currentOccupancy = currentOccupancy - 1 WHERE roomNumber = roomNum;
        IF currentOccupancy - 1 < bedCount THEN
            UPDATE room SET availabilityStatus = 'Available' WHERE roomNumber = roomNum;
        END IF;
        DELETE FROM admission WHERE patientID = p_patientID AND doctorsID = p_doctorsID;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Patient not found in admissions';
    END IF;
END //
DELIMITER ;
UPDATE room
SET currentOccupancy = currentOccupancy - 1
WHERE roomNumber = 'R103';



--Cursors
--This stored procedure uses a cursor to show the patients and their prescriptions of specific row called 
DELIMITER //
CREATE PROCEDURE ListPatientPrescriptions(IN patientID_param INT)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE pName VARCHAR(150);
    DECLARE medNames VARCHAR(1000);
    DECLARE cursorPrescriptions CURSOR FOR 
        SELECT GROUP_CONCAT(medicationName SEPARATOR ', ') 
        FROM g10_prescription 
        WHERE patientID = patientID_param;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    -- Select patient name
    SELECT patientName INTO pName FROM pomba_patient WHERE patientID = patientID_param;
    
    -- Open the cursor for prescriptions
    OPEN cursorPrescriptions;
    FETCH cursorPrescriptions INTO medNames;
    IF NOT done THEN
        SELECT CONCAT('Patient: ', pName, ' -Prescriptions: ', medNames) AS patient_prescriptions_info;
    END IF;
    CLOSE cursorPrescriptions;
END //
DELIMITER ;
CALL ListPatientPrescriptions(1001);


--Cursor for which Doctor belong to which patient
 DELIMITER //

CREATE PROCEDURE ReportPatientsByDoctor(
    IN specificDoctorID INT -- Parameter to specify which doctor to report
)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE dID INT;
    DECLARE dName VARCHAR(150);
    DECLARE pID INT;
    DECLARE pName VARCHAR(150);
    
    -- Cursor to fetch doctors and their patients based on specificDoctorID
    DECLARE cursorDoctors CURSOR FOR 
        SELECT d.doctorsMedicalLicense, d.doctorsName, p.patientID, p.patientName 
        FROM doctor d
        JOIN admission a ON d.doctorsMedicalLicense = a.doctorsID
        JOIN patient p ON a.patientID = p.patientID
        WHERE d.doctorsMedicalLicense = specificDoctorID
        ORDER BY d.doctorsMedicalLicense; -- Order by doctorsMedicalLicense for sequential fetching
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    OPEN cursorDoctors;
    
    FETCH cursorDoctors INTO dID, dName, pID, pName;
    
    WHILE NOT done DO
        -- Output doctor information if it's a new doctor
        IF @prev_dID IS NULL OR @prev_dID <> dID THEN
            SELECT CONCAT('Doctor: ', dName) AS doctor_info;
            SET @prev_dID := dID;
        END IF;
        
        -- Output patient information
        SELECT CONCAT('  Patient: ', pName) AS patient_info;
        
        -- Fetch next row
        FETCH cursorDoctors INTO dID, dName, pID, pName;
    END WHILE;
    
    CLOSE cursorDoctors;
END //

DELIMITER ;
CALL ReportPatientsByDoctor(2003);








-- Trigger to update room status after you admit a patient
DELIMITER //

DROP TRIGGER IF EXISTS update_room_status_on_admission_insert//
CREATE TRIGGER update_room_status_on_admission_insert
AFTER INSERT ON moyikwa_admission
FOR EACH ROW
BEGIN
    DECLARE patient_count INT;
    DECLARE room_occupancy INT;
    DECLARE room_bed_count INT;
    
    -- Count the number of patients asinged to the doctor
    SELECT COUNT(*) INTO patient_count FROM moyikwa_admission WHERE doctorsID = NEW.doctorsID;
    
    -- Check if doctor has more than 2 patients
    IF patient_count > 2 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doctor cannot have more than 2 patients';
    END IF;
    
    -- Get the number of people in the room and also the number of beds
    SELECT currentOccupancy, bedCount INTO room_occupancy, room_bed_count
    FROM hubert_room WHERE roomNumber = NEW.roomNumber;

    -- The missing code so that a room does not allow more patients than there are beds in a room
    IF room_occupancy + 1 > room_bed_count THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The room is full';
    END IF;
    
    -- Update the number of people in the romm and room occupancy
    IF room_occupancy >= room_bed_count THEN
        UPDATE hubert_room SET currentOccupancy = room_bed_count, availabilityStatus = 'Full' WHERE roomNumber = NEW.roomNumber;
    ELSE
        UPDATE hubert_room SET currentOccupancy = room_occupancy + 1 WHERE roomNumber = NEW.roomNumber;
        
        -- Check if room becomes full after update
        IF room_occupancy + 1 >= room_bed_count THEN
            UPDATE hubert_room SET availabilityStatus = 'Full' WHERE roomNumber = NEW.roomNumber;
        END IF;
    END IF;
END //



CREATE TRIGGER update_room_status_on_admission_delete
BEFORE DELETE ON admission
FOR EACH ROW
BEGIN
    DECLARE room_occupancy INT;
    DECLARE room_bed_count INT;
    
    -- Get current occupancy and bed count of the room
    SELECT currentOccupancy, bedCount INTO room_occupancy, room_bed_count
    FROM room WHERE roomNumber = OLD.roomNumber;
    
    -- Checking if the room was full and then making it available otherwise just create room for a bed
    IF room_occupancy = room_bed_count THEN
        UPDATE room SET currentOccupancy = room_occupancy - 1, availabilityStatus = 'Available' WHERE roomNumber = OLD.roomNumber;
    ELSE
        UPDATE room SET currentOccupancy = room_occupancy - 1 WHERE roomNumber = OLD.roomNumber;
    END IF;
END //

DELIMITER ;

DELIMITER //
CREATE PROCEDURE dischargePatient (IN inPatientID INT, IN inRoomNumber VARCHAR(5))
BEGIN
  UPDATE admission
  SET dischargeDate = CURRENT_TIMESTAMP
  WHERE patientID = inPatientID;

  UPDATE room
  SET currentOccupancy = currentOccupancy - 1
  WHERE roomNumber = inRoomNumber;
END //
DELIMITER ; */


DELIMITER //
CREATE TRIGGER PreventOverbooking
BEFORE INSERT ON admission
FOR EACH ROW
BEGIN
    DECLARE bCount INT;
    DECLARE cOccupancy INT;
    
    -- Get current bed count and occupancy for the room
    SELECT bedCount, currentOccupancy INTO bCount, cOccupancy
    FROM room
    WHERE roomNumber = NEW.roomNumber; -- NEW.roomNumber refers to the newly inserted roomNumber in admission
    
    -- Check if adding this admission would exceed the room's capacity
    IF cOccupancy >= bCount THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Room is already fully occupied. Cannot admit another patient.';
    END IF;
END //
DELIMITER ;

INSERT INTO admission (patientID, doctorsID, roomNumber, severityOfCondition, admissionDate)
VALUES (1004, 2004, 'R102', 'Moderate', '2024-06-18 14:00:00');











