from flask import Flask, Blueprint, render_template, request, make_response, jsonify
from statsFunctions import uslugePoTipuMotora, najviseUtrosenihDjelova, zaspoleniciSaNajviseServisa, zaposleniciPoNajvisojCijeni, racuniPoKupcu, topSkupiDijelovi
from db_CRUDE import add_item, delete_item, get_all_items, find_item, edit_table, get_item, get_all_cars_for_sale, get_all_salesmen, get_last_record_identificator, find_item_like, get_all_receipts, get_all_receipts_after_date, get_receipt


prodaja = Blueprint("prodaja", __name__)


# rute

# NOVI KLIJENT
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
        return make_response(render_template("success.html", data={"msg": "Klijent uspješno dodan!", "route": "/prodaja/ispis-svih-klijenata"}), 200)
    else:
        return make_response(render_template("prodaja-dodavanje-novog-klijenta.html"), 200)


# ISPIS SVIH KLIJENATA
@prodaja.route("/prodaja/ispis-svih-klijenata", methods=['POST', 'GET'])
def getClients():
    if request.method == "POST":
        try:
            table = 'klijent'
            attribut = 'ime'
            value = request.form.get('ime')
            response = find_item_like(table, attribut, value)
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


# UREĐIVANJE POJEDINOG KLIJENTA
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
        return make_response(render_template("success.html", data={"msg": "Podaci o klijentu uspješno promjenjeni!", "route": "/prodaja/ispis-svih-klijenata"}), 200)
    else:
        try:
            table = 'klijent'
            response = get_item(table, id)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("prodaja-uredivanje-klijenta.html", data=response), 200)

# ISPIS SVIH AUTOMOBILA


@prodaja.route("/prodaja/ispis-svih-automobila", methods=['POST', 'GET'])
def getCars():
    if request.method == "POST":
        try:
            queryData = {}
            for key, value in request.form.items():
                queryData[key] = value

            table = 'auto'
            attribut = queryData['identificator']
            value = queryData['query']

            if attribut == 'godina_proizvodnje':
                value = value + '-01-01'

            response = find_item_like(table, attribut, value)

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

# PRIKAZ POJEDINOG AUTOMOBILA


@prodaja.route("/prodaja/prikaz-auta/<int:id>", methods=['GET'])
def getCar(id):
    try:
        table = 'auto'
        response = get_item(table, id)

    except Exception as err:
        return make_response(render_template("fail.html", error=err), 400)
    return make_response(render_template("prodaja-prikaz-auta.html", data=response), 200)

# PRIKAZ SVIH PRODAVAČA


@prodaja.route("/prodaja/ispis-svih-prodavaca", methods=['POST', 'GET'])
def getSalesmen():
    if request.method == "POST":
        try:
            table = 'zaposlenik'
            attribut = 'ime'
            value = request.form.get('ime')
            response = find_item_like(table, attribut, value)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("prodaja-ispis-svih-prodavača.html", data=response), 200)
    else:
        try:
            table = 'zaposlenik'
            response = get_all_salesmen(table)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("prodaja-ispis-svih-prodavača.html", data=response), 200)

# KREIRANJE RAČUNA


@prodaja.route("/prodaja/kreiranje-racuna", methods=['POST', 'GET'])
def createBill():
    if request.method == "POST":
        try:

            # kreiranje dictionary sa svim atributima potrebnim za tablicu racun_prodaje
            # neki podaci su dobiveni iz argumenata rute, neki iz forme sa stranice, broj racuna preko funkcije

            brojRacuna = get_last_record_identificator(
                'racun_prodaje', 'broj_racuna') + 1
            data = {
                "id_auto": request.args.get('car_id'),
                "id_zaposlenik": request.args.get('zaposlenik_id'),
                "id_klijent": request.args.get('klijent_id'),
                "broj_racuna": brojRacuna
            }
            # dodavanje podataka iz forme u dictionary data
            for key, value in request.form.items():
                data[key] = value

            table = 'racun_prodaje'
            # dodavanje računa u tablicu račun_prodaje
            response = add_item(table, data)
            # označavanje prodanog auta kao nedostupnog
            dataToEdit = {
                "id": request.args.get('car_id'),
                "dostupnost": "NE"
            }
            response = edit_table('auto', dataToEdit)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("success.html", data={"msg": "Račun uspješno kreiran!", "route": "/prodaja/ispis-svih-automobila"}), 200)

    else:
        try:
            autoData = get_item('auto', request.args.get('car_id'))
            zaposlenikData = get_item(
                'zaposlenik', request.args.get('zaposlenik_id'))
            klijentData = get_item('klijent', request.args.get('klijent_id'))
            brojRacuna = get_last_record_identificator(
                'racun_prodaje', 'broj_racuna')+1

        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("prodaja-kreiranje-racuna.html", data={"auto": autoData, "zaposlenik": zaposlenikData, "klijent": klijentData, "broj_racuna": brojRacuna}), 200)


# ISPIS SVIH RAČUNA
@prodaja.route("/prodaja/ispis-svih-racuna", methods=['POST', 'GET'])
def getBills():
    if request.method == "POST":
        try:
            queryData = {}
            for key, value in request.form.items():
                queryData[key] = value

            table = 'svi_podaci_sa_racuna'
            attribut = queryData['identificator']
            value = queryData['query']
            if attribut == 'rp_datum':
                response = get_all_receipts_after_date(value)
            else:
                response = find_item_like(table, attribut, value)
            print(response)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("prodaja-ispis-svih-racuna.html", data=response), 200)

    else:
        try:
            response = get_all_receipts()

        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("prodaja-ispis-svih-racuna.html", data=response), 200)

# PRIKAZ DETALJA O RAČUNU


@prodaja.route("/prodaja/detalji-racuna/<int:id>", methods=['GET'])
def getReceipt(id):
    try:
        response = get_receipt(id)

    except Exception as err:
        return make_response(render_template("fail.html", error=err), 400)
    return make_response(render_template("prodaja-detalji-racuna.html", data=response), 200)

# STORNIRANJE RAČUNA


@prodaja.route("/prodaja/storniranje-racuna/<int:id>", methods=['GET'])
def removeReceipt(id):
    try:
        table = 'racun_prodaje'
        receiptData = get_item('racun_prodaje', id)

        # brisanje racuna
        response = delete_item(table, id)

        # vracanje statusa automobila sa racuna na 'Dostupan'
        dataToEdit = {
            "id": receiptData.get('id_auto'),
            "dostupnost": "DA"
        }
        response = edit_table('auto', dataToEdit)

    except Exception as err:
        return make_response(render_template("fail.html", error=err), 400)
    return make_response(render_template("success.html", data={"msg": "Račun uspješno storniran!", "route": "/prodaja/ispis-svih-racuna"}), 200)

# @prodaja.route
