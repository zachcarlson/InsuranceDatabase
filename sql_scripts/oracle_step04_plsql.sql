--------

/* Katy Matulay
Function returns age to be used in age demographic analysis view*/

CREATE OR REPLACE FUNCTION CALC_AGE(p_dob DATE)
RETURN NUMBER IS
    v_Age NUMBER(3);
    BEGIN
        v_Age := round((sysdate-p_dob)/365);
    RETURN (v_AGE);
    END CALC_AGE;
    /

--------

/*Katy Matulay
The following function calculates a cumulative comorbidity score for members, to be used in the high_risk_patient views*/

CREATE OR REPLACE FUNCTION CALC_Comorbid (p_memberID IN INT)
RETURN INT IS
    v_ComorbidityScore  INT(2);
    BEGIN
        SELECT SUM(MAX(DIABETES) + MAX(COPD) + MAX(CAD) + MAX(CHF) + MAX(HYPERTENSION))
        INTO v_ComorbidityScore
        FROM DIM_MEMBER_CONDITION
        WHERE MEMBERID = p_memberID;
        RETURN(v_ComorbidityScore);
END CALC_Comorbid;
/

--------

/*Katy Matulay
The following function calculates a comorbidity score for members in their most recent enrollment period (based on max enddate), to be used in the high_risk_patient views and HR_Mem_Outreach table */

CREATE OR REPLACE FUNCTION CALC_Comorbid_Current (p_memberID IN INT)
RETURN INT IS
v_ComorbidityScore  INT(3);
BEGIN
	SELECT SUM(DIABETES + COPD + CAD + CHF + HYPERTENSION)
	INTO v_ComorbidityScore
	FROM DIM_MEMBER_CONDITION
	WHERE MEMBERID = p_memberID
   	AND enddate =
    		(select max(enddate)
    		from dim_member_condition
   		 where memberID = p_memberID);
	RETURN(v_ComorbidityScore);
END CALC_Comorbid_Current;
/

--------

/*Katy Matulay
/*The following function determines if members have received a covid vaccination 
and represents it as a numeric count (i.e 1st dose, 2nd, 3rd, etc.), 
to be used in the high_risk_patient views
The covid vaccine code values were determined using 
https://www.cms.gov/medicare/medicare-part-b-drug-average-sales-price/covid-19-vaccines-and-monoclonal-antibodies */

CREATE OR REPLACE FUNCTION get_VaxCovid (p_memberID IN INT)
RETURN INT IS
v_covidVax INT(2);
BEGIN
	SELECT count(code_type)
	INTO v_covidVax
    	FROM CLAIM_FACT
    	WHERE code_value IN ('0001A','0002A','0003A','0004A','0011A','0012A','0013A','0064A','0071A',  '0072A','91300','91301','91302','91303','91304','91305','91306','0021A',
'0022A','0031A','0034A','0051A','0052A','0053A','0054A')
    	AND memberID = p_memberID
 	AND CLAIMSTATUSCD like 'A';
    RETURN v_covidVax;
END get_VaxCovid;
/

-------

/*Katy Matulay
The following function determines if members have received a covid vaccination in the most recent enrollment period (based on max enddate) and represents it as a numeric count (i.e 1st dose, 2nd, 3rd, etc.), 
to be used in the high_risk_patient views and HR_Mem_Outreach table
The covid vaccine code values were determined using https://www.cms.gov/medicare/medicare-part-b-drug-average-sales-price/covid-19-vaccines-and-monoclonal-antibodies */

CREATE OR REPLACE FUNCTION get_VaxCovid_Current (p_memberID IN INT)
RETURN INT IS
v_covidVax INT(2);
BEGIN
	SELECT count(CF.code_type)
	INTO v_covidVax
    	FROM CLAIM_FACT CF
    	JOIN DIM_MEMBER M
    	ON (M.memberID = CF.memberID)
    	WHERE CF.code_value IN ('0001A','0002A','0003A','0004A','0011A','0012A','0013A','0064A','0071A',  '0072A','91300','91301','91302','91303','91304','91305','91306','0021A','0022A','0031A','0034A','0051A','0052A','0053A','0054A')
    	AND CF.memberID = p_memberID
	AND CLAIMSTATUSCD like 'A'
    	AND M.enddate =
    		(select max(enddate)
    		from dim_member
    		where memberID = p_memberID);
    RETURN v_covidVax;
END get_VaxCovid_Current;
/

--------

/*Katy Matulay
The following function determines a members historical flu vaccine status as an int value, to be used in the high_risk_patient views
The flu vaccine code values were determined using https://www.cms.gov/medicare/preventive-services/flu-shot-coding */

CREATE OR REPLACE FUNCTION get_VaxFlu (p_memberID IN INT)
RETURN INT IS
v_fluVax INT(4);
BEGIN
	SELECT count(code_type)
	INTO v_fluVax
	FROM CLAIM_FACT
	WHERE code_value IN ('90630','G0008','90653','90654','90655','90656','90657','90658','90660','90662',
    '90672','90673','90674','90682','90685','90686','90687','90688','90689','90694','90756','Q2034','Q2035','Q2036','Q2037','Q2038','Q2039')
	AND CLAIMSTATUSCD like 'A'
	And memberID = p_memberID;
	RETURN v_fluVax;
END get_VaxFlu;
/

--------

