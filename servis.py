from flask import Flask, Blueprint, render_template, request, make_response, jsonify
from statsFunctions import uslugePoTipuMotora, najviseUtrosenihDjelova, zaspoleniciSaNajviseServisa, zaposleniciPoNajvisojCijeni, racuniPoKupcu, topSkupiDijelovi
from db_CRUDE import add_item, delete_item, get_all_items, find_item, edit_table, get_item, find_item_like, get_last_record_identificator, get_all_cars_for_servis
import mysql.connector
from db_CRUDE import add_item, delete_item, get_all_items, find_item, edit_table, get_all_cars_for_sale, get_item, find_item_like, get_last_record_identificator


servis = Blueprint("servis", __name__)

# NEVEN START
# rute


@servis.route("/servisi/ispis", methods=['GET', 'POST'])
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

# brisanje dijela


@servis.route("/servis/brisanje-dijelova/<int:id>", methods=['GET'])
def deleteDio(id):
    try:
        table = 'dio'
        delete_item(table, id)
    except Exception as err:
        return make_response(render_template("fail.html", error=err), 400)
    return make_response(render_template("success.html", data={"msg": "Uspješno izbrisan dio!", "route": "/servisi/ispis"}), 200)

# dodavanje dijela


@servis.route("/servis/dodavanje", methods=['POST', 'GET'])
def addDio():
    
    if request.method == "POST":
        try:
            table = 'dio'
            data = {}
            for key, value in request.form.items():
                data[key] = value
            
            add_item(table, data)
                   
           
            dio=get_all_items('dio')
            
        except Exception as err:
            return make_response(render_template("dodavanje-dijela-fail.html", error=err,data={"msg": "Odaberi već postojećeg proizvođača i naziv", "route": "/servis/stavka-dio-dodaj/<naziv>/<proizvodac>"},datan=data), 400)
        return make_response(render_template("dodavanje-dijela-success.html",data=data,dio=dio), 200)
    
        #return make_response(render_template("servis-dio-dodaj.html"), 200) 
    return render_template("servis-dio-dodaj.html")    

# dodaj sve podatke o dijelu

@servis.route("/servis/stavka-dio-dodaj/<naziv>/<proizvodac>", methods=['GET','POST'])
def add_stavkaDio(naziv,proizvodac):
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
    
    return render_template("servis-stavka-dio-dodaj.html",data=response,naziv=naziv,proizvodac=proizvodac)


@servis.route("/servis/stavka-dio-dodaj", methods=['GET','POST'])
def add_stavka_Dio():
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


@servis.route("/servis/stavka-dio-ispis", methods=['GET', 'POST'])
def ispisStavkaDio():
    if request.method == "POST":
        try:
            table = 'dijelovi'
            attribut = 'naziv'
            value = request.form.get('naziv')
            response = find_item_like(table, attribut, value)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("servis-stavka-dio-ispis.html", data=response), 200)
    else:
        try:
            table = 'dijelovi'
            response = get_all_items(table)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("servis-stavka-dio-ispis.html", data=response), 200)

# napravi uređivanje


@servis.route("/servis/stavka-uredivanje-dijelova/<int:id>", methods=['POST', 'GET'])
def urediStavkaDio(id):
    if request.method == "POST":
        try:
            table = 'stavka_dio'
            data = {}
            #print(data)
            for key, value in request.form.items():
                data[key] = value
            data["id"] = id

            edit_table(table, data)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("success.html", data={"msg": "Podaci o dijelu su uspješno promjenjeni!", "route": "/servis/stavka-dio-ispis"}), 200)
    else:
        try:
            table = 'stavka_dio'
            tabla = 'dio'
            response = get_item(table, id)
            dio = get_all_items(tabla)
            id_dio = get_item(table, id)

            # print(response)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("servis-stavka-dio-uredivanje.html", data=response, dio=dio, dio1=id_dio), 200)

# delete dio


@servis.route("/servis/stavka-brisanje-dijelova/<int:id>", methods=['GET'])
def deleteStavkaDio(id):
    try:
        table = 'stavka_dio'
        delete_item(table, id)
    except Exception as err:
        return make_response(render_template("fail.html", error=err), 400)
    return make_response(render_template("success.html", data={"msg": "Uspješno izbrisan dio!", "route": "/servis/stavka-dio-ispis"}), 200)

