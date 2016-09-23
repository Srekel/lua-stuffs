local World = stingray.World
local Gui = stingray.Gui
local Vector2 = stingray.Vector2
local Vector3 = stingray.Vector3
local Vector3Box = stingray.Vector3Box
local Vector4Box = stingray.Vector4Box
local Color = stingray.Color

stingray.core = stingray.core or {}


 --██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗
--██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝
--██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗
--██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║
--╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝
 --╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝

local width = 500
local fade_speed = 10

local boxed_colors = {
	white                            = Vector4Box(250, 255, 255, 255),
	text_color                       = Vector4Box(250, 120, 120, 0),
	text_color_overridden            = Vector4Box(255, 200, 200, 0),
	text_color_hot                   = Vector4Box(255, 230, 230, 200),
	text_color_active                = Vector4Box(255, 100, 255, 100),
	text_color_option_default_value  = Vector4Box(255, 50,  150, 50),
	text_color_option_overridden     = Vector4Box(255, 100, 255, 100),
	text_color_option_hot            = Vector4Box(255, 200, 255, 200),
	text_color_description           = Vector4Box(255, 150, 150, 150),
	row_highlight_color              = Vector4Box(150, 100, 100, 50),
	dotdotdot                        = Vector4Box(255, 75, 75, 0),
}

--██╗   ██╗████████╗██╗██╗     ██╗████████╗██╗   ██╗
--██║   ██║╚══██╔══╝██║██║     ██║╚══██╔══╝╚██╗ ██╔╝
--██║   ██║   ██║   ██║██║     ██║   ██║    ╚████╔╝
--██║   ██║   ██║   ██║██║     ██║   ██║     ╚██╔╝
--╚██████╔╝   ██║   ██║███████╗██║   ██║      ██║
 --╚═════╝    ╚═╝   ╚═╝╚══════╝╚═╝   ╚═╝      ╚═╝

local function simple_class(class)
	-- no inheritance, no reliance on appkit
	if class == nil then
		class = {}
		class.__index = class
		class.create = function(...)
			print(...)
			local object = {}
			setmetatable(object, class)
			assert(object.init, "No init function")
			object:init(...)
			return object
		end
	end

	return class
end

local function variable_to_title(variable_name)
	variable_name = variable_name:gsub("_", " ")
	variable_name = variable_name:sub(1,1):upper() .. variable_name:sub(2)
	return variable_name
end

local function config_name_to_title(variable_name)
	variable_name = variable_name:gsub("_", " ")
	variable_name = variable_name:sub(1,1):upper() .. variable_name:sub(2)
	return variable_name
end

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function ease_out_quad(t, b, c, d)
	t = t / d;
	return -c * t*(t-2) + b;
end

local function menu_item_sorter(a, b)
	if (a.type == "folder" and b.type == "folder") or (a.type ~= "folder" and b.type ~= "folder") then
		return a.title < b.title
	end

	if a.type == "folder" then
		return true
	end

	return false
end

--██╗████████╗███████╗███╗   ███╗    ████████╗██╗   ██╗██████╗ ███████╗███████╗
--██║╚══██╔══╝██╔════╝████╗ ████║    ╚══██╔══╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔════╝
--██║   ██║   █████╗  ██╔████╔██║       ██║    ╚████╔╝ ██████╔╝█████╗  ███████╗
--██║   ██║   ██╔══╝  ██║╚██╔╝██║       ██║     ╚██╔╝  ██╔═══╝ ██╔══╝  ╚════██║
--██║   ██║   ███████╗██║ ╚═╝ ██║       ██║      ██║   ██║     ███████╗███████║
--╚═╝   ╚═╝   ╚══════╝╚═╝     ╚═╝       ╚═╝      ╚═╝   ╚═╝     ╚══════╝╚══════╝

--MenuItemOptions = MenuItemOptions or {}
--MenuItemOptions.bool = function(item) return {true, false}

--local MenuItemClasses = {}
--MenuItemClasses.bool = {
	--init = function ()
			--self.height = 30
			--self.type = menu_item_type
			--self.title = config.title
			--self.setting_name = config_name
			--self.description = config.description
			--self.class = "bool"
		--end
	--},
	--options = function(item)
		--return {true, false}
	--end

--}

------------------------

