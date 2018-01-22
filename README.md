# techlib-regaly

Systém pro plánování uložení fondu knih je navržen tak, aby uživateli usnadnil rutinní činnosti spojené s touto agendou. Systém funguje tak, že načítá a předzpracovává data z externích databází. Uživatel následně při plánování pracuje s agregovanými daty. Řešení podporuje práci s daty podle typu signatury, čísla signatury a roku vydání. Dále je také možno naplánovat rezervní prostor pro přírůstky u rostoucích titulů. 

# Instalace

1. Instalace ruby závislostí: `bundle install`
2. Inicializace databáze `rake db:migrate`
3. Frontend:
	* Změna složky: `cd frontend/`
	* Instalace javascript závislostí: `npm install`
	* Build aplikace: `npm run build`

# Spuštění

`ruby app.rb`