/*Katy Matulay
The following function determines a members current enrollment period flu vaccine status as an int value, to be used in the high_risk_patient views and HR_Mem_Outreach table
The flu vaccine code values were determined using https://www.cms.gov/medicare/preventive-services/flu-shot-coding */

CREATE OR REPLACE FUNCTION get_VaxFlu_Current (p_memberID IN INT)
RETURN INT IS
v_fluVax INT(2);
BEGIN
	SELECT count(CF.code_type)
	INTO v_fluVax
	FROM CLAIM_FACT CF
    JOIN DIM_MEMBER M
    ON (M.memberID = CF.memberID)
	WHERE CF.code_value IN ('90630','G0008','90653','90654','90655','90656','90657','90658','90660','90662',    '90672','90673','90674','90682','90685','90686','90687','90688','90689','90694','90756','Q2034','Q2035','Q2036','Q2037','Q2038','Q2039')
	AND CF.CLAIMSTATUSCD like 'A'
    And CF.memberID = p_memberID
    AND M.enddate =
    (select max(enddate)
    from dim_member
    where memberID = p_memberID);
	RETURN v_fluVax;
END get_VaxFlu_Current;
/

------

/*Katy Matulay
The following function determines the number of preventative care visits as an int, to be used in the high_risk_patient views
Preventative care visits are denoted by the PROF_CD value of P43*/

CREATE OR REPLACE FUNCTION get_PC (p_memberID IN INT)
RETURN NUMBER IS
v_PCvisits INT(3);
BEGIN
	SELECT count(A.code_type)
	INTO v_PCvisits
	FROM CLAIM_FACT A
    JOIN DIM_PROCEDURE B
    ON (A.CODE_TYPE = B.CODE_TYPE
    AND A.CODE_VALUE = B.CODE_VALUE)
    WHERE B.PROF_CD like 'P43'
    AND A.memberID = p_memberID
    AND A.claimstatuscd like 'A';
    RETURN v_PCvisits;
END get_PC;
/

--------

/*Katy Matulay
The following function determines the number of preventative care visits as an int per current enrollment period, to be used in the high_risk_patient views and HR_Mem_Outreach table
Preventative care visits are denoted by the PROF_CD value of P43*/

CREATE OR REPLACE FUNCTION get_PC_Current (p_memberID IN INT)
RETURN NUMBER IS
v_PCvisits INT(3);
BEGIN
	SELECT count(A.code_type)
	INTO v_PCvisits
	FROM CLAIM_FACT A
    JOIN DIM_PROCEDURE B
    ON (A.CODE_TYPE = B.CODE_TYPE
    AND A.CODE_VALUE = B.CODE_VALUE)
    
    JOIN DIM_MEMBER M
    ON (M.memberID = A.memberID)
    
    WHERE B.PROF_CD like 'P43'
    AND A.memberID = p_memberID
    AND A.claimstatuscd like 'A'
    AND M.enddate =
    (select max(enddate)
    from dim_member
    where memberID = p_memberID);

    RETURN v_PCvisits;
END get_PC_Current;
/

--------
/* Katy Matulay
The following view represents a snapshot of patients historical tabulations regarding high risk conditions and preventative care. It utilizes the functions: calc_age, get_VaxCovid, get_VaxFlu, and get_PC to determine cumulative historical counts*/

DROP VIEW v_HIST_HIGH_RISK_PATIENTS;
CREATE OR REPLACE VIEW v_HIST_HIGH_RISK_PATIENTS as(
select distinct(memberID), firstname, lastname, gender, dateofbirth, MemberAge, Covid_Vaccine, Flu_Vaccine, PC_visits, Comorbidity_Count
from (
select M.memberID, M.firstname, M.lastname, M.gender, M.dateofbirth, 
calc_age(M.dateofbirth) as MemberAge, 
get_VaxCovid(M.memberID) as Covid_Vaccine, 
get_VaxFlu(M.memberID) as Flu_Vaccine, 
get_PC(M.memberID) as PC_visits, 
CALC_Comorbid_Current(M.memberID) as Comorbidity_Count
from dim_member M)
where Comorbidity_Count >1
);

/*view the results*/
select * from v_HIST_HIGH_RISK_PATIENTS;


---------
/* Jacob Stank
The following DDL creates the table HR_Mem_Outreach is to be utilized in the procedure populate_member_outreach and triggers created by other team members, and will store
member contact details, condition information, demographics, and current high risk condition calcs from earlier functions*/

/*Step1: Create DDL for High_Risk_Member_Outreach table as HR_Mem_Outreach */
DROP TABLE HR_MEM_Outreach;
CREATE TABLE HR_MEM_Outreach
    (IDNO 			INT NOT NULL,
    MemberID		INT NOT NULL,
    Gender			CHAR(1)NOT NULL,
    DateOfBirth		DATE NOT NULL,
    Age			INT NOT NULL,
    Firstname		VARCHAR2(100) NOT NULL,
    lastname		VARCHAR2(100) NOT NULL,
    address_street		VARCHAR2(255),
    address_city		VARCHAR2(100),
    address_County		VARCHAR2(50),
    address_state		CHAR(2),
    address_zip		CHAR(5),
    Comorbid_Curr		INT NOT NULL,
    Covid_Vax_Curr		INT NOT NULL,
    Flu_Vax_Curr		INT NOT NULL,
    PC_Visit_Curr		INT NOT NULL,
    High_Dollar		CHAR(1) NOT NULL,
    High_Risk_Codes		INT NOT NULL,
    PRIMARY KEY (IDNO));


