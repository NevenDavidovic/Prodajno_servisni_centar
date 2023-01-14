from flask import Flask, render_template, make_response
from db_CRUDE import add_item, delete_item, get_all_items, find_item, edit_table


from administracija import administracija
from prodaja import prodaja
from servis import servis


app = Flask(__name__)
app.register_blueprint(administracija)
app.register_blueprint(prodaja)
app.register_blueprint(servis)

# naslovnica


@app.route("/")
def naslovnica():
    return render_template('index.html')

# rute za testiranje fail/success pagea


@app.route("/ok")
def displayOK():
    return make_response(render_template("success.html", data={"msg": "Operation success! Be happy!"}), 200)


@app.route("/fail")
def displayFail():
    return make_response(render_template("fail.html", error="There was a big nasty ERROR!"), 400)


if __name__ == "__main__":
    app.run(port=8080, host='0.0.0.0', debug=True)
