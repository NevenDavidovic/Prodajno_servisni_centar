from flask import Flask, Blueprint, render_template, request, make_response, jsonify
from statsFunctions import uslugePoTipuMotora, najviseUtrosenihDjelova, zaspoleniciSaNajviseServisa, zaposleniciPoNajvisojCijeni, racuniPoKupcu, topSkupiDijelovi, topProdavaci, topMarkeAutomobila, mjesečniPrihodiProdaja, mjesečniPrihodiServis, prodanihAutaPoMjesecima, servisiranihAutaPoMjesecima
from db_CRUDE import add_item, delete_item, get_all_items, find_item, edit_table, get_item, find_item_like, konverzijaSnageMotora, konverzijaKuneEuri


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
        responses.append(topProdavaci())
        responses.append(topMarkeAutomobila())
        responses.append(mjesečniPrihodiProdaja())
        responses.append(mjesečniPrihodiServis())
        responses.append(prodanihAutaPoMjesecima())
        responses.append(servisiranihAutaPoMjesecima())

        # data za grafove
        table1_labels = [str(obj.get('tip_motora')).capitalize()
                         for obj in responses[0]]
        table1_data = [int(obj.get('ukupno_izvrsenih_usluga'))
                       for obj in responses[0]]

        table3_labels = [str(obj.get('Ime_i_prezime')).capitalize()
                         for obj in responses[2]]
        table3_data = [obj.get('broj_servisa') for obj in responses[2]]

        table4_labels = [str(obj.get('Ime_i_prezime')).capitalize()
                         for obj in responses[2]]
        table4_data = [int(obj.get('ukupno_po_servisu'))
                       for obj in responses[3]]

        table6_labels = [str(obj.get('serijski_broj')).capitalize(
        ) + ' ' + str(obj.get('opis').capitalize()) for obj in responses[5]]
        table6_data = [float(obj.get('nabavna_cijena'))
                       for obj in responses[5]]

        table7_labels = [str(obj.get('ime')).capitalize()
                         for obj in responses[6]]
        table7_data = [int(obj.get('ukupno_prodanih_vozila'))
                       for obj in responses[6]]

        table8_labels = [str(obj.get('marka_automobila')).capitalize()
                         for obj in responses[7]]
        table8_data = [int(obj.get('broj_prodanih_vozila'))
                       for obj in responses[7]]

        table9_labels = [str(obj.get('mjesec')).capitalize()
                         for obj in responses[8]]
        table9_data = [int(obj.get('prihodi')) for obj in responses[8]]

        table10_labels = [str(obj.get('mjesec')).capitalize()
                          for obj in responses[9]]
        table10_data = [int(obj.get('ukupna_cijena_servisa'))
                        for obj in responses[9]]

        table11_labels = [str(obj.get('mjesec')).capitalize()
                          for obj in responses[10]]
        table11_data = [int(obj.get('kolicina'))
                        for obj in responses[10]]

        table12_labels = [str(obj.get('mjesec')).capitalize()
                          for obj in responses[11]]
        table12_data = [int(obj.get('kolicina'))
                        for obj in responses[11]]

    except Exception as err:
        return make_response(render_template("fail.html", error=err), 400)

    return make_response(render_template("administracija-statistika.html", data=responses,
                                         x_table1=table1_labels,
                                         y_table1=table1_data,

                                         x_table3=table3_labels,
                                         y_table3=table3_data,

                                         x_table4=table4_labels,
                                         y_table4=table4_data,

                                         x_table6=table6_labels,
                                         y_table6=table6_data,

                                         x_table7=table7_labels,
                                         y_table7=table7_data,

                                         x_table8=table8_labels,
                                         y_table8=table8_data,

                                         x_table9=table9_labels,
                                         y_table9=table9_data,

                                         x_table10=table10_labels,
                                         y_table10=table10_data,

                                         x_table11=table11_labels,
                                         y_table11=table11_data,

                                         x_table12=table12_labels,
                                         y_table12=table12_data,

                                         ), 200)

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
        return make_response(render_template("success.html", data={"msg": "Zaposlenik uspješno dodan!", "route": "/administracija/ispis-svih-zaposlenika"}), 200)
    else:
        return make_response(render_template("administracija-dodavanje-novog-zaposlenika.html"), 200)

# ruta za ispis svih zaposlenika


