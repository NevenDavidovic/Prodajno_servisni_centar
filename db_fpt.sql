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

DROP FUNCTION IF EXISTS pronadi_tablice_sa_atributom;

# funkcija koja pronalazi sve tablice koje sadrze trazeni atribut
DELIMITER //

CREATE FUNCTION pronadi_tablice_sa_atributom(naziv_atributa VARCHAR(255))
RETURNS VARCHAR(255)
DETERMINISTIC

BEGIN
	DECLARE table_name VARCHAR(255) DEFAULT '';
    DECLARE results VARCHAR(255) DEFAULT '';

	DECLARE done BOOLEAN DEFAULT FALSE;

	DECLARE cursor_tables CURSOR FOR
		SELECT table_name FROM information_schema.columns
		WHERE column_name = naziv_atributa;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	OPEN cursor_tables;

	get_tables: LOOP
		FETCH cursor_tables INTO table_name;
		IF done THEN
		LEAVE get_tables;
		END IF;

	SET results = results + table_name;

	END LOOP;

	CLOSE cursor_tables;

	RETURN results;
END //

DELIMITER ;

SELECT pronadi_tablice_sa_atributom('naziv');

-- MARIJA end
