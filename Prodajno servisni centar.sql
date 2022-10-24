DROP DATABASE IF EXISTS Prodajno_servisni_centar;
CREATE DATABASE Prodajno_servisni_centar;
USE Prodajno_servisni_centar;


CREATE TABLE auto(
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
	broj_sasije VARCHAR (20) NOT NULL,
	marka_automobila VARCHAR (20) NOT NULL,
    	model VARCHAR (20) NOT NULL,
    	boja VARCHAR (20) NOT NULL,
    	godina_proizvodnje VARCHAR (20) NOT NULL,
    	dostupnost VARCHAR (20) NOT NULL,
    	snaga_motora VARCHAR (20) NOT NULL,
    	tip_motora VARCHAR (20) NOT NULL,
	servis/prodaja VARCHAR(10) NOT NULL
	
);


CREATE TABLE prodavac(
	id INTEGER PRIMARY KEY AUTO_INCREMENT, 
    	ime VARCHAR (20) NOT NULL,
    	prezime VARCHAR (20) NOT NULL,
    	datum_rodenja DATETIME NOT NULL,
    	adresa VARCHAR (200) NOT NULL,
    	spol VARCHAR (20) NOT NULL,
    	broj_telefona VARCHAR (20) NOT NULL,
    	OIB VARCHAR (20) NOT NULL,
    	datum_zaposlenja DATETIME NOT NULL


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

CREATE TABLE racun_prodaje(
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
    	broj_racuna VARCHAR (20) NOT NULL,
    	datum DATE NOT NULL,
	id_auto INTEGER NOT NULL,
	id_klijent INTEGER NOT NULL,
	id_prodavac INTEGER NOT NULL
    	cijena NUMERIC NOT NULL,
	FOREIGN KEY (id_auto) REFERENCES auto (id),
	FOREIGN KEY (id_klijent) REFERENCES klijent (id),
	FOREIGN KEY (id_prodavac) REFERENCES prodavac (id)

);


CREATE TABLE narudzbenica(
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
    	broj_narudzbe VARCHAR (20) NOT NULL,
	id_auto INTEGER NOT NULL,
	id_klijent INTEGER NOT NULL,
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
    	OIB  VARCHAR (20) NOT NULL, 
    	datum_zaposlenja DATETIME NOT NULL
	

);

CREATE TABLE usluge_servisa(
	id INTEGER PRIMARY KEY,
	ime_servisa VARCHAR(20) NOT NULL,
	ukupna_cijena VARCHAR(20) NOT NULL

);


CREATE TABLE servis(
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
	id_narudzbenica INTEGER NOT NULL,
	id_usluge_servisa INTEGER NOT NULL,
	id_mehanicar INTEGER NOT NULL,
    	utroseni_sati VARCHAR (20) NOT NULL,
	komentar VARCHAR (20) NOT NULL,
	FOREIGN KEY (id_usluge_servisa) REFERENCES usluge_servisa (id),
	FOREIGN KEY (id_mehanicar) REFERENCES mehanicar (id),
	FOREIGN KEY (id_narudzbenica) REFERENCES narudzbenica (id)


);

CREATE TABLE stavka_dijelovi(
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
    	serijski_broj  VARCHAR (20) NOT NULL,
    	opis  VARCHAR (20) NOT NULL,
    	nabavna_cijena  DECIMAL(7,2)  NOT NULL,
	prodajna_cijena DECIMAL(7,2)  NOT NULL
    
        );

CREATE TABLE dijelovi(
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
	id_servis INTEGER NOT NULL,
	id_stavka_dijelovi INTEGER NOT NULL,
    	kolicina VARCHAR (20) NOT NULL,
   	cijena DECIMAL(7,2) NOT NULL,
    	FOREIGN KEY (id_servis) REFERENCES servis (id),
    	FOREIGN KEY (id_stavka_dijelovi) REFERENCES stavka_dijelovi (id)
    

);




