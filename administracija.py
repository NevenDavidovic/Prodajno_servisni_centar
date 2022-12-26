from flask import Flask, Blueprint, render_template, request, make_response, jsonify
from statsFunctions import uslugePoTipuMotora, najviseUtrosenihDjelova, zaspoleniciSaNajviseServisa, zaposleniciPoNajvisojCijeni, racuniPoKupcu, topSkupiDijelovi
from db_CRUDE import add_item, delete_item, get_all_items, find_item, edit_table, get_item


administracija = Blueprint("administracija", __name__)


# RUTE

# ruta za statistiku
@administracija.route("/administracija/statistika", methods=['GET'])
def showStats():
    # pozivi bazi podataka
    responses = []
    try:
        responses.append(uslugePoTipuMotora())
        responses.append(najviseUtrosenihDjelova())
        responses.append(zaspoleniciSaNajviseServisa())
        responses.append(zaposleniciPoNajvisojCijeni())
        responses.append(racuniPoKupcu())
        responses.append(topSkupiDijelovi())

        print(responses[5])
    except Exception as err:
        return make_response(render_template("fail.html", error=err), 400)

    return make_response(render_template("administracija-statistika.html", data=responses), 200)

# ruta za dodavanje novog zaposlenika


@administracija.route("/administracija/dodavanje-novog-zaposlenika", methods=['POST', 'GET'])
def addEmployer():
    if request.method == "POST":
        try:
            table = 'zaposlenik'
            data = {}
            for key, value in request.form.items():
                data[key] = value

            add_item(table, data)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("success.html", data={"msg": "Zaposlenik uspješno dodan!"}), 200)
    else:
        return make_response(render_template("administracija-dodavanje-novog-zaposlenika.html"), 200)

# ruta za ispis svih zaposlenika


@administracija.route("/administracija/ispis-svih-zaposlenika", methods=['POST', 'GET'])
def getEmployers():
    if request.method == "POST":
        try:
            table = 'zaposlenik'
            attribut = 'ime'
            value = request.form.get('ime')
            response = find_item(table, attribut, value)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("administracija-ispis-svih-zaposlenika.html", data=response), 200)
    else:
        try:
            table = 'zaposlenik'
            response = get_all_items(table)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("administracija-ispis-svih-zaposlenika.html", data=response), 200)


# ruta za prikaz određenog zaposlenika

@administracija.route("/administracija/prikaz-zaposlenika/<int:id>", methods=['GET'])
def getEmployer(id):
    try:
        table = 'zaposlenik'
        response = get_item(table, id)
        
    except Exception as err:
        return make_response(render_template("fail.html", error=err), 400)
    return make_response(render_template("administracija-prikaz-zaposlenika.html", data=response), 200)

# ruta za brisanje određenog zaposlenika


@administracija.route("/administracija/brisanje-zaposlenika/<int:id>", methods=['GET'])
def deleteEmployer(id):
    try:
        table = 'zaposlenik'
        delete_item(table, id)
    except Exception as err:
        return make_response(render_template("fail.html", error=err), 400)
    return make_response(render_template("success.html", data={"msg": "Uspješno izbrisan zaposlenik!"}), 200)

# ruta za uredivanje podataka o zaposleniku


@administracija.route("/administracija/uredivanje-zaposlenika/<int:id>", methods=['POST', 'GET'])
def editEmployer(id):
    if request.method == "POST":
        try:
            table = 'zaposlenik'
            data = {}
            for key, value in request.form.items():
                data[key] = value
            data["id"] = id    
            
            edit_table(table, data)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("success.html", data={"msg": "Podaci o zaposleniku uspješno promjenjeni!"}), 200)
    else:
        try:
            table = 'zaposlenik'
            response = get_item(table, id)
            print(response)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("administracija-uredivanje-zaposlenika.html", data=response), 200)
