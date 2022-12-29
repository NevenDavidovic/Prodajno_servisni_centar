from flask import Flask, Blueprint, render_template, request, make_response, jsonify
from statsFunctions import uslugePoTipuMotora, najviseUtrosenihDjelova, zaspoleniciSaNajviseServisa, zaposleniciPoNajvisojCijeni, racuniPoKupcu, topSkupiDijelovi
from db_CRUDE import add_item, delete_item, get_all_items, find_item, edit_table, get_item


servis = Blueprint("servis", __name__)

# NEVEN START
# rute


# @servis.route