# ispis narudzbenice

@servis.route('/narudzbenica/popis', methods=['GET','POST'])
def ispisNarudzbenice():

        if request.method == "POST":
            try:
                queryData = {}
                for key, value in request.form.items():
                    queryData[key] = value

                table = 'narudzbenicej'
                attribut = queryData['identificator']
                value = queryData['query']

                response = find_item_like(table, attribut, value)
            
            except Exception as err:
                return make_response(render_template("fail.html", error=err), 400)
                
            return make_response(render_template("servis-narudzbenice-ispis.html", data=response), 200)
        else:
            try:
                table = 'narudzbenicej'
                response = get_all_items(table)
            except Exception as err:
                return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("servis-narudzbenice-ispis.html", data=response), 200)
    
@servis.route("/servis/narudzbenica/popis/<int:id>", methods=['GET','POST'])
def infoNarudzbenice(id):
    if request.method == "POST":
        try:
            queryData = {}
            for key, value in request.form.items():
                queryData[key] = value

            table = 'narudzbenicej'
            attribut = queryData['identificator']
            value = queryData['query']

            response = find_item_like(table, attribut, value)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("servis-narudzbenice-ispis.html", data=response), 200)
    
    a=int(id)
    
    table = 'narudzbenicej'
    response = get_item(table,a)
    #print(response)
    
    return render_template("servis-narudzbenice-vise-info.html", data=response)


# brisanje narudzbenice


@servis.route("/servis/brisanje-narudzbenica/<int:id>", methods=['GET'])
def deleteNarudzbenica(id):
    try:
        table = 'narudzbenica'
        delete_item(table, id)
    except Exception as err:
        return make_response(render_template("fail.html", error=err), 400)
    return make_response(render_template("success.html", data={"msg": "Uspješno izbrisana narudzbenica!", "route": "/narudzbenica/popis"}), 200)

# dodavanje narudzbenice-ispis svih automobila


@servis.route("/servis/ispis-svih-automobila", methods=['POST', 'GET'])
def getAuti():
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
        return make_response(render_template("servis-narudzbenica-ispis-automobila.html", data=response), 200)
    else:
        try:
            table = 'auto' 
            response = get_all_items(table)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("servis-narudzbenica-ispis-automobila.html", data=response), 200)

# dodavanje narudzbenice- prikaz auta


@servis.route("/servis/prikaz-auta/<int:id>", methods=['GET'])
def getAUToo(id):
    try:
        table = 'auto'
        response = get_item(table, id)

    except Exception as err:
        return make_response(render_template("fail.html", error=err), 400)
    return make_response(render_template("servis-narudzbenica-prikaz-auta.html", data=response), 200)

# dodavanje narudzbenice -prikaz svih klijenata

# ISPIS SVIH KLIJENATA


@servis.route("/servis/ispis-svih-klijenata", methods=['POST', 'GET'])
def getKlijent():
    if request.method == "POST":
        try:
            table = 'klijent'
            attribut = 'ime'
            value = request.form.get('ime')
            response = find_item_like(table, attribut, value)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("servis-narudzbenica-ispis-klijenata.html", data=response), 200)
    else:
        try:
            table = 'klijent'
            response = get_all_items(table)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("servis-narudzbenica-ispis-klijenata.html", data=response), 200)


# dodavanje narudzbenice-finale

