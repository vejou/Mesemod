
-- Mod:     BEES
-- Author:  Bas080 (Updated by TenPlus1)
-- License: MIT

-- Translation support

local S = minetest.get_translator("bees")

-- Functions and Formspecs

local floor, random = math.floor, math.random


local function hive_wild(pos, grafting)

	local spos = pos.x .. "," .. pos.y .. "," ..pos.z
	local formspec = "size[8,9]"
		.. "label[0,0;" .. S("Wild Bee Hive") .. "]"
		.. "list[nodemeta:" .. spos .. ";combs;1.5,3;5,1;]" -- Honey Comb
		.. "list[current_player;main;0,5;8,4;]" -- Player Inventory

	if grafting then
		formspec = formspec .."list[nodemeta:".. spos .. ";queen;3.5,1;1,1;]" -- Queen
	else
		formspec = formspec .. "item_image[3.5,1;1,1;bees:queen]"
	end

	return formspec
end


local function hive_artificial(pos)

	local spos = pos.x .. "," .. pos.y .. "," .. pos.z
	local formspec = "size[8,9]"
		.. "label[0,0;" .. S("Artificial Bee Hive") .. "]"
		.. "item_image[2.5,1;1,1;bees:queen]" -- Queen
		.. "list[nodemeta:" .. spos .. ";queen;3.5,1;1,1;]"
		.. "tooltip[3.5,1;1,1;" .. S("Queen Bee").."]"
		.. "list[nodemeta:" .. spos .. ";frames;0,3;8,1;]" -- Frames
		.. "tooltip[0,3;8,1;" .. S("Empty Hive Frame") .. "]"
		.. "list[current_player;main;0,5;8,4;]" -- Player Inventory

	return formspec
end


local polinate_flower = function(pos, flower)

	local spawn_pos = {
		x = pos.x + random(-3, 3),
		y = pos.y + random(-3, 3),
		z = pos.z + random(-3, 3)
	}
	local floor_pos = {x = spawn_pos.x, y = spawn_pos.y - 1, z = spawn_pos.z}
	local spawn = minetest.get_node(spawn_pos).name
	local floorn = minetest.get_node(floor_pos).name

	if floorn == "group:soil" and spawn == "air" then
		minetest.set_node(spawn_pos, {name = flower})
	end
end


local sting_player = function(player, damage)

	minetest.after(0.1, function()
		if player and player:get_pos() then
			player:set_hp(player:get_hp() - damage)
		end
	end)
end

-- Nodes