/*Step 2: Create sequence for primary key*/
create sequence seq_hr_mem_outreach start with 1 increment by 1;

/*Step 3: Create Procedure
The following procedure creates a HIGH RISK MEMBER OUTREACH (HR_MEM_OUTREACH) table which can be utilized to input values from Triggers for members that have high dollar claims and high risk conditions*/
CREATE OR REPLACE PROCEDURE populate_member_outreach AS
    BEGIN
        DELETE FROM HR_Mem_Outreach;
        INSERT INTO HR_Mem_Outreach(IDNO, MemberID, Gender, DateOfBirth, Age, Firstname, Lastname, address_street, address_city, address_county, address_state, address_zip, Comorbid_Curr, Covid_Vax_Curr, Flu_Vax_Curr, PC_Visit_Curr, High_Dollar, High_Risk_Codes)
            SELECT
                seq_hr_mem_outreach.NEXTVAL,
                HR.MemberID,
                HR.Gender,
                HR.DateOfBirth,
                Calc_Age(HR.DateOfBirth),
                HR.Firstname,
                HR.Lastname,
                M.address_street,
                M.address_city,
                M.address_county,
                M.address_state,
                M.address_zip,
                CALC_Comorbid_Current(HR.memberID),
                get_VaxCovid_Current(HR.memberID),
                get_VaxFlu_Current(HR.memberID),
                get_PC_Current(HR.memberID),
                'N' as High_Dollar,
                0 as High_Risk_Codes
            FROM v_HIST_HIGH_RISK_PATIENTS HR
                JOIN DIM_MEMBER M
                ON (HR.MemberID = M.MemberID);
        COMMIT;
    End populate_member_outreach;

/*Execute the procedure*/
execute populate_member_outreach;

/*View the results*/
select * from HR_Mem_Outreach;

	 
--------------
/* Jacob Stank
/*** This section of code is intended to create a Member Summary table which will store data at the Member - Month level for quick summarization of information ***/
/*** Step 01: Create DDL for Member Summary Table ***/
DROP TABLE SUM_MEMBER_CT;
CREATE TABLE SUM_MEMBER_CT
(IDNO	INT NOT NULL
,MemberID	INT NOT NULL
,PRODUCT	CHAR(3) NOT NULL
,CLIENT_ID	CHAR(6) NOT NULL
,Gender	CHAR(1) NOT NULL
,AgeRange	VARCHAR2(20) NOT NULL
,MemberRegion	VARCHAR2(20) NOT NULL
,DIABETES	INT NOT NULL
,CAD	INT NOT NULL
,CHF	INT NOT NULL
,HYPERTENSION	INT NOT NULL
,COPD	INT NOT NULL
,IncMonth	DATE NOT NULL
,Member_Count	NUMBER(10,0) NOT NULL
,CoMorbity_Count	NUMBER(10,0) NOT NULL
,PRIMARY KEY (IDNO) 
);

/*** Step 02: Create sequence number for primary key ***/
create sequence seq_mbrsum start with 1 increment by 1;

/*** Step 03: Define the Procedure to populate member summary. This table will be a complete replace each time run. Future changes would be to look to make it incremental load.***/
CREATE OR REPLACE PROCEDURE populate_member_summary AS
BEGIN
DELETE FROM SUM_Member_Ct;
   INSERT INTO SUM_Member_Ct (IDNO, MemberID, PRODUCT, CLIENT_ID, Gender, AgeRange, MemberRegion, DIABETES, CAD ,CHF, HYPERTENSION , COPD, IncMonth , Member_Count , CoMorbity_Count)
SELECT
 seq_mbrsum.NEXTVAL
,A1.MemberID
,A1.PRODUCT
,A1.CLIENT_ID
,A1.Gender
,CASE WHEN ROUND((sysdate - A1.DateofBirth)/365.25) BETWEEN 0 AND 17  THEN 'Cat01_00_17'		
	  WHEN ROUND((sysdate - A1.DateofBirth)/365.25) BETWEEN 18 AND 30 THEN 'Cat02_18_30'	
	  WHEN ROUND((sysdate - A1.DateofBirth)/365.25) BETWEEN 31 AND 40 THEN 'Cat03_31_40'	
	  WHEN ROUND((sysdate - A1.DateofBirth)/365.25) BETWEEN 41 AND 50 THEN 'Cat04_41_50'	
	  WHEN ROUND((sysdate - A1.DateofBirth)/365.25) BETWEEN 51 AND 57 THEN 'Cat05_51_57'	
	  WHEN ROUND((sysdate - A1.DateofBirth)/365.25) BETWEEN 58 AND 64 THEN 'Cat06_56_64'	
      ELSE 'Cat07_65+'		
END as AgeRange		
,CASE WHEN A1.address_County NOT IN ('Allegheny') Then A1.address_County				
      when substr(A1.address_city,1,1) = 'P' THEN 'Allegheny - South'				
      when substr(A1.address_city,1,1) IN ('M','B','W','S') Then 'Allegheny - North'
      else 'Allegheny - Other'				
