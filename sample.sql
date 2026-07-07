/*
================================================================================
 Hospital Information System (HIS) - Sample / Seed Data
 Generated for demo & UI walkthrough purposes.
 Populates: 50 patients, 15 doctors, 20 nurses,
 10 admin staff, 8 departments, 40 beds,
 200 appointments, 60 admissions, 150 lab/imaging
 requests, 149 lab results, 100 prescriptions, pharmacy inventory,
 invoices & payments, IoT devices & alerts, medical records, and diagnoses.

 IMPORTANT: Run this AFTER schemas.sql, functions.sql, triggers.sql, views.sql,
 procedures.sql, and security_login_system.sql have all been executed successfully
 against an EMPTY database. Several tables here rely on triggers (bed status,
 invoice totals, lab/IoT alerts, inventory) to compute derived values automatically.

 Demo login password for every seeded account: Passw0rd!
================================================================================
*/

SET NOCOUNT ON;
GO


-- ============================================================
-- 1. INSURANCE PROVIDERS
-- ============================================================

SET IDENTITY_INSERT [insurance] ON;
INSERT INTO [insurance] ([id], [name], [type], [coveragepercent], [isActive]) VALUES
(1, N'MediCare Plus', N'Government', 80.0, 1),
(2, N'BlueShield National', N'Private', 70.0, 1),
(3, N'HealthGuard Basic', N'Private', 50.0, 1),
(4, N'Veterans Health Plan', N'Government', 90.0, 1),
(5, N'Self-Pay', N'None', 0.0, 1),
(6, N'Legacy Family Cover', N'Private', 60.0, 0);
SET IDENTITY_INSERT [insurance] OFF;


GO


-- ============================================================
-- 1b. DEPARTMENTS
-- ============================================================

SET IDENTITY_INSERT [department] ON;
INSERT INTO [department] ([id], [name], [type]) VALUES
(1, N'Emergency Department', N'Emergency'),
(2, N'Cardiology', N'Inpatient'),
(3, N'General Surgery', N'Surgical'),
(4, N'Pediatrics', N'Inpatient'),
(5, N'Internal Medicine', N'Inpatient'),
(6, N'Orthopedics', N'Surgical'),
(7, N'Intensive Care Unit', N'ICU'),
(8, N'Obstetrics & Gynecology', N'Inpatient');
SET IDENTITY_INSERT [department] OFF;


GO


-- ============================================================
-- 1c. DRUGS
-- ============================================================

SET IDENTITY_INSERT [drug] ON;
INSERT INTO [drug] ([id], [name], [type], [description]) VALUES
(1, N'Amoxicillin 500mg', N'Antibiotic', N'Broad-spectrum penicillin antibiotic'),
(2, N'Metformin 500mg', N'Antidiabetic', N'First-line oral therapy for type 2 diabetes'),
(3, N'Lisinopril 10mg', N'Antihypertensive', N'ACE inhibitor for hypertension and heart failure'),
(4, N'Atorvastatin 20mg', N'Statin', N'Lowers LDL cholesterol'),
(5, N'Ibuprofen 400mg', N'NSAID', N'Nonsteroidal anti-inflammatory / analgesic'),
(6, N'Paracetamol 500mg', N'Analgesic', N'Pain reliever and fever reducer'),
(7, N'Warfarin 5mg', N'Anticoagulant', N'Vitamin K antagonist anticoagulant'),
(8, N'Salbutamol Inhaler', N'Bronchodilator', N'Short-acting beta agonist for asthma/COPD'),
(9, N'Omeprazole 20mg', N'PPI', N'Reduces stomach acid production'),
(10, N'Insulin Glargine', N'Antidiabetic', N'Long-acting basal insulin'),
(11, N'Ceftriaxone 1g Inj', N'Antibiotic', N'Third-generation cephalosporin, IV/IM'),
(12, N'Morphine Sulfate 10mg', N'Opioid Analgesic', N'Strong opioid for severe pain management'),
(13, N'Furosemide 40mg', N'Diuretic', N'Loop diuretic for fluid overload'),
(14, N'Clopidogrel 75mg', N'Antiplatelet', N'Prevents platelet aggregation post-MI/stroke'),
(15, N'Levothyroxine 50mcg', N'Hormone', N'Thyroid hormone replacement'),
(16, N'Amlodipine 5mg', N'Antihypertensive', N'Calcium channel blocker'),
(17, N'Azithromycin 250mg', N'Antibiotic', N'Macrolide antibiotic'),
(18, N'Prednisolone 5mg', N'Corticosteroid', N'Anti-inflammatory / immunosuppressive'),
(19, N'Diazepam 5mg', N'Benzodiazepine', N'Sedative, anxiolytic, muscle relaxant'),
(20, N'Heparin 5000 IU', N'Anticoagulant', N'Fast-acting anticoagulant, IV/SC');
SET IDENTITY_INSERT [drug] OFF;


GO


-- ============================================================
-- 1d. ICD-10 DISEASE CODES
-- ============================================================

SET IDENTITY_INSERT [icddisease] ON;
INSERT INTO [icddisease] ([id], [code], [name]) VALUES
(1, N'I10', N'Essential (primary) hypertension'),
(2, N'E11.9', N'Type 2 diabetes mellitus without complications'),
(3, N'J45.9', N'Asthma, unspecified'),
(4, N'J18.9', N'Pneumonia, unspecified organism'),
(5, N'I21.9', N'Acute myocardial infarction, unspecified'),
(6, N'K35.80', N'Acute appendicitis, unspecified'),
(7, N'S72.001A', N'Fracture of neck of right femur'),
(8, N'N18.3', N'Chronic kidney disease, stage 3'),
(9, N'O80', N'Encounter for full-term uncomplicated delivery'),
(10, N'A09', N'Infectious gastroenteritis and colitis, unspecified'),
(11, N'I50.9', N'Heart failure, unspecified'),
(12, N'J44.9', N'Chronic obstructive pulmonary disease, unspecified'),
(13, N'E03.9', N'Hypothyroidism, unspecified'),
(14, N'M17.9', N'Osteoarthritis of knee, unspecified'),
(15, N'R10.9', N'Abdominal pain, unspecified'),
(16, N'I63.9', N'Cerebral infarction, unspecified (stroke)'),
(17, N'N39.0', N'Urinary tract infection, site not specified'),
(18, N'K80.20', N'Cholelithiasis without cholecystitis'),
(19, N'S06.0', N'Concussion'),
(20, N'Z34.9', N'Encounter for supervision of normal pregnancy');
SET IDENTITY_INSERT [icddisease] OFF;


GO


-- ============================================================
-- 1e. LAB CRITICAL VALUE REFERENCE RANGES
-- ============================================================

SET IDENTITY_INSERT [isCritical] ON;
INSERT INTO [isCritical] ([id], [type], [referenceMin], [referenceMax], [isCritical_status], [unit]) VALUES
(1, N'Hemoglobin', 12.0, 17.5, N'Critical if outside range', N'g/dL'),
(2, N'WBC', 4.0, 11.0, N'Critical if outside range', N'x10^9/L'),
(3, N'Glucose', 70.0, 140.0, N'Critical if outside range', N'mg/dL'),
(4, N'Creatinine', 0.6, 1.3, N'Critical if outside range', N'mg/dL'),
(5, N'Potassium', 3.5, 5.1, N'Critical if outside range', N'mmol/L'),
(6, N'Sodium', 135.0, 145.0, N'Critical if outside range', N'mmol/L'),
(7, N'Platelets', 150.0, 400.0, N'Critical if outside range', N'x10^9/L'),
(8, N'Troponin', 0.0, 0.04, N'Critical if outside range', N'ng/mL'),
(9, N'INR', 0.8, 1.2, N'Critical if outside range', N'ratio'),
(10, N'X-Ray Finding', NULL, NULL, N'Reviewed by radiologist', NULL);
SET IDENTITY_INSERT [isCritical] OFF;


GO


-- ============================================================
-- 1f. PAYMENT METHODS
-- ============================================================

SET IDENTITY_INSERT [paymentmethod] ON;
INSERT INTO [paymentmethod] ([id], [type]) VALUES
(1, N'Cash'),
(2, N'Credit Card'),
(3, N'Debit Card'),
(4, N'Insurance Direct Billing'),
(5, N'Bank Transfer');
SET IDENTITY_INSERT [paymentmethod] OFF;


GO


-- ============================================================
-- 1g. PHARMACY / WARD STORAGE LOCATIONS
-- ============================================================

SET IDENTITY_INSERT [storage] ON;
INSERT INTO [storage] ([id], [name], [inventory], [type]) VALUES
(1, N'Main Pharmacy Store', 0, N'Pharmacy'),
(2, N'ICU Emergency Cabinet', 0, N'Ward'),
(3, N'ER Crash Cart', 0, N'Ward'),
(4, N'Surgical Ward Store', 0, N'Ward');
SET IDENTITY_INSERT [storage] OFF;


GO


-- ============================================================
-- 2. PATIENTS
-- ============================================================

INSERT INTO [patient] ([nationalID], [insuranceID], [name], [datebirth], [gender], [phone], [address]) VALUES
(N'242-23-9935', 2, N'Mary Mitchell', '2014-10-14', N'Female', N'555-232-1488', N'1545 Willow Way, Georgetown'),
(N'529-38-8359', 5, N'Mary Scott', '1950-05-26', N'Female', N'555-206-3615', N'6934 Lakeview Drive, Clinton'),
(N'489-22-6881', NULL, N'Jason Perez', '1981-10-09', N'Male', N'555-244-8527', N'8795 Elm Drive, Oakland'),
(N'982-56-4150', 5, N'Andrew Jackson', '1935-02-02', N'Male', N'555-877-4733', N'4751 Cedar Lane, Greenville'),
(N'266-57-6820', 3, N'Michael Harris', '1999-11-09', N'Male', N'555-918-2169', N'9990 Birch Boulevard, Bristol'),
(N'324-97-6313', 5, N'Barbara Robinson', '2018-04-27', N'Female', N'555-232-6168', N'6582 River Road, Riverside'),
(N'505-92-8517', 4, N'Kenneth Rivera', '2007-05-05', N'Male', N'555-452-9830', N'4314 Hillcrest Drive, Arlington'),
(N'621-73-2489', 2, N'Margaret White', '2019-02-05', N'Female', N'555-842-3621', N'6926 Meadow Lane, Riverside'),
(N'981-11-2876', 5, N'George Robinson', '1938-09-25', N'Male', N'555-473-6573', N'1837 Highland Avenue, Arlington'),
(N'612-32-9317', 3, N'James Campbell', '2012-11-10', N'Male', N'555-854-9317', N'9987 Willow Way, Fairview'),
(N'100-86-6310', 5, N'William Wright', '1963-01-04', N'Male', N'555-571-6038', N'3933 Oak Avenue, Georgetown'),
(N'878-78-3060', 1, N'Jennifer Garcia', '2009-11-16', N'Female', N'555-762-3705', N'4352 Washington Street, Greenville'),
(N'830-49-7537', 2, N'Susan Wright', '1940-11-12', N'Female', N'555-648-9479', N'7407 Elm Drive, Georgetown'),
(N'702-38-1117', 2, N'Christopher Johnson', '2016-12-21', N'Male', N'555-260-4750', N'1114 Oak Avenue, Greenville'),
(N'319-79-3167', 4, N'Steven Thomas', '1933-10-19', N'Male', N'555-684-4981', N'7759 Chestnut Street, Georgetown'),
(N'578-16-2612', 4, N'Edward Ramirez', '2018-07-24', N'Male', N'555-547-2790', N'4083 Willow Way, Georgetown'),
(N'355-19-8260', 4, N'Elizabeth Ramirez', '1955-02-02', N'Female', N'555-867-9856', N'251 Cedar Lane, Oakland'),
(N'318-61-1960', 4, N'Jessica Hernandez', '2004-07-01', N'Female', N'555-599-5345', N'7464 Highland Avenue, Arlington'),
(N'258-34-5861', 4, N'Deborah Scott', '1998-01-19', N'Female', N'555-953-9883', N'1008 Lakeview Drive, Springfield'),
(N'261-17-9320', 5, N'Paul Allen', '2015-03-03', N'Male', N'555-809-2113', N'3863 Main Street, Riverside'),
(N'734-20-7868', 1, N'Michelle Thomas', '1941-10-19', N'Female', N'555-735-6183', N'4282 Willow Way, Ashland'),
(N'568-50-2188', 3, N'Jessica Taylor', '2024-08-20', N'Female', N'555-776-2638', N'1210 Church Street, Georgetown'),
(N'478-46-3584', 2, N'Elizabeth Thompson', '1969-09-23', N'Female', N'555-509-9666', N'138 Church Street, Clinton'),
(N'860-80-3546', 1, N'Linda Rodriguez', '1991-05-20', N'Female', N'555-415-6617', N'3345 River Road, Bristol'),
(N'533-45-1722', NULL, N'Gary Brown', '2025-06-25', N'Male', N'555-333-5291', N'2657 Spring Street, Bristol'),
(N'807-29-9938', NULL, N'Donna Smith', '2021-06-19', N'Female', N'555-765-3426', N'7051 Pine Road, Springfield'),
(N'798-41-2684', 2, N'Gary Williams', '1980-09-28', N'Male', N'555-616-3532', N'3888 Birch Boulevard, Franklin'),
(N'854-52-7745', NULL, N'Cynthia Clark', '1940-12-26', N'Female', N'555-454-5371', N'2618 Elm Drive, Arlington'),
(N'458-49-4728', 4, N'Sharon Walker', '1997-01-22', N'Female', N'555-397-7528', N'5388 River Road, Greenville'),
(N'509-96-9785', 5, N'Jason Moore', '1983-01-04', N'Male', N'555-467-3925', N'9522 River Road, Springfield'),
(N'546-87-9379', 3, N'Anthony Thompson', '2011-07-19', N'Male', N'555-394-5173', N'737 Chestnut Street, Springfield'),
(N'472-65-2146', 2, N'Rebecca Wright', '1940-06-20', N'Female', N'555-521-3041', N'4930 Washington Street, Clinton'),
(N'230-34-7888', 5, N'Nancy Sanchez', '1940-07-22', N'Female', N'555-966-3851', N'9334 Highland Avenue, Arlington'),
(N'904-84-6279', 4, N'Mary Martin', '1966-08-15', N'Female', N'555-891-4501', N'8385 Franklin Avenue, Franklin'),
(N'390-75-6491', 1, N'Rebecca Mitchell', '2014-04-22', N'Female', N'555-517-4680', N'3272 Pine Road, Springfield'),
(N'566-63-4185', 1, N'Paul Flores', '1934-12-13', N'Male', N'555-706-7547', N'4007 Pine Road, Ashland'),
(N'897-64-4585', 1, N'Cynthia Carter', '2003-12-17', N'Female', N'555-675-1822', N'9142 Sunset Boulevard, Oakland'),
(N'672-86-6198', 5, N'Sandra Rodriguez', '1969-10-27', N'Female', N'555-936-9270', N'7001 Church Street, Salem'),
(N'960-91-5543', 2, N'Deborah Walker', '1959-08-21', N'Female', N'555-444-5499', N'7216 Cedar Lane, Dover'),
(N'182-27-3471', 5, N'Thomas Perez', '1996-07-23', N'Male', N'555-356-4505', N'1062 Chestnut Street, Arlington'),
(N'952-63-7381', NULL, N'Mark Clark', '1951-12-01', N'Male', N'555-983-7232', N'7824 Maple Street, Madison'),
(N'919-87-4613', 5, N'Matthew Clark', '1963-04-09', N'Male', N'555-646-8956', N'485 Main Street, Madison'),
(N'230-89-9751', 4, N'Rebecca Sanchez', '2022-07-19', N'Female', N'555-777-1444', N'1385 Chestnut Street, Fairview'),
(N'316-68-6355', 3, N'Barbara Brown', '1982-07-09', N'Female', N'555-970-7906', N'4143 Cedar Lane, Salem'),
(N'329-93-2124', 3, N'Andrew Brown', '1942-01-25', N'Male', N'555-231-5051', N'3276 Maple Street, Manchester'),
(N'323-69-5198', 5, N'David Walker', '1978-03-20', N'Male', N'555-821-2876', N'2693 Highland Avenue, Riverside'),
(N'506-35-2245', 4, N'Kathleen Martin', '1950-12-27', N'Female', N'555-842-4978', N'1679 Highland Avenue, Greenville'),
(N'901-15-6688', 5, N'Rebecca Davis', '1957-07-22', N'Female', N'555-579-2129', N'8299 Lakeview Drive, Springfield'),
(N'470-91-8532', NULL, N'Laura Young', '1935-03-14', N'Female', N'555-380-9548', N'4435 Meadow Lane, Franklin'),
(N'374-51-5022', 5, N'Stephanie Walker', '2014-05-15', N'Female', N'555-449-8613', N'9346 Meadow Lane, Ashland');

GO


-- ============================================================
-- 2b. MEDICAL RECORDS
-- ============================================================

SET IDENTITY_INSERT [medicalrecord] ON;
INSERT INTO [medicalrecord] ([id], [patientID], [preMedicalRecord], [predrugconsumption], [smokingHistory], [weight], [height], [bloodpressure]) VALUES
(1, N'242-23-9935', N'Mild osteoarthritis', N'Metformin twice daily', N'Current smoker, 1 pack/day', 71.5, 151.3, N'125/70'),
(2, N'529-38-8359', N'Previous appendectomy in 2018', N'Low-dose aspirin daily', N'Never smoked', 97.5, 165.3, N'143/87'),
(3, N'489-22-6881', N'Seasonal allergies', N'Multivitamins only', N'Never smoked', 80.0, 158.6, N'120/88'),
(4, N'982-56-4150', N'Mild osteoarthritis', N'Multivitamins only', N'Never smoked', 95.0, 181.1, N'146/87'),
(5, N'266-57-6820', N'Previous appendectomy in 2018', N'Statin therapy', N'Occasional social smoker', 53.8, 160.0, N'149/72'),
(6, N'324-97-6313', N'History of migraine', N'Statin therapy', N'Former smoker, quit 2 years ago', 82.3, 165.5, N'152/82'),
(7, N'505-92-8517', N'Hypothyroidism, on medication', N'Metformin twice daily', N'Current smoker, 1 pack/day', 76.1, 163.8, N'119/68'),
(8, N'621-73-2489', N'Type 2 diabetes, diet controlled', N'Metformin twice daily', N'Former smoker, quit 10 years ago', 55.4, 174.1, N'153/87'),
(9, N'981-11-2876', N'Previous fracture of left arm', N'Inhaler as needed', N'Never smoked', 93.8, 162.4, N'142/89'),
(10, N'612-32-9317', N'Previous appendectomy in 2018', N'None', N'Former smoker, quit 2 years ago', 99.6, 163.3, N'128/70'),
(11, N'100-86-6310', N'Previous appendectomy in 2018', N'Daily antihypertensive medication', N'Former smoker, quit 2 years ago', 81.1, 162.3, N'108/82'),
(12, N'878-78-3060', N'Previous appendectomy in 2018', N'Multivitamins only', N'Occasional social smoker', 101.8, 172.1, N'105/83'),
(13, N'830-49-7537', N'Mild osteoarthritis', N'Occasional over-the-counter pain relievers', N'Never smoked', 75.3, 158.3, N'108/73'),
(14, N'702-38-1117', N'No significant past medical history', N'Daily antihypertensive medication', N'Former smoker, quit 10 years ago', 72.8, 153.3, N'145/86'),
(15, N'319-79-3167', N'Hypertension diagnosed 5 years ago', N'Low-dose aspirin daily', N'Occasional social smoker', 98.3, 192.7, N'110/72'),
(16, N'578-16-2612', N'Previous fracture of left arm', N'None reported', N'Occasional social smoker', 85.6, 185.6, N'119/89'),
(17, N'355-19-8260', N'Previous appendectomy in 2018', N'None', N'Never smoked', 104.3, 163.4, N'142/78'),
(18, N'318-61-1960', N'No known chronic conditions', N'Metformin twice daily', N'Current smoker, 1 pack/day', 107.5, 154.5, N'153/71'),
(19, N'258-34-5861', N'Hypertension diagnosed 5 years ago', N'Daily antihypertensive medication', N'Never smoked', 88.9, 157.1, N'116/82'),
(20, N'261-17-9320', N'No significant past medical history', N'Metformin twice daily', N'Current smoker, 1 pack/day', 73.3, 181.0, N'135/74'),
(21, N'734-20-7868', N'No known chronic conditions', N'Metformin twice daily', N'Current smoker, 1 pack/day', 91.8, 181.6, N'134/67'),
(22, N'568-50-2188', N'Asthma since childhood', N'None reported', N'Never smoked', 96.8, 178.1, N'147/90'),
(23, N'478-46-3584', N'Type 2 diabetes, diet controlled', N'Occasional over-the-counter pain relievers', N'Never smoked', 81.8, 179.1, N'122/91'),
(24, N'860-80-3546', N'Family history of heart disease', N'Inhaler as needed', N'Occasional social smoker', 58.3, 163.8, N'152/91'),
(25, N'533-45-1722', N'Previous appendectomy in 2018', N'Low-dose aspirin daily', N'Never smoked', 55.7, 181.0, N'149/77'),
(26, N'807-29-9938', N'Seasonal allergies', N'Statin therapy', N'Never smoked', 78.6, 153.6, N'107/93'),
(27, N'798-41-2684', N'Family history of heart disease', N'None', N'Former smoker, quit 2 years ago', 63.5, 154.1, N'148/91'),
(28, N'854-52-7745', N'Type 2 diabetes, diet controlled', N'Multivitamins only', N'Never smoked', 98.9, 175.9, N'153/89'),
(29, N'458-49-4728', N'Seasonal allergies', N'Multivitamins only', N'Never smoked', 88.4, 191.2, N'116/83'),
(30, N'509-96-9785', N'Hypertension diagnosed 5 years ago', N'Daily antihypertensive medication', N'Current smoker, 1 pack/day', 77.1, 168.4, N'125/86'),
(31, N'546-87-9379', N'Seasonal allergies', N'Low-dose aspirin daily', N'Never smoked', 73.5, 172.3, N'147/95'),
(32, N'472-65-2146', N'History of kidney stones', N'None reported', N'Never smoked', 76.2, 164.2, N'125/68'),
(33, N'230-34-7888', N'Seasonal allergies', N'None', N'Former smoker, quit 10 years ago', 99.1, 150.1, N'139/79'),
(34, N'904-84-6279', N'Mild osteoarthritis', N'None', N'Former smoker, quit 10 years ago', 80.1, 178.0, N'136/85'),
(35, N'390-75-6491', N'Hypothyroidism, on medication', N'Multivitamins only', N'Never smoked', 64.6, 155.9, N'123/79'),
(36, N'566-63-4185', N'Type 2 diabetes, diet controlled', N'Inhaler as needed', N'Never smoked', 49.8, 178.4, N'120/87'),
(37, N'897-64-4585', N'Hypertension diagnosed 5 years ago', N'Multivitamins only', N'Never smoked', 48.8, 168.4, N'119/91'),
(38, N'672-86-6198', N'Previous fracture of left arm', N'Inhaler as needed', N'Occasional social smoker', 88.2, 156.9, N'150/74'),
(39, N'960-91-5543', N'Previous fracture of left arm', N'Daily antihypertensive medication', N'Occasional social smoker', 99.8, 194.1, N'120/79'),
(40, N'182-27-3471', N'Type 2 diabetes, diet controlled', N'Occasional over-the-counter pain relievers', N'Current smoker, 1 pack/day', 59.8, 177.0, N'152/93'),
(41, N'952-63-7381', N'History of kidney stones', N'Low-dose aspirin daily', N'Current smoker, 1 pack/day', 95.9, 188.4, N'126/94'),
(42, N'919-87-4613', N'Family history of heart disease', N'Multivitamins only', N'Former smoker, quit 10 years ago', 98.9, 162.7, N'124/91'),
(43, N'230-89-9751', N'History of kidney stones', N'Low-dose aspirin daily', N'Occasional social smoker', 75.7, 171.8, N'126/82'),
(44, N'316-68-6355', N'Asthma since childhood', N'None reported', N'Former smoker, quit 10 years ago', 76.2, 164.5, N'117/87'),
(45, N'329-93-2124', N'Mild osteoarthritis', N'None reported', N'Occasional social smoker', 101.1, 168.5, N'125/88'),
(46, N'323-69-5198', N'Mild osteoarthritis', N'None', N'Former smoker, quit 10 years ago', 109.3, 185.7, N'146/69'),
(47, N'506-35-2245', N'Mild osteoarthritis', N'Occasional over-the-counter pain relievers', N'Never smoked', 79.1, 176.6, N'111/92'),
(48, N'901-15-6688', N'No known chronic conditions', N'Daily antihypertensive medication', N'Never smoked', 104.4, 150.7, N'114/78'),
(49, N'470-91-8532', N'Hypothyroidism, on medication', N'None reported', N'Former smoker, quit 2 years ago', 77.1, 193.6, N'126/84'),
(50, N'374-51-5022', N'Previous fracture of left arm', N'None reported', N'Current smoker, 1 pack/day', 53.0, 164.8, N'148/92');
SET IDENTITY_INSERT [medicalrecord] OFF;


GO


-- ============================================================
-- 3. EMPLOYEES
-- ============================================================

SET IDENTITY_INSERT [employee] ON;
INSERT INTO [employee] ([id], [departmentID], [name], [contractType], [phone], [role], [specialization], [medicalsystemID]) VALUES
(1, 2, N'Dr. Cynthia Carter', N'Contract', N'555-236-2121', N'Doctor', N'Critical Care', N'MED-10001'),
(2, 3, N'Dr. Edward Jackson', N'Contract', N'555-292-8110', N'Doctor', N'Internal Medicine', N'MED-10002'),
(3, 4, N'Dr. Stephanie Green', N'Full-Time', N'555-654-3725', N'Doctor', N'Endocrinology', N'MED-10003'),
(4, 5, N'Dr. Cynthia Johnson', N'Part-Time', N'555-257-5806', N'Doctor', N'Cardiology', N'MED-10004'),
(5, 6, N'Dr. Anthony Martinez', N'Contract', N'555-621-3950', N'Doctor', N'Internal Medicine', N'MED-10005'),
(6, 8, N'Dr. John Flores', N'Contract', N'555-899-4945', N'Doctor', N'Obstetrics & Gynecology', N'MED-10006'),
(7, 1, N'Dr. Kenneth Martinez', N'Part-Time', N'555-853-5161', N'Doctor', N'Internal Medicine', N'MED-10007'),
(8, 7, N'Dr. Edward Smith', N'Part-Time', N'555-893-9955', N'Doctor', N'Critical Care', N'MED-10008'),
(9, 2, N'Dr. Mark Thompson', N'Part-Time', N'555-854-7951', N'Doctor', N'Pulmonology', N'MED-10009'),
(10, 3, N'Dr. Sandra Martin', N'Part-Time', N'555-694-2747', N'Doctor', N'Internal Medicine', N'MED-10010'),
(11, 4, N'Dr. Kenneth Thompson', N'Part-Time', N'555-916-5837', N'Doctor', N'Pulmonology', N'MED-10011'),
(12, 5, N'Dr. Ryan Nelson', N'Part-Time', N'555-208-1803', N'Doctor', N'Obstetrics & Gynecology', N'MED-10012'),
(13, 6, N'Dr. Deborah Young', N'Full-Time', N'555-821-6772', N'Doctor', N'Orthopedics', N'MED-10013'),
(14, 1, N'Dr. Richard Flores', N'Contract', N'555-973-3240', N'Doctor', N'Orthopedics', N'MED-10014'),
(15, 7, N'Dr. Cynthia Green', N'Full-Time', N'555-516-8222', N'Doctor', N'Nephrology', N'MED-10015'),
(16, 1, N'Daniel Campbell', N'Full-Time', N'555-292-5835', N'Nurse', NULL, N'MED-10016'),
(17, 2, N'Barbara Gonzalez', N'Full-Time', N'555-752-6994', N'Nurse', NULL, N'MED-10017'),
(18, 3, N'Sarah Hernandez', N'Part-Time', N'555-693-5835', N'Nurse', NULL, N'MED-10018'),
(19, 4, N'Sandra Jones', N'Full-Time', N'555-972-4696', N'Nurse', NULL, N'MED-10019'),
(20, 5, N'Rebecca Scott', N'Part-Time', N'555-292-7464', N'Nurse', NULL, N'MED-10020'),
(21, 6, N'Linda Robinson', N'Part-Time', N'555-888-5295', N'Nurse', NULL, N'MED-10021'),
(22, 7, N'Carol White', N'Full-Time', N'555-891-4830', N'Nurse', NULL, N'MED-10022'),
(23, 8, N'Gary Scott', N'Part-Time', N'555-824-4626', N'Nurse', NULL, N'MED-10023'),
(24, 1, N'Sandra Hall', N'Part-Time', N'555-864-7689', N'Nurse', NULL, N'MED-10024'),
(25, 2, N'Robert Martin', N'Part-Time', N'555-318-2592', N'Nurse', NULL, N'MED-10025'),
(26, 3, N'Elizabeth Harris', N'Part-Time', N'555-579-9850', N'Nurse', NULL, N'MED-10026'),
(27, 4, N'Deborah Martinez', N'Part-Time', N'555-870-2622', N'Nurse', NULL, N'MED-10027'),
(28, 5, N'Sarah Williams', N'Contract', N'555-579-4559', N'Nurse', NULL, N'MED-10028'),
(29, 6, N'Jessica White', N'Full-Time', N'555-902-7018', N'Nurse', NULL, N'MED-10029'),
(30, 7, N'Carol Thompson', N'Full-Time', N'555-607-5520', N'Nurse', NULL, N'MED-10030'),
(31, 8, N'Sharon Robinson', N'Full-Time', N'555-878-4475', N'Nurse', NULL, N'MED-10031'),
(32, 1, N'Patricia Perez', N'Full-Time', N'555-328-4362', N'Nurse', NULL, N'MED-10032'),
(33, 2, N'Donna Wilson', N'Contract', N'555-421-4817', N'Nurse', NULL, N'MED-10033'),
(34, 3, N'Rebecca Hill', N'Full-Time', N'555-483-3370', N'Nurse', NULL, N'MED-10034'),
(35, 4, N'Rebecca Lopez', N'Full-Time', N'555-876-1422', N'Nurse', NULL, N'MED-10035'),
(36, NULL, N'Jeffrey Thomas', N'Contract', N'555-531-1258', N'Pharmacist', NULL, N'MED-10036'),
(37, NULL, N'Robert Rodriguez', N'Contract', N'555-631-9619', N'Pharmacist', NULL, N'MED-10037'),
(38, NULL, N'John Walker', N'Part-Time', N'555-996-6931', N'Pharmacist', NULL, N'MED-10038'),
(39, NULL, N'Linda Lewis', N'Contract', N'555-426-1710', N'LabTech', NULL, N'MED-10039'),
(40, NULL, N'Kathleen Nelson', N'Contract', N'555-508-8504', N'LabTech', NULL, N'MED-10040'),
(41, NULL, N'Mary Brown', N'Part-Time', N'555-611-7984', N'LabTech', NULL, N'MED-10041'),
(42, NULL, N'Ashley Rivera', N'Part-Time', N'555-275-2323', N'Reception', NULL, N'MED-10042'),
(43, NULL, N'David Jones', N'Full-Time', N'555-481-9984', N'Reception', NULL, N'MED-10043'),
(44, NULL, N'Margaret Hill', N'Contract', N'555-501-8433', N'Reception', NULL, N'MED-10044'),
(45, NULL, N'Betty Miller', N'Contract', N'555-317-4522', N'Manager', NULL, N'MED-10045');
SET IDENTITY_INSERT [employee] OFF;


GO


-- ============================================================
-- 3b. DOCTORS
-- ============================================================

INSERT INTO [doctor] ([employeeID], [specialization], [medicalLicenseNo]) VALUES
(1, N'Critical Care', N'LIC-20001'),
(2, N'Internal Medicine', N'LIC-20002'),
(3, N'Endocrinology', N'LIC-20003'),
(4, N'Cardiology', N'LIC-20004'),
(5, N'Internal Medicine', N'LIC-20005'),
(6, N'Obstetrics & Gynecology', N'LIC-20006'),
(7, N'Internal Medicine', N'LIC-20007'),
(8, N'Critical Care', N'LIC-20008'),
(9, N'Pulmonology', N'LIC-20009'),
(10, N'Internal Medicine', N'LIC-20010'),
(11, N'Pulmonology', N'LIC-20011'),
(12, N'Obstetrics & Gynecology', N'LIC-20012'),
(13, N'Orthopedics', N'LIC-20013'),
(14, N'Orthopedics', N'LIC-20014'),
(15, N'Nephrology', N'LIC-20015');

GO


-- ============================================================
-- 3c. NURSES
-- ============================================================

INSERT INTO [nurse] ([employeeID], [grade]) VALUES
(16, N'Charge Nurse'),
(17, N'Licensed Practical Nurse'),
(18, N'Charge Nurse'),
(19, N'Nurse Practitioner'),
(20, N'Registered Nurse'),
(21, N'Licensed Practical Nurse'),
(22, N'Nurse Practitioner'),
(23, N'Registered Nurse'),
(24, N'Registered Nurse'),
(25, N'Senior Registered Nurse'),
(26, N'Nurse Practitioner'),
(27, N'Nurse Practitioner'),
(28, N'Nurse Practitioner'),
(29, N'Licensed Practical Nurse'),
(30, N'Senior Registered Nurse'),
(31, N'Licensed Practical Nurse'),
(32, N'Registered Nurse'),
(33, N'Charge Nurse'),
(34, N'Senior Registered Nurse'),
(35, N'Senior Registered Nurse');

GO


-- ============================================================
-- 3d. ADMIN STAFF
-- ============================================================

INSERT INTO [adminstaff] ([employeeID], [role]) VALUES
(36, N'Pharmacist'),
(37, N'Pharmacist'),
(38, N'Pharmacist'),
(39, N'lab_tech'),
(40, N'lab_tech'),
(41, N'lab_tech'),
(42, N'Reception'),
(43, N'Reception'),
(44, N'Reception'),
(45, N'Manager');

