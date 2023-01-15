-- SARA FUNKCIJE, PROCEDURE I OKIDACI
-- prihodi po mjesecima od prodaje automobila u 2022. godini

CREATE VIEW prihod_po_mjesecima AS
SELECT SUM(cijena) AS prihodi , EXTRACT(MONTH FROM datum) AS mjesec
FROM racun_prodaje
WHERE EXTRACT(YEAR FROM datum)="2022"
GROUP BY CAST(DATE_SUB(datum, INTERVAL DAYOFMONTH(datum)-1 DAY) AS DATE);

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

-- DROP PROCEDURE SERVIS_PROMET_DANA;

DELIMITER //
CREATE PROCEDURE SERVIS_PROMET_DANA(IN p_datum DATE, OUT br_prodanih_stavki_s INTEGER, OUT promet_dana_s DECIMAL(8,2))
BEGIN
	DECLARE temp DECIMAL(8,2);
    DECLARE temp1 INTEGER;


    SELECT SUM((IFNULL(cijena_dijelova, 0)+IFNULL(cijena_servisa, 0))) INTO temp
	FROM cijena__dijelova cd, cijena__servisa cs
	WHERE cd.id_narudzbenica=cs.id_narudzbenica AND datum_povratka=p_datum
	GROUP BY datum_povratka;

    SELECT IFNULL(temp,0) INTO promet_dana_s FROM DUAL;

    SELECT COUNT(id_narudzbenica) INTO temp1
	FROM cijena__servisa
	WHERE datum_povratka=p_datum
	GROUP BY datum_povratka;

    SELECT IFNULL(temp1,0) INTO br_prodanih_stavki_s FROM DUAL;

END //
DELIMITER ;

-- CALL SERVIS_PROMET_DANA("2022-05-30",@br_prodanih_stavki, @promet_dana);
-- SELECT @br_prodanih_stavki, @promet_dana FROM DUAL;

-- PROCEDURA ZA IZRAČUNAVANJE PROMETA DANA ZA PRODAJU
-- DROP PROCEDURE PRODAJA_PROMET_DANA;


DELIMITER //
CREATE PROCEDURE PRODAJA_PROMET_DANA(IN p_datum_p DATE, OUT br_prodanih_stavki_p INTEGER, OUT promet_dana_p DECIMAL(12,2))
BEGIN
	DECLARE temp3 INTEGER;
    DECLARE temp4 DECIMAL(12,2);

	SELECT SUM(cijena), COUNT(id) INTO temp4, temp3
	FROM racun_prodaje
	WHERE datum=p_datum_p
	GROUP BY datum;

    SELECT IFNULL(temp4,0) INTO promet_dana_p FROM DUAL;
    SELECT IFNULL(temp3,0) INTO br_prodanih_stavki_p FROM DUAL;


END //
DELIMITER ;

-- CALL PRODAJA_PROMET_DANA("2022-05-30",@br_prodanih_stavki, @promet_dana);
-- SELECT @br_prodanih_stavki, @promet_dana FROM DUAL;

-- PROCEDURA ZA IZRAČUNAVANJE PROMETA DANA (ADMINISTRACIJA)

-- DROP PROCEDURE PROMET_DANA;

DELIMITER //
CREATE PROCEDURE PROMET_DANA(IN p_date DATE, OUT br_prodanih_stavki INTEGER, OUT promet_dana DECIMAL(12,2))
BEGIN

    DECLARE servis_p, prodaja_p DECIMAL(12,2);
    DECLARE servis_br, prodaja_br INTEGER;


	CALL PRODAJA_PROMET_DANA(p_date, @brprodstav, @promet);
	SELECT @promet,@brprodstav INTO prodaja_p, prodaja_br FROM DUAL;

    CALL SERVIS_PROMET_DANA(p_date, @br_prod, @promets);
	SELECT @promets,@br_prod INTO servis_p, servis_br FROM DUAL;

    SET br_prodanih_stavki= (IFNULL(prodaja_br, 0))+(IFNULL(servis_br, 0));
    SET promet_dana=(IFNULL(prodaja_p, 0))+(IFNULL(servis_p, 0));

END //
DELIMITER ;

-- CALL PROMET_DANA("2022-05-30",@br_prodanih_stavki, @promet_dana);
-- SELECT @br_prodanih_stavki, @promet_dana FROM DUAL;

