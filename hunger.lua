function hud.save_hunger(player)
	local file = io.open(minetest.get_worldpath().."/hud_"..player:get_player_name().."_hunger", "w+")
	if file then
		file:write(hud.hunger[player:get_player_name()])
		file:close()
	end
end

function hud.load_hunger(player)
	local file = io.open(minetest.get_worldpath().."/hud_"..player:get_player_name().."_hunger", "r")
	if file then
		hud.hunger[player:get_player_name()] = file:read("*all")
		file:close()
		return hud.hunger[player:get_player_name()]
	else
		return
	end
	
end

local function poisenp(tick, time, time_left, player)
	time_left = time_left + tick
	if time_left < time then
		minetest.after(tick, poisenp, tick, time, time_left, player)
	end
	if player:get_hp()-1 > 0 then
		player:set_hp(player:get_hp()-1)
	end
	
end

function hud.item_eat(hunger_change, replace_with_item, poisen)
	return function(itemstack, user, pointed_thing)
		if itemstack:take_item() ~= nil then
			local h = tonumber(hud.hunger[user:get_player_name()])
			h=h+hunger_change
			if h>30 then h=30 end
			hud.hunger[user:get_player_name()]=h
			hud.save_hunger(user)
			itemstack:add_item(replace_with_item) -- note: replace_with_item is optional
			--sound:eat
			if poisen then
				poisenp(1.0, poisen, 0, user)
			end
		end
		return itemstack
	end
end

local function overwrite(name, hunger_change, replace_with_item, poisen)
	local tab = minetest.registered_items[name]
	if tab == nil then return end
	tab.on_use = hud.item_eat(hunger_change, replace_with_item, poisen)
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
	overwrite("animalmaterials:meat_undead", 3, "", 3)
	overwrite("animalmaterials:meat_toxic", 3, "", 5)
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

if minetest.get_modpath("docfarming") ~= nil then
	overwrite("docfarming:carrot", 2)
	overwrite("docfarming:cucumber", 2)
	overwrite("docfarming:corn", 2)
	overwrite("docfarming:potato", 4)
	overwrite("docfarming:bakedpotato", 5)
	overwrite("docfarming:raspberry", 3)
end

if minetest.get_modpath("farming_plus") ~= nil then
	overwrite("farming_plus:carrot_item", 3)
	overwrite("farming_plus:banana", 2)
	overwrite("farming_plus:orange_item", 2)
	overwrite("farming_plus:pumpkin_bread", 4)
	overwrite("farming_plus:strawberry_item", 2)
	overwrite("farming_plus:tomato_item", 2)
	overwrite("farming_plus:potatoe_item", 4)
end

if minetest.get_modpath("mtfoods") ~= nil then
	overwrite("mtfoods:dandelion_milk", 1)
	overwrite("mtfoods:sugar", 1)
	overwrite("mtfoods:short_bread", 4)
	overwrite("mtfoods:cream", 1)
	overwrite("mtfoods:chocolate", 2)
	overwrite("mtfoods:cupcake", 2)
	overwrite("mtfoods:strawberry_shortcake", 2)
	overwrite("mtfoods:cake", 3)
	overwrite("mtfoods:chocolate_cake", 3)
	overwrite("mtfoods:carrot_cake", 3)
	overwrite("mtfoods:pie_crust", 3)
	overwrite("mtfoods:apple_pie", 3)
	overwrite("mtfoods:rhubarb_pie", 2)
	overwrite("mtfoods:banana_pie", 3)
	overwrite("mtfoods:pumpkin_pie", 3)
	overwrite("mtfoods:cookies", 2)
	overwrite("mtfoods:mlt_burger", 5)
	overwrite("mtfoods:potato_slices", 2)
	overwrite("mtfoods:potato_chips", 3)
	--mtfoods:medicine
	overwrite("mtfoods:casserole", 3)
	overwrite("mtfoods:glass_flute", 2)
	overwrite("mtfoods:orange_juice", 2)
	overwrite("mtfoods:apple_juice", 2)
	overwrite("mtfoods:apple_cider", 2)
	overwrite("mtfoods:cider_rack", 2)
end
end)
