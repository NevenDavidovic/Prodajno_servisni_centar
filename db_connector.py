# kamen temeljac

import mysql.connector

# Definiranje baze i kursora
db = mysql.connector.connect(host="localhost",user="root",passwd="root",database="Prodajno_servisni_centar")
mycursor = db.cursor(dictionary=True) # da vraća rezultate tj. rows kao dictionaryje


zaposlenik_1 = {
    "id" : "680",
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
	"radno_mjesto" : "prodavac",
} 

###### FUNKCIJE ZAPOSLENIKA ######
############################################################
def add_zaposlenik(z_info) -> int: # vraća id unesenog zaposlenika
    qstring = f'INSERT INTO zaposlenik VALUES ({z_info["id"]},"{z_info["ime"]}","{z_info["prezime"]}","{z_info["datum_rodenja"]}","{z_info["adresa"]}","{z_info["grad"]}","{z_info["spol"]}","{z_info["broj_telefona"]}","{z_info["datum_zaposlenja"]}","{z_info["e_mail"]}",{z_info["placa"]},"{z_info["radno_mjesto"]}");'
    try:
        mycursor.execute(qstring)
    except Exception as err:
        print("Došlo je do greške!") 
        print(err)
    return z_info["id"]
############################################################    
def edit_zaposlenik():
    pass

############################################################
def delete_zaposlenik():
    pass

############################################################
def get_all_zaposlenik() -> dict: # -> znaci da vraca dictionary (google "python annotations" za vise info)
    qstring = f'SELECT * FROM zaposlenik;'
    
    try:
        mycursor.execute(qstring)
    except Exception as err:
        print("Došlo je do greške!") 
        print(err)

    myresult = mycursor.fetchall()
    return myresult
############################################################    
    
def find_zaposlenik(attribut: str , value) -> dict: 
    if isinstance(value, int): #provjerava je li vrijednost integer ili string kako bi se prilagodio upit za sql
        qstring = f'SELECT * FROM zaposlenik WHERE {attribut} = {value};'
    else:
        qstring = f'SELECT * FROM zaposlenik WHERE {attribut} = "{value}";'

    try:
        mycursor.execute(qstring)
    except Exception as err:
        print("Došlo je do greške!") 
        print(err)

    myresult = mycursor.fetchall()
    return myresult
############################################################

#### POZIVI FUNKCIJA #####

#add_zaposlenik(zaposlenik_1)
#print(get_all_zaposlenik())
#print(find_zaposlenik("ime","John"))
#print(find_zaposlenik("id",680))
#print(find_zaposlenik("grad","Zagreb"))


db.commit()
mycursor.close()
db.close()
