hud = {}

local health_hud = {}
hud.hunger = {}
local hunger_hud = {}
hud.air = {}
local air_hud = {}

local SAVE_INTERVAL = 0.5*60--currently useless

local ENABLE_HUNGER = minetest.setting_getbool("enable_damage") -- set to false if no hunger wanted
local NO_HUNGER_TIME = 300 --=5min (so 1h playing == hunger)

--minetest.after(SAVE_INTERVAL, timer, SAVE_INTERVAL)

local function hide_builtin(player)
	 player:hud_set_flags({crosshair = false, hotbar = true, healthbar = false, wielditem = true, breathbar = false})
end

local function costum_hud(player)
--crosshair
        player:hud_add({
            hud_elem_type = "image",
            text = "hud_cross.png",
            position = {x=0.5, y=0.5},
            scale = {x=1, y=1},
        })
if minetest.setting_getbool("enable_damage") then
--hunger
        player:hud_add({
		hud_elem_type = "statbar",
		position = {x=0.5,y=1},
		scale = {x=1, y=1},
		text = "hud_hunger_bg.png",
		number = 20,
		alignment = {x=-1,y=-1},
		offset = {x=15,y=-60},
	})

	hunger_hud[player:get_player_name()] = player:hud_add({
		hud_elem_type = "statbar",
		position = {x=0.5,y=1},
		scale = {x=1, y=1},
		text = "hud_hunger_fg.png",
		number = 20,
		alignment = {x=-1,y=-1},
		offset = {x=15,y=-60},
	})
--health
        player:hud_add({
		hud_elem_type = "statbar",
		position = {x=0.5,y=1},
		scale = {x=1, y=1},
		text = "hud_heart_bg.png",
		number = 20,
		alignment = {x=-1,y=-1},
		offset = {x=-175,y=-60},
	})

	health_hud[player:get_player_name()] = player:hud_add({
		hud_elem_type = "statbar",
		position = {x=0.5,y=1},
		scale = {x=1, y=1},
		text = "hud_heart_fg.png",
		number = player:get_hp(),
		alignment = {x=-1,y=-1},
		offset = {x=-175,y=-60},
	})
end

end


local function update_hud(player)
--health
	player:hud_change(health_hud[player:get_player_name()], "number", player:get_hp())
--hunger
	player:hud_change(hunger_hud[player:get_player_name()], "number", hud.hunger[player:get_player_name()])
end


local function save_hunger(player)
	local file = io.open(minetest.get_worldpath().."/hud_"..player:get_player_name().."_hunger", "w+")
	if file then
		file:write(hud.hunger[player:get_player_name()])
		file:close()
	end
end

local function timer(interval, player)
	if interval > 0 then
		save_hunger(player)
		minetest.after(interval, timer, interval, player)
	end
end

local function load_hunger(player)
	local file = io.open(minetest.get_worldpath().."/hud_"..player:get_player_name().."_hunger", "r")
	if file then
		hud.hunger[player:get_player_name()] = file:read("*all")
		file:close()
		return hud.hunger[player:get_player_name()]
	else
		return
	end
	
end


minetest.register_on_joinplayer(function(player)
	hud.hunger[player:get_player_name()] = load_hunger(player)
	if hud.hunger[player:get_player_name()] == nil then
		hud.hunger[player:get_player_name()] = 20
	end
	minetest.after(0.5, function()
		save_hunger(player)
		hide_builtin(player)
		costum_hud(player)
	end)
end)

local timer = 0
local timer2 = 0
minetest.after(2.5, function()
if minetest.setting_getbool("enable_damage") then
	minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	timer2 = timer2 + dtime
		for _,player in ipairs(minetest.get_connected_players()) do
			local h = tonumber(hud.hunger[player:get_player_name()])
			if ENABLE_HUNGER and timer > 4 then
				if h>=18 then
					player:set_hp(player:get_hp()+1)
				elseif h==1 and minetest.setting_getbool("enable_damage") then
					if player:get_hp()-1 >= 1 then player:set_hp(player:get_hp()-1) end
				end
			end
			if ENABLE_HUNGER and timer2>NO_HUNGER_TIME then
				--local h = tonumber(hunger[player:get_player_name()])
				if h>1 then
					h=h-1
					hud.hunger[player:get_player_name()]=h
					save_hunger(player)
				end
			end
			update_hud(player)
		end
		if timer>4 then timer=0 end
		if timer2>NO_HUNGER_TIME then timer2=0 end
	end)
end
end)

if ENABLE_HUNGER then dofile(minetest.get_modpath("hud").."/hunger.lua") end
dofile(minetest.get_modpath("hud").."/no_drowning.lua")
