import mysql.connector

############################################################
# funkcija kojom pronalazimo npr zadnji id ili zadnji broj narudžbe (najveći broj je zadnji)


def get_last_record_identificator(table: str, column: str) -> int:
    # Definiranje baze i kursora ( kasnije dodati nove korisnike sa ogranicenjima, za sada root user)
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


def add_item(table: str, data: dict) -> int:  # vraća id unesenog itema
    # Definiranje baze i kursora ( kasnije dodati nove korisnike sa ogranicenjima, za sada root user)
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
        # print(qstring)
        try:
            mycursor.execute(qstring)
        except Exception as err:
            raise Exception(err)
        db.commit()
        return get_last_record_identificator(table, "id")

############################################################


def delete_item(table: str, item_id: int) -> int:
    # Definiranje baze i kursora ( kasnije dodati nove korisnike sa ogranicenjima, za sada root user)
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

# -> znaci da vraca dictionary (google "python annotations" za vise info)
def get_all_items(table) -> dict:
    # Definiranje baze i kursora ( kasnije dodati nove korisnike sa ogranicenjima, za sada root user)
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


def get_all_cars_for_sale(table) -> dict:
    # Definiranje baze i kursora ( kasnije dodati nove korisnike sa ogranicenjima, za sada root user)
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


def get_all_salesmen(table) -> dict:
    # Definiranje baze i kursora ( kasnije dodati nove korisnike sa ogranicenjima, za sada root user)
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


def get_client_status(p_id) -> dict:
    # Definiranje baze i kursora ( kasnije dodati nove korisnike sa ogranicenjima, za sada root user)
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


def get_all_receipts() -> dict:
    # Definiranje baze i kursora ( kasnije dodati nove korisnike sa ogranicenjima, za sada root user)
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


def get_all_receipts_after_date(my_date) -> dict:
    # Definiranje baze i kursora ( kasnije dodati nove korisnike sa ogranicenjima, za sada root user)
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
    # Definiranje baze i kursora ( kasnije dodati nove korisnike sa ogranicenjima, za sada root user)
    with mysql.connector.connect(host="localhost", user="root", passwd="root", database="Prodajno_servisni_centar") as db:
        # da vraća rezultate tj. rows kao dictionaryje
        mycursor = db.cursor(dictionary=True)
        qstring = f'SELECT * FROM {table} WHERE id = {id};'

        try:
            mycursor.execute(qstring)
            myresult = mycursor.fetchone()
            if myresult == None:
                raise Exception("Zaposlenik nije pronađen u bazi!")
        except Exception as err:
            raise Exception(err)
        return myresult
############################################################


def get_receipt(id) -> dict:
    # Definiranje baze i kursora ( kasnije dodati nove korisnike sa ogranicenjima, za sada root user)
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


def find_item(table, attribut: str, value) -> dict:
    # Definiranje baze i kursora ( kasnije dodati nove korisnike sa ogranicenjima, za sada root user)
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
    # Definiranje baze i kursora ( kasnije dodati nove korisnike sa ogranicenjima, za sada root user)
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
    # Definiranje baze i kursora ( kasnije dodati nove korisnike sa ogranicenjima, za sada root user)
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


############################################################
# PODACI ZA TESTIRANJE FUNKCIJA
zaposlenik_1 = {
    "ime": "John",
    "prezime": "Doe",
    "datum_rodenja": "1998-05-12",
    "adresa": "Školska 17",
    "grad": "Pula",
    "spol": "m",
    "broj_telefona": "098669412",
    "datum_zaposlenja": "2012-07-12",
    "e_mail": "jdoe@gmail.com",
    "placa": "12500",
    "radno_mjesto": "mehanicar",
}
zaposlenik_2 = {
    "ime": "Srki",
    "prezime": "Bućac",
    "datum_rodenja": "1991-07-12",
    "adresa": "Školska 18",
    "grad": "Pula",
    "spol": "m",
    "broj_telefona": "091669413",
    "datum_zaposlenja": "2012-07-13",
    "e_mail": "srke@gmail.com",
    "placa": "10500",
    "radno_mjesto": "prodavac",
}

update_z1 = {
    # vazno je da je id uvijek prisutan u dictionaryju sa podacima za UPDATE(kako bi se moglo pronaci koji record treba updateat) i da je tipa int
    "id": 680,
    "adresa": "Marca Garbina 2",
    "placa": "14200",
    "radno_mjesto": "prodavac"}


# narudzbenica_31 = {
# 	"id_klijent": 10,
# 	"id_auto": 3,
# 	"broj_narudzbe": get_last_record_identificator("narudzbenica", "broj_narudzbe") + 1,
# 	"datum_zaprimanja": "2022-09-09",
# 	"datum_povratka" : "2022-09-15",
# }

update_auto1 = {
    "id": 1,
    "boja": "zlatna metallic",
    "snaga_motora": "850"
}

#### POZIVI FUNKCIJA #####
# dodavanje itema
# add_item("zaposlenik",zaposlenik_1)
# add_item("zaposlenik",zaposlenik_2)
# add_item("narudzbenica",narudzbenica_31)

# update itema
# edit_table("zaposlenik",update_z1)
# edit_table("auto",update_auto1)

# vracanje svih itema iz tablice
# print(get_all_items("zaposlenik"))

# pronalazak odredenog itema prema nekom atributu
# print(find_item("zaposlenik","ime","John"))
# print(find_item("zaposlenik","id",680))
# print(find_item("zaposlenik","grad","Zagreb"))
# print(find_item("auto","id",10))

# brisanje itema
# delete_item("zaposlenik",680)
# delete_item("auto",575)

# dobivanje zadnjeg identifikatora
# print(get_last_record_identificator("narudzbenica","broj_narudzbe")) # daje zadnji broj_narudzbe u tablici
# print(get_last_record_identificator("auto","id")) # daje id zadnjeg auta u tablici

# db.commit()
# mycursor.close()
# db.close()

# TO DO: -uvesti kaskadno brisanje podataka na sve tablice gdje je potrebno
