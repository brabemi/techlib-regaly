# techlib-regaly

Aplikace techlib-regaly slouží k usnadnění plánování umístění fondu knih na regály. Činnost je prováděna ve dvou fázích. První fází je agregace dat o fondu, kdy dochází k načtení a předzpracování dat z externích databází. V druhé fázi pak může uživatel ve webové aplikaci snadno vytvořit různé plán umístění vybrané části fondu na vybrané regály.

# Instalace

1. Instalace ruby závislostí: `bundle install`
2. Inicializace databáze `rake db:migrate`
3. Frontend:
	* Změna složky: `cd frontend/`
	* Instalace javascript závislostí: `npm install`
	* Build aplikace: `npm run build`

# Spuštění

`ruby app.rb`
