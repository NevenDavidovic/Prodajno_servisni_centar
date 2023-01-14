import mysql.connector
from globalVars import valuta, snaga
import time

############################################################
# funkcija kojom pronalazimo npr zadnji id ili zadnji broj narudžbe (najveći broj je zadnji)


def get_last_record_identificator(table: str, column: str) -> int:
    # Definiranje baze i kursora
    with mysql.connector.connect(host="localhost", user="root", passwd="root", database="Prodajno_servisni_centar") as db:
        # da vraća rezultate tj. rows kao dictionaryje
        mycursor = db.cursor(dictionary=True)

        qstring = f'SELECT MAX({column}) as last_val FROM {table}'

        try:
            mycursor.execute(qstring)
        except Exception as err:
            raise Exception(err)
        max_val = mycursor.fetchone()

        return int(max_val["last_val"])

############################################################

# funkcija za dodavanje novog unosa u tablicu


def add_item(table: str, data: dict) -> int:  # vraća id unesenog itema
    # Definiranje baze i kursora
    with mysql.connector.connect(host="localhost", user="root", passwd="root", database="Prodajno_servisni_centar") as db:
        # da vraća rezultate tj. rows kao dictionaryje
        mycursor = db.cursor(dictionary=True)

        qstring = f'INSERT INTO {table} ('
        columns = ''
        values = '('

        for key, val in data.items():
            columns = columns + key + ','
            if isinstance(val, str):
                values += f'"{val}",'
            else:
                values += f'{val},'

        columns = columns[:-1] + ')'
        values = values[:-1] + ');'

        qstring = qstring + columns + ' VALUES ' + values

        try:
            mycursor.execute(qstring)
        except Exception as err:
            raise Exception(err)
        db.commit()
        return get_last_record_identificator(table, "id")

############################################################

# funkcija za brisanje podatka iz tablice


def delete_item(table: str, item_id: int) -> int:
    # Definiranje baze i kursora
    with mysql.connector.connect(host="localhost", user="root", passwd="root", database="Prodajno_servisni_centar") as db:
        # da vraća rezultate tj. rows kao dictionaryje
        mycursor = db.cursor(dictionary=True)

        qstring = f'DELETE FROM {table} WHERE id = {item_id};'
        try:
            mycursor.execute(qstring)
            db.commit()
        except Exception as err:
            raise Exception(err)
        return item_id


############################################################
# funkcija koja vraća sve zapise iz tablice
def get_all_items(table) -> dict:
    # Definiranje baze i kursora
    with mysql.connector.connect(host="localhost", user="root", passwd="root", database="Prodajno_servisni_centar") as db:
        # da vraća rezultate tj. rows kao dictionaryje
        mycursor = db.cursor(dictionary=True)
        qstring = f'SELECT * FROM {table};'

        try:
            mycursor.execute(qstring)
        except Exception as err:
            raise Exception(err)
        myresult = mycursor.fetchall()
        return myresult
############################################################

# funkcija koja vraća sve aute za prodaju


def get_all_cars_for_sale(table) -> dict:
    # Definiranje baze i kursora
    with mysql.connector.connect(host="localhost", user="root", passwd="root", database="Prodajno_servisni_centar") as db:
        # da vraća rezultate tj. rows kao dictionaryje
        mycursor = db.cursor(dictionary=True)
        qstring = f'SELECT * FROM {table} WHERE servis_prodaja = "P";'

        try:
            mycursor.execute(qstring)
        except Exception as err:
            raise Exception(err)
        myresult = mycursor.fetchall()

        return myresult
############################################################
# funkcija koja vraća sve aute za prodaju


def get_all_cars_for_servis(table) -> dict:
    # Definiranje baze i kursora
    with mysql.connector.connect(host="localhost", user="root", passwd="root", database="Prodajno_servisni_centar") as db:
        # da vraća rezultate tj. rows kao dictionaryje
        mycursor = db.cursor(dictionary=True)
        qstring = f'SELECT * FROM {table} WHERE servis_prodaja = "S";'

        try:
            mycursor.execute(qstring)
        except Exception as err:
            raise Exception(err)
        myresult = mycursor.fetchall()

        return myresult
