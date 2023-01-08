-- SARA FUNKCIJE, PROCEDURE I OKIDACI

-- funkcija za određivanje dobiti ili gubitka

DELIMITER //
CREATE FUNCTION d_ili_g(rashod INTEGER, prihod INTEGER) RETURNS VARCHAR(90)
DETERMINISTIC
BEGIN
	DECLARE rj VARCHAR(90);

	IF rashod>prihod THEN
    SET rj="Ostvarili ste gubitak u tekućoj godini";
    ELSE
    SET rj ="Ostvarili ste dobit u tekućoj godini";
    END IF;

 RETURN rj;
END//
DELIMITER ;

-- SELECT d_ili_g(rashodi, prihodi) FROM rash_prih;

-- PROCEDURA ZA IZRAČUNAVANJE PROMETA DANA ZA SERVIS



DELIMITER //
CREATE PROCEDURE SERVIS_PROMET_DANA(IN p_datum DATE,OUT br_prodanih_stavki_s INTEGER, OUT promet_dana_s DECIMAL(6,2))
BEGIN
	
    SELECT SUM((IFNULL(cijena_dijelova, 0)+IFNULL(cijena_servisa, 0))) INTO promet_dana_s
	FROM cijena__dijelova cd, cijena__servisa cs
	WHERE cd.id_narudzbenica=cs.id_narudzbenica AND datum_povratka=p_datum
	GROUP BY datum_povratka;
    
    SELECT COUNT(id_narudzbenica) INTO br_prodanih_stavki_s
	FROM cijena__servisa
	WHERE datum_povratka=p_datum
	GROUP BY datum_povratka;
    
END //
DELIMITER ;

-- CALL SERVIS_PROMET_DANA("2022-05-30",@br_prodanih_stavki_s, @promet_dana_s);
-- SELECT @promet_dana_s,@br_prodanih_stavki_s FROM DUAL;

-- PROCEDURA ZA IZRAČUNAVANJE PROMETA DANA ZA PRODAJU
-- DROP PROCEDURE PRODAJA_PROMET_DANA;


DELIMITER //
CREATE PROCEDURE PRODAJA_PROMET_DANA(IN p_datum_p DATE,OUT br_prodanih_stavki_p INTEGER, OUT promet_dana_p DECIMAL(12,2))
BEGIN

	SELECT SUM(cijena), COUNT(id) INTO promet_dana_p, br_prodanih_stavki_p
	FROM racun_prodaje
	WHERE datum=p_datum_p
	GROUP BY datum;
    
  
END //
DELIMITER ;

-- CALL PRODAJA_PROMET_DANA("2022-05-30",@br_prodanih_stavki_p, @promet_dana_p);
-- SELECT @promet_dana_p,@br_prodanih_stavki_p FROM DUAL;

-- PROCEDURA ZA IZRAČUNAVANJE PROMETA DANA (ADMINISTRACIJA)

-- DROP PROCEDURE PROMET_DANA;

DELIMITER //
CREATE PROCEDURE PROMET_DANA(IN p_datum DATE,OUT br_prodanih_stavki INTEGER, OUT promet_dana DECIMAL(12,2))
BEGIN
	
    DECLARE servis_p, prodaja_p DECIMAL(12,2);
    DECLARE servis_br, prodaja_br INTEGER;

	CALL PRODAJA_PROMET_DANA(p_datum,@brprodstav, @promet);
	SELECT @promet,@brprodstav INTO prodaja_p, prodaja_br FROM DUAL;
    
    CALL SERVIS_PROMET_DANA(p_datum,@br_prod, @promets);
	SELECT @promets,@br_prod INTO servis_p, servis_br FROM DUAL;
    
    SET br_prodanih_stavki= (IFNULL(prodaja_br, 0))+(IFNULL(servis_br, 0));
    SET promet_dana=(IFNULL(prodaja_p, 0))+(IFNULL(servis_p, 0));

END //
DELIMITER ;

-- CALL PROMET_DANA("2022-11-11",@br_prodanih_stavki, @promet_dana);
-- SELECT @promet_dana,@br_prodanih_stavki FROM DUAL;