@administracija.route("/administracija/ispis-svih-zaposlenika", methods=['POST', 'GET'])
def getEmployers():
    if request.method == "POST":
        try:
            queryData = {}
            for key, value in request.form.items():
                queryData[key] = value

            table = 'zaposlenik'
            attribut = queryData['identificator']
            value = queryData['query']

            response = find_item_like(table, attribut, value)
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
    return make_response(render_template("success.html", data={"msg": "Uspješno izbrisan zaposlenik!", "route": "/administracija/ispis-svih-zaposlenika"}), 200)

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
        return make_response(render_template("success.html", data={"msg": "Podaci o zaposleniku uspješno promjenjeni!", "route": "/administracija/ispis-svih-zaposlenika"}), 200)
    else:
        try:
            table = 'zaposlenik'
            response = get_item(table, id)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("administracija-uredivanje-zaposlenika.html", data=response), 200)


# ruta za ispis svih usluga

@administracija.route("/administracija/ispis-svih-usluga", methods=['POST', 'GET'])
def getServices():
    if request.method == "POST":
        try:
            table = 'usluga_servis'
            attribut = 'naziv'
            value = request.form.get('naziv')
            response = find_item_like(table, attribut, value)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("administracija-ispis-svih-usluga.html", data=response), 200)
    else:
        try:
            table = 'usluga_servis'
            response = get_all_items(table)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("administracija-ispis-svih-usluga.html", data=response), 200)


# ruta za dodavanje nove usluge

@administracija.route("/administracija/dodavanje-nove-usluge", methods=['POST', 'GET'])
def addService():
    if request.method == "POST":
        try:
            table = 'usluga_servis'
            data = {}
            for key, value in request.form.items():
                data[key] = value

            add_item(table, data)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("success.html", data={"msg": "Usluga uspješno dodana!", "route": "/administracija/ispis-svih-usluga"}), 200)
    else:
        return make_response(render_template("administracija-dodavanje-nove-usluge.html"), 200)


# ruta za brisanje određene usluge


@administracija.route("/administracija/brisanje-usluge/<int:id>", methods=['GET'])
def deleteService(id):
    try:
        table = 'usluga_servis'
        delete_item(table, id)
    except Exception as err:
        return make_response(render_template("fail.html", error=err), 400)
    return make_response(render_template("success.html", data={"msg": "Uspješno izbrisana usluga!", "route": "/administracija/ispis-svih-usluga"}), 200)


# ruta za uredivanje podataka o usluzi


@administracija.route("/administracija/uredivanje-usluge/<int:id>", methods=['POST', 'GET'])
def editService(id):
    if request.method == "POST":
        try:
            table = 'usluga_servis'
            data = {}
            for key, value in request.form.items():
                data[key] = value
            data["id"] = id

            edit_table(table, data)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("success.html", data={"msg": "Podaci o usluzi uspješno promjenjeni!", "route": "/administracija/ispis-svih-usluga"}), 200)
    else:
        try:
            table = 'usluga_servis'
            response = get_item(table, id)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("administracija-uredivanje-usluge.html", data=response), 200)


# ruta za ispis svih automobila

@administracija.route("/administracija/ispis-svih-automobila", methods=['POST', 'GET'])
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
        return make_response(render_template("administracija-ispis-svih-automobila.html", data=response), 200)
    else:
        try:
            table = 'auto'
            response = get_all_items(table)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("administracija-ispis-svih-automobila.html", data=response), 200)

# ruta za prikaz određenog automobila


@administracija.route("/administracija/prikaz-automobila/<int:id>", methods=['GET'])
def getCar(id):
    try:
        table = 'auto'
        response = get_item(table, id)
        oprema = find_item('oprema_vozila', 'id_auto', id)
        # print(oprema)

        idList = []
        for item in oprema:
            idList.append(item['id_oprema'])
        # print(idList)

        opremaData = []
        for item in idList:
            opremaData.append(get_item('oprema', item))
        # print(opremaData)

    except Exception as err:
        return make_response(render_template("fail.html", error=err), 400)
    return make_response(render_template("administracija-prikaz-automobila.html", data={"auto": response, "oprema": opremaData}), 200)

# ruta za brisanje određenog automobila


