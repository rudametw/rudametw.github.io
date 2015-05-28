DROP TABLE effectue;
DROP TABLE suit;
DROP TABLE Contact;
DROP TABLE Stage;
DROP TABLE Formation;
DROP TABLE Departement;
DROP TABLE Entreprise;
DROP TABLE Pays;
DROP TABLE Etudiant;


CREATE TABLE Etudiant (
  numEt INTEGER  ,
  nomEt TEXT  ,
  prenomEt TEXT  ,
  civilite TEXT  ,
  PRIMARY KEY (numEt)
) ;
CREATE TABLE Pays (
  numPa INTEGER,
  nomPa TEXT  ,
  PRIMARY KEY (numPa)
) ;
CREATE TABLE Entreprise (
  numEn INTEGER  ,
  nomEn TEXT  ,
  PRIMARY KEY (numEn)
) ;
CREATE TABLE Departement (
  nomCourt TEXT  ,
  nomLong TEXT  ,
  PRIMARY KEY (nomCourt)
) ;
CREATE TABLE Formation (
  numFo INTEGER  ,
  dept TEXT REFERENCES Departement,
  PRIMARY KEY (numFo, dept)
) ;

CREATE TABLE Stage (
  numSt INTEGER  ,
  sujet TEXT  ,
  job BOOLEAN  ,
  remuneration FLOAT  ,
  convention DATE  ,
  fax DATE  ,
  ville TEXT  ,
  pays INTEGER REFERENCES Pays,
  entreprise INTEGER REFERENCES Entreprise,
  etudiant INTEGER REFERENCES Etudiant,
  formation INTEGER ,
  dept TEXT ,
  dateDeb DATE ,
  dateFin DATE ,
  FOREIGN KEY (formation, dept) REFERENCES Formation (numFo, dept),
  PRIMARY KEY (numSt)
) ;

CREATE TABLE Contact (
  numCo INTEGER  ,
  civilite TEXT  ,
  fonction TEXT  ,
  entreprise INTEGER REFERENCES Entreprise,
  stage INTEGER REFERENCES Stage,
  PRIMARY KEY (numCo)
) ;
CREATE TABLE suit (
  formation INTEGER ,
  dept TEXT ,
  etudiant INTEGER REFERENCES Etudiant,
  anneeDeb INTEGER ,
  anneeFin INTEGER ,
  PRIMARY KEY(formation, dept, etudiant),
  FOREIGN KEY (formation, dept) REFERENCES Formation (numFo, dept)
) ;

CREATE TABLE effectue (
  stage INTEGER REFERENCES Stage,
  etudiant INTEGER REFERENCES Etudiant,
  PRIMARY KEY(stage, etudiant)
) ;
