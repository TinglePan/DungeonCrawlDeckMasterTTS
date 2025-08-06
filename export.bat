start /MIN nanDECK src\deck\TrinketDeckFile.txt /createpng /NOPDFDIAG output=build\image
start /MIN nanDECK src\deck\AttributeDeckFile.txt /createpng /NOPDFDIA Goutput=build\image
start /MIN nanDECK src\deck\CardBack.txt /createpng /NOPDFDIA Goutput=build\image
start /MIN nanDECK src\deck\CardBackBlack.txt /createpng /NOPDFDIAG output=build\image
start /MIN nanDECK src\deck\ChallengeDeckFile.txt /createpng /NOPDFDIAG output=build\image
start /MIN nanDECK src\deck\ItemDeckFile.txt /createpng output=build\image
start /MIN nanDECK src\deck\EventDeckFile.txt /createpng output=build\image
start /MIN nanDECK src\deck\ExtraDeckFile.txt /createpng output=build\image
start /MIN nanDECK src\deck\ExtraDeckCardBack.txt /createpng output=build\image
start /MIN nanDECK src\deck\LootDeckFile.txt /createpng output=build\image
start /MIN nanDECK src\deck\MonsterDeckFile.txt /createpng output=build\image
start /MIN nanDECK src\deck\SkillDeckFile.txt /createpng output=build\image
start /MIN nanDECK src\deck\TrapDeckFile.txt /createpng output=build\image
src\py\venv\Scripts\python.exe src\py\main.py