stingray.core.MenuItemDescription = simple_class(stingray.core.MenuItemDescription)
stingray.core.MenuItemFolder = simple_class(stingray.core.MenuItemFolder)
stingray.core.MenuItemBool = simple_class(stingray.core.MenuItemBool)
stingray.core.MenuItemSetting = simple_class(stingray.core.MenuItemSetting)
local MenuItemDescription = stingray.core.MenuItemDescription
local MenuItemFolder = stingray.core.MenuItemFolder
local MenuItemBool = stingray.core.MenuItemBool
local MenuItemSetting = stingray.core.MenuItemSetting

local MenuItemClasses = {
	folder = MenuItemFolder,
	bool = MenuItemBool,
}
local function item_init(item, config_name, config, debug_setting_table)
	item.type = config.type or "folder" -- necessary?
	item.title = config.title or config_name_to_title(config_name)
	item.setting_name = config_name
	item.debug_setting_table = debug_setting_table
	item.expanded = true
	item.children = {}
	item.children_offset = 0
	if config.description then
		item.children[1] = MenuItemDescription(item.description)
	end
end

-------------------------

function MenuItemDescription:init(title)
	self.title = title
	self.height = 30
end

function MenuItemDescription:draw()
	-- todo
end

-------------------------

function MenuItemSetting:init(title, value, debug_setting_table, )
	self.title = title
	self.value = value
	self.debug_setting_table = debug_setting_table
	self.height = 30
end

function MenuItemSetting:draw()
	-- todo
end

function MenuItemSetting:activate()
	self.parent:apply_value(self.value)
end

-------------------------