############################################################

# funkcija koja vraća sve prodavače


def get_all_salesmen(table) -> dict:
    # Definiranje baze i kursora
    with mysql.connector.connect(host="localhost", user="root", passwd="root", database="Prodajno_servisni_centar") as db:
        # da vraća rezultate tj. rows kao dictionaryje
        mycursor = db.cursor(dictionary=True)
        qstring = f'SELECT * FROM {table} WHERE radno_mjesto = "prodavac";'

        try:
            mycursor.execute(qstring)
        except Exception as err:
            raise Exception(err)
        myresult = mycursor.fetchall()

        return myresult
############################################################

# funkcija koja provjerava status klijenta


def get_client_status(p_id) -> dict:
    # Definiranje baze i kursora
    with mysql.connector.connect(host="localhost", user="root", passwd="root", database="Prodajno_servisni_centar") as db:
        # da vraća rezultate tj. rows kao dictionaryje
        # definiranje pocetnih uvjeta
        clientStatus = {
            "prijasnji_klijent": False,
            "klijent_zaposlenik": False
        }

        # upit koji preborjava koliko se puta pojavljuje klijent na računima
        mycursor = db.cursor(dictionary=True)
        qstring1 = f'''SELECT count(id) as broj
        FROM racun_prodaje
        where id_klijent = {p_id};'''

        # upit koji provjerava je li klijent ujedno i zaposlenik
        qstring2 = f'''SELECT count(*) as broj
        FROM zaposlenik z
        WHERE oib = (SELECT oib FROM klijent WHERE id = {p_id});'''

        try:

            mycursor.execute(qstring1)
            repeatedClientCount = mycursor.fetchone()

            mycursor.execute(qstring2)
            employerClientCount = mycursor.fetchone()
        except Exception as err:
            raise Exception(err)

        if int(repeatedClientCount.get('broj')):
            clientStatus['prijasnji_klijent'] = True
        if int(employerClientCount.get('broj')):
            clientStatus['klijent_zaposlenik'] = True

        return clientStatus
############################################################

# funkcija koja vraća sve račune


def get_all_receipts() -> dict:
    # Definiranje baze i kursora
    with mysql.connector.connect(host="localhost", user="root", passwd="root", database="Prodajno_servisni_centar") as db:
        # da vraća rezultate tj. rows kao dictionaryje
        mycursor = db.cursor(dictionary=True)
        qstring = f'SELECT * FROM  svi_podaci_sa_racuna ORDER BY rp_datum DESC;'

        try:
            mycursor.execute(qstring)
        except Exception as err:
            raise Exception(err)
        myresult = mycursor.fetchall()

        return myresult
############################################################

# funkcija koja vraća sve račune nakon određenog datuma


def get_all_receipts_after_date(my_date) -> dict:
    # Definiranje baze i kursora
    with mysql.connector.connect(host="localhost", user="root", passwd="root", database="Prodajno_servisni_centar") as db:
        # da vraća rezultate tj. rows kao dictionaryje
        mycursor = db.cursor(dictionary=True)
        print(my_date)
        qstring = f'SELECT * FROM  svi_podaci_sa_racuna WHERE rp_datum > "{my_date}" ORDER BY rp_datum DESC;'

        try:
            mycursor.execute(qstring)
        except Exception as err:
            raise Exception(err)
        myresult = mycursor.fetchall()

        return myresult
############################################################

# dohvaca item iz tablice po id-ju