GO


-- ============================================================
-- 4. SHIFTS
-- ============================================================

SET IDENTITY_INSERT [shift] ON;
INSERT INTO [shift] ([id], [shiftDate], [startTime], [endTime], [shiftType]) VALUES
(1, '2026-06-22', '07:00:00', '15:00:00', N'Morning'),
(2, '2026-06-22', '15:00:00', '23:00:00', N'Evening'),
(3, '2026-06-22', '23:00:00', '07:00:00', N'Night'),
(4, '2026-06-23', '07:00:00', '15:00:00', N'Morning'),
(5, '2026-06-23', '15:00:00', '23:00:00', N'Evening'),
(6, '2026-06-23', '23:00:00', '07:00:00', N'Night'),
(7, '2026-06-24', '07:00:00', '15:00:00', N'Morning'),
(8, '2026-06-24', '15:00:00', '23:00:00', N'Evening'),
(9, '2026-06-24', '23:00:00', '07:00:00', N'Night'),
(10, '2026-06-25', '07:00:00', '15:00:00', N'Morning'),
(11, '2026-06-25', '15:00:00', '23:00:00', N'Evening'),
(12, '2026-06-25', '23:00:00', '07:00:00', N'Night'),
(13, '2026-06-26', '07:00:00', '15:00:00', N'Morning'),
(14, '2026-06-26', '15:00:00', '23:00:00', N'Evening'),
(15, '2026-06-26', '23:00:00', '07:00:00', N'Night'),
(16, '2026-06-27', '07:00:00', '15:00:00', N'Morning'),
(17, '2026-06-27', '15:00:00', '23:00:00', N'Evening'),
(18, '2026-06-27', '23:00:00', '07:00:00', N'Night'),
(19, '2026-06-28', '07:00:00', '15:00:00', N'Morning'),
(20, '2026-06-28', '15:00:00', '23:00:00', N'Evening'),
(21, '2026-06-28', '23:00:00', '07:00:00', N'Night'),
(22, '2026-06-29', '07:00:00', '15:00:00', N'Morning'),
(23, '2026-06-29', '15:00:00', '23:00:00', N'Evening'),
(24, '2026-06-29', '23:00:00', '07:00:00', N'Night'),
(25, '2026-06-30', '07:00:00', '15:00:00', N'Morning'),
(26, '2026-06-30', '15:00:00', '23:00:00', N'Evening'),
(27, '2026-06-30', '23:00:00', '07:00:00', N'Night'),
(28, '2026-07-01', '07:00:00', '15:00:00', N'Morning'),
(29, '2026-07-01', '15:00:00', '23:00:00', N'Evening'),
(30, '2026-07-01', '23:00:00', '07:00:00', N'Night'),
(31, '2026-07-02', '07:00:00', '15:00:00', N'Morning'),
(32, '2026-07-02', '15:00:00', '23:00:00', N'Evening'),
(33, '2026-07-02', '23:00:00', '07:00:00', N'Night'),
(34, '2026-07-03', '07:00:00', '15:00:00', N'Morning'),
(35, '2026-07-03', '15:00:00', '23:00:00', N'Evening'),
(36, '2026-07-03', '23:00:00', '07:00:00', N'Night'),
(37, '2026-07-04', '07:00:00', '15:00:00', N'Morning'),
(38, '2026-07-04', '15:00:00', '23:00:00', N'Evening'),
(39, '2026-07-04', '23:00:00', '07:00:00', N'Night'),
(40, '2026-07-05', '07:00:00', '15:00:00', N'Morning'),
(41, '2026-07-05', '15:00:00', '23:00:00', N'Evening'),
(42, '2026-07-05', '23:00:00', '07:00:00', N'Night');
SET IDENTITY_INSERT [shift] OFF;


GO


-- ============================================================
-- 4b. EMPLOYEE SHIFT ASSIGNMENTS
-- ============================================================

SET IDENTITY_INSERT [employeeshift] ON;
INSERT INTO [employeeshift] ([id], [employeeID], [shiftID]) VALUES
(1, 1, 29),
(2, 1, 15),
(3, 1, 27),
(4, 1, 22),
(5, 1, 30),
(6, 2, 27),
(7, 2, 7),
(8, 2, 21),
(9, 2, 28),
(10, 2, 17),
(11, 3, 10),
(12, 3, 31),
(13, 3, 5),
(14, 3, 6),
(15, 3, 28),
(16, 4, 24),
(17, 4, 9),
(18, 4, 36),
(19, 4, 4),
(20, 5, 36),
(21, 5, 42),
(22, 5, 22),
(23, 5, 8),
(24, 5, 27),
(25, 5, 23),
(26, 6, 28),
(27, 6, 4),
(28, 6, 19),
(29, 6, 39),
(30, 6, 20),
(31, 6, 23),
(32, 7, 37),
(33, 7, 33),
(34, 7, 14),
(35, 7, 10),
(36, 8, 31),
(37, 8, 15),
(38, 8, 7),
(39, 8, 23),
(40, 8, 36),
(41, 8, 24),
(42, 9, 18),
(43, 9, 37),
(44, 9, 15),
(45, 9, 28),
(46, 10, 40),
(47, 10, 42),
(48, 10, 36),
(49, 10, 2),
(50, 10, 18),
(51, 10, 39),
(52, 11, 18),
(53, 11, 20),
(54, 11, 22),
(55, 11, 23),
(56, 12, 12),
(57, 12, 10),
(58, 12, 37),
(59, 12, 26),
(60, 13, 10),
(61, 13, 41),
(62, 13, 2),
(63, 13, 6),
(64, 14, 34),
(65, 14, 14),
(66, 14, 25),
(67, 14, 27),
(68, 14, 30),
(69, 14, 22),
(70, 15, 24),
(71, 15, 20),
(72, 15, 21),
(73, 15, 37),
(74, 16, 6),
(75, 16, 4),
(76, 16, 10),
(77, 16, 11),
(78, 16, 41),
(79, 16, 42),
(80, 17, 29),
(81, 17, 28),
(82, 17, 32),
(83, 17, 39),
(84, 17, 27),
(85, 18, 14),
(86, 18, 33),
(87, 18, 8),
(88, 18, 23),
(89, 18, 28),
(90, 19, 19),
(91, 19, 38),
(92, 19, 32),
(93, 19, 34),
(94, 20, 20),
(95, 20, 3),
(96, 20, 15),
(97, 20, 26),
(98, 20, 4),
(99, 20, 1),
(100, 21, 20);
INSERT INTO [employeeshift] ([id], [employeeID], [shiftID]) VALUES
(101, 21, 14),
(102, 21, 9),
(103, 21, 17),
(104, 22, 21),
(105, 22, 8),
(106, 22, 1),
(107, 22, 32),
(108, 22, 28),
(109, 23, 9),
(110, 23, 25),
(111, 23, 35),
(112, 23, 15),
(113, 24, 36),
(114, 24, 23),
(115, 24, 5),
(116, 24, 26),
(117, 24, 3),
(118, 24, 28),
(119, 25, 30),
(120, 25, 5),
(121, 25, 21),
(122, 25, 37),
(123, 26, 37),
(124, 26, 26),
(125, 26, 41),
(126, 26, 27),
(127, 26, 19),
(128, 27, 26),
(129, 27, 2),
(130, 27, 21),
(131, 27, 11),
(132, 28, 30),
(133, 28, 24),
(134, 28, 6),
(135, 28, 28),
(136, 28, 7),
(137, 28, 16),
(138, 29, 38),
(139, 29, 26),
(140, 29, 34),
(141, 29, 6),
(142, 29, 20),
(143, 30, 22),
(144, 30, 15),
(145, 30, 42),
(146, 30, 11),
(147, 30, 5),
(148, 30, 33),
(149, 31, 8),
(150, 31, 34),
(151, 31, 33),
(152, 31, 13),
(153, 31, 23),
(154, 31, 38),
(155, 32, 42),
(156, 32, 10),
(157, 32, 16),
(158, 32, 7),
(159, 32, 41),
(160, 32, 17),
(161, 33, 12),
(162, 33, 39),
(163, 33, 10),
(164, 33, 42),
(165, 34, 12),
(166, 34, 41),
(167, 34, 32),
(168, 34, 30),
(169, 35, 38),
(170, 35, 29),
(171, 35, 37),
(172, 35, 21),
(173, 35, 39),
(174, 35, 10);
SET IDENTITY_INSERT [employeeshift] OFF;


GO


-- ============================================================
-- 5. BEDS (initial state: Free)
-- ============================================================

SET IDENTITY_INSERT [bed] ON;
INSERT INTO [bed] ([id], [departmentID], [status], [room]) VALUES
(1, 1, N'Free', N'101'),
(2, 1, N'Free', N'102'),
(3, 1, N'Free', N'103'),
(4, 1, N'Free', N'104'),
(5, 1, N'Free', N'105'),
(6, 2, N'Free', N'201'),
(7, 2, N'Free', N'202'),
(8, 2, N'Free', N'203'),
(9, 2, N'Free', N'204'),
(10, 2, N'Free', N'205'),
(11, 3, N'Free', N'301'),
(12, 3, N'Free', N'302'),
(13, 3, N'Free', N'303'),
(14, 3, N'Free', N'304'),
(15, 3, N'Free', N'305'),
(16, 4, N'Free', N'401'),
(17, 4, N'Free', N'402'),
(18, 4, N'Free', N'403'),
(19, 4, N'Free', N'404'),
(20, 4, N'Free', N'405'),
(21, 5, N'Free', N'501'),
(22, 5, N'Free', N'502'),
(23, 5, N'Free', N'503'),
(24, 5, N'Free', N'504'),
(25, 5, N'Free', N'505'),
(26, 6, N'Free', N'601'),
(27, 6, N'Free', N'602'),
(28, 6, N'Free', N'603'),
(29, 6, N'Free', N'604'),
(30, 6, N'Free', N'605'),
(31, 7, N'Free', N'701'),
(32, 7, N'Free', N'702'),
(33, 7, N'Free', N'703'),
(34, 7, N'Free', N'704'),
(35, 7, N'Free', N'705'),
(36, 8, N'Free', N'801'),
(37, 8, N'Free', N'802'),
(38, 8, N'Free', N'803'),
(39, 8, N'Free', N'804'),
(40, 8, N'Free', N'805');
SET IDENTITY_INSERT [bed] OFF;


GO


-- ============================================================
-- 6. APPOINTMENTS (ids auto-assigned in order by the INSTEAD OF trigger; do not use IDENTITY_INSERT here)
-- ============================================================

INSERT INTO [appointment] ([employeeID], [patientID], [departmentID], [date], [time], [status], [appointment_type]) VALUES
(8, N'266-57-6820', 7, '2026-07-17', '15:30:00', N'Scheduled', N'InPerson'),
(6, N'230-34-7888', 8, '2026-05-27', '12:45:00', N'Completed', N'InPerson'),
(14, N'258-34-5861', 1, '2026-05-27', '09:45:00', N'Completed', N'InPerson'),
(13, N'901-15-6688', 6, '2026-05-23', '15:15:00', N'Completed', N'InPerson'),
(3, N'982-56-4150', 4, '2026-07-14', '09:30:00', N'Rescheduled', N'InPerson'),
(11, N'878-78-3060', 4, '2026-05-23', '11:45:00', N'Rescheduled', N'InPerson'),
(10, N'100-86-6310', 3, '2026-07-03', '13:30:00', N'Completed', N'InPerson'),
(11, N'960-91-5543', 4, '2026-05-24', '13:00:00', N'Completed', N'InPerson'),
(7, N'258-34-5861', 1, '2026-06-19', '10:30:00', N'Completed', N'InPerson'),
(15, N'478-46-3584', 7, '2026-06-26', '14:15:00', N'Completed', N'Online'),
(5, N'566-63-4185', 6, '2026-07-05', '13:15:00', N'Completed', N'InPerson'),
(12, N'316-68-6355', 5, '2026-07-24', '09:45:00', N'Scheduled', N'InPerson'),
(5, N'878-78-3060', 6, '2026-06-14', '13:45:00', N'Completed', N'Online'),
(3, N'266-57-6820', 4, '2026-06-24', '09:00:00', N'Completed', N'Online'),
(10, N'981-11-2876', 3, '2026-07-05', '10:15:00', N'Completed', N'InPerson'),
(10, N'100-86-6310', 3, '2026-07-13', '08:45:00', N'Scheduled', N'InPerson'),
(8, N'182-27-3471', 7, '2026-06-23', '15:15:00', N'Completed', N'InPerson'),
(13, N'546-87-9379', 6, '2026-06-11', '13:45:00', N'Completed', N'InPerson'),
(7, N'230-34-7888', 1, '2026-07-24', '14:15:00', N'Scheduled', N'InPerson'),
(3, N'355-19-8260', 4, '2026-05-24', '15:30:00', N'Completed', N'InPerson'),
(14, N'904-84-6279', 1, '2026-06-02', '12:00:00', N'Cancelled', N'InPerson'),
(15, N'230-34-7888', 7, '2026-06-05', '14:00:00', N'Rescheduled', N'InPerson'),
(8, N'478-46-3584', 7, '2026-05-21', '14:00:00', N'Completed', N'InPerson'),
(7, N'324-97-6313', 1, '2026-07-04', '11:00:00', N'Completed', N'InPerson'),
(12, N'919-87-4613', 5, '2026-06-29', '10:15:00', N'Completed', N'Online'),
(8, N'329-93-2124', 7, '2026-06-04', '15:45:00', N'Completed', N'Online'),
(1, N'355-19-8260', 2, '2026-06-14', '10:45:00', N'Completed', N'InPerson'),
(5, N'621-73-2489', 6, '2026-05-24', '11:45:00', N'Completed', N'InPerson'),
(2, N'621-73-2489', 3, '2026-07-20', '16:00:00', N'Scheduled', N'InPerson'),
(12, N'612-32-9317', 5, '2026-06-24', '14:00:00', N'Completed', N'InPerson'),
(7, N'878-78-3060', 1, '2026-05-28', '16:30:00', N'Completed', N'InPerson'),
(9, N'230-34-7888', 2, '2026-07-27', '08:45:00', N'Cancelled', N'InPerson'),
(7, N'860-80-3546', 1, '2026-06-19', '08:30:00', N'Cancelled', N'InPerson'),
(12, N'230-89-9751', 5, '2026-05-31', '13:15:00', N'Completed', N'InPerson'),
(14, N'919-87-4613', 1, '2026-06-09', '15:45:00', N'Completed', N'InPerson'),
(2, N'323-69-5198', 3, '2026-07-15', '08:30:00', N'Scheduled', N'InPerson'),
(15, N'489-22-6881', 7, '2026-06-27', '12:45:00', N'Rescheduled', N'InPerson'),
(5, N'489-22-6881', 6, '2026-06-11', '12:30:00', N'Cancelled', N'InPerson'),
(11, N'568-50-2188', 4, '2026-06-21', '09:30:00', N'Completed', N'InPerson'),
(8, N'533-45-1722', 7, '2026-06-30', '10:45:00', N'Completed', N'InPerson'),
(13, N'904-84-6279', 6, '2026-06-21', '09:45:00', N'Completed', N'InPerson'),
(14, N'878-78-3060', 1, '2026-07-26', '12:30:00', N'Scheduled', N'InPerson'),
(5, N'261-17-9320', 6, '2026-07-14', '14:15:00', N'Scheduled', N'InPerson'),
(1, N'506-35-2245', 2, '2026-07-02', '14:30:00', N'Completed', N'InPerson'),
(1, N'266-57-6820', 2, '2026-07-08', '13:15:00', N'Rescheduled', N'InPerson'),
(10, N'316-68-6355', 3, '2026-07-13', '08:15:00', N'Scheduled', N'InPerson'),
(6, N'860-80-3546', 8, '2026-07-06', '08:15:00', N'Completed', N'Online'),
(6, N'458-49-4728', 8, '2026-05-27', '10:30:00', N'Completed', N'InPerson'),
(4, N'621-73-2489', 5, '2026-05-21', '10:45:00', N'Completed', N'Online'),
(2, N'355-19-8260', 3, '2026-06-20', '15:15:00', N'Rescheduled', N'InPerson'),
(15, N'472-65-2146', 7, '2026-06-12', '09:15:00', N'Cancelled', N'InPerson'),
(15, N'323-69-5198', 7, '2026-07-13', '09:30:00', N'Scheduled', N'InPerson'),
(9, N'390-75-6491', 2, '2026-06-24', '12:15:00', N'Completed', N'Online'),
(11, N'878-78-3060', 4, '2026-07-03', '16:15:00', N'Completed', N'InPerson'),
(3, N'578-16-2612', 4, '2026-07-20', '08:30:00', N'Scheduled', N'InPerson'),
(13, N'566-63-4185', 6, '2026-06-03', '09:00:00', N'Completed', N'Online'),
(12, N'546-87-9379', 5, '2026-07-24', '14:45:00', N'Scheduled', N'InPerson'),
(6, N'919-87-4613', 8, '2026-05-27', '15:45:00', N'Completed', N'InPerson'),
(15, N'374-51-5022', 7, '2026-07-27', '10:15:00', N'Scheduled', N'Online'),
(1, N'621-73-2489', 2, '2026-07-23', '10:30:00', N'Scheduled', N'InPerson'),
(12, N'319-79-3167', 5, '2026-07-01', '16:30:00', N'Cancelled', N'InPerson'),
(11, N'566-63-4185', 4, '2026-06-22', '10:30:00', N'Completed', N'InPerson'),
(11, N'100-86-6310', 4, '2026-06-06', '10:30:00', N'Cancelled', N'InPerson'),
(14, N'529-38-8359', 1, '2026-05-28', '08:30:00', N'Completed', N'InPerson'),
(7, N'182-27-3471', 1, '2026-05-21', '15:30:00', N'Completed', N'InPerson'),
(4, N'316-68-6355', 5, '2026-07-08', '12:45:00', N'Scheduled', N'InPerson'),
(8, N'798-41-2684', 7, '2026-07-18', '15:15:00', N'Scheduled', N'InPerson'),
(14, N'323-69-5198', 1, '2026-06-27', '13:45:00', N'Completed', N'InPerson'),
(9, N'505-92-8517', 2, '2026-06-27', '11:45:00', N'Completed', N'InPerson'),
(3, N'505-92-8517', 4, '2026-05-24', '12:45:00', N'Cancelled', N'InPerson'),
(14, N'100-86-6310', 1, '2026-06-28', '13:15:00', N'Cancelled', N'InPerson'),
(9, N'509-96-9785', 2, '2026-07-20', '12:45:00', N'Scheduled', N'Online'),
(9, N'509-96-9785', 2, '2026-06-17', '11:30:00', N'Completed', N'InPerson'),
(10, N'919-87-4613', 3, '2026-07-17', '12:00:00', N'Scheduled', N'InPerson'),
(15, N'355-19-8260', 7, '2026-07-03', '14:30:00', N'Completed', N'InPerson'),
(9, N'830-49-7537', 2, '2026-07-03', '16:30:00', N'Completed', N'InPerson'),
(13, N'566-63-4185', 6, '2026-06-22', '09:15:00', N'Rescheduled', N'InPerson'),
(13, N'568-50-2188', 6, '2026-07-28', '13:15:00', N'Scheduled', N'InPerson'),
(9, N'489-22-6881', 2, '2026-05-23', '08:15:00', N'Completed', N'InPerson'),
(9, N'509-96-9785', 2, '2026-06-06', '16:15:00', N'Completed', N'InPerson'),
(3, N'807-29-9938', 4, '2026-06-25', '13:45:00', N'Completed', N'InPerson'),
(14, N'529-38-8359', 1, '2026-07-04', '13:00:00', N'Rescheduled', N'InPerson'),
(13, N'506-35-2245', 6, '2026-05-21', '15:30:00', N'Rescheduled', N'InPerson'),
(13, N'672-86-6198', 6, '2026-06-16', '08:45:00', N'Completed', N'InPerson'),
(1, N'897-64-4585', 2, '2026-06-01', '11:00:00', N'Completed', N'InPerson'),
(7, N'329-93-2124', 1, '2026-06-13', '14:45:00', N'Cancelled', N'InPerson'),
(1, N'323-69-5198', 2, '2026-06-04', '16:15:00', N'Completed', N'Online'),
(8, N'904-84-6279', 7, '2026-07-05', '13:15:00', N'Completed', N'InPerson'),
(9, N'478-46-3584', 2, '2026-06-20', '15:15:00', N'Rescheduled', N'InPerson'),
(5, N'319-79-3167', 6, '2026-06-25', '12:15:00', N'Completed', N'InPerson'),
(8, N'478-46-3584', 7, '2026-07-28', '12:30:00', N'Scheduled', N'InPerson'),
(7, N'807-29-9938', 1, '2026-07-01', '10:30:00', N'Completed', N'Online'),
(2, N'478-46-3584', 3, '2026-07-13', '12:45:00', N'Scheduled', N'InPerson'),
(5, N'566-63-4185', 6, '2026-06-21', '10:00:00', N'Completed', N'InPerson'),
(4, N'982-56-4150', 5, '2026-07-24', '11:15:00', N'Scheduled', N'InPerson'),
(12, N'546-87-9379', 5, '2026-05-30', '10:00:00', N'Rescheduled', N'Online'),
(3, N'798-41-2684', 4, '2026-07-17', '15:15:00', N'Scheduled', N'InPerson'),
(5, N'919-87-4613', 6, '2026-05-25', '09:15:00', N'Completed', N'InPerson'),
(15, N'489-22-6881', 7, '2026-06-09', '14:15:00', N'Rescheduled', N'InPerson'),
(14, N'807-29-9938', 1, '2026-07-20', '10:30:00', N'Cancelled', N'InPerson');
INSERT INTO [appointment] ([employeeID], [patientID], [departmentID], [date], [time], [status], [appointment_type]) VALUES
(10, N'960-91-5543', 3, '2026-05-31', '13:30:00', N'Completed', N'InPerson'),
(9, N'472-65-2146', 2, '2026-06-04', '16:45:00', N'Completed', N'InPerson'),
(6, N'100-86-6310', 8, '2026-07-15', '12:15:00', N'Scheduled', N'InPerson'),
(5, N'897-64-4585', 6, '2026-06-11', '10:45:00', N'Cancelled', N'InPerson'),
(2, N'807-29-9938', 3, '2026-05-30', '10:15:00', N'Completed', N'Online'),
(1, N'355-19-8260', 2, '2026-07-06', '11:45:00', N'Cancelled', N'Online'),
(5, N'672-86-6198', 6, '2026-05-19', '12:30:00', N'Completed', N'InPerson'),
(2, N'509-96-9785', 3, '2026-06-26', '10:45:00', N'Completed', N'Online'),
(15, N'323-69-5198', 7, '2026-06-26', '09:30:00', N'Completed', N'InPerson'),
(3, N'546-87-9379', 4, '2026-06-06', '15:30:00', N'Completed', N'InPerson'),
(8, N'470-91-8532', 7, '2026-07-25', '11:15:00', N'Scheduled', N'InPerson'),
(13, N'324-97-6313', 6, '2026-07-24', '15:30:00', N'Scheduled', N'InPerson'),
(1, N'566-63-4185', 2, '2026-07-21', '11:15:00', N'Scheduled', N'Online'),
(8, N'621-73-2489', 7, '2026-06-13', '15:00:00', N'Cancelled', N'InPerson'),
(1, N'509-96-9785', 2, '2026-06-03', '16:45:00', N'Completed', N'InPerson'),
(8, N'316-68-6355', 7, '2026-06-26', '08:45:00', N'Completed', N'InPerson'),
(4, N'672-86-6198', 5, '2026-05-27', '08:45:00', N'Completed', N'InPerson'),
(1, N'266-57-6820', 2, '2026-07-17', '08:30:00', N'Scheduled', N'InPerson'),
(13, N'919-87-4613', 6, '2026-07-10', '13:45:00', N'Scheduled', N'Online'),
(7, N'533-45-1722', 1, '2026-05-28', '16:15:00', N'Completed', N'InPerson'),
(3, N'390-75-6491', 4, '2026-07-07', '16:15:00', N'Scheduled', N'InPerson'),
(1, N'470-91-8532', 2, '2026-05-20', '12:45:00', N'Completed', N'InPerson'),
(9, N'533-45-1722', 2, '2026-06-16', '11:45:00', N'Completed', N'InPerson'),
(15, N'506-35-2245', 7, '2026-06-01', '08:45:00', N'Completed', N'Online'),
(15, N'529-38-8359', 7, '2026-06-17', '11:00:00', N'Completed', N'InPerson'),
(10, N'316-68-6355', 3, '2026-05-24', '11:00:00', N'Completed', N'InPerson'),
(4, N'470-91-8532', 5, '2026-05-25', '10:30:00', N'Completed', N'Online'),
(10, N'734-20-7868', 3, '2026-06-28', '11:30:00', N'Cancelled', N'Online'),
(9, N'319-79-3167', 2, '2026-07-09', '12:30:00', N'Scheduled', N'Online'),
(15, N'901-15-6688', 7, '2026-06-09', '14:45:00', N'Completed', N'InPerson'),
(11, N'230-89-9751', 4, '2026-07-05', '16:30:00', N'Completed', N'InPerson'),
(5, N'533-45-1722', 6, '2026-06-10', '16:45:00', N'Completed', N'InPerson'),
(14, N'323-69-5198', 1, '2026-06-05', '15:00:00', N'Completed', N'Online'),
(9, N'904-84-6279', 2, '2026-06-04', '14:15:00', N'Completed', N'InPerson'),
(2, N'458-49-4728', 3, '2026-07-04', '09:15:00', N'Completed', N'InPerson'),
(10, N'960-91-5543', 3, '2026-05-23', '09:15:00', N'Cancelled', N'InPerson'),
(11, N'566-63-4185', 4, '2026-06-14', '15:15:00', N'Cancelled', N'InPerson'),
(15, N'242-23-9935', 7, '2026-06-14', '11:00:00', N'Completed', N'InPerson'),
(15, N'578-16-2612', 7, '2026-06-13', '14:15:00', N'Completed', N'InPerson'),
(7, N'509-96-9785', 1, '2026-07-25', '13:30:00', N'Scheduled', N'InPerson'),
(8, N'509-96-9785', 7, '2026-05-30', '15:30:00', N'Rescheduled', N'InPerson'),
(7, N'489-22-6881', 1, '2026-06-15', '10:00:00', N'Completed', N'Online'),
(10, N'506-35-2245', 3, '2026-07-10', '12:15:00', N'Scheduled', N'InPerson'),
(10, N'578-16-2612', 3, '2026-07-20', '16:30:00', N'Scheduled', N'InPerson'),
(12, N'919-87-4613', 5, '2026-07-19', '15:15:00', N'Scheduled', N'InPerson'),
(3, N'506-35-2245', 4, '2026-07-26', '15:15:00', N'Cancelled', N'InPerson'),
(11, N'982-56-4150', 4, '2026-07-24', '08:00:00', N'Cancelled', N'InPerson'),
(13, N'242-23-9935', 6, '2026-07-09', '10:15:00', N'Scheduled', N'InPerson'),
(4, N'230-34-7888', 5, '2026-07-15', '13:00:00', N'Scheduled', N'InPerson'),
(10, N'546-87-9379', 3, '2026-07-19', '08:00:00', N'Scheduled', N'InPerson'),
(1, N'904-84-6279', 2, '2026-06-22', '16:30:00', N'Completed', N'InPerson'),
(11, N'854-52-7745', 4, '2026-06-09', '09:00:00', N'Completed', N'InPerson'),
(10, N'904-84-6279', 3, '2026-06-19', '13:30:00', N'Cancelled', N'InPerson'),
(7, N'509-96-9785', 1, '2026-06-18', '11:30:00', N'Completed', N'InPerson'),
(11, N'919-87-4613', 4, '2026-05-22', '09:45:00', N'Completed', N'InPerson'),
(1, N'952-63-7381', 2, '2026-05-19', '10:00:00', N'Completed', N'InPerson'),
(13, N'568-50-2188', 6, '2026-05-30', '16:00:00', N'Completed', N'Online'),
(12, N'897-64-4585', 5, '2026-07-17', '12:00:00', N'Cancelled', N'InPerson'),
(5, N'390-75-6491', 6, '2026-05-22', '10:30:00', N'Completed', N'InPerson'),
(3, N'470-91-8532', 4, '2026-07-07', '09:30:00', N'Completed', N'InPerson'),
(14, N'533-45-1722', 1, '2026-07-26', '13:45:00', N'Scheduled', N'InPerson'),
(12, N'506-35-2245', 5, '2026-05-28', '16:30:00', N'Completed', N'InPerson'),
(14, N'266-57-6820', 1, '2026-06-30', '14:30:00', N'Completed', N'InPerson'),
(8, N'472-65-2146', 7, '2026-06-16', '13:45:00', N'Completed', N'InPerson'),
(11, N'533-45-1722', 4, '2026-05-28', '12:15:00', N'Completed', N'InPerson'),
(3, N'533-45-1722', 4, '2026-06-06', '14:30:00', N'Completed', N'InPerson'),
(5, N'458-49-4728', 6, '2026-07-03', '12:00:00', N'Completed', N'InPerson'),
(8, N'566-63-4185', 7, '2026-07-28', '16:45:00', N'Scheduled', N'InPerson'),
(9, N'324-97-6313', 2, '2026-06-28', '14:00:00', N'Completed', N'InPerson'),
(2, N'506-35-2245', 3, '2026-07-28', '11:15:00', N'Scheduled', N'InPerson'),
(5, N'261-17-9320', 6, '2026-06-21', '15:15:00', N'Completed', N'InPerson'),
(7, N'261-17-9320', 1, '2026-07-18', '09:30:00', N'Scheduled', N'InPerson'),
(11, N'472-65-2146', 4, '2026-06-12', '15:00:00', N'Completed', N'InPerson'),
(7, N'568-50-2188', 1, '2026-07-05', '13:45:00', N'Completed', N'InPerson'),
(14, N'919-87-4613', 1, '2026-06-04', '12:30:00', N'Completed', N'InPerson'),
(8, N'734-20-7868', 7, '2026-06-09', '14:30:00', N'Completed', N'InPerson'),
(8, N'897-64-4585', 7, '2026-06-18', '13:45:00', N'Completed', N'InPerson'),
(6, N'621-73-2489', 8, '2026-06-12', '16:15:00', N'Completed', N'InPerson'),
(12, N'509-96-9785', 5, '2026-06-13', '15:30:00', N'Cancelled', N'InPerson'),
(4, N'355-19-8260', 5, '2026-06-06', '14:45:00', N'Completed', N'Online'),
(8, N'672-86-6198', 7, '2026-07-08', '16:45:00', N'Scheduled', N'InPerson'),
(6, N'329-93-2124', 8, '2026-07-25', '09:00:00', N'Scheduled', N'InPerson'),
(6, N'100-86-6310', 8, '2026-05-23', '14:30:00', N'Rescheduled', N'InPerson'),
(1, N'505-92-8517', 2, '2026-06-20', '11:15:00', N'Completed', N'InPerson'),
(13, N'316-68-6355', 6, '2026-07-21', '10:30:00', N'Rescheduled', N'InPerson'),
(5, N'798-41-2684', 6, '2026-05-28', '09:15:00', N'Completed', N'InPerson'),
(13, N'702-38-1117', 6, '2026-07-23', '15:30:00', N'Scheduled', N'InPerson'),
(12, N'458-49-4728', 5, '2026-06-27', '09:30:00', N'Completed', N'InPerson'),
(1, N'568-50-2188', 2, '2026-05-31', '10:15:00', N'Completed', N'InPerson'),
(6, N'566-63-4185', 8, '2026-07-11', '15:15:00', N'Scheduled', N'InPerson'),
(3, N'952-63-7381', 4, '2026-07-12', '14:00:00', N'Scheduled', N'Online'),
(8, N'672-86-6198', 7, '2026-07-11', '14:00:00', N'Scheduled', N'InPerson'),
(13, N'323-69-5198', 6, '2026-05-26', '09:15:00', N'Completed', N'InPerson'),
(2, N'355-19-8260', 3, '2026-07-19', '16:30:00', N'Scheduled', N'InPerson'),
(10, N'621-73-2489', 3, '2026-07-01', '13:45:00', N'Completed', N'InPerson'),
(12, N'261-17-9320', 5, '2026-05-28', '10:30:00', N'Completed', N'InPerson'),
(3, N'860-80-3546', 4, '2026-06-05', '16:45:00', N'Completed', N'InPerson'),
(7, N'854-52-7745', 1, '2026-06-10', '15:15:00', N'Completed', N'InPerson'),
(3, N'878-78-3060', 4, '2026-06-27', '15:00:00', N'Cancelled', N'Online'),
(8, N'981-11-2876', 7, '2026-06-11', '14:45:00', N'Completed', N'InPerson');

GO


-- ============================================================
-- 7. ADMISSIONS
-- ============================================================