minetest.register_node("bees:extractor", {
	description = S("Honey Extractor"),
	tiles = {
		"bees_extractor.png", "bees_extractor.png", "bees_extractor.png",
		"bees_extractor.png", "bees_extractor.png", "bees_extractor_front.png"
	},
	paramtype2 = "facedir",
	groups = {
		choppy = 2, oddly_breakable_by_hand = 2, tubedevice = 1,
		tubedevice_receiver = 1
	},
	is_ground_content = false,

	on_construct = function(pos)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		pos = pos.x .. "," .. pos.y .. "," .. pos.z

		inv:set_size("frames_filled", 1)
		inv:set_size("frames_emptied", 1)
		inv:set_size("bottles_empty", 1)
		inv:set_size("bottles_full", 1)
		inv:set_size("wax", 1)

		meta:set_string("formspec", "size[8,9]"
			.. "label[0,0;" .. S("Honey Extractor") .. "]"
			-- input
			.. "item_image[1,1;1,1;bees:frame_full]"
			.. "list[nodemeta:" .. pos .. ";frames_filled;2,1;1,1;]"
			.. "tooltip[2,1;1,1;" .. S("Filled Hive Frame") .. "]"
			.. "item_image[1,3;1,1;vessels:glass_bottle]"
			.. "list[nodemeta:" .. pos .. ";bottles_empty;2,3;1,1;]"
			.. "tooltip[2,3;1,1;Empty Bottles]"
			-- output
			.. "label[4,2;->]"
			.. "list[nodemeta:" .. pos .. ";frames_emptied;5,0.5;1,1;]"
			.. "tooltip[5,0.5;1,1;" .. S("Empty Hive Frame") .. "]"
			.. "list[nodemeta:" .. pos .. ";wax;5,2;1,1;]"
			.. "tooltip[5,2;1,1;" .. S("Bees Wax") .. "]"
			.. "list[nodemeta:" .. pos .. ";bottles_full;5,3.5;1,1;]"
			.. "tooltip[5,3.5;1,1;" .. S("Honey Bottle") .. "]"
			-- player inventory
			.. "list[current_player;main;0,5;8,4;]"
		)
	end,

	can_dig = function(pos)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		if inv:is_empty("frames_filled") and inv:is_empty("frames_emptied")
		and inv:is_empty("bottles_empty") and inv:is_empty("bottles_full")
		and inv:is_empty("wax") then
			return true
		else
			return false
		end
	end,

	on_timer = function(pos)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local timer = minetest.get_node_timer(pos)

		if not inv:contains_item("frames_filled", "bees:frame_full")
		or not inv:contains_item("bottles_empty", "vessels:glass_bottle") then
			return
		end

		if inv:room_for_item("frames_emptied", "bees:frame_empty")
		and inv:room_for_item("wax", "bees:wax")
		and inv:room_for_item("bottles_full", "bees:bottle_honey") then

			-- add to output
			inv:add_item("frames_emptied", "bees:frame_empty")
			inv:add_item("wax", "bees:wax")
			inv:add_item("bottles_full", "bees:bottle_honey")

			-- remove from input
			inv:remove_item("bottles_empty", "vessels:glass_bottle")
			inv:remove_item("frames_filled", "bees:frame_full")

			-- wax flying all over the place
			minetest.add_particle({
				pos = {x = pos.x, y = pos.y, z = pos.z},
				velocity = {
					x = random(-1, 1),
					y = random(4),
					z = random(-1, 1)
				},
				acceleration = {x = 0, y = -6, z = 0},
				expirationtime = 2,
				size = random(1, 3),
				collisiondetection = false,
				texture = "bees_wax_particle.png",
			})

			timer:start(5)
		else
			timer:start(5) -- try again in 5 seconds (was 1)
		end
	end,

	tube = {
		insert_object = function(pos, _, stack)

			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			local timer = minetest.get_node_timer(pos)

			if stack:get_name() == "bees:frame_full" then

				if inv:is_empty("frames_filled") then
					timer:start(5)
				end

				return inv:add_item("frames_filled",stack)

			elseif stack:get_name() == "vessels:glass_bottle" then

				if inv:is_empty("bottles_empty") then
					timer:start(5)
				end

				return inv:add_item("bottles_empty",stack)
			end

			return stack
		end,

		can_insert = function(pos, _, stack)

			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()

			if stack:get_name() == "bees:frame_full" then

				return inv:room_for_item("frames_filled", stack)

			elseif stack:get_name() == "vessels:glass_bottle" then

				return inv:room_for_item("bottles_empty", stack)
			end

			return false
		end,

		input_inventory = {"frames_emptied", "bottles_full", "wax"},

		connect_sides = {left = 1, right = 1, back = 1, front = 1, bottom = 1, top = 1}
	},

	on_metadata_inventory_put = function(pos, listname, _, stack)

		local timer = minetest.get_node_timer(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		-- if inventory empty start timer for honey bottle, empty frame and wax
		if inv:get_stack(listname, 1):get_count() == stack:get_count() then
			timer:start(5)
		end
	end,

	allow_metadata_inventory_put = function(_, listname, _, stack)

		if (listname == "bottles_empty" and stack:get_name() == "vessels:glass_bottle")
		or (listname == "frames_filled" and stack:get_name() == "bees:frame_full") then
			return stack:get_count()
		else
			return 0
		end
	end,

	allow_metadata_inventory_move = function()
		return 0
	end,

	allow_metadata_inventory_take = function(pos, _, _, stack, player)

		if player and minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end

		return stack:get_count()
	end
})


minetest.register_node("bees:bees", {
	description = S("Bees"),
	drawtype = "plantlike",
	paramtype = "light",
	groups = {not_in_creative_inventory = 1},
	tiles = {{
		name = "bees_strip.png",
		animation = {
			type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 2.0
		}
	}},
	damage_per_second = 1,
	walkable = false,
	buildable_to = true,
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.3, -0.4, -0.3, 0.3, 0.4, 0.3}
		}
	},

	on_timer = function(pos)
		minetest.remove_node(pos)
	end,

	on_construct = function(pos)

		local timer = minetest.get_node_timer(pos)

		timer:start(25)

		minetest.sound_play("bees",
				{pos = pos, gain = 1.0, max_hear_distance = 10}, true)
	end,

	on_punch = function(_, _, puncher)
		sting_player(puncher, 2)
	end
})


