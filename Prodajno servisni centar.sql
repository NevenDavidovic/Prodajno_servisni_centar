DROP DATABASE IF EXISTS Prodajno_servisni_centar;
CREATE DATABASE Prodajno_servisni_centar;
USE Prodajno_servisni_centar;


-- DONE
CREATE TABLE zaposlenik(
	id INTEGER AUTO_INCREMENT,
	ime VARCHAR (20) NOT NULL,
	prezime VARCHAR (20) NOT NULL,
	datum_rodenja DATE NOT NULL,
	adresa VARCHAR (40) NOT NULL,
	grad VARCHAR (20) NOT NULL,
	spol CHAR (1) NOT NULL,
	broj_telefona VARCHAR (20) NOT NULL UNIQUE,
    datum_zaposlenja DATE NOT NULL,
	e_mail VARCHAR (30) NOT NULL UNIQUE,
	placa DECIMAL (8,2) NOT NULL,
	radno_mjesto VARCHAR (20) NOT NULL,
	PRIMARY KEY (id),
	CHECK (spol='Ž' OR spol='M')
);




-- DONE
CREATE TABLE auto(
	id INTEGER AUTO_INCREMENT,
	broj_sasije VARCHAR (20) NOT NULL UNIQUE,
	marka_automobila VARCHAR (20) NOT NULL,
	model VARCHAR (40) NOT NULL,
	boja VARCHAR (20) NOT NULL,
	godina_proizvodnje DATE NOT NULL,
	dostupnost CHAR (2) NOT NULL,
	snaga_motora VARCHAR (20) NOT NULL,
    kilometraza INTEGER NOT NULL,
	tip_motora VARCHAR (20) NOT NULL,
	servis_prodaja CHAR(1) NOT NULL,
	PRIMARY KEY (id),
	CHECK (dostupnost='DA' OR dostupnost='NE'),
	CHECK (servis_prodaja='S' OR servis_prodaja='P')
);


-- DONE
CREATE TABLE oprema(
	id INTEGER AUTO_INCREMENT,
	naziv VARCHAR (40) NOT NULL,
   	marka VARCHAR (40) NOT NULL,
    model VARCHAR (40) NOT NULL,
	cijena DECIMAL (8,2) NOT NULL,
	PRIMARY KEY (id)
);


-- DONE
CREATE TABLE oprema_vozila(
	id INTEGER AUTO_INCREMENT,
	id_auto INTEGER NOT NULL,
	id_oprema INTEGER NOT NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (id_auto) REFERENCES auto (id) on delete cascade,
	FOREIGN KEY (id_oprema) REFERENCES oprema (id) on delete cascade,
    UNIQUE KEY (id_auto, id_oprema)
);


-- DONE
CREATE TABLE klijent(
	id INTEGER AUTO_INCREMENT,
	ime VARCHAR (20) NOT NULL,
	prezime VARCHAR (20) NOT NULL,
	broj_telefona VARCHAR (20) NOT NULL UNIQUE,
	adresa VARCHAR (40) NOT NULL,
	grad VARCHAR (20) NOT NULL,
	spol CHAR (1) NOT NULL,
	PRIMARY KEY (id),
	CHECK (spol='Ž' OR spol='M')
);


-- DONE
CREATE TABLE racun_prodaje(
	id INTEGER AUTO_INCREMENT,
	id_zaposlenik INTEGER NOT NULL,
	id_auto INTEGER NOT NULL UNIQUE,
	id_klijent INTEGER NOT NULL,
	broj_racuna INTEGER UNIQUE,
	datum DATE NOT NULL,
	cijena DECIMAL (8,2),
	PRIMARY KEY (id),
	FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik (id) on delete cascade,
	FOREIGN KEY (id_auto) REFERENCES auto (id) on delete cascade,
	FOREIGN KEY (id_klijent) REFERENCES klijent (id) on delete cascade
);


-- DONE
CREATE TABLE narudzbenica(
	id INTEGER AUTO_INCREMENT,
	id_klijent INTEGER NOT NULL,
	id_auto INTEGER NOT NULL,
	broj_narudzbe INTEGER,
	datum_zaprimanja DATE NOT NULL,
	datum_povratka DATETIME NOT NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (id_klijent) REFERENCES klijent (id) on delete cascade,
	FOREIGN KEY (id_auto) REFERENCES auto (id) on delete cascade
);


-- DONE
CREATE TABLE usluga_servis(
	id INTEGER AUTO_INCREMENT,
	naziv VARCHAR (50) NOT NULL,
	cijena DECIMAL (8,2) NOT NULL,
	PRIMARY KEY (id)
);


-- DONE
CREATE TABLE servis(
	id INTEGER AUTO_INCREMENT,
	id_usluga_servis INTEGER NOT NULL,
	id_zaposlenik INTEGER NOT NULL,
	id_narudzbenica INTEGER NOT NULL,
	komentar VARCHAR(100) DEFAULT "Servis uredno izvrsen",
	PRIMARY KEY (id),
	FOREIGN KEY (id_usluga_servis) REFERENCES usluga_servis (id) on delete cascade,
	FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik (id) on delete cascade,
	FOREIGN KEY (id_narudzbenica) REFERENCES narudzbenica (id) on delete cascade,
	UNIQUE KEY (id_usluga_servis, id_narudzbenica)
);


-- DONE
CREATE TABLE dio(
	id INTEGER AUTO_INCREMENT,
	naziv VARCHAR (50) NOT NULL,
	proizvodac VARCHAR (30) NOT NULL,
	PRIMARY KEY (id)
);


-- DONE
CREATE TABLE dio_na_servisu(
	id INTEGER AUTO_INCREMENT,
	id_servis INTEGER NOT NULL,
	id_dio INTEGER NOT NULL,
	kolicina INTEGER NOT NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (id_servis) REFERENCES servis (id) on delete cascade,
	FOREIGN KEY (id_dio) REFERENCES dio (id) on delete cascade
);


-- DONE
CREATE TABLE stavka_dio(
	id INTEGER AUTO_INCREMENT,
	id_dio INTEGER NOT NULL,
	serijski_broj VARCHAR (20) NOT NULL UNIQUE,
	opis TINYTEXT NOT NULL,
   	kategorija VARCHAR(20) NOT NULL,
	nabavna_cijena DECIMAL (8,2) NOT NULL,
	prodajna_cijena DECIMAL (8,2) NOT NULL,
    	dostupna_kolicina INTEGER NOT NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (id_dio) REFERENCES dio (id) on delete cascade
);