SET IDENTITY_INSERT [admission] ON;
INSERT INTO [admission] ([id], [patientID], [bedID], [employeeID], [appointmentID], [entrydate], [exitdate], [reason]) VALUES
(1, N'472-65-2146', 26, 13, NULL, '2026-05-23', '2026-06-06', N'Acute gastroenteritis with dehydration'),
(2, N'506-35-2245', 16, 11, NULL, '2026-05-24', '2026-06-01', N'Elective hip replacement surgery'),
(3, N'230-89-9751', 6, 9, NULL, '2026-05-25', '2026-06-07', N'Stroke - acute management'),
(4, N'807-29-9938', 21, 4, NULL, '2026-05-26', '2026-06-09', N'Acute kidney injury'),
(5, N'472-65-2146', 36, 6, NULL, '2026-05-26', '2026-05-31', N'Fall with suspected fracture'),
(6, N'566-63-4185', 1, 14, NULL, '2026-05-26', NULL, N'Hypertensive crisis'),
(7, N'472-65-2146', 7, 1, NULL, '2026-05-27', '2026-06-09', N'Acute gastroenteritis with dehydration'),
(8, N'489-22-6881', 31, 8, 79, '2026-05-27', '2026-06-10', N'Uncontrolled type 2 diabetes'),
(9, N'458-49-4728', 2, 7, 48, '2026-05-28', NULL, N'Observation after minor head trauma'),
(10, N'919-87-4613', 32, 15, NULL, '2026-05-28', NULL, N'Labor and delivery'),
(11, N'324-97-6313', 37, 6, NULL, '2026-05-29', NULL, N'Stroke - acute management'),
(12, N'230-89-9751', 17, 11, NULL, '2026-05-29', NULL, N'Post-operative recovery, appendectomy'),
(13, N'261-17-9320', 22, 12, 196, '2026-05-30', '2026-06-01', N'Congestive heart failure exacerbation'),
(14, N'546-87-9379', 23, 4, NULL, '2026-05-31', NULL, N'Elective hip replacement surgery'),
(15, N'904-84-6279', 24, 12, NULL, '2026-05-31', NULL, N'Observation after minor head trauma'),
(16, N'568-50-2188', 25, 12, 157, '2026-05-31', '2026-06-07', N'Uncontrolled type 2 diabetes'),
(17, N'319-79-3167', 27, 13, NULL, '2026-05-31', NULL, N'COPD exacerbation'),
(18, N'505-92-8517', 18, 3, NULL, '2026-05-31', '2026-06-05', N'Uncontrolled type 2 diabetes'),
(19, N'533-45-1722', 19, 3, 120, '2026-06-01', '2026-06-12', N'Severe asthma exacerbation'),
(20, N'182-27-3471', 3, 4, NULL, '2026-06-01', '2026-06-13', N'Post-operative recovery, appendectomy'),
(21, N'612-32-9317', 4, 14, NULL, '2026-06-01', '2026-06-09', N'Cellulitis requiring IV antibiotics'),
(22, N'702-38-1117', 28, 13, NULL, '2026-06-02', '2026-06-05', N'Elective hip replacement surgery'),
(23, N'621-73-2489', 5, 7, NULL, '2026-06-02', '2026-06-08', N'Hypertensive crisis'),
(24, N'981-11-2876', 11, 2, NULL, '2026-06-02', NULL, N'Congestive heart failure exacerbation'),
(25, N'578-16-2612', 12, 10, NULL, '2026-06-03', '2026-06-15', N'Abdominal pain, suspected cholecystitis'),
(26, N'258-34-5861', 33, 15, NULL, '2026-06-04', '2026-06-15', N'Acute chest pain, rule out myocardial infarction'),
(27, N'904-84-6279', 8, 7, 134, '2026-06-05', '2026-06-17', N'Post-surgical wound infection'),
(28, N'578-16-2612', 34, 8, NULL, '2026-06-05', '2026-06-09', N'Sepsis of unknown origin'),
(29, N'952-63-7381', 35, 15, NULL, '2026-06-05', NULL, N'Post-surgical wound infection'),
(30, N'860-80-3546', 9, 14, NULL, '2026-06-05', NULL, N'Acute gastroenteritis with dehydration'),
(31, N'798-41-2684', 28, 13, NULL, '2026-06-06', '2026-06-09', N'Stroke - acute management'),
(32, N'374-51-5022', 13, 2, NULL, '2026-06-07', NULL, N'Elective hip replacement surgery'),
(33, N'242-23-9935', 10, 15, NULL, '2026-06-07', NULL, N'Fall with suspected fracture'),
(34, N'982-56-4150', 22, 12, NULL, '2026-06-07', '2026-06-18', N'COPD exacerbation'),
(35, N'230-34-7888', 14, 2, NULL, '2026-06-08', '2026-06-15', N'Cellulitis requiring IV antibiotics'),
(36, N'390-75-6491', 15, 2, NULL, '2026-06-09', NULL, N'Post-surgical wound infection'),
(37, N'230-34-7888', 6, 9, NULL, '2026-06-09', '2026-06-12', N'Acute kidney injury'),
(38, N'672-86-6198', 25, 12, NULL, '2026-06-09', '2026-06-16', N'Elective hip replacement surgery'),
(39, N'578-16-2612', 5, 15, NULL, '2026-06-09', NULL, N'Community-acquired pneumonia'),
(40, N'854-52-7745', 16, 1, NULL, '2026-06-09', '2026-06-19', N'Uncontrolled type 2 diabetes'),
(41, N'901-15-6688', 18, 12, 4, '2026-06-09', NULL, N'Post-operative recovery, appendectomy'),
(42, N'100-86-6310', 7, 9, NULL, '2026-06-10', '2026-06-19', N'Sepsis of unknown origin'),
(43, N'506-35-2245', 20, 3, NULL, '2026-06-10', NULL, N'Fall with suspected fracture'),
(44, N'318-61-1960', 36, 6, NULL, '2026-06-10', '2026-06-11', N'Uncontrolled type 2 diabetes'),
(45, N'854-52-7745', 21, 12, NULL, '2026-06-11', '2026-06-16', N'Fall with suspected fracture'),
(46, N'952-63-7381', 36, 6, 156, '2026-06-12', '2026-06-21', N'Elective hip replacement surgery'),
(47, N'860-80-3546', 4, 2, NULL, '2026-06-12', NULL, N'Post-operative recovery, appendectomy'),
(48, N'316-68-6355', 26, 9, 126, '2026-06-12', NULL, N'Uncontrolled type 2 diabetes'),
(49, N'578-16-2612', 31, 15, 139, '2026-06-13', '2026-06-20', N'Community-acquired pneumonia'),
(50, N'566-63-4185', 3, 4, NULL, '2026-06-14', NULL, N'Cellulitis requiring IV antibiotics'),
(51, N'506-35-2245', 6, 2, NULL, '2026-06-14', NULL, N'Acute gastroenteritis with dehydration'),
(52, N'621-73-2489', 19, 3, 178, '2026-06-14', '2026-06-15', N'Scheduled cardiac catheterization'),
(53, N'489-22-6881', 34, 8, NULL, '2026-06-15', NULL, N'COPD exacerbation'),
(54, N'374-51-5022', 28, 8, NULL, '2026-06-15', '2026-06-24', N'Labor and delivery'),
(55, N'242-23-9935', 12, 10, NULL, '2026-06-16', NULL, N'Stroke - acute management'),
(56, N'901-15-6688', 38, 6, NULL, '2026-06-16', NULL, N'Post-surgical wound infection'),
(57, N'472-65-2146', 29, 13, NULL, '2026-06-17', '2026-06-26', N'Acute kidney injury'),
(58, N'612-32-9317', 21, 4, NULL, '2026-06-17', '2026-06-18', N'Acute chest pain, rule out myocardial infarction'),
(59, N'390-75-6491', 33, 15, 159, '2026-06-17', '2026-06-29', N'Stroke - acute management'),
(60, N'242-23-9935', 30, 5, 138, '2026-06-18', '2026-06-30', N'COPD exacerbation');
SET IDENTITY_INSERT [admission] OFF;


GO


-- ============================================================
-- 8. PATIENT TRANSFERS
-- ============================================================

SET IDENTITY_INSERT [patienttransfer] ON;
INSERT INTO [patienttransfer] ([id], [date], [time], [reason], [admissionID], [fromBedID], [toBedID]) VALUES
(1, '2026-05-31', '12:30:00', N'Room reassignment', 11, 37, 39),
(2, '2026-06-07', '15:30:00', N'Patient condition improved', 30, 9, 8),
(3, '2026-06-01', '10:00:00', N'Patient condition improved', 14, 23, 21),
(4, '2026-06-17', '15:45:00', N'Transferred for specialized monitoring', 56, 38, 37),
(5, '2026-06-01', '16:30:00', N'Patient condition improved', 15, 24, 23),
(6, '2026-06-16', '15:30:00', N'Ward capacity reallocation', 51, 6, 9),
(7, '2026-06-16', '20:30:00', N'Ward capacity reallocation', 53, 34, 31),
(8, '2026-06-09', '10:00:00', N'Patient condition improved', 33, 10, 6),
(9, '2026-06-07', '16:00:00', N'Transferred for specialized monitoring', 29, 35, 34),
(10, '2026-06-10', '08:45:00', N'Room reassignment', 41, 18, 19),
(11, '2026-06-15', '16:15:00', N'Ward capacity reallocation', 48, 26, 30),
(12, '2026-06-08', '20:15:00', N'Ward capacity reallocation', 32, 13, 14);
SET IDENTITY_INSERT [patienttransfer] OFF;


GO


-- ============================================================
-- 9. DOCTOR DIAGNOSES
-- ============================================================

SET IDENTITY_INSERT [doctordiagnosis] ON;
INSERT INTO [doctordiagnosis] ([id], [appointmentID], [admissionID], [icdID], [description]) VALUES
(1, 2, NULL, 8, N'Diagnosed with chronic kidney disease, stage 3 during outpatient visit.'),
(2, 3, NULL, 13, N'Diagnosed with hypothyroidism, unspecified during outpatient visit.'),
(3, 4, NULL, 3, N'Diagnosed with asthma, unspecified during outpatient visit.'),
(4, 8, NULL, 3, N'Diagnosed with asthma, unspecified during outpatient visit.'),
(5, 9, NULL, 3, N'Diagnosed with asthma, unspecified during outpatient visit.'),
(6, 10, NULL, 15, N'Diagnosed with abdominal pain, unspecified during outpatient visit.'),
(7, 13, NULL, 11, N'Diagnosed with heart failure, unspecified during outpatient visit.'),
(8, 14, NULL, 15, N'Diagnosed with abdominal pain, unspecified during outpatient visit.'),
(9, 15, NULL, 19, N'Diagnosed with concussion during outpatient visit.'),
(10, 17, NULL, 13, N'Diagnosed with hypothyroidism, unspecified during outpatient visit.'),
(11, 18, NULL, 13, N'Diagnosed with hypothyroidism, unspecified during outpatient visit.'),
(12, 23, NULL, 7, N'Diagnosed with fracture of neck of right femur during outpatient visit.'),
(13, 25, NULL, 15, N'Diagnosed with abdominal pain, unspecified during outpatient visit.'),
(14, 27, NULL, 20, N'Diagnosed with encounter for supervision of normal pregnancy during outpatient visit.'),
(15, 31, NULL, 18, N'Diagnosed with cholelithiasis without cholecystitis during outpatient visit.'),
(16, 34, NULL, 3, N'Diagnosed with asthma, unspecified during outpatient visit.'),
(17, 35, NULL, 5, N'Diagnosed with acute myocardial infarction, unspecified during outpatient visit.'),
(18, 39, NULL, 17, N'Diagnosed with urinary tract infection, site not specified during outpatient visit.'),
(19, 40, NULL, 18, N'Diagnosed with cholelithiasis without cholecystitis during outpatient visit.'),
(20, 48, NULL, 18, N'Diagnosed with cholelithiasis without cholecystitis during outpatient visit.'),
(21, 53, NULL, 19, N'Diagnosed with concussion during outpatient visit.'),
(22, 54, NULL, 13, N'Diagnosed with hypothyroidism, unspecified during outpatient visit.'),
(23, 56, NULL, 1, N'Diagnosed with essential (primary) hypertension during outpatient visit.'),
(24, 58, NULL, 8, N'Diagnosed with chronic kidney disease, stage 3 during outpatient visit.'),
(25, 62, NULL, 9, N'Diagnosed with encounter for full-term uncomplicated delivery during outpatient visit.'),
(26, 64, NULL, 16, N'Diagnosed with cerebral infarction, unspecified (stroke) during outpatient visit.'),
(27, 65, NULL, 19, N'Diagnosed with concussion during outpatient visit.'),
(28, 73, NULL, 8, N'Diagnosed with chronic kidney disease, stage 3 during outpatient visit.'),
(29, 75, NULL, 2, N'Diagnosed with type 2 diabetes mellitus without complications during outpatient visit.'),
(30, 84, NULL, 6, N'Diagnosed with acute appendicitis, unspecified during outpatient visit.'),
(31, 85, NULL, 19, N'Diagnosed with concussion during outpatient visit.'),
(32, 87, NULL, 12, N'Diagnosed with chronic obstructive pulmonary disease, unspecified during outpatient visit.'),
(33, 90, NULL, 12, N'Diagnosed with chronic obstructive pulmonary disease, unspecified during outpatient visit.'),
(34, 101, NULL, 16, N'Diagnosed with cerebral infarction, unspecified (stroke) during outpatient visit.'),
(35, 102, NULL, 6, N'Diagnosed with acute appendicitis, unspecified during outpatient visit.'),
(36, 105, NULL, 3, N'Diagnosed with asthma, unspecified during outpatient visit.'),
(37, 107, NULL, 20, N'Diagnosed with encounter for supervision of normal pregnancy during outpatient visit.'),
(38, 108, NULL, 17, N'Diagnosed with urinary tract infection, site not specified during outpatient visit.'),
(39, 109, NULL, 11, N'Diagnosed with heart failure, unspecified during outpatient visit.'),
(40, 115, NULL, 5, N'Diagnosed with acute myocardial infarction, unspecified during outpatient visit.'),
(41, 116, NULL, 6, N'Diagnosed with acute appendicitis, unspecified during outpatient visit.'),
(42, 122, NULL, 1, N'Diagnosed with essential (primary) hypertension during outpatient visit.'),
(43, 123, NULL, 5, N'Diagnosed with acute myocardial infarction, unspecified during outpatient visit.'),
(44, 130, NULL, 13, N'Diagnosed with hypothyroidism, unspecified during outpatient visit.'),
(45, 132, NULL, 11, N'Diagnosed with heart failure, unspecified during outpatient visit.'),
(46, 133, NULL, 6, N'Diagnosed with acute appendicitis, unspecified during outpatient visit.'),
(47, 135, NULL, 16, N'Diagnosed with cerebral infarction, unspecified (stroke) during outpatient visit.'),
(48, 139, NULL, 18, N'Diagnosed with cholelithiasis without cholecystitis during outpatient visit.'),
(49, 154, NULL, 19, N'Diagnosed with concussion during outpatient visit.'),
(50, 156, NULL, 10, N'Diagnosed with infectious gastroenteritis and colitis, unspecified during outpatient visit.'),
(51, 157, NULL, 1, N'Diagnosed with essential (primary) hypertension during outpatient visit.'),
(52, 162, NULL, 19, N'Diagnosed with concussion during outpatient visit.'),
(53, 163, NULL, 20, N'Diagnosed with encounter for supervision of normal pregnancy during outpatient visit.'),
(54, 164, NULL, 20, N'Diagnosed with encounter for supervision of normal pregnancy during outpatient visit.'),
(55, 165, NULL, 19, N'Diagnosed with concussion during outpatient visit.'),
(56, 166, NULL, 16, N'Diagnosed with cerebral infarction, unspecified (stroke) during outpatient visit.'),
(57, 167, NULL, 3, N'Diagnosed with asthma, unspecified during outpatient visit.'),
(58, 169, NULL, 11, N'Diagnosed with heart failure, unspecified during outpatient visit.'),
(59, 171, NULL, 3, N'Diagnosed with asthma, unspecified during outpatient visit.'),
(60, 176, NULL, 1, N'Diagnosed with essential (primary) hypertension during outpatient visit.'),
(61, 177, NULL, 8, N'Diagnosed with chronic kidney disease, stage 3 during outpatient visit.'),
(62, 180, NULL, 4, N'Diagnosed with pneumonia, unspecified organism during outpatient visit.'),
(63, 186, NULL, 15, N'Diagnosed with abdominal pain, unspecified during outpatient visit.'),
(64, 195, NULL, 13, N'Diagnosed with hypothyroidism, unspecified during outpatient visit.'),
(65, 196, NULL, 13, N'Diagnosed with hypothyroidism, unspecified during outpatient visit.'),
(66, 197, NULL, 16, N'Diagnosed with cerebral infarction, unspecified (stroke) during outpatient visit.'),
(67, NULL, 1, 8, N'Primary admitting diagnosis: chronic kidney disease, stage 3.'),
(68, NULL, 2, 3, N'Primary admitting diagnosis: asthma, unspecified.'),
(69, NULL, 3, 2, N'Primary admitting diagnosis: type 2 diabetes mellitus without complications.'),
(70, NULL, 4, 11, N'Primary admitting diagnosis: heart failure, unspecified.'),
(71, NULL, 5, 4, N'Primary admitting diagnosis: pneumonia, unspecified organism.'),
(72, NULL, 6, 6, N'Primary admitting diagnosis: acute appendicitis, unspecified.'),
(73, NULL, 7, 6, N'Primary admitting diagnosis: acute appendicitis, unspecified.'),
(74, NULL, 8, 18, N'Primary admitting diagnosis: cholelithiasis without cholecystitis.'),
(75, NULL, 11, 20, N'Primary admitting diagnosis: encounter for supervision of normal pregnancy.'),
(76, NULL, 12, 1, N'Primary admitting diagnosis: essential (primary) hypertension.'),
(77, NULL, 13, 6, N'Primary admitting diagnosis: acute appendicitis, unspecified.'),
(78, NULL, 14, 14, N'Primary admitting diagnosis: osteoarthritis of knee, unspecified.'),
(79, NULL, 15, 4, N'Primary admitting diagnosis: pneumonia, unspecified organism.'),
(80, NULL, 16, 7, N'Primary admitting diagnosis: fracture of neck of right femur.'),
(81, NULL, 17, 18, N'Primary admitting diagnosis: cholelithiasis without cholecystitis.'),
(82, NULL, 18, 18, N'Primary admitting diagnosis: cholelithiasis without cholecystitis.'),
(83, NULL, 19, 10, N'Primary admitting diagnosis: infectious gastroenteritis and colitis, unspecified.'),
(84, NULL, 20, 4, N'Primary admitting diagnosis: pneumonia, unspecified organism.'),
(85, NULL, 21, 19, N'Primary admitting diagnosis: concussion.'),
(86, NULL, 22, 16, N'Primary admitting diagnosis: cerebral infarction, unspecified (stroke).'),
(87, NULL, 23, 12, N'Primary admitting diagnosis: chronic obstructive pulmonary disease, unspecified.'),
(88, NULL, 24, 3, N'Primary admitting diagnosis: asthma, unspecified.'),
(89, NULL, 25, 20, N'Primary admitting diagnosis: encounter for supervision of normal pregnancy.'),
(90, NULL, 26, 4, N'Primary admitting diagnosis: pneumonia, unspecified organism.'),
(91, NULL, 27, 6, N'Primary admitting diagnosis: acute appendicitis, unspecified.'),
(92, NULL, 28, 3, N'Primary admitting diagnosis: asthma, unspecified.'),
(93, NULL, 29, 4, N'Primary admitting diagnosis: pneumonia, unspecified organism.'),
(94, NULL, 30, 13, N'Primary admitting diagnosis: hypothyroidism, unspecified.'),
(95, NULL, 31, 9, N'Primary admitting diagnosis: encounter for full-term uncomplicated delivery.'),
(96, NULL, 32, 18, N'Primary admitting diagnosis: cholelithiasis without cholecystitis.'),
(97, NULL, 33, 12, N'Primary admitting diagnosis: chronic obstructive pulmonary disease, unspecified.'),
(98, NULL, 34, 12, N'Primary admitting diagnosis: chronic obstructive pulmonary disease, unspecified.'),
(99, NULL, 35, 2, N'Primary admitting diagnosis: type 2 diabetes mellitus without complications.'),
(100, NULL, 36, 15, N'Primary admitting diagnosis: abdominal pain, unspecified.');
INSERT INTO [doctordiagnosis] ([id], [appointmentID], [admissionID], [icdID], [description]) VALUES
(101, NULL, 37, 9, N'Primary admitting diagnosis: encounter for full-term uncomplicated delivery.'),
(102, NULL, 38, 5, N'Primary admitting diagnosis: acute myocardial infarction, unspecified.'),
(103, NULL, 39, 4, N'Primary admitting diagnosis: pneumonia, unspecified organism.'),
(104, NULL, 40, 12, N'Primary admitting diagnosis: chronic obstructive pulmonary disease, unspecified.'),
(105, NULL, 41, 14, N'Primary admitting diagnosis: osteoarthritis of knee, unspecified.'),
(106, NULL, 43, 18, N'Primary admitting diagnosis: cholelithiasis without cholecystitis.'),
(107, NULL, 44, 13, N'Primary admitting diagnosis: hypothyroidism, unspecified.'),
(108, NULL, 45, 14, N'Primary admitting diagnosis: osteoarthritis of knee, unspecified.'),
(109, NULL, 47, 16, N'Primary admitting diagnosis: cerebral infarction, unspecified (stroke).'),
(110, NULL, 48, 8, N'Primary admitting diagnosis: chronic kidney disease, stage 3.'),
(111, NULL, 49, 3, N'Primary admitting diagnosis: asthma, unspecified.'),
(112, NULL, 50, 2, N'Primary admitting diagnosis: type 2 diabetes mellitus without complications.'),
(113, NULL, 51, 17, N'Primary admitting diagnosis: urinary tract infection, site not specified.'),
(114, NULL, 52, 20, N'Primary admitting diagnosis: encounter for supervision of normal pregnancy.'),
(115, NULL, 53, 15, N'Primary admitting diagnosis: abdominal pain, unspecified.'),
(116, NULL, 54, 6, N'Primary admitting diagnosis: acute appendicitis, unspecified.'),
(117, NULL, 56, 5, N'Primary admitting diagnosis: acute myocardial infarction, unspecified.'),
(118, NULL, 57, 3, N'Primary admitting diagnosis: asthma, unspecified.'),
(119, NULL, 59, 5, N'Primary admitting diagnosis: acute myocardial infarction, unspecified.'),
(120, NULL, 60, 9, N'Primary admitting diagnosis: encounter for full-term uncomplicated delivery.');
SET IDENTITY_INSERT [doctordiagnosis] OFF;


GO


-- ============================================================
-- 10. LAB / IMAGING REQUESTS
-- ============================================================

SET IDENTITY_INSERT [Labimagingrequest] ON;
INSERT INTO [Labimagingrequest] ([id], [employeeID], [appointmentID], [admissionID], [type], [date], [status]) VALUES
(1, 11, 152, NULL, N'Lab', '2026-06-09', N'Completed'),
(2, 4, 127, NULL, N'Lab', '2026-05-25', N'Completed'),
(3, 6, 47, NULL, N'Lab', '2026-07-06', N'Completed'),
(4, 10, NULL, 25, N'Lab', '2026-06-03', N'Completed'),
(5, 7, NULL, 9, N'Imaging', '2026-05-28', N'Completed'),
(6, 4, 180, NULL, N'Imaging', '2026-06-06', N'Completed'),
(7, 15, 125, NULL, N'Lab', '2026-06-17', N'Completed'),
(8, 8, 40, NULL, N'Lab', '2026-06-30', N'Completed'),
(9, 7, 154, NULL, N'Lab', '2026-06-18', N'Completed'),
(10, 5, 186, NULL, N'Lab', '2026-05-28', N'Completed'),
(11, 7, 142, NULL, N'Lab', '2026-06-15', N'Completed'),
(12, 8, 88, NULL, N'Lab', '2026-07-05', N'Completed'),
(13, 5, 90, NULL, N'Lab', '2026-06-25', N'Completed'),
(14, 5, 11, NULL, N'Imaging', '2026-07-05', N'Completed'),
(15, 12, 162, NULL, N'Imaging', '2026-05-28', N'Completed'),
(16, 14, 175, NULL, N'Imaging', '2026-06-04', N'Completed'),
(17, 15, 125, NULL, N'Lab', '2026-06-17', N'Completed'),
(18, 12, NULL, 41, N'Lab', '2026-06-09', N'Completed'),
(19, 3, NULL, 52, N'Lab', '2026-06-14', N'Completed'),
(20, 14, NULL, 21, N'Lab', '2026-06-01', N'Completed'),
(21, 5, 171, NULL, N'Lab', '2026-06-21', N'Completed'),
(22, 2, NULL, 51, N'Lab', '2026-06-14', N'Completed'),
(23, 2, 135, NULL, N'Imaging', '2026-07-04', N'Completed'),
(24, 11, 62, NULL, N'Lab', '2026-06-22', N'Completed'),
(25, 3, 14, NULL, N'Lab', '2026-06-24', N'Completed'),
(26, 2, NULL, 51, N'Lab', '2026-06-14', N'Completed'),
(27, 14, NULL, 30, N'Imaging', '2026-06-05', N'Completed'),
(28, 13, NULL, 31, N'Lab', '2026-06-06', N'Completed'),
(29, 5, 107, NULL, N'Lab', '2026-05-19', N'Completed'),
(30, 14, NULL, 6, N'Lab', '2026-05-26', N'Completed'),
(31, 1, 27, NULL, N'Lab', '2026-06-14', N'Completed'),
(32, 2, 135, NULL, N'Lab', '2026-07-04', N'Completed'),
(33, 6, NULL, 5, N'Imaging', '2026-05-26', N'Completed'),
(34, 3, 81, NULL, N'Lab', '2026-06-25', N'Completed'),
(35, 9, 79, NULL, N'Lab', '2026-05-23', N'Completed'),
(36, 12, 196, NULL, N'Lab', '2026-05-28', N'Completed'),
(37, 10, 7, NULL, N'Lab', '2026-07-03', N'Completed'),
(38, 4, 117, NULL, N'Imaging', '2026-05-27', N'Completed'),
(39, 12, NULL, 38, N'Lab', '2026-06-09', N'Completed'),
(40, 14, NULL, 21, N'Lab', '2026-06-01', N'Completed'),
(41, 12, NULL, 13, N'Lab', '2026-05-30', N'Completed'),
(42, 10, 101, NULL, N'Lab', '2026-05-31', N'Completed'),
(43, 3, 14, NULL, N'Lab', '2026-06-24', N'Completed'),
(44, 10, NULL, 55, N'Lab', '2026-06-16', N'Completed'),
(45, 8, NULL, 28, N'Lab', '2026-06-05', N'Completed'),
(46, 13, 193, NULL, N'Lab', '2026-05-26', N'Completed'),
(47, 13, 41, NULL, N'Lab', '2026-06-21', N'Completed'),
(48, 3, NULL, 43, N'Imaging', '2026-06-10', N'Completed'),
(49, 9, 134, NULL, N'Imaging', '2026-06-04', N'Completed'),
(50, 6, 2, NULL, N'Imaging', '2026-05-27', N'Completed'),
(51, 14, 35, NULL, N'Lab', '2026-06-09', N'Completed'),
(52, 9, 134, NULL, N'Lab', '2026-06-04', N'Completed'),
(53, 3, 166, NULL, N'Lab', '2026-06-06', N'Completed'),
(54, 13, 4, NULL, N'Lab', '2026-05-23', N'Completed'),
(55, 15, 125, NULL, N'Lab', '2026-06-17', N'Completed'),
(56, 4, NULL, 4, N'Lab', '2026-05-26', N'Completed'),
(57, 9, 76, NULL, N'Imaging', '2026-07-03', N'Completed'),
(58, 6, NULL, 11, N'Lab', '2026-05-29', N'Completed'),
(59, 5, 11, NULL, N'Lab', '2026-07-05', N'InProgress'),
(60, 13, 56, NULL, N'Lab', '2026-06-03', N'Completed'),
(61, 10, NULL, 55, N'Lab', '2026-06-16', N'Completed'),
(62, 15, NULL, 59, N'Lab', '2026-06-17', N'Completed'),
(63, 13, NULL, 57, N'Lab', '2026-06-17', N'Completed'),
(64, 14, NULL, 30, N'Lab', '2026-06-05', N'Completed'),
(65, 8, NULL, 8, N'Lab', '2026-05-27', N'Completed'),
(66, 15, 130, NULL, N'Imaging', '2026-06-09', N'Completed'),
(67, 3, 110, NULL, N'Imaging', '2026-06-06', N'Completed'),
(68, 11, NULL, 2, N'Lab', '2026-05-24', N'Completed'),
(69, 8, NULL, 28, N'Imaging', '2026-06-05', N'Completed'),
(70, 3, NULL, 18, N'Lab', '2026-05-31', N'Completed'),
(71, 4, NULL, 4, N'Lab', '2026-05-26', N'Completed'),
(72, 11, 39, NULL, N'Lab', '2026-06-21', N'Completed'),
(73, 14, 133, NULL, N'Lab', '2026-06-05', N'Completed'),
(74, 5, 186, NULL, N'Imaging', '2026-05-28', N'Completed'),
(75, 1, 87, NULL, N'Lab', '2026-06-04', N'Completed'),
(76, 12, NULL, 38, N'Imaging', '2026-06-09', N'Completed'),
(77, 6, 58, NULL, N'Lab', '2026-05-27', N'Completed'),
(78, 6, NULL, 11, N'Lab', '2026-05-29', N'Completed'),
(79, 13, 41, NULL, N'Lab', '2026-06-21', N'Completed'),
(80, 4, 117, NULL, N'Lab', '2026-05-27', N'Completed'),
(81, 9, NULL, 42, N'Lab', '2026-06-10', N'Completed'),
(82, 15, NULL, 29, N'Lab', '2026-06-05', N'Completed'),
(83, 5, NULL, 60, N'Imaging', '2026-06-18', N'Completed'),
(84, 6, 48, NULL, N'Lab', '2026-05-27', N'Completed'),
(85, 1, 189, NULL, N'Lab', '2026-05-31', N'Completed'),
(86, 15, 10, NULL, N'Lab', '2026-06-26', N'Completed'),
(87, 15, 75, NULL, N'Lab', '2026-07-03', N'Completed'),
(88, 15, NULL, 26, N'Imaging', '2026-06-04', N'Completed'),
(89, 5, 107, NULL, N'Lab', '2026-05-19', N'Completed'),
(90, 5, 132, NULL, N'Lab', '2026-06-10', N'Completed'),
(91, 1, 151, NULL, N'Lab', '2026-06-22', N'Completed'),
(92, 13, NULL, 1, N'Lab', '2026-05-23', N'Completed'),
(93, 8, 88, NULL, N'Lab', '2026-07-05', N'Completed'),
(94, 10, 15, NULL, N'Lab', '2026-07-05', N'Completed'),
(95, 1, NULL, 7, N'Lab', '2026-05-27', N'Completed'),
(96, 9, NULL, 48, N'Lab', '2026-06-12', N'Completed'),
(97, 11, 152, NULL, N'Lab', '2026-06-09', N'Completed'),
(98, 7, NULL, 27, N'Lab', '2026-06-05', N'Completed'),
(99, 1, 156, NULL, N'Lab', '2026-05-19', N'Completed'),
(100, 8, NULL, 54, N'Imaging', '2026-06-15', N'Completed');
INSERT INTO [Labimagingrequest] ([id], [employeeID], [appointmentID], [admissionID], [type], [date], [status]) VALUES
(101, 2, NULL, 47, N'Imaging', '2026-06-12', N'Completed'),
(102, 6, 48, NULL, N'Lab', '2026-05-27', N'Completed'),
(103, 3, NULL, 19, N'Lab', '2026-06-01', N'Completed'),
(104, 7, 154, NULL, N'Lab', '2026-06-18', N'Completed'),
(105, 5, 98, NULL, N'Lab', '2026-05-25', N'Completed'),
(106, 7, 198, NULL, N'Lab', '2026-06-10', N'Completed'),
(107, 1, 156, NULL, N'Imaging', '2026-05-19', N'Completed'),
(108, 2, NULL, 35, N'Lab', '2026-06-08', N'Completed'),
(109, 1, 151, NULL, N'Imaging', '2026-06-22', N'Completed'),
(110, 12, 25, NULL, N'Lab', '2026-06-29', N'Completed'),
(111, 14, 133, NULL, N'Lab', '2026-06-05', N'Completed'),
(112, 7, 174, NULL, N'Lab', '2026-07-05', N'Completed'),
(113, 7, NULL, 27, N'Lab', '2026-06-05', N'Completed'),
(114, 8, NULL, 53, N'Lab', '2026-06-15', N'Completed'),
(115, 12, NULL, 34, N'Lab', '2026-06-07', N'Completed'),
(116, 12, 162, NULL, N'Imaging', '2026-05-28', N'Completed'),
(117, 7, 120, NULL, N'Imaging', '2026-05-28', N'Completed'),
(118, 8, NULL, 28, N'Lab', '2026-06-05', N'Completed'),
(119, 5, 90, NULL, N'Lab', '2026-06-25', N'Completed'),
(120, 8, 40, NULL, N'Lab', '2026-06-30', N'Completed'),
(121, 6, NULL, 56, N'Lab', '2026-06-16', N'Completed'),
(122, 12, 196, NULL, N'Imaging', '2026-05-28', N'Completed'),
(123, 7, 198, NULL, N'Lab', '2026-06-10', N'Completed'),
(124, 14, NULL, 6, N'Lab', '2026-05-26', N'Completed'),
(125, 15, 130, NULL, N'Lab', '2026-06-09', N'Completed'),
(126, 5, 28, NULL, N'Lab', '2026-05-24', N'Completed'),
(127, 15, NULL, 39, N'Imaging', '2026-06-09', N'Completed'),
(128, 15, NULL, 26, N'Lab', '2026-06-04', N'Completed'),
(129, 14, 133, NULL, N'Imaging', '2026-06-05', N'Completed'),
(130, 1, 115, NULL, N'Lab', '2026-06-03', N'Completed'),
(131, 2, NULL, 32, N'Lab', '2026-06-07', N'Completed'),
(132, 2, 105, NULL, N'Lab', '2026-05-30', N'Completed'),
(133, 5, 94, NULL, N'Lab', '2026-06-21', N'Completed'),
(134, 10, 15, NULL, N'Lab', '2026-07-05', N'Completed'),
(135, 7, NULL, 27, N'Lab', '2026-06-05', N'Completed'),
(136, 5, 28, NULL, N'Lab', '2026-05-24', N'Completed'),
(137, 12, 162, NULL, N'Lab', '2026-05-28', N'Completed'),
(138, 9, 76, NULL, N'Imaging', '2026-07-03', N'Completed'),
(139, 9, NULL, 42, N'Lab', '2026-06-10', N'Completed'),
(140, 6, 48, NULL, N'Lab', '2026-05-27', N'Completed'),
(141, 12, 188, NULL, N'Imaging', '2026-06-27', N'Completed'),
(142, 15, NULL, 49, N'Lab', '2026-06-13', N'Completed'),
(143, 1, 184, NULL, N'Lab', '2026-06-20', N'Completed'),
(144, 7, 31, NULL, N'Imaging', '2026-05-28', N'Completed'),
(145, 12, NULL, 41, N'Imaging', '2026-06-09', N'Completed'),
(146, 3, 160, NULL, N'Lab', '2026-07-07', N'Completed'),
(147, 7, 92, NULL, N'Lab', '2026-07-01', N'Completed'),
(148, 3, 81, NULL, N'Lab', '2026-06-25', N'Completed'),
(149, 6, NULL, 56, N'Imaging', '2026-06-16', N'Completed'),
(150, 9, 169, NULL, N'Lab', '2026-06-28', N'Completed');
SET IDENTITY_INSERT [Labimagingrequest] OFF;


