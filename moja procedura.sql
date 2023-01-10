USE Prodajno_servisni_centar;

-- DROP PROCEDURE podesi_prodajne_cijene;
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

-- CALL podesi_prodajne_cijene();
-- DROP VIEW dijelovi_ugradeni_u_zadnjih_mjesec_dana;
CREATE VIEW dijelovi_ugradeni_u_zadnjih_mjesec_dana AS
SELECT dns.id_dio, nabavna_cijena, prodajna_cijena, (prodajna_cijena - nabavna_cijena) as profitna_razlika, SUM(kolicina) as ukupno_ugradeno_dijelova, datum_povratka as datum_ugradnje
FROM stavka_dio sd 
INNER JOIN dio_na_servisu dns ON dns.id_dio = sd.id_dio
INNER JOIN servis s ON dns.id_servis = s.id
INNER JOIN narudzbenica n ON s.id_narudzbenica = n.id
WHERE datum_povratka > (SELECT NOW() - INTERVAL 1 MONTH FROM DUAL)
GROUP BY dns.id_dio
ORDER BY ukupno_ugradeno_dijelova DESC;


SELECT * FROM dijelovi_ugradeni_u_zadnjih_mjesec_dana;

CREATE EVENT podesi_cijene_dijelova
ON SCHEDULE
EVERY 1 MONTH
STARTS '2023-01-10 14:08:00'
DO
CALL podesi_prodajne_cijene();