END AS MemberRegion
,CASE WHEN B1.DIABETES IS NULL THEN 0 ELSE B1.DIABETES END AS DIABETES
,CASE WHEN B1.CAD IS NULL THEN 0 ELSE B1.CAD END AS CAD
,CASE WHEN B1.CHF IS NULL THEN 0 ELSE B1.CHF END AS CHF
,CASE WHEN B1.HYPERTENSION IS NULL THEN 0 ELSE B1.HYPERTENSION END AS HYPERTENSION
,CASE WHEN B1.COPD IS NULL THEN 0 ELSE B1.COPD END AS COPD
,A1.IncMonth
,1 AS Member_Count
,CASE WHEN B1.CoMorbity_Count IS NULL THEN 0 ELSE B1.CoMorbity_Count END AS CoMorbity_Count
FROM (SELECT A.*
       ,B.IncMonth
FROM DIM_MEMBER A
INNER JOIN DIM_DATE  B
	ON (B.IncMonth BETWEEN A.StartDate and A.EndDate)
) A1
LEFT JOIN 
(SELECT C.*
       ,(C.DIABETES + C.CAD + C.CHF + C.HYPERTENSION + C.COPD) AS CoMorbity_Count 
       ,D.IncMonth
FROM DIM_MEMBER_CONDITION C
INNER JOIN DIM_DATE D
	ON (D.IncMonth BETWEEN C.StartDate and C.EndDate)
) B1
ON (A1.MemberID = B1.MemberID
AND A1.IncMonth = B1.IncMonth)
;
COMMIT;
End populate_member_summary;
/

/*** Step 04 - Execute inserting data into the member summary ***/
execute populate_member_summary;

/* Jacob Stank
/*** This next section of code will build a claims summary table to allow for quick summarization of claims detail for adhoc queries. It is designed currently to be a full table
     replace and future iterations would look to make it an incremental load. ***/

/*** Step 01: Create DDL for Claims Summary ***/
DROP TABLE SUM_CLAIMS_CT;
CREATE TABLE SUM_CLAIMS_CT
(IDNO	INT NOT NULL
,MemberID	INT NOT NULL
,PRODUCT	CHAR(3) NOT NULL
,CLIENT_ID	CHAR(6) NOT NULL
,Gender	CHAR(1) NOT NULL
,AgeRange	VARCHAR2(20) NOT NULL
,MemberRegion	VARCHAR2(20) NOT NULL
,DIABETES	INT NOT NULL
,CAD	INT NOT NULL
,CHF	INT NOT NULL 
,HYPERTENSION	INT NOT NULL
,COPD	INT NOT NULL
,ProviderID	INT NOT NULL
,ProviderRegion	VARCHAR2(20) NOT NULL
,SpecRup_DESC	VARCHAR2(100) NOT NULL
,RPT_CD	VARCHAR2(10) NOT NULL
,LVL_01	VARCHAR2(10) NOT NULL
,LVL_02	VARCHAR2(100) NOT NULL
,LVL_03	VARCHAR2(100) NOT NULL
,pos_Desc	VARCHAR2(100) NOT NULL
,IncMonth	DATE NOT NULL
,CoMorbity_Count	NUMBER(10,0) NOT NULL
,Cases	NUMBER(12,0) NOT NULL
,Services	NUMBER(12,0) NOT NULL
,ClaimCount	NUMBER(12,0) NOT NULL
,AllowedCharges	NUMBER(14,2) NOT NULL
,PaidClaims	NUMBER(14,2) NOT NULL
,MemberPaid	NUMBER(14,2) NOT NULL
,OPL	NUMBER(14,2) NOT NULL
,PRIMARY KEY (IDNO)
);

/*** Step 02: Create sequence number for primary key ***/
create sequence seq_clmsum start with 1 increment by 1;

