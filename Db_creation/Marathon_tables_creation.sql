use viettel_marathon_2024;

CREATE TABLE Runners_id (
  ID int NOT NUll,
  constraint pk_id primary key (ID),
  runner_name TEXT,
  Gender text,
  constraint gender_check CHECK (Gender in ('male', 'female', 'not specified')),
  Division TEXT,
  Country TEXT
);

CREATE TABLE result_5k (
  bib char(5) primary key,
  ID int,
  foreign key (ID) references Runners_id(ID),
  point039k time,
  ChipTime time,
  FinishTime time
);

CREATE TABLE result_10k (
  bib char(5) primary key,
  ID int,
  foreign key (ID) references Runners_id(ID),
  point055k time,
  point089k time,
  ChipTime time,
  FinishTime time
);

CREATE TABLE result_half_marathon (
  bib char(5) primary key,
  ID int,
  foreign key (ID) references Runners_id(ID),
  point111k time,
  point166k time,
  point200k time,
  point207k time,
  ChipTime time,
  FinishTime time
);

CREATE TABLE result_marathon (
    bib CHAR(5) PRIMARY KEY,
    ID int,
    FOREIGN KEY (ID)
        REFERENCES Runners_id (ID),
    point144k TIME,
    point258k TIME,
    point323k TIME,
    point379k TIME,
    ChipTime TIME,
    FinishTime TIME
);

CREATE TABLE Sponsors (
    SponsorID INT PRIMARY KEY auto_increment,
    SponsorName VARCHAR(100) NOT NULL UNIQUE,
    Tier text NOT NULL,
    constraint sp_tier check (Tier in ('Gold', 'Silver', 'Bronze')),
    Amount int NOT NULL
);

CREATE TABLE Sponsorship (
    RunnerSponsorID INT PRIMARY KEY AUTO_INCREMENT,
    RunnerID int NOT NULL,
    SponsorID INT NOT NULL,
    StartYear INT,
    EndYear INT,
    FOREIGN KEY (RunnerID) REFERENCES Runners_ID(ID),
    FOREIGN KEY (SponsorID) REFERENCES Sponsors(SponsorID)
);




