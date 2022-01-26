CREATE TABLE SERVICE_TYPE (
    servTypeID 		INT NOT NULL,
    ServiceDesc 	VARCHAR(255) NOT NULL,
    PRIMARY KEY (servTypeID)
);

CREATE TABLE PROVIDER_SPECIALTY (
    specialtyID 	INT NOT NULL,
    specialtyType 	VARCHAR(15) NOT NULL,
    specialtyDesc 	VARCHAR(255) NOT NULL,
    PRIMARY KEY (specialtyID)
);

CREATE TABLE PROVIDER (
    ProviderID 		INT NOT NULL,
    FirstName 		VARCHAR(100) NOT NULL,
    LastName 		VARCHAR(100) NOT NULL,
    Gender 			CHAR(1) NOT NULL,
    dateOfBirth 	DATE NOT NULL,
    provider_street VARCHAR(255),
    provider_city 	VARCHAR(100),
    provider_county VARCHAR(50),
    provider_state	CHAR(2),
    provider_zip 	CHAR(5),
    SpecialtyID 	INT NOT NULL,
    PRIMARY KEY (ProviderID)
);

CREATE TABLE CHARGE_TYPE (
    ChargeTypeID 		INT NOT NULL,
    Code_Value 			VARCHAR(15) NOT NULL,
    Code_Description 	VARCHAR(255) NOT NULL,
    chargeAmt 			INT(10) NOT NULL,
    PRIMARY KEY (ChargeTypeID)
);

CREATE TABLE POLICY (
    PolicyID 			INT NOT NULL,
    PolicyName 			VARCHAR(50) NOT NULL,
    PolicyType 			VARCHAR(50) NOT NULL,
    Premium 			INT(10) NOT NULL,
    PRIMARY KEY (PolicyID)
);

CREATE TABLE CLAIMS (
    ClaimID 	 INT NOT NULL,
    servTypeID   INT NOT NULL,
    MemberID 	 INT NOT NULL,
    ProviderID   INT NOT NULL,
    posID 		 INT NOT NULL,
    ServiceDate  DATE NOT NULL,
    ChargeTypeID INT NOT NULL,
    PRIMARY KEY (ClaimID)
);

CREATE TABLE MEMBERS (
    memberID 		INT NOT NULL,
    firstname 		VARCHAR(100) NOT NULL,
    lastname 		VARCHAR(100) NOT NULL,
    Gender 			CHAR(1) NOT NULL,
    dateOfBirth  	DATE NOT NULL,
    member_street   VARCHAR(255),
    member_city		VARCHAR(100),
    member_County   VARCHAR(50),
    member_state 	CHAR(2),
    member_zip 		CHAR(5),
    PolicyID 		INT NOT NULL,
    StartDate 		DATE NOT NULL,
    EndDate 		DATE NOT NULL,
    PRIMARY KEY (memberID)
);

CREATE TABLE POS_TYPE (
    POSID 	INT NOT NULL,
    POSDESC VARCHAR(75) NOT NULL,
    POSTYPE CHAR(2) NOT NULL,
    PRIMARY KEY (POSID)
);