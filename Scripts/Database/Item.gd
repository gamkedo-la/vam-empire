extends Sprite

var item_dict_name
var index
export (String) var itemName
export (Database.ItemType) var itemType
export (Array, int) var asteroids
export (Texture) var itemTexture



func _init(itemName:String, itemType:int, asteroids:Array, itemTexture:Texture):
	pass

func _ready():
	print(Database.ItemType)