/*** Step 03: Define the Procedure to populate Claims summary ***/
CREATE OR REPLACE PROCEDURE populate_claims_summary AS
        BEGIN
        DELETE FROM SUM_CLAIMS_CT;
        INSERT INTO SUM_CLAIMS_CT (IDNO,MemberID,PRODUCT,CLIENT_ID,Gender,AgeRange,MemberRegion,DIABETES,CAD,CHF,HYPERTENSION,COPD,ProviderID,ProviderRegion,SpecRup_DESC,RPT_CD,LVL_01,LVL_02,LVL_03,pos_Desc,IncMonth,CoMorbity_Count,Cases,Services,ClaimCount,AllowedCharges,PaidClaims,MemberPaid,OPL)
        SELECT
         seq_clmsum.NEXTVAL
        ,S01.MemberID
        ,COALESCE(S02.PRODUCT,'NA') AS PRODUCT
        ,COALESCE(S02.CLIENT_ID,'NA') AS CLIENT_ID
        ,COALESCE(S02.Gender,'X') AS Gender
        ,COALESCE(S02.AgeRange,'NA') AS AgeRange
        ,COALESCE(S02.MemberRegion,'NA') AS MemberRegion
        ,COALESCE(S02.DIABETES,0) AS DIABETES 
        ,COALESCE(S02.CAD,0) AS CAD
        ,COALESCE(S02.CHF,0) AS CHF
        ,COALESCE(S02.HYPERTENSION,0) AS HYPERTENSION
        ,COALESCE(S02.COPD,0) AS COPD
        ,S01.ProviderID
        ,S01.ProviderRegion
        ,S01.SpecRup_DESC
        ,S01.RPT_CD
        ,S01.LVL_01
        ,S01.LVL_02
        ,S01.LVL_03
        ,S01.POS_DESC
        ,S01.IncMonth
        ,COALESCE(S02.CoMorbity_Count,0) AS CoMorbity_Count
        ,S01.Cases
        ,S01.Services
        ,S01.ClaimCount
        ,S01.AllowedCharges
        ,S01.PaidClaims
        ,S01.MemberPaid
        ,S01.OPL
        FROM (
        SELECT
         d01.MemberID
        ,d01.ProviderID
        ,d01.ProviderRegion		
        ,d01.SpecRup_DESC
        ,d01.RPT_CD
        ,d01.LVL_01
        ,d01.LVL_02
        ,d01.LVL_03
        ,d01.POS_DESC
        ,d01.IncMonth
        ,SUM(d01.Cases) AS Cases
        ,SUM(d01.Services) AS Services
        ,COUNT(DISTINCT d01.ClaimID) AS ClaimCount
        ,SUM(d01.AllowedCharges) AS AllowedCharges
        ,SUM(d01.PaidClaims) as PaidClaims
        ,SUM(d01.MemberPaid) as MemberPaid
        ,SUM(d01.OPL) as OPL
        FROM (
        SELECT 
         A.*
        ,CASE WHEN D.address_County NOT IN ('Allegheny') Then D.address_County				
              when substr(D.address_city,1,1) = 'P' THEN 'Allegheny - South'				
              when substr(D.address_city,1,1) IN ('M','B','W','S') Then 'Allegheny - North'
              else 'Allegheny - Other'
        END AS ProviderRegion		
        ,E.SpecRup_DESC
        ,CASE WHEN A.ClaimType IN ('I','O') THEN COALESCE(F1.RPT_CD,'OTH')
             ELSE COALESCE(F2.RPT_CD,'OTH')
        END AS RPT_CD
        ,CASE WHEN A.ClaimType IN ('I','O') THEN COALESCE(F1.LVL_01,'OTH')
             ELSE COALESCE(F2.LVL_01,'OTH')
        END AS LVL_01
        ,CASE WHEN A.ClaimType IN ('I','O') THEN COALESCE(F1.LVL_02,'OTH')
             ELSE COALESCE(F2.LVL_02,'OTH')
        END AS LVL_02
        ,CASE WHEN A.ClaimType IN ('I','O') THEN COALESCE(F1.LVL_03,'OTH')
             ELSE COALESCE(F2.LVL_03,'OTH')
        END AS LVL_03
        ,B.POS_DESC
        ,I.IncMonth
        FROM CLAIM_FACT A
        INNER JOIN DIM_DATE I
            ON (A.ServiceDate BETWEEN I.StartDate AND I.EndDate)
        LEFT JOIN DIM_PLACE_OF_SERVICE B
            ON (A.posID = B.posID)
        LEFT JOIN DIM_PROCEDURE C
            ON (A.Code_Type = C.Code_Type
            AND A.Code_Value = C.Code_Value )
        LEFT JOIN DIM_PROVIDER D
            ON (A.ProviderID = D.ProviderID)
        LEFT JOIN DIM_PROVIDER_SPECIALTY E
            ON (D.SpecialtyID = E.SpecialtyID)
        LEFT JOIN DIM_REPORTING_CATEGORY F1
            ON (C.FACILITY_CD = F1.RPT_CD)
        LEFT JOIN DIM_REPORTING_CATEGORY F2
            ON (C.PROF_CD = F2.RPT_CD)
        ) d01
        GROUP BY 
         d01.MemberID
        ,d01.ProviderID
        ,d01.ProviderRegion		
        ,d01.SpecRup_DESC
        ,d01.RPT_CD
        ,d01.LVL_01
        ,d01.LVL_02
        ,d01.LVL_03
        ,d01.POS_DESC
        ,d01.IncMonth
        ) S01
        LEFT JOIN SUM_Member_Ct S02
            ON (S01.MemberID = S02.MemberID
            AND S01.IncMonth = S02.IncMonth);
        COMMIT;
END populate_claims_summary;


/*** Step 04: Execute inserting data into the member summary ***/
execute populate_claims_summary;


/* Jacob Stank
/*** The goal of this next piece is to build a check to see if Claim is over 25K in Allowed Charges. This will allow for investigation and tracking of these 
     claims by the clinical teams as well as enable forecast analysis to back out of claim outliers to smooth the curve for projections. ***/
CREATE OR REPLACE FUNCTION Calc_HD_Claim (p_claimID IN INT)
RETURN INT IS
v_HighDollarClaim INT;
BEGIN 
SELECT D.ClaimID INTO v_HighDollarClaim
FROM 
(SELECT ClaimID, SUM(AllowedCharges) AS AMT
FROM CLAIM_FACT 
WHERE ClaimID = p_ClaimID
GROUP BY ClaimID
) D
WHERE D.AMT>2500.00;
RETURN(v_HighDollarClaim);
END Calc_HD_Claim;
/

--------------
/***
This next section of code is developed to populate two reporting tables that will allow for a BI tool to leverage to create Trend Reports that capture Utilization per 1k,
Cost per Utilization, and PMPM at the level of detail needed for the specified report. 
Summary Report 01 (SUMMARY_RPT_01) will compile the data Needed to produce a Trend Report analyzing differences at the Cobmorbity Levels
Summary Report 02 (SUMMARY_RPT_02) will compile the data needed to produce a Trend Report at RPT Category 01 & 02 Levels to determine the categories to drill into detail
for further analysis.
***/
 
