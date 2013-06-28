local function drwn_overwrite(name)
	local table = minetest.registered_nodes[name]
	local table2 = {}
	for i,v in pairs(table) do
		table2[i] = v
	end
	table2.drowning = false
	table2.hud_drowning = true
	minetest.register_node(":"..name, table2)
end

drwn_overwrite("default:water_source")
drwn_overwrite("default:water_flowing")
drwn_overwrite("default:lava_source")
drwn_overwrite("default:lava_flowing")
