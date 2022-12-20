from flask import Flask, render_template
# from db_CRUDE import ...


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


if __name__ == "__main__":
    app.run()