GO


-- ============================================================
-- 10b. LAB RESULTS (labalert rows auto-generated by trigger)
-- ============================================================

SET IDENTITY_INSERT [labresult] ON;
INSERT INTO [labresult] ([id], [reportedbyemployeeID], [isCritical], [LabimagingrequestID], [value], [status], [date], [description]) VALUES
(1, 39, 2, 1, N'7.86', N'Completed', '2026-06-10', N'WBC result'),
(2, 41, 1, 2, N'16.3', N'Completed', '2026-05-27', N'Hemoglobin result'),
(3, 39, 2, 3, N'9.5', N'Completed', '2026-07-07', N'WBC result'),
(4, 40, 7, 4, N'293.01', N'Completed', '2026-06-04', N'Platelets result'),
(5, 40, NULL, 5, N'Mild cardiomegaly noted.', N'Completed', '2026-05-28', N'Radiology report'),
(6, 41, NULL, 6, N'No acute abnormality identified.', N'Completed', '2026-06-06', N'Radiology report'),
(7, 40, 1, 7, N'16.64', N'Completed', '2026-06-18', N'Hemoglobin result'),
(8, 39, 4, 8, N'0.91', N'Completed', '2026-07-01', N'Creatinine result'),
(9, 41, 7, 9, N'122.96', N'Completed', '2026-06-20', N'Platelets result'),
(10, 40, 9, 10, N'0.86', N'Completed', '2026-05-28', N'INR result'),
(11, 39, 7, 11, N'157.24', N'Completed', '2026-06-17', N'Platelets result'),
(12, 39, 1, 12, N'17.05', N'Completed', '2026-07-05', N'Hemoglobin result'),
(13, 41, 8, 13, N'0.0', N'Completed', '2026-06-26', N'Troponin result'),
(14, 39, NULL, 14, N'Mild cardiomegaly noted.', N'Completed', '2026-07-06', N'Radiology report'),
(15, 41, NULL, 15, N'No acute abnormality identified.', N'Completed', '2026-05-30', N'Radiology report'),
(16, 39, NULL, 16, N'Mild degenerative changes noted.', N'Completed', '2026-06-06', N'Radiology report'),
(17, 39, 9, 17, N'1.73', N'Completed', '2026-06-19', N'INR result'),
(18, 40, 4, 18, N'0.81', N'Completed', '2026-06-11', N'Creatinine result'),
(19, 40, 7, 19, N'266.67', N'Completed', '2026-06-15', N'Platelets result'),
(20, 41, 7, 20, N'633.97', N'Completed', '2026-06-01', N'Platelets result'),
(21, 40, 5, 21, N'2.96', N'Completed', '2026-06-23', N'Potassium result'),
(22, 40, 5, 22, N'4.93', N'Completed', '2026-06-16', N'Potassium result'),
(23, 39, NULL, 23, N'No fracture or dislocation seen.', N'Completed', '2026-07-06', N'Radiology report'),
(24, 40, 8, 24, N'0.02', N'Completed', '2026-06-23', N'Troponin result'),
(25, 40, 4, 25, N'1.08', N'Completed', '2026-06-26', N'Creatinine result'),
(26, 41, 6, 26, N'143.41', N'Completed', '2026-06-15', N'Sodium result'),
(27, 40, NULL, 27, N'Small pleural effusion identified.', N'Completed', '2026-06-05', N'Radiology report'),
(28, 41, 3, 28, N'85.56', N'Completed', '2026-06-07', N'Glucose result'),
(29, 40, 5, 29, N'4.44', N'Completed', '2026-05-20', N'Potassium result'),
(30, 39, 8, 30, N'0.04', N'Completed', '2026-05-28', N'Troponin result'),
(31, 41, 4, 31, N'0.87', N'Completed', '2026-06-14', N'Creatinine result'),
(32, 39, 3, 32, N'139.1', N'Completed', '2026-07-04', N'Glucose result'),
(33, 39, NULL, 33, N'Findings consistent with clinical presentation.', N'Completed', '2026-05-27', N'Radiology report'),
(34, 39, 1, 34, N'16.19', N'Completed', '2026-06-26', N'Hemoglobin result'),
(35, 40, 3, 35, N'100.36', N'Completed', '2026-05-23', N'Glucose result'),
(36, 40, 8, 36, N'0.0', N'Completed', '2026-05-28', N'Troponin result'),
(37, 39, 9, 37, N'1.05', N'Completed', '2026-07-03', N'INR result'),
(38, 40, NULL, 38, N'No acute abnormality identified.', N'Completed', '2026-05-27', N'Radiology report'),
(39, 39, 2, 39, N'7.19', N'Completed', '2026-06-10', N'WBC result'),
(40, 40, 6, 40, N'138.43', N'Completed', '2026-06-03', N'Sodium result'),
(41, 39, 4, 41, N'0.51', N'Completed', '2026-05-31', N'Creatinine result'),
(42, 39, 9, 42, N'1.06', N'Completed', '2026-05-31', N'INR result'),
(43, 41, 5, 43, N'7.38', N'Completed', '2026-06-26', N'Potassium result'),
(44, 41, 1, 44, N'14.09', N'Completed', '2026-06-16', N'Hemoglobin result'),
(45, 39, 3, 45, N'70.65', N'Completed', '2026-06-07', N'Glucose result'),
(46, 40, 9, 46, N'0.85', N'Completed', '2026-05-28', N'INR result'),
(47, 40, 2, 47, N'7.48', N'Completed', '2026-06-21', N'WBC result'),
(48, 41, NULL, 48, N'Findings consistent with clinical presentation.', N'Completed', '2026-06-10', N'Radiology report'),
(49, 39, NULL, 49, N'No fracture or dislocation seen.', N'Completed', '2026-06-06', N'Radiology report'),
(50, 39, NULL, 50, N'Small pleural effusion identified.', N'Completed', '2026-05-29', N'Radiology report'),
(51, 41, 2, 51, N'2.32', N'Completed', '2026-06-11', N'WBC result'),
(52, 39, 1, 52, N'16.69', N'Completed', '2026-06-04', N'Hemoglobin result'),
(53, 40, 6, 53, N'224.84', N'Completed', '2026-06-08', N'Sodium result'),
(54, 40, 3, 54, N'136.86', N'Completed', '2026-05-24', N'Glucose result'),
(55, 40, 2, 55, N'6.81', N'Completed', '2026-06-18', N'WBC result'),
(56, 41, 7, 56, N'312.21', N'Completed', '2026-05-27', N'Platelets result'),
(57, 39, NULL, 57, N'No fracture or dislocation seen.', N'Completed', '2026-07-03', N'Radiology report'),
(58, 39, 8, 58, N'0.01', N'Completed', '2026-05-31', N'Troponin result'),
(59, 39, 8, 60, N'0.0', N'Completed', '2026-06-04', N'Troponin result'),
(60, 41, 9, 61, N'0.89', N'Completed', '2026-06-18', N'INR result'),
(61, 41, 9, 62, N'0.84', N'Completed', '2026-06-19', N'INR result'),
(62, 40, 8, 63, N'0.02', N'Completed', '2026-06-19', N'Troponin result'),
(63, 39, 1, 64, N'14.78', N'Completed', '2026-06-07', N'Hemoglobin result'),
(64, 39, 3, 65, N'93.16', N'Completed', '2026-05-28', N'Glucose result'),
(65, 41, NULL, 66, N'No fracture or dislocation seen.', N'Completed', '2026-06-11', N'Radiology report'),
(66, 41, NULL, 67, N'No acute abnormality identified.', N'Completed', '2026-06-07', N'Radiology report'),
(67, 41, 8, 68, N'0.0', N'Completed', '2026-05-26', N'Troponin result'),
(68, 41, NULL, 69, N'Small pleural effusion identified.', N'Completed', '2026-06-07', N'Radiology report'),
(69, 40, 8, 70, N'0.03', N'Completed', '2026-06-01', N'Troponin result'),
(70, 41, 8, 71, N'0.02', N'Completed', '2026-05-28', N'Troponin result'),
(71, 39, 4, 72, N'1.04', N'Completed', '2026-06-22', N'Creatinine result'),
(72, 41, 6, 73, N'74.14', N'Completed', '2026-06-05', N'Sodium result'),
(73, 39, NULL, 74, N'No fracture or dislocation seen.', N'Completed', '2026-05-28', N'Radiology report'),
(74, 40, 2, 75, N'9.86', N'Completed', '2026-06-04', N'WBC result'),
(75, 40, NULL, 76, N'Mild cardiomegaly noted.', N'Completed', '2026-06-11', N'Radiology report'),
(76, 41, 1, 77, N'26.73', N'Completed', '2026-05-29', N'Hemoglobin result'),
(77, 41, 3, 78, N'127.07', N'Completed', '2026-05-31', N'Glucose result'),
(78, 41, 6, 79, N'141.09', N'Completed', '2026-06-22', N'Sodium result'),
(79, 40, 6, 80, N'136.38', N'Completed', '2026-05-28', N'Sodium result'),
(80, 40, 9, 81, N'0.93', N'Completed', '2026-06-12', N'INR result'),
(81, 39, 4, 82, N'1.08', N'Completed', '2026-06-07', N'Creatinine result'),
(82, 41, NULL, 83, N'Small pleural effusion identified.', N'Completed', '2026-06-20', N'Radiology report'),
(83, 40, 9, 84, N'1.07', N'Completed', '2026-05-29', N'INR result'),
(84, 40, 9, 85, N'1.01', N'Completed', '2026-06-01', N'INR result'),
(85, 41, 1, 86, N'16.13', N'Completed', '2026-06-26', N'Hemoglobin result'),
(86, 39, 5, 87, N'3.97', N'Completed', '2026-07-03', N'Potassium result'),
(87, 39, NULL, 88, N'Small pleural effusion identified.', N'Completed', '2026-06-06', N'Radiology report'),
(88, 40, 9, 89, N'1.12', N'Completed', '2026-05-19', N'INR result'),
(89, 40, 1, 90, N'16.33', N'Completed', '2026-06-11', N'Hemoglobin result'),
(90, 39, 1, 91, N'15.41', N'Completed', '2026-06-24', N'Hemoglobin result'),
(91, 41, 6, 92, N'136.96', N'Completed', '2026-05-25', N'Sodium result'),
(92, 39, 2, 93, N'4.84', N'Completed', '2026-07-05', N'WBC result'),
(93, 39, 3, 94, N'70.4', N'Completed', '2026-07-07', N'Glucose result'),
(94, 39, 3, 95, N'111.78', N'Completed', '2026-05-27', N'Glucose result'),
(95, 40, 5, 96, N'3.62', N'Completed', '2026-06-14', N'Potassium result'),
(96, 41, 3, 97, N'81.16', N'Completed', '2026-06-09', N'Glucose result'),
(97, 40, 2, 98, N'8.64', N'Completed', '2026-06-05', N'WBC result'),
(98, 41, 4, 99, N'0.99', N'Completed', '2026-05-21', N'Creatinine result'),
(99, 40, NULL, 100, N'Small pleural effusion identified.', N'Completed', '2026-06-15', N'Radiology report'),
(100, 41, NULL, 101, N'No fracture or dislocation seen.', N'Completed', '2026-06-13', N'Radiology report');
INSERT INTO [labresult] ([id], [reportedbyemployeeID], [isCritical], [LabimagingrequestID], [value], [status], [date], [description]) VALUES
(101, 41, 9, 102, N'1.8', N'Completed', '2026-05-28', N'INR result'),
(102, 40, 8, 103, N'0.03', N'Completed', '2026-06-01', N'Troponin result'),
(103, 39, 2, 104, N'8.39', N'Completed', '2026-06-20', N'WBC result'),
(104, 41, 4, 105, N'0.74', N'Completed', '2026-05-26', N'Creatinine result'),
(105, 41, 2, 106, N'7.21', N'Completed', '2026-06-12', N'WBC result'),
(106, 39, NULL, 107, N'Findings consistent with clinical presentation.', N'Completed', '2026-05-19', N'Radiology report'),
(107, 40, 5, 108, N'4.15', N'Completed', '2026-06-09', N'Potassium result'),
(108, 41, NULL, 109, N'Small pleural effusion identified.', N'Completed', '2026-06-22', N'Radiology report'),
(109, 41, 1, 110, N'14.77', N'Completed', '2026-06-29', N'Hemoglobin result'),
(110, 41, 5, 111, N'4.98', N'Completed', '2026-06-05', N'Potassium result'),
(111, 39, 8, 112, N'0.03', N'Completed', '2026-07-07', N'Troponin result'),
(112, 40, 3, 113, N'137.58', N'Completed', '2026-06-07', N'Glucose result'),
(113, 41, 1, 114, N'12.23', N'Completed', '2026-06-17', N'Hemoglobin result'),
(114, 41, 9, 115, N'1.1', N'Completed', '2026-06-07', N'INR result'),
(115, 39, NULL, 116, N'Mild degenerative changes noted.', N'Completed', '2026-05-28', N'Radiology report'),
(116, 41, NULL, 117, N'No acute abnormality identified.', N'Completed', '2026-05-30', N'Radiology report'),
(117, 39, 9, 118, N'0.9', N'Completed', '2026-06-06', N'INR result'),
(118, 40, 8, 119, N'0.03', N'Completed', '2026-06-26', N'Troponin result'),
(119, 39, 2, 120, N'6.3', N'Completed', '2026-07-01', N'WBC result'),
(120, 41, 3, 121, N'92.14', N'Completed', '2026-06-18', N'Glucose result'),
(121, 39, NULL, 122, N'Small pleural effusion identified.', N'Completed', '2026-05-28', N'Radiology report'),
(122, 39, 6, 123, N'143.78', N'Completed', '2026-06-12', N'Sodium result'),
(123, 40, 5, 124, N'6.05', N'Completed', '2026-05-28', N'Potassium result'),
(124, 41, 3, 125, N'132.04', N'Completed', '2026-06-09', N'Glucose result'),
(125, 41, 1, 126, N'23.32', N'Completed', '2026-05-26', N'Hemoglobin result'),
(126, 41, NULL, 127, N'Mild cardiomegaly noted.', N'Completed', '2026-06-10', N'Radiology report'),
(127, 40, 3, 128, N'124.05', N'Completed', '2026-06-05', N'Glucose result'),
(128, 40, 10, 129, N'Mild cardiomegaly noted.', N'Completed', '2026-06-06', N'Radiology report'),
(129, 41, 3, 130, N'82.54', N'Completed', '2026-06-03', N'Glucose result'),
(130, 41, 3, 131, N'95.12', N'Completed', '2026-06-09', N'Glucose result'),
(131, 39, 4, 132, N'0.63', N'Completed', '2026-05-31', N'Creatinine result'),
(132, 40, 6, 133, N'143.82', N'Completed', '2026-06-22', N'Sodium result'),
(133, 41, 9, 134, N'0.91', N'Completed', '2026-07-06', N'INR result'),
(134, 41, 7, 135, N'313.33', N'Completed', '2026-06-06', N'Platelets result'),
(135, 39, 7, 136, N'354.31', N'Completed', '2026-05-26', N'Platelets result'),
(136, 41, 8, 137, N'0.01', N'Completed', '2026-05-28', N'Troponin result'),
(137, 39, NULL, 138, N'Mild degenerative changes noted.', N'Completed', '2026-07-03', N'Radiology report'),
(138, 41, 2, 139, N'6.31', N'Completed', '2026-06-10', N'WBC result'),
(139, 40, 8, 140, N'0.03', N'Completed', '2026-05-27', N'Troponin result'),
(140, 39, NULL, 141, N'Mild cardiomegaly noted.', N'Completed', '2026-06-29', N'Radiology report'),
(141, 39, 3, 142, N'82.6', N'Completed', '2026-06-13', N'Glucose result'),
(142, 41, 1, 143, N'13.56', N'Completed', '2026-06-22', N'Hemoglobin result'),
(143, 40, NULL, 144, N'Mild degenerative changes noted.', N'Completed', '2026-05-28', N'Radiology report'),
(144, 41, NULL, 145, N'Mild cardiomegaly noted.', N'Completed', '2026-06-11', N'Radiology report'),
(145, 39, 2, 146, N'4.76', N'Completed', '2026-07-07', N'WBC result'),
(146, 41, 9, 147, N'1.04', N'Completed', '2026-07-02', N'INR result'),
(147, 41, 1, 148, N'12.51', N'Completed', '2026-06-27', N'Hemoglobin result'),
(148, 41, NULL, 149, N'No fracture or dislocation seen.', N'Completed', '2026-06-18', N'Radiology report'),
(149, 40, 9, 150, N'0.99', N'Completed', '2026-06-28', N'INR result');
SET IDENTITY_INSERT [labresult] OFF;


GO


-- ============================================================
-- 11. DRUG INTERACTIONS
-- ============================================================

SET IDENTITY_INSERT [druginteraction] ON;
INSERT INTO [druginteraction] ([id], [drugID1], [drugID2], [severity], [description]) VALUES
(1, 7, 5, N'Severe', N'Warfarin + NSAID increases bleeding risk significantly.'),
(2, 7, 20, N'Severe', N'Warfarin + Heparin causes additive anticoagulant effect.'),
(3, 3, 13, N'Moderate', N'ACE inhibitor + loop diuretic may cause hypotension/renal effects.'),
(4, 9, 14, N'Moderate', N'Omeprazole may reduce the antiplatelet effect of Clopidogrel.'),
(5, 12, 19, N'Severe', N'Opioid + benzodiazepine combination increases risk of respiratory depression.'),
(6, 4, 17, N'Minor', N'Statin + macrolide may slightly increase statin plasma levels.'),
(7, 16, 3, N'Minor', N'Additive blood-pressure-lowering effect; monitor for hypotension.'),
(8, 10, 2, N'Moderate', N'Combined glucose-lowering effect; monitor for hypoglycemia.');
SET IDENTITY_INSERT [druginteraction] OFF;


GO


-- ============================================================
-- 11b. PRESCRIPTIONS
-- ============================================================

SET IDENTITY_INSERT [prescription] ON;
INSERT INTO [prescription] ([id], [patientID], [employeeID], [appointmentID], [admissionID], [date], [status]) VALUES
(1, N'568-50-2188', 7, 174, NULL, '2026-07-05', N'Dispensed'),
(2, N'323-69-5198', 1, 87, NULL, '2026-06-04', N'Dispensed'),
(3, N'261-17-9320', 12, 196, NULL, '2026-05-28', N'Dispensed'),
(4, N'566-63-4185', 5, 94, NULL, '2026-06-21', N'Dispensed'),
(5, N'901-15-6688', 6, NULL, 56, '2026-06-16', N'Dispensed'),
(6, N'505-92-8517', 3, NULL, 18, '2026-05-31', N'Dispensed'),
(7, N'182-27-3471', 7, 65, NULL, '2026-05-21', N'Dispensed'),
(8, N'242-23-9935', 10, NULL, 55, '2026-06-16', N'Dispensed'),
(9, N'489-22-6881', 9, 79, NULL, '2026-05-23', N'Dispensed'),
(10, N'621-73-2489', 6, 178, NULL, '2026-06-12', N'Dispensed'),
(11, N'919-87-4613', 14, 35, NULL, '2026-06-09', N'Dispensed'),
(12, N'506-35-2245', 1, 44, NULL, '2026-07-02', N'Dispensed'),
(13, N'324-97-6313', 6, NULL, 11, '2026-05-29', N'Pending'),
(14, N'566-63-4185', 4, NULL, 50, '2026-06-14', N'Pending'),
(15, N'182-27-3471', 4, NULL, 20, '2026-06-01', N'Dispensed'),
(16, N'472-65-2146', 8, 164, NULL, '2026-06-16', N'Dispensed'),
(17, N'672-86-6198', 4, 117, NULL, '2026-05-27', N'Pending'),
(18, N'258-34-5861', 15, NULL, 26, '2026-06-04', N'Cancelled'),
(19, N'672-86-6198', 13, 84, NULL, '2026-06-16', N'Cancelled'),
(20, N'506-35-2245', 12, 162, NULL, '2026-05-28', N'Dispensed'),
(21, N'533-45-1722', 8, 40, NULL, '2026-06-30', N'Dispensed'),
(22, N'919-87-4613', 5, 98, NULL, '2026-05-25', N'Dispensed'),
(23, N'509-96-9785', 2, 108, NULL, '2026-06-26', N'Pending'),
(24, N'904-84-6279', 12, NULL, 15, '2026-05-31', N'Dispensed'),
(25, N'472-65-2146', 9, 102, NULL, '2026-06-04', N'Pending'),
(26, N'258-34-5861', 7, 9, NULL, '2026-06-19', N'Dispensed'),
(27, N'242-23-9935', 5, NULL, 60, '2026-06-18', N'Dispensed'),
(28, N'318-61-1960', 6, NULL, 44, '2026-06-10', N'Dispensed'),
(29, N'904-84-6279', 1, 151, NULL, '2026-06-22', N'Dispensed'),
(30, N'672-86-6198', 12, NULL, 38, '2026-06-09', N'Dispensed'),
(31, N'612-32-9317', 12, 30, NULL, '2026-06-24', N'Dispensed'),
(32, N'506-35-2245', 15, 124, NULL, '2026-06-01', N'Dispensed'),
(33, N'230-89-9751', 11, 131, NULL, '2026-07-05', N'Dispensed'),
(34, N'878-78-3060', 5, 13, NULL, '2026-06-14', N'Dispensed'),
(35, N'258-34-5861', 15, NULL, 26, '2026-06-04', N'Dispensed'),
(36, N'578-16-2612', 15, 139, NULL, '2026-06-13', N'Dispensed'),
(37, N'489-22-6881', 8, NULL, 8, '2026-05-27', N'Dispensed'),
(38, N'798-41-2684', 13, NULL, 31, '2026-06-06', N'Dispensed'),
(39, N'506-35-2245', 15, 124, NULL, '2026-06-01', N'Dispensed'),
(40, N'919-87-4613', 6, 58, NULL, '2026-05-27', N'Dispensed'),
(41, N'904-84-6279', 13, 41, NULL, '2026-06-21', N'Dispensed'),
(42, N'323-69-5198', 14, 68, NULL, '2026-06-27', N'Dispensed'),
(43, N'904-84-6279', 12, NULL, 15, '2026-05-31', N'Cancelled'),
(44, N'904-84-6279', 7, NULL, 27, '2026-06-05', N'Dispensed'),
(45, N'672-86-6198', 4, 117, NULL, '2026-05-27', N'Dispensed'),
(46, N'734-20-7868', 8, 176, NULL, '2026-06-09', N'Dispensed'),
(47, N'533-45-1722', 3, 166, NULL, '2026-06-06', N'Pending'),
(48, N'316-68-6355', 8, 116, NULL, '2026-06-26', N'Dispensed'),
(49, N'230-89-9751', 12, 34, NULL, '2026-05-31', N'Dispensed'),
(50, N'578-16-2612', 10, NULL, 25, '2026-06-03', N'Pending'),
(51, N'489-22-6881', 8, NULL, 53, '2026-06-15', N'Pending'),
(52, N'981-11-2876', 10, 15, NULL, '2026-07-05', N'Dispensed'),
(53, N'266-57-6820', 14, 163, NULL, '2026-06-30', N'Dispensed'),
(54, N'904-84-6279', 9, 134, NULL, '2026-06-04', N'Pending'),
(55, N'919-87-4613', 12, 25, NULL, '2026-06-29', N'Dispensed'),
(56, N'612-32-9317', 14, NULL, 21, '2026-06-01', N'Dispensed'),
(57, N'506-35-2245', 1, 44, NULL, '2026-07-02', N'Dispensed'),
(58, N'261-17-9320', 12, NULL, 13, '2026-05-30', N'Dispensed'),
(59, N'612-32-9317', 12, 30, NULL, '2026-06-24', N'Dispensed'),
(60, N'242-23-9935', 15, 138, NULL, '2026-06-14', N'Dispensed'),
(61, N'323-69-5198', 15, 109, NULL, '2026-06-26', N'Dispensed'),
(62, N'316-68-6355', 9, NULL, 48, '2026-06-12', N'Cancelled'),
(63, N'672-86-6198', 13, 84, NULL, '2026-06-16', N'Dispensed'),
(64, N'566-63-4185', 4, NULL, 50, '2026-06-14', N'Dispensed'),
(65, N'230-34-7888', 6, 2, NULL, '2026-05-27', N'Pending'),
(66, N'807-29-9938', 2, 105, NULL, '2026-05-30', N'Dispensed'),
(67, N'505-92-8517', 9, 69, NULL, '2026-06-27', N'Dispensed'),
(68, N'355-19-8260', 4, 180, NULL, '2026-06-06', N'Dispensed'),
(69, N'230-89-9751', 11, NULL, 12, '2026-05-29', N'Pending'),
(70, N'854-52-7745', 7, 198, NULL, '2026-06-10', N'Dispensed'),
(71, N'578-16-2612', 15, NULL, 49, '2026-06-13', N'Dispensed'),
(72, N'546-87-9379', 13, 18, NULL, '2026-06-11', N'Dispensed'),
(73, N'897-64-4585', 8, 177, NULL, '2026-06-18', N'Dispensed'),
(74, N'355-19-8260', 4, 180, NULL, '2026-06-06', N'Dispensed'),
(75, N'355-19-8260', 1, 27, NULL, '2026-06-14', N'Dispensed'),
(76, N'266-57-6820', 14, 163, NULL, '2026-06-30', N'Dispensed'),
(77, N'182-27-3471', 7, 65, NULL, '2026-05-21', N'Dispensed'),
(78, N'878-78-3060', 7, 31, NULL, '2026-05-28', N'Dispensed'),
(79, N'533-45-1722', 5, 132, NULL, '2026-06-10', N'Dispensed'),
(80, N'324-97-6313', 6, NULL, 11, '2026-05-29', N'Dispensed'),
(81, N'489-22-6881', 9, 79, NULL, '2026-05-23', N'Dispensed'),
(82, N'242-23-9935', 10, NULL, 55, '2026-06-16', N'Cancelled'),
(83, N'506-35-2245', 1, 44, NULL, '2026-07-02', N'Dispensed'),
(84, N'258-34-5861', 7, 9, NULL, '2026-06-19', N'Dispensed'),
(85, N'470-91-8532', 4, 127, NULL, '2026-05-25', N'Pending'),
(86, N'568-50-2188', 7, 174, NULL, '2026-07-05', N'Dispensed'),
(87, N'242-23-9935', 10, NULL, 55, '2026-06-16', N'Dispensed'),
(88, N'854-52-7745', 11, 152, NULL, '2026-06-09', N'Pending'),
(89, N'242-23-9935', 15, 138, NULL, '2026-06-14', N'Dispensed'),
(90, N'323-69-5198', 15, 109, NULL, '2026-06-26', N'Dispensed'),
(91, N'568-50-2188', 12, NULL, 16, '2026-05-31', N'Pending'),
(92, N'672-86-6198', 5, 107, NULL, '2026-05-19', N'Dispensed'),
(93, N'390-75-6491', 15, NULL, 59, '2026-06-17', N'Cancelled'),
(94, N'854-52-7745', 12, NULL, 45, '2026-06-11', N'Dispensed'),
(95, N'904-84-6279', 1, 151, NULL, '2026-06-22', N'Dispensed'),
(96, N'578-16-2612', 10, NULL, 25, '2026-06-03', N'Dispensed'),
(97, N'830-49-7537', 9, 76, NULL, '2026-07-03', N'Dispensed'),
(98, N'458-49-4728', 12, 188, NULL, '2026-06-27', N'Dispensed'),
(99, N'807-29-9938', 4, NULL, 4, '2026-05-26', N'Dispensed'),
(100, N'702-38-1117', 13, NULL, 22, '2026-06-02', N'Pending');
SET IDENTITY_INSERT [prescription] OFF;


GO


-- ============================================================
-- 11c. PRESCRIPTION ITEMS
-- ============================================================

