from flask import Flask, Blueprint, render_template, request, make_response, jsonify
from statsFunctions import uslugePoTipuMotora, najviseUtrosenihDjelova, zaspoleniciSaNajviseServisa, zaposleniciPoNajvisojCijeni, racuniPoKupcu, topSkupiDijelovi
from db_CRUDE import add_item, delete_item, get_all_items, find_item, edit_table, get_item


servis = Blueprint("servis", __name__)

# NEVEN START
# rute
@servis.route("/servisi/ispis", methods=['GET','POST'])
def ispisiServis():
    
     if request.method == "POST":
        try:
            table = 'dio'
            attribut = 'naziv'
            value = request.form.get('naziv')
            response = find_item(table, attribut, value)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("servis-dio-ispis.html", data=response), 200)
     else:
        try:
            table = 'dio'
            response = get_all_items(table)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("servis-dio-ispis.html", data=response), 200)
    
@servis.route("/servis/uredivanje-dijelova/<int:id>", methods=['POST', 'GET'])
def urediDio(id):
    if request.method == "POST":
        try:
            table = 'dio'
            data = {}
            for key, value in request.form.items():
                data[key] = value
            data["id"] = id

            edit_table(table, data)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("success.html", data={"msg": "Podaci o dijelu su uspješno promjenjeni!", "route": "/servisi/ispis"}), 200)
    else:
        try:
            table = 'dio'
            response = get_item(table, id)
            # print(response)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("servis-dio-uredivanje.html", data=response), 200)
    
    
@servis.route("/servis/brisanje-dijelova/<int:id>", methods=['GET'])
def deleteDio(id):
    try:
        table = 'dio'
        delete_item(table, id)
    except Exception as err:
        return make_response(render_template("fail.html", error=err), 400)
    return make_response(render_template("success.html", data={"msg": "Uspješno izbrisan dio!", "route": "/servisi/ispis"}), 200)

    
        
            
    




