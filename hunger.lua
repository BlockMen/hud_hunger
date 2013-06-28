function hud.item_eat(hunger_change, replace_with_item)
	return function(itemstack, user, pointed_thing)
		if itemstack:take_item() ~= nil then
			local h = tonumber(hud.hunger[user:get_player_name()])
			h=h+hunger_change
			if h>20 then h=20 end
			hud.hunger[user:get_player_name()]=h
			itemstack:add_item(replace_with_item) -- note: replace_with_item is optional
			--sound:eat
		end
		return itemstack
	end
end

local function overwrite(name, hunger_change, as_node)
	local tab = minetest.registered_items[name]
	if tab == nil then return end
	local tab2 = {}
	for i,v in pairs(tab) do
		tab2[i] = v
	end
	tab2.on_use = hud.item_eat(hunger_change)

	if as_node then
		minetest.register_node(":"..name, tab2)
	else
		minetest.register_craftitem(":"..name, tab2)
	end
end

overwrite("default:apple", 2, true)
if minetest.get_modpath("farming") ~= nil then
	overwrite("farming:bread", 6, false)
end
