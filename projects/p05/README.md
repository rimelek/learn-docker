Konténerek indítása és php image készítése

```bash
docker-compose up -d
```

PHP konténer több példányban indítása:

```bash
docker-compose up -d --scale php=2
```

Megfigyelhető a böngészőben, hogy mindig más hosztnév jelenik meg.