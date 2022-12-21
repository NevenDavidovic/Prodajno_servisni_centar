import mysql.connector

# STATISTIKE TIN
def uslugePoTipuMotora():
    # Definiranje baze i kursora ( kasnije dodati nove korisnike sa ogranicenjima, za sada root user)
    with mysql.connector.connect(host="localhost",user="root",passwd="root",database="Prodajno_servisni_centar") as db:
        mycursor = db.cursor(dictionary=True) # da vraća rezultate tj. rows kao dictionaryje


        qstring = f'''SELECT a.tip_motora, SUM(broj_izvrsenih_usluga) as ukupno_izvrsenih_usluga
        FROM usluge_po_narudzbenici upn
        INNER JOIN narudzbenica n ON upn.id_narudzbenica = n.id
        INNER JOIN auto a ON a.id = n.id_auto
        WHERE datum_zaprimanja > DATE(DATE_sub(NOW(), INTERVAL 6 MONTH))
        GROUP BY tip_motora
        ORDER BY ukupno_izvrsenih_usluga DESC;
        '''
        
        try:
            mycursor.execute(qstring) 
        except Exception as err:
            raise Exception(err)
        result = mycursor.fetchall()
        return result


def najviseUtrosenihDjelova():
    # Definiranje baze i kursora ( kasnije dodati nove korisnike sa ogranicenjima, za sada root user)
    with mysql.connector.connect(host="localhost",user="root",passwd="root",database="Prodajno_servisni_centar") as db:
        mycursor = db.cursor(dictionary=True) # da vraća rezultate tj. rows kao dictionaryje

        qstring = f'''SELECT a.marka_automobila, a.model,SUM(kolicina) AS broj_ugradjenih_djelova
        FROM auto a INNER JOIN narudzbenica n ON a.id = n.id_auto
        INNER JOIN servis s ON n.id = s.id_narudzbenica
        INNER JOIN dio_na_servisu i ON s.id = i.id_servis
        WHERE datum_zaprimanja > DATE(DATE_sub(NOW(), INTERVAL 6 MONTH))
        GROUP BY model
        ORDER BY broj_ugradjenih_djelova DESC
        LIMIT 5;'''

        try:
            mycursor.execute(qstring) 
        except Exception as err:
            raise Exception(err)
        result = mycursor.fetchall()
        return result

# STATISTIKE NEVEN
def zaspoleniciSaNajviseServisa():
    # Definiranje baze i kursora ( kasnije dodati nove korisnike sa ogranicenjima, za sada root user)
    with mysql.connector.connect(host="localhost",user="root",passwd="root",database="Prodajno_servisni_centar") as db:
        mycursor = db.cursor(dictionary=True) # da vraća rezultate tj. rows kao dictionaryje

        qstring = f'''SELECT CONCAT(z.ime ,' ', z.prezime) AS Ime_i_prezime,COUNT(z.id) as broj_servisa
        FROM servis AS s, usluga_servis AS u, zaposlenik AS z
        WHERE z.id=id_zaposlenik AND u.id=id_usluga_servis
        GROUP BY z.id
        ORDER BY broj_servisa
        DESC LIMIT 3;'''

        try:
            mycursor.execute(qstring) 
        except Exception as err:
            raise Exception(err)
        result = mycursor.fetchall()
        return result

def zaposleniciPoNajvisojCijeni():
    # Definiranje baze i kursora ( kasnije dodati nove korisnike sa ogranicenjima, za sada root user)
    with mysql.connector.connect(host="localhost",user="root",passwd="root",database="Prodajno_servisni_centar") as db:
        mycursor = db.cursor(dictionary=True) # da vraća rezultate tj. rows kao dictionaryje

        qstring = f'''SELECT * FROM servisirano LIMIT 3;'''

        try:
            mycursor.execute(qstring) 
        except Exception as err:
            raise Exception(err)
        result = mycursor.fetchall()
        return result

# STATISTIKE DARJAN

def racuniPoKupcu():
    # Definiranje baze i kursora ( kasnije dodati nove korisnike sa ogranicenjima, za sada root user)
    with mysql.connector.connect(host="localhost",user="root",passwd="root",database="Prodajno_servisni_centar") as db:
        mycursor = db.cursor(dictionary=True) # da vraća rezultate tj. rows kao dictionaryje

        qstring = f'''select k.*, count(r.id) as Ukupan_broj_računa
        from klijent k
        inner join racun_prodaje r on k.id = r.id_klijent
        group by k.id
        order by Ukupan_broj_računa
        LIMIT 5;'''

        try:
            mycursor.execute(qstring) 
        except Exception as err:
            raise Exception(err)
        result = mycursor.fetchall()
        return result


def topSkupiDijelovi():
    # Definiranje baze i kursora ( kasnije dodati nove korisnike sa ogranicenjima, za sada root user)
    with mysql.connector.connect(host="localhost",user="root",passwd="root",database="Prodajno_servisni_centar") as db:
        mycursor = db.cursor(dictionary=True) # da vraća rezultate tj. rows kao dictionaryje

        qstring = f'''select serijski_broj,opis,nabavna_cijena 
        from skup_dio
        order by nabavna_cijena DESC
        LIMIT 5;'''

        try:
            mycursor.execute(qstring) 
        except Exception as err:
            raise Exception(err)
        result = mycursor.fetchall()
        return result

    # STATISTIKE SARA