def get_item(table, id) -> dict:
    # Definiranje baze i kursora
    with mysql.connector.connect(host="localhost", user="root", passwd="root", database="Prodajno_servisni_centar") as db:
        # da vraća rezultate tj. rows kao dictionaryje
        mycursor = db.cursor(dictionary=True)
        qstring = f'SELECT * FROM {table} WHERE id = {id};'

        try:
            mycursor.execute(qstring)
            myresult = mycursor.fetchone()
            if myresult == None:
                raise Exception("Ne postoji zapis u bazi!")
        except Exception as err:
            raise Exception(err)
        return myresult
############################################################

# funkcija dohvaća račun prema id-ju


def get_receipt(id) -> dict:
    # Definiranje baze i kursora
    with mysql.connector.connect(host="localhost", user="root", passwd="root", database="Prodajno_servisni_centar") as db:
        # da vraća rezultate tj. rows kao dictionaryje
        mycursor = db.cursor(dictionary=True)
        qstring = f'SELECT * FROM svi_podaci_sa_racuna WHERE rp_id = {id};'

        try:
            mycursor.execute(qstring)
            myresult = mycursor.fetchone()
            if myresult == None:
                raise Exception("Račun nije pronađen u bazi!")
        except Exception as err:
            raise Exception(err)
        return myresult
############################################################

# funkcija koja pronalazi određenu stavku iz tablice prema vrijednosti atributa


def find_item(table, attribut: str, value) -> dict:
    # Definiranje baze i kursora
    with mysql.connector.connect(host="localhost", user="root", passwd="root", database="Prodajno_servisni_centar") as db:
        # da vraća rezultate tj. rows kao dictionaryje
        mycursor = db.cursor(dictionary=True)
        # provjerava je li vrijednost integer ili string kako bi se prilagodio upit za sql
        if isinstance(value, int):
            qstring = f'SELECT * FROM {table} WHERE {attribut} = {value};'
        else:
            qstring = f'SELECT * FROM {table} WHERE {attribut} = "{value}";'

        try:
            mycursor.execute(qstring)
        except Exception as err:
            raise Exception(err)
        return mycursor.fetchall()
############################################################


def find_item_like(table, attribut: str, value) -> dict:
    # Definiranje baze i kursora
    with mysql.connector.connect(host="localhost", user="root", passwd="root", database="Prodajno_servisni_centar") as db:
        # da vraća rezultate tj. rows kao dictionaryje
        mycursor = db.cursor(dictionary=True)
        # provjerava je li vrijednost integer ili string kako bi se prilagodio upit za sql
        if isinstance(value, int):
            qstring = f'SELECT * FROM {table} WHERE {attribut} LIKE %{value}%;'
        else:
            qstring = f'SELECT * FROM {table} WHERE {attribut} LIKE "%{value}%";'

        try:
            mycursor.execute(qstring)
        except Exception as err:
            raise Exception(err)
        return mycursor.fetchall()
############################################################


def edit_table(table, data):
    # Definiranje baze i kursora
    with mysql.connector.connect(host="localhost", user="root", passwd="root", database="Prodajno_servisni_centar") as db:
        # da vraća rezultate tj. rows kao dictionaryje
        mycursor = db.cursor(dictionary=True)
        for key, val in data.items():
            if isinstance(val, int):
                qstring = f'UPDATE {table} SET {key} = {val} WHERE id = {data["id"]};'
            else:
                qstring = f'UPDATE {table} SET {key} = "{val}" WHERE id = {data["id"]};'
            try:
                mycursor.execute(qstring)
                db.commit()
            except Exception as err:
                raise Exception(err)


##########################################################################


def get_parts_by_id(id: int) -> dict:
    # Create connection to the database
    with mysql.connector.connect(host="localhost", user="root", passwd="root", database="Prodajno_servisni_centar") as db:
        # Create a cursor
        cursor = db.cursor(dictionary=True)
        # Define the query string, using the ID argument in the WHERE clause
        query = f'SELECT  * FROM dio_na_servisu dns '\
            'INNER JOIN servis s ON dns.id_servis = s.id '\
            'INNER JOIN dio d ON dns.id_dio = d.id '\
            'INNER JOIN stavka_dio sd ON dns.id_dio = sd.id_dio '\
            'WHERE dns.id_servis = {id};'
        try:
            # Execute the query
            cursor.execute(query)
            # Fetch all records
            result = cursor.fetchall()
        except Exception as e:
            raise Exception(e)
        return result


