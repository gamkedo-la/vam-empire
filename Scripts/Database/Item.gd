extends Sprite

var item_dict_name
var index
export (String) var itemName
export (Database.ItemType) var itemType
export (Array, int) var asteroids
export (Texture) var itemTexture

func _init(itemName:String = "", itemType:int = 0, asteroids:Array = [], itemTexture:Texture = null):
	pass

func _ready():
	print(Database.ItemType)
	
func init_item(_itemName:String, _itemType:int, _itemTexturePath:String):
	itemName = _itemName
	itemType = _itemType
	
	itemTexture = load(_itemTexturePath)
	# update sprite texture
	texture = itemTexture

func collect():
	# TODO: update inventory
	print("Collected ", itemName)
	queue_free()


func _on_LootTrigger_area_entered(area):
	collect()