@servis.route("/servis/dodavanje-narudzbenice", methods=['POST', 'GET'])
def createNarudzbenica():
    if request.method == "POST":
        try:

            # kreiranje dictionary sa svim atributima potrebnim za tablicu racun_prodaje
            # neki podaci su dobiveni iz argumenata rute, neki iz forme sa stranice, broj racuna preko funkcije

            brojNarudzbe = get_last_record_identificator(
                'narudzbenica', 'broj_narudzbe') + 1
            data = {
                "id_auto": request.args.get('car_id'),
                "id_klijent": request.args.get('klijent_id'),
                "broj_narudzbe": brojNarudzbe
            }
            # dodavanje podataka iz forme u dictionary data
            for key, value in request.form.items():
                data[key] = value

            table = 'narudzbenica'
            # dodavanje narudzbenice u tablicu narudzbenica
            response = add_item(table, data)
            # označavanje prodanog auta kao nedostupnog
            dataToEdit = {
                "id": request.args.get('car_id'),
                "dostupnost": "NE"
            }
            response = edit_table('auto', dataToEdit)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("success.html", data={"msg": "Narudžbenica uspješno dodana!", "route": "/narudzbenica/popis"}), 200)

    else:
        try:
            autoData = get_item('auto', request.args.get('car_id'))
            klijentData = get_item('klijent', request.args.get('klijent_id'))
            brojNarudzbe = get_last_record_identificator(
                'narudzbenica', 'broj_narudzbe')+1

        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("servis-narudzbenica-dodaj.html", data={"auto": autoData, "klijent": klijentData, "broj_narudzbe": brojNarudzbe}), 200)


# Unos novog automobila na servis
@servis.route("/servis/dodavanje-novog-automobila", methods=['POST', 'GET'])
def addCar():
    if request.method == "POST":
        try:
            table = 'auto'
            data = {}
            for key, value in request.form.items():
                if key == 'godina_proizvodnje':
                    value = value + '-01-01'
                data[key] = value

            add_item(table, data)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("success.html", data={"msg": "Automobil uspješno dodan!", "route": "/servis/ispis-svih-automobila"}), 200)
    else:
        return make_response(render_template("servis-dodavanje-novog-automobila.html"), 200)


# ruta za dodavanje novog klijenta
@servis.route("/servis/dodavanje-novog-klijenta", methods=['POST', 'GET'])
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
        return make_response(render_template("success.html", data={"msg": "Klijent uspješno dodan!", "route": "/servis/svi-klijenti"}), 200)
    else:
        return make_response(render_template("servis-dodavanje-novog-klijenta.html"), 200)

# ruta za ispis svih klijenata


@servis.route("/servis/svi-klijenti", methods=['POST', 'GET'])
def getClients():
    if request.method == "POST":
        try:
            queryData = {}
            for key, value in request.form.items():
                queryData[key] = value

            table = 'klijent'
            attribut = queryData['identificator']
            value = queryData['query']

            response = find_item_like(table, attribut, value)

            response = find_item_like(table, attribut, value)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("servis-ispis-svih-klijenata.html", data=response), 200)
    else:
        try:
            table = 'klijent'
            response = get_all_items(table)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("servis-ispis-svih-klijenata.html", data=response), 200)

# ruta za uredivanje pojedinog klijenta


@servis.route("/servis/uredivanje-klijenta/<int:id>", methods=['POST', 'GET'])
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
        return make_response(render_template("success.html", data={"msg": "Podaci o klijentu uspješno promjenjeni!", "route": "/servis/svi-klijenti"}), 200)
    else:
        try:
            table = 'klijent'
            response = get_item(table, id)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("servis-uredivanje-klijenta.html", data=response), 200)

# ruta za ispis servisa

@servis.route("/servis/ispis-servisa", methods=['POST', 'GET'])
def ispisPodatakaServis():
    if request.method == "POST":
        try:
            queryData = {}
            for key, value in request.form.items():
                queryData[key] = value

            table = 'podaci_o_servisu'
            attribut = queryData['identificator']
            value = queryData['query']

            response = find_item_like(table, attribut, value)
        
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
            
        return make_response(render_template("servis-servis-ispis.html", data=response), 200)
    else:
        try:
            table = 'podaci_o_servisu'
            response = get_all_items(table)
            
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
    return make_response(render_template("servis-servis-ispis.html", data=response), 200)

