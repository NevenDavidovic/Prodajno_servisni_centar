from flask import Flask, Blueprint, render_template, request, make_response, jsonify
from statsFunctions import uslugePoTipuMotora, najviseUtrosenihDjelova, zaspoleniciSaNajviseServisa, zaposleniciPoNajvisojCijeni, racuniPoKupcu, topSkupiDijelovi
from db_CRUDE import add_item, delete_item, get_all_items, find_item, edit_table, get_item,find_item_like


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
            response = find_item_like(table, attribut, value)
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

# uredivanje dijela   
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
    
#brisanje dijela  
@servis.route("/servis/brisanje-dijelova/<int:id>", methods=['GET'])
def deleteDio(id):
    try:
        table = 'dio'
        delete_item(table, id)
    except Exception as err:
        return make_response(render_template("fail.html", error=err), 400)
    return make_response(render_template("success.html", data={"msg": "Uspješno izbrisan dio!", "route": "/servisi/ispis"}), 200)

#dodavanje dijela
@servis.route("/servis/dodavanje", methods=['POST', 'GET'])
def addDio():
    if request.method == "POST":
        try:
            table = 'dio'
            data = {}
            for key, value in request.form.items():
                data[key] = value

            add_item(table, data)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("success.html", data={"msg": "Dio uspješno dodan!", "route": "/servisi/ispis"}), 200)
    
        #return make_response(render_template("servis-dio-dodaj.html"), 200) 
    return render_template("servis-dio-dodaj.html")    
            
  
  # napravi servis 

# dodaj sve podatke o dijelu
@servis.route("/servis/stavka-dio-dodaj", methods=['GET','POST'])
def add_stavkaDio():
    if request.method == "POST":
        try:
            table = 'stavka_dio'
            data = {}
            for key, value in request.form.items():
                data[key] = value

            add_item(table, data)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("success.html", data={"msg": "Dio uspješno dodan!", "route": "/servis/stavka-dio-ispis"}), 200)
    
    response = get_all_items('dio')
    
    return render_template("servis-stavka-dio-dodaj.html",data=response) 

@servis.route("/servis/stavka-dio-ispis", methods=['GET','POST'])
def ispisStavkaDio():
    if request.method == "POST":
        try:
            table = 'stavka_dio'
            attribut = 'naziv'
            value = request.form.get('naziv')
            response = find_item(table, attribut, value)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("servis-stavka-dio-ispis.html", data=response), 200)
    else:
        try:
            table = 'stavka_dio'
            response = get_all_items(table)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("servis-stavka-dio-ispis.html", data=response), 200)

# Svašta nešta treba promijeniti