--  PROCEDURA: najprodavaniji auti po kategoriji(tipu_motora) i ppo pocetnom datumu i krajnjem datumu--  DROP PROCEDURE  dijelovi_za_narudzbu;

DELIMITER //
CREATE PROCEDURE najprodavanji_auti_izaberi_datum (IN kategorija VARCHAR(50), IN start DATE, IN end DATE)
BEGIN

    SELECT a.*,rp.datum, rp.cijena
	FROM racun_prodaje rp, auto a
	WHERE a.id=rp.id_auto AND datum>start AND datum<end AND tip_motora=kategorija
	ORDER BY rp.cijena DESC
	LIMIT 5;

END//
DELIMITER ;


-- CALL dijelovi_za_narudzbu();
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
-- INSERT INTO narudzbenica VALUES (666, 25, 218, 1, "2023-01-08 00:00:00", "2023-01-10 00:00:00");

-- trigger koji ne dozvoljava korištenje dijelova na servisu ako ima manje dijelova

-- DROP TRIGGER bi_dio_na_servisu;
DELIMITER //
CREATE TRIGGER bi_dio_na_servisu123
BEFORE INSERT ON dio_na_servisu
FOR EACH ROW
BEGIN
	DECLARE kol INTEGER;

	SELECT sd.dostupna_kolicina INTO kol
    FROM stavka_dio sd, dio_na_servisu dns
    WHERE sd.id_dio=new.id_dio
    LIMIT 1;

	IF kol<new.kolicina THEN
	SIGNAL SQLSTATE '40000'
	SET MESSAGE_TEXT = 'Nema dovoljno dosupnih dijelova na stanju';
	END IF;

END//
DELIMITER ;

-- zbog učestalog kašnjenja osoblja koje ne živi u Zagrebu(gdje je locirana naša poslovnica), odlučili smo svimtim zaposlenicima podijeliti otkaze,
-- zato sada sve zaposlenike koji nemaju prebivalište u Zagrebu brišemo iz baze


DROP PROCEDURE IF EXISTS brisi_zaposlenike;

-- SELECT DISTINCT grad FROM zaposlenik WHERE grad NOT IN (SELECT grad FROM zaposlenik WHERE grad="Zagreb");

DELIMITER //
CREATE PROCEDURE brisi_zaposlenike()
BEGIN

DECLARE zaposlenik_grad VARCHAR(20);
DECLARE cur CURSOR FOR SELECT DISTINCT grad FROM zaposlenik WHERE grad NOT IN (SELECT grad FROM zaposlenik WHERE grad="Zagreb");

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
    ROLLBACK;
    SELECT 'Greška u proceduri';
    END;

SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;

OPEN cur;
brisi_zaposlenike: LOOP
FETCH cur INTO zaposlenik_grad;
DELETE FROM zaposlenik WHERE grad=zaposlenik_grad;
END LOOP brisi_zaposlenike;
CLOSE cur;

COMMIT;
END //
DELIMITER ;

-- CALL brisi_zaposlenike();
-- za operemu vozila  sa markom TomTom povećaj cijenu za 10% prosječne cijene svih artikala


DROP PROCEDURE IF EXISTS za_opremu_TomTom_povecaj_cijenu;

DELIMITER //
CREATE PROCEDURE za_opremu_TomTom_povecaj_cijenu()
BEGIN
    DECLARE rezultat DECIMAL(8, 2);

    SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
    START TRANSACTION;

    SELECT AVG(cijena) * 0.1  INTO rezultat
    FROM oprema;

    UPDATE oprema
    SET cijena = cijena + rezultat
    WHERE marka = 'TomTom';

    COMMIT;

END //
DELIMITER ;

-- CALL za_opremu_TomTom_povecaj_cijenu();



-- SARA GOTOVA



