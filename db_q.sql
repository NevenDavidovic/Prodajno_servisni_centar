-- MARIJA start
/*
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

-- 1. UPIT: Kolicina prodanih automobila prema tipu motora i godini proizvodnje
-- /tip motora - x os, godina proizvodnje - y os: graf sa stupcima/

# popis tipova motora automobila
SELECT DISTINCT tip_motora AS vrsta_vozila
	FROM auto;

# kolicina prodanih benzinskih automobila prema godini proizvodnje
SELECT godina_proizvodnje, COUNT(godina_proizvodnje) AS kolicina_benzin
	FROM racun_prodaje, auto
    WHERE racun_prodaje.id_auto=auto.id AND tip_motora='benzinski'
    GROUP BY godina_proizvodnje
    ORDER BY godina_proizvodnje ASC;

# kolicina prodanih dizelskih automobila prema godini proizvodnje
SELECT godina_proizvodnje, COUNT(godina_proizvodnje) AS kolicina_dizel
	FROM racun_prodaje, auto
    WHERE racun_prodaje.id_auto=auto.id AND tip_motora='dizel'
    GROUP BY godina_proizvodnje
    ORDER BY godina_proizvodnje ASC;

# kolicina prodanih elektricnih automobila prema godini proizvodnje
SELECT godina_proizvodnje, COUNT(godina_proizvodnje) AS kolicina_elektricni
	FROM racun_prodaje, auto
    WHERE racun_prodaje.id_auto=auto.id AND tip_motora='električni'
    GROUP BY godina_proizvodnje
    ORDER BY godina_proizvodnje ASC;

# kolicina prodanih hibridnih automobila prema godini proizvodnje
SELECT godina_proizvodnje, COUNT(godina_proizvodnje) AS kolicina_hibridni
	FROM racun_prodaje, auto
    WHERE racun_prodaje.id_auto=auto.id AND tip_motora='hibridni'
    GROUP BY godina_proizvodnje
    ORDER BY godina_proizvodnje ASC;

-- 2. UPIT: Kolicina automobila prema markama koji nisu prodani
-- (niti jedan automobil navedenih marki nije prodan)
-- /marka automobila - x os, kolicina - y os: graf sa stupcima/

# popis marki automobila koji su se prodali
SELECT DISTINCT marka_automobila
	FROM racun_prodaje, auto
    WHERE racun_prodaje.id_auto=auto.id
    ORDER BY marka_automobila ASC;

# kolicina automobila prema markama koji nisu prodani
SELECT marka_automobila, COUNT(marka_automobila) AS kolicina
	FROM auto
    WHERE auto.marka_automobila NOT IN
    (SELECT DISTINCT marka_automobila
			FROM racun_prodaje, auto
			WHERE racun_prodaje.id_auto=auto.id)
    GROUP BY marka_automobila
    ORDER BY kolicina DESC;
*/

-- UPITI ZA ADMINISTRACIJA - STATISTIKA

-- 1. UPIT: Koliko je automobila prodano po mjesecima u 2022. godini?

# kolicina prodanih automobila u 2022. godini po mjesecima
CREATE VIEW prodaja_automobila_po_mjesecima_2022 AS
SELECT EXTRACT(MONTH FROM datum) AS mjesec, COUNT(datum) AS kolicina
	FROM racun_prodaje
    WHERE EXTRACT(YEAR FROM datum)="2022"
    GROUP BY EXTRACT(MONTH FROM datum)
    ORDER BY mjesec ASC;

SELECT * FROM prodaja_automobila_po_mjesecima_2022;

# mjesec sa najvise prodaja
SELECT *
	FROM prodaja_automobila_po_mjesecima_2022
    WHERE kolicina IN (
		SELECT MAX(kolicina)
			FROM prodaja_automobila_po_mjesecima_2022
    );

# mjesec sa najmanje prodaja
SELECT *
	FROM prodaja_automobila_po_mjesecima_2022
    WHERE kolicina IN (
		SELECT MIN(kolicina)
			FROM prodaja_automobila_po_mjesecima_2022
    );

-- 2. UPIT: Koliko je automobila servisirano po mjesecima u 2022. godini?

