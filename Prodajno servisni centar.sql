DROP DATABASE IF EXISTS Prodajno_servisni_centar;
CREATE DATABASE Prodajno_servisni_centar;
USE Prodajno_servisni_centar;

CREATE TABLE prodavac(
	id INTEGER PRIMARY KEY AUTO_INCREMENT, 
    ime VARCHAR (20) NOT NULL,
    prezime VARCHAR (20) NOT NULL,
    datum_rodenja DATETIME NOT NULL,
    adresa VARCHAR (200) NOT NULL,
    spol VARCHAR (20) NOT NULL,
    broj_telefona VARCHAR (20) NOT NULL,
    oib VARCHAR (20) NOT NULL,
    datum_zaposlenja DATETIME NOT NULL


);

CREATE TABLE racun_prodaje(
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
    broj_racuna VARCHAR (20) NOT NULL,
    datum DATE NOT NULL,
    cijena NUMERIC NOT NULL,
FOREIGN KEY (id_auto) REFERENCES auto (id),
FOREIGN KEY (id_kupac) REFERENCES kupac (id),
FOREIGN KEY (id_prodavac) REFERENCES prodavac (id)

);

CREATE TABLE auto(
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
    serijski_broj VARCHAR (20) NOT NULL,
    marka_automobila VARCHAR (20) NOT NULL,
    model VARCHAR (20) NOT NULL,
    boja VARCHAR (20) NOT NULL,
    godina_proizvodnje VARCHAR (20) NOT NULL,
    dostupnost VARCHAR (20) NOT NULL,
    snaga_motora VARCHAR (20) NOT NULL,
    tip_goriva VARCHAR (20) NOT NULL
);

CREATE TABLE klijent(
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
    ime VARCHAR (20) NOT NULL,
    prezime VARCHAR (20) NOT NULL,
    broj_telefona VARCHAR (20) NOT NULL,
    adresa VARCHAR (20) NOT NULL,
    grad VARCHAR (20) NOT NULL,
    spol VARCHAR (20) NOT NULL


);


CREATE TABLE narudzbenica(
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
    broj_narudzbe VARCHAR (20) NOT NULL,
    datum_zaprimanja DATETIME NOT NULL,
    komentar VARCHAR (20) NOT NULL,
    datum_povratka VARCHAR (20) NOT NULL,
    FOREIGN KEY (id_auto) REFERENCES auto (id),
    FOREIGN KEY (id_klijent) REFERENCES klijent (id)
);


CREATE TABLE mehanicar(
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
    ime  VARCHAR (20) NOT NULL,
    prezime  VARCHAR (20) NOT NULL,
    datum_rodenja  DATE NOT NULL,
    adresa  VARCHAR (20) NOT NULL,
    spol  VARCHAR (20) NOT NULL,
    broj_telefona  VARCHAR (20) NOT NULL,
    oib  VARCHAR (20) NOT NULL, 
    datum_zaposlenja DATETIME NOT NULL
	

);

CREATE TABLE otpremnica(
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
    utroseni_sati  VARCHAR (20) NOT NULL,
    komentar  VARCHAR (20) NOT NULL,
    cijena  DECIMAL(7,2)  NOT NULL,
    FOREIGN KEY (id_servis) REFERENCES servis (id),
    FOREIGN KEY (id_mehanicar) REFERENCES mehanicar (id),
    FOREIGN KEY (id_narudzbenica) REFERENCES narudzbenica (id)
    
    
    );

CREATE TABLE koristeni_dijelovi(
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
    kolicina VARCHAR (20) NOT NULL,
    cijena DECIMAL(7,2) NOT NULL,
    FOREIGN KEY (id_dijelovi) REFERENCES dijelovi (id),
    FOREIGN KEY (id_onarudzbenica) REFERENCES narudzbenica (id)
    

);

CREATE TABLE servis(
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
    satnica INTEGER NOT NULL,
    ime_servisa VARCHAR (20) NOT NULL


);

CREATE TABLE dijelovi (
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
    serijski_broj VARCHAR (20) NOT NULL,
    opis VARCHAR (20) NOT NULL,
    nabavna_cijena DECIMAL(7,2) NOT NULL,
    prodajna_cijena DECIMAL(7,2) NOT NULL
);