DELIMITER //
CREATE TRIGGER bi_narudzbenica
BEFORE INSERT ON narudzbenica
FOR EACH ROW
BEGIN
IF new.datum_zaprimanja > CURDATE() THEN
 SIGNAL SQLSTATE '40000'
 SET MESSAGE_TEXT = 'Datum zaprimanja ne može biti veći od trenutačnog datuma';
 END IF;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER bi_narudzbenica1
BEFORE INSERT ON narudzbenica
FOR EACH ROW
BEGIN
IF new.datum_povratka < new.datum_zaprimanja THEN
 SIGNAL SQLSTATE '40000'
 SET MESSAGE_TEXT = 'Datum povratka ne može biti manji od datuma zaprimanja';
 END IF;
END//
DELIMITER ;
INSERT INTO narudzbenica VALUES (666, 25, 218, 1, "2023-01-08 00:00:00", "2023-01-10 00:00:00");


-- SARA GOTOVA



-- DARJAN FPO

-- Napiši funkciju koja će u računu_prodaje vratiti vrijednost "DA" ako je vozilo prodano u posljednjih 6 mjeseci,
-- u suprotnom će pisati "NE"

DELIMITER //
CREATE FUNCTION f_racun_datum (p_id_racun int) returns CHAR (2)
DETERMINISTIC
BEGIN
declare dat datetime;
select datum into dat
from racun_prodaje
where id = p_id_racun;
if dat > (select now() - interval 6 month from dual) then
return "DA";
else return "NE";
end if;
end//
DELIMITER ;

-- Poziv funkcije

-- select*, f_racun_datum(id) as "Prodan u zadnjih šest mjeseci" from racun_prodaje;

-- Napiši funkciju koja će za svakog zaposlenika u firmi vratiti broj godina koliko radi kod nas

DELIMITER //
CREATE FUNCTION godina_u_firmi (p_datum date) returns INTEGER
DETERMINISTIC
BEGIN
declare trenutni_datum date;
select now() into trenutni_datum;
return year(trenutni_datum) - year(p_datum);
end//
DELIMITER ;

-- Poziv funkcije

-- select ime, prezime, radno_mjesto, godina_u_firmi(datum_zaposlenja) as "Godina u firmi" from zaposlenik;

-- Napravi proceduru koja će za vozila koja su na prodaji a imaju više od 200000 kilometara i starija su od 15 godina,
-- promijeniti dostupnost u "NE" (vozila idu u rashod)

delimiter //
create procedure stari_auti_puno_kilometara ()
begin
update auto
set dostupnost = "NE"
where year(now()) - year(godina_proizvodnje) > 15
and kilometraza > 200000
and servis_prodaja = "P"
and dostupnost = "DA";
end//
delimiter ;

-- poziv PROCEDURE
-- call stari_auti_puno_kilometara();
-- select * from auto;

-- Napravi okidač koji za postojećeg klijenta (kupca) smanjuje cijenu novog vozila kojeg je kupio/la za 10%
DELIMITER //
CREATE TRIGGER popust_10
BEFORE INSERT ON racun_prodaje
FOR EACH ROW
BEGIN
declare br_klijenata integer;
select count(id) into br_klijenata
from racun_prodaje
where id_klijent = new.id_klijent;
if br_klijenata > 0 then
set new.cijena = new.cijena - (new.cijena * 0.1);
end if;
END//
DELIMITER ;

-- INSERT INTO racun_prodaje VALUES (31, 4, 96, 1, 31, "2022-04-04 00:00:00", 121320.53957275549);

-- select * from racun_prodaje;

-- okidač radi, cijena vozila na računu je umanjena za 10%

-- Napravi okidač kojim će se zabraniti izmjena datuma računa prodaje (sa porukom greške)

DELIMITER //
CREATE TRIGGER datum_racuna
BEFORE UPDATE ON racun_prodaje
FOR EACH ROW
BEGIN
if old.datum != new.datum then
signal sqlstate '40003'
set message_text = "Datum računa nije moguće mijenjati!";
end if;
end//
DELIMITER ;

-- drop trigger datum_racuna;

-- Napravi okidač koji će provjeriti upisanu dostupnu količinu u stavku_dio na sljedeći način:
-- ako je upisana količina manja od nula, automatski dostupnu_kolicinu staviti na vrijednost 0.
-- ako je upisana količina veća od 100 izbaciti će grešku sa porukom: "Nije moguće u inventaru imati više od 100 komada pojedinog artikla"