SET IDENTITY_INSERT [prescriptionitem] ON;
INSERT INTO [prescriptionitem] ([id], [prescriptionID], [drugID], [dose], [duration], [quantity]) VALUES
(1, 1, 19, N'1 tablet', N'14 days', 31),
(2, 1, 4, N'2 tablets', N'5 days', 19),
(3, 1, 14, N'40mg', N'Once daily ongoing', 17),
(4, 2, 1, N'250mg', N'3 days', 25),
(5, 2, 19, N'2 tablets', N'30 days', 27),
(6, 2, 17, N'20mg', N'5 days', 10),
(7, 3, 9, N'5mg', N'30 days', 40),
(8, 3, 18, N'10mg', N'Once daily ongoing', 49),
(9, 4, 16, N'1 vial', N'As needed', 17),
(10, 4, 6, N'10mg', N'30 days', 50),
(11, 4, 12, N'5mg', N'7 days', 55),
(12, 5, 15, N'1 tablet', N'5 days', 14),
(13, 6, 18, N'500mg', N'7 days', 25),
(14, 6, 20, N'500mg', N'5 days', 53),
(15, 7, 14, N'2 tablets', N'30 days', 6),
(16, 7, 3, N'40mg', N'3 days', 47),
(17, 7, 9, N'5mg', N'Once daily ongoing', 40),
(18, 8, 20, N'1 puff', N'As needed', 1),
(19, 8, 2, N'2 tablets', N'14 days', 13),
(20, 8, 6, N'500mg', N'10 days', 40),
(21, 9, 8, N'1 tablet', N'5 days', 18),
(22, 9, 1, N'5mg', N'30 days', 43),
(23, 10, 17, N'500mg', N'5 days', 59),
(24, 11, 18, N'2 tablets', N'10 days', 30),
(25, 11, 19, N'5mg', N'3 days', 17),
(26, 11, 9, N'1 tablet', N'Once daily ongoing', 33),
(27, 12, 10, N'1 vial', N'14 days', 57),
(28, 12, 11, N'1 vial', N'14 days', 45),
(29, 12, 4, N'1 puff', N'Once daily ongoing', 37),
(30, 13, 15, N'500mg', N'As needed', 8),
(31, 13, 19, N'10mg', N'5 days', 25),
(32, 14, 8, N'20mg', N'Once daily ongoing', 23),
(33, 15, 9, N'250mg', N'Once daily ongoing', 44),
(34, 15, 8, N'20mg', N'5 days', 36),
(35, 15, 10, N'1 tablet', N'As needed', 21),
(36, 16, 9, N'1 puff', N'10 days', 16),
(37, 16, 6, N'2 tablets', N'14 days', 14),
(38, 16, 7, N'2 tablets', N'10 days', 54),
(39, 17, 5, N'250mg', N'5 days', 44),
(40, 17, 4, N'1 puff', N'3 days', 49),
(41, 18, 12, N'20mg', N'As needed', 58),
(42, 18, 20, N'40mg', N'14 days', 32),
(43, 19, 9, N'40mg', N'7 days', 4),
(44, 19, 13, N'1 vial', N'Once daily ongoing', 31),
(45, 19, 8, N'1 vial', N'3 days', 33),
(46, 20, 6, N'1 vial', N'As needed', 21),
(47, 20, 15, N'500mg', N'3 days', 44),
(48, 20, 4, N'2 tablets', N'Once daily ongoing', 38),
(49, 21, 9, N'10mg', N'10 days', 18),
(50, 21, 6, N'1 puff', N'30 days', 24),
(51, 21, 18, N'1 tablet', N'As needed', 28),
(52, 22, 12, N'10mg', N'As needed', 12),
(53, 22, 13, N'40mg', N'7 days', 37),
(54, 23, 9, N'5mg', N'Once daily ongoing', 13),
(55, 23, 8, N'1 tablet', N'7 days', 31),
(56, 23, 18, N'500mg', N'7 days', 27),
(57, 24, 17, N'1 puff', N'14 days', 17),
(58, 24, 18, N'1 vial', N'3 days', 26),
(59, 24, 11, N'250mg', N'7 days', 4),
(60, 25, 4, N'20mg', N'14 days', 24),
(61, 25, 15, N'20mg', N'14 days', 23),
(62, 26, 20, N'40mg', N'7 days', 50),
(63, 26, 19, N'10mg', N'30 days', 21),
(64, 27, 15, N'40mg', N'14 days', 30),
(65, 27, 3, N'1 tablet', N'7 days', 41),
(66, 27, 13, N'20mg', N'Once daily ongoing', 41),
(67, 28, 3, N'1 tablet', N'30 days', 15),
(68, 29, 9, N'5mg', N'14 days', 57),
(69, 29, 20, N'1 puff', N'30 days', 48),
(70, 30, 14, N'1 tablet', N'3 days', 9),
(71, 30, 6, N'2 tablets', N'14 days', 48),
(72, 31, 4, N'1 puff', N'3 days', 2),
(73, 31, 3, N'5mg', N'5 days', 7),
(74, 32, 13, N'10mg', N'10 days', 16),
(75, 33, 5, N'1 vial', N'7 days', 2),
(76, 34, 16, N'1 vial', N'14 days', 36),
(77, 34, 15, N'1 puff', N'7 days', 45),
(78, 35, 15, N'1 vial', N'14 days', 59),
(79, 35, 19, N'20mg', N'As needed', 35),
(80, 35, 14, N'2 tablets', N'5 days', 29),
(81, 36, 5, N'500mg', N'3 days', 34),
(82, 36, 10, N'1 tablet', N'30 days', 19),
(83, 37, 16, N'5mg', N'14 days', 39),
(84, 37, 10, N'2 tablets', N'3 days', 36),
(85, 37, 1, N'20mg', N'10 days', 27),
(86, 38, 6, N'5mg', N'Once daily ongoing', 15),
(87, 39, 8, N'10mg', N'14 days', 42),
(88, 39, 17, N'1 vial', N'14 days', 27),
(89, 39, 20, N'2 tablets', N'5 days', 12),
(90, 40, 15, N'40mg', N'As needed', 13),
(91, 40, 20, N'20mg', N'3 days', 10),
(92, 40, 9, N'500mg', N'3 days', 12),
(93, 41, 15, N'500mg', N'10 days', 6),
(94, 42, 11, N'5mg', N'14 days', 51),
(95, 43, 2, N'250mg', N'7 days', 4),
(96, 43, 11, N'10mg', N'Once daily ongoing', 5),
(97, 44, 9, N'5mg', N'3 days', 8),
(98, 45, 8, N'2 tablets', N'As needed', 48),
(99, 45, 2, N'250mg', N'10 days', 31),
(100, 46, 11, N'500mg', N'5 days', 17);
INSERT INTO [prescriptionitem] ([id], [prescriptionID], [drugID], [dose], [duration], [quantity]) VALUES
(101, 46, 6, N'1 puff', N'14 days', 13),
(102, 47, 7, N'5mg', N'30 days', 1),
(103, 47, 4, N'1 tablet', N'14 days', 38),
(104, 47, 8, N'250mg', N'Once daily ongoing', 51),
(105, 48, 19, N'1 puff', N'7 days', 24),
(106, 49, 3, N'20mg', N'3 days', 4),
(107, 49, 20, N'20mg', N'7 days', 45),
(108, 50, 16, N'2 tablets', N'30 days', 36),
(109, 51, 7, N'5mg', N'30 days', 47),
(110, 51, 1, N'1 tablet', N'14 days', 58),
(111, 52, 18, N'1 vial', N'As needed', 13),
(112, 52, 10, N'40mg', N'7 days', 35),
(113, 53, 9, N'1 vial', N'7 days', 5),
(114, 53, 20, N'1 vial', N'7 days', 29),
(115, 54, 12, N'1 vial', N'Once daily ongoing', 47),
(116, 54, 15, N'1 tablet', N'3 days', 40),
(117, 54, 1, N'20mg', N'10 days', 21),
(118, 55, 13, N'1 puff', N'7 days', 40),
(119, 55, 7, N'10mg', N'30 days', 27),
(120, 55, 17, N'20mg', N'5 days', 7),
(121, 56, 5, N'1 tablet', N'3 days', 13),
(122, 57, 2, N'40mg', N'Once daily ongoing', 43),
(123, 58, 19, N'20mg', N'10 days', 39),
(124, 58, 9, N'250mg', N'3 days', 60),
(125, 58, 2, N'2 tablets', N'As needed', 60),
(126, 59, 2, N'5mg', N'30 days', 51),
(127, 59, 12, N'500mg', N'14 days', 34),
(128, 59, 18, N'500mg', N'5 days', 54),
(129, 60, 17, N'250mg', N'5 days', 47),
(130, 61, 7, N'1 vial', N'10 days', 37),
(131, 62, 18, N'40mg', N'30 days', 44),
(132, 62, 14, N'1 puff', N'Once daily ongoing', 57),
(133, 62, 4, N'250mg', N'7 days', 51),
(134, 63, 11, N'40mg', N'As needed', 60),
(135, 63, 6, N'20mg', N'30 days', 36),
(136, 63, 18, N'20mg', N'30 days', 27),
(137, 64, 11, N'40mg', N'10 days', 25),
(138, 64, 20, N'1 vial', N'14 days', 24),
(139, 64, 8, N'1 puff', N'As needed', 26),
(140, 65, 20, N'1 vial', N'7 days', 57),
(141, 65, 1, N'10mg', N'3 days', 20),
(142, 66, 1, N'1 vial', N'7 days', 7),
(143, 66, 9, N'500mg', N'As needed', 23),
(144, 67, 19, N'2 tablets', N'14 days', 52),
(145, 67, 8, N'10mg', N'5 days', 37),
(146, 68, 3, N'20mg', N'As needed', 12),
(147, 69, 19, N'10mg', N'3 days', 47),
(148, 69, 4, N'40mg', N'Once daily ongoing', 6),
(149, 69, 20, N'500mg', N'30 days', 23),
(150, 70, 8, N'40mg', N'3 days', 41),
(151, 71, 17, N'20mg', N'7 days', 21),
(152, 71, 2, N'1 vial', N'10 days', 10),
(153, 72, 15, N'40mg', N'5 days', 15),
(154, 72, 20, N'5mg', N'14 days', 51),
(155, 73, 3, N'40mg', N'3 days', 36),
(156, 73, 16, N'5mg', N'14 days', 6),
(157, 74, 5, N'2 tablets', N'As needed', 26),
(158, 74, 16, N'40mg', N'10 days', 36),
(159, 74, 18, N'40mg', N'10 days', 16),
(160, 75, 11, N'250mg', N'5 days', 43),
(161, 75, 19, N'5mg', N'Once daily ongoing', 24),
(162, 76, 20, N'10mg', N'7 days', 23),
(163, 76, 1, N'40mg', N'As needed', 40),
(164, 77, 7, N'20mg', N'7 days', 49),
(165, 78, 8, N'40mg', N'7 days', 56),
(166, 79, 4, N'1 puff', N'3 days', 22),
(167, 79, 10, N'2 tablets', N'10 days', 14),
(168, 79, 15, N'1 vial', N'14 days', 36),
(169, 80, 1, N'5mg', N'3 days', 17),
(170, 81, 20, N'10mg', N'3 days', 30),
(171, 82, 13, N'10mg', N'30 days', 56),
(172, 83, 13, N'250mg', N'30 days', 32),
(173, 83, 8, N'40mg', N'5 days', 12),
(174, 83, 17, N'2 tablets', N'As needed', 36),
(175, 84, 10, N'5mg', N'7 days', 2),
(176, 84, 11, N'20mg', N'30 days', 23),
(177, 84, 16, N'10mg', N'10 days', 33),
(178, 85, 9, N'1 vial', N'14 days', 15),
(179, 85, 13, N'1 tablet', N'30 days', 58),
(180, 85, 1, N'5mg', N'7 days', 6),
(181, 86, 20, N'2 tablets', N'7 days', 28),
(182, 86, 8, N'10mg', N'30 days', 29),
(183, 86, 14, N'1 vial', N'7 days', 14),
(184, 87, 7, N'1 tablet', N'Once daily ongoing', 59),
(185, 87, 10, N'1 tablet', N'7 days', 21),
(186, 87, 17, N'250mg', N'5 days', 12),
(187, 88, 1, N'20mg', N'Once daily ongoing', 27),
(188, 89, 9, N'1 tablet', N'7 days', 2),
(189, 89, 5, N'40mg', N'14 days', 39),
(190, 89, 4, N'40mg', N'10 days', 39),
(191, 90, 12, N'250mg', N'As needed', 9),
(192, 91, 12, N'5mg', N'As needed', 31),
(193, 91, 6, N'1 tablet', N'7 days', 13),
(194, 92, 9, N'5mg', N'10 days', 48),
(195, 93, 3, N'1 tablet', N'As needed', 56),
(196, 94, 15, N'5mg', N'Once daily ongoing', 50),
(197, 94, 8, N'500mg', N'Once daily ongoing', 47),
(198, 95, 19, N'1 vial', N'3 days', 34),
(199, 95, 20, N'250mg', N'As needed', 30),
(200, 95, 18, N'500mg', N'10 days', 34);
INSERT INTO [prescriptionitem] ([id], [prescriptionID], [drugID], [dose], [duration], [quantity]) VALUES
(201, 96, 2, N'1 vial', N'3 days', 13),
(202, 96, 18, N'10mg', N'As needed', 26),
(203, 96, 13, N'10mg', N'14 days', 30),
(204, 97, 2, N'1 puff', N'As needed', 6),
(205, 97, 17, N'1 vial', N'5 days', 12),
(206, 97, 5, N'40mg', N'7 days', 26),
(207, 98, 6, N'1 puff', N'10 days', 57),
(208, 99, 6, N'250mg', N'5 days', 46),
(209, 99, 4, N'1 puff', N'30 days', 6),
(210, 100, 17, N'5mg', N'Once daily ongoing', 3),
(211, 100, 20, N'1 tablet', N'30 days', 37),
(212, 100, 6, N'1 tablet', N'7 days', 56);
SET IDENTITY_INSERT [prescriptionitem] OFF;


GO


-- ============================================================
-- 12. PHARMACY STOCK TRANSACTIONS (inventory auto-updated by trigger)
-- ============================================================

SET IDENTITY_INSERT [storage_transaction] ON;
INSERT INTO [storage_transaction] ([id], [drugID], [storageID], [date], [type], [quantity], [reason]) VALUES
(1, 1, 1, '2026-05-08', N'IN', 448, N'Initial stock receipt'),
(2, 2, 1, '2026-05-08', N'IN', 483, N'Initial stock receipt'),
(3, 3, 1, '2026-05-08', N'IN', 352, N'Initial stock receipt'),
(4, 4, 1, '2026-05-08', N'IN', 729, N'Initial stock receipt'),
(5, 5, 1, '2026-05-08', N'IN', 615, N'Initial stock receipt'),
(6, 6, 1, '2026-05-08', N'IN', 616, N'Initial stock receipt'),
(7, 7, 1, '2026-05-08', N'IN', 756, N'Initial stock receipt'),
(8, 8, 1, '2026-05-08', N'IN', 595, N'Initial stock receipt'),
(9, 9, 1, '2026-05-08', N'IN', 941, N'Initial stock receipt'),
(10, 10, 1, '2026-05-08', N'IN', 485, N'Initial stock receipt'),
(11, 11, 1, '2026-05-08', N'IN', 420, N'Initial stock receipt'),
(12, 12, 1, '2026-05-08', N'IN', 434, N'Initial stock receipt'),
(13, 13, 1, '2026-05-08', N'IN', 507, N'Initial stock receipt'),
(14, 14, 1, '2026-05-08', N'IN', 303, N'Initial stock receipt'),
(15, 15, 1, '2026-05-08', N'IN', 937, N'Initial stock receipt'),
(16, 16, 1, '2026-05-08', N'IN', 559, N'Initial stock receipt'),
(17, 17, 1, '2026-05-08', N'IN', 312, N'Initial stock receipt'),
(18, 18, 1, '2026-05-08', N'IN', 769, N'Initial stock receipt'),
(19, 19, 1, '2026-05-08', N'IN', 809, N'Initial stock receipt'),
(20, 20, 1, '2026-05-08', N'IN', 810, N'Initial stock receipt'),
(21, 17, 1, '2026-07-02', N'IN', 352, N'Restock'),
(22, 4, 1, '2026-06-19', N'IN', 343, N'Restock'),
(23, 11, 1, '2026-06-06', N'IN', 326, N'Restock'),
(24, 2, 1, '2026-05-25', N'IN', 103, N'Restock'),
(25, 4, 1, '2026-05-28', N'IN', 242, N'Restock'),
(26, 17, 1, '2026-06-19', N'IN', 125, N'Restock'),
(27, 3, 1, '2026-06-23', N'IN', 128, N'Restock'),
(28, 6, 1, '2026-06-30', N'IN', 174, N'Restock'),
(29, 1, 1, '2026-05-21', N'IN', 395, N'Restock'),
(30, 5, 1, '2026-06-11', N'IN', 144, N'Restock'),
(31, 1, 1, '2026-06-26', N'IN', 313, N'Restock'),
(32, 3, 1, '2026-06-22', N'IN', 245, N'Restock'),
(33, 17, 1, '2026-06-21', N'IN', 333, N'Restock'),
(34, 6, 1, '2026-06-30', N'IN', 147, N'Restock'),
(35, 5, 1, '2026-06-12', N'IN', 288, N'Restock'),
(36, 12, 2, '2026-05-09', N'IN', 77, N'Ward stock allocation'),
(37, 20, 2, '2026-05-09', N'IN', 44, N'Ward stock allocation'),
(38, 6, 2, '2026-05-09', N'IN', 72, N'Ward stock allocation'),
(39, 5, 2, '2026-05-09', N'IN', 24, N'Ward stock allocation'),
(40, 13, 2, '2026-05-09', N'IN', 68, N'Ward stock allocation'),
(41, 8, 2, '2026-05-09', N'IN', 47, N'Ward stock allocation'),
(42, 12, 3, '2026-05-09', N'IN', 73, N'Ward stock allocation'),
(43, 20, 3, '2026-05-09', N'IN', 55, N'Ward stock allocation'),
(44, 6, 3, '2026-05-09', N'IN', 24, N'Ward stock allocation'),
(45, 5, 3, '2026-05-09', N'IN', 38, N'Ward stock allocation'),
(46, 13, 3, '2026-05-09', N'IN', 50, N'Ward stock allocation'),
(47, 8, 3, '2026-05-09', N'IN', 28, N'Ward stock allocation'),
(48, 12, 4, '2026-05-09', N'IN', 27, N'Ward stock allocation'),
(49, 20, 4, '2026-05-09', N'IN', 64, N'Ward stock allocation'),
(50, 6, 4, '2026-05-09', N'IN', 75, N'Ward stock allocation'),
(51, 5, 4, '2026-05-09', N'IN', 37, N'Ward stock allocation'),
(52, 13, 4, '2026-05-09', N'IN', 41, N'Ward stock allocation'),
(53, 8, 4, '2026-05-09', N'IN', 53, N'Ward stock allocation'),
(54, 19, 1, '2026-07-06', N'OUT', 31, N'Dispense prescription #1'),
(55, 4, 1, '2026-07-05', N'OUT', 19, N'Dispense prescription #1'),
(56, 14, 1, '2026-07-05', N'OUT', 17, N'Dispense prescription #1'),
(57, 1, 1, '2026-06-04', N'OUT', 25, N'Dispense prescription #2'),
(58, 19, 1, '2026-06-04', N'OUT', 27, N'Dispense prescription #2'),
(59, 17, 1, '2026-06-04', N'OUT', 10, N'Dispense prescription #2'),
(60, 9, 1, '2026-05-29', N'OUT', 40, N'Dispense prescription #3'),
(61, 18, 1, '2026-05-29', N'OUT', 49, N'Dispense prescription #3'),
(62, 16, 1, '2026-06-22', N'OUT', 17, N'Dispense prescription #4'),
(63, 6, 1, '2026-06-22', N'OUT', 50, N'Dispense prescription #4'),
(64, 12, 1, '2026-06-22', N'OUT', 55, N'Dispense prescription #4'),
(65, 15, 1, '2026-06-17', N'OUT', 14, N'Dispense prescription #5'),
(66, 18, 1, '2026-05-31', N'OUT', 25, N'Dispense prescription #6'),
(67, 20, 1, '2026-06-01', N'OUT', 53, N'Dispense prescription #6'),
(68, 14, 1, '2026-05-22', N'OUT', 6, N'Dispense prescription #7'),
(69, 3, 1, '2026-05-22', N'OUT', 47, N'Dispense prescription #7'),
(70, 9, 1, '2026-05-21', N'OUT', 40, N'Dispense prescription #7'),
(71, 20, 1, '2026-06-16', N'OUT', 1, N'Dispense prescription #8'),
(72, 2, 1, '2026-06-17', N'OUT', 13, N'Dispense prescription #8'),
(73, 6, 1, '2026-06-16', N'OUT', 40, N'Dispense prescription #8'),
(74, 8, 1, '2026-05-23', N'OUT', 18, N'Dispense prescription #9'),
(75, 1, 1, '2026-05-23', N'OUT', 43, N'Dispense prescription #9'),
(76, 17, 1, '2026-06-12', N'OUT', 59, N'Dispense prescription #10'),
(77, 18, 1, '2026-06-10', N'OUT', 30, N'Dispense prescription #11'),
(78, 19, 1, '2026-06-09', N'OUT', 17, N'Dispense prescription #11'),
(79, 9, 1, '2026-06-09', N'OUT', 33, N'Dispense prescription #11'),
(80, 10, 1, '2026-07-03', N'OUT', 57, N'Dispense prescription #12'),
(81, 11, 1, '2026-07-03', N'OUT', 45, N'Dispense prescription #12'),
(82, 4, 1, '2026-07-02', N'OUT', 37, N'Dispense prescription #12'),
(83, 9, 1, '2026-06-02', N'OUT', 44, N'Dispense prescription #15'),
(84, 8, 1, '2026-06-02', N'OUT', 36, N'Dispense prescription #15'),
(85, 10, 1, '2026-06-01', N'OUT', 21, N'Dispense prescription #15'),
(86, 9, 1, '2026-06-16', N'OUT', 16, N'Dispense prescription #16'),
(87, 6, 1, '2026-06-16', N'OUT', 14, N'Dispense prescription #16'),
(88, 7, 1, '2026-06-17', N'OUT', 54, N'Dispense prescription #16'),
(89, 6, 1, '2026-05-29', N'OUT', 21, N'Dispense prescription #20'),
(90, 15, 1, '2026-05-28', N'OUT', 44, N'Dispense prescription #20'),
(91, 4, 1, '2026-05-29', N'OUT', 38, N'Dispense prescription #20'),
(92, 9, 1, '2026-07-01', N'OUT', 18, N'Dispense prescription #21'),
(93, 6, 1, '2026-07-01', N'OUT', 24, N'Dispense prescription #21'),
(94, 18, 1, '2026-06-30', N'OUT', 28, N'Dispense prescription #21'),
(95, 12, 1, '2026-05-25', N'OUT', 12, N'Dispense prescription #22'),
(96, 13, 1, '2026-05-26', N'OUT', 37, N'Dispense prescription #22'),
(97, 17, 1, '2026-06-01', N'OUT', 17, N'Dispense prescription #24'),
(98, 18, 1, '2026-06-01', N'OUT', 26, N'Dispense prescription #24'),
(99, 11, 1, '2026-05-31', N'OUT', 4, N'Dispense prescription #24'),
(100, 20, 1, '2026-06-19', N'OUT', 50, N'Dispense prescription #26');
INSERT INTO [storage_transaction] ([id], [drugID], [storageID], [date], [type], [quantity], [reason]) VALUES
(101, 19, 1, '2026-06-19', N'OUT', 21, N'Dispense prescription #26'),
(102, 15, 1, '2026-06-19', N'OUT', 30, N'Dispense prescription #27'),
(103, 3, 1, '2026-06-19', N'OUT', 41, N'Dispense prescription #27'),
(104, 13, 1, '2026-06-19', N'OUT', 41, N'Dispense prescription #27'),
(105, 3, 1, '2026-06-11', N'OUT', 15, N'Dispense prescription #28'),
(106, 9, 1, '2026-06-22', N'OUT', 57, N'Dispense prescription #29'),
(107, 20, 1, '2026-06-22', N'OUT', 48, N'Dispense prescription #29'),
(108, 14, 1, '2026-06-10', N'OUT', 9, N'Dispense prescription #30'),
(109, 6, 1, '2026-06-09', N'OUT', 48, N'Dispense prescription #30'),
(110, 4, 1, '2026-06-25', N'OUT', 2, N'Dispense prescription #31'),
(111, 3, 1, '2026-06-25', N'OUT', 7, N'Dispense prescription #31'),
(112, 13, 1, '2026-06-02', N'OUT', 16, N'Dispense prescription #32'),
(113, 5, 1, '2026-07-06', N'OUT', 2, N'Dispense prescription #33'),
(114, 16, 1, '2026-06-14', N'OUT', 36, N'Dispense prescription #34'),
(115, 15, 1, '2026-06-15', N'OUT', 45, N'Dispense prescription #34'),
(116, 15, 1, '2026-06-05', N'OUT', 59, N'Dispense prescription #35'),
(117, 19, 1, '2026-06-04', N'OUT', 35, N'Dispense prescription #35'),
(118, 14, 1, '2026-06-04', N'OUT', 29, N'Dispense prescription #35'),
(119, 5, 1, '2026-06-14', N'OUT', 34, N'Dispense prescription #36'),
(120, 10, 1, '2026-06-14', N'OUT', 19, N'Dispense prescription #36'),
(121, 16, 1, '2026-05-27', N'OUT', 39, N'Dispense prescription #37'),
(122, 10, 1, '2026-05-27', N'OUT', 36, N'Dispense prescription #37'),
(123, 1, 1, '2026-05-28', N'OUT', 27, N'Dispense prescription #37'),
(124, 6, 1, '2026-06-06', N'OUT', 15, N'Dispense prescription #38'),
(125, 8, 1, '2026-06-02', N'OUT', 42, N'Dispense prescription #39'),
(126, 17, 1, '2026-06-02', N'OUT', 27, N'Dispense prescription #39'),
(127, 20, 1, '2026-06-01', N'OUT', 12, N'Dispense prescription #39'),
(128, 15, 1, '2026-05-28', N'OUT', 13, N'Dispense prescription #40'),
(129, 20, 1, '2026-05-27', N'OUT', 10, N'Dispense prescription #40'),
(130, 9, 1, '2026-05-27', N'OUT', 12, N'Dispense prescription #40'),
(131, 15, 1, '2026-06-22', N'OUT', 6, N'Dispense prescription #41'),
(132, 11, 1, '2026-06-28', N'OUT', 51, N'Dispense prescription #42'),
(133, 9, 1, '2026-06-05', N'OUT', 8, N'Dispense prescription #44'),
(134, 8, 1, '2026-05-28', N'OUT', 48, N'Dispense prescription #45'),
(135, 2, 1, '2026-05-28', N'OUT', 31, N'Dispense prescription #45'),
(136, 11, 1, '2026-06-09', N'OUT', 17, N'Dispense prescription #46'),
(137, 6, 1, '2026-06-10', N'OUT', 13, N'Dispense prescription #46'),
(138, 19, 1, '2026-06-26', N'OUT', 24, N'Dispense prescription #48'),
(139, 3, 1, '2026-06-01', N'OUT', 4, N'Dispense prescription #49'),
(140, 20, 1, '2026-06-01', N'OUT', 45, N'Dispense prescription #49'),
(141, 18, 1, '2026-07-06', N'OUT', 13, N'Dispense prescription #52'),
(142, 10, 1, '2026-07-05', N'OUT', 35, N'Dispense prescription #52'),
(143, 9, 1, '2026-07-01', N'OUT', 5, N'Dispense prescription #53'),
(144, 20, 1, '2026-06-30', N'OUT', 29, N'Dispense prescription #53'),
(145, 13, 1, '2026-06-29', N'OUT', 40, N'Dispense prescription #55'),
(146, 7, 1, '2026-06-30', N'OUT', 27, N'Dispense prescription #55'),
(147, 17, 1, '2026-06-29', N'OUT', 7, N'Dispense prescription #55'),
(148, 5, 1, '2026-06-01', N'OUT', 13, N'Dispense prescription #56'),
(149, 2, 1, '2026-07-02', N'OUT', 43, N'Dispense prescription #57'),
(150, 19, 1, '2026-05-31', N'OUT', 39, N'Dispense prescription #58'),
(151, 9, 1, '2026-05-30', N'OUT', 60, N'Dispense prescription #58'),
(152, 2, 1, '2026-05-31', N'OUT', 60, N'Dispense prescription #58'),
(153, 2, 1, '2026-06-24', N'OUT', 51, N'Dispense prescription #59'),
(154, 12, 1, '2026-06-24', N'OUT', 34, N'Dispense prescription #59'),
(155, 18, 1, '2026-06-25', N'OUT', 54, N'Dispense prescription #59'),
(156, 17, 1, '2026-06-15', N'OUT', 47, N'Dispense prescription #60'),
(157, 7, 1, '2026-06-27', N'OUT', 37, N'Dispense prescription #61'),
(158, 11, 1, '2026-06-17', N'OUT', 60, N'Dispense prescription #63'),
(159, 6, 1, '2026-06-16', N'OUT', 36, N'Dispense prescription #63'),
(160, 18, 1, '2026-06-16', N'OUT', 27, N'Dispense prescription #63'),
(161, 11, 1, '2026-06-14', N'OUT', 25, N'Dispense prescription #64'),
(162, 20, 1, '2026-06-14', N'OUT', 24, N'Dispense prescription #64'),
(163, 8, 1, '2026-06-14', N'OUT', 26, N'Dispense prescription #64'),
(164, 1, 1, '2026-05-31', N'OUT', 7, N'Dispense prescription #66'),
(165, 9, 1, '2026-05-31', N'OUT', 23, N'Dispense prescription #66'),
(166, 19, 1, '2026-06-27', N'OUT', 52, N'Dispense prescription #67'),
(167, 8, 1, '2026-06-27', N'OUT', 37, N'Dispense prescription #67'),
(168, 3, 1, '2026-06-07', N'OUT', 12, N'Dispense prescription #68'),
(169, 8, 1, '2026-06-10', N'OUT', 41, N'Dispense prescription #70'),
(170, 17, 1, '2026-06-13', N'OUT', 21, N'Dispense prescription #71'),
(171, 2, 1, '2026-06-14', N'OUT', 10, N'Dispense prescription #71'),
(172, 15, 1, '2026-06-12', N'OUT', 15, N'Dispense prescription #72'),
(173, 20, 1, '2026-06-11', N'OUT', 51, N'Dispense prescription #72'),
(174, 3, 1, '2026-06-18', N'OUT', 36, N'Dispense prescription #73'),
(175, 16, 1, '2026-06-19', N'OUT', 6, N'Dispense prescription #73'),
(176, 5, 1, '2026-06-06', N'OUT', 26, N'Dispense prescription #74'),
(177, 16, 1, '2026-06-07', N'OUT', 36, N'Dispense prescription #74'),
(178, 18, 1, '2026-06-06', N'OUT', 16, N'Dispense prescription #74'),
(179, 11, 1, '2026-06-15', N'OUT', 43, N'Dispense prescription #75'),
(180, 19, 1, '2026-06-14', N'OUT', 24, N'Dispense prescription #75'),
(181, 20, 1, '2026-06-30', N'OUT', 23, N'Dispense prescription #76'),
(182, 1, 1, '2026-07-01', N'OUT', 40, N'Dispense prescription #76'),
(183, 7, 1, '2026-05-22', N'OUT', 49, N'Dispense prescription #77'),
(184, 8, 1, '2026-05-29', N'OUT', 56, N'Dispense prescription #78'),
(185, 4, 1, '2026-06-11', N'OUT', 22, N'Dispense prescription #79'),
(186, 10, 1, '2026-06-10', N'OUT', 14, N'Dispense prescription #79'),
(187, 15, 1, '2026-06-11', N'OUT', 36, N'Dispense prescription #79'),
(188, 1, 1, '2026-05-29', N'OUT', 17, N'Dispense prescription #80'),
(189, 20, 1, '2026-05-23', N'OUT', 30, N'Dispense prescription #81'),
(190, 13, 1, '2026-07-03', N'OUT', 32, N'Dispense prescription #83'),
(191, 8, 1, '2026-07-02', N'OUT', 12, N'Dispense prescription #83'),
(192, 17, 1, '2026-07-02', N'OUT', 36, N'Dispense prescription #83'),
(193, 10, 1, '2026-06-19', N'OUT', 2, N'Dispense prescription #84'),
(194, 11, 1, '2026-06-19', N'OUT', 23, N'Dispense prescription #84'),
(195, 16, 1, '2026-06-20', N'OUT', 33, N'Dispense prescription #84'),
(196, 20, 1, '2026-07-06', N'OUT', 28, N'Dispense prescription #86'),
(197, 8, 1, '2026-07-06', N'OUT', 29, N'Dispense prescription #86'),
(198, 14, 1, '2026-07-05', N'OUT', 14, N'Dispense prescription #86'),
(199, 7, 1, '2026-06-17', N'OUT', 59, N'Dispense prescription #87'),
(200, 10, 1, '2026-06-16', N'OUT', 21, N'Dispense prescription #87');
INSERT INTO [storage_transaction] ([id], [drugID], [storageID], [date], [type], [quantity], [reason]) VALUES
(201, 17, 1, '2026-06-16', N'OUT', 12, N'Dispense prescription #87'),
(202, 9, 1, '2026-06-14', N'OUT', 2, N'Dispense prescription #89'),
(203, 5, 1, '2026-06-15', N'OUT', 39, N'Dispense prescription #89'),
(204, 4, 1, '2026-06-15', N'OUT', 39, N'Dispense prescription #89'),
(205, 12, 1, '2026-06-27', N'OUT', 9, N'Dispense prescription #90'),
(206, 9, 1, '2026-05-19', N'OUT', 48, N'Dispense prescription #92'),
(207, 15, 1, '2026-06-11', N'OUT', 50, N'Dispense prescription #94'),
(208, 8, 1, '2026-06-11', N'OUT', 47, N'Dispense prescription #94'),
(209, 19, 1, '2026-06-23', N'OUT', 34, N'Dispense prescription #95'),
(210, 20, 1, '2026-06-22', N'OUT', 30, N'Dispense prescription #95'),
(211, 18, 1, '2026-06-22', N'OUT', 34, N'Dispense prescription #95'),
(212, 2, 1, '2026-06-04', N'OUT', 13, N'Dispense prescription #96'),
(213, 18, 1, '2026-06-03', N'OUT', 26, N'Dispense prescription #96'),
(214, 13, 1, '2026-06-03', N'OUT', 30, N'Dispense prescription #96'),
(215, 2, 1, '2026-07-04', N'OUT', 6, N'Dispense prescription #97'),
(216, 17, 1, '2026-07-04', N'OUT', 12, N'Dispense prescription #97'),
(217, 5, 1, '2026-07-03', N'OUT', 26, N'Dispense prescription #97'),
(218, 6, 1, '2026-06-28', N'OUT', 57, N'Dispense prescription #98'),
(219, 6, 1, '2026-05-27', N'OUT', 46, N'Dispense prescription #99'),
(220, 4, 1, '2026-05-27', N'OUT', 6, N'Dispense prescription #99');
SET IDENTITY_INSERT [storage_transaction] OFF;


GO


-- ============================================================
-- 13. INVOICES (totals seeded 0; recalculated by trigger after invoiceitem load)
-- ============================================================