@administracija.route("/administracija/brisanje-automobila/<int:id>", methods=['GET'])
def deleteCar(id):
    try:
        table = 'auto'
        delete_item(table, id)
    except Exception as err:
        return make_response(render_template("fail.html", error=err), 400)
    return make_response(render_template("success.html", data={"msg": "Uspješno izbrisan automobil!", "route": "/administracija/ispis-svih-automobila"}), 200)

# ruta za dodavanje novog automobila


@administracija.route("/administracija/dodavanje-novog-automobila", methods=['POST', 'GET'])
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
        return make_response(render_template("success.html", data={"msg": "Automobil uspješno dodan!", "route": "/administracija/ispis-svih-automobila"}), 200)
    else:
        return make_response(render_template("administracija-dodavanje-novog-automobila.html"), 200)

# ruta za uredivanje podataka o automobilu


@administracija.route("/administracija/uredivanje-automobila/<int:id>", methods=['POST', 'GET'])
def editCar(id):
    if request.method == "POST":
        try:
            table = 'auto'
            data = {}
            for key, value in request.form.items():
                if key == 'godina_proizvodnje':
                    value = value + '-01-01'
                data[key] = value
            data["id"] = id

            edit_table(table, data)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("success.html", data={"msg": "Podaci o automobilu uspješno promjenjeni!", "route": "/administracija/ispis-svih-automobila"}), 200)
    else:
        try:
            table = 'auto'
            response = get_item(table, id)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("administracija-uredivanje-automobila.html", data=response), 200)

# ruta za ispis sve opreme


@administracija.route("/administracija/ispis-sve-opreme", methods=['POST', 'GET'])
def getEquipment():
    if request.method == "POST":
        try:
            queryData = {}
            for key, value in request.form.items():
                queryData[key] = value

            table = 'oprema'
            attribut = queryData['identificator']
            value = queryData['query']

            response = find_item_like(table, attribut, value)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("administracija-ispis-sve-opreme.html", data=response), 200)
    else:
        try:
            table = 'oprema'
            response = get_all_items(table)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("administracija-ispis-sve-opreme.html", data=response), 200)

# ruta za brisanje određene opreme


@administracija.route("/administracija/brisanje-opreme/<int:id>", methods=['GET'])
def deleteEquipment(id):
    try:
        table = 'oprema'
        delete_item(table, id)
    except Exception as err:
        return make_response(render_template("fail.html", error=err), 400)
    return make_response(render_template("success.html", data={"msg": "Uspješno izbrisana oprema!", "route": "/administracija/ispis-sve-opreme"}), 200)

# ruta za dodavanje nove opreme


@administracija.route("/administracija/dodavanje-nove-opreme", methods=['POST', 'GET'])
def addEquipment():
    if request.method == "POST":
        try:
            table = 'oprema'
            data = {}
            for key, value in request.form.items():
                data[key] = value

            add_item(table, data)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("success.html", data={"msg": "Oprema uspješno dodana!", "route": "/administracija/ispis-sve-opreme"}), 200)
    else:
        return make_response(render_template("administracija-dodavanje-nove-opreme.html"), 200)

# ruta za uredivanje podataka o opremi


@administracija.route("/administracija/uredivanje-opreme/<int:id>", methods=['POST', 'GET'])
def editEquipment(id):
    if request.method == "POST":
        try:
            table = 'oprema'
            data = {}
            for key, value in request.form.items():
                data[key] = value
            data["id"] = id

            edit_table(table, data)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("success.html", data={"msg": "Podaci o opremi uspješno promjenjeni!", "route": "/administracija/ispis-sve-opreme"}), 200)
    else:
        try:
            table = 'oprema'
            response = get_item(table, id)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("administracija-uredivanje-opreme.html", data=response), 200)

# ruta za ispis svih klijenata


@administracija.route("/administracija/ispis-svih-klijenata", methods=['POST', 'GET'])
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
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("administracija-ispis-svih-klijenata.html", data=response), 200)
    else:
        try:
            table = 'klijent'
            response = get_all_items(table)
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("administracija-ispis-svih-klijenata.html", data=response), 200)


# ruta za brisanje određenog klijenta


@administracija.route("/administracija/brisanje-klijenta/<int:id>", methods=['GET'])
def deleteClient(id):
    try:
        table = 'klijent'
        delete_item(table, id)
    except Exception as err:
        return make_response(render_template("fail.html", error=err), 400)
    return make_response(render_template("success.html", data={"msg": "Uspješno izbrisan klijent!", "route": "/administracija/ispis-svih-klijenata"}), 200)


