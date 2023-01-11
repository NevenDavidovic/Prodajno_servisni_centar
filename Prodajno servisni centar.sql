DROP DATABASE IF EXISTS Prodajno_servisni_centar;
CREATE DATABASE Prodajno_servisni_centar;
USE Prodajno_servisni_centar;

-- DONE
CREATE TABLE zaposlenik(
	id INTEGER AUTO_INCREMENT,
	oib VARCHAR (20) NOT NULL UNIQUE,
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
	CONSTRAINT zaposlenik_pk PRIMARY KEY (id),
	CONSTRAINT zaposlenik_spol_ck CHECK (spol='Ž' OR spol='M')
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
	CONSTRAINT	auto_pk PRIMARY KEY (id),
	CONSTRAINT auto_dostupnost_ck CHECK (dostupnost='DA' OR dostupnost='NE'),
	CONSTRAINT auto_servis_prodaja_ck CHECK (servis_prodaja='S' OR servis_prodaja='P')
);


-- DONE
CREATE TABLE oprema(
	id INTEGER AUTO_INCREMENT,
	naziv VARCHAR (40) NOT NULL,
   	marka VARCHAR (40) NOT NULL,
    model VARCHAR (40) NOT NULL,
	cijena DECIMAL (8,2) NOT NULL,
	CONSTRAINT oprema_pk PRIMARY KEY (id)
);


-- DONE
CREATE TABLE oprema_vozila(
	id INTEGER AUTO_INCREMENT,
	id_auto INTEGER,
	id_oprema INTEGER,
	CONSTRAINT oprema_vozila_pk PRIMARY KEY (id),
	CONSTRAINT oprema_vozila_auto_fk FOREIGN KEY (id_auto) REFERENCES auto (id) on delete set null,
	CONSTRAINT oprema_vozila_oprema_fk FOREIGN KEY (id_oprema) REFERENCES oprema (id) on delete set null,
    CONSTRAINT oprema_auto_qk UNIQUE KEY (id_auto, id_oprema)
);


-- DONE
CREATE TABLE klijent(
	id INTEGER AUTO_INCREMENT,
	oib VARCHAR (20) NOT NULL UNIQUE,
	ime VARCHAR (20) NOT NULL,
	prezime VARCHAR (20) NOT NULL,
	broj_telefona VARCHAR (20) NOT NULL UNIQUE,
	adresa VARCHAR (40) NOT NULL,
	grad VARCHAR (20) NOT NULL,
	spol CHAR (1) NOT NULL,
	CONSTRAINT klijent_pk PRIMARY KEY (id),
	CONSTRAINT klijent_spol_ck CHECK (spol='Ž' OR spol='M')
);


-- DONE
CREATE TABLE racun_prodaje(
	id INTEGER AUTO_INCREMENT,
	id_zaposlenik INTEGER,
	id_auto INTEGER UNIQUE,
	id_klijent INTEGER,
	broj_racuna INTEGER UNIQUE,
	datum DATE NOT NULL,
	cijena DECIMAL (8,2),
	CONSTRAINT racun_prodaje_pk PRIMARY KEY (id),
	CONSTRAINT racun_prodaje_zaposlenik_fk FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik (id) on delete set null,
	CONSTRAINT racun_prodaje_auto_fk FOREIGN KEY (id_auto) REFERENCES auto (id) on delete set null,
	CONSTRAINT racun_prodaje_klijent_fk FOREIGN KEY (id_klijent) REFERENCES klijent (id) on delete set null,
    CONSTRAINT racun_prodaje_cijena_ck CHECK (cijena >= 0)
);



-- DONE
CREATE TABLE narudzbenica(
	id INTEGER AUTO_INCREMENT,
	id_klijent INTEGER,
	id_auto INTEGER,
	broj_narudzbe INTEGER UNIQUE,
	datum_zaprimanja DATE NOT NULL,
	datum_povratka DATETIME NOT NULL,
	CONSTRAINT narudzbenica_pk PRIMARY KEY (id),
	CONSTRAINT narudzbenica_klijent_fk FOREIGN KEY (id_klijent) REFERENCES klijent (id) on delete set null,
	CONSTRAINT narudzbenica_auto_fk FOREIGN KEY (id_auto) REFERENCES auto (id) on delete set null
);


-- DONE
CREATE TABLE usluga_servis(
	id INTEGER AUTO_INCREMENT,
	naziv VARCHAR (50) NOT NULL,
	cijena DECIMAL (8,2) NOT NULL,
	CONSTRAINT usluga_servis_pk PRIMARY KEY (id)
);


-- DONE
CREATE TABLE servis(
	id INTEGER AUTO_INCREMENT,
	id_usluga_servis INTEGER,
	id_zaposlenik INTEGER,
	id_narudzbenica INTEGER,
	komentar VARCHAR(100) DEFAULT "Servis uredno izvrsen",
	CONSTRAINT servis_pk PRIMARY KEY (id),
	CONSTRAINT servis_usluga_servis_fk FOREIGN KEY (id_usluga_servis) REFERENCES usluga_servis (id) on delete set null,
	CONSTRAINT servis_zaposlenik_fk FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik (id) on delete set null,
	CONSTRAINT servis_narudzbenica_fk FOREIGN KEY (id_narudzbenica) REFERENCES narudzbenica (id) on delete set null,
	CONSTRAINT servis_narudzbenica_uk UNIQUE KEY (id_usluga_servis, id_narudzbenica)
);


-- DONE
CREATE TABLE dio(
	id INTEGER AUTO_INCREMENT,
	naziv VARCHAR (50) NOT NULL,
	proizvodac VARCHAR (30) NOT NULL,
	CONSTRAINT naziv_proizvodac_uk UNIQUE (naziv, proizvodac),
	CONSTRAINT dio_pk PRIMARY KEY (id)
);


-- DONE
CREATE TABLE dio_na_servisu(
	id INTEGER AUTO_INCREMENT,
	id_servis INTEGER,
	id_dio INTEGER,
	kolicina INTEGER NOT NULL,
	CONSTRAINT dio_na_servisu_pk PRIMARY KEY (id),
	CONSTRAINT dio_na_servisu_servis_fk FOREIGN KEY (id_servis) REFERENCES servis (id) on delete set null,
	CONSTRAINT dio_na_servisu_dio_fk FOREIGN KEY (id_dio) REFERENCES dio (id) on delete set null,
	CONSTRAINT servis_dio_uk UNIQUE KEY (id_servis, id_dio)
);


-- DONE
CREATE TABLE stavka_dio(
	id INTEGER AUTO_INCREMENT,
	id_dio INTEGER,
	serijski_broj VARCHAR (20) NOT NULL UNIQUE,
	opis TINYTEXT NOT NULL,
   	kategorija VARCHAR(20) NOT NULL,
	nabavna_cijena DECIMAL (8,2) NOT NULL,
	prodajna_cijena DECIMAL (8,2) NOT NULL,
    dostupna_kolicina INTEGER NOT NULL,
	CONSTRAINT stavka_dio_pk PRIMARY KEY (id),
	CONSTRAINT stavka_dio_dio_fk FOREIGN KEY (id_dio) REFERENCES dio (id) on delete set null
);