# kolicina servisiranih automobila u 2022. godini po mjesecima
CREATE VIEW servis_automobila_po_mjesecima_2022 AS
SELECT EXTRACT(MONTH FROM datum_zaprimanja) AS mjesec, COUNT(datum_zaprimanja) AS kolicina
	FROM narudzbenica
    WHERE EXTRACT(YEAR FROM datum_zaprimanja)="2022"
    GROUP BY EXTRACT(MONTH FROM datum_zaprimanja)
    ORDER BY mjesec ASC;

SELECT * FROM servis_automobila_po_mjesecima_2022;

# mjesec sa najvise servisa
SELECT *
	FROM servis_automobila_po_mjesecima_2022
    WHERE kolicina IN (
		SELECT MAX(kolicina)
			FROM servis_automobila_po_mjesecima_2022
    );

# mjesec sa najmanje servisa
SELECT *
	FROM servis_automobila_po_mjesecima_2022
    WHERE kolicina IN (
		SELECT MIN(kolicina)
			FROM servis_automobila_po_mjesecima_2022
    );
-- MARIJA end

-- NEVEN UPITI
-- Prva tri zaposlenika koja imaju najviše servisa

CREATE VIEW dijelovi AS
SELECT stavka_dio.id,naziv,proizvodac,serijski_broj,opis, kategorija, nabavna_cijena,prodajna_cijena,dostupna_kolicina 
FROM dio,stavka_dio 
WHERE dio.id=stavka_dio.id_dio;

CREATE VIEW narudzbenicej AS
SELECT narudzbenica.id,broj_sasije,oib, marka_automobila, model, boja,
dostupnost,godina_proizvodnje, snaga_motora, kilometraza, tip_motora, 
ime, prezime, broj_telefona, adresa,grad,spol,broj_narudzbe, datum_zaprimanja, datum_povratka  
FROM auto, klijent, narudzbenica 
WHERE auto.id=narudzbenica.id_auto 
AND klijent.id=narudzbenica.id_klijent 
AND servis_prodaja='S';

CREATE VIEW podaci_o_servisu AS
SELECT s.id as servis_id,n.id as narudzbenica_id,z.id as zaposlenik_id, us.id as usluga_servis_id, k.id as klijent_id,
komentar,datum_zaprimanja, datum_povratka, z.oib as zaposlenik_oib, z.ime as zaposlenik_ime, z.prezime as zaposlenik_prezime,
z.datum_rodenja as zaposlenik_datum_rodenja, z.adresa as zaposlenik_adresa, z.grad as zaposlenik_grad, z.spol as zaposlenik_spol,
z.broj_telefona as zaposlenik_broj_telefona, z.datum_zaposlenja as zaposlenik_datum_zaposlenja,z.e_mail as zaposlenik_e_mail,
z.placa as zaposlenik_placa, z.radno_mjesto as zaposlenik_radno_mjesto, us.naziv as usluga_servis_naziv, us.cijena as usluga_servis_cijena,
k.oib as klijent_oib,k.ime as klijent_ime, k.prezime as klijent_prezime,k.broj_telefona as klijent_broj_telefona, k.adresa as klijent_adresa,
k.grad as klijent_grad, k.spol as klijent_spol, broj_sasije, marka_automobila,model, boja,godina_proizvodnje,dostupnost,snaga_motora, kilometraza,
tip_motora,broj_narudzbe
FROM
servis as s,
narudzbenica as n,
zaposlenik as z,
usluga_servis as us,
klijent as k,
auto as a
 WHERE n.id=s.id_narudzbenica
 AND z.id=s.id_zaposlenik
 AND us.id=s.id_usluga_servis
 AND k.id=n.id_klijent
 AND a.id= n.id_auto;

CREATE VIEW dijelovi_po_servisu AS
SELECT dio.id as dio_id,dio_na_servisu.id_servis as dio_na_servisu_servis_id, stavka_dio.id as stavka_id,
naziv,dio_na_servisu.id as dio_na_servisu_id, dio.naziv as dio_naziv ,proizvodac, 
serijski_broj,opis,kategorija, nabavna_cijena,prodajna_cijena,dostupna_kolicina,kolicina
FROM dio_na_servisu,dio,stavka_dio 
WHERE stavka_dio.id_dio=dio.id 
AND dio.id=dio_na_servisu.id_dio;

SELECT CONCAT(z.ime ,' ', z.prezime) AS Ime_i_prezime,COUNT(z.id) as broj_servisa
FROM servis AS s, usluga_servis AS u, zaposlenik AS z
WHERE z.id=s.id_zaposlenik AND u.id=s.id_usluga_servis
GROUP BY z.id
ORDER BY broj_servisa
DESC LIMIT 3;

