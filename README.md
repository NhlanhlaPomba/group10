# Hospital Management Database System

This repository contains a comprehensive MySQL database schema and sample data for a hospital management system, suitable for academic or demonstration purposes. The schema models patients, doctors, room management, admissions, prescriptions, and includes advanced features like stored procedures, triggers, and cursors.

---

## Features

- **Patient Management**: Records patient details and supports adding new patients via stored procedures.
- **Doctor Management**: Records doctor information including qualifications and gender.
- **Room Management**: Tracks rooms, bed counts, current occupancy, and availability status. Supports different room types (General, Private, ICU).
- **Admissions**: Links patients to doctors and rooms, tracks severity of conditions, and manages admission dates.
- **Prescription Handling**: Assigns prescriptions to patients from doctors with medication details and start dates.
- **Sample Data**: Includes initial records for all tables to illustrate usage.
- **Stored Procedures**:
  - `AddNewPatient`: Adds a new patient record.
  - `AssignPatientToRoom`: Handles logic for admitting a patient to a room, checks and updates occupancy.
  - `DischargePatient`: Removes a patient from a room and updates occupancy.
  - `ListPatientPrescriptions`: Uses a cursor to display all prescriptions for a specific patient.
  - `ReportPatientsByDoctor`: Uses a cursor to list all patients assigned to a specific doctor.
  - `dischargePatient`: Updates discharge date and decreases room occupancy.
- **Triggers**:
  - `update_room_status_on_admission_insert`: Ensures a doctor cannot have more than two patients, and prevents overbooking of rooms.
  - `update_room_status_on_admission_delete`: Updates room status and occupancy when a patient is discharged.
  - `PreventOverbooking`: Prevents admitting more patients than a room's capacity.
- **Business Rules**:
  - No doctor can have more than two patients at the same time.
  - No room can be overbooked beyond its bed count.
  - Room availability status updates automatically as patients are admitted/discharged.

---

## Database Tables

- `pomba_patient`: Patient details.
- `zano_doctor`: Doctor details.
- `hubert_room`: Room information and status.
- `moyikwa_admission`: Records the admission of patients, linking them to doctors and rooms.
- `g10_prescription`: Medication prescribed to patients.

---

## Sample Usage

- **Run the SQL script** in your MySQL environment to create the schema and populate it with sample data.
- **Stored Procedures**:
    - To add a patient:
      ```sql
      CALL AddNewPatient(1006, 'John Doe', '1993-05-01', '078-123-4567', '123 New Road, City');
      ```
    - To assign a patient to a room:
      ```sql
      CALL AssignPatientToRoom(1001, 2001, 'R101', 'Moderate');
      ```
    - To discharge a patient:
      ```sql
      CALL DischargePatient(1001, 2001);
      ```
    - To list prescriptions for a patient:
      ```sql
      CALL ListPatientPrescriptions(1001);
      ```
    - To list patients by doctor:
      ```sql
      CALL ReportPatientsByDoctor(2003);
      ```

---

## Notes

- Table and procedure names are prefixed to reflect team contribution.
- Some stored procedures and triggers reference short table names like `room` or `admission`, while some tables are created with longer names (e.g., `hubert_room`, `moyikwa_admission`). Adjust these in the SQL as needed for consistency.
- This script uses MySQL-specific features (e.g., `ENUM`, `SIGNAL SQLSTATE`, `CURSOR`).

---

## License

This project is for educational and demonstration purposes. You are free to use and modify it for your own use.

---
