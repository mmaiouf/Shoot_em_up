 -- Cette ligne permet d'afficher des traces dans la console pendant l'éxécution
io.stdout:setvbuf('no')

-- Empèche Love de filtrer les contours des images quand elles sont redimentionnées
-- Indispensable pour du pixel art
love.graphics.setDefaultFilter("nearest")

-- Cette ligne permet de déboguer pas à pas dans ZeroBraneStudio
if arg[#arg] == "-debug" then require("mobdebug").start() end

-- 1/ mtn, le héros se prend des explosions, il meurt, et disparaît.
-- 2/ le héros a 5 vies et ses vies sont affichés en bas de l'écran
-- 3/ j'ai géré le son des tirs, le son des musiques, le son des explosions selon les aliens etc...
-- 4/ pour régler le problème de supression du héros, j'ai fait en sorte que les aliens puissent tirer uniquement si le héros est pas supprimé de la table de sprites, du coup quand je meurs, il s'arrête de tirer, et moi je peux faire la manipulation du clavier + espaces tirs que si je suis sur l'écran.
-- 5/ j'ai ajouté d'autres aliens avec chacun leur comportement;
-- 6/ j'ai ajouté un score, on perd 10 points si on est touché, et on en gagne plus ou moins lorsqu'on en tue.
-- 7/ j'ai ajouté un mushroom et quand on collisionne avec ça fait un son, il disparaît et on prends 5 vies
-- 8/ j'ai fais un boss plus gros avec comportement chaud (avec la musique, les aliens qui les accompagne etc) 
-- 9/ un certain alien tire uniquement si il se fait toucher 
-- 10/ j'ai ajouté une potion "shield" qui, lorsque l'on collisionne avec, fait apparaître un cercle autour du héros et qui le protège des projectiles (à suivre !!)
-- 11/ ajouter un mushroom capable de multiplier par 2 la vitesse actuelle du héros.


hero = {} -- the hero don't need a specific treatment because he's a global variable.

math.randomseed(love.timer.getTime()) -- this allows to initialize the random value, so that it does not generate the same number.


spriteList = {} -- a sprite is defined by all elements that move on the screen (it can be the ship, the enemies, the shots, the boss etc ...)
shotList = {} -- the shots will be in two tables : in the sprites table and in the shots table
alienList = {}
mushroomList = {}
shieldList = {}
bubbleList = {}


-- Map 16x12

map = {}
  
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})  
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})  
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})  
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})  
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
  table.insert(map , {0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0}) 
  table.insert(map , {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}) 
  table.insert(map , {3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3}) 
  
  
  -- Score
  score = {}
  
  
  -- Camera
  
  camera = {}
  camera.y = 0
  camera.vy = 1
  
  -- Current screen
  current_screen = "menu" 
  
  -- Score
  
  score = {}
  
  -- Victory
  
  victory = false
  timerVictory = 0
  
  -- Defeat
  
  defeat = false
  timerDefeat = 0
  
  -- Bubble
  bubbleOn = false
  
  -- Speed * 2
  
  mushroomSpeed = false

-- Images of tiles

imgTiles = {}
local n

  for n = 1 , 3 do
    imgTiles[n] = love.graphics.newImage("images/tuile_"..n..".png") -- faster way to load the tiles!    
  end
  
  
-- Images of explosions
  
imgExplosion = {}
    
    for n = 1, 5 do
      
      imgExplosion[n] = love.graphics.newImage("images/explode_"..n..".png")
      
    end
    

-- Images of screens
  
imgMenu = love.graphics.newImage("images/menu.jpg")
imgGameover = love.graphics.newImage("images/gameover.jpg")
imgVictory = love.graphics.newImage("images/victory.jpg")


-- Sounds and musics

shootSound = love.audio.newSource("sons/shoot.wav" , "static")
shootSound:setVolume(0.3)
explodeSound = love.audio.newSource("sons/explode_touch.wav" , "static")
explodeSound:setVolume(0.3)
gameoverSound = love.audio.newSource("sons/game-over-sound-effect.mp3" , "static")
gameoverSound:setVolume(0.2)
victorySound = love.audio.newSource("sons/victory-sound-effect.mp3" , "static")
galaxyMenu = love.audio.newSource("sons/star-festival-super-mario-galaxy.mp3" , "stream")
galaxyMenu:setVolume(0.2)
galaxyGame = love.audio.newSource("sons/gusty-garden-galaxy-super-smash-bros-ultimate.mp3" , "stream")
galaxyGame:setVolume(0.2)
mushroomSound = love.audio.newSource("sons/mushroomSound.mp3" , "static")
mushroomSound2 = love.audio.newSource("sons/mushroomSound2.mp3" , "static")
finalBoss = love.audio.newSource("sons/finalBoss.mp3", "stream")
shieldSound = love.audio.newSource("sons/shieldSound.mp3", "static")
audioPlayed = false

-- Returns the angle between two points.
function math.angle(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1) end




