# Prodajno servisni centar automobila (PSC)

## Opis projekta

**Prodajno servisni centar automobila** je web aplikacija nastala za potrebe projekta unutar kolegija Baze podataka 2. Simulira rad unutar tri korisnička sučelja (administracija, prodaja i servis).

## Osnovne funkcionalnosti web aplikacije

### Administracija

Korisničko sučelje administracija nudi sljedeće mogućnosti:

* **dodavanje podataka** (zaposlenika, usluga, automobila i opreme)
* **ispis podataka** (zaposlenika, usluga, automobila, opreme i klijenata)
* **ažuriranje podataka** (zaposlenika, usluga, automobila i opreme)
* **brisanje podataka** (zaposlenika, usluga, automobila, opreme i klijenata)

### Prodaja

### Servis

## Specifične funkcionalnosti web aplikacije

*Navesti sve što nije CRUD i staviti screenshotove.*

## Lokalno pokretanje web aplikacije

### Na računalo je potrebno instalirati

* Python (https://www.python.org/downloads/)
* MySQL Workbench (https://www.mysql.com/products/workbench/)
* Virtual enviroment (https://www.youtube.com/watch?v=CHpQF1rdUMY)

*Koraci za instalaciju virtual enviromenta:*

1. Preuzmite repozitorij i raspakirajte ga
2. Otvorite terminal u datoteci u kojoj se nalazi projekt
3. Kako bi kreirali enviroment upišite:
`python -m venv myVenv`
4. Kako bi aktivirali enviroment upišite:
`.\myVenv\Scripts\activate`
5. Kako bi instalirali sve potrebno za rad aplikacije upišite: 
`pip install requirements.txt`

### Upute za lokalno pokretanje aplikacije

**Kreiranje baze podataka**

Za ispravan rad baze podataka, prije pokretanja aplikacije, potrebno je kreirati bazu podataka.

*Koraci za kreiranje baze podataka:*

1. Unutar MySQL Workbencha kreirati korisnika sa korisničkim imenom "**root**" i lozinkom "**root**"
2. Pokrenuti sljedeće sql fajlove unutar "**root**" korisnika sljedećim redosljedom:
    * Prodajno servisni centar.sql
    * db_data.sql
    * db_fpt.sql
    * db_q.sql

**Pokretanje aplikacije**

1. Otvorite terminal u datoteci u kojoj se nalazi projekt
2. Kako bi aktivirali enviroment upišite:
`.\myVenv\Scripts\activate`
3. Kako bi pokrenuli aplikaciju upišite:
`flask run`
4. Otvorite dobivenu lokalnu adresu u bilo kojem internet pregledniku