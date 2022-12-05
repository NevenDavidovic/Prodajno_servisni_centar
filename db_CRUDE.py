# kamen temeljac

import mysql.connector

# Definiranje baze i kursora ( kasnije dodati nove korisnike sa ogranicenjima, za sada root user)
db = mysql.connector.connect(host="localhost",user="root",passwd="root",database="Prodajno_servisni_centar")
mycursor = db.cursor(dictionary=True) # da vraća rezultate tj. rows kao dictionaryje



############################################################
# funkcija kojom pronalazimo npr zadnji id ili zadnji broj narudžbe (najveći broj je zadnji)
def get_last_record_identificator(table:str, column:str)->int:
    
    # qstring = f'SELECT MAX({column}) as last_val FROM {table}' -> prebaceno u SQL funkciju
    qstring1 = f'CALL get_last_record_identificator("{table}","{column}",@last_record);'
    qstring2 = f'SELECT @last_record AS last_val;'
    try:
        mycursor.execute(qstring1)
        mycursor.execute(qstring2)
    except Exception as err:
        print("Došlo je do greške!") 
        print(err)
        return {"error_message" : err}
    max_val = mycursor.fetchone()
    
    return int(max_val["last_val"])

############################################################
def add_item(table: str,data: dict) -> int: # vraća id unesenog itema
    qstring = f'INSERT INTO {table} ('
    columns = ''
    values = '('

    for key,val in data.items():
        columns = columns + key + ','
        if isinstance(val,str):
            values += f'"{val}",'
        else:
             values += f'{val},'
    
    columns = columns[:-1] + ')'
    values = values[:-1] + ');'

    qstring = qstring + columns + ' VALUES ' + values
    #print(qstring)
    try:
        mycursor.execute(qstring)
    except Exception as err:
        print("Došlo je do greške!") 
        print(err)
        return {"error_message" : err}
    db.commit()
    return get_last_record_identificator(table,"id")

############################################################

def delete_item(table: str,item_id: int) -> int:
    qstring = f'DELETE FROM {table} WHERE id = {item_id};'
    try:
        mycursor.execute(qstring)
    except Exception as err:
        print("Došlo je do greške!") 
        print(err)
        return {"error_message" : err}
    return item_id
    

############################################################

def get_all_items(table) -> dict: # -> znaci da vraca dictionary (google "python annotations" za vise info)
    qstring = f'SELECT * FROM {table};'
    
    try:
        mycursor.execute(qstring)
    except Exception as err:
        print("Došlo je do greške!") 
        print(err)
        return {"error_message" : err}
    myresult = mycursor.fetchall()
    return myresult
############################################################    
    
def find_item(table, attribut: str , value) -> dict: 
    if isinstance(value, int): #provjerava je li vrijednost integer ili string kako bi se prilagodio upit za sql
        qstring = f'SELECT * FROM {table} WHERE {attribut} = {value};'
    else:
        qstring = f'SELECT * FROM {table} WHERE {attribut} = "{value}";'

    try:
        mycursor.execute(qstring)
    except Exception as err:
        print("Došlo je do greške!") 
        print(err)
        return {"error_message" : err}

    myresult = mycursor.fetchall()
    return myresult
############################################################
  
def edit_table(table, data):
    for key,val in data.items():
        if isinstance(val,int):
            qstring = f'UPDATE {table} SET {key} = {val} WHERE id = {data["id"]};'
        else:
            qstring = f'UPDATE {table} SET {key} = "{val}" WHERE id = {data["id"]};'
        try:
            mycursor.execute(qstring)
        except Exception as err:
            print("Došlo je do greške!") 
            print(err)
            return {"error_message" : err}
    
############################################################
####### PODACI ZA TESTIRANJE FUNKCIJA
zaposlenik_1 = {
	"ime" : "John",
	"prezime": "Doe",
	"datum_rodenja" : "1998-05-12",
	"adresa" : "Školska 17",
    "grad" : "Pula",
	"spol" : "m",
	"broj_telefona" : "098669412",
    "datum_zaposlenja" : "2012-07-12",
	"e_mail" : "jdoe@gmail.com" ,
	"placa" : "12500",
	"radno_mjesto" : "mehanicar",
}
zaposlenik_2 = {
	"ime" : "Srki",
	"prezime": "Bućac",
	"datum_rodenja" : "1991-07-12",
	"adresa" : "Školska 18",
    "grad" : "Pula",
	"spol" : "m",
	"broj_telefona" : "091669413",
    "datum_zaposlenja" : "2012-07-13",
	"e_mail" : "srke@gmail.com" ,
	"placa" : "10500",
	"radno_mjesto" : "prodavac",
}

update_z1 = {
"id": 680,  # vazno je da je id uvijek prisutan u dictionaryju sa podacima za UPDATE(kako bi se moglo pronaci koji record treba updateat) i da je tipa int
"adresa":"Marca Garbina 2",
"placa":"14200",
"radno_mjesto":"prodavac"}


narudzbenica_31 = {
	"id_klijent": 10,
	"id_auto": 3,
	"broj_narudzbe": get_last_record_identificator("narudzbenica", "broj_narudzbe") + 1,
	"datum_zaprimanja": "2022-09-09",
	"datum_povratka" : "2022-09-15",
}

update_auto1 = {
"id": 1,
"boja":"zlatna metallic",
"snaga_motora":"850"
}

#### POZIVI FUNKCIJA #####
### dodavanje itema
# add_item("zaposlenik",zaposlenik_1)
# add_item("zaposlenik",zaposlenik_2)
# add_item("narudzbenica",narudzbenica_31)

### update itema
# edit_table("zaposlenik",update_z1)
# edit_table("auto",update_auto1)

### vracanje svih itema iz tablice
# print(get_all_items("zaposlenik"))

### pronalazak odredenog itema prema nekom atributu
# print(find_item("zaposlenik","ime","John"))
# print(find_item("zaposlenik","id",680))
# print(find_item("zaposlenik","grad","Zagreb"))
# print(find_item("auto","id",10))

### brisanje itema
# delete_item("zaposlenik",680)
# delete_item("auto",575)

### dobivanje zadnjeg identifikatora
# print(get_last_record_identificator("narudzbenica","broj_narudzbe")) # daje zadnji broj_narudzbe u tablici
# print(get_last_record_identificator("auto","id")) # daje id zadnjeg auta u tablici

db.commit()
mycursor.close()
db.close()

## TO DO: -uvesti kaskadno brisanje podataka na sve tablice gdje je potrebno