-- MARIJA start
-- 1. upit: Popis zaposlenika koji su servisirali aute kupljene u PSC

CREATE VIEW narudzbenica_kupljeni AS
SELECT *
	FROM narudzbenica
    WHERE id_auto IN (
		SELECT id_auto
			FROM racun_prodaje
    );

SELECT *
	FROM zaposlenik
    WHERE id IN (
		SELECT DISTINCT id_zaposlenik
			FROM servis, narudzbenica_kupljeni
			WHERE servis.id_narudzbenica=narudzbenica_kupljeni.id
			ORDER BY id_zaposlenik ASC
    );


-- 2. upit: Marke auta sevisirane od strane mehaničara

CREATE VIEW narudzbenica_mehanicar AS
SELECT narudzbenica.*
	FROM servis, narudzbenica
    WHERE servis.id_narudzbenica=narudzbenica.id
    AND servis.id_zaposlenik IN (
		SELECT id
			FROM zaposlenik
			WHERE radno_mjesto='mehanicar'
    );

SELECT DISTINCT marka_automobila
	FROM auto
    WHERE id IN (
		SELECT id_auto
			FROM narudzbenica_mehanicar
    )
    ORDER BY marka_automobila ASC;
-- MARIJA end

-- NEVEN UPITI
-- Prva tri zaposlenika koja imaju najviše servisa

SELECT CONCAT(z.ime ,' ', z.prezime) AS Ime_i_prezime,COUNT(z.id) as broj_servisa
FROM servis AS s, usluga_servis AS u, zaposlenik AS z
WHERE z.id=id_zaposlenik AND u.id=id_usluga_servis
GROUP BY z.id
ORDER BY broj_servisa
DESC LIMIT 3;

-- Zaposlenici(prva 3) sa najvišom kumulativnom cijenom svih obavljenih servisa servisa.

SELECT CONCAT(z.ime ,' ', z.prezime)as Ime_i_prezime, u.naziv,SUM(u.cijena) AS ukupno_po_servisu
FROM servis AS s, usluga_servis AS u, zaposlenik AS z
WHERE z.id=id_zaposlenik AND u.id=id_usluga_servis
GROUP BY z.id
ORDER BY ukupno_po_servisu DESC
LIMIT 3;

-- Pogled pomoću kojeg saznajemo

CREATE VIEW servisirano AS
SELECT CONCAT(z.ime ,' ', z.prezime)as Ime_i_prezime, u.naziv,SUM(u.cijena) AS ukupno_po_servisu
FROM servis AS s, usluga_servis AS u, zaposlenik AS z
WHERE z.id=id_zaposlenik AND u.id=id_usluga_servis
GROUP BY z.id
ORDER BY ukupno_po_servisu DESC;

-- Prosjek servisa po zaposlenicima
SELECT AVG(ukupno_po_servisu) FROM servisirano;
-- Zaposlenici koji su obavili manje servisa od prosjeka
SELECT * FROM servisirano WHERE ukupno_po_servisu <(SELECT AVG(ukupno_po_servisu) FROM servisirano);
-- Zaposlenici koji su obavili više servisa od prosjeka
SELECT * FROM servisirano WHERE ukupno_po_servisu >(SELECT AVG(ukupno_po_servisu) FROM servisirano);

-- neven kraj upita

-- TIN UPITI
## Top 5 modela auta sa najviše utrošenih djelova na servisima u zadnjih 6 mjeseci?

SELECT a.marka_automobila, a.model,SUM(kolicina) AS broj_ugradjenih_djelova
FROM auto a INNER JOIN narudzbenica n ON a.id = n.id_auto
INNER JOIN servis s ON n.id = s.id_narudzbenica
INNER JOIN dio_na_servisu i ON s.id = i.id_servis
WHERE datum_zaprimanja > DATE(DATE_sub(NOW(), INTERVAL 6 MONTH))
GROUP BY model
ORDER BY broj_ugradjenih_djelova DESC
LIMIT 5;

## Koliko je usluga servisa bilo izvrseno na benzinskim, dizelskim i elektricnim autima u zadnjih 6 mj?

CREATE VIEW usluge_po_narudzbenici AS
SELECT id_narudzbenica, COUNT(id_usluga_servis) AS broj_izvrsenih_usluga
FROM servis s
GROUP by id_narudzbenica;

SELECT a.tip_motora, SUM(broj_izvrsenih_usluga) as ukupno_izvrsenih_usluga
FROM usluge_po_narudzbenici upn
INNER JOIN narudzbenica n ON upn.id_narudzbenica = n.id
INNER JOIN auto a ON a.id = n.id_auto
WHERE datum_zaprimanja > DATE(DATE_sub(NOW(), INTERVAL 6 MONTH))
GROUP BY tip_motora
ORDER BY ukupno_izvrsenih_usluga DESC;

##  Koji se automobili najviše prodaju u kojem cjenovnom rangu (jeftini, srednji, skupi)?