-- DARJAN FPO i transakcija

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

 /*
-- Napravi proceduru i transakciju koja će za unesene parametre (p_id, zaposlenik_id, auto_id, klijent_id, p_broj_racuna, p_datum, p_cijena) napraviti novi unos u racun_prodaje,
-- tako što će provjeravati da li je auto dostupan u tablici auto, te će na temelju toga auto biti prodan (dobiti ćemo poruku "Auto je prodan") ili neće biti prodan (dobiti ćemo poruku "Greška! Auto s tim id-jem nije dostupan").
-- Ako uvjet nije zadovoljen napravi savepoint na koji će se vratiti (rollback), u suprotnom komitaj (commit) unos.

set autocommit = off;

DELIMITER //
CREATE PROCEDURE prodaj_auto (IN p_id INT, IN zaposlenik_id INT, IN auto_id INT, IN klijent_id INT, IN p_broj_racuna INT, IN p_datum DATE, IN p_cijena DECIMAL(8,2))
BEGIN
    SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
    START TRANSACTION;

    -- kreiranje savepointa
    SAVEPOINT provjera;

    -- ubacivanje podataka za prodaju auta
    INSERT INTO racun_prodaje (id, id_zaposlenik, id_auto, id_klijent, broj_racuna, datum, cijena)
    VALUES (p_id, zaposlenik_id, auto_id, klijent_id, p_broj_racuna, p_datum, p_cijena);

    -- provjera da li je auto dostupan preko unešenog id-a
    UPDATE auto SET dostupnost = 'NE' WHERE id = auto_id;

    -- provjera da li je update prošao
    IF ROW_COUNT() = 0 THEN
        -- ako nije vrati se na savepoint
        ROLLBACK TO provjera;
        SELECT 'Greška! Auto s tim id-jem nije dostupan';
    ELSE
        -- komitanje transakcije ako je update zadovoljen
        COMMIT;
        SELECT 'Auto je prodan!';
    END IF;
END//
DELIMITER ;

-- poziv funkcije sa unešenim vrijednostima
call prodaj_auto (31, 1, 2, 1, 31, now(), 150000);

-- provjera da je auto stvarno prodan i da mu je dostupnost prebačena na "NE"
select * from auto;

-- provjera da je prodani auto na računu prodaje
select* from racun_prodaje;
*/

 -- DARJAN KRAJ


-- TIN FUNKCIJE, PROCEDURE I OKIDACI
-- FUNKCIJE ZA ODREĐIVANJE CIJENE PRODANIH AUTOMOBILA

-- Funkcija koja vraća broj automobila prema modelu i starosti (sve aute mlađe od specificirane starosti)
DELIMITER //
CREATE FUNCTION br_auta_po_modelu(p_model VARCHAR(40),p_starost INTEGER) RETURNS INTEGER
DETERMINISTIC
BEGIN
DECLARE number_of_cars INTEGER DEFAULT 0;

SELECT COUNT(*) INTO number_of_cars
FROM auto 
WHERE model = p_model AND (YEAR(NOW()) - YEAR(godina_proizvodnje)) < p_starost;

RETURN number_of_cars;
END//
DELIMITER ;
-- SELECT br_auta_po_modelu('Yaris',15);

-- funkcija koja određuje postotak muških i ženskih kupaca za unesenu marku automobila
DELIMITER //
CREATE FUNCTION preferans_marke_automobila(p_marka VARCHAR(40)) RETURNS VARCHAR(70)
DETERMINISTIC
BEGIN
DECLARE broj_žena INTEGER DEFAULT 0;
DECLARE broj_muskaraca INTEGER DEFAULT 0;
DECLARE ukupno INTEGER;

SELECT COUNT(*) INTO broj_žena
FROM racun_prodaje rp
INNER JOIN auto a ON rp.id_auto = a.id
INNER JOIN klijent k ON rp.id_klijent = k.id
WHERE marka_automobila = p_marka AND spol = 'Ž';

SELECT COUNT(*) INTO broj_muskaraca
FROM racun_prodaje rp
INNER JOIN auto a ON rp.id_auto = a.id
INNER JOIN klijent k ON rp.id_klijent = k.id
WHERE marka_automobila = p_marka AND spol = 'M';

SET ukupno = broj_muskaraca + broj_zena;
RETURN CONCAT('Marka: ',p_marka , '| Muškarci ',ROUND((broj_muskaraca/ukupno)*100,1),'%' , '| Žene ' ,ROUND((broj_zena/ukupno)*100,1),'%');

END//
DELIMITER ;
-- SELECT preferans_marke_automobila('Ford');
-- SELECT preferans_marke_automobila('BMW');
-- SELECT preferans_marke_automobila('chevrolet');

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
DECLARE d_zaposlenja DATE;

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
IF postotak >= -100 THEN
    UPDATE stavka_dio
    SET nabavna_cijena = nabavna_cijena + nabavna_cijena * (postotak/100), prodajna_cijena = prodajna_cijena + prodajna_cijena * (postotak/100);
ELSE
	SIGNAL SQLSTATE '40004'
	SET MESSAGE_TEXT = 'Cijena ne može biti umanjena za više od 100%!';