@servis.route("/servis/servis-popis/<id>", methods=['GET','POST'])
def info_servisServisi(id):
    if request.method == "POST":
        try:
            queryData = {}
            for key, value in request.form.items():
                queryData[key] = value

            table = 'podaci_o_servisu'
            attribut = queryData['identificator']
            value = queryData['query']

            response = find_item_like(table, attribut, value)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("servis-narudzbenice-ispis.html", data=response), 200)
    
   
    
    table = 'podaci_o_servisu'
    attribut='servis_id'
    response= find_item_like(table,attribut,id)
    tabla='dijelovi_po_servisu'
    attribute='dio_na_servisu_servis_id'
    dijelovi=find_item_like(tabla,attribute, id)
    
    #print(dijelovi)
    broj_dijelova=len(dijelovi)
    if int(broj_dijelova) ==0:
        return render_template("servis-servis-info-fail.html", data=response)
    
    return render_template("servis-servis-info.html", data=response,dijelovi=dijelovi)


@servis.route("/servis/brisanje-servis/<int:id>", methods=['GET'])
def deleteServisnilist(id):
    try:
        table = 'servis'
        delete_item(table, id)
    except Exception as err:
        return make_response(render_template("fail.html", error=err), 400)
    return make_response(render_template("success.html", data={"msg": "Uspješno izbrisan servisni list!", "route": "/servis/ispis-servisa"}), 200)

#dodavanje servisa

@servis.route("/servis/servis-dodaj-narudzbenicu", methods=['GET','POST'])
def getZaposlenik():
    if request.method == "POST":
        try:
            table = 'zaposlenik'
            attribut = 'prezime'
            value = request.form.get('prezime')
            response = find_item_like(table, attribut, value)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("servis-servis-dodavanje-zaposlenika.html", data=response), 200)
    else:
        try:
            table = 'zaposlenik'
            response = get_all_items(table)
            #print(response)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("servis-servis-dodavanje-zaposlenika.html", data=response), 200)
    
@servis.route("/servis/dodavanje-narudzbenice-zaposlenika", methods=['POST', 'GET'])
def addZaposlenik_toServis():
    if request.method == "POST":
        try:
            table = 'usluga_servis'
            attribut = 'naziv'
            value = request.form.get('naziv')
            response = find_item_like(table, attribut, value)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("servis-servis-dodavanje-usluga.html", data=response), 200)
    else:
        try:
            table = 'usluga_servis'
            response = get_all_items(table)
            #print(response)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("servis-servis-dodavanje-usluga.html", data=response), 200)
  
@servis.route("/servis/dodavanje-narudzbenice-komentara", methods=['POST', 'GET'])
def createServis():
    if request.method == "POST":
        try:

            # kreiranje dictionary sa svim atributima potrebnim za tablicu racun_prodaje
            # neki podaci su dobiveni iz argumenata rute, neki iz forme sa stranice, broj racuna preko funkcije

            komentar=request.form['komentar']
            data = {
                "id_narudzbenica": request.args.get('narudzbenica_id'),
                "id_zaposlenik": request.args.get('zaposlenik_id'),
                "id_usluga_servis": request.args.get('usluga_id'),
                "komentar": komentar
            }
            # dodavanje podataka iz forme u dictionary data
            for key, value in request.form.items():
                data[key] = value

        
            table = 'servis'
            # dodavanje računa u tablicu račun_prodaje
            response = add_item(table, data)
            # označavanje prodanog auta kao nedostupnog
            zadnji_Servis_id=get_last_record_identificator('servis','id')
            
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("servis-dodan-success.html", data={"msg": "Servis uspješno dodan!", "route": "/servis/ispis-servisa"}, servis_id=zadnji_Servis_id), 200)

    else:
        try:
            narudzbenica_ide = request.args.get('narudzbenica_id')
            zaposlenik_ide = request.args.get('zaposlenik_id')
            usluga=request.args.get('usluga_id')
            #usluga_id = request.args.get('usluga_id')
            narudzbenica_id=get_item('narudzbenica',narudzbenica_ide)
            zaposlenik_id= get_item('zaposlenik', zaposlenik_ide)
            usluga_id=get_item('usluga_servis',usluga)
            #print(narudzbenica_id)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("servis-servis-dodaj.html", narudzbenica= narudzbenica_id, zaposlenik= zaposlenik_id, usluga=usluga_id ), 200)
    
@servis.route("/servis/servis-dodaj-dio/<id>", methods=['GET','POST'] )
def dodajDio_naServis():
    
    svi_dijelovi=get_all_items('dijelovi')
    
    return render_template()
    
    
    
    
    