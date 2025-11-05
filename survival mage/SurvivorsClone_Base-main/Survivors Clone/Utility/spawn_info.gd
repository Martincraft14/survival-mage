extends Resource

#Le ponemos un nombre de clase para poder referenciarlo luego
class_name Spawn_info

@export var time_start:int #cuando spawnea el enemigo
@export var time_end:int
@export var enemy:Resource #que enemig ospawnea 
@export var enemy_numb:int #numero de enemigos 
@export var enemy_spawn_delay:int # los segundos de delay entre spawns 

var spawn_delay_counter = 0 # guarda cunato timepo ha pasado desde el spawn