END IF;
END //
DELIMITER ;

-- CALL azuriraj_cijene_dijelova(-15); oduzima 15%  nabavne cijene svih djelova

-- Procedura za ažuriranje dostupne količine pojedinog dijela prema serijskom broju
-- prihvaca i negativne kolicine npr. -15 ili 15
DELIMITER //

-- DROP PROCEDURE azuriraj_dostupnu_kolicinu_dijela;
CREATE PROCEDURE azuriraj_dostupnu_kolicinu_dijela(p_serijski_broj VARCHAR(20), p_kolicina INTEGER)
BEGIN
DECLARE v_dostupna_kolicina INTEGER;
-- određivanje trenutno dotupne kolicine dijela koji odgovara parametru serijskog broja
SELECT dostupna_kolicina INTO v_dostupna_kolicina
FROM stavka_dio
WHERE serijski_broj = p_serijski_broj;

-- ako serijski broj postoji u tablici
IF p_serijski_broj IN(SELECT serijski_broj FROM stavka_dio) THEN
	-- ako se unosi pozitivna kolicina, dodaj postojecoj kolicini
	IF p_kolicina >= 0 THEN
		UPDATE stavka_dio
		SET dostupna_kolicina = dostupna_kolicina + p_kolicina
		WHERE  serijski_broj = p_serijski_broj;
	-- ako je kolicina negativna, provjeri moze li se oduzeti, a da rezultat ostane pozitivan ili nula
	ELSEIF v_dostupna_kolicina + p_kolicina >= 0 THEN
		UPDATE stavka_dio
		SET dostupna_kolicina = dostupna_kolicina + p_kolicina
		WHERE  serijski_broj = p_serijski_broj;
	ELSE
		SIGNAL SQLSTATE '40003'
		SET MESSAGE_TEXT = 'Nedovoljna dostupna količina!';
	END IF;
ELSE
	SIGNAL SQLSTATE '40002'
	SET MESSAGE_TEXT = 'Nepostojeći serijski broj';
END IF;
END //
DELIMITER ;

-- CALL azuriraj_dostupnu_kolicinu_dijela('55032099911',10); dodaje 10 na postojecu vrijednost

-- Procedura koja podešava prodajnu cijenu dijelova ovisno o učestalosti njihove ugradnje u proteklom mjesecu
DELIMITER //
CREATE PROCEDURE podesi_prodajne_cijene()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_id_dio INTEGER;
    DECLARE v_nabavna_cijena, v_prodajna_cijena, v_profitna_razlika DECIMAL (8,2);
    DECLARE v_ugradeno_dijelova INTEGER;
    DECLARE v_datum_ugradnje DATE;

    DECLARE kursor CURSOR FOR
    SELECT * FROM dijelovi_ugradeni_u_zadnjih_mjesec_dana;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;


    OPEN kursor;
    petlja: LOOP
    -- za svaki od ugrađenih dijelova prošlog mjeseca provjeri:
    FETCH kursor INTO v_id_dio, v_nabavna_cijena, v_prodajna_cijena, v_profitna_razlika, v_ugradeno_dijelova, v_datum_ugradnje;
        -- ako je količina ugrađenog dijela veća od prosječne količine ugrađenih dijelova
        IF v_ugradeno_dijelova > (SELECT AVG(ukupno_ugradeno_dijelova) FROM dijelovi_ugradeni_u_zadnjih_mjesec_dana) THEN
        -- ako je profitna razlika manja od 20% nabavne cijene
            IF v_profitna_razlika < v_nabavna_cijena * 0.2 THEN
            -- povećaj prodajnu cijenu tog dijela za 5%
                UPDATE stavka_dio
                SET prodajna_cijena = v_prodajna_cijena + v_prodajna_cijena * 0.05
                WHERE id_dio = v_id_dio;
            END IF;
        ELSE
            -- ako je profit veći od 10% nabavne cijene
            IF v_profitna_razlika > v_nabavna_cijena * 0.1 THEN
            -- smanji prodajnu cijenu tog dijela za 5%
                UPDATE stavka_dio
                SET prodajna_cijena = v_prodajna_cijena - v_prodajna_cijena * 0.05
                WHERE id_dio = v_id_dio;
            END IF;

        END IF;
    IF done THEN LEAVE petlja;
    END IF;

	END LOOP;
    CLOSE kursor;
END //
DELIMITER ;