function collide(a1, a2) -- for the collision, 2 parameters, the first table and the 2nd table (they are sprites)
  
 if (a1==a2) then return false end -- in any case, the 2 objects can not collide because they are the same objects
 
 local dx = a1.x - a2.x -- calculating the distance between the 2 objects
 local dy = a1.y - a2.y
 
 -- box collision system, it's as if there was a square around the sprite, and if these two squares intersect, then there is a collision.
 
 if (math.abs(dx) < a1.image:getWidth() + a2.image:getWidth()) then -- math.abs : whatever the sign of the number
   
  if (math.abs(dy) < a1.image:getHeight() + a2.image:getHeight())  then
    
   return true -- it's true, collision !
   
  end
  
 end
 
 return false -- else no collision
 
end


function CreateShot(pType, pImg, pX, pY, pVx, pVy) -- to have a good collision, we added "pType" which defines whether the shot is an enemy shot or a shot of the hero.
  
    local shot = CreateSprite(pImg, pX, pY, pVx, pVy) -- we create a sprite "shot" who has been add on the sprite table
    shot.type = pType
    shot.vx = pVx
    shot.vy = pVy
    table.insert(shotList, shot) -- we also add the sprite "shot" on the table of shots, because the shots need a specific treatment
    shootSound:play()
  
end

function CreateMushroom(pImg, pType, pX, pY, pVx, pVy)
  
  local mushroom = CreateSprite(pImg, pX, pY)
  mushroom.vx = pVx
  mushroom.vy = pVy
  mushroom.type = pType
  table.insert(mushroomList, mushroom)
  
end

function CreateShield(pImg, pX, pY, pVx, pVy)
  
  local shield = CreateSprite(pImg, pX, pY)
  shield.vx = pVx
  shield.vy = pVy
  table.insert(shieldList, shield)
  
end

function CreateBubble(pImg, pX, pY, pVx, pVy, pE)
  
  local bubble = CreateSprite(pImg, pX, pY)
  bubble.vx = pVx
  bubble.vy = pVy
  bubble.energy = pE
  table.insert(bubbleList, bubble)
  
end


function CreateAlien(pType, pX, pY) -- there are 3 types of enemies.
  
  local imgName = ""
  
  -- alienImage
  
    if pType == 1 then
      
      imgName = "enemy1" 
      
    end
    
    if pType == 2 then
      
      imgName = "enemy2"
      
    end
    
    if pType == 3 then
      
      imgName = "tourelle"
      
    end
    
    if pType == 4 then
      
      imgName = "enemy4"
      
    end
    
    if pType == 5 then
      
      imgName = "enemy5"
      
    end
    
    if pType == 6 then
      
      imgName = "enemy6"
      
    end
    
    if pType == 7 then
      
      imgName = "enemy7"
      
    end
    
    if pType == 8 then
      
      imgName = "enemy8"
      
    end
    
    if pType == 9 then
      
      imgName = "enemy3"
      
    end
    
    if pType == 10 then
      
      imgName = "enemy9"
      
    end
    
    if pType == 11 then
      
      imgName = "enemy10"
      
    end
    
    if pType == 12 then
      
      imgName = "enemy10"
      
    end
  
local alien = CreateSprite(imgName, pX, pY)

    alien.type = pType

    alien.asleep = true -- by default, an alien is asleep, we don't move the alien until it is visible on the screen (we will place the aliens off the screen.)
    alien.shotTimer = 0 -- when an alien shoots, he will have a shooting timer. it's a universal concept, we put timers everywhere to define the elements that take place sequentially at regular intervals. the timer will increase, and when it reaches a number, the alien shoot and it is reset to 0.
  
  -- alien behavior by type
  
      if pType == 1 then
      
      alien.vy = 2
      alien.vx = 0
      alien.energy = 1 -- we add life points to our aliens
      
    end
    
    if pType == 2 then
      
      alien.vy = 2
      alien.energy = 3   
      
      local direction = math.random(1,2) -- to have a random direction between 1 and 2.
      
        if direction == 1 then
          
        alien.vx = 1
        
        elseif direction == 2 then
        
        alien.vx = -1
        
      end
      
    end
    
    if pType == 3 then
      
      alien.vx = 0 
      alien.vy = camera.vy -- the turret don't move
      alien.energy = 5
      
    end
    
    if pType == 4 then 
      
      alien.vx = 2
      alien.vy = camera.vy
      alien.energy = 6
      
      
    end
    
    if pType == 5 then
      
      alien.vx = 0
      alien.vy = camera.vy
      alien.energy = 4
      
    end
    
    if pType == 6 then
      
      alien.vx = 2
      alien.vy = 1
      alien.energy = 10
      
      
    end
    
    if pType == 7 then
      
      alien.vx = 0
      alien.vy = 1
      alien.energy = 3
      
    end
    
    if pType == 8 then
      
      alien.vx = 0
      alien.vy = 1
      alien.energy = 10
      
    end
    
    if pType == 9 then -- for the under boss
      
      alien.vx = 0
      alien.vy = camera.vy * 2 -- the boss will come faster.
      alien.energy = 20
      alien.angle = 0 -- angle of shots
      
    end
    
    if pType == 10 then 
      
      alien.vx = 5
      alien.vy = 5
      alien.energy = 40
      alien.angle = 0
      
    end
    
    
    if pType == 11 then
      
      alien.vx = 0
      alien.vy = 2
      alien.energy = 5
      
    end
    
    if pType == 12 then
      
      alien.vx = 0
      alien.vy = 2
      alien.energy = 5
      
    end
    
  table.insert(alienList, alien)
  