SET IDENTITY_INSERT [invoice] ON;
INSERT INTO [invoice] ([id], [patientID], [admissionID], [appointmentID], [insuranceId], [paymentmethodID], [total_amount], [status], [date]) VALUES
(1, N'472-65-2146', 1, NULL, 2, 4, 0, N'Unpaid', '2026-05-23'),
(2, N'506-35-2245', 2, NULL, 4, 2, 0, N'Unpaid', '2026-05-24'),
(3, N'230-89-9751', 3, NULL, 4, 2, 0, N'Unpaid', '2026-05-25'),
(4, N'807-29-9938', 4, NULL, NULL, 2, 0, N'Unpaid', '2026-05-26'),
(5, N'472-65-2146', 5, NULL, 2, 5, 0, N'Unpaid', '2026-05-26'),
(6, N'566-63-4185', 6, NULL, 1, 5, 0, N'Unpaid', '2026-05-26'),
(7, N'472-65-2146', 7, NULL, 2, 1, 0, N'Unpaid', '2026-05-27'),
(8, N'489-22-6881', 8, NULL, NULL, NULL, 0, N'Unpaid', '2026-05-27'),
(9, N'458-49-4728', 9, NULL, 4, 4, 0, N'Unpaid', '2026-05-28'),
(10, N'919-87-4613', 10, NULL, 5, 2, 0, N'Unpaid', '2026-05-28'),
(11, N'324-97-6313', 11, NULL, 5, 4, 0, N'Unpaid', '2026-05-29'),
(12, N'230-89-9751', 12, NULL, 4, 4, 0, N'Unpaid', '2026-05-29'),
(13, N'261-17-9320', 13, NULL, 5, 3, 0, N'Unpaid', '2026-05-30'),
(14, N'546-87-9379', 14, NULL, 3, 2, 0, N'Unpaid', '2026-05-31'),
(15, N'904-84-6279', 15, NULL, 4, 2, 0, N'Unpaid', '2026-05-31'),
(16, N'568-50-2188', 16, NULL, 3, 1, 0, N'Unpaid', '2026-05-31'),
(17, N'319-79-3167', 17, NULL, 4, 2, 0, N'Unpaid', '2026-05-31'),
(18, N'505-92-8517', 18, NULL, 4, 3, 0, N'Unpaid', '2026-05-31'),
(19, N'533-45-1722', 19, NULL, NULL, 4, 0, N'Unpaid', '2026-06-01'),
(20, N'182-27-3471', 20, NULL, 5, 4, 0, N'Unpaid', '2026-06-01'),
(21, N'612-32-9317', 21, NULL, 3, 4, 0, N'Unpaid', '2026-06-01'),
(22, N'702-38-1117', 22, NULL, 2, 3, 0, N'Unpaid', '2026-06-02'),
(23, N'621-73-2489', 23, NULL, 2, 5, 0, N'Unpaid', '2026-06-02'),
(24, N'981-11-2876', 24, NULL, 5, 4, 0, N'Unpaid', '2026-06-02'),
(25, N'578-16-2612', 25, NULL, 4, 3, 0, N'Unpaid', '2026-06-03'),
(26, N'258-34-5861', 26, NULL, 4, 4, 0, N'Unpaid', '2026-06-04'),
(27, N'904-84-6279', 27, NULL, 4, 5, 0, N'Unpaid', '2026-06-05'),
(28, N'578-16-2612', 28, NULL, 4, 2, 0, N'Unpaid', '2026-06-05'),
(29, N'952-63-7381', 29, NULL, NULL, 5, 0, N'Unpaid', '2026-06-05'),
(30, N'860-80-3546', 30, NULL, 1, 5, 0, N'Unpaid', '2026-06-05'),
(31, N'798-41-2684', 31, NULL, 2, 3, 0, N'Unpaid', '2026-06-06'),
(32, N'374-51-5022', 32, NULL, 5, NULL, 0, N'Unpaid', '2026-06-07'),
(33, N'242-23-9935', 33, NULL, 2, 3, 0, N'Unpaid', '2026-06-07'),
(34, N'982-56-4150', 34, NULL, 5, 1, 0, N'Unpaid', '2026-06-07'),
(35, N'230-34-7888', 35, NULL, 5, 2, 0, N'Unpaid', '2026-06-08'),
(36, N'390-75-6491', 36, NULL, 1, 2, 0, N'Unpaid', '2026-06-09'),
(37, N'230-34-7888', 37, NULL, 5, 4, 0, N'Unpaid', '2026-06-09'),
(38, N'672-86-6198', 38, NULL, 5, 2, 0, N'Unpaid', '2026-06-09'),
(39, N'578-16-2612', 39, NULL, 4, 4, 0, N'Unpaid', '2026-06-09'),
(40, N'854-52-7745', 40, NULL, NULL, 4, 0, N'Unpaid', '2026-06-09'),
(41, N'901-15-6688', 41, NULL, 5, 1, 0, N'Unpaid', '2026-06-09'),
(42, N'100-86-6310', 42, NULL, 5, 5, 0, N'Unpaid', '2026-06-10'),
(43, N'506-35-2245', 43, NULL, 4, 1, 0, N'Unpaid', '2026-06-10'),
(44, N'318-61-1960', 44, NULL, 4, NULL, 0, N'Unpaid', '2026-06-10'),
(45, N'854-52-7745', 45, NULL, NULL, 1, 0, N'Unpaid', '2026-06-11'),
(46, N'952-63-7381', 46, NULL, NULL, 2, 0, N'Unpaid', '2026-06-12'),
(47, N'860-80-3546', 47, NULL, 1, 1, 0, N'Unpaid', '2026-06-12'),
(48, N'316-68-6355', 48, NULL, 3, 1, 0, N'Unpaid', '2026-06-12'),
(49, N'578-16-2612', 49, NULL, 4, 2, 0, N'Unpaid', '2026-06-13'),
(50, N'566-63-4185', 50, NULL, 1, 5, 0, N'Unpaid', '2026-06-14'),
(51, N'506-35-2245', 51, NULL, 4, 3, 0, N'Unpaid', '2026-06-14'),
(52, N'621-73-2489', 52, NULL, 2, NULL, 0, N'Unpaid', '2026-06-14'),
(53, N'489-22-6881', 53, NULL, NULL, 5, 0, N'Unpaid', '2026-06-15'),
(54, N'374-51-5022', 54, NULL, 5, 3, 0, N'Unpaid', '2026-06-15'),
(55, N'242-23-9935', 55, NULL, 2, 2, 0, N'Unpaid', '2026-06-16'),
(56, N'901-15-6688', 56, NULL, 5, 2, 0, N'Unpaid', '2026-06-16'),
(57, N'472-65-2146', 57, NULL, 2, 3, 0, N'Unpaid', '2026-06-17'),
(58, N'612-32-9317', 58, NULL, 3, 4, 0, N'Unpaid', '2026-06-17'),
(59, N'390-75-6491', 59, NULL, 1, 5, 0, N'Unpaid', '2026-06-17'),
(60, N'242-23-9935', 60, NULL, 2, 1, 0, N'Unpaid', '2026-06-18'),
(61, N'230-34-7888', NULL, 2, 5, 4, 0, N'Unpaid', '2026-05-27'),
(62, N'258-34-5861', NULL, 3, 4, 3, 0, N'Unpaid', '2026-05-27'),
(63, N'960-91-5543', NULL, 8, 2, 4, 0, N'Unpaid', '2026-05-24'),
(64, N'878-78-3060', NULL, 13, 1, 4, 0, N'Unpaid', '2026-06-14'),
(65, N'182-27-3471', NULL, 17, 5, 5, 0, N'Unpaid', '2026-06-23'),
(66, N'546-87-9379', NULL, 18, 3, 5, 0, N'Unpaid', '2026-06-11'),
(67, N'324-97-6313', NULL, 24, 5, 4, 0, N'Unpaid', '2026-07-04'),
(68, N'329-93-2124', NULL, 26, 3, 2, 0, N'Unpaid', '2026-06-04'),
(69, N'621-73-2489', NULL, 28, 2, 4, 0, N'Unpaid', '2026-05-24'),
(70, N'612-32-9317', NULL, 30, 3, 2, 0, N'Unpaid', '2026-06-24'),
(71, N'878-78-3060', NULL, 31, 1, 3, 0, N'Unpaid', '2026-05-28'),
(72, N'919-87-4613', NULL, 35, 5, 1, 0, N'Unpaid', '2026-06-09'),
(73, N'533-45-1722', NULL, 40, NULL, 2, 0, N'Unpaid', '2026-06-30'),
(74, N'904-84-6279', NULL, 41, 4, NULL, 0, N'Unpaid', '2026-06-21'),
(75, N'506-35-2245', NULL, 44, 4, 5, 0, N'Unpaid', '2026-07-02'),
(76, N'860-80-3546', NULL, 47, 1, 2, 0, N'Unpaid', '2026-07-06'),
(77, N'458-49-4728', NULL, 48, 4, 2, 0, N'Unpaid', '2026-05-27'),
(78, N'390-75-6491', NULL, 53, 1, 5, 0, N'Unpaid', '2026-06-24'),
(79, N'878-78-3060', NULL, 54, 1, 2, 0, N'Unpaid', '2026-07-03'),
(80, N'919-87-4613', NULL, 58, 5, 5, 0, N'Unpaid', '2026-05-27'),
(81, N'566-63-4185', NULL, 62, 1, 2, 0, N'Unpaid', '2026-06-22'),
(82, N'182-27-3471', NULL, 65, 5, NULL, 0, N'Unpaid', '2026-05-21'),
(83, N'505-92-8517', NULL, 69, 4, 1, 0, N'Unpaid', '2026-06-27'),
(84, N'509-96-9785', NULL, 73, 5, 2, 0, N'Unpaid', '2026-06-17'),
(85, N'355-19-8260', NULL, 75, 4, 3, 0, N'Unpaid', '2026-07-03'),
(86, N'489-22-6881', NULL, 79, NULL, 5, 0, N'Unpaid', '2026-05-23'),
(87, N'509-96-9785', NULL, 80, 5, 5, 0, N'Unpaid', '2026-06-06'),
(88, N'807-29-9938', NULL, 81, NULL, 4, 0, N'Unpaid', '2026-06-25'),
(89, N'672-86-6198', NULL, 84, 5, 4, 0, N'Unpaid', '2026-06-16'),
(90, N'897-64-4585', NULL, 85, 1, 1, 0, N'Unpaid', '2026-06-01'),
(91, N'323-69-5198', NULL, 87, 5, 4, 0, N'Unpaid', '2026-06-04'),
(92, N'319-79-3167', NULL, 90, 4, 4, 0, N'Unpaid', '2026-06-25'),
(93, N'919-87-4613', NULL, 98, 5, 1, 0, N'Unpaid', '2026-05-25'),
(94, N'472-65-2146', NULL, 102, 2, 2, 0, N'Unpaid', '2026-06-04'),
(95, N'546-87-9379', NULL, 110, 3, 4, 0, N'Unpaid', '2026-06-06'),
(96, N'316-68-6355', NULL, 116, 3, 4, 0, N'Unpaid', '2026-06-26'),
(97, N'672-86-6198', NULL, 117, 5, 4, 0, N'Unpaid', '2026-05-27'),
(98, N'533-45-1722', NULL, 120, NULL, 1, 0, N'Unpaid', '2026-05-28'),
(99, N'470-91-8532', NULL, 122, NULL, NULL, 0, N'Unpaid', '2026-05-20'),
(100, N'533-45-1722', NULL, 123, NULL, 1, 0, N'Unpaid', '2026-06-16');
INSERT INTO [invoice] ([id], [patientID], [admissionID], [appointmentID], [insuranceId], [paymentmethodID], [total_amount], [status], [date]) VALUES
(101, N'901-15-6688', NULL, 130, 5, 5, 0, N'Unpaid', '2026-06-09'),
(102, N'533-45-1722', NULL, 132, NULL, 1, 0, N'Unpaid', '2026-06-10'),
(103, N'323-69-5198', NULL, 133, 5, 2, 0, N'Unpaid', '2026-06-05'),
(104, N'904-84-6279', NULL, 134, 4, 5, 0, N'Unpaid', '2026-06-04'),
(105, N'854-52-7745', NULL, 152, NULL, 3, 0, N'Unpaid', '2026-06-09'),
(106, N'509-96-9785', NULL, 154, 5, NULL, 0, N'Unpaid', '2026-06-18'),
(107, N'952-63-7381', NULL, 156, NULL, 3, 0, N'Unpaid', '2026-05-19'),
(108, N'568-50-2188', NULL, 157, 3, 5, 0, N'Unpaid', '2026-05-30'),
(109, N'470-91-8532', NULL, 160, NULL, 1, 0, N'Unpaid', '2026-07-07'),
(110, N'568-50-2188', NULL, 174, 3, 3, 0, N'Unpaid', '2026-07-05'),
(111, N'897-64-4585', NULL, 177, 1, 3, 0, N'Unpaid', '2026-06-18'),
(112, N'505-92-8517', NULL, 184, 4, 1, 0, N'Unpaid', '2026-06-20'),
(113, N'568-50-2188', NULL, 189, 3, 1, 0, N'Unpaid', '2026-05-31'),
(114, N'323-69-5198', NULL, 193, 5, 5, 0, N'Unpaid', '2026-05-26'),
(115, N'621-73-2489', NULL, 195, 2, 2, 0, N'Unpaid', '2026-07-01'),
(116, N'261-17-9320', NULL, 196, 5, 1, 0, N'Unpaid', '2026-05-28');
SET IDENTITY_INSERT [invoice] OFF;


GO


-- ============================================================
-- 13b. INVOICE ITEMS (drives invoice total/insurance split via trigger)
-- ============================================================

SET IDENTITY_INSERT [invoiceitem] ON;
INSERT INTO [invoiceitem] ([id], [invoiceID], [item], [type], [description], [amount]) VALUES
(1, 1, N'Physical Therapy Session', N'Service', N'Physical Therapy Session charge', 72.52),
(2, 1, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 288.86),
(3, 1, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 170.23),
(4, 2, N'Consultation Fee', N'Service', N'Consultation Fee charge', 90.08),
(5, 2, N'Emergency Room Fee', N'Service', N'Emergency Room Fee charge', 465.47),
(6, 2, N'Anesthesia Fee', N'Procedure', N'Anesthesia Fee charge', 528.96),
(7, 3, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 106.79),
(8, 3, N'ICU Daily Charge', N'Room', N'ICU Daily Charge charge', 886.44),
(9, 3, N'Imaging - CT Scan', N'Imaging', N'Imaging - CT Scan charge', 570.03),
(10, 3, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 238.83),
(11, 3, N'Anesthesia Fee', N'Procedure', N'Anesthesia Fee charge', 292.9),
(12, 4, N'Imaging - CT Scan', N'Imaging', N'Imaging - CT Scan charge', 320.08),
(13, 4, N'Nursing Care Fee', N'Service', N'Nursing Care Fee charge', 54.92),
(14, 4, N'ICU Daily Charge', N'Room', N'ICU Daily Charge charge', 838.29),
(15, 4, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 130.03),
(16, 5, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 179.08),
(17, 5, N'Nursing Care Fee', N'Service', N'Nursing Care Fee charge', 61.5),
(18, 5, N'Emergency Room Fee', N'Service', N'Emergency Room Fee charge', 341.74),
(19, 5, N'Physical Therapy Session', N'Service', N'Physical Therapy Session charge', 126.75),
(20, 6, N'ICU Daily Charge', N'Room', N'ICU Daily Charge charge', 1044.97),
(21, 6, N'Consultation Fee', N'Service', N'Consultation Fee charge', 112.82),
(22, 6, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 157.41),
(23, 6, N'Nursing Care Fee', N'Service', N'Nursing Care Fee charge', 111.0),
(24, 7, N'Anesthesia Fee', N'Procedure', N'Anesthesia Fee charge', 514.65),
(25, 7, N'ICU Daily Charge', N'Room', N'ICU Daily Charge charge', 904.7),
(26, 7, N'Laboratory Test', N'Lab', N'Laboratory Test charge', 77.29),
(27, 7, N'Consultation Fee', N'Service', N'Consultation Fee charge', 125.94),
(28, 8, N'Emergency Room Fee', N'Service', N'Emergency Room Fee charge', 275.62),
(29, 8, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 303.95),
(30, 8, N'Nursing Care Fee', N'Service', N'Nursing Care Fee charge', 85.78),
(31, 8, N'Anesthesia Fee', N'Procedure', N'Anesthesia Fee charge', 328.48),
(32, 8, N'Laboratory Test', N'Lab', N'Laboratory Test charge', 94.14),
(33, 9, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 195.2),
(34, 9, N'Laboratory Test', N'Lab', N'Laboratory Test charge', 72.74),
(35, 9, N'Surgical Procedure Fee', N'Procedure', N'Surgical Procedure Fee charge', 922.43),
(36, 9, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 196.97),
(37, 10, N'Imaging - CT Scan', N'Imaging', N'Imaging - CT Scan charge', 426.51),
(38, 10, N'Anesthesia Fee', N'Procedure', N'Anesthesia Fee charge', 567.18),
(39, 10, N'Surgical Procedure Fee', N'Procedure', N'Surgical Procedure Fee charge', 2076.78),
(40, 10, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 132.03),
(41, 10, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 338.87),
(42, 11, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 139.87),
(43, 11, N'Nursing Care Fee', N'Service', N'Nursing Care Fee charge', 100.71),
(44, 11, N'Surgical Procedure Fee', N'Procedure', N'Surgical Procedure Fee charge', 1771.71),
(45, 11, N'Imaging - CT Scan', N'Imaging', N'Imaging - CT Scan charge', 618.27),
(46, 12, N'Physical Therapy Session', N'Service', N'Physical Therapy Session charge', 142.59),
(47, 12, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 181.11),
(48, 12, N'Nursing Care Fee', N'Service', N'Nursing Care Fee charge', 174.3),
(49, 12, N'Consultation Fee', N'Service', N'Consultation Fee charge', 110.23),
(50, 12, N'Emergency Room Fee', N'Service', N'Emergency Room Fee charge', 475.41),
(51, 13, N'Laboratory Test', N'Lab', N'Laboratory Test charge', 78.42),
(52, 13, N'Physical Therapy Session', N'Service', N'Physical Therapy Session charge', 101.5),
(53, 14, N'Physical Therapy Session', N'Service', N'Physical Therapy Session charge', 60.95),
(54, 14, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 152.12),
(55, 14, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 72.91),
(56, 14, N'Nursing Care Fee', N'Service', N'Nursing Care Fee charge', 103.46),
(57, 15, N'Laboratory Test', N'Lab', N'Laboratory Test charge', 81.94),
(58, 15, N'Surgical Procedure Fee', N'Procedure', N'Surgical Procedure Fee charge', 1010.46),
(59, 15, N'Consultation Fee', N'Service', N'Consultation Fee charge', 121.59),
(60, 15, N'ICU Daily Charge', N'Room', N'ICU Daily Charge charge', 1125.78),
(61, 16, N'ICU Daily Charge', N'Room', N'ICU Daily Charge charge', 763.17),
(62, 16, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 340.96),
(63, 17, N'Laboratory Test', N'Lab', N'Laboratory Test charge', 112.27),
(64, 17, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 62.51),
(65, 17, N'Emergency Room Fee', N'Service', N'Emergency Room Fee charge', 328.1),
(66, 17, N'Physical Therapy Session', N'Service', N'Physical Therapy Session charge', 141.31),
(67, 18, N'Imaging - CT Scan', N'Imaging', N'Imaging - CT Scan charge', 499.59),
(68, 18, N'Anesthesia Fee', N'Procedure', N'Anesthesia Fee charge', 230.03),
(69, 19, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 125.96),
(70, 19, N'Surgical Procedure Fee', N'Procedure', N'Surgical Procedure Fee charge', 1460.24),
(71, 20, N'ICU Daily Charge', N'Room', N'ICU Daily Charge charge', 1138.83),
(72, 20, N'Physical Therapy Session', N'Service', N'Physical Therapy Session charge', 124.39),
(73, 20, N'Emergency Room Fee', N'Service', N'Emergency Room Fee charge', 230.99),
(74, 21, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 134.04),
(75, 21, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 150.22),
(76, 22, N'ICU Daily Charge', N'Room', N'ICU Daily Charge charge', 805.24),
(77, 22, N'Consultation Fee', N'Service', N'Consultation Fee charge', 139.08),
(78, 22, N'Nursing Care Fee', N'Service', N'Nursing Care Fee charge', 151.52),
(79, 22, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 159.22),
(80, 22, N'Anesthesia Fee', N'Procedure', N'Anesthesia Fee charge', 470.06),
(81, 23, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 70.49),
(82, 23, N'Physical Therapy Session', N'Service', N'Physical Therapy Session charge', 149.73),
(83, 23, N'Laboratory Test', N'Lab', N'Laboratory Test charge', 84.71),
(84, 23, N'Imaging - CT Scan', N'Imaging', N'Imaging - CT Scan charge', 519.21),
(85, 24, N'Physical Therapy Session', N'Service', N'Physical Therapy Session charge', 63.54),
(86, 24, N'Surgical Procedure Fee', N'Procedure', N'Surgical Procedure Fee charge', 2221.41),
(87, 24, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 197.75),
(88, 24, N'Nursing Care Fee', N'Service', N'Nursing Care Fee charge', 140.46),
(89, 25, N'Emergency Room Fee', N'Service', N'Emergency Room Fee charge', 210.71),
(90, 25, N'Physical Therapy Session', N'Service', N'Physical Therapy Session charge', 62.28),
(91, 25, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 199.31),
(92, 25, N'Surgical Procedure Fee', N'Procedure', N'Surgical Procedure Fee charge', 1682.39),
(93, 25, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 247.19),
(94, 26, N'Consultation Fee', N'Service', N'Consultation Fee charge', 83.92),
(95, 26, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 209.68),
(96, 27, N'Physical Therapy Session', N'Service', N'Physical Therapy Session charge', 63.32),
(97, 27, N'Nursing Care Fee', N'Service', N'Nursing Care Fee charge', 68.41),
(98, 27, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 313.46),
(99, 27, N'Surgical Procedure Fee', N'Procedure', N'Surgical Procedure Fee charge', 2543.51),
(100, 27, N'Emergency Room Fee', N'Service', N'Emergency Room Fee charge', 475.41);
INSERT INTO [invoiceitem] ([id], [invoiceID], [item], [type], [description], [amount]) VALUES
(101, 28, N'Laboratory Test', N'Lab', N'Laboratory Test charge', 65.62),
(102, 28, N'Emergency Room Fee', N'Service', N'Emergency Room Fee charge', 251.21),
(103, 29, N'Emergency Room Fee', N'Service', N'Emergency Room Fee charge', 301.2),
(104, 29, N'Surgical Procedure Fee', N'Procedure', N'Surgical Procedure Fee charge', 3892.82),
(105, 29, N'Imaging - CT Scan', N'Imaging', N'Imaging - CT Scan charge', 742.76),
(106, 30, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 172.69),
(107, 30, N'Surgical Procedure Fee', N'Procedure', N'Surgical Procedure Fee charge', 2041.36),
(108, 30, N'Consultation Fee', N'Service', N'Consultation Fee charge', 88.45),
(109, 31, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 17.73),
(110, 31, N'Surgical Procedure Fee', N'Procedure', N'Surgical Procedure Fee charge', 1169.88),
(111, 31, N'ICU Daily Charge', N'Room', N'ICU Daily Charge charge', 1093.16),
(112, 32, N'Emergency Room Fee', N'Service', N'Emergency Room Fee charge', 412.02),
(113, 32, N'Consultation Fee', N'Service', N'Consultation Fee charge', 121.56),
(114, 32, N'Physical Therapy Session', N'Service', N'Physical Therapy Session charge', 85.54),
(115, 32, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 323.38),
(116, 32, N'Anesthesia Fee', N'Procedure', N'Anesthesia Fee charge', 596.12),
(117, 33, N'Imaging - CT Scan', N'Imaging', N'Imaging - CT Scan charge', 730.32),
(118, 33, N'Surgical Procedure Fee', N'Procedure', N'Surgical Procedure Fee charge', 3064.58),
(119, 33, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 172.01),
(120, 33, N'Consultation Fee', N'Service', N'Consultation Fee charge', 137.85),
(121, 33, N'ICU Daily Charge', N'Room', N'ICU Daily Charge charge', 710.84),
(122, 34, N'ICU Daily Charge', N'Room', N'ICU Daily Charge charge', 1103.91),
(123, 34, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 247.49),
(124, 35, N'Consultation Fee', N'Service', N'Consultation Fee charge', 127.97),
(125, 35, N'Surgical Procedure Fee', N'Procedure', N'Surgical Procedure Fee charge', 4383.72),
(126, 35, N'Emergency Room Fee', N'Service', N'Emergency Room Fee charge', 342.32),
(127, 35, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 194.08),
(128, 36, N'Laboratory Test', N'Lab', N'Laboratory Test charge', 30.44),
(129, 36, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 69.97),
(130, 36, N'ICU Daily Charge', N'Room', N'ICU Daily Charge charge', 876.15),
(131, 36, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 40.03),
(132, 36, N'Consultation Fee', N'Service', N'Consultation Fee charge', 82.03),
(133, 37, N'Imaging - CT Scan', N'Imaging', N'Imaging - CT Scan charge', 767.39),
(134, 37, N'Surgical Procedure Fee', N'Procedure', N'Surgical Procedure Fee charge', 2006.69),
(135, 37, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 78.63),
(136, 37, N'Physical Therapy Session', N'Service', N'Physical Therapy Session charge', 126.4),
(137, 38, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 102.04),
(138, 38, N'ICU Daily Charge', N'Room', N'ICU Daily Charge charge', 1123.34),
(139, 39, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 393.89),
(140, 39, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 48.42),
(141, 39, N'Surgical Procedure Fee', N'Procedure', N'Surgical Procedure Fee charge', 1270.68),
(142, 39, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 191.52),
(143, 40, N'Imaging - CT Scan', N'Imaging', N'Imaging - CT Scan charge', 662.18),
(144, 40, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 347.39),
(145, 40, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 181.22),
(146, 40, N'Surgical Procedure Fee', N'Procedure', N'Surgical Procedure Fee charge', 3062.65),
(147, 40, N'Laboratory Test', N'Lab', N'Laboratory Test charge', 36.99),
(148, 41, N'Nursing Care Fee', N'Service', N'Nursing Care Fee charge', 86.29),
(149, 41, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 148.7),
(150, 41, N'Surgical Procedure Fee', N'Procedure', N'Surgical Procedure Fee charge', 3523.86),
(151, 41, N'Physical Therapy Session', N'Service', N'Physical Therapy Session charge', 82.2),
(152, 41, N'Anesthesia Fee', N'Procedure', N'Anesthesia Fee charge', 363.65),
(153, 42, N'Imaging - CT Scan', N'Imaging', N'Imaging - CT Scan charge', 324.04),
(154, 42, N'Consultation Fee', N'Service', N'Consultation Fee charge', 112.95),
(155, 43, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 141.7),
(156, 43, N'Surgical Procedure Fee', N'Procedure', N'Surgical Procedure Fee charge', 2304.49),
(157, 43, N'Emergency Room Fee', N'Service', N'Emergency Room Fee charge', 265.4),
(158, 43, N'Nursing Care Fee', N'Service', N'Nursing Care Fee charge', 96.59),
(159, 43, N'Consultation Fee', N'Service', N'Consultation Fee charge', 96.73),
(160, 44, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 394.11),
(161, 44, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 98.11),
(162, 44, N'ICU Daily Charge', N'Room', N'ICU Daily Charge charge', 597.04),
(163, 44, N'Consultation Fee', N'Service', N'Consultation Fee charge', 129.22),
(164, 45, N'Imaging - CT Scan', N'Imaging', N'Imaging - CT Scan charge', 618.55),
(165, 45, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 116.35),
(166, 46, N'ICU Daily Charge', N'Room', N'ICU Daily Charge charge', 1015.03),
(167, 46, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 70.41),
(168, 47, N'Imaging - CT Scan', N'Imaging', N'Imaging - CT Scan charge', 579.21),
(169, 47, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 67.77),
(170, 48, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 284.91),
(171, 48, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 183.32),
(172, 48, N'Surgical Procedure Fee', N'Procedure', N'Surgical Procedure Fee charge', 3528.31),
(173, 49, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 112.66),
(174, 49, N'Laboratory Test', N'Lab', N'Laboratory Test charge', 26.34),
(175, 49, N'Nursing Care Fee', N'Service', N'Nursing Care Fee charge', 94.88),
(176, 49, N'Imaging - CT Scan', N'Imaging', N'Imaging - CT Scan charge', 591.74),
(177, 50, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 45.79),
(178, 50, N'ICU Daily Charge', N'Room', N'ICU Daily Charge charge', 1118.79),
(179, 50, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 76.59),
(180, 50, N'Emergency Room Fee', N'Service', N'Emergency Room Fee charge', 317.2),
(181, 51, N'Anesthesia Fee', N'Procedure', N'Anesthesia Fee charge', 448.16),
(182, 51, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 368.75),
(183, 52, N'Physical Therapy Session', N'Service', N'Physical Therapy Session charge', 97.81),
(184, 52, N'Nursing Care Fee', N'Service', N'Nursing Care Fee charge', 145.9),
(185, 52, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 155.37),
(186, 52, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 45.92),
(187, 52, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 64.19),
(188, 53, N'Physical Therapy Session', N'Service', N'Physical Therapy Session charge', 113.4),
(189, 53, N'Anesthesia Fee', N'Procedure', N'Anesthesia Fee charge', 548.43),
(190, 53, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 219.96),
(191, 53, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 94.6),
(192, 54, N'Laboratory Test', N'Lab', N'Laboratory Test charge', 57.19),
(193, 54, N'Surgical Procedure Fee', N'Procedure', N'Surgical Procedure Fee charge', 1866.14),
(194, 54, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 170.65),
(195, 55, N'Anesthesia Fee', N'Procedure', N'Anesthesia Fee charge', 291.14),
(196, 55, N'Nursing Care Fee', N'Service', N'Nursing Care Fee charge', 72.8),
(197, 55, N'Laboratory Test', N'Lab', N'Laboratory Test charge', 90.81),
(198, 56, N'Emergency Room Fee', N'Service', N'Emergency Room Fee charge', 372.36),
(199, 56, N'Consultation Fee', N'Service', N'Consultation Fee charge', 110.86),
(200, 56, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 130.24);
INSERT INTO [invoiceitem] ([id], [invoiceID], [item], [type], [description], [amount]) VALUES
(201, 57, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 245.34),
(202, 57, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 111.39),
(203, 57, N'Nursing Care Fee', N'Service', N'Nursing Care Fee charge', 65.79),
(204, 58, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 232.82),
(205, 58, N'Consultation Fee', N'Service', N'Consultation Fee charge', 129.38),
(206, 58, N'Nursing Care Fee', N'Service', N'Nursing Care Fee charge', 111.61),
(207, 58, N'ICU Daily Charge', N'Room', N'ICU Daily Charge charge', 702.88),
(208, 59, N'ICU Daily Charge', N'Room', N'ICU Daily Charge charge', 982.4),
(209, 59, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 149.01),
(210, 59, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 231.03),
(211, 60, N'ICU Daily Charge', N'Room', N'ICU Daily Charge charge', 728.46),
(212, 60, N'Surgical Procedure Fee', N'Procedure', N'Surgical Procedure Fee charge', 3050.16),
(213, 60, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 47.08),
(214, 60, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 160.02),
(215, 60, N'Emergency Room Fee', N'Service', N'Emergency Room Fee charge', 434.39),
(216, 61, N'Physical Therapy Session', N'Service', N'Physical Therapy Session charge', 95.5),
(217, 61, N'Emergency Room Fee', N'Service', N'Emergency Room Fee charge', 347.14),
(218, 61, N'Nursing Care Fee', N'Service', N'Nursing Care Fee charge', 128.41),
(219, 62, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 242.41),
(220, 62, N'Imaging - CT Scan', N'Imaging', N'Imaging - CT Scan charge', 523.7),
(221, 63, N'Emergency Room Fee', N'Service', N'Emergency Room Fee charge', 422.46),
(222, 63, N'Surgical Procedure Fee', N'Procedure', N'Surgical Procedure Fee charge', 2337.76),
(223, 63, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 94.08),
(224, 64, N'ICU Daily Charge', N'Room', N'ICU Daily Charge charge', 918.55),
(225, 65, N'Emergency Room Fee', N'Service', N'Emergency Room Fee charge', 426.83),
(226, 65, N'ICU Daily Charge', N'Room', N'ICU Daily Charge charge', 561.91),
(227, 66, N'Anesthesia Fee', N'Procedure', N'Anesthesia Fee charge', 577.62),
(228, 66, N'ICU Daily Charge', N'Room', N'ICU Daily Charge charge', 595.85),
(229, 67, N'Laboratory Test', N'Lab', N'Laboratory Test charge', 103.46),
(230, 68, N'Consultation Fee', N'Service', N'Consultation Fee charge', 90.78),
(231, 69, N'Physical Therapy Session', N'Service', N'Physical Therapy Session charge', 119.93),
(232, 70, N'Emergency Room Fee', N'Service', N'Emergency Room Fee charge', 429.42),
(233, 71, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 174.99),
(234, 71, N'ICU Daily Charge', N'Room', N'ICU Daily Charge charge', 939.6),
(235, 71, N'Imaging - CT Scan', N'Imaging', N'Imaging - CT Scan charge', 585.62),
(236, 72, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 164.63),
(237, 72, N'ICU Daily Charge', N'Room', N'ICU Daily Charge charge', 723.78),
(238, 73, N'Laboratory Test', N'Lab', N'Laboratory Test charge', 56.12),
(239, 74, N'Nursing Care Fee', N'Service', N'Nursing Care Fee charge', 171.72),
(240, 74, N'Physical Therapy Session', N'Service', N'Physical Therapy Session charge', 106.25),
(241, 75, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 211.98),
(242, 75, N'Physical Therapy Session', N'Service', N'Physical Therapy Session charge', 84.43),
(243, 76, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 279.54),
(244, 77, N'Surgical Procedure Fee', N'Procedure', N'Surgical Procedure Fee charge', 1371.85),
(245, 78, N'Anesthesia Fee', N'Procedure', N'Anesthesia Fee charge', 556.27),
(246, 78, N'Nursing Care Fee', N'Service', N'Nursing Care Fee charge', 141.29),
(247, 78, N'Physical Therapy Session', N'Service', N'Physical Therapy Session charge', 132.23),
(248, 79, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 76.16),
(249, 80, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 65.46),
(250, 80, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 353.64),
(251, 80, N'Laboratory Test', N'Lab', N'Laboratory Test charge', 42.24),
(252, 81, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 182.55),
(253, 81, N'Surgical Procedure Fee', N'Procedure', N'Surgical Procedure Fee charge', 1090.84),
(254, 82, N'Imaging - CT Scan', N'Imaging', N'Imaging - CT Scan charge', 417.81),
(255, 82, N'Consultation Fee', N'Service', N'Consultation Fee charge', 82.3),
(256, 83, N'Laboratory Test', N'Lab', N'Laboratory Test charge', 86.76),
(257, 84, N'Physical Therapy Session', N'Service', N'Physical Therapy Session charge', 91.64),
(258, 85, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 345.2),
(259, 85, N'Nursing Care Fee', N'Service', N'Nursing Care Fee charge', 129.68),
(260, 86, N'Nursing Care Fee', N'Service', N'Nursing Care Fee charge', 78.21),
(261, 87, N'Anesthesia Fee', N'Procedure', N'Anesthesia Fee charge', 249.34),
(262, 88, N'Anesthesia Fee', N'Procedure', N'Anesthesia Fee charge', 292.56),
(263, 88, N'ICU Daily Charge', N'Room', N'ICU Daily Charge charge', 971.47),
(264, 89, N'Nursing Care Fee', N'Service', N'Nursing Care Fee charge', 79.58),
(265, 90, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 326.18),
(266, 90, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 115.86),
(267, 90, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 67.72),
(268, 91, N'Anesthesia Fee', N'Procedure', N'Anesthesia Fee charge', 312.94),
(269, 91, N'Laboratory Test', N'Lab', N'Laboratory Test charge', 60.73),
(270, 91, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 197.14),
(271, 92, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 249.76),
(272, 92, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 272.91),
(273, 92, N'Consultation Fee', N'Service', N'Consultation Fee charge', 87.36),
(274, 93, N'Imaging - CT Scan', N'Imaging', N'Imaging - CT Scan charge', 540.37),
(275, 94, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 245.29),
(276, 95, N'Surgical Procedure Fee', N'Procedure', N'Surgical Procedure Fee charge', 3901.0),
(277, 96, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 124.6),
(278, 96, N'Physical Therapy Session', N'Service', N'Physical Therapy Session charge', 96.4),
(279, 97, N'Emergency Room Fee', N'Service', N'Emergency Room Fee charge', 275.21),
(280, 98, N'Anesthesia Fee', N'Procedure', N'Anesthesia Fee charge', 226.43),
(281, 99, N'Imaging - CT Scan', N'Imaging', N'Imaging - CT Scan charge', 662.75),
(282, 100, N'Nursing Care Fee', N'Service', N'Nursing Care Fee charge', 76.25),
(283, 100, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 135.8),
(284, 100, N'Physical Therapy Session', N'Service', N'Physical Therapy Session charge', 104.12),
(285, 101, N'Consultation Fee', N'Service', N'Consultation Fee charge', 141.61),
(286, 101, N'Anesthesia Fee', N'Procedure', N'Anesthesia Fee charge', 259.57),
(287, 101, N'Imaging - CT Scan', N'Imaging', N'Imaging - CT Scan charge', 570.07),
(288, 102, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 289.17),
(289, 103, N'Imaging - CT Scan', N'Imaging', N'Imaging - CT Scan charge', 487.48),
(290, 103, N'Room Charge (per day)', N'Room', N'Room Charge (per day) charge', 247.27),
(291, 104, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 172.33),
(292, 104, N'Anesthesia Fee', N'Procedure', N'Anesthesia Fee charge', 453.34),
(293, 104, N'Nursing Care Fee', N'Service', N'Nursing Care Fee charge', 100.88),
(294, 105, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 65.35),
(295, 105, N'Consultation Fee', N'Service', N'Consultation Fee charge', 83.16),
(296, 106, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 141.35),
(297, 106, N'Imaging - CT Scan', N'Imaging', N'Imaging - CT Scan charge', 895.17),
(298, 106, N'Emergency Room Fee', N'Service', N'Emergency Room Fee charge', 323.58),
(299, 107, N'Emergency Room Fee', N'Service', N'Emergency Room Fee charge', 234.34),
(300, 107, N'Anesthesia Fee', N'Procedure', N'Anesthesia Fee charge', 284.89);
INSERT INTO [invoiceitem] ([id], [invoiceID], [item], [type], [description], [amount]) VALUES
(301, 107, N'Laboratory Test', N'Lab', N'Laboratory Test charge', 73.84),
(302, 108, N'Imaging - CT Scan', N'Imaging', N'Imaging - CT Scan charge', 717.58),
(303, 108, N'Laboratory Test', N'Lab', N'Laboratory Test charge', 78.8),
(304, 108, N'Consultation Fee', N'Service', N'Consultation Fee charge', 149.0),
(305, 109, N'Emergency Room Fee', N'Service', N'Emergency Room Fee charge', 261.77),
(306, 109, N'Physical Therapy Session', N'Service', N'Physical Therapy Session charge', 104.71),
(307, 110, N'Surgical Procedure Fee', N'Procedure', N'Surgical Procedure Fee charge', 3151.14),
(308, 110, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 195.08),
(309, 111, N'Laboratory Test', N'Lab', N'Laboratory Test charge', 119.62),
(310, 112, N'ICU Daily Charge', N'Room', N'ICU Daily Charge charge', 735.79),
(311, 112, N'Emergency Room Fee', N'Service', N'Emergency Room Fee charge', 220.18),
(312, 112, N'Anesthesia Fee', N'Procedure', N'Anesthesia Fee charge', 600.59),
(313, 113, N'Laboratory Test', N'Lab', N'Laboratory Test charge', 63.29),
(314, 113, N'Nursing Care Fee', N'Service', N'Nursing Care Fee charge', 120.19),
(315, 113, N'Anesthesia Fee', N'Procedure', N'Anesthesia Fee charge', 300.04),
(316, 114, N'Consultation Fee', N'Service', N'Consultation Fee charge', 123.95),
(317, 115, N'Anesthesia Fee', N'Procedure', N'Anesthesia Fee charge', 668.58),
(318, 115, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 111.22),
(319, 115, N'Laboratory Test', N'Lab', N'Laboratory Test charge', 81.44),
(320, 116, N'Surgical Procedure Fee', N'Procedure', N'Surgical Procedure Fee charge', 1346.65),
(321, 116, N'Imaging - X-Ray', N'Imaging', N'Imaging - X-Ray charge', 88.59),
(322, 116, N'Medication Charge', N'Pharmacy', N'Medication Charge charge', 140.21);
SET IDENTITY_INSERT [invoiceitem] OFF;