# ruta za dodavanje opreme automobilu

@administracija.route("/administracija/dodavanje-opreme-automobilu", methods=['POST', 'GET'])
def addCarEquipment():
    if request.method == "POST":
        try:
            data = {
                "id_auto": request.args.get('auto_id'),
                "id_oprema": request.args.get('oprema_id')
            }

            for key, value in request.form.items():
                data[key] = value

            table = 'oprema_vozila'

            add_item(table, data)

        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("success.html", data={"msg": "Oprema uspješno dodana!", "route": "/administracija/ispis-svih-automobila"}), 200)

    else:
        try:
            table = 'auto'
            response = get_item(table, request.args.get('auto_id'))
            oprema = find_item('oprema_vozila', 'id_auto',
                               request.args.get('auto_id'))

            idList = []
            for item in oprema:
                idList.append(item['id_oprema'])

            pOpremaData = []
            for item in idList:
                pOpremaData.append(get_item('oprema', item))

            autoData = get_item('auto', request.args.get('auto_id'))
            opremaData = get_item('oprema', request.args.get('oprema_id'))

        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("administracija-dodavanje-opreme-automobilu.html", data={"auto": autoData, "oprema": opremaData, "p_oprema": pOpremaData}), 200)

# ruta za ispis sve opreme (u svrhu dodavanja na automobil)


@administracija.route("/administracija/ispis-sve-opreme-za-automobil", methods=['POST', 'GET'])
def getCarEquipment():
    if request.method == "POST":
        try:
            queryData = {}
            for key, value in request.form.items():
                queryData[key] = value

            table = 'oprema'
            attribut = queryData['identificator']
            value = request.form.get('query')

            response = find_item_like(table, attribut, value)
            autoData = get_item('auto', request.args.get('auto_id'))
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("administracija-ispis-sve-opreme-za-automobil.html", data={"auto": autoData, "oprema": response}), 200)
    else:
        try:
            table = 'oprema'
            response = get_all_items(table)
            autoData = get_item('auto', request.args.get('auto_id'))
        except Exception as err:
            return make_response(render_template("fail.html", error=err), 400)
        return make_response(render_template("administracija-ispis-sve-opreme-za-automobil.html", data={"auto": autoData, "oprema": response}), 200)

# ruta za dodavanje zaposlenika kao klijenta


@administracija.route("/administracija/dodavanje-zaposlenika-kao-klijenta/<int:id>", methods=['GET'])
def addEmployerAsClient(id):
    try:
        # dohvacanje podataka o zaposleniku
        zaposlenikData = get_item('zaposlenik', id)
        table = 'klijent'
        # uzimanje relevantnih podataka za klijenta od zaposlenika
        data = {
            "oib": zaposlenikData.get('oib'),
            "ime": zaposlenikData.get('ime'),
            "prezime": zaposlenikData.get('prezime'),
            "broj_telefona": zaposlenikData.get('broj_telefona'),
            "adresa": zaposlenikData.get('adresa'),
            "grad": zaposlenikData.get('grad'),
            "spol": zaposlenikData.get('spol')
        }
        # dodavanje klijenta
        add_item(table, data)
    except Exception as err:
        return make_response(render_template("fail.html", error=err), 400)
    return make_response(render_template("success.html", data={"msg": "Zaposlenik uspješno dodan kao klijent!", "route": "/administracija/ispis-svih-klijenata"}), 200)


# ruta za konverziju snage motora (procedura)

@administracija.route("/administracija/konverzija-snage-motora/", methods=['POST'])
def enginePowerConversion():
    try:
        konverzijaSnageMotora()
    except Exception as err:
        return make_response(render_template("fail.html", error=err), 400)
    return make_response(render_template("success.html", data={"msg": "Snaga motora uspješno pretvorena iz KW u BHP!", "route": "/administracija/ispis-svih-automobila"}), 200)


# ruta za konverziju kuna u eure (procedura)

@administracija.route("/administracija/konverzija-kuna-u-eure/", methods=['POST'])
def moneyConversion():
    try:
        konverzijaKuneEuri()
    except Exception as err:
        return make_response(render_template("fail.html", error=err), 400)
    return make_response(render_template("success.html", data={"msg": "Uspješno ste promjenili cijenu iz kuna u eure! Sretno!", "route": "/"}), 200)
