from flask import Flask, Blueprint, render_template, request, make_response, jsonify
from statsFunctions import uslugePoTipuMotora, najviseUtrosenihDjelova, zaspoleniciSaNajviseServisa, zaposleniciPoNajvisojCijeni, racuniPoKupcu, topSkupiDijelovi
from db_CRUDE import add_item, delete_item, get_all_items, find_item, edit_table, get_item,get_all_cars_for_sale


prodaja = Blueprint("prodaja", __name__)


# rute

### NOVI KLIJENT
@prodaja.route("/prodaja/dodavanje-novog-klijenta", methods=['POST', 'GET'])
def addClient():
    if request.method == "POST":
        try:
            table = 'klijent'
            data = {}
            for key, value in request.form.items():
                data[key] = value

            add_item(table, data)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("success.html", data={"msg": "Klijent uspješno dodan!","route":"/prodaja/ispis-svih-klijenata"}), 200)
    else:
        return make_response(render_template("prodaja-dodavanje-novog-klijenta.html"), 200)


### ISPIS SVIH KLIJENATA
@prodaja.route("/prodaja/ispis-svih-klijenata", methods=['POST', 'GET'])
def getClients():
    if request.method == "POST":
        try:
            table = 'klijent'
            attribut = 'ime'
            value = request.form.get('ime')
            response = find_item(table, attribut, value)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("prodaja-ispis-svih-klijenata.html", data=response), 200)
    else:
        try:
            table = 'klijent'
            response = get_all_items(table)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("prodaja-ispis-svih-klijenata.html", data=response), 200)


### UREĐIVANJE POJEDINOG KLIJENTA
@prodaja.route("/prodaja/uredivanje-klijenta/<int:id>", methods=['POST', 'GET'])
def editClient(id):
    if request.method == "POST":
        try:
            table = 'klijent'
            data = {}
            for key, value in request.form.items():
                data[key] = value
            data["id"] = id    
            
            edit_table(table, data)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("success.html", data={"msg": "Podaci o klijentu uspješno promjenjeni!","route":"/prodaja/ispis-svih-klijenata"}), 200)
    else:
        try:
            table = 'klijent'
            response = get_item(table, id)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("prodaja-uredivanje-klijenta.html", data=response), 200)

### ISPIS SVIH AUTOMOBILA
@prodaja.route("/prodaja/ispis-svih-automobila", methods=['POST', 'GET'])
def getCars():
    if request.method == "POST":
        try:
            queryData = {}
            for key,value in request.form.items(): 
                    queryData[key] = value
    
            table = 'auto'
            attribut = queryData['identificator']
            value = queryData['query']

            if attribut == 'godina_proizvodnje':
                value = value + '-01-01'

            
            response = find_item(table, attribut, value)
            
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("prodaja-ispis-svih-automobila.html", data=response), 200)
    else:
        try:
            table = 'auto'
            response = get_all_cars_for_sale(table)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("prodaja-ispis-svih-automobila.html", data=response), 200)

### PRIKAZ POJEDINOG AUTOMOBILA

@prodaja.route("/prodaja/prikaz-auta/<int:id>", methods=['GET'])
def getCar(id):
    try:
        table = 'auto'
        response = get_item(table, id)
        
    except Exception as err:
        return make_response(render_template("fail.html", error=err), 400)
    return make_response(render_template("prodaja-prikaz-auta.html", data=response), 200)

# @prodaja.route
