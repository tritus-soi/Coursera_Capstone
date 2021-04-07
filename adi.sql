-- แบบทดสอบความรู้ภาษา SQL เรื่องการติดตามทวงถามหนี้ของสัญญาที่ตกเป็นหนี้ศูนย์

-- สร้างตารางที่1 TB_DATA_WO
CREATE TABLE TB_DATA_WO (
AGREEMENT_NO INT(15) NOT NULL,
 OUTSTANDING_BALANCE INT(255) NOT NULL,
 AGE_OF_WRITE_OFF INT(2) NOT NULL,
 AUTO_TYPE_NAME CHAR(15) NOT NULL,
 COLLECTOR_CODE CHAR(6) NOT NULL,
 REPO_STATUS CHAR(1),
 PRIMARY KEY (AGREEMENT_NO)
 );

-- ใส่ข้อมูลที่เกี่ยวข้อง
INSERT INTO TB_DATA_WO(
AGREEMENT_NO,
 OUTSTANDING_BALANCE,
 AGE_OF_WRITE_OFF,
 AUTO_TYPE_NAME,
 COLLECTOR_CODE,
 REPO_STATUS)
VALUES
(061000020000929, 25000, 2, 'Motocycle', 'OA1010', null),
(061000020003800, 50000, 3, 'Motocycle', 'OA1010','W'),
(061000020005149, 165000, 2, 'Non Motorcycle', 'OA1011', 'W'),
(061000020006709, 200000, 1, 'Non Motorcycle', 'OA1012', null),
(061000020007110, 355000, 1, 'Non Motorcycle', 'OA1012', 'W')

-- ตารางที่ 2 TB_DATA_JUDETYPE
CREATE TABLE TB_DATA_JUDETYPE (
AGREEMENT_NO INT(15) NOT NULL,
 JUDGE_TYPE INT(1) NOT NULL,
 PRIMARY KEY (AGREEMENT_NO)
 );

-- ใส่ข้อมูลที่เกี่ยวข้อง
INSERT INTO TB_DATA_JUDETYPE(AGREEMENT_NO, JUDGE_TYPE)
VALUES
(061000020000929, 1),
(061000020004200, 2),
(061000020005149, 0),
(061000020003099, 1),
(061000020007110, 2)

;

-- ตารางที่ 3 TABLE TB_CAR_CASE
CREATE TABLE TB_CAR_CASE (
AGREEMENT_NO INT(15) NOT NULL,
 CAR_CASE_DESC CHAR(20) NOT NULL,
 PRIMARY KEY (AGREEMENT_NO)
 );

-- ใส่ข้อมูลที่เกี่ยวข้อง
INSERT INTO TB_CAR_CASE(AGREEMENT_NO, CAR_CASE_DESC)
VALUES
(061000020002909, 'รถที่เป็นซาก'),
(061000020001180, 'รถเคลมประกัน'),
(061000020001459, 'รถเคลมประกัน'),
(061000020006709, 'รถติดคดี'),
(061000020007220, 'รถเคลมประกัน')
;

/* 1.ให้ทำการแบ่งกลุ่มสำหรับการติดตามทวงถามหนี้ (30 คะแนน)
โดยแสดงข้อมูลดังนี้ Agreement_no, Outstanding_Balance, Judge_Type, Group, Age_Of_WO,
Auto_Type_Name
มีเงื่อนไขการแบ่งกลุ่มดังนี้
กลุ่มที่ 1 มียอดหนี้คงเหลือน้อยกว่า 50,000 บาท
กลุ่มที่ 2 มียอดหนี้คงเหลือมากกว่าเท่ากับ 50,000 บาท และไม่มีสถานะค าพิพากษาเป็น 1,2
กลุ่มที่ 3 มียอดหนี้คงเหลือมากกว่าเท่ากับ 50,000 บาท และมีสถานะค าพิพากษาเป็น 1,2
และทุกกลุ่มจะต้องไม่มีรถที่มีปัญหา เช่น รถเคลมประกัน รถที่ติดคดี และรถที่เป็นซาก */

SELECT
0||WO.AGREEMENT_NO AS AGREEMENT_NO,
WO.OUTSTANDING_BALANCE,
JUDE.JUDGE_TYPE,

CASE
 WHEN CAR.CAR_CASE_DESC IS NULL AND WO.OUTSTANDING_BALANCE < 50000 THEN 1
WHEN CAR.CAR_CASE_DESC IS NULL AND WO.OUTSTANDING_BALANCE >= 50000 AND
JUDE.JUDGE_TYPE NOT IN (1, 2) THEN 2
WHEN CAR.CAR_CASE_DESC IS NULL AND WO.OUTSTANDING_BALANCE >= 50000 AND
JUDE.JUDGE_TYPE IN (1, 2) THEN 3
END AS 'GROUP',

WO.AGE_OF_WRITE_OFF AS AGE_OF_WO,
WO.AUTO_TYPE_NAME

FROM TB_DATA_WO AS WO
LEFT JOIN TB_CAR_CASE AS CAR
ON WO.AGREEMENT_NO = CAR.AGREEMENT_NO