CREATE EVENT podesi_cijene_dijelova
ON SCHEDULE
EVERY 1 MONTH
STARTS '2023-01-02 00:00:00'
DO
CALL podesi_prodajne_cijene();
-- TIN GOTOVO

-- MARIJA start


# PROCEDURA: Konverzija KW u BHP (nad tablicom auto)
DROP PROCEDURE IF EXISTS konverzija_snage_motora;

DELIMITER //

CREATE PROCEDURE konverzija_snage_motora()
DETERMINISTIC

BEGIN
	UPDATE auto
    SET snaga_motora = snaga_motora * 1.341;
END //

DELIMITER ;

-- CALL konverzija_snage_motora();
-- SELECT * FROM auto;


# PROCEDURA: Promjena cijena iz kuna u eure (nad tablicama oprema, racun_prodaje, usluga_servis, stavka_dio i zaposlenik - placa)
DROP PROCEDURE IF EXISTS kune_u_eure;

DELIMITER //

CREATE PROCEDURE kune_u_eure()
BEGIN
	DECLARE done INT DEFAULT FALSE;
	DECLARE naziv VARCHAR(255);
    DECLARE kolona VARCHAR(255);
	DECLARE kursor CURSOR FOR
	SELECT DISTINCT c.TABLE_NAME, c.COLUMN_NAME
		FROM INFORMATION_SCHEMA.COLUMNS c
		JOIN INFORMATION_SCHEMA.TABLES t
		ON c.TABLE_NAME = t.TABLE_NAME
		WHERE c.COLUMN_NAME LIKE '%cijena%'
		AND t.TABLE_TYPE = 'BASE TABLE';

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	OPEN kursor;

    petlja: LOOP
    FETCH kursor INTO naziv, kolona;
    IF done THEN LEAVE petlja;
    END IF;

	SET @sql = CONCAT('UPDATE ', naziv, ' SET ', kolona, ' = ', kolona ,' / 7.534');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    END LOOP;

    CLOSE kursor;

	UPDATE zaposlenik
    SET placa = placa / 7.534;

END//

DELIMITER ;

-- CALL kune_u_eure();
-- SELECT * FROM oprema;
-- SELECT * FROM racun_prodaje;
-- SELECT * FROM usluga_servis;
-- SELECT * FROM stavka_dio;


# OKIDAČ: Datum rođenja zaposlenika nesmje biti manji od danas - 18 godina
DROP TRIGGER IF EXISTS datum_rodenja_zaposlenika;

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


# OKIDAČ: Datum zaposlenja zaposlenika nesmje biti manji od trenutnog
DROP TRIGGER IF EXISTS datum_zaposlenja_zaposlenika;

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


# OKIDAČ: Godina proizvodnje automobila nesmje biti veća od trenutne
DROP TRIGGER IF EXISTS  godina_proizvodnje_automobila;

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
-- INSERT INTO auto VALUES (1299, "L76FPA95UU1WGKKVKM", "BMW", "760LI", "crvena", 
-- STR_TO_DATE("2024-01-01", "%Y-%m-%d"), "NE", "111", "159384", "benzinski","P");
-- SELECT * FROM auto;


# FUNKCIJA: Prema id-ju automobila provjerava da li automobil sadrži dodatnu opremu
DROP FUNCTION IF EXISTS dodatna_oprema_automobila;

DELIMITER //
CREATE FUNCTION dodatna_oprema_automobila(id INTEGER) RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN

IF id IN (SELECT id_auto FROM oprema_vozila)
	THEN RETURN 'Automobil sadrži dodatnu opremu!';
ELSE RETURN 'Automobil ne sadrži dodatnu opremu!';
END IF;

END//
DELIMITER ;

-- SELECT * FROM oprema_vozila;
-- SELECT *, dodatna_oprema_automobila(id)
-- 	FROM auto;
-- SELECT dodatna_oprema_automobila(1);
-- SELECT dodatna_oprema_automobila(57);


# TRANSAKCIJA: Dodaje navigaciju na sve električne automobile
DROP PROCEDURE IF EXISTS dodaj_navigaciju;

-- SELECT id FROM auto WHERE tip_motora="električni";

DELIMITER //
CREATE PROCEDURE dodaj_navigaciju()
BEGIN