minetest.register_node("bees:hive_wild", {
	description = S("Wild Bee Hive"),
	tiles = { -- Neuromancer's base texture
		"bees_hive_wild.png", "bees_hive_wild.png", "bees_hive_wild.png",
		"bees_hive_wild.png", "bees_hive_wild_bottom.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "wallmounted",
	drop = {
		max_items = 6,
		items = {
			{items = {"bees:honey_comb"}, rarity = 5}
		}
	},
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 3},
	is_ground_content = false,
	node_box = { -- VanessaE's wild hive nodebox contribution
		type = "fixed",
		fixed = {
			{-0.25,   -0.5,   -0.25,   0.25,   0.375, 0.25},
			{-0.3125, -0.375, -0.3125, 0.3125, 0.25,  0.3125},
			{-0.375,  -0.25,  -0.375,  0.375,  0.125, 0.375},
			{-0.0625, -0.5,   -0.0625, 0.0625, 0.5,   0.0625}
		}
	},

	on_timer = function(pos)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local timer = minetest.get_node_timer(pos)
		local rad = 10
		local flowers = minetest.find_nodes_in_area(
			{x = pos.x - rad, y = pos.y - rad, z = pos.z - rad},
			{x = pos.x + rad, y = pos.y + rad, z = pos.z + rad},
			"group:flower")

		-- Queen dies if no flowers nearby
		if #flowers == 0 then

			inv:set_stack("queen", 1, "")

			meta:set_string("infotext", S("Colony died, not enough flowers in area!"))

			return
		end

		-- Requires 2 or more flowers to make honey
		if #flowers < 3 then return end

		local flower = flowers[random(#flowers)]

		polinate_flower(flower, minetest.get_node(flower).name)

		local stacks = inv:get_list("combs")

		for k, _ in pairs(stacks) do

			if inv:get_stack("combs", k):is_empty() then

				inv:set_stack("combs", k, "bees:honey_comb")

				timer:start(1000 / #flowers)

				return
			end
		end
		-- what to do if all combs are filled
	end,

	on_construct = function(pos)

		minetest.get_node(pos).param2 = 0

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local timer = minetest.get_node_timer(pos)

		meta:set_int("agressive", 1)

		timer:start(100 + random(100))

		inv:set_size("queen", 1)
		inv:set_size("combs", 5)
		inv:set_stack("queen", 1, "bees:queen")

		for i = 1, random(3) do
			inv:set_stack("combs", i, "bees:honey_comb")
		end
	end,

	on_punch = function(pos, _, puncher)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		if inv:contains_item("queen", "bees:queen") then
			sting_player(puncher, 4)
		end

		minetest.sound_play("bees",
				{pos = pos, gain = 1.0, max_hear_distance = 10}, true)
	end,

	on_metadata_inventory_take = function(pos, listname, _, _, taker)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local timer= minetest.get_node_timer(pos)

		if listname == "combs" and inv:contains_item("queen", "bees:queen") then

			timer:start(10)

			sting_player(taker, 2)
		end
	end,

	on_metadata_inventory_put = function(pos)

		local timer = minetest.get_node_timer(pos)

		if not timer:is_started() then
			timer:start(10)
		end
	end,

	allow_metadata_inventory_put = function(_, listname, _, stack)

		-- restart the colony by adding a queen
		if listname == "queen" and stack:get_name() == "bees:queen" then
			return 1
		else
			return 0
		end
	end,

	on_rightclick = function(pos, _, clicker, itemstack)

		if not itemstack then return end

		minetest.show_formspec(clicker:get_player_name(),
			"bees:hive_artificial",
			hive_wild(pos, (itemstack:get_name() == "bees:grafting_tool"))
		)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		if meta:get_int("agressive") == 1
		and inv:contains_item("queen", "bees:queen") then

			minetest.sound_play("bees",
					{pos = pos, gain = 1.0, max_hear_distance = 10}, true)

			sting_player(clicker, 4)
		else
			meta:set_int("agressive", 1)
		end
	end,

	can_dig = function(pos)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		if inv:is_empty("queen") and inv:is_empty("combs") then
			return true
		else
			return false
		end
	end,

	after_dig_node = function(_, _, _, user)

		local wielded
		if user:get_wielded_item() ~= nil then
			wielded = user:get_wielded_item()
		else
			return
		end

		if "bees:grafting_tool" == wielded:get_name() then

			local inv = user:get_inventory()

			if inv then
				inv:add_item("main", ItemStack("bees:queen"))
			end
		end
	end
})


minetest.register_node("bees:hive_artificial", {
	description = S("Artificial Bee Hive"),
	tiles = {
		"default_wood.png", "default_wood.png", "default_wood.png",
		"default_wood.png", "default_wood.png", "bees_hive_artificial.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {
		snappy = 1, choppy = 2, oddly_breakable_by_hand = 2,
		flammable = 3, wood = 1
	},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-4/8, 2/8, -4/8, 4/8, 3/8, 4/8},
			{-3/8, -4/8, -2/8, 3/8, 2/8, 3/8},
			{-3/8, 0/8, -3/8, 3/8, 2/8, -2/8},
			{-3/8, -4/8, -3/8, 3/8, -1/8, -2/8},
			{-3/8, -1/8, -3/8, -1/8, 0/8, -2/8},
			{1/8, -1/8, -3/8, 3/8, 0/8, -2/8},
		}
	},

	on_construct = function(pos)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		meta:set_int("agressive", 1)

		inv:set_size("queen", 1)
		inv:set_size("frames", 8)

		meta:set_string("infotext", S("Requires Queen bee to function"))
	end,

	on_rightclick = function(pos, _, clicker)

		local player_name = clicker:get_player_name()

		if minetest.is_protected(pos, player_name) then
			return
		end

		minetest.show_formspec(player_name,
			"bees:hive_artificial",
			hive_artificial(pos)
		)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		if meta:get_int("agressive") == 1
		and inv:contains_item("queen", "bees:queen") then
			sting_player(clicker, 4)
		else
			meta:set_int("agressive", 1)
		end
	end,

	on_timer = function(pos)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local timer = minetest.get_node_timer(pos)

		if inv:contains_item("queen", "bees:queen") then

			if inv:contains_item("frames", "bees:frame_empty") then

				timer:start(30)

				local rad = 10
				local flowers = minetest.find_nodes_in_area(
					{x = pos.x - rad, y = pos.y - rad, z = pos.z - rad},
					{x = pos.x + rad, y = pos.y + rad, z = pos.z + rad},
					"group:flower")

				local progress = meta:get_int("progress")

				progress = progress + #flowers

				meta:set_int("progress", progress)

				if progress > 1000 then

					local flower = flowers[random(#flowers)]

					polinate_flower(flower, minetest.get_node(flower).name)

					local stacks = inv:get_list("frames")

					for k, _ in pairs(stacks) do

						if inv:get_stack("frames", k):get_name() == "bees:frame_empty" then

							meta:set_int("progress", 0)

							inv:set_stack("frames", k, "bees:frame_full")

							return
						end
					end
				else
					meta:set_string("infotext", S("progress:")
						.. " " .. progress .. " + " .. #flowers .. " / 1000")
				end
			else
				meta:set_string("infotext", S("Does not have empty frame(s)"))

				timer:stop()
			end
		end
	end,

	on_metadata_inventory_take = function(pos, listname)

		if listname == "queen" then

			local timer = minetest.get_node_timer(pos)
			local meta = minetest.get_meta(pos)

			meta:set_string("infotext", S("Requires Queen bee to function"))

			timer:stop()
		end
	end,

	allow_metadata_inventory_move = function(pos, from_list, _, to_list, to_index)

		local inv = minetest.get_meta(pos):get_inventory()

		if from_list == to_list then

			if inv:get_stack(to_list, to_index):is_empty() then
				return 1
			else
				return 0
			end
		else
			return 0
		end
	end,

	on_metadata_inventory_put = function(pos, listname, _, stack)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local timer = minetest.get_node_timer(pos)

		if listname == "queen" or listname == "frames" then

			meta:set_string("queen", stack:get_name())
			meta:set_string("infotext", S("Queen inserted, now for the empty frames"))

			if inv:contains_item("frames", "bees:frame_empty") then

				timer:start(30)

				meta:set_string("infotext", S("Bees are aclimating"))
			end
		end
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack)

		if not minetest.get_meta(pos):get_inventory():get_stack(
				listname, index):is_empty() then return 0 end

		if listname == "queen" then

			if stack:get_name():match("bees:queen*") then
				return 1
			end

		elseif listname == "frames" then

			if stack:get_name() == ("bees:frame_empty") then
				return 1
			end
		end

		return 0
	end,

	can_dig = function(pos)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		if inv:is_empty("queen") and inv:is_empty("frames") then
			return true
		else
			return false
		end
	end
})

-- ABMs

minetest.register_abm({
	label = "spawn bee particles",
	nodenames = {"bees:hive_artificial", "bees:hive_wild", "bees:hive_industrial"},
	interval = 10,
	chance = 4,

	action = function(pos, node)

		-- Bee particle
		minetest.add_particle({
			pos = {x = pos.x, y = pos.y, z = pos.z},
			velocity = {
				x = (random() - 0.5) * 5,
				y = (random() - 0.5) * 5,
				z = (random() - 0.5) * 5
			},
			acceleration = {
				x = random() - 0.5,
				y = random() - 0.5,
				z = random() - 0.5
			},
			expirationtime = random(2, 5),
			size = random(3),
			collisiondetection = true,
			texture = "bees_particle_bee.png",
		})

		minetest.sound_play("bees",
				{pos = pos, gain = 0.6, max_hear_distance = 5}, true)

		-- floating hive check and removal
		if node.name == "bees:hive_wild" then

			local num = #minetest.find_nodes_in_area(
				{x = pos.x - 1, y = pos.y - 1, z = pos.z - 1},
				{x = pos.x + 1, y = pos.y + 1, z = pos.z + 1}, {"air"})

			if num and num > 25 then
				minetest.remove_node(pos)
			end
		end
	end
})

-- Hive spawn ABM. This should be changed to a more realistic type of spawning

minetest.register_abm({
	label = "spawn bee hives",
	nodenames = {"group:leaves"},
	neighbors = {"air"},
	interval = 300,
	chance = 4,

	action = function(pos)

		if floor(pos.x / 20) ~= pos.x / 20
		or floor(pos.z / 20) ~= pos.z / 20
		or floor(pos.y /  3) ~= pos.y / 3 then return end

		local p = {x = pos.x, y = pos.y - 1, z = pos.z}

		-- skip if nearby hive found
		if minetest.find_node_near(p, 25, {"bees:hive_artificial", "bees:hive_wild",
				"bees:hive_industrial"}) then
			return
		end

		local nod = minetest.get_node_or_nil(p)
		local def = nod and minetest.registered_nodes[nod.name]

		if not def or def.walkable then return end

		if minetest.find_node_near(p, 5, "group:flora") then
			minetest.add_node(p, {name = "bees:hive_wild"})
		end
	end
})

-- Spawning bees around bee hive

minetest.register_abm({
	label = "spawn bees around bee hives",
	nodenames = {"bees:hive_wild", "bees:hive_artificial", "bees:hive_industrial"},
	neighbors = {"group:flower", "group:leaves"},
	interval = 30,
	chance = 4,

	action = function(pos)

		local p = {
			x = pos.x + random(-5, 5),
			y = pos.y - random(0, 3),
			z = pos.z + random(-5, 5)
		}

		if minetest.get_node(p).name == "air" then
			minetest.add_node(p, {name="bees:bees"})
		end
	end
})

-- Helper function

local function add_eatable(item, hp)

	local def = minetest.registered_items[item]

	if def then

		local groups = table.copy(def.groups) or {}

		groups.eatable = hp ; groups.flammable = 2

		minetest.override_item(item, {groups = groups})
	end
end

-- Items

minetest.register_craftitem("bees:frame_empty", {
	description = S("Empty Hive Frame"),
	inventory_image = "bees_frame_empty.png",
	stack_max = 24
})

minetest.register_craftitem("bees:frame_full", {
	description = S("Filled Hive Frame"),
	inventory_image = "bees_frame_full.png",
	stack_max = 12
})

minetest.register_craftitem("bees:bottle_honey", {
	description = S("Honey Bottle"),
	inventory_image = "bees_bottle_honey.png",
	stack_max = 12,
	on_use = minetest.item_eat(3, "vessels:glass_bottle"),
	groups = {vessel = 1}
})

add_eatable("bees:bottle_honey", 3)

minetest.register_craftitem("bees:wax", {
	description = S("Bees Wax"),
	inventory_image = "bees_wax.png",
	stack_max = 48
})

minetest.register_craftitem("bees:honey_comb", {
	description = S("Honey Comb"),
	inventory_image = "bees_comb.png",
	on_use = minetest.item_eat(2),
	stack_max = 8
})

add_eatable("bees:honey_comb", 2)

minetest.register_craftitem("bees:queen", {
	description = S("Queen Bee"),
	inventory_image = "bees_particle_bee.png",
	stack_max = 1
})

-- Crafts

minetest.register_craft({
	output = "bees:extractor",
	recipe = {
		{"", "default:steel_ingot", ""},
		{"default:steel_ingot", "default:stick", "default:steel_ingot"},
		{"default:mese_crystal", "default:steel_ingot", "default:mese_crystal"}
	}
})

minetest.register_craft({
	output = "bees:smoker",
	recipe = {
		{"default:steel_ingot", "wool:red", ""},
		{"", "default:torch", ""},
		{"", "default:steel_ingot",""}
	}
})

minetest.register_craft({
	output = "bees:hive_artificial",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"group:wood", "default:stick", "group:wood"},
		{"group:wood", "default:stick", "group:wood"}
	}
})