JOIN TB_DATA_JUDETYPE AS JUDE
ON WO.AGREEMENT_NO = JUDE.AGREEMENT_NO
;

/*ข้อ 2 .ให้ทำการคำนวณผลรวมการจ่าย Incentive ให้กับแต่ละผู้ติดตามทวงถามหนี้แต่ละกลุ่ม (50 คะแนน)
โดยแสดงข้อมูลดังนี้ Collector_Code, Agreement_no, Outstanding_Balance, Judge_Type,
Group, Age_Of_WO, Auto_Type_Name, Incentive มีเงื่อนไขการจ่าย Incentive กรณีที่ทำการยึดรถ
(สถานะของการยึดรถเป็น “W”) */


SELECT
WO.COLLECTOR_CODE,
0||WO.AGREEMENT_NO AS AGREEMENT_NO,
WO.OUTSTANDING_BALANCE,
JUDE.JUDGE_TYPE,

CASE
WHEN CAR.CAR_CASE_DESC IS NULL AND WO.OUTSTANDING_BALANCE < 50000 THEN 1
WHEN CAR.CAR_CASE_DESC IS NULL AND WO.OUTSTANDING_BALANCE >= 50000 AND
JUDE.JUDGE_TYPE NOT IN (1, 2) THEN 2
WHEN CAR.CAR_CASE_DESC IS NULL AND WO.OUTSTANDING_BALANCE >= 50000 AND
JUDE.JUDGE_TYPE IN (1, 2) THEN 3
END AS 'GROUP',

WO.AGE_OF_WRITE_OFF AS AGE_OF_WO,
WO.AUTO_TYPE_NAME,

CASE

-- Motorcycle
WHEN WO.REPO_STATUS NOT NULL AND WO.AGE_OF_WRITE_OFF <=1 AND
AUTO_TYPE_NAME='Motocycle' AND WO.OUTSTANDING_BALANCE < 10000 THEN 1500
WHEN WO.REPO_STATUS NOT NULL AND WO.AGE_OF_WRITE_OFF <=1 AND
AUTO_TYPE_NAME='Motocycle' AND WO.OUTSTANDING_BALANCE BETWEEN 10000 AND
30000 THEN 2000
WHEN WO.REPO_STATUS NOT NULL AND WO.AGE_OF_WRITE_OFF <=1 AND
AUTO_TYPE_NAME='Motocycle' AND WO.OUTSTANDING_BALANCE >= 30000 THEN 2500
WHEN WO.REPO_STATUS NOT NULL AND WO.REPO_STATUS NOT NULL AND
WO.AGE_OF_WRITE_OFF BETWEEN 2 AND 3 AND AUTO_TYPE_NAME='Motocycle' AND
WO.OUTSTANDING_BALANCE < 10000 THEN 2000
WHEN WO.REPO_STATUS NOT NULL AND WO.AGE_OF_WRITE_OFF BETWEEN 2 AND 3 AND
AUTO_TYPE_NAME='Motocycle' AND WO.OUTSTANDING_BALANCE BETWEEN 10000 AND
30000 THEN 2500
WHEN WO.REPO_STATUS NOT NULL AND WO.AGE_OF_WRITE_OFF BETWEEN 2 AND 3 AND
AUTO_TYPE_NAME='Motocycle' AND WO.OUTSTANDING_BALANCE >= 30000 THEN 3000

-- Non Motorcycle
WHEN WO.REPO_STATUS NOT NULL AND WO.AGE_OF_WRITE_OFF <=1 AND
AUTO_TYPE_NAME='Non Motorcycle'AND WO.OUTSTANDING_BALANCE < 100000 THEN 2500
WHEN WO.REPO_STATUS NOT NULL AND WO.AGE_OF_WRITE_OFF <=1 AND
AUTO_TYPE_NAME='Non Motorcycle'AND WO.OUTSTANDING_BALANCE BETWEEN 100000 AND
300000 THEN 3100
WHEN WO.REPO_STATUS NOT NULL AND WO.AGE_OF_WRITE_OFF <=1 AND
AUTO_TYPE_NAME='Non Motorcycle'AND WO.OUTSTANDING_BALANCE >= 300000 THEN 3600
WHEN WO.REPO_STATUS NOT NULL AND WO.AGE_OF_WRITE_OFF BETWEEN 2 AND 3 AND
AUTO_TYPE_NAME='Non Motorcycle' AND WO.OUTSTANDING_BALANCE < 100000 THEN 3000
WHEN WO.REPO_STATUS NOT NULL AND WO.AGE_OF_WRITE_OFF BETWEEN 2 AND 3 AND
AUTO_TYPE_NAME='Non Motorcycle' AND WO.OUTSTANDING_BALANCE BETWEEN 100000
AND 300000 THEN 3600
WHEN WO.REPO_STATUS NOT NULL AND WO.AGE_OF_WRITE_OFF BETWEEN 2 AND 3 AND
AUTO_TYPE_NAME='Non Motorcycle' AND WO.OUTSTANDING_BALANCE >= 300000 THEN 4100
END AS 'INCENTIVE'

