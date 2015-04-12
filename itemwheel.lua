local hb = {}

local function update_wheel(player)
	local name = player:get_player_name()
	if not player or not name then
		return
	end

	local i = player:get_wield_index()
	local i1 = i - 1
	local i3 = i + 1

	-- it's a wheel
	if i1 < 1 then
		i1 = HUD_IW_MAX
	end
	if i3 > HUD_IW_MAX then
		i3 = 1
	end

	-- get the displayed items
	local inv = player:get_inventory()
	local item = hb[name].item
	local item2 = player:get_wielded_item():get_name()

	-- update all items when wielded has changed
	if item and item2 and item ~= item2 or item == "wheel_init" then
		local items = {}
		items[1] = inv:get_stack("main", i1):get_name() or nil
		items[2] = item2
		items[3] = inv:get_stack("main", i3):get_name() or nil

		for n, m in pairs(items) do
			-- some default values
			local image = "hud_wielded.png"
			local scale = false
			local s1 = {x = 1, y = 1}
			local s2 = {x = 3, y = 3}
			if n ~= 2 then
				s1 = {x = 0.6, y = 0.6}
				s2 = {x = 2, y = 2}
			end

			-- get the images
			local def = minetest.registered_items[m]
			if def then
				if def.tiles then
					image = minetest.inventorycube(def.tiles[1], def.tiles[6] or def.tiles[3] or def.tiles[1], def.tiles[3] or def.tiles[1])
					scale = true
				end
				if def.inventory_image and def.inventory_image ~= "" then
					image = def.inventory_image
					scale = false
				end
				if def.wielded_image and def.wielded_image ~= "" then
					image = def.wielded_image
					scale = false
				end
			end

			-- get the id and update hud elements
			local id = hb[name].id[n]
			if id and image then
				if scale then
					player:hud_change(id, "scale", s1)
				else
					player:hud_change(id, "scale", s2)
				end
				-- make previous and next item darker
				--if n ~= 2 then
					--image = image .. "^[colorize:#0005"
				--end
				player:hud_change(id, "text", image)
			end
		end
	end

	-- update wielded buffer
	if hb[name].id[2] ~= nil then
		hb[name].item = item
	end
end

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    hb[name]= {}
    hb[name].id = {}
    hb[name].item = "wheel_init"

    minetest.after(0.1, function()

	-- hide builtin hotbar
	local hud_flags = player:hud_get_flags()
	hud_flags.hotbar = false
	player:hud_set_flags(hud_flags)

	player:hud_add({
		hud_elem_type = "image",
		text = "hud_new.png",
		position = {x=0.5, y=1},
		scale = {x=1, y=1},
		alignment = {x=0, y=-1},
		offset = {x = 0, y = 0}
	})

	hb[name].id[1] = player:hud_add({
		hud_elem_type = "image",
		text = "hud_wielded.png",
		position = {x = 0.5, y = 1},
		scale = {x = 1, y = 1},
		alignment = {x = 0, y = -1},
		offset = {x = -75, y = -8}
	})

	hb[name].id[2] = player:hud_add({
		hud_elem_type = "image",
		text = "hud_wielded.png",
		position = {x = 0.5, y = 1},
		scale = {x = 3, y = 3},
		alignment = {x = 0, y = -1},
		offset = {x = 0, y = -20}
	})

	hb[name].id[3] = player:hud_add({
		hud_elem_type = "image",
		text = "hud_wielded.png",
		position = {x = 0.5, y = 1},
		scale = {x = 1, y = 1},
		alignment = {x = 0, y = -1},
		offset = {x = 75, y = -8}
	})

	-- init item wheel
	hb[name].item = "wheel_init"
	update_wheel(player)
    end)
end)


local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer >= HUD_IW_TICK then
		timer = 0
		for _, player in ipairs(minetest.get_connected_players()) do
			update_wheel(player)
		end
	end--timer
end)