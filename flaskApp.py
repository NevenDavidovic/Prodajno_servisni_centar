from flask import Flask, Blueprint, render_template, request, make_response, jsonify
from statsFunctions import uslugePoTipuMotora,najviseUtrosenihDjelova,zaspoleniciSaNajviseServisa,zaposleniciPoNajvisojCijeni,racuniPoKupcu,topSkupiDijelovi
import mysql.connector

app = Flask(__name__)


# Home page route
@app.route("/")
@app.route("/home")
@app.route("/index")
def home():
    return render_template("index.html")

# rute za testiranje fail/success pagea
@app.route("/ok")
def displayOK():
       return make_response(render_template("success.html",data={"msg":"Operation success! Be happy!"}),200) 
@app.route("/fail")
def displayFail():
       return make_response(render_template("fail.html",error="There was a big nasty ERROR!"),400) 


@app.route("/stats", methods=['GET'])
def showStats():
        # pozivi bazi podataka
        try:
                response1 = uslugePoTipuMotora()
                response2 = najviseUtrosenihDjelova()
                response3 = zaspoleniciSaNajviseServisa()
                response4 = zaposleniciPoNajvisojCijeni()
                response5 = racuniPoKupcu()
                response6 = topSkupiDijelovi()
                print(response6)
        except Exception as err:
                return make_response(render_template("fail.html",error=err),400)   

        return make_response(render_template("stats.html",data1=response1,data2=response2,data3=response3,data4=response4,data5=response5,data6=response6), 200)    
    
if __name__ == '__main__':
    app.run(port=8080, host='0.0.0.0', debug=True)
