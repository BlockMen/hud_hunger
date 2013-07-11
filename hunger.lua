function hud.item_eat(hunger_change, replace_with_item)
	return function(itemstack, user, pointed_thing)
		if itemstack:take_item() ~= nil then
			local h = tonumber(hud.hunger[user:get_player_name()])
			h=h+hunger_change
			if h>30 then h=30 end
			hud.hunger[user:get_player_name()]=h
			hud.save_hunger(user)
			itemstack:add_item(replace_with_item) -- note: replace_with_item is optional
			--sound:eat
		end
		return itemstack
	end
end

local function overwrite(name, hunger_change, replace_with_item)
	local tab = minetest.registered_items[name]
	if tab == nil then return end
	tab.on_use = hud.item_eat(hunger_change)--, replace_with_item)
	minetest.registered_items[name] = tab
end

minetest.after(0.5, function()--ensure all other mods get loaded
overwrite("default:apple", 2)
if minetest.get_modpath("farming") ~= nil then
	overwrite("farming:bread", 4)
end

if minetest.get_modpath("mobs") ~= nil then
	overwrite("mobs:meat", 6)
	overwrite("mobs:meat_raw", 3)
	overwrite("mobs:rat_cooked", 5)
end

if minetest.get_modpath("moretrees") ~= nil then
	overwrite("moretrees:coconut_milk", 1)
	overwrite("moretrees:raw_coconut", 2)
	overwrite("moretrees:acorn_muffin", 3)
	overwrite("moretrees:spruce_nuts", 1)
	overwrite("moretrees:pine_nuts", 1)
	overwrite("moretrees:fir_nuts", 1)
end

if minetest.get_modpath("dwarves") ~= nil then
	overwrite("dwarves:beer", 2)
	overwrite("dwarves:apple_cider", 1)
	overwrite("dwarves:midus", 2)
	overwrite("dwarves:tequila", 2)
	overwrite("dwarves:tequila_with_lime", 2)
	overwrite("dwarves:sake", 2)
end

if minetest.get_modpath("animalmaterials") ~= nil then
	overwrite("animalmaterials:milk", 2)
	overwrite("animalmaterials:meat_raw", 3)
	overwrite("animalmaterials:meat_pork", 3)
	overwrite("animalmaterials:meat_beef", 3)
	overwrite("animalmaterials:meat_chicken", 3)
	overwrite("animalmaterials:meat_lamb", 3)
	overwrite("animalmaterials:meat_venison", 3)
	--overwrite("animalmaterials:meat_undead", 3)-- -3 damage
	--overwrite("animalmaterials:meat_toxic", 3)-- -5 damage
	overwrite("animalmaterials:meat_ostrich", 3)
	overwrite("animalmaterials:fish_bluewhite", 2)
	overwrite("animalmaterials:fish_clownfish", 2)
end

if minetest.get_modpath("fishing") ~= nil then
	overwrite("fishing:fish_raw", 2)
	overwrite("fishing:fish", 4)
	overwrite("fishing:sushi", 6)
end

if minetest.get_modpath("glooptest") ~= nil then
	overwrite("glooptest:kalite_lump", 1)
end

if minetest.get_modpath("bushes") ~= nil then
	overwrite("bushes:sugar", 1)
	overwrite("bushes:strawberry", 2)
	overwrite("bushes:berry_pie_raw", 3)
	overwrite("bushes:berry_pie_cooked", 4)
	overwrite("bushes:basket_pies", 15)
end
end)