/*** Step 01: Create the DDL for the Report Tables. ***/
DROP TABLE SUMMARY_RPT_01;
CREATE TABLE SUMMARY_RPT_01
(IDNO INT NOT NULL
,CoMorbity_Count	NUMBER(10,0) NOT NULL
,IncMonth DATE NOT NULL
,Cases	NUMBER(12,0) NOT NULL
,Services	NUMBER(12,0) NOT NULL
,ClaimCount	NUMBER(12,0) NOT NULL
,AllowedCharges	NUMBER(14,2) NOT NULL
,PaidClaims	NUMBER(14,2) NOT NULL
,MemberPaid	NUMBER(14,2) NOT NULL
,OPL	NUMBER(14,2) NOT NULL
,Member_Count	NUMBER(10,0) NOT NULL
,PRIMARY KEY (IDNO)
);
DROP TABLE SUMMARY_RPT_02;
CREATE TABLE SUMMARY_RPT_02
(IDNO INT NOT NULL
,LVL_01	VARCHAR2(10) NOT NULL
,LVL_02	VARCHAR2(100) NOT NULL
,IncMonth DATE NOT NULL
,Cases	NUMBER(12,0) NOT NULL
,Services	NUMBER(12,0) NOT NULL
,ClaimCount	NUMBER(12,0) NOT NULL
,AllowedCharges	NUMBER(14,2) NOT NULL
,PaidClaims	NUMBER(14,2) NOT NULL
,MemberPaid	NUMBER(14,2) NOT NULL
,OPL	NUMBER(14,2) NOT NULL
,Member_Count	NUMBER(10,0) NOT NULL
,PRIMARY KEY (IDNO)
);

/***Step 02: Create sequence number for primary key purposes ***/
create sequence seq_rpt01 start with 1 increment by 1;
create sequence seq_rpt02 start with 1 increment by 1;

/***Step 03: Define the Trigger which will populate these Report Tables after SUM_CLAIM_FACT is created ***/
CREATE OR REPLACE TRIGGER report_insert 
AFTER INSERT ON SUM_CLAIMS_CT
BEGIN
DELETE FROM SUMMARY_RPT_01;
INSERT INTO SUMMARY_RPT_01 (IDNO,CoMorbity_Count,IncMonth,Cases,Services,ClaimCount,AllowedCharges,PaidClaims,MemberPaid,OPL,Member_Count)
SELECT seq_rpt01.NEXTVAL AS IDNO
      ,D2.*
FROM (
SELECT 
 D1.CoMorbity_Count
,D1.IncMonth
,SUM(D1.Cases) AS Cases
,SUM(D1.Services) AS Services
,SUM(D1.ClaimCount) AS  ClaimCount
,Sum(D1.AllowedCharges) AS AllowedCharges	
,Sum(D1.PaidClaims) AS PaidClaims
,SUM(D1.MemberPaid) AS MemberPaid	
,SUM(D1.OPL) AS OPL
,SUM(D1.Member_Count) AS Member_Count
FROM (
SELECT
 A.CoMorbity_Count
,B.IncMonth
,SUM(A.Cases) AS Cases
,SUM(A.Services) AS Services
,SUM(A.ClaimCount) AS  ClaimCount
,Sum(A.AllowedCharges) AS AllowedCharges	
,Sum(A.PaidClaims) AS PaidClaims
,SUM(A.MemberPaid) AS MemberPaid	
,SUM(A.OPL) AS OPL
,SUM(0) AS Member_Count
FROM SUM_CLAIMS_CT A
INNER JOIN DIM_DATE B
	ON(A.IncMonth = B.IncMonth
	AND B.tValue0 BETWEEN 2 AND 37)
GROUP BY A.CoMorbity_Count, B.IncMonth
UNION
SELECT
 A1.CoMorbity_Count
,B1.IncMonth
,SUM(0) AS Cases
,SUM(0) AS Services
,SUM(0) AS ClaimCount
,SUM(0) AS AllowedCharges	
,SUM(0) AS PaidClaims
,SUM(0) AS MemberPaid	
,SUM(0) AS OPL
,SUM(A1.Member_Count) AS Member_Count
FROM SUM_MEMBER_CT A1
INNER JOIN DIM_DATE B1
	ON(A1.IncMonth = B1.IncMonth
	AND B1.tValue0 BETWEEN 2 AND 37)
GROUP BY A1.CoMorbity_Count, B1.IncMonth
) D1
GROUP BY D1.CoMorbity_Count, D1.IncMonth
) D2;
DELETE FROM SUMMARY_RPT_02;
INSERT INTO SUMMARY_RPT_02 (IDNO, LVL_01,LVL_02,IncMonth,Cases,Services,ClaimCount,AllowedCharges,PaidClaims,MemberPaid,OPL,Member_Count)
SELECT  seq_rpt02.NEXTVAL AS IDNO
       ,D2.*