minetest.register_craft({
	output = "bees:grafting_tool",
	recipe = {
		{"", "", "default:steel_ingot"},
		{"", "default:stick", ""},
		{"", "", ""}
	}
})

minetest.register_craft({
	output = "bees:frame_empty",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"default:stick", "default:stick", "default:stick"},
		{"default:stick", "default:stick", "default:stick"}
	}
})

if minetest.get_modpath("bushes_classic") then

	minetest.register_craft({
		type = "cooking",
		cooktime = 5,
		recipe = "bees:bottle_honey",
		output = "bushes:sugar"
	})
end

-- Tools

minetest.register_tool("bees:smoker", {
	description = S("Smoker"),
	inventory_image = "bees_smoker.png",
	tool_capabilities = {
		full_punch_interval = 3.0,
		max_drop_level = 0,
		damage_groups = {fleshy = 2}
	},

	on_use = function(itemstack, _, pointed_thing)

		if pointed_thing.type ~= "node" then return end

		local pos = pointed_thing.under

		for i = 1, 6 do

			minetest.add_particle({
				pos = {
					x = pos.x + random() - 0.5,
					y = pos.y,
					z = pos.z + random() - 0.5
				},
				velocity = {x = 0, y = 0.5 + random(), z = 0},
				acceleration = {x = 0, y = 0, z = 0},
				expirationtime = 2 + random(2.5),
				size = random(3),
				collisiondetection = false,
				texture = "bees_smoke_particle.png"
			})
		end

		itemstack:add_wear(65535 / 200)

		local nodename = minetest.get_node(pos).name or ""

		if nodename:find("bees:hive_") then

			local meta = minetest.get_meta(pos)

			meta:set_int("agressive", 0)
		end

		return itemstack
	end
})