DELIMITER //
CREATE TRIGGER bi_dio_kolicina
BEFORE INSERT ON stavka_dio
FOR EACH ROW
BEGIN
if new.dostupna_kolicina > 100 then
signal sqlstate '40004'
set message_text = "Nije moguće u inventaru imati više od 100 komada pojedinog artikla";
elseif new.dostupna_kolicina <= 0 then
set new.dostupna_kolicina = 0;
end if;
end//
DELIMITER ;

 -- drop trigger bi_dio_kolicina;

 -- DARJAN KRAJ


-- TIN FUNKCIJE, PROCEDURE I OKIDACI
-- FUNKCIJE ZA ODREĐIVANJE CIJENE PRODANIH AUTOMOBILA

-- Funkcija koja vraca namjmanju cijenu u tablici racun_prodaje
DELIMITER //
CREATE FUNCTION min_cijena() RETURNS INTEGER
DETERMINISTIC
BEGIN

RETURN (SELECT MIN(cijena) FROM racun_prodaje);

END//
DELIMITER ;

-- Funkcija koja vraca najvecu cijenu u tablici racun_prodaje
DELIMITER //
CREATE FUNCTION max_cijena() RETURNS INTEGER
DETERMINISTIC
BEGIN

RETURN (SELECT MAX(cijena) FROM racun_prodaje);

END//
DELIMITER ;

-- Funkcija koja vraca raspon cijena u tablici racun_prodaje
DELIMITER //
CREATE FUNCTION raspon_cijena() RETURNS INTEGER
DETERMINISTIC
BEGIN

RETURN ((SELECT MAX(cijena) FROM racun_prodaje) - (SELECT MIN(cijena) FROM racun_prodaje));

END//
DELIMITER ;

-- TRIGGER koji daje klijentima koji su ujedno zaposlenici popust u visini od jedne njihove place
DELIMITER //
CREATE TRIGGER popust_za_zaposlenike_u_visini_jedne_place
BEFORE INSERT ON racun_prodaje
FOR EACH ROW
BEGIN
DECLARE br_zaposlenika INTEGER;
DECLARE z_placa NUMERIC(8,2);
DECLARE klijent_oib VARCHAR(20);

-- određivanje OIB-a
SELECT oib INTO klijent_oib
FROM klijent WHERE id = new.id_klijent;

-- prebrojavanje zaposlenika sa oibom klijenta
SELECT count(*) INTO br_zaposlenika
FROM zaposlenik
WHERE oib = klijent_oib;

-- (vrijednost veca od 0 znaci klijent je ujedno i zaposlenik)
IF br_zaposlenika > 0 THEN
	-- dobivanje place zaposlenika
	SELECT placa INTO z_placa
	FROM zaposlenik
    WHERE oib = klijent_oib;

    -- ako je cijena umanjena za placu veca od nule oduzmi, inace stavi na nulu (sprijecavamo negativne vrijednosti cijene)
    IF new.cijena - z_placa >= 0 THEN
		SET new.cijena = new.cijena - z_placa;
	ELSE SET new.cijena = 0;
	END IF;
END IF;

END//
DELIMITER ;

-- TRIGGER koji provjerava datum prodaje automobila i datum zaposlenja zaposlenika
DELIMITER //
CREATE TRIGGER datum_prodaja_zaposlenje
BEFORE INSERT ON racun_prodaje
FOR EACH ROW
BEGIN
DECLARE d_zaposlenja,d_prodaje DATE;

-- određivanje datuma zaposlenja
SELECT datum_zaposlenja INTO d_zaposlenja
FROM zaposlenik WHERE id = new.id_zaposlenik;


IF d_zaposlenja > new.datum THEN
	SIGNAL SQLSTATE '40000'
	SET MESSAGE_TEXT = 'Datum zaposlenja je nakon datuma kreiranja računa!';
END IF;

END//
DELIMITER ;

-- TRIGGER koji provjerava da datum prodaje automobila nije veći od trenutnog datuma
DELIMITER //
CREATE TRIGGER datum_prodaje
BEFORE INSERT ON racun_prodaje
FOR EACH ROW
BEGIN
DECLARE d_prodaje DATE;