FROM (
SELECT 
 D1.LVL_01
,D1.LVL_02
,D1.IncMonth
,SUM(D1.Cases) AS Cases
,SUM(D1.Services) AS Services
,SUM(D1.ClaimCount) AS  ClaimCount
,Sum(D1.AllowedCharges) AS AllowedCharges	
,Sum(D1.PaidClaims) AS PaidClaims
,SUM(D1.MemberPaid) AS MemberPaid	
,SUM(D1.OPL) AS OPL
,SUM(D1.Member_Count) AS Member_Count
FROM (
SELECT
 A.LVL_01
,A.LVL_02
,B.IncMonth
,SUM(A.Cases) AS Cases
,SUM(A.Services) AS Services
,SUM(A.ClaimCount) AS  ClaimCount
,Sum(A.AllowedCharges) AS AllowedCharges	
,Sum(A.PaidClaims) AS PaidClaims
,SUM(A.MemberPaid) AS MemberPaid	
,SUM(A.OPL) AS OPL
,SUM(0) AS Member_Count
FROM SUM_CLAIMS_CT A
INNER JOIN DIM_DATE B
	ON(A.IncMonth = B.IncMonth
	AND B.tValue0 BETWEEN 2 AND 37)
GROUP BY A.LVL_01,A.LVL_02, B.IncMonth
UNION
SELECT
 'ENR' AS LVL_01
,'ENR' AS LVL_02
,B1.IncMonth
,SUM(0) AS Cases
,SUM(0) AS Services
,SUM(0) AS ClaimCount
,SUM(0) AS AllowedCharges	
,SUM(0) AS PaidClaims
,SUM(0) AS MemberPaid	
,SUM(0) AS OPL
,SUM(A1.Member_Count) AS Member_Count
FROM SUM_MEMBER_CT A1
INNER JOIN DIM_DATE B1
	ON(A1.IncMonth = B1.IncMonth
	AND B1.tValue0 BETWEEN 2 AND 37)
GROUP BY B1.IncMonth
) D1
GROUP BY D1.LVL_01, D1.LVL_02, D1.IncMonth
) D2;
END;
/    
	
/* Jacob Williamson
Triggers when a claim contains an allowed charge > $25,000

Updates the High Risk Member Outreach table and flags the member
as having a high-dollar claim
*/
CREATE OR REPLACE TRIGGER Claim_Fact_HighDollar
    AFTER 
        INSERT OR
        UPDATE OF allowedcharges
    ON Claim_Fact
FOR EACH ROW
BEGIN
    IF :NEW.allowedcharges > 25000 THEN
        UPDATE HR_MEM_Outreach
        SET High_Dollar = 'Y'
        WHERE MemberID = :NEW.MEMBERID;
    END IF;
END;
/

/* Jacob Williamson
Triggers when a claim for a high-risk procedure is entered

Update the High Risk Member Outreach table and adds to the member's count
of high-risk procedures

Future: Create table for high-risk codes to prevent updating the list in multiple places in the trigger
*/
CREATE OR REPLACE TRIGGER Claim_Fact_HighRiskProcedure
    AFTER 
        INSERT OR
        UPDATE OF code_value
    ON Claim_Fact
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        IF :NEW.code_value IN ('023','236','246','247','266','270') THEN
            UPDATE HR_MEM_Outreach
            SET High_Risk_Codes = High_Risk_Codes + 1
            WHERE MemberID = :NEW.MEMBERID;
        END IF;
    ELSE -- Updating
        IF :NEW.code_value IN ('023','236','246','247','266','270') AND :OLD.code_value NOT IN ('023','236','246','247','266','270') THEN
            UPDATE HR_MEM_Outreach
            SET High_Risk_Codes = High_Risk_Codes + 1
            WHERE MemberID = :NEW.MEMBERID;
        ELSIF :NEW.code_value NOT IN ('023','236','246','247','266','270') AND :OLD.code_value IN ('023','236','246','247','266','270') THEN
            UPDATE HR_MEM_Outreach
            SET High_Risk_Codes = High_Risk_Codes - 1
            WHERE MemberID = :NEW.MEMBERID;
        END IF;
    END IF;
END;
/

/* Jacob Williamson

Returns 1 if the member currently has diabetes, 0 otherwise
*/
CREATE OR REPLACE FUNCTION HASDIABETES (
    mem_id IN number
)
RETURN number IS 
    has_diabetes number;
BEGIN
    SELECT Diabetes
    INTO has_diabetes
    FROM DIM_MEMBER_CONDITION
    WHERE MemberID = mem_id
    ORDER BY enddate DESC
    FETCH FIRST 1 ROW ONLY; -- Only works on 12c and later

    RETURN has_diabetes;
END HASDIABETES;
/

/* Jacob Williamson

Creates a table containing information for rebate mailers.
To be consumed by external service.
Null values on MAILED_ON indicates that the rebate has not been mailed out.
*/
DROP TABLE REBATE_MAILER;

CREATE TABLE REBATE_MAILER
(
    IDNO INT NOT NULL,
    MEMBERID INT NOT NULL,
    FIRSTNAME VARCHAR2(100) NOT NULL,
    LASTNAME VARCHAR2(100) NOT NULL,
    ADDRESS_STREET VARCHAR2(255) NOT NULL,
    ADDRESS_CITY VARCHAR2(100) NOT NULL,
    ADDRESS_STATE VARCHAR2(2) NOT NULL,
    ADDRESS_ZIP VARCHAR2(5) NOT NULL,
    REASON VARCHAR2(255) NOT NULL,
    MAILED_ON DATE,
    PRIMARY KEY (IDNO)
);

/* Jacob Williamson

Creates sequence for Rebate Mailer table
*/
CREATE SEQUENCE seq_rebatemailer
    MINVALUE 1
    START WITH 1
    INCREMENT BY 1;

