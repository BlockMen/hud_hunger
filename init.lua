hud = {}

local health_hud = {}
hud.hunger = {}
local hunger_hud = {}
local air_hud = {}
local inv_hud = {}

local SAVE_INTERVAL = 0.5*60--currently useless

--default settings
HUD_ENABLE_HUNGER = minetest.setting_getbool("hud_hunger_enable")
if HUD_ENABLE_HUNGER == nil then HUD_ENABLE_HUNGER = minetest.setting_getbool("enable_damage") end
HUD_HUNGER_TICK = 300
HUD_HEALTH_POS = {x=0.5,y=0.9}
HUD_HEALTH_OFFSET = {x=-175, y=2}
HUD_HUNGER_POS = {x=0.5,y=0.9}
HUD_HUNGER_OFFSET = {x=15, y=2}

--load costum settings
local set = io.open(minetest.get_modpath("hud").."/hud.conf", "r")
if set then 
	dofile(minetest.get_modpath("hud").."/hud.conf")
	set:close()
else
	if not HUD_ENABLE_HUNGER then
		HUD_AIR_OFFSET = {x=15,y=0}
	end
end

--minetest.after(SAVE_INTERVAL, timer, SAVE_INTERVAL)

local function hide_builtin(player)
	 player:hud_set_flags({crosshair = true, hotbar = true, healthbar = false, wielditem = true, breathbar = false})
end


local function costum_hud(player)

 if minetest.setting_getbool("enable_damage") then
 --hunger
	if HUD_ENABLE_HUNGER then
       	 player:hud_add({
		hud_elem_type = "statbar",
		position = HUD_HUNGER_POS,
		scale = {x=1, y=1},
		text = "hud_hunger_bg.png",
		number = 20,
		alignment = {x=-1,y=-1},
		offset = HUD_HUNGER_OFFSET,
	 })

	 hunger_hud[player:get_player_name()] = player:hud_add({
		hud_elem_type = "statbar",
		position = HUD_HUNGER_POS,
		scale = {x=1, y=1},
		text = "hud_hunger_fg.png",
		number = 20,
		alignment = {x=-1,y=-1},
		offset = HUD_HUNGER_OFFSET,
	 })
	end
 --health
        player:hud_add({
		hud_elem_type = "statbar",
		position = HUD_HEALTH_POS,
		scale = {x=1, y=1},
		text = "hud_heart_bg.png",
		number = 20,
		alignment = {x=-1,y=-1},
		offset = HUD_HEALTH_OFFSET,
	})

	health_hud[player:get_player_name()] = player:hud_add({
		hud_elem_type = "statbar",
		position = HUD_HEALTH_POS,
		scale = {x=1, y=1},
		text = "hud_heart_fg.png",
		number = player:get_hp(),
		alignment = {x=-1,y=-1},
		offset = HUD_HEALTH_OFFSET,
	})
 end

end


local function update_hud(player)
--health
	player:hud_change(health_hud[player:get_player_name()], "number", player:get_hp())
--hunger
	local h = tonumber(hud.hunger[player:get_player_name()])
	if h>20 then h=20 end
	player:hud_change(hunger_hud[player:get_player_name()], "number", h)
end

function hud.save_hunger(player)
	local file = io.open(minetest.get_worldpath().."/hud_"..player:get_player_name().."_hunger", "w+")
	if file then
		file:write(hud.hunger[player:get_player_name()])
		file:close()
	end
end

local function timer(interval, player)
	if interval > 0 then
		hud.save_hunger(player)
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
		hud.save_hunger(player)
		hide_builtin(player)
		costum_hud(player)
	end)
end)

minetest.register_on_respawnplayer(function(player)
	hud.hunger[player:get_player_name()] = 20
	minetest.after(0.5, function()
		hud.save_hunger(player)
	end)
end)

local timer = 0
local timer2 = 0
minetest.after(2.5, function()
	minetest.register_globalstep(function(dtime)
	 timer = timer + dtime
	 timer2 = timer2 + dtime
		for _,player in ipairs(minetest.get_connected_players()) do
			update_fast(player)
			if minetest.setting_getbool("enable_damage") then
			 local h = tonumber(hud.hunger[player:get_player_name()])
			 if HUD_ENABLE_HUNGER and timer > 4 then
				if h>=16 and player:get_hp() > 0 then
					player:set_hp(player:get_hp()+1)
				elseif h<=1 and minetest.setting_getbool("enable_damage") then
					if player:get_hp()-1 >= 1 then player:set_hp(player:get_hp()-1) end
				end
			 end
			 if HUD_ENABLE_HUNGER and timer2>HUD_HUNGER_TICK then
				if h>1 then
					h=h-1
					hud.hunger[player:get_player_name()]=h
					hud.save_hunger(player)
				end
			 end
			 update_hud(player)
			end
		end
		if timer>4 then timer=0 end
		if timer2>HUD_HUNGER_TICK then timer2=0 end
	end)
end)

if HUD_ENABLE_HUNGER then dofile(minetest.get_modpath("hud").."/hunger.lua") end