-- Zaposlenici(prva 3) sa najvišom kumulativnom cijenom svih obavljenih servisa servisa.

SELECT CONCAT(z.ime ,' ', z.prezime)as Ime_i_prezime ,SUM(u.cijena) AS ukupno_po_servisu
FROM servis AS s, usluga_servis AS u, zaposlenik AS z
WHERE z.id=s.id_zaposlenik AND u.id=s.id_usluga_servis
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
-- DROP VIEW svi_podaci_sa_racuna;
CREATE VIEW svi_podaci_sa_racuna AS
SELECT 
rp.id as rp_id,
rp.id_zaposlenik as rp_id_zaposlenik,
rp.id_auto as rp_id_auto,
rp.id_klijent as rp_id_klijent,
rp.broj_racuna as rp_broj_racuna,
rp.datum as rp_datum,
rp.cijena as rp_cijena,

z.id as z_id,
z.ime as z_ime,
z.prezime as z_prezime,
z.oib as z_oib,

a.broj_sasije as a_broj_sasije,
a.marka_automobila as a_marka_automobila,
a.model as a_model,
a.boja as a_boja,
a.godina_proizvodnje as a_godina_proizvodnje,
a.snaga_motora as a_snaga_motora,
a.kilometraza as a_kilometraza,
a.tip_motora as a_tip_motora,

k.ime as k_ime,
k.prezime as k_prezime,
k.broj_telefona as k_broj_telefona,
k.adresa as k_adresa,
k.grad as k_grad,
k.spol as k_spol,
k.oib as k_oib

FROM racun_prodaje rp 
INNER JOIN zaposlenik z ON rp.id_zaposlenik = z.id
INNER JOIN auto a ON rp.id_auto = a.id
INNER JOIN klijent k ON rp.id_klijent = k.id;

-- view koji prikazuje kolicinu i informacije o djelovima ugrađenim u zadnjih mjesec dana
CREATE VIEW dijelovi_ugradeni_u_zadnjih_mjesec_dana AS
SELECT dns.id_dio, nabavna_cijena, prodajna_cijena, (prodajna_cijena - nabavna_cijena) as profitna_razlika, SUM(kolicina) as ukupno_ugradeno_dijelova, datum_povratka as datum_ugradnje
FROM stavka_dio sd 
INNER JOIN dio_na_servisu dns ON dns.id_dio = sd.id_dio
INNER JOIN servis s ON dns.id_servis = s.id
INNER JOIN narudzbenica n ON s.id_narudzbenica = n.id
WHERE datum_povratka > (SELECT NOW() - INTERVAL 1 MONTH FROM DUAL)
GROUP BY dns.id_dio
ORDER BY ukupno_ugradeno_dijelova DESC;

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

SELECT * FROM dio_servis_po_mj;
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


-- NOEL upiti preko pogleda za statistiku

-- Prikaži preko pogleda samo one zaposlenike (prodavače) koji su prodali barem jedan auto (ime, prezime, radno mjesto, ukupno_prodanih_vozila) i poredaj ih prema broju prodanih vozila silazno

create view  prodavaci_sa_najvise_prodanih_automobila as
select CONCAT(z.ime,' ', z.prezime) AS ime, z.radno_mjesto, count(z.id) as ukupno_prodanih_vozila
from zaposlenik z
inner join racun_prodaje r on z.id = r.id_zaposlenik
where radno_mjesto = "prodavac"
group by z.id
order by ukupno_prodanih_vozila DESC;

-- Prikaz preko pogleda

select *
from prodavaci_sa_najvise_prodanih_automobila;

-- Brisanje pogleda

-- drop view prodavaci_sa_najvise_prodanih_automobila;

-- Prikaži preko pogleda statistički podatak koja je marka vozila najprodavanija u PSC-u, podatke poredaj silazno

create view najprodavanija_marka_automobila as
select marka_automobila, count(a.marka_automobila) as broj_prodanih_vozila
from auto a
inner join racun_prodaje r on a.id = r.id_auto
where servis_prodaja = "P" and dostupnost = "NE"
group by a.marka_automobila
order by broj_prodanih_vozila DESC;

-- Prikaz preko pogleda

select *
from najprodavanija_marka_automobila;

-- Brisanje pogleda

-- drop view najprodavanija_marka_automobila;

-- NOEL KRAJ