/* Jacob Williamson

Populates Rebate Mailer table based on if members meet the following condition:
Member has diabetes AND received a COVID vaccine
*/
CREATE OR REPLACE PROCEDURE populate_rebate_mailer AS
BEGIN
   INSERT INTO rebate_mailer (IDNO, MEMBERID, FIRSTNAME, LASTNAME, ADDRESS_STREET, ADDRESS_CITY, ADDRESS_STATE, ADDRESS_ZIP, REASON) 
    SELECT seq_rebatemailer.NEXTVAL, MEMBERID, FIRSTNAME, LASTNAME, ADDRESS_STREET, ADDRESS_CITY, ADDRESS_STATE, ADDRESS_ZIP, 'Diabetes and Covid Vaccine' 
    FROM DIM_MEMBER 
    WHERE HASDIABETES(MEMBERID) = 1 
        AND get_VaxCovid(MEMBERID) > 0 
        AND MEMBERID NOT IN (
            SELECT MEMBERID
            FROM REBATE_MAILER
            WHERE REASON LIKE 'Diabetes and Covid Vaccine%'
        ); 
    COMMIT;
END populate_rebate_mailer;

execute populate_rebate_mailer;


/* Zach Carlson 

Function to return the name of the provider, taking into account whether the provider is a organization
or a doctor with a first and last name.
*/
CREATE OR REPLACE FUNCTION GET_PROVIDER_NAME (provider_id IN number)
RETURN varchar2 IS 

    v_provider_type dim_provider.providertype%type;
    v_provider_name varchar2(100);
BEGIN
    /*Get provider type, specifies whether doctor or organization*/
    SELECT PROVIDERTYPE 
    INTO v_provider_type 
    FROM DIM_PROVIDER 
    WHERE PROVIDERID = provider_id;
    /*if doctor*/
    IF v_provider_type = 1 THEN
        SELECT ORGNAME INTO v_provider_name FROM DIM_PROVIDER WHERE PROVIDERID = provider_id;
    END IF;
    IF v_provider_type = 2 THEN
        SELECT FIRSTNAME || ' ' || LASTNAME AS FULL_NAME INTO v_provider_name FROM DIM_PROVIDER WHERE PROVIDERID = provider_id;
    END IF;
    RETURN (v_provider_name);
END GET_PROVIDER_NAME;
/
/* Zach Carlson 

Function to return the speciality of the provider given the provider ID
*/
CREATE OR REPLACE FUNCTION GET_PROVIDER_SPECIALTY (provider_id IN number)
RETURN varchar2 IS 
    v_provider_specialtyid number;
    v_provider_specialty varchar2(100);
BEGIN
    /*Get provider type, specifies whether doctor or organization*/
    SELECT SPECIALTYID
    INTO v_provider_specialtyid 
    FROM DIM_PROVIDER 
    WHERE PROVIDERID = provider_id;
    /*Get specialty name*/
    SELECT SPECIALTY_DESC 
    INTO v_provider_specialty
    FROM DIM_PROVIDER_SPECIALTY
    WHERE SPECIALTYID = v_provider_specialtyid;
    RETURN (v_provider_specialty);
END GET_PROVIDER_SPECIALTY;
/
/* Zach Carlson

Procedure to populate a table of provider names and total number of claims.*/

--Step 1: Create table to populate
DROP TABLE PROVIDER_CLAIM_REPORT;
CREATE TABLE PROVIDER_CLAIM_REPORT
(
    PROVIDERID INT NOT NULL,
    PROVIDERNAME VARCHAR2(100),
    PROVIDERSPECIALTY VARCHAR2(100),
    NUM_CLAIMS NUMBER(14,2),
    SUM_ALLOWEDCHARGES NUMBER(14,2)
);

--Step 2: Create procedure
CREATE OR REPLACE PROCEDURE populate_provider_claim_report AS
BEGIN
   INSERT INTO provider_claim_report (PROVIDERID, PROVIDERNAME, PROVIDERSPECIALTY, NUM_CLAIMS, SUM_ALLOWEDCHARGES) 
    SELECT PROVIDERID, GET_PROVIDER_NAME(PROVIDERID) AS PROVIDER_NAME, GET_PROVIDER_SPECIALTY(PROVIDERID) AS PROVIDER_SPECIALTY, COUNT(DISTINCT CLAIMID) AS NUM_CLAIMS, SUM(ALLOWEDCHARGES) AS SUM_ALLOWEDCHARGES
    FROM CLAIM_FACT
    GROUP BY PROVIDERID; 
    COMMIT;
END populate_provider_claim_report;

execute populate_provider_claim_report;


/*Zach Carlson


Trigger to update PROVIDER_CLAIM_REPORT whenever a claim is inserted, updated, or deleted*/
CREATE OR REPLACE TRIGGER provider_claim_report_AIUDS
    AFTER INSERT OR DELETE OR UPDATE ON claim_fact
    DECLARE
        CURSOR c_stat IS
            SELECT PROVIDERID, GET_PROVIDER_NAME(PROVIDERID) AS PROVIDER_NAME, GET_PROVIDER_SPECIALTY(PROVIDERID), COUNT(DISTINCT CLAIMID) AS NUM_CLAIMS, SUM(ALLOWEDCHARGES) AS SUM_ALLOWEDCHARGES
            FROM CLAIM_FACT
            GROUP BY PROVIDERID;
    BEGIN
        FOR v_stat in c_stat LOOP
            UPDATE provider_claim_report SET NUM_CLAIMS = v_stat.NUM_CLAIMS
                WHERE PROVIDERID = v_stat.PROVIDERID;
            UPDATE provider_claim_report SET SUM_ALLOWEDCHARGES = v_stat.SUM_ALLOWEDCHARGES
                WHERE PROVIDERID = v_stat.PROVIDERID;
        END LOOP;
    END provider_claim_report_AIUDS;

