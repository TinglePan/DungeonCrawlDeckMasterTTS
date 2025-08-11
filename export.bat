start /wait /MIN nanDECK src\deck\CardBack.txt /createpng /NOPDFDIAG output=build\image
start /wait /MIN nanDECK src\deck\CardBackBlack.txt /createpng /NOPDFDIAG output=build\image
start /wait /MIN nanDECK src\deck\ExtraDeckCardBack.txt /createpng /NOPDFDIAG output=build\image

start /wait /MIN nanDECK src\deck\MonsterDeckFile.txt /createpng /NOPDFDIAG output=build\image
start /wait /MIN nanDECK src\deck\TrapDeckFile.txt /createpng /NOPDFDIAG output=build\image

start /wait /MIN nanDECK src\deck\EventDeckFile.txt /createpng /NOPDFDIAG output=build\image
start /wait /MIN nanDECK src\deck\LootDeckFile.txt /createpng /NOPDFDIAG output=build\image

start /wait /MIN nanDECK src\deck\ItemDeckFile.txt /createpng /NOPDFDIAG output=build\image
start /wait /MIN nanDECK src\deck\TrinketDeckFile.txt /createpng /NOPDFDIAG output=build\image
start /wait /MIN nanDECK src\deck\GearDeckFile.txt /createpng /NOPDFDIAG output=build\image

start /wait /MIN nanDECK src\deck\AttributeDeckFile.txt /createpng /NOPDFDIAG output=build\image
start /wait /MIN nanDECK src\deck\SkillDeckFile.txt /createpng /NOPDFDIAG output=build\image

start /wait /MIN nanDECK src\deck\ChallengeDeckFile.txt /createpng /NOPDFDIAG output=build\image

start /wait /MIN nanDECK src\deck\ExtraDeckFile.txt /createpng /NOPDFDIAG output=build\image
src\py\venv\Scripts\python.exe src\py\main.py