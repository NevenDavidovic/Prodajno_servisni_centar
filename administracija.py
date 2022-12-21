from flask import Flask, Blueprint, render_template, request, make_response, jsonify
from statsFunctions import uslugePoTipuMotora, najviseUtrosenihDjelova, zaspoleniciSaNajviseServisa, zaposleniciPoNajvisojCijeni, racuniPoKupcu, topSkupiDijelovi
from db_CRUDE import add_item, delete_item, get_all_items, find_item, edit_table


administracija = Blueprint("administracija", __name__)


# RUTE

# ruta za statistiku
@administracija.route("/stats", methods=['GET'])
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

    return make_response(render_template("stats.html", data=responses), 200)

# ruta za dodavanje novog zaposlenika


@administracija.route("/administracija/dodavanje-novog-zaposlenika", methods=['POST', 'GET'])
def addEmployer():
    if request.method == "POST":
        try:
            table = 'zaposlenik'
            keys = ["ime", "prezime", "datum_rodenja", "adresa", "grad", "spol",
                    "broj_telefona", "datum_zaposlenja", "e_mail", "placa", "radno_mjesto"]
            data = {key: request.form.items() for key in keys}
            response = add_item(table, data)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("success.html"), 200)
    else:
        return make_response(render_template("dodavanje-novog-zaposlenika.html"), 200)