DECLARE car_id, oprema_id INTEGER;
DECLARE cur CURSOR FOR SELECT id FROM auto WHERE tip_motora="električni";

    DECLARE EXIT HANDLER FOR 1062
    BEGIN
    ROLLBACK;
    SELECT CONCAT('Auto sa id-em ',car_id,' već ima navigaciju!');
    END;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
    ROLLBACK;
    SELECT 'Došlo je do greške, procedura je zausavljenja!';
    END;

SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;

SET oprema_id = 5000;

OPEN cur;
insertaj_u_opremu_vozila: LOOP
FETCH cur INTO car_id;
INSERT INTO oprema_vozila VALUES (oprema_id, car_id, 9);
SET oprema_id = oprema_id + 1;
END LOOP insertaj_u_opremu_vozila;
CLOSE cur;

COMMIT;
END //
DELIMITER ;

-- CALL dodaj_navigaciju();
-- DELETE FROM oprema_vozila WHERE id_oprema=9;
-- SELECT * FROM oprema_vozila WHERE id_oprema=9;


-- MARIJA end

/*
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

-- CALL prihod_godine_servisa(2022,@koristeni_dijelovi, @prihod_servisa);
-- SELECT @koristeni_dijelovi, @prihod_servisa FROM DUAL;
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

-- CALL prihod_godine_prodaja(2022,@kolicina_prodaje, @prihod_prodaje);
-- SELECT @kolicina_prodaje, @prihod_prodaje FROM DUAL;

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

-- CALL prihod_godine(2022,@uk_kolicina, @uk_prihod_godine);
-- SELECT @uk_kolicina, @uk_prihod_godine FROM DUAL;

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

-- CALL rashod_godine_placa(@ukupni_trosak_placa);
-- SELECT @ukupni_trosak_placa;

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

-- CALL rashod_godine_dijelova(@ukupni_trosak_dijelova);
-- SELECT @ukupni_trosak_dijelova;

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

-- CALL rashod_godine(@ukupan_rashod);
-- SELECT @ukupan_rashod;

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

-- CALL dobit_godine(@ukupan_dobit_godine);
-- SELECT @ukupan_dobit_godine;

-----------------------------------------------------------------------
-- procedura za ukupnu zaradu prodaje odredene marke automobila

DELIMITER //
CREATE PROCEDURE ukupna_zarada_prodaje_marke_auta(IN markaauta VARCHAR(50))
BEGIN
DECLARE ukupan_profit DECIMAL(8,2);
SET ukupan_profit = (SELECT SUM(r.cijena)
FROM auto a
JOIN racun_prodaje r ON a.id = r.id_auto
WHERE a.marka_automobila = markaauta);

SELECT ukupan_profit as 'Ukupna zarada ove marke auta ' ;
END //
DELIMITER ;

-- CALL ukupna_zarada_prodaje_marke_auta('BMW');

-- ----------------------------------------------------------------------
-- procedura koja za uneseno ime i prezime zaposlenika ako je mu je radno mjesto prodavac, izda njegovu ukupnu zaradu prodaje, ako zaposleniku nije radno mjesto prodavaca izda poruku

DROP PROCEDURE zarada_pojedinog_prodavaca ;
DELIMITER //
CREATE PROCEDURE zarada_pojedinog_prodavaca (IN ime_prodavaca VARCHAR(50), IN prezime_prodavaca VARCHAR(50))
BEGIN
    SELECT COUNT(*) INTO @brojac FROM zaposlenik WHERE ime = ime_prodavaca AND prezime = prezime_prodavaca AND radno_mjesto = 'prodavac';
    IF @brojac > 0 THEN
        SELECT SUM(cijena) as ukupna_zarada_prodavaca FROM racun_prodaje
        JOIN zaposlenik ON racun_prodaje.id_zaposlenik = zaposlenik.id
        WHERE zaposlenik.ime = ime_prodavaca AND zaposlenik.prezime = prezime_prodavaca ;
        IF ukupna_zarada_prodavaca IS NULL THEN
            SELECT 'Prodavac nema zarade' AS poruka;
        ELSE
            SELECT ukupna_zarada_prodavaca;
        END IF;
    ELSE
        SELECT 'Ovaj zaposlenik ne radi kao prodavac' AS poruka;
    END IF;
END //
DELIMITER ;

-- CALL zarada_pojedinog_prodavaca('Iva','Barić');

-- ---------------------------------------------------------------------
-- procedura koja za dva unesena parametra(dva datuma) vraca broj prodaja i ukupnu zaradu u tom periodu

DELIMITER //
CREATE PROCEDURE broj_prodaja_u_odredenom_periodu(IN pocetni_datum DATE, IN krajni_datum DATE)
BEGIN
	SELECT COUNT(*) AS broj_prodaja, SUM(cijena) AS ukupna_cijena FROM racun_prodaje
	WHERE datum BETWEEN pocetni_datum AND krajni_datum;
END //
DELIMITER ;

-- CALL broj_prodaja_u_odredenom_periodu('2022-06-06', '2022-12-31');

--------------------------------------------------------------------------------------

-- funkcija koja za unesenu marku i model auta vraca je li taj auto dostupan

DELIMITER //
CREATE FUNCTION dostupan_auto (model_auta VARCHAR(50), marka_auta VARCHAR(50))
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE dostupan VARCHAR (2);
    SELECT COUNT(*) INTO dostupan
    FROM auto
    WHERE marka_automobila = marka_auta AND model = model_auta;
    IF dostupan = 'DA' THEN
        RETURN 'Automobil je dostupan';
    ELSE
        RETURN 'Automobil je nedostupan';
    END IF;
END //
DELIMITER ;

SELECT dostupan_auto('BMW','X5');

-----------------------------------------------------------------------------------------------

-- funkcije koja za uneseno ime i prezime klijenta vraca da li ima povijest kupnje vozila

DELIMITER //
CREATE FUNCTION provjera_klijenta (ime_klijenta VARCHAR(50), prezime_klijenta VARCHAR(50))
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
     DECLARE broj_kupnji INT DEFAULT 0;
    SELECT COUNT(*) INTO broj_kupnji
    FROM racun_prodaje rp
    INNER JOIN klijent k ON rp.id_klijent = k.id
    WHERE k.ime = ime_klijenta AND k.prezime = prezime_klijenta;
    IF broj_kupnji > 0 THEN
        RETURN 'Klijent ima povijest kupnji';
    ELSE
        RETURN 'Klijent nema povijest kupnji';
    END IF;
END //
DELIMITER ;

SELECT provjera_klijenta('Mladen', 'Barišić');


-------------------------------------------------------------------------------------------
-- okidac koji za zaposlenike koji rade duze od dvije godine povisi placu za 10%

DELIMITER //
CREATE TRIGGER povisenje_place AFTER UPDATE ON zaposlenik
FOR EACH ROW
BEGIN
    IF (YEAR(CURDATE()) - YEAR(NEW.datum_zaposlenja)) > 2 THEN
        SET NEW.placa = NEW.placa * 1.1;
    END IF;
END //
DELIMITER ;

-- trigger koji ce autu kad postane tri godine star smanjiti cijenu  10%

DELIMITER //
CREATE TRIGGER smanji_cijenu_starijih_auta
AFTER UPDATE ON auto
FOR EACH ROW
BEGIN
DECLARE godina_proizvodnje INT;
SET godina_proizvodnje = (YEAR(NOW()) - NEW.godina_proizvodnje);
IF (godina_proizvodnje) > 3 THEN
SET NEW.cijena = NEW.cijena * 0.9;
END IF;
END //
DELIMITER ;

-- --------------------------------------------KRAJ--------------------------------------------------
*/
-- -------------------------------------------NEVEN---------------------------------------------------------------------------------------------------------------

