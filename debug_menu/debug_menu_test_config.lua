
local test_config_all = {
	tests = {
		bool_simple = {
			description = "Sets a bool in the debug table.",
			values = "bool",
		},
		
		bool_function = {
			description = "Calls a function",
			values = "bool",
			func = function(value)
				MyGlobalOrUpvalueManager.bool_changed(value, some_upvalue)
			end,
		},
		
		table_simple = {
			description = "Gives choice between 1, 4, 9, and 16.",
			values = "table",
			table = {1, 4, 9, 16},
		},
		
		table_path = {
			description = "Gives choice between 1, 4, 9, 16, etc, based on contents of table.",
			values = "table_path",
			table_source = {"MyGlobalGameSetting", "squares"},
		},
		
		function_source = {
			description = "Gives dynamic choice of things",
			values = function()
				local lol = {}
				for i=1,4 do
					local value = i + 100
					lol[i] = {tostring(i) .. ": " .. tostring(value), value}
				end
				return lol
			end,
		},
		
		table_and_function_with_title = {
			title = "Tables, set-function, title",
			description = "Choices from table, calls function when changed",
			values = "table",
			table = {1,1,2,3,5,8,13},
			func = function(value)
				print("table_and_function changed to", value)
			end,
		}
		
		image_simple = {
			description = "Shows an image",
			values = "image",
			image = "some_resource",
			image_size = 128,
		},
		
		image_multiple = {
			description = "Shows multiple images. Calls a function when changed.",
			values = function()
				local lol = {}
				for i=1, 4 do
					lol[i] = {"Image number " .. tostring(i), "image_" .. tostring(i)}
				end
				return lol, "image"
			end
			image_size = 128,
			func = function(value)
				MyGlobalOrUpvalueManager.image_chosen(value)
			end
			table_set = true
		},
		
		preset = {
			description = "Applies change to multiple settings.",
			preset = {
				bool_simple = true,
				image_multiple = 1,
			},
		}
		
		preset_multiple = {
			description = "Applies change to multiple settings.",
			values = "table",
			table = {1, 4, 9, 16},
			preset = function(value)
				if value < 5 then
					return {
						bool_simple = true,
						image_multiple = 1,
					}
				else
					return {
						bool_simple = false,
						function_source = 2,
					}
				end
			end,
		},
		
		commands = {
			description = "Sends console commands.",
			values = "commands",
			command_list = {
				{
					description = "Debug rendering off."
					commands = {
						{"renderer", "settings", "debug_rendering", "false"},
					},
				},
				{
					description = "Physics debug enable"
					commands = {
						{"physics", "debug", "0"},
					},
				},
				{
					description = "Physics debug disable"
					commands = {
						{"physics", "debug", "1"},
					},
				},
			},
		},
	}
}

local test_config_implemented = {
	tests = {
		bool_simple = {
			description = "Sets a bool in the debug table.",
			values = "bool",
		},
	}
}

return {
	all = test_config_all,
	implemented = test_config_implemented,
}
