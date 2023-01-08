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

-- MARIJA end


-- NEVEN START

-- TRIGGER - kod dodavanja novog auta da datum proizvodnji ne smije biti veći od jučerašnjeg dana.

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

-- PROCEDURA 1.
-- Procedura počinje izvršavanjem naredbe UPDATE na tablici "auto". Ova naredba postavlja stupac "dostupnost" na 'DA' 
-- za redak s "id"-om koji odgovara "p_auto_id", pod uvjetom da je "p_datum_povratka_date" manji ili jednak trenutnom datumu (CURDATE()).
-- Procedura zatim izvršava naredbu SELECT koja dohvaća stupce "id", "model", "dostupnost" i "datum_povratka" iz tablica "auto" i "narudzbenica", spojenih na stupac "id" iz tablica "auto" i stupac "id_auto" iz tablica "narudzbenica". 
-- Naredba SELECT vraća redove gdje je stupac "datum_povratka" manji ili jednak trenutnom datumu.
DELIMITER //

CREATE PROCEDURE update_dostupnost_auta (IN p_auto_id INT, IN p_datum_povratka_date DATETIME)
BEGIN
    UPDATE auto
    SET dostupnost = 'DA'
    WHERE id = p_auto_id AND p_datum_povratka_date <= CURDATE();

    SELECT a.id, a.model,a.dostupnost,n.datum_povratka
    FROM auto as a
        INNER JOIN narudzbenica as n
        ON a.id = n.id_auto
    WHERE n.datum_povratka <= CURDATE();
END//

DELIMITER ;

-- CALL update_dostupnost_auta(1, '2023-01-01 00:00:00');

/*
PROCEDURA 2. 
-- procedura za update svih auta kojima je datum na narudzbenici manji ili jednak trenutnom te promjena dostupnosti u DA. 
-- Izbacuje rezultat svaki put kad promijeni vrijednost
-- u sebi sadrzi prethodnu proceduru

CREATE PROCEDURE update_dostupnost_svih_auta()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE p_auto_id INT;
    DECLARE p_datum_povratka_date DATETIME;

    DECLARE cur CURSOR FOR
        SELECT id_auto, datum_povratka
        FROM narudzbenica;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    REPEAT
        FETCH cur INTO p_auto_id, p_datum_povratka_date;
        IF NOT done THEN
            UPDATE auto
            SET dostupnost = 'DA'
            WHERE id = p_auto_id AND p_datum_povratka_date <= CURDATE();

            SELECT a.id, a.model,a.dostupnost,n.datum_povratka
            FROM auto as a
                INNER JOIN narudzbenica as n
                ON a.id = n.id_auto
            WHERE n.datum_povratka <= CURDATE();
        END IF;
    UNTIL done END REPEAT;

    CLOSE cur;

END//

DELIMITER ;
*/
-- call update_dostupnost_svih_auta();

-- PROCEDURA 3. Vraća samo jedan rezultat za razliku od prethodne

DELIMITER //

CREATE PROCEDURE update_dostupnost_svih_autax()
BEGIN
    DECLARE p_auto_id INT;
    DECLARE p_datum_povratka_date DATETIME;

    SELECT a.id, a.model,a.dostupnost,n.datum_povratka
    FROM auto as a
        INNER JOIN narudzbenica as n
        ON a.id = n.id_auto
    WHERE n.datum_povratka <= CURDATE();

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

-- FUNKCIJa koja nam govori koji proizvod je jeftin a koji skup

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


-- PROCEDURA U sklopu procedure nalazi se 
-- naredba za ažuriranje koja ažurira stupac "komentar" u tablici "servis" na temelju vrijednosti stupca "datum_povratka" u tablici "narudžbenica".

DELIMITER //
CREATE PROCEDURE update_komentar_servisa()
BEGIN
    UPDATE servis as s
    INNER JOIN narudzbenica as n
        ON s.id_narudzbenica = n.id
    SET s.komentar = CASE
        WHEN n.datum_povratka < CURDATE() THEN 'Servis u tijeku'
        ELSE 'Automobil spreman za preuzimanje'
    END
    WHERE n.datum_povratka <= CURDATE() ;
END//

DELIMITER ;

call update_komentar_servisa();

SELECT *FROM servis, narudzbenica WHERE servis.id_narudzbenica=narudzbenica.id;


-- NEVEN END