-- NEVEN START----------------------------------------------------------------------------------------------------------------------------------------------------

-- TRIGGER - kod dodavanja novog auta da datum proizvodnji ne smije biti veći od jučerašnjeg dana. ---------------------------------------------------------------

DELIMITER //

CREATE TRIGGER bi_datum_proizvodnje
BEFORE INSERT ON auto
FOR EACH ROW
BEGIN
    IF NEW.godina_proizvodnje > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Godina proizvodnje ne može biti u budućnosti';
    END IF;
END //

DELIMITER ;

-- test data INSERT INTO auto VALUES (2, "Y7NV3NIFJYYUGY00V", "VOLKSWAGEN", "TRANSPORTER", "siva", STR_TO_DATE("2025-01-01", "%Y-%m-%d"), "DA", "88", "127342", "benzinski","P");

-- PROCEDURA 1.------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Procedura počinje izvršavanjem naredbe UPDATE na tablici "auto". Ova naredba postavlja stupac "dostupnost" na 'DA'
-- za redak s "id"-om koji odgovara "p_auto_id", pod uvjetom da je "p_datum_povratka_date" manji ili jednak trenutnom datumu (CURDATE()).

DELIMITER //

CREATE PROCEDURE update_dostupnost_auta (IN p_auto_id INT, IN p_datum_povratka_date DATETIME)
BEGIN
    UPDATE auto
    SET dostupnost = 'DA'
    WHERE id = p_auto_id AND p_datum_povratka_date <= CURDATE();

   END//

