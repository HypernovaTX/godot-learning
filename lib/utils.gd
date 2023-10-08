extends Node

const SAVE_PATH = "res://savegame.bin"; # users://

func saveGame():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE);
	var data: Dictionary = {
		"player_hp": Global.player_hp,
		"coins": Global.coins
	};
	var json_string = JSON.stringify(data);
	file.store_line(json_string);

func loadGame():
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ);
	if (FileAccess.file_exists(SAVE_PATH)):
		if (!file.eof_reached()):
			var current_line = JSON.parse_string(file.get_line())
			if (current_line):
				Global.player_hp = current_line['player_hp'] || 10;
				Global.coins = current_line['coins'] || 0;