-- FUNKCIJE ZA ODREĐIVANJE CIJENE PRODANIH AUTOMOBILA
DELIMITER //
CREATE FUNCTION min_cijena() RETURNS INTEGER
DETERMINISTIC
BEGIN

RETURN (SELECT MIN(cijena) FROM racun_prodaje);

END//
DELIMITER ;

DELIMITER //
CREATE FUNCTION max_cijena() RETURNS INTEGER
DETERMINISTIC
BEGIN

RETURN (SELECT MAX(cijena) FROM racun_prodaje);

END//
DELIMITER ;

DELIMITER //
CREATE FUNCTION raspon_cijena() RETURNS INTEGER
DETERMINISTIC
BEGIN

RETURN ((SELECT MAX(cijena) FROM racun_prodaje) - (SELECT MIN(cijena) FROM racun_prodaje));

END//
DELIMITER ;


## jefitni  auti
CREATE VIEW najprodavaniji_jefitni_auti AS
SELECT a.marka_automobila,a.model,COUNT(*) AS br_prodanih_auta
FROM racun_prodaje rp
INNER JOIN auto a ON rp.id_auto = a.id
WHERE cijena BETWEEN (SELECT min_cijena() FROM DUAL) AND ((SELECT raspon_cijena() FROM DUAL)/3)
GROUP BY a.model
ORDER BY br_prodanih_auta DESC;

SELECT * FROM najprodavaniji_jefitni_auti;


## srednje skupi auti
CREATE VIEW najprodavaniji_srednje_skupi_auti AS
SELECT a.marka_automobila,a.model,COUNT(*) AS br_prodanih_auta
FROM racun_prodaje rp
INNER JOIN auto a ON rp.id_auto = a.id
WHERE cijena BETWEEN ((SELECT raspon_cijena() FROM DUAL)/3) AND (((SELECT raspon_cijena() FROM DUAL)/3) * 2)
GROUP BY a.model
ORDER BY br_prodanih_auta DESC;

SELECT * FROM najprodavaniji_srednje_skupi_auti;


## skupi auti
CREATE VIEW najprodavaniji_skupi_auti AS
SELECT a.marka_automobila,a.model,COUNT(*) AS br_prodanih_auta
FROM racun_prodaje rp
INNER JOIN auto a ON rp.id_auto = a.id
WHERE cijena BETWEEN (((SELECT raspon_cijena() FROM DUAL)/3) * 2) AND (SELECT max_cijena() FROM DUAL)
GROUP BY a.model
ORDER BY br_prodanih_auta DESC;

SELECT * FROM najprodavaniji_skupi_auti;

-- TIN KRAJ UPITA


-- DARJAN UPITI + POGLED

# Selektiraj sve automobile koji za dodatnu opremu imaju parkirnu kameru marke Garmin, kako bi se na istima ažurirao softver

select  a.id, marka_automobila, upper(naziv) as " Dodatna oprema ", upper(marka) as "Marka"
from auto a
inner join oprema_vozila s on a.id = s.id_auto
inner join oprema o on s.id_oprema = o.id
where naziv = "parkirna kamera" and marka = "Garmin";

# Prikaži sve klijente (kupce) sa ukupnim brojem računa (koliko su auta kupili kod nas)

select k.*, count(r.id) as "Ukupan broj računa"
from klijent k
inner join racun_prodaje r on k.id = r.id_klijent
group by k.id;

# Napravi pogled koji prikazuje skupe dijelove (prodajna cijena > 1000), pritom se kroz pogled mogu unositi samo podaci koji zadovoljavaju uvjet

# drop view skup_dio;

create view skup_dio as
select *
from stavka_dio
where prodajna_cijena > 1000
with check option;

# Prikaz skupih dijelova

select * from skup_dio;

# Unos nije moguć zbog uvjeta

# INSERT INTO skup_dio VALUES (40, 40, "55032099911", "set zupcasti remen + pumpa", "pogon", 945.1871943242245, 980.2079936935827, 8);

-- DARJAN KRAJ

-- SARA UPITI

-- prihodi po mjesecima od prodaje automobila u 2022. godini

CREATE VIEW prihod_po_mjesecima AS
SELECT SUM(cijena) AS prihodi , EXTRACT(MONTH FROM datum) AS mjesec
FROM racun_prodaje
WHERE EXTRACT(YEAR FROM datum)="2022"
GROUP BY CAST(DATE_SUB(datum, INTERVAL DAYOFMONTH(datum)-1 DAY) AS DATE);

-- mjesec sa najmanje prihoda i iznos prihoda od prodaje automobila
SELECT *
FROM  prihod_po_mjesecima
WHERE prihodi IN ( SELECT MIN(prihodi) FROM prihod_po_mjesecima);

-- mjesec sa najvise prihoda od prodje automobila
SELECT *
FROM  prihod_po_mjesecima
WHERE prihodi IN ( SELECT MAX(prihodi) FROM prihod_po_mjesecima);