end


function CreateSprite(pImg, pX, pY) -- we create a function "CreateSprite" because we want to be able to display all our sprites at once and not one by one, with as parameter the corresponding sprite, its x coordinate and its y coordinate. In addition, each sprite has a specific treatment, so it's very important.
  
  -- the function "Create Sprite" will have the particularity of: 
  
      sprite = {} -- creating a sprite
        sprite.x = pX
        sprite.y = pY
        sprite.image = love.graphics.newImage("images/"..pImg..".png") -- it's very convenient to do like that, it will be enough just to put the name of the image when we will call the function.
        sprite.delete = false
        sprite.width = sprite.image:getWidth()
        sprite.height = sprite.image:getHeight()
        
        sprite.frame = 1 -- this is the counter for the animation of the explosion, by default it starts at 1.
        sprite.frameList = {} -- an explosion can have several animations
        sprite.frameMax = 1 
      
      table.insert(spriteList , sprite) -- and to adding a sprite on the table "sprites"
      
      return sprite 
  
end

function CreateExplosion(pX, pY) -- position of the explosion
  
  local newExp = CreateSprite("explode_1", pX, pY)
  
  -- it is here that we have modify the behavior of our explosion
    newExp.frameList = imgExplosion -- we make the link between the frame list and the table of images explosion.
    newExp.frameMax = 5
  
end


function love.load()
  
  love.window.setMode(1024,768) -- for choosing the size of the window
  love.window.setTitle("Shoot'em up !") -- for choosing the name of the window
  
  width = love.graphics.getWidth()
  height = love.graphics.getHeight()
  
  print("Screen width : "..width)
  print("Screen height : "..height)

  
  
end


function StartGame() -- to reset the elements of the game.

  
    hero = CreateSprite("heros", width/2, height/2) -- we created a sprite "hero" with these features and we put it in the table that contains all the sprites.

  -- we reset the position of hero and aliens.
  
  hero.x = width/2
  hero.y = height - (hero.height*2)
  hero.energy = 10
  hero.velocity = 4
  
  -- Creation of aliens
  local line = 4
  alien = CreateAlien(1, width/2, -(64/2) - (64*(line-1))) -- we want to position the first alien at the 4th line from the bottom. (64/2) makes it possible to center the alien on the line (tile)
  line = 10
  alien = CreateAlien(2, (64*4), -(64/2) - (64*(line-1)))
  line = 11
  alien = CreateAlien(3, (64*4), -(64/2) - (64*(line-1)))
  line = 17
  alien = CreateAlien(4, width/2, -(64/2) - (64*(line-1)))
  line = 27
  alien = CreateAlien(5, width - (sprite.width*7), -(64/2) - (64*(line-1)))
  line = 30
  alien = CreateAlien(6, width/2, -(64/2) - (64*(line-1)))
  line = 33
  alien = CreateAlien(7, (64*4), -(64/2) - (64*(line-1)))
  line = 22
  alien = CreateAlien(8, (64*4), -(64/2) - (64*(line-1)))
  
  -- under boss
  
  line = 40
  alien = CreateAlien(9, width/2, -(64/2) - (64*(line-1)))
  
  -- boss final
  
  line = 55
  alien = CreateAlien(10, width/2, -(64/2) - (64*(line-1)))
  
  line = 62
  alien = CreateAlien(11, 100, -(64/2) - (64*(line-1)))
  
  line = 62
  alien = CreateAlien(12, width-100, -(64/2) - (64*(line-1)))

  -- reset the position of camera
  camera.y = 0
  
  -- reset the score
  score = 0
  
  -- the mushroom for reinitialise the life of hero
  line = 43
  mushroom = CreateMushroom("mushroom", 1, width/4 , -(64/2) - (64*(line-1)), 0, 1)
  
  line = 59
  mushroom2 = CreateMushroom("mushroom2", 2, width-200 , -(64/2) - (64*(line-1)), 0, 1)

  
  -- the shield for protect the hero
  line = 50
  shield = CreateShield("shield", width-200, -(64/2) - (64*(line-1)), 0, 1)
  
  galaxyGame:setVolume(0.2)
  galaxyMenu:setVolume(0.2)

  
end