minetest.register_tool("bees:grafting_tool", {
	description = S("Grafting Tool"),
	inventory_image = "bees_grafting_tool.png",
	tool_capabilities = {
		full_punch_interval = 3.0,
		max_drop_level = 0,
		damage_groups = {fleshy = 2}
	}
})

-- COMPATIBILTY

-- Aliases

minetest.register_alias("bees:honey_extractor", "bees:extractor")
minetest.register_alias("bees:honey_bottle", "bees:bottle_honey")

-- Start hive timers on map load

minetest.register_lbm({
	nodenames = {"bees:hive", "bees:hive_artificial_inhabited", "bees:bees"},
	name = "bees:replace_old_hives",
	label = "Replace old hives",
	run_at_every_load = true,

	action = function(pos, node)

		if node.name == "bees:bees" then

			local timer = minetest.get_node_timer(pos)

			timer:start(20)
		end

		if node.name == "bees:hive" then

			minetest.set_node(pos, {name = "bees:hive_wild"})

			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()

			inv:set_stack("queen", 1, "bees:queen")
		end

		if node.name == "bees:hive_artificial_inhabited" then

			minetest.set_node(pos, {name = "bees:hive_artificial"})

			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()

			inv:set_stack("queen", 1, "bees:queen")

			local timer = minetest.get_node_timer(pos)

			timer:start(60)
		end
	end
})

