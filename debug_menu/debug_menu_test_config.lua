
	local debug_menu_config = {
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
			
			table_source = {
				description = "Gives choice between 1, 4, 9, 16, etc, based on contents of table.",
				values = "table_source",
				table_source = {"MyGlobalGameSetting", "squares"},
			},
			
			function_source = {
				description = "Gives dynamic choice of things",
				values = function()
					local lol = {}
					for i=1,4 do
						local value = MyGlobalOrUpvalueManager.get_current_value_for_index(i)
						lol[i] = {tostring(value), value}
					end
					return lol
				end,
			},
			
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