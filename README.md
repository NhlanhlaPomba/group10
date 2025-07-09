# Hospital Database SQL Project

This repository contains the SQL script to create and manage a simple hospital database system. The schema covers essential hospital functionality, including patient management, doctor management, admissions, rooms, and prescriptions. It also includes stored procedures for inserting data and triggers to maintain business rules and data integrity.

## Features

- **Patients Table**: Store patient personal details.
- **Doctors Table**: Store doctor information and qualifications.
- **Rooms Table**: Track hospital rooms, types, occupancy, and status.
- **Admissions Table**: Record patient admissions, link patients to doctors and rooms, and track severity.
- **Prescriptions Table**: Track patient prescriptions assigned by doctors.
- **Stored Procedures**: Insert data into major tables using defined procedures.
- **Triggers**: 
  - Prevent a doctor from having more than two patients simultaneously.
  - Prevent rooms from being overfilled.
  - Automatically update room occupancy and availability status on admission and discharge.

## Getting Started

### Prerequisites

- MySQL 5.7+ (or compatible database supporting triggers, enums, and signals)

### Usage

1. **Clone the repository** or copy the `hospital_database.sql` file.
2. **Run the SQL script** in your MySQL environment. The script will:
    - Drop and recreate the `group10` database.
    - Create all tables, procedures, and triggers.

   ```sh
   mysql -u <user> -p < hospital_database.sql
   ```

3. **Insert data** using the stored procedures:
    - `CALL insert_patient(Name, DOB, Phone, Address);`
    - `CALL insert_doctor(Name, Gender, Phone, Qualification);`
    - `CALL insert_room(room_number, bed_count, room_type);`
    - `CALL admit_patient(patients, doctors, room, pcondition);`
    - `CALL insert_prescription(patient, doctor, medication, date);`

### Table Overview

- **pomba_patient**: Patient records
- **zano_doctor**: Doctor records
- **masela_room**: Hospital rooms
- **moyikwa_admission**: Admissions (links patients, doctors, rooms)
- **keith_prescription**: Prescriptions

### Business Rules Enforced

- A doctor cannot have more than two patients admitted at the same time.
- Rooms cannot be overfilled beyond their bed count.
- Room status is automatically updated to 'Full' or 'Available' based on occupancy.

### Extending the Database

You can add more tables, procedures, or triggers as needed for billing, appointments, or other hospital workflows.

## Notes

- All table and procedure names are prefixed to show group contributions.
- All foreign key relationships are enforced.
- ENUMs are used for gender, room types, and severity/status fields.

## License

This project is provided for educational purposes. Feel free to use and modify it as needed.
