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

Korisničko sučelje prodaja nudi sljedeće mogućnosti:

* **dodavanje podataka** (računa, klijenata)
* **ispis podataka** (klijenata, računa, automobila)
* **ažuriranje podataka** (klijenata)
* **brisanje podataka** (računa)

### Servis

* **dodavanje podataka** (klijenta, narudžbenice, dijela, servisa, automobila)
* **ispis podataka** (klijenta, narudžbenice, dijela, servisa, automobila)
* **ažuriranje podataka** (narudžbenice, dijelova, servisa)
* **brisanje podataka** (narudžbenice, dijelova, servisa)

## Specifične funkcionalnosti web aplikacije

### Administracija

*Naslovna stranica*\
Mogućnost konverzije valute na cijeloj aplikaciji.

![](https://i.imgur.com/CT6jKgD.png)

*Na ruti /administracija/ispis-svih-automobila*\
Mogućnost konverzije snage motora svih automobila.

![](https://i.imgur.com/BVFUVhe.png)

*Kod automobila koji su dostupni za prodaju*\
Mogućnost dodavanja dodatne opreme automobilima.

![](https://i.imgur.com/7g5pnPJ.png)

*Na ruti /administracija/promet-dana/*\
Mogućnost kalkulacije dnevnih prometa (ukupnog, za prodaju i za servis).

![](https://i.imgur.com/P5CRb2m.png)

*Na ruti /administracija/statistika*\
Mogućnost pregleda statističkih podataka prikazanih u grafovima.

![](https://i.imgur.com/ZX1wDFO.png)

## Lokalno pokretanje web aplikacije

### Na računalo je potrebno instalirati

* Python (https://www.python.org/downloads/)
* MySQL Workbench (https://www.mysql.com/products/workbench/)
* Python Virtual Environment (https://www.youtube.com/watch?v=CHpQF1rdUMY)

*Koraci za instalaciju virtual environmenta:*

1. Preuzmite repozitorij i raspakirajte ga
2. Otvorite terminal u datoteci u kojoj se nalazi projekt
3. Kako bi kreirali environment upišite:
`python -m venv myVenv`
4. Kako bi aktivirali environment upišite:
`.\myVenv\Scripts\activate`
5. Kako bi instalirali sve potrebno za rad web aplikacije upišite: 
`pip install -r requirements.txt`

### Upute za lokalno pokretanje web aplikacije

**Kreiranje baze podataka**

Za ispravan rad baze podataka, prije pokretanja web aplikacije, potrebno je kreirati bazu podataka.

*Koraci za kreiranje baze podataka:*

1. Unutar MySQL Workbencha kreirati korisnika sa korisničkim imenom "**root**" i lozinkom "**root**"
2. Pokrenuti sljedeće SQL fajlove unutar "**root**" korisnika sljedećim redosljedom:
    * Prodajno servisni centar.sql
    * db_data.sql
    * db_fpt.sql
    * db_q.sql

**Pokretanje web aplikacije**

1. Otvorite terminal u datoteci u kojoj se nalazi projekt
2. Kako bi aktivirali environment upišite:
`.\myVenv\Scripts\activate`
3. Kako bi pokrenuli web aplikaciju upišite:
`flask run`
4. Otvorite dobivenu lokalnu adresu u bilo kojem internet pregledniku