IF new.datum > (SELECT NOW() FROM DUAL) THEN
	SIGNAL SQLSTATE '40001'
	SET MESSAGE_TEXT = 'Datum kreiranja računa je veći od trenutnog datuma!';
END IF;

END//
DELIMITER ;

-- Procedura za ažuriranje cijene svih dijelova
-- prihvaca i negativne postotke npr. -15 ili 15
DELIMITER //
CREATE PROCEDURE azuriraj_cijene_dijelova(postotak DECIMAL(8, 2))
BEGIN
UPDATE stavka_dio
SET nabavna_cijena = nabavna_cijena + nabavna_cijena * (postotak/100);
END //
DELIMITER ;

-- CALL azuriraj_cijene_dijelova(-15); oduzima 15%  nabavne cijene svih djelova

-- Procedura za ažuriranje dostupne količine pojedinog dijela prema serijskom broju
-- prihvaca i negativne kolicine npr. -15 ili 15
DELIMITER //
CREATE PROCEDURE azuriraj_dostupnu_kolicinu_dijela(p_serijski_broj VARCHAR(20), p_kolicina INTEGER)
BEGIN
UPDATE stavka_dio
SET dostupna_kolicina = dostupna_kolicina + p_kolicina
WHERE serijski_broj = p_serijski_broj;
END //
DELIMITER ;

-- CALL azuriraj_dostupnu_kolicinu_dijela('55032099911',10); dodaje 10 na postojecu vrijednost
-- TIN GOTOVO

-- MARIJA start

DROP PROCEDURE IF EXISTS konverzija_snage_motora;

# konverzija KW u BHP (procedura nad tablicom auto)
DELIMITER //

CREATE PROCEDURE konverzija_snage_motora()
DETERMINISTIC

BEGIN
	UPDATE auto
    SET snaga_motora = snaga_motora * 1.341;
END //

DELIMITER ;

CALL konverzija_snage_motora();
SELECT * FROM auto;

# promjena cijena iz kuna u eure (nad tablicama oprema, racun_prodaje, usluga_servis, stavka_dio)

# procedura koja pronalazi sve tablice koje sadrze atribut cijena

DROP PROCEDURE IF EXISTS get_tables_with_column;
DELIMITER //

CREATE PROCEDURE get_tables_with_column()
BEGIN
	DECLARE done INT DEFAULT FALSE;
	DECLARE naziv VARCHAR(255);
	DECLARE kursor CURSOR FOR
	SELECT DISTINCT c.TABLE_NAME
		FROM INFORMATION_SCHEMA.COLUMNS c
        JOIN INFORMATION_SCHEMA.TABLES t
        ON c.TABLE_NAME = t.TABLE_NAME
        WHERE c.COLUMN_NAME LIKE 'cijena'
        AND t.TABLE_TYPE = 'BASE TABLE';
	
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	OPEN kursor;
    
    petlja: LOOP
    FETCH kursor INTO naziv;
    IF done THEN LEAVE petlja;
    END IF;
    
	SET @sql = CONCAT('UPDATE ', naziv, ' SET cijena = cijena / 7.534');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    END LOOP;
    
    CLOSE kursor;

END//

DELIMITER ;

CALL get_tables_with_column();

SELECT * FROM oprema;


/*
SELECT table_name FROM information_schema.columns
	WHERE column_name = 'cijena';
*/

DROP TRIGGER IF EXISTS datum_rodenja_zaposlenika;
# datum rodenja nesmje biti manji od danas - 18 godina
DELIMITER //
CREATE TRIGGER datum_rodenja_zaposlenika
BEFORE INSERT ON zaposlenik
FOR EACH ROW
BEGIN
DECLARE razlika DATE;

SET razlika = NOW()-INTERVAL 18 YEAR;

IF new.datum_rodenja > razlika THEN
	SIGNAL SQLSTATE '49000'
	SET MESSAGE_TEXT = 'Zaposlenik nije punoljetan!';
END IF;

END//
DELIMITER ;

-- INSERT INTO zaposlenik VALUES(19, "5412610278033", "Matija", "Vuković", "2000-01-15 00:00:00", "Jardasi 23", "Zagreb", "m",
-- "496588144", "2010-07-13 00:00:00", "m.vuković1@yahoo.com", 6073.036628185772, "autoelektricar");