GO


-- ============================================================
-- 13c. PAYMENTS (drives invoice paidAmount/status via trigger)
-- ============================================================

SET IDENTITY_INSERT [payment] ON;
INSERT INTO [payment] ([id], [invoiceID], [patientID], [paymentmethodID], [amount], [type], [date]) VALUES
(1, 1, N'472-65-2146', 4, 159.48, N'Payment', '2026-05-29'),
(2, 3, N'230-89-9751', 2, 209.5, N'Payment', '2026-06-03'),
(3, 4, N'807-29-9938', 2, 1343.32, N'Payment', '2026-05-27'),
(4, 6, N'566-63-4185', 5, 145.62, N'Payment', '2026-05-30'),
(5, 7, N'472-65-2146', 1, 486.77, N'Payment', '2026-06-05'),
(6, 8, N'489-22-6881', 3, 1087.97, N'Payment', '2026-06-05'),
(7, 10, N'919-87-4613', 2, 3541.37, N'Payment', '2026-05-30'),
(8, 11, N'324-97-6313', 4, 2630.56, N'Payment', '2026-06-02'),
(9, 13, N'261-17-9320', 3, 75.73, N'Payment', '2026-06-09'),
(10, 14, N'546-87-9379', 2, 194.72, N'Payment', '2026-06-10'),
(11, 15, N'904-84-6279', 2, 233.98, N'Payment', '2026-06-09'),
(12, 16, N'568-50-2188', 1, 552.07, N'Payment', '2026-06-02'),
(13, 17, N'319-79-3167', 2, 29.74, N'Payment', '2026-06-02'),
(14, 19, N'533-45-1722', 4, 1586.2, N'Payment', '2026-06-03'),
(15, 20, N'182-27-3471', 4, 1494.21, N'Payment', '2026-06-10'),
(16, 21, N'612-32-9317', 4, 142.13, N'Payment', '2026-06-07'),
(17, 22, N'702-38-1117', 3, 517.54, N'Payment', '2026-06-09'),
(18, 25, N'578-16-2612', 3, 149.33, N'Payment', '2026-06-10'),
(19, 26, N'258-34-5861', 4, 29.36, N'Payment', '2026-06-05'),
(20, 27, N'904-84-6279', 5, 346.41, N'Payment', '2026-06-15'),
(21, 28, N'578-16-2612', 2, 31.68, N'Payment', '2026-06-06'),
(22, 29, N'952-63-7381', 5, 4936.78, N'Payment', '2026-06-06'),
(23, 30, N'860-80-3546', 5, 460.5, N'Payment', '2026-06-11'),
(24, 31, N'798-41-2684', 3, 684.23, N'Payment', '2026-06-08'),
(25, 32, N'374-51-5022', 1, 1538.62, N'Payment', '2026-06-09'),
(26, 33, N'242-23-9935', 3, 1444.68, N'Payment', '2026-06-15'),
(27, 34, N'982-56-4150', 1, 1351.4, N'Payment', '2026-06-14'),
(28, 35, N'230-34-7888', 2, 1623.25, N'Payment', '2026-06-18'),
(29, 36, N'390-75-6491', 2, 219.72, N'Payment', '2026-06-10'),
(30, 38, N'672-86-6198', 2, 1225.38, N'Payment', '2026-06-18'),
(31, 39, N'578-16-2612', 4, 190.45, N'Payment', '2026-06-11'),
(32, 41, N'901-15-6688', 1, 4204.7, N'Payment', '2026-06-18'),
(33, 42, N'100-86-6310', 5, 138.44, N'Payment', '2026-06-18'),
(34, 44, N'318-61-1960', 3, 121.85, N'Payment', '2026-06-15'),
(35, 45, N'854-52-7745', 1, 476.97, N'Payment', '2026-06-20'),
(36, 47, N'860-80-3546', 1, 129.4, N'Payment', '2026-06-22'),
(37, 48, N'316-68-6355', 1, 1469.86, N'Payment', '2026-06-15'),
(38, 49, N'578-16-2612', 2, 82.56, N'Payment', '2026-06-14'),
(39, 50, N'566-63-4185', 5, 311.67, N'Payment', '2026-06-15'),
(40, 51, N'506-35-2245', 3, 81.69, N'Payment', '2026-06-24'),
(41, 52, N'621-73-2489', 3, 109.6, N'Payment', '2026-06-22'),
(42, 53, N'489-22-6881', 5, 976.39, N'Payment', '2026-06-17'),
(43, 54, N'374-51-5022', 3, 2093.98, N'Payment', '2026-06-19'),
(44, 56, N'901-15-6688', 2, 613.46, N'Payment', '2026-06-16'),
(45, 57, N'472-65-2146', 3, 126.76, N'Payment', '2026-06-24'),
(46, 59, N'390-75-6491', 5, 272.49, N'Payment', '2026-06-25'),
(47, 60, N'242-23-9935', 1, 527.57, N'Payment', '2026-06-19'),
(48, 61, N'230-34-7888', 4, 571.05, N'Payment', '2026-05-27'),
(49, 62, N'258-34-5861', 3, 76.61, N'Payment', '2026-06-01'),
(50, 63, N'960-91-5543', 4, 856.29, N'Payment', '2026-05-30'),
(51, 64, N'878-78-3060', 4, 183.71, N'Payment', '2026-06-18'),
(52, 65, N'182-27-3471', 5, 988.74, N'Payment', '2026-06-27'),
(53, 66, N'546-87-9379', 5, 586.73, N'Payment', '2026-06-17'),
(54, 67, N'324-97-6313', 4, 103.46, N'Payment', '2026-07-07'),
(55, 68, N'329-93-2124', 2, 45.39, N'Payment', '2026-06-14'),
(56, 69, N'621-73-2489', 4, 35.98, N'Payment', '2026-05-26'),
(57, 70, N'612-32-9317', 2, 214.71, N'Payment', '2026-06-25'),
(58, 71, N'878-78-3060', 3, 122.34, N'Payment', '2026-06-05'),
(59, 73, N'533-45-1722', 2, 56.12, N'Payment', '2026-07-05'),
(60, 74, N'904-84-6279', 3, 10.89, N'Payment', '2026-06-22'),
(61, 75, N'506-35-2245', 5, 14.26, N'Payment', '2026-07-07'),
(62, 76, N'860-80-3546', 2, 55.91, N'Payment', '2026-07-07'),
(63, 77, N'458-49-4728', 2, 137.19, N'Payment', '2026-05-30'),
(64, 78, N'390-75-6491', 5, 165.96, N'Payment', '2026-06-25'),
(65, 79, N'878-78-3060', 2, 5.63, N'Payment', '2026-07-07'),
(66, 81, N'566-63-4185', 2, 176.24, N'Payment', '2026-06-23'),
(67, 82, N'182-27-3471', 1, 298.36, N'Payment', '2026-05-28'),
(68, 83, N'505-92-8517', 1, 6.0, N'Payment', '2026-07-06'),
(69, 84, N'509-96-9785', 2, 91.64, N'Payment', '2026-06-21'),
(70, 85, N'355-19-8260', 3, 47.49, N'Payment', '2026-07-04'),
(71, 86, N'489-22-6881', 5, 78.21, N'Payment', '2026-05-27'),
(72, 87, N'509-96-9785', 5, 249.34, N'Payment', '2026-06-14'),
(73, 88, N'807-29-9938', 4, 1264.03, N'Payment', '2026-06-30'),
(74, 89, N'672-86-6198', 4, 79.58, N'Payment', '2026-06-21'),
(75, 90, N'897-64-4585', 1, 101.95, N'Payment', '2026-06-02'),
(76, 91, N'323-69-5198', 4, 570.81, N'Payment', '2026-06-05'),
(77, 92, N'319-79-3167', 4, 61.0, N'Payment', '2026-07-05'),
(78, 93, N'919-87-4613', 1, 540.37, N'Payment', '2026-05-26'),
(79, 94, N'472-65-2146', 2, 73.59, N'Payment', '2026-06-13'),
(80, 95, N'546-87-9379', 4, 856.78, N'Payment', '2026-06-15'),
(81, 96, N'316-68-6355', 4, 110.5, N'Payment', '2026-06-30'),
(82, 97, N'672-86-6198', 4, 275.21, N'Payment', '2026-06-06'),
(83, 98, N'533-45-1722', 1, 226.43, N'Payment', '2026-06-07'),
(84, 99, N'470-91-8532', 3, 662.75, N'Payment', '2026-05-24'),
(85, 100, N'533-45-1722', 1, 316.17, N'Payment', '2026-06-21'),
(86, 103, N'323-69-5198', 2, 429.41, N'Payment', '2026-06-12'),
(87, 104, N'904-84-6279', 5, 72.66, N'Payment', '2026-06-10'),
(88, 105, N'854-52-7745', 3, 70.46, N'Payment', '2026-06-18'),
(89, 106, N'509-96-9785', 1, 1360.1, N'Payment', '2026-06-21'),
(90, 107, N'952-63-7381', 3, 593.07, N'Payment', '2026-05-29'),
(91, 108, N'568-50-2188', 5, 472.69, N'Payment', '2026-06-05'),
(92, 109, N'470-91-8532', 1, 232.24, N'Payment', '2026-07-07'),
(93, 110, N'568-50-2188', 3, 1673.11, N'Payment', '2026-07-07'),
(94, 111, N'897-64-4585', 3, 23.92, N'Payment', '2026-06-21'),
(95, 112, N'505-92-8517', 1, 155.66, N'Payment', '2026-06-23'),
(96, 113, N'568-50-2188', 1, 241.76, N'Payment', '2026-06-09'),
(97, 114, N'323-69-5198', 5, 123.95, N'Payment', '2026-05-28'),
(98, 115, N'621-73-2489', 2, 133.54, N'Payment', '2026-07-07'),
(99, 116, N'261-17-9320', 1, 1575.45, N'Payment', '2026-06-03');
SET IDENTITY_INSERT [payment] OFF;


GO


-- ============================================================
-- 14. IOT DEVICES
-- ============================================================

SET IDENTITY_INSERT [iotdevice] ON;
INSERT INTO [iotdevice] ([id], [macaddress], [type], [status], [installationdate]) VALUES
(1, N'20:68:D3:88:92:52', N'Blood Pressure Monitor', N'Active', '2025-11-09'),
(2, N'CF:7A:3A:4C:62:0E', N'Pulse Oximeter', N'Active', '2025-06-21'),
(3, N'DF:D8:12:67:51:8B', N'Pulse Oximeter', N'Active', '2025-12-31'),
(4, N'8E:5A:15:F8:0A:1C', N'IV Infusion Pump', N'Active', '2026-05-24'),
(5, N'98:20:D0:BA:2E:CB', N'IV Infusion Pump', N'Active', '2026-04-26'),
(6, N'78:39:3D:80:FE:2E', N'Pulse Oximeter', N'Inactive', '2025-06-02'),
(7, N'A0:A8:C7:78:D8:6F', N'Pulse Oximeter', N'Active', '2025-08-04'),
(8, N'8C:E1:D1:82:1C:FB', N'Temperature Sensor', N'Active', '2026-04-14'),
(9, N'39:A2:D8:F3:7E:8E', N'IV Infusion Pump', N'Active', '2025-11-28'),
(10, N'BC:9D:0A:11:1B:7A', N'Blood Pressure Monitor', N'Active', '2026-03-25'),
(11, N'B9:3E:79:E2:C6:04', N'Glucose Monitor', N'Active', '2025-08-29'),
(12, N'78:98:6B:52:E0:A2', N'IV Infusion Pump', N'Active', '2026-01-28'),
(13, N'11:8C:29:FB:F1:D3', N'IV Infusion Pump', N'Active', '2025-07-13'),
(14, N'33:52:85:21:B4:D7', N'Temperature Sensor', N'Active', '2025-12-19'),
(15, N'E8:0E:1A:5E:E3:45', N'Heart Rate Monitor', N'Active', '2025-08-31'),
(16, N'9C:A0:2A:38:50:7F', N'Temperature Sensor', N'Active', '2025-11-14'),
(17, N'42:D2:A3:E7:F4:44', N'Blood Pressure Monitor', N'UnderMaintenance', '2025-06-07'),
(18, N'A7:90:65:2B:D4:BC', N'Pulse Oximeter', N'Active', '2026-03-11'),
(19, N'72:0A:0B:75:2D:EC', N'Pulse Oximeter', N'Inactive', '2025-11-18'),
(20, N'56:19:CD:DB:85:4C', N'Heart Rate Monitor', N'Active', '2026-01-24'),
(21, N'3C:07:DE:E8:FD:3C', N'Pulse Oximeter', N'Active', '2025-12-01'),
(22, N'88:93:FD:C3:42:DC', N'IV Infusion Pump', N'Active', '2025-06-07'),
(23, N'90:60:D6:5C:D1:4A', N'Heart Rate Monitor', N'Active', '2026-02-22'),
(24, N'78:E6:7F:BD:EA:2B', N'Heart Rate Monitor', N'UnderMaintenance', '2026-01-10'),
(25, N'A5:CB:6C:C4:D8:83', N'Heart Rate Monitor', N'Active', '2025-10-10'),
(26, N'1A:AA:78:F1:B5:17', N'Heart Rate Monitor', N'Active', '2026-04-20'),
(27, N'C3:9A:CA:BD:43:15', N'Temperature Sensor', N'Active', '2026-01-29'),
(28, N'FC:AD:EF:43:2D:A2', N'ECG Monitor', N'Active', '2026-03-08'),
(29, N'85:3B:A0:16:41:FF', N'IV Infusion Pump', N'Active', '2025-09-09'),
(30, N'DC:90:86:87:A0:DF', N'Pulse Oximeter', N'Active', '2026-01-15');
SET IDENTITY_INSERT [iotdevice] OFF;


GO


-- ============================================================
-- 14b. DEVICE-TO-PATIENT ASSIGNMENTS
-- ============================================================

SET IDENTITY_INSERT [devicetransfer] ON;
INSERT INTO [devicetransfer] ([id], [patientID], [admissionID], [departmentID], [bedID], [iotdeviceID], [assignedAt], [unassignedAt]) VALUES
(1, N'901-15-6688', 56, 8, 38, 29, '2026-07-04', NULL),
(2, N'952-63-7381', 29, 7, 35, 23, '2026-07-02', NULL),
(3, N'242-23-9935', 55, 3, 12, 9, '2026-07-07', NULL),
(4, N'546-87-9379', 14, 5, 23, 15, '2026-07-05', NULL),
(5, N'981-11-2876', 24, 3, 11, 2, '2026-07-07', NULL),
(6, N'566-63-4185', 50, 1, 3, 22, '2026-07-05', NULL),
(7, N'242-23-9935', 33, 2, 10, 14, '2026-07-02', NULL),
(8, N'506-35-2245', 51, 2, 6, 1, '2026-07-02', NULL),
(9, N'374-51-5022', 32, 3, 13, 26, '2026-07-07', NULL),
(10, N'390-75-6491', 36, 3, 15, 30, '2026-07-04', NULL),
(11, N'506-35-2245', 43, 4, 20, 12, '2026-07-05', NULL),
(12, N'319-79-3167', 17, 6, 27, 21, '2026-07-03', NULL),
(13, N'566-63-4185', 6, 1, 1, 27, '2026-07-07', NULL),
(14, N'919-87-4613', 10, 7, 32, 10, '2026-07-05', NULL),
(15, N'324-97-6313', 11, 8, 37, 25, '2026-07-06', NULL),
(16, N'316-68-6355', 48, 6, 26, 20, '2026-07-07', NULL),
(17, N'489-22-6881', 53, 7, 34, 7, '2026-07-07', NULL),
(18, N'904-84-6279', 15, 5, 24, 11, '2026-07-04', NULL),
(19, N'458-49-4728', 9, 1, 2, 8, '2026-07-02', NULL),
(20, N'578-16-2612', 39, 1, 5, 3, '2026-07-02', NULL),
(21, N'860-80-3546', 47, 1, 4, 13, '2026-07-04', NULL),
(22, N'230-89-9751', 12, 4, 17, 28, '2026-07-04', NULL),
(23, N'901-15-6688', 41, 4, 18, 5, '2026-07-02', NULL),
(24, N'860-80-3546', 30, 2, 9, 4, '2026-07-05', NULL);
SET IDENTITY_INSERT [devicetransfer] OFF;


GO


-- ============================================================
-- 15. GLOBAL ALERT THRESHOLDS
-- ============================================================

SET IDENTITY_INSERT [AlertThreshold] ON;
INSERT INTO [AlertThreshold] ([id], [measurementType], [minValue], [maxValue], [severity], [isGlobal], [employeeID], [patientID], [createdate]) VALUES
(1, N'HeartRate', 60, 100, N'Critical', 1, NULL, NULL, '2025-12-19'),
(2, N'SpO2', 95, 100, N'Critical', 1, NULL, NULL, '2025-12-19'),
(3, N'SystolicBP', 90, 140, N'Critical', 1, NULL, NULL, '2025-12-19'),
(4, N'DiastolicBP', 60, 90, N'Critical', 1, NULL, NULL, '2025-12-19'),
(5, N'Temperature', 36.1, 37.8, N'Critical', 1, NULL, NULL, '2025-12-19'),
(6, N'GlucoseLevel', 70, 180, N'Critical', 1, NULL, NULL, '2025-12-19'),
(7, N'RespiratoryRate', 12, 20, N'Critical', 1, NULL, NULL, '2025-12-19');
SET IDENTITY_INSERT [AlertThreshold] OFF;


GO


-- ============================================================
-- 15b. IOT DEVICE LOGS (vital-sign alerts auto-generated by trigger)
-- ============================================================

