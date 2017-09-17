# Learn Docker

## Leírás

A projekt a Docker alapjainak elsajátításához tartalmaz példákat és segédszkripteket.

A példák az Ipszilon szemináriumra készültek a Cloud For Education rendszerben létrehozott
virtuális gépekre, így a projekt olyan szkripteket is tartalmaz, amik adott
környezetben szükségesek voltak, de más gépeken a telepítésük elhagyható.

* [fixhost.sh](system/etc/profile.d/fixhost.sh): A "sudo" parancs kiadásakor megjelenő
hibaüzenet elhallgattatására szolgál. Ellenőrzi, hogy a gép hosztneve szerepel-e a hosts fájlban.
Ha nem, akkor beírja. A szkript Ubuntu 16.04-ben az /etc/profile.d/ mappába másolandó.
* [xip.sh](system/usr/local/bin/xip.sh): Az xip.io publikus névszerver szolgáltatáshoz
generál domain neveket a gép aktuális nyilvános, vagy helyi hálózati IP címe alapján.
A fájlt "xip" néven a /usr/local/bin/ mappába kell másolni. Ezután az "xip" parancs kiadásakor
megjelenik egy használható domain név 192.168.1.2.xip.io formában. Az xip aramétert is fogad. 
Ilyenkor aldomaint is beállít. Pl.: "xip web1" eredménye web1.192.168.1.2.xip.io
* [xip.variable.sh](system/etc/profile.d/xip.variable.sh): Az xip program segítségével
beállítja az XIP környezeti változót, ami a fenti példánál maradva a 192.168.1.2.xip.io-hoz 
hasonló domaint tartalmazza, ami felhasználható a docker-compose.yml fájlokban is.

A fenti szkripteknek futtatási jogot is kell adni. Saját környezetben azonban nem szükséges
a telepítésük. Az XIP változót manuálisan is be lehet állítani.


## Projekt struktúra

- projects: A példaprojektek mappája
- system: A rendszerre telepíthető szkriptek gyűjteménye
- install.sh: A futtatáshoz szükséges programok telepítése, a rendszer előkészítése