-- SELECT * FROM zaposlenik;

DROP TRIGGER IF EXISTS datum_zaposlenja_zaposlenika;
# datum zaposlenja nesmje biti manji od trenutnog
DELIMITER //
CREATE TRIGGER datum_zaposlenja_zaposlenika
BEFORE INSERT ON zaposlenik
FOR EACH ROW
BEGIN

IF new.datum_zaposlenja < NOW() THEN
	SIGNAL SQLSTATE '49001'
	SET MESSAGE_TEXT = 'Neispravan datum zaposlenja!';
END IF;

END//
DELIMITER ;

-- DELETE FROM zaposlenik WHERE id = 19;
-- INSERT INTO zaposlenik VALUES(19, "5412610278033", "Matija", "Vuković", "2000-01-15 00:00:00", "Jardasi 23", "Zagreb", "m", 
-- "496588144", "2023-07-13 00:00:00", "m.vuković1@yahoo.com", 6073.036628185772, "autoelektricar");

-- SELECT * FROM zaposlenik;

DROP TRIGGER IF EXISTS  godina_proizvodnje_automobila;
# godina proizvodnje automobila nesmje biti veća od trenutne
DELIMITER //
CREATE TRIGGER godina_proizvodnje_automobila
BEFORE INSERT ON auto
FOR EACH ROW
BEGIN

IF YEAR(new.godina_proizvodnje) > YEAR(NOW()) THEN
	SIGNAL SQLSTATE '49002'
	SET MESSAGE_TEXT = 'Neispravna godina proizvodnje!';
END IF;

END//
DELIMITER ;

-- DELETE FROM auto WHERE id=1299;
-- INSERT INTO auto VALUES (1299, "L76FPA95UU1WGKKVKM", "BMW", "760LI", "crvena", STR_TO_DATE("2024-01-01", "%Y-%m-%d"), "NE", "111", "159384", "benzinski","P");
-- SELECT * FROM auto;


-- MARIJA end

-- ----------------------------------------------NOEL--------------------------------------------------------
-- procedura za prihod godine servisa
-- DROP PROCEDURE prihod_godine_servisa

DELIMITER //
CREATE PROCEDURE prihod_godine_servisa(IN godina INT ,OUT koristeni_dijelovi INTEGER, OUT prihod_servisa DECIMAL(12,2))
BEGIN
	
    SELECT SUM((IFNULL(cijena_dijelova, 0)+IFNULL(cijena_servisa, 0))) INTO prihod_servisa
	FROM cijena__dijelova cd, cijena__servisa cs
	WHERE cd.id_narudzbenica=cs.id_narudzbenica AND YEAR(datum_povratka)=godina
	GROUP BY YEAR(datum_povratka);
    
    SELECT COUNT(id_narudzbenica) INTO koristeni_dijelovi
	FROM cijena__servisa
	WHERE YEAR(datum_povratka)=godina
	GROUP BY YEAR(datum_povratka);
    
END //
DELIMITER ;

CALL prihod_godine_servisa(2022,@koristeni_dijelovi, @prihod_servisa);
SELECT @koristeni_dijelovi, @prihod_servisa FROM DUAL;
-----------------------------------------------------------------------------------------------------------------------
-- procedura za prihod godine prodaje
-- DROP PROCEDURE prihod_godine_prodaja

DELIMITER //
CREATE PROCEDURE prihod_godine_prodaja(IN godina INT,OUT kolicina_prodaje INTEGER, OUT prihod_prodaje DECIMAL(12,2))
BEGIN

	SELECT SUM(cijena), COUNT(id) INTO prihod_prodaje, kolicina_prodaje
	FROM racun_prodaje
	WHERE YEAR(datum)=godina;
    
  
END //
DELIMITER ;

CALL prihod_godine_prodaja(2022,@kolicina_prodaje, @prihod_prodaje);
SELECT @kolicina_prodaje, @prihod_prodaje FROM DUAL;

--------------------------------------------------------------------------------------------------------
-- procedura za ukupan prihod godine
-- DROP PROCEDURE prihod_godine;