function MenuItemFolder:init(config_name, config, debug_setting_table)
	item_init(self, config_name, config)
	self.height = 30
	
	for child_config_name, child_config in pairs(config) do
		local menu_item_type = child_config.type or "folder"
		local child_menu_item = MenuItemClasses[menu_item_type](config_name, config, debug_setting_table)
		child_menu_item.parent = self
		self.children[#self.children + 1] = child_menu_item
	end
	
	self.num_children = #self.children
	table.sort(self.children, menu_item_sorter)
end

function MenuItemFolder:draw(gui, position, alpha)
end

-------------------------

function MenuItemBool:init(config_name, config, debug_setting_table)
	item_init(self, config_name, config, debug_setting_table)
	self.height = 30
	
	self.children[#self.children + 1] = MenuItemSetting("true", true)
	self.children[#self.children + 1] = MenuItemSetting("false", false)
end

function MenuItemBool:draw(gui, position, alpha)
end

function MenuItemBool:set_value(value)
	item.debug_setting_table[self.setting_name] = value
end


-------------------------

--██╗███╗   ██╗██╗████████╗
--██║████╗  ██║██║╚══██╔══╝
--██║██╔██╗ ██║██║   ██║
--██║██║╚██╗██║██║   ██║
--██║██║ ╚████║██║   ██║
--╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝

local function generate_children__folder(menu_item, config_name, config, debug_setting_table)
	local num_children = 0
	menu_item.children = {}
	for child_config_name, child_config in pairs(config) do
		local child_menu_item = create_menu_item(child_config_name, child_config, debug_setting_table)
		child_menu_item.parent = menu_item
		menu_item.children[#menu_item.children + 1] = child_config_name
		menu_item.children[#menu_item.children + 1] = child_menu_item
		
		num_children = num_children + 1
	end
	
	menu_item.num_children = num_children
end

BOOL_CHILDREN = {"true", true, "false", false}
local function generate_children__bool(menu_item, config_name, config, debug_setting_table)
	menu_item.children = BOOL_CHILDREN
	menu_item.num_children = 2
end

local function activate__folder(menu_item, index, debug_setting_table)
	local child_menu_item = menu_item.children[index * 2]
	if not child_menu_item.expanded then
		child_menu_item.expanded = true
		child_menu_item.generate_children(child_menu_item, debug_setting_table)
	end
	-- debug_setting_table[menu_item.setting_name] = value
	-- if menu_item.set_func then
		-- menu_item.set_func(index, value)
	-- end
end

local function deactivate__folder(menu_item, index, debug_setting_table)
	local child_menu_item = menu_item.children[index * 2]
	child_menu_item.expanded = false
end

local function activate__bool(menu_item, index, debug_setting_table)
	local value = menu_item.children[index * 2]
	debug_setting_table[menu_item.setting_name] = value
end

local function create_menu_item(config_name, config, debug_setting_table)
	-- local on_expand = expand_folder
	-- if config.values then 
		-- if config.values == "bool" then
			-- on_expand = expand_bool
		-- else
		-- end
	-- end
	local activate = activate__folder
	local generate_children = generate_children__folder
	if config.values then 
		if config.values == "bool" then
			activate = activate__bool
			generate_children = generate_children__bool
		else
			assert(false, "Unknown menu item values type " .. tostring(config.value))
		end
	end
	
	local menu_item = {
		title = config.title or config_name_to_title(config_name),
		description = config.description,
		expanded = false,
		children = {},
		num_children = 0,
		generate_children = generate_children,
		activate = activate,
		set_func = config.func,
	}
	
	return menu_item
end

local default_input_update_function = function(input_data)
	local Keyboard = stingray.Keyboard

	input_data.go_sibling_up = Keyboard.pressed(Keyboard.button_index("up"))
	input_data.go_sibling_down = Keyboard.pressed(Keyboard.button_index("down"))
	--input_data.go_down = Keyboard.pressed(Keyboard.button_index("down"))
	input_data.go_parent = Keyboard.pressed(Keyboard.button_index("left"))
	input_data.go_child = Keyboard.pressed(Keyboard.button_index("right"))
end

local function create(world, input_data, config, debug_setting_table)
	local gui = World.create_screen_gui(world, "immediate")
	local menu_root = create_menu_item("root", config, debug_setting_table)
	menu_root.activate(menu_item, 1, debug_setting_table)

	local input_update_function = nil
	if input_data == nil then
		input_update_function = default_input_update_function
		input_data = {}
	end

	local debug_menu = {
		enabled = true,
		world = world,
		input_data = input_data,
		input_update_function = input_update_function,
		gui = gui,
		debug_setting_table = debug_setting_table,
		menu_root = menu_root,
		active_item = menu_root.children[1],
		hot_item = menu_root.children[1],
		colors = {},
		fade_timer = 0,
		time = 0,
	}

	return debug_menu
end

local function destroy(debug_menu)
	World.destroy_gui(debug_menu.world, debug_menu.gui)
end

--██╗███╗   ██╗██████╗ ██╗   ██╗████████╗
--██║████╗  ██║██╔══██╗██║   ██║╚══██╔══╝
--██║██╔██╗ ██║██████╔╝██║   ██║   ██║
--██║██║╚██╗██║██╔═══╝ ██║   ██║   ██║
--██║██║ ╚████║██║     ╚██████╔╝   ██║
--╚═╝╚═╝  ╚═══╝╚═╝      ╚═════╝    ╚═╝

local function child_index(t, size, value)
	for i=1, size do
		if t[i] == value then return i end
	end
end

local function handle_input(debug_menu)
	local input_data = debug_menu.input_data
	if debug_menu.input_update_function then
		debug_menu.input_update_function(input_data)
	end

	local current_hot_item = debug_menu.hot_item

	-- Update enabled/disabled menu
	if debug_menu.enabled and input_data.go_parent and current_hot_item.parent == debug_menu.menu_root then
		debug_menu.enabled = false
	end

	if not debug_menu.enabled and input_data.go_child and current_hot_item.parent == debug_menu.menu_root then
		debug_menu.enabled = true
		return -- don't want to do any more input the same frame
	end

	if not debug_menu.enabled then
		return
	end

	-- Go up/down/left/right
	if input_data.go_sibling_up then
		local parent = debug_menu.hot_item.parent
		local hot_item_child_index = child_index(parent.children, parent.num_children, current_hot_item)
		if hot_item_child_index == 1 then
			debug_menu.hot_item = parent.children[parent.num_children]
		else
			debug_menu.hot_item = parent.children[hot_item_child_index - 1]
		end
	end

	if input_data.go_sibling_down then
		local hot_item = debug_menu.hot_item
		local parent = debug_menu.hot_item.parent
		local hot_item_child_index = child_index(parent.children, parent.num_children, hot_item)
		if hot_item_child_index == parent.num_children then
			debug_menu.hot_item = parent.children[1]
		else
			debug_menu.hot_item = parent.children[hot_item_child_index + 1]
		end
	end

	if input_data.go_up then
		local hot_item = debug_menu.hot_item
		local parent = debug_menu.hot_item.parent
		local hot_item_child_index = child_index(parent.children, parent.num_children, hot_item)
		if hot_item.num_children > 0 and hot_item.children[1].num_children > 0 then
			debug_menu.hot_item = hot_item.children[1]
		elseif hot_item_child_index == parent.num_children then
			-- Find a parent that is "next in line" to be hot
			while parent.parent ~= nil and hot_item_child_index == parent.num_children do
				hot_item = hot_item.parent
				parent = hot_item.parent
				hot_item_child_index = child_index(parent.children, parent.num_children, hot_item)
				-- debug_menu.hot_item = parent.children[1]
			end

			if parent == nil or parent.num_children == hot_item_child_index then
				debug_menu.hot_item = debug_menu.menu_root.children[1]
			else
				debug_menu.hot_item = parent.children[hot_item_child_index + 1]
			end
		else
			debug_menu.hot_item = parent.children[hot_item_child_index + 1]
		end
	end

	if input_data.go_down then
		local hot_item = debug_menu.hot_item
		local parent = debug_menu.hot_item.parent
		local hot_item_child_index = child_index(parent.children, parent.num_children, hot_item)
		if hot_item.num_children > 0 and hot_item.children[1].num_children > 0 then

			debug_menu.hot_item = hot_item.children[1]
		elseif hot_item_child_index == parent.num_children then
			-- Find a parent that is "next in line" to be hot
			while parent.parent ~= nil and hot_item_child_index == parent.num_children do
				hot_item = hot_item.parent
				parent = hot_item.parent
				hot_item_child_index = child_index(parent.children, parent.num_children, hot_item)
				-- debug_menu.hot_item = parent.children[1]
			end

			if parent == nil or parent.num_children == hot_item_child_index then
				debug_menu.hot_item = debug_menu.menu_root.children[1]
			else
				debug_menu.hot_item = parent.children[hot_item_child_index + 1]
			end
		else
			debug_menu.hot_item = parent.children[hot_item_child_index + 1]
		end
	end

	if input_data.go_parent then
		local hot_item = debug_menu.hot_item
		local parent = debug_menu.hot_item.parent
		if parent.parent then
			debug_menu.hot_item = parent
		end
	end

	if input_data.go_child then
		local hot_item = debug_menu.hot_item
		if hot_item.children ~= nil then
			debug_menu.hot_item = hot_item.children[1] -- todo
		end
	end

	-- Update hot item status
	if current_hot_item ~= debug_menu.hot_item then
		current_hot_item.hot = false
		local parent = current_hot_item.parent
		while parent ~= nil do
			parent.hot_child = nil
			parent = parent.parent
		end

		debug_menu.hot_item.hot = true
		local parent = debug_menu.hot_item.parent
		while parent ~= nil do
			parent.hot_child = true
			parent = parent.parent
		end
	end
end

--██╗   ██╗██████╗ ██████╗  █████╗ ████████╗███████╗
--██║   ██║██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██╔════╝
--██║   ██║██████╔╝██║  ██║███████║   ██║   █████╗
--██║   ██║██╔═══╝ ██║  ██║██╔══██║   ██║   ██╔══╝
--╚██████╔╝██║     ██████╔╝██║  ██║   ██║   ███████╗
 --╚═════╝ ╚═╝     ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝

local function distance_to_item(current, item)
	local distance_to_child = current.children_offset
	for i=1, current.num_children do
		local child_menu_item = current.children[i]
		if item == child_menu_item then
			return distance_to_child
		end

		distance_to_child = distance_to_child + child_menu_item.height

		local sub_distance = distance_to_item(child_menu_item, item)
		if sub_distance then
			return distance_to_child + sub_distance
		end

		distance_to_child = distance_to_child + child_menu_item.actual_height
	end
end

local function update_total_heights(item)
	local child_total_heights = 0
	for i=1, item.num_children do
		-- child_total_heights = child_total_heights + item.children[i].height
		child_total_heights = child_total_heights + update_total_heights(item.children[i])
	end

	item.total_height = child_total_heights
	return child_total_heights + item.height
end

local function update_actual_heights(item)
	local actual_height = item.children_offset or 0
	for i=1, item.num_children do
		-- child_total_heights = child_total_heights + item.children[i].height
		actual_height = actual_height + update_actual_heights(item.children[i])
	end

	item.actual_height = actual_height
	return actual_height + item.height
end

local function reset_min_children_offsets(item)
	item.min_children_offset = 0
	for i=1, item.num_children do
		item.min_children_offset = item.min_children_offset - item.height
		reset_min_children_offsets(item.children[i])
	end
end

local function update_min_children_offsets(item)
	if item.parent == nil then return end

	local min_children_offset = 0
	for i=1, item.parent.num_children do
		if item.parent.children[i] == item then
			break
		end

		min_children_offset = min_children_offset - item.parent.children[i].total_height
	end

	item.parent.min_children_offset = min_children_offset

	update_min_children_offsets(item.parent)
end

local function update_child_offsets_up(item, y_delta)
	assert(y_delta < 0)

	local y_offset = item.children_offset
	for i=1, item.num_children do
		if y_offset > -y_delta then
			-- the next child is further away than y_delta so just move it
			item.children_offset = item.children_offset + y_delta
			return 0
		--elseif y_offset >= 0 or i==item.num_children then
		elseif y_offset > 0 then
			-- Next child needs to be moved up but it's not enough, it's children
			--   will have to be moved too.
			-- Move the child to max top position
			item.children_offset = item.children_offset - y_offset
			y_delta = y_delta + y_offset

			if y_delta == 0  then
				-- Very unlikely (y_delta should still be < 0) but hey
				return 0
			end
			assert(y_delta < 0)
		end

		local child_item = item.children[i]
		if child_item.num_children > 0 then
			y_delta = update_child_offsets_up(child_item, y_delta)
			if y_delta == 0 then
				return 0
			end
		end

		y_offset = y_offset + item.children[i].height
	end


	if item.children_offset > item.min_children_offset then
		item.children_offset = item.children_offset + y_delta
		if item.children_offset < item.min_children_offset then
			y_delta = item.children_offset - item.min_children_offset
			assert(y_delta < 0)
			item.children_offset = item.min_children_offset
		else
			return 0
		end
	end

	assert(y_delta < 0)
	return y_delta

end

local function update_child_offsets_down(item, y_delta)
	-- the hot item is above where we want it to be, so move everything DOWN
	assert(y_delta > 0)

	local y_offset = item.children_offset
	local next_child_index = 0
	for i=1, item.num_children do
		local child_item = item.children[i]
		if child_item.hot_child or child_item.hot then
			next_child_index = i
			break
		end

		if y_offset >= 0 then
			next_child_index = i
			break
		end

		y_offset = y_offset + child_item.actual_height + child_item.height
	end

	-- y_offset is now the distance to the hot item or a parent to it. negative means it's too far up.
	if y_offset < -y_delta then
		item.children_offset = item.children_offset + y_delta
		return 0
	elseif y_offset < 0 then
		item.children_offset = item.children_offset - y_offset
		y_delta = y_delta + y_offset
	end

	for i = next_child_index, 1, -1 do
		local child_item = item.children[i]

		if y_offset > y_delta then
			-- the next child is further away than y_delta so just move it
			item.children_offset = item.children_offset + y_delta
			return 0
		elseif y_offset > 0 then
			-- Next child needs to be moved up but it's not enough, it's children
			--   will have to be moved too.
			-- Move the child to max top position
			item.children_offset = item.children_offset - y_offset
			y_delta = y_delta + y_offset

			if y_delta == 0  then
				-- Very unlikely (y_delta should still be < 0) but hey
				return 0
			end
			assert(y_delta > 0)
		end

		if child_item.num_children > 0 then
			y_delta = update_child_offsets_down(child_item, y_delta)
			if y_delta == 0 then
				return 0
			end
		end
	end

	if item.title == "Root" then
		item.children_offset = item.children_offset + y_delta
		return 0
	end

	if item.children_offset < 0 then
		item.children_offset = item.children_offset + y_delta
		if item.children_offset > 0 then
			local overflow = item.children_offset
			item.children_offset = 0
			return overflow
		else
			return 0
		end
	end

	return y_delta
end

local function update_child_offsets_below_hot_item(item)
	local found_hot = false
	for i=1, item.num_children do
		local child_item = item.children[i]

		if child_item.hot_child or child_item.hot then
			found_hot = true
		end

		if found_hot then
			if child_item.num_children > 0 and child_item.children_offset < 0 and not child_item.hot_child then
				child_item.children_offset = math.min(0, child_item.children_offset + 5)
			end

			update_child_offsets_below_hot_item(child_item)
		end
	end
end

local function update_menu(debug_menu, dt)
	debug_menu.time = debug_menu.time + dt

	local res_x, res_y = Gui.resolution()
	local center = res_y *0.25

	local hot_item = debug_menu.hot_item
	local distance_to_hot_item_from_top_of_window = distance_to_item(debug_menu.menu_root, hot_item)
	local distance_to_center_upwards = distance_to_hot_item_from_top_of_window - center
	local lerp_t = 0.05

	if math.abs(distance_to_center_upwards) < 50 then
		update_child_offsets_below_hot_item(debug_menu.menu_root)
	end

	if math.abs(distance_to_center_upwards) > 0.01 then
		local wanted_distance_to_center = lerp(distance_to_center_upwards, 0, lerp_t)


		-- y_delta is negative if hot item is below center
		local y_delta = -(distance_to_center_upwards - wanted_distance_to_center)

		update_actual_heights(debug_menu.menu_root)
		update_total_heights(debug_menu.menu_root) -- todo
		reset_min_children_offsets(debug_menu.menu_root) -- todo
		update_min_children_offsets(debug_menu.hot_item) -- todo
		if y_delta < 0 then
			update_child_offsets_up(debug_menu.menu_root, y_delta)
		elseif y_delta > 0 then
			update_child_offsets_down(debug_menu.menu_root, y_delta)
		end
	end

	if debug_menu.enabled then
		debug_menu.fade_timer = math.min(1, debug_menu.fade_timer + dt * fade_speed)
	else
		debug_menu.fade_timer = math.max(0, debug_menu.fade_timer - dt * fade_speed)
	end
end

--██████╗ ██████╗  █████╗ ██╗    ██╗
--██╔══██╗██╔══██╗██╔══██╗██║    ██║
--██║  ██║██████╔╝███████║██║ █╗ ██║
--██║  ██║██╔══██╗██╔══██║██║███╗██║
--██████╔╝██║  ██║██║  ██║╚███╔███╔╝
--╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚══╝╚══╝


font = 'core/editor_slave/resources/gui/arial'
font_material = 'core/editor_slave/resources/gui/arial'
font_size_normal = 24
font_size_hot = 28
font_size_dotdotdot = 72
templates = {
	--folder = {
		--size = font_size_normal,
		--color = "white"
	--},
	title = {
		size = font_size_normal,
		color = "text_color",
	},
	title_hot = {
		size = font_size_hot,
		color = "text_color_hot",
	},
	dotdotdot = {
		size = font_size_dotdotdot,
		color = "dotdotdot",
	},
}

draw_text = function(gui, colors, style_template, text, position, alpha)
	local template = templates[style_template]
	local size = template.size
	local color = colors[template.color]
	local old_alpha = color.x
	color.x = color.x * alpha
	Gui.text(gui, text, font_material, size, font, position, Vector2(1,1), color)
	color.x = old_alpha
end

text_extents = function(gui, style_template, text)
	local font_size = templates[style_template].size
	local extents_min, extents_max, caret = Gui.text_extents(gui, text, font, font_size)
	return extents_min, extents_max, caret
end

local function draw_menu_item_children(debug_menu, menu_item, position)
	-- todo rewrite this to draw itself and then call itself on children?

	local gui = debug_menu.gui
	local colors = debug_menu.colors

	--if menu_item.title == "Root" then
		--local alpha = 1
		--local loltext = string.format("  ------------------------------------------- [ h = %d, co = %d / %d ]", menu_item.total_height, menu_item.children_offset, menu_item.min_children_offset)
		--local rootpos = Vector3(position.x - 20, position.y, position.z)
		--draw_text(gui, colors, menu_item.hot and "title_hot" or "title", menu_item.title .. loltext, rootpos, alpha)

		---- menu_item:draw(gui, position, alpha)
	--end

	local y_offset = menu_item.children_offset
	position.y = position.y - y_offset
	for i=1, menu_item.num_children do
		local child_menu_item = menu_item.children[i]
		y_offset = y_offset + child_menu_item.height
		position.y = position.y - child_menu_item.height

		if y_offset > 0 then
			local alpha = 1
			if y_offset < 10 then
				alpha = 0
			elseif y_offset < child_menu_item.height then
				alpha = lerp(0, 1, (y_offset-10) / (child_menu_item.height-10))
			end

			if child_menu_item.hot then
				Gui.rect(gui, position + Vector3(-position.x, -5, 0), Vector2(width, child_menu_item.height), colors.row_highlight_color)
				draw_text(gui, colors, "title_hot", ">", position - Vector3(20, 0, 0), 1)
				--Gui.text(gui, ">", font_mtrl, font_size, font , Vector3(setting_x + indicator_offset_anim, pos_y, 900), text_color_hot)
			end

			local loltext = ""--child_menu_item.num_children == 0 and "" or string.format("  -----                                              --- [ h = %d, co = %d / %d ]", child_menu_item.total_height, child_menu_item.children_offset, child_menu_item.min_children_offset)
			draw_text(gui, colors, child_menu_item.hot and "title_hot" or "title", child_menu_item.title .. loltext, position, alpha)

			child_menu_item:draw(gui, position, alpha)

			if child_menu_item.num_children > 0 and child_menu_item.children_offset < -10 then
				local extents_min, extents_max, caret = text_extents(gui, "title", child_menu_item.title)
				local dotposition = position + Vector3(caret.x, 0, 0)
				draw_text(gui, colors, "dotdotdot", string.rep(".", math.ceil(child_menu_item.children_offset / -30)), dotposition, alpha)
			end

		else
			local alpha = 10
			local loltext = child_menu_item.num_children == 0 and "" or string.format("  -----                                              --- [ h = %d, co = %d / %d ]", child_menu_item.total_height, child_menu_item.children_offset, child_menu_item.min_children_offset)
			--draw_text(gui, colors, "title", child_menu_item.title .. loltext, position, alpha)

			--child_menu_item:draw(gui, position, alpha)
		end

		y_offset = y_offset + child_menu_item.total_height + (child_menu_item.num_children == 0 and 0 or child_menu_item.children_offset)

		if child_menu_item.expanded and y_offset > 0 then
			position.x = position.x + 50
			draw_menu_item_children(debug_menu, child_menu_item, position)
			position.x = position.x - 50
		end
	end
end

local function draw_background(gui, res_y, offset_lerp)
	Gui.rect(gui, Vector3(-width + offset_lerp * width, 0, 0), Vector2(width, res_y), Color(offset_lerp*220,25,50,25))
end

local function draw_menu(debug_menu, dt)
	-- update colors
	local offset_lerp = ease_out_quad(debug_menu.fade_timer, 0, 1, 1)
	for name, color in pairs(boxed_colors) do
		debug_menu.colors[name] = color:unbox()
		debug_menu.colors[name].x = debug_menu.colors[name].x * offset_lerp -- alpha component
	end

	local hot_anim_t = (math.sin(debug_menu.time * 10) + 1) * 0.5
	debug_menu.colors.text_color_hot.y = debug_menu.colors.text_color_hot.y + hot_anim_t * 25
	debug_menu.colors.text_color_hot.z = debug_menu.colors.text_color_hot.z + hot_anim_t * 25
	debug_menu.colors.text_color_hot.w = debug_menu.colors.text_color_hot.w + hot_anim_t * 25

	local res_x, res_y = Gui.resolution()
	local offset_x = -width + offset_lerp * width
	local position = Vector3(20 + offset_x, res_y - 100, 0)
	position.y = res_y - 20
	draw_background(debug_menu.gui, res_y, offset_lerp)
	draw_menu_item_children(debug_menu, debug_menu.menu_root, position)
end

local function update(debug_menu, dt)
	jit.off()

	handle_input(debug_menu)
	update_menu(debug_menu, dt)
	draw_menu(debug_menu)
end

 --█████╗ ██████╗ ██╗
--██╔══██╗██╔══██╗██║
--███████║██████╔╝██║
--██╔══██║██╔═══╝ ██║
--██║  ██║██║     ██║
--╚═╝  ╚═╝╚═╝     ╚═╝

jit.off()

stingray.core = stingray.core or {}
stingray.core.DebugMenu = simple_class(stingray.core.DebugMenu)
local DebugMenu = stingray.core.DebugMenu

function DebugMenu:init(...)
	self.debug_menu = create(...)
end

function DebugMenu:update(dt)
	update(self.debug_menu, dt)
end

function DebugMenu:destroy()
	destroy(self.debug_menu)
end

return DebugMenu