FROM TB_DATA_WO AS WO
LEFT JOIN TB_CAR_CASE AS CAR
ON WO.AGREEMENT_NO = CAR.AGREEMENT_NO

JOIN TB_DATA_JUDETYPE AS JUDE
ON WO.AGREEMENT_NO = JUDE.AGREEMENT_NO
;

/*3.ให้ทำการหาผู้ที่ได้รับเงินค่า Incentive มากที่สุดในแต่ละกลุ่ม (20 คะแนน)
โดยแสดงข้อมูลดังนี้ Group, Collector_Code, Incentive
*/

SELECT

CASE
WHEN CAR.CAR_CASE_DESC IS NULL AND WO.OUTSTANDING_BALANCE < 50000 THEN 1
WHEN CAR.CAR_CASE_DESC IS NULL AND WO.OUTSTANDING_BALANCE >= 50000 AND
JUDE.JUDGE_TYPE NOT IN (1, 2) THEN 2
WHEN CAR.CAR_CASE_DESC IS NULL AND WO.OUTSTANDING_BALANCE >= 50000 AND
JUDE.JUDGE_TYPE IN (1, 2) THEN 3
END AS 'GROUP',

WO.COLLECTOR_CODE,

CASE

-- Motorcycle
WHEN WO.REPO_STATUS NOT NULL AND WO.AGE_OF_WRITE_OFF <=1 AND
AUTO_TYPE_NAME='Motocycle' AND WO.OUTSTANDING_BALANCE < 10000 THEN 1500
WHEN WO.REPO_STATUS NOT NULL AND WO.AGE_OF_WRITE_OFF <=1 AND
AUTO_TYPE_NAME='Motocycle' AND WO.OUTSTANDING_BALANCE BETWEEN 10000 AND 30000 THEN
2000
WHEN WO.REPO_STATUS NOT NULL AND WO.AGE_OF_WRITE_OFF <=1 AND
AUTO_TYPE_NAME='Motocycle' AND WO.OUTSTANDING_BALANCE >= 30000 THEN 2500
WHEN WO.REPO_STATUS NOT NULL AND WO.REPO_STATUS NOT NULL AND WO.AGE_OF_WRITE_OFF
BETWEEN 2 AND 3 AND AUTO_TYPE_NAME='Motocycle' AND WO.OUTSTANDING_BALANCE < 10000
THEN 2000
WHEN WO.REPO_STATUS NOT NULL AND WO.AGE_OF_WRITE_OFF BETWEEN 2 AND 3 AND
AUTO_TYPE_NAME='Motocycle' AND WO.OUTSTANDING_BALANCE BETWEEN 10000 AND 30000 THEN
2500
WHEN WO.REPO_STATUS NOT NULL AND WO.AGE_OF_WRITE_OFF BETWEEN 2 AND 3 AND
AUTO_TYPE_NAME='Motocycle' AND WO.OUTSTANDING_BALANCE >= 30000 THEN 3000

-- Non Motorcycle
WHEN WO.REPO_STATUS NOT NULL AND WO.AGE_OF_WRITE_OFF <=1 AND AUTO_TYPE_NAME='Non
Motorcycle'AND WO.OUTSTANDING_BALANCE < 100000 THEN 2500
WHEN WO.REPO_STATUS NOT NULL AND WO.AGE_OF_WRITE_OFF <=1 AND AUTO_TYPE_NAME='Non
Motorcycle'AND WO.OUTSTANDING_BALANCE BETWEEN 100000 AND 300000 THEN 3100
WHEN WO.REPO_STATUS NOT NULL AND WO.AGE_OF_WRITE_OFF <=1 AND AUTO_TYPE_NAME='Non
Motorcycle'AND WO.OUTSTANDING_BALANCE >= 300000 THEN 3600
WHEN WO.REPO_STATUS NOT NULL AND WO.AGE_OF_WRITE_OFF BETWEEN 2 AND 3 AND
AUTO_TYPE_NAME='Non Motorcycle' AND WO.OUTSTANDING_BALANCE < 100000 THEN 3000
WHEN WO.REPO_STATUS NOT NULL AND WO.AGE_OF_WRITE_OFF BETWEEN 2 AND 3 AND
AUTO_TYPE_NAME='Non Motorcycle' AND WO.OUTSTANDING_BALANCE BETWEEN 100000 AND
300000 THEN 3600
WHEN WO.REPO_STATUS NOT NULL AND WO.AGE_OF_WRITE_OFF BETWEEN 2 AND 3 AND
AUTO_TYPE_NAME='Non Motorcycle' AND WO.OUTSTANDING_BALANCE >= 300000 THEN 4100
END AS 'INCENTIVE'

FROM TB_DATA_WO AS WO
LEFT JOIN TB_CAR_CASE AS CAR
ON WO.AGREEMENT_NO = CAR.AGREEMENT_NO

JOIN TB_DATA_JUDETYPE AS JUDE
ON WO.AGREEMENT_NO = JUDE.AGREEMENT_NO
ORDER BY INCENTIVE, 'GROUP' DESC;