DELIMITER //
CREATE PROCEDURE prihod_godine(IN godina INT,OUT uk_kolicina INTEGER, OUT uk_prihod_godine DECIMAL(12,2))
BEGIN
	
    DECLARE servis_prihodi, prodaja_prihodi DECIMAL(12,2);
    DECLARE servis_kolicina, prodaja_kolicina INTEGER;

	CALL prihod_godine_prodaja(godina,@brprodstav, @promet);
	SELECT @promet,@brprodstav INTO prodaja_prihodi, prodaja_kolicina FROM DUAL;
    
    CALL prihod_godine_servisa(godina,@br_prod, @promets);
	SELECT @promets,@br_prod INTO servis_prihodi, servis_kolicina FROM DUAL;
    
    SET uk_kolicina= (IFNULL(prodaja_kolicina, 0))+(IFNULL(servis_kolicina, 0));
    SET uk_prihod_godine=(IFNULL(prodaja_prihodi, 0))+(IFNULL(servis_prihodi, 0));

END //
DELIMITER ;

CALL prihod_godine(2022,@uk_kolicina, @uk_prihod_godine);
SELECT @uk_kolicina, @uk_prihod_godine FROM DUAL;

-----------------------------------------------------------------------------------
-- procedura za rashod godine placa
-- DROP PROCEDURE rashod_godine_placa

DELIMITER //
CREATE PROCEDURE rashod_godine_placa( OUT ukupni_trosak_placa DECIMAL(12,2))
BEGIN

SELECT SUM(placa*12) INTO ukupni_trosak_placa 
FROM zaposlenik;

  
END //
DELIMITER ;

CALL rashod_godine_placa(@ukupni_trosak_placa);
SELECT @ukupni_trosak_placa;

-----------------------------------------------------------------------------------
-- procedura za rashod godine dijelova
-- DROP PROCEDURE rashod_godine_dijelova

DELIMITER //
CREATE PROCEDURE rashod_godine_dijelova( OUT ukupni_trosak_dijelova DECIMAL(12,2))
BEGIN

SELECT SUM((nabavna_cijena*dostupna_kolicina)) INTO ukupni_trosak_dijelova
FROM stavka_dio;

  
END //
DELIMITER ;

CALL rashod_godine_dijelova(@ukupni_trosak_dijelova);
SELECT @ukupni_trosak_dijelova;

-----------------------------------------------------------------------------------
-- procedura za ukupni rashod godine 
-- DROP PROCEDURE rashod_godine

DELIMITER //
CREATE PROCEDURE rashod_godine(OUT ukupan_rashod DECIMAL(12,2))
BEGIN

DECLARE uk_rashod_placa DECIMAL(12,2);
DECLARE uk_rashod_dijelova DECIMAL(12,2);

CALL rashod_godine_placa(@ukupni_trosak_placa);
SELECT @ukupni_trosak_placa INTO uk_rashod_placa;

CALL rashod_godine_dijelova(@ukupni_trosak_dijelova);
SELECT @ukupni_trosak_dijelova INTO uk_rashod_dijelova;

SET ukupan_rashod = (uk_rashod_dijelova)+(uk_rashod_placa);

END //
DELIMITER ;

CALL rashod_godine(@ukupan_rashod);
SELECT @ukupan_rashod;

---------------------------------------------------------------------
-- procedura za dobit u godini
-- DROP PROCEDURE dobit_godine

DELIMITER //
CREATE PROCEDURE dobit_godine(OUT ukupan_dobit_godine DECIMAL(12,2))
BEGIN

DECLARE ukupan_prihod_godine DECIMAL(12,2);
DECLARE ukupan_rashod_godine DECIMAL(12,2);

CALL prihod_godine(2022,@uk_kolicina, @uk_prihod_godine);
SELECT @uk_prihod_godine  INTO ukupan_prihod_godine;

CALL rashod_godine(@ukupan_rashod);
SELECT @ukupan_rashod INTO ukupan_rashod_godine;

SET ukupan_dobit_godine = (ukupan_prihod_godine)-(ukupan_rashod_godine);

END //
DELIMITER ;

CALL dobit_godine(@ukupan_dobit_godine);
SELECT @ukupan_dobit_godine;

-- --------------------------------------------KRAJ--------------------------------------------------