def updatePartsPrice(percantage: float):
    # Create connection to the database
    with mysql.connector.connect(host="localhost", user="root", passwd="root", database="Prodajno_servisni_centar") as db:
        # Create a cursor
        cursor = db.cursor(dictionary=True)
        # Define the query string, using the ID argument in the WHERE clause
        query = f'''CALL azuriraj_cijene_dijelova({percantage});'''
        try:
            # Execute the query
            cursor.execute(query)
            db.commit()
        except Exception as e:
            raise Exception(e)


def updatePartsQuantity(serial, quantity):
    # Create connection to the database
    with mysql.connector.connect(host="localhost", user="root", passwd="root", database="Prodajno_servisni_centar") as db:
        # Create a cursor
        cursor = db.cursor(dictionary=True)
        # Define the query string

        query = f'''CALL azuriraj_dostupnu_kolicinu_dijela({serial},{int(quantity)});'''
        print(query)
        try:
            # Execute the query
            cursor.execute(query)
            db.commit()
        except Exception as e:
            raise Exception(e)


def konverzijaSnageMotora() -> None:
    global snaga
    with mysql.connector.connect(host="localhost", user="root", passwd="root", database="Prodajno_servisni_centar") as db:
        db.cursor(dictionary=True).execute("CALL konverzija_snage_motora();")
        db.commit()
    snaga = 'BHP'


def getSnaga() -> str:
    return snaga


def konverzijaKuneEuri() -> None:
    global valuta
    with mysql.connector.connect(host="localhost", user="root", passwd="root", database="Prodajno_servisni_centar") as db:
        db.cursor(dictionary=True).execute("CALL kune_u_eure();")
        db.commit()
    valuta = 'EUR'


def getValuta() -> str:
    return valuta


def prometDana() -> dict:
    with mysql.connector.connect(host="localhost", user="root", passwd="root", database="Prodajno_servisni_centar") as db:
        datum = time.strftime("%Y-%m-%d")
        mycursor = db.cursor(dictionary=True)

        qstring1 = f'CALL PROMET_DANA("{datum}",@br_prodanih_stavki, @promet_dana);'
        qstring2 = f'SELECT @br_prodanih_stavki, @promet_dana FROM DUAL;'

        mycursor.execute(qstring1)
        mycursor.execute(qstring2)
        return mycursor.fetchall()

def prometDanaProdaja() -> dict:
    with mysql.connector.connect(host="localhost", user="root", passwd="root", database="Prodajno_servisni_centar") as db:
        datum = time.strftime("%Y-%m-%d")
        mycursor = db.cursor(dictionary=True)

        qstring1 = f'CALL PRODAJA_PROMET_DANA("{datum}",@br_prodanih_stavki, @promet_dana);'
        qstring2 = f'SELECT @br_prodanih_stavki, @promet_dana FROM DUAL;'

        mycursor.execute(qstring1)
        mycursor.execute(qstring2)
        return mycursor.fetchall()


def prometDanaServis() -> dict:
    with mysql.connector.connect(host="localhost", user="root", passwd="root", database="Prodajno_servisni_centar") as db:
        datum = time.strftime("%Y-%m-%d")
        mycursor = db.cursor(dictionary=True)

        qstring1 = f'CALL SERVIS_PROMET_DANA("{datum}",@br_prodanih_stavki, @promet_dana);'
        qstring2 = f'SELECT @br_prodanih_stavki, @promet_dana FROM DUAL;'

        mycursor.execute(qstring1)
        mycursor.execute(qstring2)
        return mycursor.fetchall()