-- Pipeworks

if minetest.get_modpath("pipeworks") then

	minetest.register_node("bees:hive_industrial", {
		description = S("Industrial Bee Hive"),
		tiles = {"bees_hive_industrial.png"},
		paramtype2 = "facedir",
		groups = {
			snappy = 1, choppy = 2, oddly_breakable_by_hand = 2,
			tubedevice = 1, tubedevice_receiver = 1
		},
		is_ground_content = false,
		sounds = default.node_sound_wood_defaults(),

		tube = {
			insert_object = function(pos, _, stack)

				local meta = minetest.get_meta(pos)
				local inv = meta:get_inventory()

				if stack:get_name() ~= "bees:frame_empty"
				or stack:get_count() > 1 then
					return stack
				end

				for i = 1, 8 do

					if inv:get_stack("frames", i):is_empty() then

						inv:set_stack("frames", i, stack)

						local timer = minetest.get_node_timer(pos)

						timer:start(30)

						meta:set_string("infotext", S("Bees are aclimating"))

						return ItemStack("")
					end
				end

				return stack
			end,

			can_insert = function(pos, _, stack)

				local meta = minetest.get_meta(pos)
				local inv = meta:get_inventory()

				if stack:get_name() ~= "bees:frame_empty"
				or stack:get_count() > 1 then
					return false
				end

				for i = 1, 8 do

					if inv:get_stack("frames", i):is_empty() then
						return true
					end
				end

				return false
			end,

			can_remove = function(_, _, stack)

				if stack:get_name() == "bees:frame_full" then
					return 1
				else
					return 0
				end
			end,

			input_inventory = "frames",

			connect_sides = {left = 1, right = 1, back = 1, front = 1, bottom = 1, top = 1}
		},

		on_construct = function(pos)

			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()

			meta:set_int("agressive", 1)

			inv:set_size("queen", 1)
			inv:set_size("frames", 8)

			meta:set_string("infotext", S("Requires Queen bee to function"))
		end,

		can_dig = function(pos)

			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()

			if inv:is_empty("queen") and inv:is_empty("frames") then
				return true
			else
				return false
			end
		end,

		on_rightclick = function(pos, _, clicker)

			local player_name = clicker:get_player_name()

			if minetest.is_protected(pos, player_name) then
				return
			end

			minetest.show_formspec(player_name,
				"bees:hive_artificial",
				hive_artificial(pos)
			)

			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()

			if meta:get_int("agressive") == 1
			and inv:contains_item("queen", "bees:queen") then
				sting_player(clicker, 4)
			else
				meta:set_int("agressive", 1)
			end
		end,

		on_timer = function(pos)

			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			local timer = minetest.get_node_timer(pos)

			if inv:contains_item("queen", "bees:queen") then

				if inv:contains_item("frames", "bees:frame_empty") then

					timer:start(30)

					local rad = 10
					local minp = {x = pos.x - rad, y = pos.y - rad, z = pos.z - rad}
					local maxp = {x = pos.x + rad, y = pos.y + rad, z = pos.z + rad}
					local flowers = minetest.find_nodes_in_area(minp, maxp, "group:flower")
					local progress = meta:get_int("progress")

					progress = progress + #flowers

					meta:set_int("progress", progress)

					if progress > 1000 then

						local flower = flowers[random(#flowers)]

						polinate_flower(flower, minetest.get_node(flower).name)

						local stacks = inv:get_list("frames")

						for k, _ in pairs(stacks) do

							if inv:get_stack("frames", k):get_name() == "bees:frame_empty" then

								meta:set_int("progress", 0)

								inv:set_stack("frames", k, "bees:frame_full")

								return
							end
						end
					else
						meta:set_string("infotext", S("progress:")
							.. " " .. progress .. " + " .. #flowers .. " / 1000")
					end
				else
					meta:set_string("infotext", S("Does not have empty frame(s)"))

					timer:stop()
				end
			end
		end,

		on_metadata_inventory_take = function(pos, listname)

			if listname == "queen" then

				local timer = minetest.get_node_timer(pos)
				local meta = minetest.get_meta(pos)

				meta:set_string("infotext", S("Requires Queen bee to function"))

				timer:stop()
			end
		end,

		allow_metadata_inventory_move = function(pos, from_list, _, to_list, to_index)

			local inv = minetest.get_meta(pos):get_inventory()

			if from_list == to_list then

				if inv:get_stack(to_list, to_index):is_empty() then
					return 1
				else
					return 0
				end
			else
				return 0
			end
		end,

		on_metadata_inventory_put = function(pos, listname, _, stack)

			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			local timer = minetest.get_node_timer(pos)

			if listname == "queen" or listname == "frames" then

				meta:set_string("queen", stack:get_name())
				meta:set_string("infotext", S("Queen inserted, now for the empty frames"))

				if inv:contains_item("frames", "bees:frame_empty") then

					timer:start(30)

					meta:set_string("infotext", S("Bees are aclimating"))
				end
			end
		end,

		allow_metadata_inventory_put = function(pos, listname, index, stack)

			if not minetest.get_meta(pos):get_inventory():get_stack(listname, index):is_empty() then
				return 0
			end

			if listname == "queen" then

				if stack:get_name():match("bees:queen*") then
					return 1
				end

			elseif listname == "frames" then

				if stack:get_name() == ("bees:frame_empty") then
					return 1
				end
			end

			return 0
		end
	})

	minetest.register_craft({
		output = "bees:hive_industrial",
		recipe = {
			{"default:steel_ingot", "homedecor:plastic_sheeting", "default:steel_ingot"},
			{"pipeworks:tube_1", "bees:hive_artificial", "pipeworks:tube_1"},
			{"default:steel_ingot", "homedecor:plastic_sheeting", "default:steel_ingot"}
		}
	})
end

-- Lucky Blocks

if minetest.get_modpath("lucky_block") then

	local add_bees = function(pos, player)

		local objs = minetest.get_objects_inside_radius(pos, 15)

		minetest.chat_send_player(player:get_player_name(),
				minetest.colorize("violet", S("Bees! Bees for all!")))

		for n = 1, #objs do

			if objs[n]:is_player() then

				local player_pos = objs[n]:get_pos()

				player_pos.y = player_pos.y + 1

				minetest.set_node(player_pos, {name = "bees:bees"})
			end
		end
	end

	lucky_block:add_blocks({
		{"cus", add_bees},
		{"dro", {"bees:grafting_tool"}, 1},
		{"dro", {"bees:frame_empty"}, 2},
		{"dro", {"bees:queen"}, 1},
		{"nod", "bees:extractor"},
		{"dro", {"bees:frame_full"}, 2},
		{"dro", {"bees:bottle_honey"}, 3},
		{"dro", {"bees:smoker"}, 1},
		{"nod", "bees:hive_artificial"}
	})
end


print("[MOD] Bees Loaded")