function GameUpdate()

  audioPlayed = false
  galaxyGame:play()
  galaxyMenu:stop()

  
  -- move the camera
  camera.y = camera.y + camera.vy
    
    local n
    
  -- shooting treatment
    
    for n=#shotList, 1, -1 do -- we have to reverse the scan of the list from bottom to top so that when we delete the shots, that there is no problem during the scan, problems of reversal of places of the indexes.
      
      local shot = shotList[n] -- after each table scan, it is important to create a variable to identify the elements of the table with the index in square brackets.
      
      shot.x = shot.x + shot.vx
      shot.y = shot.y + shot.vy
      
      -- check if an alien shot touches a hero.
      
        if shot.type == "alien" then -- if it's a alien shot
          if collide(shot,hero) then
            
            print("Alerte, j'ai été touché !")
            
            shot.delete = true -- when a shot hits the ship, it's hit several times because the shot goes through several pixels when it touches the ship (until it comes out of the screen), so when the shot touches the ship, the shot is removed from the table of sprite and table of shots.
            table.remove(shotList, n)
            
            hero.energy = hero.energy - 1
            CreateExplosion(shot.x, shot.y)
            explodeSound:play()
            score = score - 10
            
            
            if hero.energy <= 0 then
              
              timerDefeat = 80
              defeat = true
                     
              for nExplosion = 1,5 do
                CreateExplosion(hero.x + math.random(-10,10) , hero.y + math.random(-10,10))
                explodeSound:setVolume(0.7)
              end
              
              finalBoss:stop()
              galaxyGame:setVolume(0)
              hero.delete = true
              table.remove(hero, #hero)
              
            end
          end
          
          -- bubble collision
            for nBubble = #bubbleList, 1, -1 do
              
              bubble = bubbleList[nBubble]
              
                if bubbleOn == true then
                  
                  if collide(shot, bubble) then
                    
                    shot.delete = true
                    table.remove(shotList, n)
                    bubble.energy = bubble.energy - 1
                    CreateExplosion(shot.x , shot.y)
                    explodeSound:play()
                    print("Bulle touchée !")
                    
                  end
                  
                  if bubble.energy <= 0 then
                    
                    bubble.delete = true
                    table.remove(bubbleList, n)
                    
                  end
                  
                end
                
            end
        end
        
        if shot.type == "hero" then
          local nAlien
            for nAlien = #alienList, 1, -1 do --we scan the table of aliens to see if at any given moment, the hero's shot touches an alien from the list.
              local alien = alienList[nAlien] 
                if alien.asleep == false then 
                  if collide(alien, shot) then
                    
                    CreateExplosion(shot.x, shot.y)
                    shot.delete = true -- we change the place of the suppression of the shots, we must always remove them at the collision and not that if the energy of the ship is 0, otherwise it removes everything whatever the condition.
                    table.remove(shotList, n)

                    print("Alien touché, bien joué !")
                    
                    alien.energy = alien.energy - 1
                    explodeSound:play()
                    
                      if alien.type == 8 then
                        
                              
                            alien.shotTimer = alien.shotTimer - 1
                                      
                              if alien.shotTimer <= 0 then
                                                
                                alien.shotTimer = 60
                                local vx, vy
                                local angle
                                  
                                angle = math.angle(alien.x, alien.y, hero.x, hero.y)
                                                
                                vx = 10 * math.cos(angle)
                                vy = 10 * math.sin(angle)
                                                
                                CreateShot("alien", "laser2", alien.x, alien.y, vx, vy)
                                shootSound:setVolume(0.7)
                                
                              end
                      end
                    
                        if alien.energy <= 0 then -- when an alien dies
                          
                          local nExplosion
                          
                            for nExplosion = 1 , 5 do -- we create five explosions, here the scan is used to repeat a code a number of times (5 times).
                              
                              CreateExplosion(alien.x + math.random(-10,10) , alien.y + math.random(-10,10)) -- when an alien dies, there is a bigger explosion. the random value allows to create an illusion of several explosions around the alien (between 10 pixels by the left and 10 pixels by the right)
                              explodeSound:setVolume(0.7)
                              
                            end
                            
                          if alien.type == 1 then 
                            
                            score = score + 10
                            
                          end
                          
                          if alien.type == 2 then 
                            
                            score = score + 20
                            
                          end
                          
                          if alien.type == 3 then 
                            
                            score = score + 30
                            
                          end
                          
                          if alien.type == 4 then 
                            
                            score = score + 40
                            
                          end
                          
                          if alien.type == 5 then
                            
                            score = score + 50
                            
                          end
                          
                          if alien.type == 6 then
                            
                            score = score + 60
                            
                          end
                        
                          if alien.type == 7 then
                            
                            score = score + 10
                            
                          end
                          
                          if alien.type == 8 then
                            
                            score = score + 5
                            
                          end
                            -- under boss
                            
                          if alien.type == 9 then
                            
                            -- we would like to display the image of victory when there is nothing more on the screen, the simplest is to use a counter that would stop at the end of the animation of the explosion.
                            score = score + 90
                            
                              for nExplosion = 1 , 15 do
                              
                                CreateExplosion(alien.x + math.random(-50,50) , alien.y + math.random(-50,50))
                                explodeSound:setVolume(0.9)
                              
                              end
                            
                          end
                          
                          if alien.type == 10 then
                            
                            victory = true 
                            timerVictory = 80
                            score = score + 100
                            finalBoss:stop()
                            galaxyGame:setVolume(0)
                            
                            for nAlien = 1, 30 do 
                              
                              CreateExplosion(alien.x + math.random(-100,100) , alien.y + math.random(-100, 100))
                              explodeSound:setVolume(1)
                              
                            end
                            
                          end
                          
                          
                          if alien.type == 12 then
                            
                            score = score + 20
                            
                          end

                          alien.delete = true
                          table.remove(alienList, nAlien)
                          
                        end
                  end
                end
            end
        end
      
      
      -- however, it is necessary to delete the elements of the "shots" list when they come out of the screen, otherwise it will saturate the memory and there may be slowdowns (because even if the shots come out of the screen, they are still in the game)
      
      if (shot.y < 0 or shot.y > height) and shot.delete == false then
        
        shot.delete = true -- we mark the sprite to remove it later
        table.remove(shotList, n) -- no "shot" but "n", the index, the laser we just shot.
        
      end
      
      if shot.x < 0 or shot.x > width and shot.delete == false then
        
        shot.delete = true
        table.remove(shotList, n)
        
      end
      
    end
      
      
      -- aliens treatment
    
      for n=#alienList, 1, -1 do -- the inverse is essential to remove the elements of a list.
        
        local alien = alienList[n] -- recover
        
        if alien.y > 0 then -- we wake up the alien
          
         alien.asleep = false
          
        end
        
        
        if alien.asleep == false then -- we move the alien only if they are'nt asleep.
         
          alien.x = alien.x + alien.vx
          alien.y = alien.y + alien.vy
          
          if hero.delete == false then
            
                if alien.type == 1 or alien.type == 2 then  
                  
                    alien.shotTimer = alien.shotTimer - 1 
                  
                    if alien.shotTimer <= 0 then 
                      
                      alien.shotTimer = math.random(60,100) -- 0 - 60 - 0 - 82 - 0 - 77 - 0 - 65 ... 60 = 1/60 * 60 = 1 second
                      CreateShot("alien", "laser2", alien.x, alien.y, 0, 10)
                      shootSound:setVolume(0.5)
                                        
                    end
                    
                elseif alien.type == 3  then
                  
                  alien.shotTimer = alien.shotTimer - 1 
                  
                    if alien.shotTimer <= 0 then 
                      
                      alien.shotTimer = 40 
                      local angle
                      local vx,vy
                      
                      angle = math.angle(alien.x, alien.y, hero.x, hero.y) -- after declaring the function to calculate the angle between 2 points (at top), we can now calculate the angle between the hero and the aliens, so that the turret shots follow the ship regardless of angle with the ship.
                      vx = 10 * math.cos(angle) -- cos : angle x with the velocity
                      vy = 10 * math.sin(angle) -- sin : angle y with the velocity
                      
                      CreateShot("alien", "laser2", alien.x, alien.y, vx, vy)
                      shootSound:setVolume(0.8)
                      
                      
                    end
                  
                elseif alien.type == 4 then
                  
                  if alien.x >= 800 and alien.vx >= 0 then
                    
                    alien.vx = 0 - alien.vx
                    
                  end
                  
                  if alien.x <= width/2 and alien.vx <= 0 then
                    
                    alien.vx = 0 - alien.vx
                    
                  end
                  
                  alien.shotTimer = alien.shotTimer - 1
                  
                    if alien.shotTimer <= 0 then
                      
                      alien.shotTimer = 30
                      CreateShot("alien", "laser2", alien.x , alien.y, 0, 10)
                      shootSound:setVolume(0.7)
                      
                    end
                    
                  elseif alien.type == 5 then
                    
                    alien.shotTimer = alien.shotTimer - 1
                  
                    if alien.shotTimer <= 0 then
                      
                      alien.shotTimer = math.random(30,40)
                      
                      local angle
                      local vx,vy 
                      
                      angle = math.angle(alien.x, alien.y, hero.x, hero.y)
                      
                      vx = 10 * math.cos(angle)
                      vy = 10 * math.sin(angle)
                      
                      CreateShot("alien", "laser2", (alien.x - alien.width/2) , alien.y, vx, vy)
                      shootSound:setVolume(0.8)
                      
                    end
                    
                  elseif alien.type == 6 then
                    
                    alien.shotTimer = alien.shotTimer - 1
                    
                      if alien.shotTimer <= 0 then
                        
                        alien.shotTimer = math.random(60,80)                       
                        CreateShot("alien", "laser2", alien.x, alien.y, 0, 10)
                        shootSound:setVolume(0.9)
                        
                      end
                      
                        if alien.x >= (width/2) + 30 then
                          
                          alien.vx = 0 - alien.vx
                          
                        end
                        
                        if alien.x <= (width/2) - 30 then
                          
                          alien.vx = 0 - alien.vx
                          
                        end
                        
 
            
              elseif alien.type == 9 then
                
                  
                  if alien.y > height/3 then
                    
                    alien.y = height/3 -- we want that when the boss come at the third of the screen, he stops.
                    
                    alien.shotTimer = alien.shotTimer - 1 
                  
                    if alien.shotTimer <= 0 then 
                      
                      alien.shotTimer = 5 
                      local vx,vy
                      
                      alien.angle = alien.angle + 0.5 -- he will shoot around him every 0.5 pixels. one complete turn in radian: 2 * Pi (6.28), but it's not a problem because when the angle has made a complete turn it continues.
                      
                      vx = 10 * math.cos(alien.angle) -- cos : angle x with the velocity of shots
                      vy = 10 * math.sin(alien.angle) -- sin : angle y with the velocity of shots
                      
                      CreateShot("alien", "laser2", alien.x, alien.y, vx, vy)
                      
                    end
                    
                    
                  end
                       
                  
                elseif alien.type == 10 then
                  
                  galaxyGame:stop()
                  finalBoss:play()
                  finalBoss:setVolume(0.3)
                  
                      if alien.x >= width - (alien.width) and alien.vx >= 0 then
                        
                        alien.vx = 0 - alien.vx
                        alien.x = width - (alien.width)
                        
                      end
                      
                      if alien.x <= 0 + (alien.width) and alien.vx <= 0  then
                        
                        alien.vx = 0 - alien.vx
                        alien.x = 0 + (alien.width)
                        
                      end
                      
                      if alien.y >= height - (alien.height) and alien.vy >= 0 then
                        
                        alien.vy = 0 - alien.vy
                        alien.y = height - (alien.height)
                        
                      end
                      
                      if alien.y >= 0 + alien.height then
                        
                        if alien.y <= 0 + alien.height and alien.vy <= 0 then
                          
                          alien.vy = 0 - alien.vy
                          alien.y = 0 + alien.height
                          
                        end
                      end

                      alien.shotTimer = alien.shotTimer - 1
                      
                        if alien.shotTimer <= 0 then
                          
                          alien.shotTimer = 20

                          local vx, vy
                          local angle
                          
                          angle = math.angle(alien.x, alien.y, hero.x, hero.y)
                          
                          vx = 10 * math.cos(angle)
                          vy = 10 * math.sin(angle)
                          
                          CreateShot("alien", "laser2", alien.x , alien.y + (alien.height), vx, vy)
                          shootSound:setVolume(0.7)
                          
                        end
                        
                      if collide(alien,hero) then
                        
                        hero.energy = 0
                        finalBoss:setVolume(0)
                        galaxyGame:setVolume(0)
                        

                        
                        for nExplosion = 1, 5 do
                          
                          CreateExplosion(hero.x + (math.random(-50,50)) , hero.y + (math.random(-50,50)))
                          
                        end
                        
                        timerDefeat = 80
                        defeat = true
                        
                        hero.delete = true
                        table.remove(hero, #hero)
                        
                        bubble.delete = true
                        table.remove(bubbleList, n)
                        
                      end
                      
                elseif alien.type == 11 then -- bodyguard of the boss
                
                alien.shotTimer = alien.shotTimer - 1
                
                  if alien.shotTimer <= 0 then                    
                    
                    alien.shotTimer = 20
                    CreateShot("alien", "laser2", alien.x, alien.y, 10, 0)
                    
                  end
                  
                elseif alien.type == 12 then -- bodyguard of the boss
                
                alien.shotTimer = alien.shotTimer - 1
                
                  if alien.shotTimer <= 0 then

                    alien.shotTimer = 20
                    CreateShot("alien", "laser2", alien.x, alien.y, -10, 0)
                    
                  end
                        
                end

          end
              
              else
                
                alien.y = alien.y + camera.vy -- else we move the alien at the same velocity as camera.
                
              end

        
        if alien.y > height or current_screen == "gameover" or current_screen == "victory" then
          
          alien.delete = true
          table.remove(alienList, n)
           
          
        end
        
      end
      
      -- mushroom treatment
        
        local nMushroom
        
        for nMushroom = #mushroomList, 1, -1 do
          
          local mushroom = mushroomList[nMushroom]
          
          mushroom.x = mushroom.x + mushroom.vx
          mushroom.y = mushroom.y + mushroom.vy
          
            if collide(mushroom, hero) then
              
              if mushroom.type == 1 then
                
                  mushroomSound:play()
                  mushroomSound:setVolume(0.5)
                  hero.energy = hero.energy + 5
                
                  mushroom.delete = true
                  table.remove(mushroomList, nMushroom)
                  
              end
              
              if mushroom.type == 2 then
                
                mushroomSpeed = true
                mushroomSound2:play()
                
                mushroom.delete = true
                table.remove(mushroomList, nMushroom)
                
              end
            
            end
            
            if mushroom.y >= height then
              
              mushroom.delete = true
              table.remove(mushroomList, nMushroom)
              
            end
          
        end
        
        
        -- shield treatment
        
        local nShield
        
            for nShield = #shieldList, 1, -1 do
              
              local shield = shieldList[nShield]
              
              shield.x = shield.x + shield.vx
              shield.y = shield.y + shield.vy
              
                if collide(shield, hero) then
                  
                    shieldSound:play()
                    shield.delete = true
                    table.remove(shieldList, nSHield)
                    
                    
                    CreateBubble("bubble", hero.x, hero.y, 0, 1, 20)
                    bubbleOn = true
                  
                end
                
                if shield.y >= height then
                  
                  shield.delete = true
                  table.remove(shieldList, nShield)
                  
                end
              
            end
          

      
      
        -- sprites treatment and purge of sprites.
        for n= #spriteList, 1, -1 do
          
          local sprite = spriteList[n]
          
          -- to know if the sprite is animated or not
          if sprite.frameMax > 1 then -- to logically, if a sprite has more than one frame, it is animated.
            
            sprite.frame = sprite.frame + 0.2
            
              if math.floor(sprite.frame) > sprite.frameMax then -- math.floor : without the comma, only the left part.
                
                sprite.delete = true -- once the animation is finished, we delete the sprite.
                
              else
                
                sprite.image = sprite.frameList[math.floor(sprite.frame)] -- while it is less than 5, we continue to scroll the images of our list for the animation of the explosion.
                
              end
            
          end
          
          
          if sprite.delete == true then
            
            table.remove(spriteList,n)
            
          end
          
        end
    

    
    -- keys treatment
   

  if hero.delete == false then
    
        if love.keyboard.isDown("up") and hero.y > 0 + hero.height/2 then
          
          hero.y = hero.y - hero.velocity
          
          for nBubble = #bubbleList, 1, -1 do
            local bubble = bubbleList[nBubble]
              if bubbleOn == true then
                bubble.y = bubble.y - 4
              end
              
              if mushroomSpeed == true then
                bubble.y = bubble.y - 5
              end
          end
          
          if mushroomSpeed == true then
            
            hero.y = hero.y - 5
            
          end
          
        end
        
        if love.keyboard.isDown("right") and hero.x < width - hero.width/2 then
          
          hero.x = hero.x + hero.velocity
          
          for nBubble = #bubbleList, 1, -1 do
            local bubble = bubbleList[nBubble]
              if bubbleOn == true then
                bubble.x = bubble.x + 4
              end
              
              if mushroomSpeed == true then
                bubble.x = bubble.x + 5
              end
          end
          
          if mushroomSpeed == true then
            
            hero.x = hero.x + 5
            
          end
          
        end
        
        if love.keyboard.isDown("down") and hero.y < height - hero.height/2 then
          
          hero.y = hero.y + hero.velocity
          
          for nBubble = #bubbleList, 1, -1 do
            local bubble = bubbleList[nBubble]
              if bubbleOn == true then
                bubble.y = bubble.y + 4
              end
              
              if mushroomSpeed == true then
                bubble.y = bubble.y + 5
              end
          end
          
          if mushroomSpeed == true then
            
            hero.y = hero.y + 5
            
          end
          
        end
        
        if love.keyboard.isDown("left") and hero.x > 0 + hero.width/2 then
          
          hero.x = hero.x - hero.velocity
          
          for nBubble = #bubbleList, 1, -1 do
            local bubble = bubbleList[nBubble]
              if bubbleOn == true then
                bubble.x = bubble.x - 4
              end
              
              if mushroomSpeed == true then
                
                bubble.x = bubble.x - 5
                
              end
          end
          
          if mushroomSpeed == true then
            
            hero.x = hero.x - 5
            
          end
          
        end
        
      
  end
    
    -- Victory and Defeat
    
    
    if victory == true then
      
      timerVictory = timerVictory - 1
      
      if timerVictory == 0 then
      
        current_screen = "victory"
        
      end
      
      
    end
    
    if defeat == true then
      
      timerDefeat = timerDefeat - 1
      
        if timerDefeat == 0 then
          
          current_screen = "gameover"
          
        end
    end
  
  
end

function GameMenu()
  
  if audioPlayed == false then
  
    galaxyMenu:play()
    gameoverSound:stop()
    victorySound:stop()
    
    audioPlayed = true
    
  end
  
end

function GameOver()
  
  if audioPlayed == false then -- to check if the sound is not already played, otherwise the sound will be repeated.
    
    gameoverSound:play()
    galaxyGame:stop()
    finalBoss:stop()
    
    audioPlayed = true
    
  end
  
end

function GameVictory()
  
  if audioPlayed == false then -- "we can play a sound if no other is played"
    
    victorySound:play()
    galaxyGame:stop()
    finalBoss:stop()
    
    audioPlayed = true
    
  end
  
  
end

function love.update(dt)
  
  if current_screen == "game" then
    
    GameUpdate()
    
  elseif current_screen == "menu" then
    
    GameMenu()
    
  elseif current_screen == "gameover" then
    
    GameOver()
    table.remove(spriteList, #spriteList)
    table.remove(alienList, #alienList)
    table.remove(shotList, #shotList)
    table.remove(mushroomList, #mushroomList)
    table.remove(shieldList, #shieldList)
    table.remove(bubbleList, #bubbleList)
    bubbleOn = false
    mushroomSpeed = false
    
  elseif current_screen == "victory" then
    
    GameVictory()
    table.remove(spriteList, #spriteList)
    table.remove(alienList, #alienList)
    table.remove(shotList, #shotList)
    table.remove(mushroomList, #mushroomList)
    table.remove(shieldList, #shieldList)
    table.remove(bubbleList, #bubbleList)
    bubbleOn = false
    mushroomSpeed = false
    
  end
  

end

function DrawGame()
  
  -- Draw the map
  local nbLines = #map
  local l,c
  local x,y
  
  x = 0 -- where will start the scan ?
  y = (0 - 64) + camera.y -- we add the horizontal scrolling to the map thanks to the camera.
  
  for l = nbLines, 1, -1 do -- return the map upside down. "I put the last line at the top of the screen" I want the scan to begin at position y.
    
    for c = 1 , 16 do
     
     -- Draw the tile

    local tile = map[l][c] -- variable to lighten the code, we made the link between the identifier of the tiles and the numbers on the grid of the map.
    
      if tile > 0 then
        
        love.graphics.draw(imgTiles[tile] , x , y , 0 , 2 , 2)
        
      end
      
     x = x + 64  -- you move horizontally from 64 to 64. (size of one tile)
     
    end
    
   x = 0 -- after scanning a column, you have to go back to the line.
   y = y - 64
   
  end
  
  
  -- we scan the table of sprites to be able to display our hero (here we display all the sprites).
  
  local n
  
    for n=1, #spriteList do
      
      local s = spriteList[n] -- n : index, all elements of the table "sprites". variable to lighten the code.
      
        love.graphics.draw(s.image, s.x, s.y, 0, 2, 2, s.width/2, s.height/2) 
      
    end
    
    
    if bubbleOn == true then
      
      local nBubble
      
        for nBubble = #bubbleList, 1, -1 do
          
          bubble = bubbleList[nBubble]
          love.graphics.print("Nombre de vies du shield : "..bubble.energy, 0, 730)
          
        end
      
    end
    
    
    


  love.graphics.print("Nombre de tirs : "..#shotList)
  love.graphics.print("Nombre de sprites : "..#spriteList, 0, 20)
  love.graphics.print("Nombre d'aliens : "..#alienList, 0, 40)
  love.graphics.print("Nombre de mushroom : "..#mushroomList, 0, 60)
  love.graphics.print("Nombre de shield : "..#shieldList, 0,80)
  love.graphics.print("Nombre de bubble : "..#bubbleList, 0,100)
  --love.graphics.print("Hero velocity : "..hero.velocity, 0,120)



  love.graphics.print("Nombre de vies : "..hero.energy, 0, 750)
  love.graphics.print("Score : "..score, width-70, 750)

  
end

function DrawMenu()
  
  love.graphics.draw(imgMenu, 0,0)


end

function DrawGameOver()
  
  love.graphics.draw(imgGameover, 0,0)
  
end

function DrawVictory()
  
  love.graphics.draw(imgVictory, 0,0)
  
end

function love.draw()

  if current_screen == "game" then
    
    DrawGame()
    
    
  elseif current_screen == "menu" then
    
    DrawMenu()
    
  elseif current_screen == "gameover" then
    
    DrawGameOver()
  
  elseif current_screen == "victory" then
  
    DrawVictory()
    
  end
  
  
end

function love.keypressed(key) -- in this function, it is necessary to press a key several times, press the key once and it stops, better for example escape key or the keys of the mouse etc...
  
  if current_screen == "game" then
    
    if hero.delete == false then
      if key == "space" then
        
        CreateShot("hero", "laser1", hero.x , hero.y - hero.height , 0, -10)
        shootSound:setVolume(0.6)
        
      end
    end
    
  end
  
  if current_screen == "menu" then 
    
    if key == "space" then
      
      current_screen = "game"
      StartGame()
      
    end
    
  end
  
  if current_screen == "gameover" then
    
    if key == "r" then
      
      current_screen = "menu"
      
    end
    
  end
  
  if current_screen == "victory" then
    
    if key == "r" then
      
      current_screen = "menu"
      
      
    end
    
  end

  
end