SET IDENTITY_INSERT [logs] ON;
INSERT INTO [logs] ([id], [deviceID], [timestamp], [type], [value], [unit]) VALUES
(1, 29, '2026-07-04 08:21:00', N'Temperature', 37.2, N'C'),
(2, 29, '2026-07-04 14:28:00', N'Temperature', 37.3, N'C'),
(3, 29, '2026-07-04 20:46:00', N'Temperature', 37.5, N'C'),
(4, 29, '2026-07-05 02:08:00', N'Temperature', 36.2, N'C'),
(5, 29, '2026-07-04 08:41:00', N'GlucoseLevel', 157.8, N'mg/dL'),
(6, 29, '2026-07-04 14:47:00', N'GlucoseLevel', 209.5, N'mg/dL'),
(7, 29, '2026-07-04 20:25:00', N'GlucoseLevel', 96.4, N'mg/dL'),
(8, 29, '2026-07-05 02:49:00', N'GlucoseLevel', 79.8, N'mg/dL'),
(9, 29, '2026-07-04 08:54:00', N'HeartRate', 75.5, N'bpm'),
(10, 29, '2026-07-04 14:25:00', N'HeartRate', 90.1, N'bpm'),
(11, 29, '2026-07-04 20:41:00', N'HeartRate', 71.9, N'bpm'),
(12, 29, '2026-07-05 02:51:00', N'HeartRate', 92.3, N'bpm'),
(13, 23, '2026-07-04 08:08:00', N'SystolicBP', 94.8, N'mmHg'),
(14, 23, '2026-07-04 14:23:00', N'SystolicBP', 114.5, N'mmHg'),
(15, 23, '2026-07-04 20:56:00', N'SystolicBP', 103.4, N'mmHg'),
(16, 23, '2026-07-05 02:38:00', N'SystolicBP', 127.8, N'mmHg'),
(17, 23, '2026-07-04 08:51:00', N'GlucoseLevel', 90.5, N'mg/dL'),
(18, 23, '2026-07-04 14:40:00', N'GlucoseLevel', 74.4, N'mg/dL'),
(19, 23, '2026-07-04 20:21:00', N'GlucoseLevel', 144.4, N'mg/dL'),
(20, 23, '2026-07-05 02:41:00', N'GlucoseLevel', 87.1, N'mg/dL'),
(21, 23, '2026-07-04 08:31:00', N'Temperature', 37.2, N'C'),
(22, 23, '2026-07-04 14:05:00', N'Temperature', 36.8, N'C'),
(23, 23, '2026-07-04 20:58:00', N'Temperature', 36.6, N'C'),
(24, 23, '2026-07-05 02:08:00', N'Temperature', 36.6, N'C'),
(25, 9, '2026-07-04 08:18:00', N'SpO2', 97.8, N'%'),
(26, 9, '2026-07-04 14:58:00', N'SpO2', 75.4, N'%'),
(27, 9, '2026-07-04 20:06:00', N'SpO2', 98.6, N'%'),
(28, 9, '2026-07-05 02:52:00', N'SpO2', 96.3, N'%'),
(29, 9, '2026-07-04 08:05:00', N'Temperature', 36.1, N'C'),
(30, 9, '2026-07-04 14:47:00', N'Temperature', 36.4, N'C'),
(31, 9, '2026-07-04 20:11:00', N'Temperature', 36.2, N'C'),
(32, 9, '2026-07-05 02:26:00', N'Temperature', 36.6, N'C'),
(33, 9, '2026-07-04 08:37:00', N'DiastolicBP', 82.7, N'mmHg'),
(34, 9, '2026-07-04 14:28:00', N'DiastolicBP', 68.0, N'mmHg'),
(35, 9, '2026-07-04 20:58:00', N'DiastolicBP', 65.6, N'mmHg'),
(36, 9, '2026-07-05 02:11:00', N'DiastolicBP', 102.3, N'mmHg'),
(37, 15, '2026-07-04 08:34:00', N'GlucoseLevel', 49.2, N'mg/dL'),
(38, 15, '2026-07-04 14:41:00', N'GlucoseLevel', 146.1, N'mg/dL'),
(39, 15, '2026-07-04 20:55:00', N'GlucoseLevel', 151.9, N'mg/dL'),
(40, 15, '2026-07-05 02:46:00', N'GlucoseLevel', 138.0, N'mg/dL'),
(41, 15, '2026-07-04 08:39:00', N'HeartRate', 87.0, N'bpm'),
(42, 15, '2026-07-04 14:44:00', N'HeartRate', 92.2, N'bpm'),
(43, 15, '2026-07-04 20:05:00', N'HeartRate', 60.6, N'bpm'),
(44, 15, '2026-07-05 02:07:00', N'HeartRate', 87.8, N'bpm'),
(45, 15, '2026-07-04 08:12:00', N'DiastolicBP', 66.3, N'mmHg'),
(46, 15, '2026-07-04 14:41:00', N'DiastolicBP', 67.3, N'mmHg'),
(47, 15, '2026-07-04 20:53:00', N'DiastolicBP', 83.7, N'mmHg'),
(48, 15, '2026-07-05 02:12:00', N'DiastolicBP', 100.1, N'mmHg'),
(49, 2, '2026-07-04 08:10:00', N'DiastolicBP', 82.2, N'mmHg'),
(50, 2, '2026-07-04 14:28:00', N'DiastolicBP', 74.1, N'mmHg'),
(51, 2, '2026-07-04 20:55:00', N'DiastolicBP', 67.3, N'mmHg'),
(52, 2, '2026-07-05 02:18:00', N'DiastolicBP', 85.0, N'mmHg'),
(53, 2, '2026-07-04 08:03:00', N'HeartRate', 64.1, N'bpm'),
(54, 2, '2026-07-04 14:54:00', N'HeartRate', 99.2, N'bpm'),
(55, 2, '2026-07-04 20:54:00', N'HeartRate', 83.1, N'bpm'),
(56, 2, '2026-07-05 02:46:00', N'HeartRate', 71.6, N'bpm'),
(57, 2, '2026-07-04 08:31:00', N'GlucoseLevel', 126.5, N'mg/dL'),
(58, 2, '2026-07-04 14:46:00', N'GlucoseLevel', 144.7, N'mg/dL'),
(59, 2, '2026-07-04 20:52:00', N'GlucoseLevel', 95.5, N'mg/dL'),
(60, 2, '2026-07-05 02:03:00', N'GlucoseLevel', 116.4, N'mg/dL'),
(61, 22, '2026-07-04 08:17:00', N'SystolicBP', 110.9, N'mmHg'),
(62, 22, '2026-07-04 14:30:00', N'SystolicBP', 121.1, N'mmHg'),
(63, 22, '2026-07-04 20:41:00', N'SystolicBP', 124.9, N'mmHg'),
(64, 22, '2026-07-05 02:01:00', N'SystolicBP', 126.3, N'mmHg'),
(65, 22, '2026-07-04 08:30:00', N'Temperature', 36.5, N'C'),
(66, 22, '2026-07-04 14:14:00', N'Temperature', 37.3, N'C'),
(67, 22, '2026-07-04 20:58:00', N'Temperature', 37.5, N'C'),
(68, 22, '2026-07-05 02:42:00', N'Temperature', 37.6, N'C'),
(69, 22, '2026-07-04 08:46:00', N'HeartRate', 98.4, N'bpm'),
(70, 22, '2026-07-04 14:53:00', N'HeartRate', 86.1, N'bpm'),
(71, 22, '2026-07-04 20:23:00', N'HeartRate', 92.0, N'bpm'),
(72, 22, '2026-07-05 02:54:00', N'HeartRate', 68.3, N'bpm'),
(73, 14, '2026-07-04 08:42:00', N'GlucoseLevel', 89.1, N'mg/dL'),
(74, 14, '2026-07-04 14:10:00', N'GlucoseLevel', 81.1, N'mg/dL'),
(75, 14, '2026-07-04 20:26:00', N'GlucoseLevel', 124.3, N'mg/dL'),
(76, 14, '2026-07-05 02:15:00', N'GlucoseLevel', 75.2, N'mg/dL'),
(77, 14, '2026-07-04 08:01:00', N'RespiratoryRate', 14.1, N'breaths/min'),
(78, 14, '2026-07-04 14:43:00', N'RespiratoryRate', 18.6, N'breaths/min'),
(79, 14, '2026-07-04 20:57:00', N'RespiratoryRate', 18.5, N'breaths/min'),
(80, 14, '2026-07-05 02:21:00', N'RespiratoryRate', 16.9, N'breaths/min'),
(81, 14, '2026-07-04 08:07:00', N'HeartRate', 79.5, N'bpm'),
(82, 14, '2026-07-04 14:21:00', N'HeartRate', 90.8, N'bpm'),
(83, 14, '2026-07-04 20:49:00', N'HeartRate', 70.7, N'bpm'),
(84, 14, '2026-07-05 02:09:00', N'HeartRate', 94.9, N'bpm'),
(85, 1, '2026-07-04 08:45:00', N'Temperature', 47.5, N'C'),
(86, 1, '2026-07-04 14:53:00', N'Temperature', 37.8, N'C'),
(87, 1, '2026-07-04 20:50:00', N'Temperature', 37.4, N'C'),
(88, 1, '2026-07-05 02:06:00', N'Temperature', 36.2, N'C'),
(89, 1, '2026-07-04 08:06:00', N'GlucoseLevel', 83.0, N'mg/dL'),
(90, 1, '2026-07-04 14:13:00', N'GlucoseLevel', 87.3, N'mg/dL'),
(91, 1, '2026-07-04 20:18:00', N'GlucoseLevel', 153.8, N'mg/dL'),
(92, 1, '2026-07-05 02:31:00', N'GlucoseLevel', 80.9, N'mg/dL'),
(93, 1, '2026-07-04 08:41:00', N'HeartRate', 92.8, N'bpm'),
(94, 1, '2026-07-04 14:07:00', N'HeartRate', 77.6, N'bpm'),
(95, 1, '2026-07-04 20:26:00', N'HeartRate', 60.3, N'bpm'),
(96, 1, '2026-07-05 02:53:00', N'HeartRate', 73.7, N'bpm'),
(97, 26, '2026-07-04 08:17:00', N'Temperature', 37.4, N'C'),
(98, 26, '2026-07-04 14:23:00', N'Temperature', 36.5, N'C'),
(99, 26, '2026-07-04 20:48:00', N'Temperature', 36.8, N'C'),
(100, 26, '2026-07-05 02:14:00', N'Temperature', 36.8, N'C');
INSERT INTO [logs] ([id], [deviceID], [timestamp], [type], [value], [unit]) VALUES
(101, 26, '2026-07-04 08:58:00', N'SpO2', 97.3, N'%'),
(102, 26, '2026-07-04 14:54:00', N'SpO2', 98.4, N'%'),
(103, 26, '2026-07-04 20:01:00', N'SpO2', 98.9, N'%'),
(104, 26, '2026-07-05 02:45:00', N'SpO2', 99.7, N'%'),
(105, 26, '2026-07-04 08:05:00', N'HeartRate', 76.1, N'bpm'),
(106, 26, '2026-07-04 14:49:00', N'HeartRate', 62.5, N'bpm'),
(107, 26, '2026-07-04 20:48:00', N'HeartRate', 111.3, N'bpm'),
(108, 26, '2026-07-05 02:36:00', N'HeartRate', 123.7, N'bpm'),
(109, 30, '2026-07-04 08:26:00', N'GlucoseLevel', 144.9, N'mg/dL'),
(110, 30, '2026-07-04 14:35:00', N'GlucoseLevel', 149.4, N'mg/dL'),
(111, 30, '2026-07-04 20:20:00', N'GlucoseLevel', 70.9, N'mg/dL'),
(112, 30, '2026-07-05 02:17:00', N'GlucoseLevel', 137.1, N'mg/dL'),
(113, 30, '2026-07-04 08:09:00', N'Temperature', 36.9, N'C'),
(114, 30, '2026-07-04 14:13:00', N'Temperature', 37.2, N'C'),
(115, 30, '2026-07-04 20:39:00', N'Temperature', 37.3, N'C'),
(116, 30, '2026-07-05 02:56:00', N'Temperature', 37.2, N'C'),
(117, 30, '2026-07-04 08:49:00', N'SystolicBP', 105.1, N'mmHg'),
(118, 30, '2026-07-04 14:02:00', N'SystolicBP', 109.5, N'mmHg'),
(119, 30, '2026-07-04 20:46:00', N'SystolicBP', 96.3, N'mmHg'),
(120, 30, '2026-07-05 02:34:00', N'SystolicBP', 94.6, N'mmHg'),
(121, 12, '2026-07-04 08:21:00', N'Temperature', 36.4, N'C'),
(122, 12, '2026-07-04 14:01:00', N'Temperature', 37.0, N'C'),
(123, 12, '2026-07-04 20:16:00', N'Temperature', 37.4, N'C'),
(124, 12, '2026-07-05 02:46:00', N'Temperature', 37.0, N'C'),
(125, 12, '2026-07-04 08:46:00', N'SystolicBP', 75.4, N'mmHg'),
(126, 12, '2026-07-04 14:22:00', N'SystolicBP', 127.8, N'mmHg'),
(127, 12, '2026-07-04 20:07:00', N'SystolicBP', 118.6, N'mmHg'),
(128, 12, '2026-07-05 02:00:00', N'SystolicBP', 139.1, N'mmHg'),
(129, 12, '2026-07-04 08:51:00', N'RespiratoryRate', 16.7, N'breaths/min'),
(130, 12, '2026-07-04 14:45:00', N'RespiratoryRate', 17.0, N'breaths/min'),
(131, 12, '2026-07-04 20:34:00', N'RespiratoryRate', 13.9, N'breaths/min'),
(132, 12, '2026-07-05 02:19:00', N'RespiratoryRate', 18.3, N'breaths/min'),
(133, 21, '2026-07-04 08:45:00', N'GlucoseLevel', 151.1, N'mg/dL'),
(134, 21, '2026-07-04 14:06:00', N'GlucoseLevel', 134.1, N'mg/dL'),
(135, 21, '2026-07-04 20:52:00', N'GlucoseLevel', 120.0, N'mg/dL'),
(136, 21, '2026-07-05 02:09:00', N'GlucoseLevel', 161.1, N'mg/dL'),
(137, 21, '2026-07-04 08:05:00', N'Temperature', 26.3, N'C'),
(138, 21, '2026-07-04 14:13:00', N'Temperature', 36.7, N'C'),
(139, 21, '2026-07-04 20:33:00', N'Temperature', 37.1, N'C'),
(140, 21, '2026-07-05 02:49:00', N'Temperature', 36.5, N'C'),
(141, 21, '2026-07-04 08:31:00', N'SpO2', 100.0, N'%'),
(142, 21, '2026-07-04 14:44:00', N'SpO2', 97.4, N'%'),
(143, 21, '2026-07-04 20:26:00', N'SpO2', 95.7, N'%'),
(144, 21, '2026-07-05 02:08:00', N'SpO2', 97.3, N'%'),
(145, 27, '2026-07-04 08:07:00', N'GlucoseLevel', 120.1, N'mg/dL'),
(146, 27, '2026-07-04 14:02:00', N'GlucoseLevel', 173.8, N'mg/dL'),
(147, 27, '2026-07-04 20:23:00', N'GlucoseLevel', 83.1, N'mg/dL'),
(148, 27, '2026-07-05 02:54:00', N'GlucoseLevel', 83.3, N'mg/dL'),
(149, 27, '2026-07-04 08:36:00', N'Temperature', 37.0, N'C'),
(150, 27, '2026-07-04 14:07:00', N'Temperature', 37.8, N'C'),
(151, 27, '2026-07-04 20:19:00', N'Temperature', 36.1, N'C'),
(152, 27, '2026-07-05 02:09:00', N'Temperature', 37.1, N'C'),
(153, 27, '2026-07-04 08:03:00', N'RespiratoryRate', 14.4, N'breaths/min'),
(154, 27, '2026-07-04 14:18:00', N'RespiratoryRate', 18.6, N'breaths/min'),
(155, 27, '2026-07-04 20:31:00', N'RespiratoryRate', 21.9, N'breaths/min'),
(156, 27, '2026-07-05 02:02:00', N'RespiratoryRate', 16.6, N'breaths/min'),
(157, 10, '2026-07-04 08:50:00', N'Temperature', 37.5, N'C'),
(158, 10, '2026-07-04 14:53:00', N'Temperature', 37.4, N'C'),
(159, 10, '2026-07-04 20:32:00', N'Temperature', 37.4, N'C'),
(160, 10, '2026-07-05 02:42:00', N'Temperature', 37.6, N'C'),
(161, 10, '2026-07-04 08:20:00', N'DiastolicBP', 109.5, N'mmHg'),
(162, 10, '2026-07-04 14:24:00', N'DiastolicBP', 71.9, N'mmHg'),
(163, 10, '2026-07-04 20:34:00', N'DiastolicBP', 106.0, N'mmHg'),
(164, 10, '2026-07-05 02:17:00', N'DiastolicBP', 86.0, N'mmHg'),
(165, 10, '2026-07-04 08:45:00', N'SystolicBP', 175.0, N'mmHg'),
(166, 10, '2026-07-04 14:19:00', N'SystolicBP', 96.2, N'mmHg'),
(167, 10, '2026-07-04 20:35:00', N'SystolicBP', 167.9, N'mmHg'),
(168, 10, '2026-07-05 02:48:00', N'SystolicBP', 157.0, N'mmHg'),
(169, 25, '2026-07-04 08:07:00', N'DiastolicBP', 76.0, N'mmHg'),
(170, 25, '2026-07-04 14:01:00', N'DiastolicBP', 66.2, N'mmHg'),
(171, 25, '2026-07-04 20:53:00', N'DiastolicBP', 86.6, N'mmHg'),
(172, 25, '2026-07-05 02:28:00', N'DiastolicBP', 103.5, N'mmHg'),
(173, 25, '2026-07-04 08:37:00', N'Temperature', 41.0, N'C'),
(174, 25, '2026-07-04 14:27:00', N'Temperature', 36.1, N'C'),
(175, 25, '2026-07-04 20:33:00', N'Temperature', 36.5, N'C'),
(176, 25, '2026-07-05 02:07:00', N'Temperature', 37.0, N'C'),
(177, 25, '2026-07-04 08:18:00', N'HeartRate', 70.2, N'bpm'),
(178, 25, '2026-07-04 14:05:00', N'HeartRate', 98.1, N'bpm'),
(179, 25, '2026-07-04 20:43:00', N'HeartRate', 84.6, N'bpm'),
(180, 25, '2026-07-05 02:20:00', N'HeartRate', 88.5, N'bpm'),
(181, 20, '2026-07-04 08:20:00', N'SystolicBP', 134.7, N'mmHg'),
(182, 20, '2026-07-04 14:16:00', N'SystolicBP', 131.4, N'mmHg'),
(183, 20, '2026-07-04 20:07:00', N'SystolicBP', 74.8, N'mmHg'),
(184, 20, '2026-07-05 02:15:00', N'SystolicBP', 127.6, N'mmHg'),
(185, 20, '2026-07-04 08:24:00', N'DiastolicBP', 68.1, N'mmHg'),
(186, 20, '2026-07-04 14:20:00', N'DiastolicBP', 72.2, N'mmHg'),
(187, 20, '2026-07-04 20:30:00', N'DiastolicBP', 115.3, N'mmHg'),
(188, 20, '2026-07-05 02:01:00', N'DiastolicBP', 88.9, N'mmHg'),
(189, 20, '2026-07-04 08:43:00', N'HeartRate', 90.5, N'bpm'),
(190, 20, '2026-07-04 14:41:00', N'HeartRate', 72.2, N'bpm'),
(191, 20, '2026-07-04 20:26:00', N'HeartRate', 93.9, N'bpm'),
(192, 20, '2026-07-05 02:32:00', N'HeartRate', 98.7, N'bpm'),
(193, 7, '2026-07-04 08:50:00', N'SystolicBP', 137.6, N'mmHg'),
(194, 7, '2026-07-04 14:58:00', N'SystolicBP', 92.1, N'mmHg'),
(195, 7, '2026-07-04 20:52:00', N'SystolicBP', 131.5, N'mmHg'),
(196, 7, '2026-07-05 02:18:00', N'SystolicBP', 98.4, N'mmHg'),
(197, 7, '2026-07-04 08:03:00', N'Temperature', 36.9, N'C'),
(198, 7, '2026-07-04 14:38:00', N'Temperature', 37.3, N'C'),
(199, 7, '2026-07-04 20:22:00', N'Temperature', 36.5, N'C'),
(200, 7, '2026-07-05 02:53:00', N'Temperature', 36.2, N'C');
INSERT INTO [logs] ([id], [deviceID], [timestamp], [type], [value], [unit]) VALUES
(201, 7, '2026-07-04 08:47:00', N'SpO2', 95.3, N'%'),
(202, 7, '2026-07-04 14:05:00', N'SpO2', 95.6, N'%'),
(203, 7, '2026-07-04 20:08:00', N'SpO2', 100.0, N'%'),
(204, 7, '2026-07-05 02:56:00', N'SpO2', 98.1, N'%'),
(205, 11, '2026-07-04 08:40:00', N'RespiratoryRate', 18.0, N'breaths/min'),
(206, 11, '2026-07-04 14:28:00', N'RespiratoryRate', 17.3, N'breaths/min'),
(207, 11, '2026-07-04 20:20:00', N'RespiratoryRate', 15.7, N'breaths/min'),
(208, 11, '2026-07-05 02:38:00', N'RespiratoryRate', 19.3, N'breaths/min'),
(209, 11, '2026-07-04 08:08:00', N'SystolicBP', 90.1, N'mmHg'),
(210, 11, '2026-07-04 14:30:00', N'SystolicBP', 66.4, N'mmHg'),
(211, 11, '2026-07-04 20:35:00', N'SystolicBP', 125.2, N'mmHg'),
(212, 11, '2026-07-05 02:48:00', N'SystolicBP', 94.1, N'mmHg'),
(213, 11, '2026-07-04 08:56:00', N'GlucoseLevel', 78.5, N'mg/dL'),
(214, 11, '2026-07-04 14:01:00', N'GlucoseLevel', 159.8, N'mg/dL'),
(215, 11, '2026-07-04 20:28:00', N'GlucoseLevel', 108.8, N'mg/dL'),
(216, 11, '2026-07-05 02:52:00', N'GlucoseLevel', 136.1, N'mg/dL'),
(217, 8, '2026-07-04 08:07:00', N'DiastolicBP', 88.1, N'mmHg'),
(218, 8, '2026-07-04 14:28:00', N'DiastolicBP', 112.2, N'mmHg'),
(219, 8, '2026-07-04 20:43:00', N'DiastolicBP', 70.7, N'mmHg'),
(220, 8, '2026-07-05 02:05:00', N'DiastolicBP', 78.8, N'mmHg'),
(221, 8, '2026-07-04 08:51:00', N'SpO2', 96.2, N'%'),
(222, 8, '2026-07-04 14:31:00', N'SpO2', 95.2, N'%'),
(223, 8, '2026-07-04 20:31:00', N'SpO2', 98.5, N'%'),
(224, 8, '2026-07-05 02:13:00', N'SpO2', 122.0, N'%'),
(225, 8, '2026-07-04 08:07:00', N'HeartRate', 82.8, N'bpm'),
(226, 8, '2026-07-04 14:31:00', N'HeartRate', 67.8, N'bpm'),
(227, 8, '2026-07-04 20:47:00', N'HeartRate', 87.3, N'bpm'),
(228, 8, '2026-07-05 02:36:00', N'HeartRate', 83.5, N'bpm'),
(229, 3, '2026-07-04 08:16:00', N'GlucoseLevel', 164.1, N'mg/dL'),
(230, 3, '2026-07-04 14:56:00', N'GlucoseLevel', 156.0, N'mg/dL'),
(231, 3, '2026-07-04 20:12:00', N'GlucoseLevel', 72.5, N'mg/dL'),
(232, 3, '2026-07-05 02:44:00', N'GlucoseLevel', 137.6, N'mg/dL'),
(233, 3, '2026-07-04 08:43:00', N'HeartRate', 78.2, N'bpm'),
(234, 3, '2026-07-04 14:27:00', N'HeartRate', 97.7, N'bpm'),
(235, 3, '2026-07-04 20:03:00', N'HeartRate', 72.9, N'bpm'),
(236, 3, '2026-07-05 02:54:00', N'HeartRate', 71.0, N'bpm'),
(237, 3, '2026-07-04 08:43:00', N'SpO2', 97.5, N'%'),
(238, 3, '2026-07-04 14:33:00', N'SpO2', 99.4, N'%'),
(239, 3, '2026-07-04 20:14:00', N'SpO2', 119.7, N'%'),
(240, 3, '2026-07-05 02:20:00', N'SpO2', 68.2, N'%'),
(241, 13, '2026-07-04 08:44:00', N'Temperature', 36.2, N'C'),
(242, 13, '2026-07-04 14:15:00', N'Temperature', 36.7, N'C'),
(243, 13, '2026-07-04 20:04:00', N'Temperature', 36.3, N'C'),
(244, 13, '2026-07-05 02:30:00', N'Temperature', 36.1, N'C'),
(245, 13, '2026-07-04 08:51:00', N'HeartRate', 73.4, N'bpm'),
(246, 13, '2026-07-04 14:16:00', N'HeartRate', 78.9, N'bpm'),
(247, 13, '2026-07-04 20:21:00', N'HeartRate', 92.9, N'bpm'),
(248, 13, '2026-07-05 02:33:00', N'HeartRate', 97.7, N'bpm'),
(249, 13, '2026-07-04 08:49:00', N'SpO2', 97.2, N'%'),
(250, 13, '2026-07-04 14:06:00', N'SpO2', 97.9, N'%'),
(251, 13, '2026-07-04 20:05:00', N'SpO2', 99.6, N'%'),
(252, 13, '2026-07-05 02:24:00', N'SpO2', 99.2, N'%'),
(253, 28, '2026-07-04 08:58:00', N'HeartRate', 62.2, N'bpm'),
(254, 28, '2026-07-04 14:39:00', N'HeartRate', 62.6, N'bpm'),
(255, 28, '2026-07-04 20:43:00', N'HeartRate', 53.2, N'bpm'),
(256, 28, '2026-07-05 02:25:00', N'HeartRate', 113.1, N'bpm'),
(257, 28, '2026-07-04 08:38:00', N'SpO2', 98.1, N'%'),
(258, 28, '2026-07-04 14:29:00', N'SpO2', 99.0, N'%'),
(259, 28, '2026-07-04 20:56:00', N'SpO2', 95.5, N'%'),
(260, 28, '2026-07-05 02:41:00', N'SpO2', 98.9, N'%'),
(261, 28, '2026-07-04 08:29:00', N'RespiratoryRate', 16.7, N'breaths/min'),
(262, 28, '2026-07-04 14:06:00', N'RespiratoryRate', 16.8, N'breaths/min'),
(263, 28, '2026-07-04 20:04:00', N'RespiratoryRate', 18.7, N'breaths/min'),
(264, 28, '2026-07-05 02:57:00', N'RespiratoryRate', 17.1, N'breaths/min'),
(265, 5, '2026-07-04 08:30:00', N'SystolicBP', 112.2, N'mmHg'),
(266, 5, '2026-07-04 14:15:00', N'SystolicBP', 92.2, N'mmHg'),
(267, 5, '2026-07-04 20:08:00', N'SystolicBP', 111.8, N'mmHg'),
(268, 5, '2026-07-05 02:41:00', N'SystolicBP', 105.6, N'mmHg'),
(269, 5, '2026-07-04 08:56:00', N'RespiratoryRate', 13.2, N'breaths/min'),
(270, 5, '2026-07-04 14:30:00', N'RespiratoryRate', 14.7, N'breaths/min'),
(271, 5, '2026-07-04 20:23:00', N'RespiratoryRate', 16.1, N'breaths/min'),
(272, 5, '2026-07-05 02:42:00', N'RespiratoryRate', 12.5, N'breaths/min'),
(273, 5, '2026-07-04 08:32:00', N'DiastolicBP', 76.8, N'mmHg'),
(274, 5, '2026-07-04 14:03:00', N'DiastolicBP', 65.9, N'mmHg'),
(275, 5, '2026-07-04 20:12:00', N'DiastolicBP', 66.0, N'mmHg'),
(276, 5, '2026-07-05 02:04:00', N'DiastolicBP', 80.0, N'mmHg'),
(277, 4, '2026-07-04 08:38:00', N'GlucoseLevel', 163.7, N'mg/dL'),
(278, 4, '2026-07-04 14:36:00', N'GlucoseLevel', 137.8, N'mg/dL'),
(279, 4, '2026-07-04 20:26:00', N'GlucoseLevel', 81.5, N'mg/dL'),
(280, 4, '2026-07-05 02:56:00', N'GlucoseLevel', 74.6, N'mg/dL'),
(281, 4, '2026-07-04 08:14:00', N'RespiratoryRate', 17.1, N'breaths/min'),
(282, 4, '2026-07-04 14:44:00', N'RespiratoryRate', 17.0, N'breaths/min'),
(283, 4, '2026-07-04 20:15:00', N'RespiratoryRate', 18.1, N'breaths/min'),
(284, 4, '2026-07-05 02:52:00', N'RespiratoryRate', 17.9, N'breaths/min'),
(285, 4, '2026-07-04 08:13:00', N'DiastolicBP', 84.8, N'mmHg'),
(286, 4, '2026-07-04 14:00:00', N'DiastolicBP', 62.2, N'mmHg'),
(287, 4, '2026-07-04 20:01:00', N'DiastolicBP', 64.3, N'mmHg'),
(288, 4, '2026-07-05 02:28:00', N'DiastolicBP', 77.6, N'mmHg');
SET IDENTITY_INSERT [logs] OFF;


GO


-- ============================================================
-- 16. FINAL BED OCCUPANCY SNAPSHOT (realistic current state)
-- ============================================================

UPDATE [bed] SET [status] = N'Occupied' WHERE [id] = 1;
UPDATE [bed] SET [status] = N'Occupied' WHERE [id] = 2;
UPDATE [bed] SET [status] = N'Occupied' WHERE [id] = 3;
UPDATE [bed] SET [status] = N'Occupied' WHERE [id] = 4;
UPDATE [bed] SET [status] = N'Occupied' WHERE [id] = 5;
UPDATE [bed] SET [status] = N'Occupied' WHERE [id] = 6;
UPDATE [bed] SET [status] = N'Reserved' WHERE [id] = 7;
UPDATE [bed] SET [status] = N'Occupied' WHERE [id] = 8;
UPDATE [bed] SET [status] = N'Occupied' WHERE [id] = 9;
UPDATE [bed] SET [status] = N'Free' WHERE [id] = 10;
UPDATE [bed] SET [status] = N'Occupied' WHERE [id] = 11;
UPDATE [bed] SET [status] = N'Occupied' WHERE [id] = 12;
UPDATE [bed] SET [status] = N'Free' WHERE [id] = 13;
UPDATE [bed] SET [status] = N'Occupied' WHERE [id] = 14;
UPDATE [bed] SET [status] = N'Occupied' WHERE [id] = 15;
UPDATE [bed] SET [status] = N'Free' WHERE [id] = 16;
UPDATE [bed] SET [status] = N'Occupied' WHERE [id] = 17;
UPDATE [bed] SET [status] = N'Free' WHERE [id] = 18;
UPDATE [bed] SET [status] = N'Occupied' WHERE [id] = 19;
UPDATE [bed] SET [status] = N'Occupied' WHERE [id] = 20;
UPDATE [bed] SET [status] = N'Occupied' WHERE [id] = 21;
UPDATE [bed] SET [status] = N'Free' WHERE [id] = 22;
UPDATE [bed] SET [status] = N'Occupied' WHERE [id] = 23;
UPDATE [bed] SET [status] = N'Free' WHERE [id] = 24;
UPDATE [bed] SET [status] = N'Reserved' WHERE [id] = 25;
UPDATE [bed] SET [status] = N'Free' WHERE [id] = 26;
UPDATE [bed] SET [status] = N'Occupied' WHERE [id] = 27;
UPDATE [bed] SET [status] = N'Free' WHERE [id] = 28;
UPDATE [bed] SET [status] = N'Free' WHERE [id] = 29;
UPDATE [bed] SET [status] = N'Occupied' WHERE [id] = 30;
UPDATE [bed] SET [status] = N'Occupied' WHERE [id] = 31;
UPDATE [bed] SET [status] = N'Occupied' WHERE [id] = 32;
UPDATE [bed] SET [status] = N'Free' WHERE [id] = 33;
UPDATE [bed] SET [status] = N'Occupied' WHERE [id] = 34;
UPDATE [bed] SET [status] = N'Free' WHERE [id] = 35;
UPDATE [bed] SET [status] = N'Reserved' WHERE [id] = 36;
UPDATE [bed] SET [status] = N'Occupied' WHERE [id] = 37;
UPDATE [bed] SET [status] = N'Free' WHERE [id] = 38;
UPDATE [bed] SET [status] = N'Occupied' WHERE [id] = 39;
UPDATE [bed] SET [status] = N'Free' WHERE [id] = 40;

GO


-- ============================================================
-- 17. USER ACCOUNTS / LOGIN CREDENTIALS
-- ============================================================

DECLARE @salt_laura_young uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'laura.young', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_laura_young) + N'Passw0rd!'), @salt_laura_young, N'Patient', N'470-91-8532', NULL);
DECLARE @salt_linda_rodriguez uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'linda.rodriguez', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_linda_rodriguez) + N'Passw0rd!'), @salt_linda_rodriguez, N'Patient', N'860-80-3546', NULL);
DECLARE @salt_jason_perez uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'jason.perez', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_jason_perez) + N'Passw0rd!'), @salt_jason_perez, N'Patient', N'489-22-6881', NULL);
DECLARE @salt_mary_scott uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'mary.scott', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_mary_scott) + N'Passw0rd!'), @salt_mary_scott, N'Patient', N'529-38-8359', NULL);
DECLARE @salt_susan_wright uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'susan.wright', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_susan_wright) + N'Passw0rd!'), @salt_susan_wright, N'Patient', N'830-49-7537', NULL);
DECLARE @salt_david_walker uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'david.walker', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_david_walker) + N'Passw0rd!'), @salt_david_walker, N'Patient', N'323-69-5198', NULL);
DECLARE @salt_deborah_scott uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'deborah.scott', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_deborah_scott) + N'Passw0rd!'), @salt_deborah_scott, N'Patient', N'258-34-5861', NULL);
DECLARE @salt_jennifer_garcia uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'jennifer.garcia', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_jennifer_garcia) + N'Passw0rd!'), @salt_jennifer_garcia, N'Patient', N'878-78-3060', NULL);
DECLARE @salt_steven_thomas uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'steven.thomas', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_steven_thomas) + N'Passw0rd!'), @salt_steven_thomas, N'Patient', N'319-79-3167', NULL);
DECLARE @salt_elizabeth_ramirez uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'elizabeth.ramirez', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_elizabeth_ramirez) + N'Passw0rd!'), @salt_elizabeth_ramirez, N'Patient', N'355-19-8260', NULL);
DECLARE @salt_rebecca_sanchez uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'rebecca.sanchez', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_rebecca_sanchez) + N'Passw0rd!'), @salt_rebecca_sanchez, N'Patient', N'230-89-9751', NULL);
DECLARE @salt_jessica_taylor uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'jessica.taylor', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_jessica_taylor) + N'Passw0rd!'), @salt_jessica_taylor, N'Patient', N'568-50-2188', NULL);
DECLARE @salt_paul_flores uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'paul.flores', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_paul_flores) + N'Passw0rd!'), @salt_paul_flores, N'Patient', N'566-63-4185', NULL);
DECLARE @salt_edward_ramirez uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'edward.ramirez', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_edward_ramirez) + N'Passw0rd!'), @salt_edward_ramirez, N'Patient', N'578-16-2612', NULL);
DECLARE @salt_thomas_perez uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'thomas.perez', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_thomas_perez) + N'Passw0rd!'), @salt_thomas_perez, N'Patient', N'182-27-3471', NULL);
DECLARE @salt_andrew_brown uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'andrew.brown', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_andrew_brown) + N'Passw0rd!'), @salt_andrew_brown, N'Patient', N'329-93-2124', NULL);
DECLARE @salt_kathleen_martin uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'kathleen.martin', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_kathleen_martin) + N'Passw0rd!'), @salt_kathleen_martin, N'Patient', N'506-35-2245', NULL);
DECLARE @salt_sandra_rodriguez uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'sandra.rodriguez', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_sandra_rodriguez) + N'Passw0rd!'), @salt_sandra_rodriguez, N'Patient', N'672-86-6198', NULL);
DECLARE @salt_mark_clark uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'mark.clark', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_mark_clark) + N'Passw0rd!'), @salt_mark_clark, N'Patient', N'952-63-7381', NULL);
DECLARE @salt_jason_moore uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'jason.moore', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_jason_moore) + N'Passw0rd!'), @salt_jason_moore, N'Patient', N'509-96-9785', NULL);
DECLARE @salt_andrew_jackson uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'andrew.jackson', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_andrew_jackson) + N'Passw0rd!'), @salt_andrew_jackson, N'Patient', N'982-56-4150', NULL);
DECLARE @salt_mary_mitchell uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'mary.mitchell', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_mary_mitchell) + N'Passw0rd!'), @salt_mary_mitchell, N'Patient', N'242-23-9935', NULL);
DECLARE @salt_gary_williams uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'gary.williams', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_gary_williams) + N'Passw0rd!'), @salt_gary_williams, N'Patient', N'798-41-2684', NULL);
DECLARE @salt_deborah_walker uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'deborah.walker', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_deborah_walker) + N'Passw0rd!'), @salt_deborah_walker, N'Patient', N'960-91-5543', NULL);
DECLARE @salt_michael_harris uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'michael.harris', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_michael_harris) + N'Passw0rd!'), @salt_michael_harris, N'Patient', N'266-57-6820', NULL);
DECLARE @salt_rebecca_mitchell uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'rebecca.mitchell', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_rebecca_mitchell) + N'Passw0rd!'), @salt_rebecca_mitchell, N'Patient', N'390-75-6491', NULL);
DECLARE @salt_michelle_thomas uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'michelle.thomas', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_michelle_thomas) + N'Passw0rd!'), @salt_michelle_thomas, N'Patient', N'734-20-7868', NULL);
DECLARE @salt_anthony_thompson uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'anthony.thompson', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_anthony_thompson) + N'Passw0rd!'), @salt_anthony_thompson, N'Patient', N'546-87-9379', NULL);
DECLARE @salt_william_wright uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'william.wright', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_william_wright) + N'Passw0rd!'), @salt_william_wright, N'Patient', N'100-86-6310', NULL);
DECLARE @salt_kenneth_rivera uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'kenneth.rivera', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_kenneth_rivera) + N'Passw0rd!'), @salt_kenneth_rivera, N'Patient', N'505-92-8517', NULL);
DECLARE @salt_cynthia_carter uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'cynthia.carter', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_cynthia_carter) + N'Passw0rd!'), @salt_cynthia_carter, N'Doctor', NULL, 1);
DECLARE @salt_edward_jackson uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'edward.jackson', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_edward_jackson) + N'Passw0rd!'), @salt_edward_jackson, N'Doctor', NULL, 2);
DECLARE @salt_stephanie_green uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'stephanie.green', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_stephanie_green) + N'Passw0rd!'), @salt_stephanie_green, N'Doctor', NULL, 3);
DECLARE @salt_cynthia_johnson uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'cynthia.johnson', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_cynthia_johnson) + N'Passw0rd!'), @salt_cynthia_johnson, N'Doctor', NULL, 4);
DECLARE @salt_anthony_martinez uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'anthony.martinez', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_anthony_martinez) + N'Passw0rd!'), @salt_anthony_martinez, N'Doctor', NULL, 5);
DECLARE @salt_john_flores uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'john.flores', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_john_flores) + N'Passw0rd!'), @salt_john_flores, N'Doctor', NULL, 6);
DECLARE @salt_kenneth_martinez uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'kenneth.martinez', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_kenneth_martinez) + N'Passw0rd!'), @salt_kenneth_martinez, N'Doctor', NULL, 7);
DECLARE @salt_edward_smith uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'edward.smith', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_edward_smith) + N'Passw0rd!'), @salt_edward_smith, N'Doctor', NULL, 8);
DECLARE @salt_mark_thompson uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'mark.thompson', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_mark_thompson) + N'Passw0rd!'), @salt_mark_thompson, N'Doctor', NULL, 9);
DECLARE @salt_sandra_martin uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'sandra.martin', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_sandra_martin) + N'Passw0rd!'), @salt_sandra_martin, N'Doctor', NULL, 10);
DECLARE @salt_kenneth_thompson uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'kenneth.thompson', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_kenneth_thompson) + N'Passw0rd!'), @salt_kenneth_thompson, N'Doctor', NULL, 11);
DECLARE @salt_ryan_nelson uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'ryan.nelson', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_ryan_nelson) + N'Passw0rd!'), @salt_ryan_nelson, N'Doctor', NULL, 12);
DECLARE @salt_deborah_young uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'deborah.young', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_deborah_young) + N'Passw0rd!'), @salt_deborah_young, N'Doctor', NULL, 13);
DECLARE @salt_richard_flores uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'richard.flores', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_richard_flores) + N'Passw0rd!'), @salt_richard_flores, N'Doctor', NULL, 14);
DECLARE @salt_cynthia_green uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'cynthia.green', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_cynthia_green) + N'Passw0rd!'), @salt_cynthia_green, N'Doctor', NULL, 15);
DECLARE @salt_daniel_campbell uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'daniel.campbell', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_daniel_campbell) + N'Passw0rd!'), @salt_daniel_campbell, N'Nurse', NULL, 16);
DECLARE @salt_barbara_gonzalez uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'barbara.gonzalez', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_barbara_gonzalez) + N'Passw0rd!'), @salt_barbara_gonzalez, N'Nurse', NULL, 17);
DECLARE @salt_sarah_hernandez uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'sarah.hernandez', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_sarah_hernandez) + N'Passw0rd!'), @salt_sarah_hernandez, N'Nurse', NULL, 18);
DECLARE @salt_sandra_jones uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'sandra.jones', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_sandra_jones) + N'Passw0rd!'), @salt_sandra_jones, N'Nurse', NULL, 19);
DECLARE @salt_rebecca_scott uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'rebecca.scott', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_rebecca_scott) + N'Passw0rd!'), @salt_rebecca_scott, N'Nurse', NULL, 20);
DECLARE @salt_linda_robinson uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'linda.robinson', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_linda_robinson) + N'Passw0rd!'), @salt_linda_robinson, N'Nurse', NULL, 21);
DECLARE @salt_carol_white uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'carol.white', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_carol_white) + N'Passw0rd!'), @salt_carol_white, N'Nurse', NULL, 22);
DECLARE @salt_gary_scott uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'gary.scott', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_gary_scott) + N'Passw0rd!'), @salt_gary_scott, N'Nurse', NULL, 23);
DECLARE @salt_sandra_hall uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'sandra.hall', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_sandra_hall) + N'Passw0rd!'), @salt_sandra_hall, N'Nurse', NULL, 24);
DECLARE @salt_robert_martin uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'robert.martin', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_robert_martin) + N'Passw0rd!'), @salt_robert_martin, N'Nurse', NULL, 25);
DECLARE @salt_elizabeth_harris uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'elizabeth.harris', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_elizabeth_harris) + N'Passw0rd!'), @salt_elizabeth_harris, N'Nurse', NULL, 26);
DECLARE @salt_deborah_martinez uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'deborah.martinez', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_deborah_martinez) + N'Passw0rd!'), @salt_deborah_martinez, N'Nurse', NULL, 27);
DECLARE @salt_sarah_williams uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'sarah.williams', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_sarah_williams) + N'Passw0rd!'), @salt_sarah_williams, N'Nurse', NULL, 28);
DECLARE @salt_jessica_white uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'jessica.white', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_jessica_white) + N'Passw0rd!'), @salt_jessica_white, N'Nurse', NULL, 29);
DECLARE @salt_carol_thompson uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'carol.thompson', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_carol_thompson) + N'Passw0rd!'), @salt_carol_thompson, N'Nurse', NULL, 30);
DECLARE @salt_sharon_robinson uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'sharon.robinson', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_sharon_robinson) + N'Passw0rd!'), @salt_sharon_robinson, N'Nurse', NULL, 31);
DECLARE @salt_patricia_perez uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'patricia.perez', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_patricia_perez) + N'Passw0rd!'), @salt_patricia_perez, N'Nurse', NULL, 32);
DECLARE @salt_donna_wilson uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'donna.wilson', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_donna_wilson) + N'Passw0rd!'), @salt_donna_wilson, N'Nurse', NULL, 33);
DECLARE @salt_rebecca_hill uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'rebecca.hill', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_rebecca_hill) + N'Passw0rd!'), @salt_rebecca_hill, N'Nurse', NULL, 34);
DECLARE @salt_rebecca_lopez uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'rebecca.lopez', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_rebecca_lopez) + N'Passw0rd!'), @salt_rebecca_lopez, N'Nurse', NULL, 35);
DECLARE @salt_jeffrey_thomas uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'jeffrey.thomas', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_jeffrey_thomas) + N'Passw0rd!'), @salt_jeffrey_thomas, N'Pharmacist', NULL, 36);
DECLARE @salt_robert_rodriguez uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'robert.rodriguez', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_robert_rodriguez) + N'Passw0rd!'), @salt_robert_rodriguez, N'Pharmacist', NULL, 37);
DECLARE @salt_john_walker uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'john.walker', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_john_walker) + N'Passw0rd!'), @salt_john_walker, N'Pharmacist', NULL, 38);
DECLARE @salt_linda_lewis uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'linda.lewis', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_linda_lewis) + N'Passw0rd!'), @salt_linda_lewis, N'LabTech', NULL, 39);
DECLARE @salt_kathleen_nelson uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'kathleen.nelson', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_kathleen_nelson) + N'Passw0rd!'), @salt_kathleen_nelson, N'LabTech', NULL, 40);
DECLARE @salt_mary_brown uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'mary.brown', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_mary_brown) + N'Passw0rd!'), @salt_mary_brown, N'LabTech', NULL, 41);
DECLARE @salt_ashley_rivera uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'ashley.rivera', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_ashley_rivera) + N'Passw0rd!'), @salt_ashley_rivera, N'Reception', NULL, 42);
DECLARE @salt_david_jones uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'david.jones', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_david_jones) + N'Passw0rd!'), @salt_david_jones, N'Reception', NULL, 43);
DECLARE @salt_margaret_hill uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'margaret.hill', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_margaret_hill) + N'Passw0rd!'), @salt_margaret_hill, N'Reception', NULL, 44);
DECLARE @salt_betty_miller uniqueidentifier = NEWID();
INSERT INTO [UserAccount] ([username],[passwordHash],[passwordSalt],[role],[patientID],[employeeID])
VALUES (N'betty.miller', HASHBYTES('SHA2_256', CONVERT(nvarchar(36), @salt_betty_miller) + N'Passw0rd!'), @salt_betty_miller, N'Manager', NULL, 45);

GO