-- prosječan iznos prihoda za 2022. godinu od prodaje automobila
SELECT AVG(prihodi)
FROM prihod_po_mjesecima;

-- ukupan prihod servisa i dijelova po mjesecima 2022
CREATE VIEW cijena__servisa AS
SELECT id_narudzbenica, SUM(cijena) AS cijena_servisa, datum_povratka, s.id
FROM narudzbenica n, servis s,usluga_servis u
WHERE n.id=s.id_narudzbenica AND u.id=s.id_usluga_servis
GROUP BY id_narudzbenica;

CREATE VIEW cijena__dijelova AS
SELECT id_narudzbenica, SUM(kolicina*prodajna_cijena) AS cijena_dijelova, id_servis
FROM dio_na_servisu i
INNER JOIN stavka_dio sd ON i.id_dio=sd.id_dio
RIGHT JOIN servis s ON s.id=i.id_servis
GROUP BY id_narudzbenica;

CREATE VIEW dio_servis_po_mj AS 
SELECT SUM((IFNULL(cijena_dijelova, 0)+cijena_servisa)) AS ukupna_cijena_servisa, EXTRACT(MONTH FROM datum_povratka) AS mjesec 
FROM cijena__dijelova cd, cijena__servisa cs
WHERE cd.id_narudzbenica=cs.id_narudzbenica AND EXTRACT(YEAR FROM datum_povratka)="2022"
GROUP BY CAST(DATE_SUB(datum_povratka, INTERVAL DAYOFMONTH(datum_povratka)-1 DAY) AS DATE)
ORDER BY mjesec ASC;

-- ukupni prihodi u godini 2022

CREATE VIEW svi_prihodi_u_godini AS
SELECT SUM((IFNULL(prihodi, 0)+ukupna_cijena_servisa)) AS prihodi
FROM prihod_po_mjesecima pm
RIGHT JOIN dio_servis_po_mj ds ON pm.mjesec=ds.mjesec;

-- ukupan rashod od placa zaposlenika
CREATE VIEW rashod_placa AS
SELECT SUM(placa*12) AS ukupni_trosak_placa
FROM zaposlenik;

-- ukupan rashod od kupnje dijelova

CREATE VIEW rashod_dijelova AS
SELECT SUM((nabavna_cijena*dostupna_kolicina)) AS ukupan_trosak_dijelova
FROM stavka_dio;

-- ukupan rashod u godini 2022

CREATE VIEW ukupni_rashodi AS
SELECT (ukupan_trosak_dijelova+ukupni_trosak_placa) AS rashodi
FROM rashod_dijelova rd, rashod_placa rp;

-- prihodi-rashodi

SELECT (prihodi-rashodi) AS racun_dobiti_ili_gubitka
FROM ukupni_rashodi ur,svi_prihodi_u_godini pr;

-- tablica sa rashodima i prihodima da se može uspostaviti dobit ili gubitak

CREATE VIEW rash_prih AS
SELECT prihodi , rashodi
FROM ukupni_rashodi ur,svi_prihodi_u_godini pr;


-- SARA KRAJ

-- NOEL UPITI

-- prikaži sve klijente koji su u prodajno servisnom centru kupili automobil "MITSUBISHI OUTLANDER"

/*

SELECT klijent.ime, klijent.prezime
FROM klijent
INNER JOIN racun_prodaje ON klijent.id = racun_prodaje.id_klijent
INNER JOIN auto ON racun_prodaje.id_auto = auto.id
WHERE marka_automobila = "MITSUBISHI" AND model = "OUTLANDER";

*/

-- prikazi sve automobile marke 'BMW'  sa godinom proizvodnje starijom od 2015.

/*

CREATE VIEW stariji_modeli_automobila AS
SELECT *
FROM auto
WHERE YEAR (godina_proizvodnje) < 2018
ORDER BY godina_proizvodnje ASC;
SELECT marka_automobila, model, godina_proizvodnje
FROM stariji_modeli_automobila
HAVING marka_automobila ='BMW';

*/

-- prikaz broja zaposlenika ali samo onih koji rade kao mehanicari i prikaz imena, prezimena i broja godina najmladeg i najstarijeg mehanicara

/*

CREATE VIEW godine_mehanicara AS
SELECT *, CURDATE() as sadasnji_datum, TIMESTAMPDIFF(YEAR, datum_rodenja, CURDATE())AS age FROM zaposlenik
WHERE radno_mjesto = 'mehanicar'
ORDER BY datum_rodenja ;

-- ime prezime i broj godina najstarijeg mehaničara
SELECT ime, prezime, MAX(age)
FROM godine_mehanicara;

-- broj mehaničara
SELECT COUNT(*) as broj_mehanicara
FROM godine_mehanicara;

-- ime prezime i broj godina najmlađeg mehaničara
SELECT ime, prezime, MIN(age) FROM godine_mehanicara;

*/

-- NOEL KRAJ