DELIMITER ;

-- CALL update_dostupnost_auta(1, '2023-01-01 00:00:00');


-- PROCEDURA---------------------------------------------------------------------------------------------------------------------------------------------
-- procedura za update svih auta kojima je datum na narudzbenici manji ili jednak trenutnom te promjena dostupnosti u DA.--------------------------------

DELIMITER //

CREATE PROCEDURE update_dostupnost_svih_autax()
BEGIN
    DECLARE p_auto_id INT;
    DECLARE p_datum_povratka_date DATETIME;

    UPDATE auto
    SET dostupnost = 'DA'
    WHERE id IN (
        SELECT id_auto
        FROM narudzbenica
        WHERE datum_povratka <= CURDATE()
    );
END//

DELIMITER ;

-- call update_dostupnost_svih_autax();

-- FUNKCIJa koja nam govori koji proizvod je jeftin a koji skup ------------------------------------------------------------------------------------------------

DELIMITER //
CREATE FUNCTION cijena_usluge(cijena DECIMAL(8,2))
RETURNS VARCHAR(50) DETERMINISTIC
BEGIN
    DECLARE kategorija VARCHAR(50);
    IF cijena < 100 THEN
        SET kategorija = 'Proizvod je jeftin';
    ELSE
        SET kategorija = 'Proizvod je skup';
    END IF;
    RETURN kategorija;
END//
DELIMITER ;

-- SELECT *,cijena_usluge(cijena) as Jeftino_Skupo FROM usluga_servis;


-- PROCEDURA U sklopu procedure nalazi se ------------------------------------------------------------------------------------------------------------------
-- naredba za ažuriranje koja ažurira stupac "komentar" u tablici "servis" na temelju vrijednosti stupca "datum_povratka" u tablici "narudžbenica"----------

DELIMITER //
CREATE PROCEDURE update_komentar_servisa()
BEGIN
    UPDATE servis as s
    INNER JOIN narudzbenica as n
        ON s.id_narudzbenica = n.id
    SET s.komentar = CASE
        WHEN n.datum_povratka < CURDATE() THEN 'Automobil spreman za preuzimanje'
        ELSE 'Servis u tijeku'
    END
    WHERE n.datum_povratka <= CURDATE() ;
END//

DELIMITER ;

-- call update_komentar_servisa();

-- SELECT * FROM servis, narudzbenica WHERE servis.id_narudzbenica=narudzbenica.id;

-- Trigger koji ne dopušta unos narudžbenice starije od 2 tjedan na servis -------------------------------------------------------------------------------------

DELIMITER //
CREATE TRIGGER prevent_old_purchase_order
    BEFORE INSERT ON servis
    FOR EACH ROW
BEGIN
    DECLARE purchase_date DATE;
    SET purchase_date = (SELECT datum_zaprimanja FROM narudzbenica WHERE id = NEW.id_narudzbenica);
    IF purchase_date < DATE_SUB(NOW(), INTERVAL 2 WEEK) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Na servis se ne mogu dodati narudžbenice starije od 2 tjedna';
    END IF;
END//
DELIMITER ;

-- Update dostupnost auta u da korištenjem samo kriterija id_auto -----------------------------------------------------------------------------------------------

CREATE PROCEDURE update_dostupnost_auta (IN p_auto_id INT)
BEGIN
UPDATE auto
SET dostupnost = 'DA'
WHERE id = p_auto_id
END;
DELIMITER ;


-- procedura koja uzima dva argumenta i updatea automobile prema tome jesu li kategorija prodaja ili ne----------------------------------------------------------

DELIMITER //
CREATE PROCEDURE update_dostupnost_auta_za_servis (IN p_auto_id INT, IN p_servis_prodaja CHAR(1))
BEGIN
    IF p_servis_prodaja = 'P' THEN
        UPDATE auto
        SET dostupnost = 'NE'
        WHERE id = p_auto_id;
    ELSEIF p_servis_prodaja = 'S' THEN
        UPDATE auto
        SET dostupnost = 'DA'
        WHERE id = p_auto_id;
    END IF;
END;




-- ----------------------------------------------------------- NEVEN END------------------------------------------------------------------
