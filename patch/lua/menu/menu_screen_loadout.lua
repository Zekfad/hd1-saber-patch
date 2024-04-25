require("lua/settings/loadout_settings")
require("lua/settings/difficulty_settings")

MenuScreenLoadout = class("MenuScreenLoadout", "MenuScreenBase")

local var_0_0 = 60
local var_0_1 = 20
local var_0_2 = 1
local var_0_3 = 2
local var_0_4 = 3
local var_0_5 = 4
local var_0_6 = 1
local var_0_7 = 2

function MenuScreenLoadout.init(arg_1_0, ...)
	MenuScreenBase.init(arg_1_0, ...)

	arg_1_0.name = "menu_screen_loadout"
end

function MenuScreenLoadout.on_enter(arg_1_0, arg_1_1)
	arg_1_0.current_user_pad_number = GameSettings.get_main_pad_number()
	arg_1_0.specified_loadout = arg_1_1 and arg_1_1.specified_loadout
	arg_1_0.specified_description = arg_1_1 and arg_1_1.specified_description
	arg_1_0.mission_seed = arg_1_1 and arg_1_1.mission_seed or arg_1_0.parent:get_mission_seed()
	arg_1_0.shown_random_loadout_hint = false
	arg_1_0.is_proving_ground_trial = false
	arg_1_0.provinggrounds_seed = arg_1_1 and arg_1_1.provinggrounds_seed or arg_1_0.parent.get_provinggrounds_seed and arg_1_0.parent:get_provinggrounds_seed()

	if arg_1_0.provinggrounds_seed then
		arg_1_0.is_proving_ground_trial = true

		local var_1_0 = ProvinggroundsSettings.get_provinggrounds_params_flat(arg_1_0.provinggrounds_seed)

		arg_1_0.proving_grounds_loadout = ProvinggroundsConditions.construct_loadout(table.clone(LoadoutSettings.default_loadout), var_1_0.sub_condition, arg_1_0.provinggrounds_seed, var_1_0)
	end

	arg_1_0.network_session_handler = arg_1_0.parent.network_session_handler
	arg_1_0.perk_icon_size = {
		232,
		60,
	}
	arg_1_0.primary_weapon_icon_size = {
		128,
		56,
	}
	arg_1_0.stratagem_icon_size = {
		50,
		50,
	}
	arg_1_0.upgrade_icon_size = {
		21,
		21,
	}
	arg_1_0.option_menus = {}

	for iter_1_0 = 1, 4 do
		arg_1_0:setup_loadout(iter_1_0)
	end

	local var_1_1 = {
		"listbox_01",
		"selectionbox_01",
		"icon_arrow_02",
		"stratagem_gradient_blue",
		"stratagem_gradient_green",
		"stratagem_gradient_red",
		"stratagem_gradient_yellow",
		"stratagem_frame_level_2",
		"stratagem_frame_level_3",
		"weapon_upgrade_empty_slot",
		"icon_stratagem_upgrade_arrow",
	}

	for iter_1_1, iter_1_2 in ipairs(LoadoutSettings.primary_weapon) do
		var_1_1[#var_1_1 + 1] = iter_1_2.icon

		for iter_1_3, iter_1_4 in ipairs(iter_1_2.upgrades) do
			var_1_1[#var_1_1 + 1] = iter_1_4.upgrade_icon
		end
	end

	for iter_1_5, iter_1_6 in ipairs(LoadoutSettings.stratagems) do
		var_1_1[#var_1_1 + 1] = iter_1_6.icon
	end

	for iter_1_7, iter_1_8 in ipairs(LoadoutSettings.perks) do
		var_1_1[#var_1_1 + 1] = iter_1_8.icon
	end

	local var_1_2 = FontSettings.fonts
	local var_1_3 = {
		FontSettings.fonts.body.material,
		FontSettings.fonts.body_large.material,
		"weapon_stats_bar",
	}
	local var_1_4 = {
		body = FontSettings.fonts.body,
		body_large = FontSettings.fonts.body_large,
	}

	arg_1_0.hd_gui = {}
	arg_1_0.hd_gui_scroll = {}
	arg_1_0.hd_gui_horizontal_scroll = {}

	for iter_1_9 = 1, 4 do
		local var_1_5 = arg_1_0.parent.world_proxy:get_name()

		arg_1_0.hd_gui[iter_1_9] = HdGui(var_1_5, "loadout_ui" .. tostring(iter_1_9), {
			"menu/menu",
			"hud/hud",
			"fonts/fonts",
		})

		arg_1_0.hd_gui[iter_1_9]:add_fonts(var_1_2)
		arg_1_0.hd_gui[iter_1_9]:set_clippable_materials(var_1_1)

		arg_1_0.hd_gui_scroll[iter_1_9] = HdGui(var_1_5, "loadout_ui_scroll" .. tostring(iter_1_9), {
			"menu/menu",
			"hud/hud",
			"fonts/fonts",
		})

		arg_1_0.hd_gui_scroll[iter_1_9]:add_fonts(var_1_4)
		arg_1_0.hd_gui_scroll[iter_1_9]:set_clippable_materials(var_1_3)

		arg_1_0.hd_gui_horizontal_scroll[iter_1_9] = HdGui(var_1_5, "loadout_ui_vertical_scroll" .. tostring(iter_1_9), {
			"menu/menu",
			"hud/hud",
			"fonts/fonts",
		})

		arg_1_0.hd_gui_horizontal_scroll[iter_1_9]:add_fonts(var_1_4)
		arg_1_0.hd_gui_horizontal_scroll[iter_1_9]:set_clippable_materials(var_1_3)
	end

	arg_1_0.prevent_hotjoin = false

	local var_1_6 = arg_1_0.parent.world_proxy:viewport("menu_viewport")

	var_1_6:set_shading_environment_variable("dof_near_setting", "vector2", {
		0,
		1,
	})
	var_1_6:set_shading_environment_variable("dof_far_setting", "vector2", {
		0,
		1,
	})
end

function MenuScreenLoadout.setup_loadout(arg_1_0, arg_1_1)
	local var_1_0
	local var_1_1
	local var_1_2
	local var_1_3
	local var_1_4 = false

	if arg_1_0.parent.players[arg_1_1].player_go:owned() then
		local var_1_5 = arg_1_0.parent.players[arg_1_1].pad_number
		local var_1_6 = UserManager:get_user_id(var_1_5)

		var_1_0 = SaveManager:user_get("item_unlocks", var_1_6) or {}
		var_1_1 = SaveManager:user_get("new_unlocks", var_1_6) or {}
		var_1_3 = SaveManager:user_get("item_upgrades", var_1_6) or {}
		var_1_2 = DlcSettings.get_combined_entitlements(var_1_6)
		var_1_4 = true
	else
		var_1_0 = {}
		var_1_1 = {}
		var_1_2 = {}
		var_1_3 = {}
	end

	local var_1_7

	if arg_1_0.parent.players[arg_1_1].player_go:exists() then
		var_1_7 = arg_1_0.parent.players[arg_1_1].player_go:get("xp")
	else
		var_1_7 = 0
	end

	local var_1_8 = {
		available_items = {
			perks = {
				groups = {},
			},
			primary_weapon = {
				groups = {},
			},
			stratagems = {
				groups = {},
			},
		},
		new_unlocks = var_1_1,
		item_upgrades = var_1_3,
		is_owned = var_1_4,
	}

	var_1_8.loadout_hover_index_cursor = nil
	var_1_8.loadout_hover_index = 1
	var_1_8.last_current_selection_index = 1

	for iter_1_0, iter_1_1 in ipairs(LoadoutSettings.perks) do
		local var_1_9 = false

		if arg_1_0.specified_loadout then
			for iter_1_2, iter_1_3 in ipairs(arg_1_0.specified_loadout.perks) do
				if iter_1_3 == iter_1_1.name then
					var_1_9 = true
				end
			end
		else
			var_1_9 = ProgressionSettings.can_use(iter_1_1.name, "perks", var_1_7) or DlcSettings.can_use(iter_1_1.name, var_1_2)

			if not var_1_9 then
				for iter_1_4, iter_1_5 in ipairs(var_1_0) do
					if iter_1_1.name == iter_1_5 then
						var_1_9 = true

						break
					end
				end
			end
		end

		if var_1_9 then
			local var_1_10 = var_1_8.available_items.perks.groups
			local var_1_11 = iter_1_1.group or iter_1_1.name
			local var_1_12 = false

			for iter_1_6, iter_1_7 in ipairs(var_1_10) do
				if iter_1_7.name == var_1_11 then
					iter_1_7.items[#iter_1_7.items + 1] = iter_1_1
					var_1_12 = true

					break
				end
			end

			if not var_1_12 then
				local var_1_13 = {
					item_index = 1,
					name = var_1_11,
					items = {
						iter_1_1,
					},
				}

				var_1_10[#var_1_10 + 1] = var_1_13
			end
		end
	end

	for iter_1_8, iter_1_9 in ipairs(LoadoutSettings.primary_weapon) do
		if iter_1_9.group ~= "melee" and iter_1_9.group ~= "support" then
			local var_1_14 = var_1_3[iter_1_9.name] or 0
			local var_1_15 = LoadoutSettings.get_upgraded_primary_weapon(iter_1_8, var_1_14)
			local var_1_16 = false

			if arg_1_0.specified_loadout then
				for iter_1_10, iter_1_11 in ipairs(arg_1_0.specified_loadout.primary_weapon) do
					if iter_1_11 == var_1_15.name then
						var_1_16 = true
					end
				end
			else
				var_1_16 = ProgressionSettings.can_use(var_1_15.name, "primary_weapon", var_1_7) or DlcSettings.can_use(var_1_15.name, var_1_2)

				if not var_1_16 then
					for iter_1_12, iter_1_13 in ipairs(var_1_0) do
						if var_1_15.name == iter_1_13 then
							var_1_16 = true

							break
						end
					end
				end
			end

			if var_1_16 then
				local var_1_17 = var_1_8.available_items.primary_weapon.groups
				local var_1_18 = var_1_15.group or var_1_15.name
				local var_1_19 = false

				for iter_1_14, iter_1_15 in ipairs(var_1_17) do
					if iter_1_15.name == var_1_18 then
						iter_1_15.items[#iter_1_15.items + 1] = var_1_15
						var_1_19 = true

						break
					end
				end

				if not var_1_19 then
					local var_1_20 = {
						item_index = 1,
						name = var_1_18,
						items = {
							var_1_15,
						},
					}

					var_1_17[#var_1_17 + 1] = var_1_20
				end
			end
		end
	end

	for iter_1_16, iter_1_17 in ipairs(LoadoutSettings.stratagems) do
		local var_1_21 = var_1_3[iter_1_17.name] or 0
		local var_1_22 = LoadoutSettings.get_upgraded_stratagem(iter_1_16, var_1_21)

		if not array.find(LoadoutSettings.static_stratagems, var_1_22.name) then
			local var_1_23 = false

			if arg_1_0.specified_loadout then
				for iter_1_18, iter_1_19 in ipairs(arg_1_0.specified_loadout.stratagems) do
					if iter_1_19 == var_1_22.name then
						var_1_23 = true
					end
				end
			else
				var_1_23 = ProgressionSettings.can_use(var_1_22.name, "stratagems", var_1_7) or DlcSettings.can_use(var_1_22.name, var_1_2)

				if not var_1_23 then
					for iter_1_20, iter_1_21 in ipairs(var_1_0) do
						if var_1_22.name == iter_1_21 then
							var_1_23 = true

							break
						end
					end
				end
			end

			if var_1_23 then
				local var_1_24 = var_1_8.available_items.stratagems.groups
				local var_1_25 = var_1_22.group or var_1_22.name
				local var_1_26 = false

				for iter_1_22, iter_1_23 in ipairs(var_1_24) do
					if iter_1_23.name == var_1_25 then
						iter_1_23.items[#iter_1_23.items + 1] = var_1_22
						var_1_26 = true

						break
					end
				end

				if not var_1_26 then
					local var_1_27 = {
						item_index = 1,
						name = var_1_25,
						items = {
							var_1_22,
						},
					}

					var_1_24[#var_1_24 + 1] = var_1_27
				end
			end
		end
	end

	local var_1_28
	local var_1_29

	if arg_1_0.parent.players[arg_1_1].player_go:owned() then
		arg_1_0.parent.players[arg_1_1].player_go:set("loadout_done", false)

		local var_1_30 = arg_1_0.parent.players[arg_1_1].pad_number
		local var_1_31 = UserManager:get_user_id(var_1_30)

		if IS_PS4 or var_1_30 == GameSettings.get_main_pad_number() then
			var_1_29 = SaveManager:user_get("loadouts", var_1_31)
			var_1_28 = SaveManager:user_get("loadout", var_1_31)
		else
			var_1_28 = SaveManager:get("loadout_" .. tostring(var_1_30))
			var_1_29 = SaveManager:get("loadouts_" .. tostring(var_1_30))
		end

		if var_1_29 == nil or #var_1_29 == 0 then
			var_1_29 = table.clone(LoadoutSettings.default_loadouts)

			if var_1_28 then
				var_1_29[1] = table.clone(var_1_28)
				var_1_29[2] = table.clone(var_1_28)
				var_1_29[3] = table.clone(var_1_28)
			end
		end

		var_1_28 = table.clone(var_1_29[1])

		for iter_1_24, iter_1_25 in ipairs(var_1_29) do
			iter_1_25 = Boot.ensure_loadout(var_1_31, iter_1_25 or table.clone(LoadoutSettings.default_loadout))
			iter_1_25.sidearm_weapon = LoadoutSettings.default_loadout.sidearm_weapon
		end
	else
		var_1_29 = table.clone(LoadoutSettings.default_loadouts)
		var_1_28 = table.clone(var_1_29[1])
	end

	var_1_8.loadouts = var_1_29
	var_1_8.loadout_index = 1

	if arg_1_0.specified_loadout then
		var_1_28.perk = arg_1_0.specified_loadout.perks[1]
		var_1_28.primary_weapon = arg_1_0.specified_loadout.primary_weapon[1]

		local var_1_32 = 0

		for iter_1_26 = #LoadoutSettings.static_stratagems + 1, LoadoutSettings.nr_of_stratagem_slots do
			local var_1_33 = var_1_32 % #arg_1_0.specified_loadout.stratagems + 1

			var_1_28.stratagems[iter_1_26] = arg_1_0.specified_loadout.stratagems[var_1_33]
			var_1_32 = var_1_32 + 1
		end
	else
		for iter_1_27, iter_1_28 in ipairs(var_1_29) do
			local var_1_34 = false

			for iter_1_29, iter_1_30 in ipairs(var_1_8.available_items.primary_weapon.groups) do
				for iter_1_31, iter_1_32 in ipairs(iter_1_30.items) do
					if iter_1_28.primary_weapon == iter_1_32.name then
						var_1_34 = true

						break
					end
				end

				if var_1_34 then
					break
				end
			end

			local var_1_35 = false

			for iter_1_33, iter_1_34 in ipairs(var_1_8.available_items.perks.groups) do
				for iter_1_35, iter_1_36 in ipairs(iter_1_34.items) do
					if iter_1_28.perk == iter_1_36.name then
						var_1_35 = true

						break
					end
				end

				if var_1_35 then
					break
				end
			end

			local var_1_36 = true

			for iter_1_37, iter_1_38 in ipairs(iter_1_28.stratagems) do
				local var_1_37 = false

				if array.find(LoadoutSettings.static_stratagems, iter_1_38) then
					var_1_37 = true
				else
					for iter_1_39, iter_1_40 in ipairs(var_1_8.available_items.stratagems.groups) do
						for iter_1_41, iter_1_42 in ipairs(iter_1_40.items) do
							if iter_1_38 == iter_1_42.name then
								var_1_37 = true

								break
							end
						end

						if var_1_37 then
							break
						end
					end
				end

				if not var_1_37 then
					var_1_36 = false

					break
				end
			end

			if not var_1_34 or not var_1_35 or not var_1_36 then
				var_1_29[iter_1_27] = table.clone(LoadoutSettings.default_loadout)
			end
		end
	end

	for iter_1_43, iter_1_44 in ipairs(var_1_29) do
		for iter_1_45, iter_1_46 in ipairs(LoadoutSettings.static_stratagems) do
			local var_1_38 = false

			for iter_1_47, iter_1_48 in ipairs(iter_1_44.stratagems) do
				if iter_1_46 == iter_1_48 then
					var_1_38 = true

					break
				end
			end

			if not var_1_38 then
				array.insert_at(iter_1_44.stratagems, #LoadoutSettings.static_stratagems - (iter_1_45 - 1), iter_1_46)

				while #iter_1_44.stratagems > LoadoutSettings.nr_of_stratagem_slots do
					iter_1_44.stratagems[#iter_1_44.stratagems] = nil
				end
			end
		end
	end

	local var_1_39 = table.clone(var_1_29[1])

	if arg_1_0.is_proving_ground_trial then
		var_1_39 = arg_1_0.proving_grounds_loadout
	end

	local var_1_40 = table.clone(LoadoutSettings.get_item("primary_weapon", var_1_39.primary_weapon))

	if var_1_39.primary_weapon and not var_1_40 then
		local var_1_41 = LoadoutSettings.get_item_by_unit_path("primary_weapon", var_1_39.primary_weapon).name

		var_1_40 = table.clone(LoadoutSettings.get_item("primary_weapon", var_1_41))
	end

	var_1_8.loadout_menu = {
		{
			type = "perks",
			item = table.clone(LoadoutSettings.get_item("perks", var_1_39.perk)),
		},
		{
			type = "primary_weapon",
			item = var_1_40,
		},
	}

	for iter_1_49 = #LoadoutSettings.static_stratagems + 1, LoadoutSettings.nr_of_stratagem_slots do
		if var_1_39.stratagems then
			array.insert_end(var_1_8.loadout_menu, {
				type = "stratagems",
				id = iter_1_49,
				item = table.clone(LoadoutSettings.get_item("stratagems", var_1_39.stratagems[iter_1_49])),
				up_index = var_0_7,
				down_index = var_0_7 + 5,
			})
		end
	end

	array.insert_end(var_1_8.loadout_menu, {
		type = "button",
		up_index = var_0_7 + 1,
	})

	var_1_8.enabled = true
	var_1_8.current_selection_index = 1
	var_1_8.selected_loadout_slot = 1
	var_1_8.confirm_loadout_blink = 0
	var_1_8.confirm_selection_blink = 0
	var_1_8.scroll_index_mouse = 1
	var_1_8.random_loadout = false
	var_1_8.cursor_selection_direction = nil

	if arg_1_0.is_proving_ground_trial then
		var_1_8.current_selection_index = #var_1_8.loadout_menu
	end

	arg_1_0.option_menus[arg_1_1] = var_1_8
end

function MenuScreenLoadout.update_selected_option_cursor(arg_1_0)
	for iter_1_0, iter_1_1 in ipairs(arg_1_0.option_menus) do
		if iter_1_1.loadout_hover_index_cursor then
			if iter_1_1.loadout_hover_index ~= iter_1_1.loadout_hover_index_cursor then
				iter_1_1.loadout_hover_index = iter_1_1.loadout_hover_index_cursor

				local var_1_0 = _G.KEYBOARD_MOUSE_PAD_NUMBER

				arg_1_0:play_sound_scroll(nil, var_1_0)
			end

			iter_1_1.loadout_hover_index_cursor = nil
		end

		if iter_1_1.current_selection_index_cursor then
			if iter_1_1.current_selection_index_cursor ~= iter_1_1.current_selection_index and (not iter_1_1.submenu or arg_1_0.cursor_moved) then
				local var_1_1 = _G.KEYBOARD_MOUSE_PAD_NUMBER

				iter_1_1.current_selection_index = iter_1_1.current_selection_index_cursor

				arg_1_0:play_sound_scroll(nil, var_1_1)
			end

			iter_1_1.current_selection_index_cursor = nil
		end
	end
end

function MenuScreenLoadout.update(arg_1_0, arg_1_1, arg_1_2)
	local var_1_0 = false

	for iter_1_0 = 1, 4 do
		arg_1_0.hd_gui[iter_1_0]:update()

		var_1_0 = var_1_0 or arg_1_0.hd_gui[iter_1_0].is_dirty

		arg_1_0.hd_gui_scroll[iter_1_0]:update()

		var_1_0 = var_1_0 or arg_1_0.hd_gui_scroll[iter_1_0].is_dirty

		arg_1_0.hd_gui_horizontal_scroll[iter_1_0]:update()

		var_1_0 = var_1_0 or arg_1_0.hd_gui_horizontal_scroll[iter_1_0].is_dirty
	end

	if var_1_0 then
		for iter_1_1 = 1, 4 do
			arg_1_0.hd_gui[iter_1_1].is_dirty = false
			arg_1_0.hd_gui_scroll[iter_1_1].is_dirty = false
			arg_1_0.hd_gui_horizontal_scroll[iter_1_1].is_dirty = false
		end
	end

	local var_1_1 = arg_1_0.parent.gui_manager

	MenuScreenBase.update(arg_1_0, var_1_1, arg_1_1, arg_1_2)
	arg_1_0:update_selected_option_cursor()
	MenuScreenBase.draw_title(arg_1_0, var_1_1, arg_1_2, arg_1_0.specified_caption or LocalizationManager:string("menu_loadout"))
	MenuScreenBase.draw_special_infobox(arg_1_0, var_1_1, arg_1_2, false)

	local var_1_2 = 470
	local var_1_3 = 248
	local var_1_4 = InputUtility.get_available_inputs(arg_1_0.parent.players)
	local var_1_5 = (1 - var_1_1.ui_scale_user) * 320

	for iter_1_2 = 1, 4 do
		local var_1_6 = Vector3(96 + 280 * (iter_1_2 - 1), 86 + var_1_5, 0)

		arg_1_0.hd_gui[iter_1_2]:move(var_1_6)
		arg_1_0:draw_player_panel(arg_1_0.hd_gui[iter_1_2], var_1_2 + 20, var_1_3, Color(55, 255, 255, 255), arg_1_2)
		arg_1_0.hd_gui[iter_1_2]:move(Vector3.zero())
	end

	local var_1_7

	if IS_PSVITA then
		var_1_7 = {}

		for iter_1_3, iter_1_4 in ipairs(arg_1_0.parent.players) do
			if iter_1_4.player_go:owned() then
				var_1_7[#var_1_7 + 1] = iter_1_3

				break
			end
		end

		for iter_1_5, iter_1_6 in ipairs(arg_1_0.parent.players) do
			if not iter_1_6.player_go:owned() then
				var_1_7[#var_1_7 + 1] = iter_1_5
			end
		end
	else
		var_1_7 = {
			1,
			2,
			3,
			4,
		}
	end

	local var_1_8 = Color(255, 255, 255, 255)

	for iter_1_7, iter_1_8 in ipairs(var_1_7) do
		local var_1_9 = arg_1_0.option_menus[iter_1_8]
		local var_1_10 = arg_1_0.parent.players[iter_1_8].player_go

		if var_1_10:exists() then
			local var_1_11 = Vector3(96 + 280 * (iter_1_7 - 1), 86 + var_1_5, 0)
			local var_1_12 = var_1_10:get("name")
			local var_1_13 = ProgressionSettings.get_rank(var_1_10:get("xp"))
			local var_1_14 = arg_1_0.hd_gui[iter_1_8]

			var_1_14:move(var_1_11)
			var_1_14:set_current_font("body")

			local var_1_15 = arg_1_0.hd_gui_scroll[iter_1_8]

			var_1_15:move(var_1_11)
			var_1_15:set_current_font("body")

			local var_1_16 = arg_1_0.hd_gui_horizontal_scroll[iter_1_8]

			var_1_16:move(var_1_11)
			var_1_16:set_current_font("body")

			local var_1_17 = var_1_3 - 48
			local var_1_18 = FontSettings.fonts.body.font_size

			while var_1_17 < var_1_14:get_text_extents(var_1_12, nil, var_1_18, true) do
				var_1_18 = var_1_18 - 1
			end

			local var_1_19 = {
				Quaternion.to_elements(QuaternionAux.unbox(GameSettings.player_colors[var_1_10:get("index")])),
			}
			local var_1_20 = HudSettings.settings.player_hud.hud_heights.color_bar

			var_1_14:image("hud_icon_color_gradient_01", Vector3(0, var_1_2 + 18 + var_1_20, arg_1_2 + 1), Vector2(var_1_3 - 2, var_1_20), ColorAux.from_table(var_1_19), Vector2(0, 0), Vector2(0.99, 1))

			var_1_19[1] = 200

			arg_1_0:draw_player_panel(var_1_14, var_1_2 + 20, var_1_3, Color(200, 255, 255, 255), arg_1_2)
			var_1_14:text(var_1_12, Vector3(30, var_1_2, arg_1_2 + 10), Color(255, 178, 178, 178), nil, var_1_18)
			var_1_14:image(var_1_13.icon, Vector3(2, var_1_2 - 2, arg_1_2 + 10), Vector2(24, 24))

			if rawget(_G, "Voice") or IS_STEAM then
				local var_1_21 = var_1_10:get("name")
				local var_1_22 = not string.find(var_1_21, "#")
				local var_1_23 = false

				if var_1_22 then
					local var_1_24 = var_1_10:owner()

					if IS_STEAM then
						if not VoiceManager:peer_muted(var_1_24) and VoiceManager:is_peer_active(var_1_24) then
							var_1_23 = true
						end
					elseif not VoiceManager:get_voice_muted() and Voice.is_user_active(var_1_21) and (var_1_10:owned() or not VoiceManager:peer_muted(var_1_24)) then
						var_1_23 = true
					end
				end

				if var_1_23 then
					local var_1_25 = 24
					local var_1_26 = 48
					local var_1_27 = 0.8
					local var_1_28 = 0.2

					var_1_14:image("voice_volume", Vector3(var_1_26 * var_1_27, var_1_2 + var_1_25 + 7, arg_1_2 + 100) - Vector2(var_1_26, var_1_25 / 4) * var_1_27, Vector2(var_1_26, var_1_25) * var_1_27, Color(255, 255, 200, 0), Vector2(var_1_28 * 4, 0), Vector2(var_1_28 * 5, 1))
				end
			end

			arg_1_0:draw_menu(arg_1_1, var_1_14, var_1_15, var_1_16, var_1_3, var_1_2, arg_1_2, var_1_9, var_1_13, var_1_10)

			var_1_9.confirm_loadout_blink = math.max(var_1_9.confirm_loadout_blink - arg_1_1 * 3, 0)
			var_1_9.confirm_selection_blink = math.max(var_1_9.confirm_selection_blink - arg_1_1 * 3, 0)

			if var_1_10:owned() then
				for iter_1_9, iter_1_10 in ipairs(var_1_9.loadout_menu) do
					if iter_1_10.item ~= nil then
						local var_1_29 = LoadoutSettings.get_item_id_by_name(iter_1_10.type, iter_1_10.item.name)

						if iter_1_10.type == "perks" then
							var_1_10:set("perk_index", var_1_29)
						elseif iter_1_10.type == "primary_weapon" then
							var_1_10:set("primary_weapon_index", var_1_29)

							local var_1_30 = var_1_9.item_upgrades[iter_1_10.item.name] or 0

							var_1_10:set("primary_weapon_upgrade", var_1_30)
						elseif iter_1_10.type == "stratagems" then
							var_1_10:set("stratagem" .. tostring(iter_1_10.id) .. "_index", var_1_29)

							local var_1_31 = var_1_9.item_upgrades[iter_1_10.item.name] or 0

							var_1_10:set("stratagem" .. tostring(iter_1_10.id) .. "_upgrade", var_1_31)
						end
					end
				end

				if not var_1_9.submenu then
					var_1_10:set("loadout_selection", var_1_9.current_selection_index)
				else
					var_1_10:set("loadout_selection", var_1_9.selected_loadout_slot)
				end

				var_1_10:set("using_random_loadout", var_1_9.random_loadout)
				var_1_10:set("loadout_done", not var_1_9.enabled)
				var_1_10:set("favorite_loadout_index", var_1_9.loadout_index)
			else
				for iter_1_11, iter_1_12 in ipairs(var_1_9.loadout_menu) do
					if iter_1_12.item ~= nil then
						if iter_1_12.type == "perks" then
							local var_1_32 = var_1_10:get("perk_index")

							if var_1_32 > 0 then
								if iter_1_12.index and iter_1_12.index ~= var_1_32 then
									var_1_9.confirm_selection_blink = 1
								end

								iter_1_12.index = var_1_32
								iter_1_12.item = table.clone(LoadoutSettings.perks[var_1_32])
							end
						elseif iter_1_12.type == "primary_weapon" then
							local var_1_33 = var_1_10:get("primary_weapon_index")
							local var_1_34 = var_1_10:get("primary_weapon_upgrade")

							if var_1_33 > 0 then
								if iter_1_12.index and iter_1_12.index ~= var_1_33 then
									var_1_9.confirm_selection_blink = 1
								end

								iter_1_12.index = var_1_33
								iter_1_12.item = table.clone(LoadoutSettings.primary_weapon[var_1_33])
								iter_1_12.upgrade_value = var_1_34
							end
						elseif iter_1_12.type == "stratagems" then
							local var_1_35 = var_1_10:get("stratagem" .. tostring(iter_1_12.id) .. "_index")
							local var_1_36 = var_1_10:get("stratagem" .. tostring(iter_1_12.id) .. "_upgrade")

							if var_1_35 > 0 then
								if iter_1_12.index and iter_1_12.index ~= var_1_35 then
									var_1_9.confirm_selection_blink = 1
								end

								iter_1_12.index = var_1_35
								iter_1_12.item = table.clone(LoadoutSettings.stratagems[var_1_35])
								iter_1_12.upgrade_value = var_1_36
							end
						end
					end
				end

				local var_1_37 = var_1_10:get("loadout_selection")

				if var_1_37 > 0 then
					if var_1_9.current_selection_index ~= var_1_37 then
						var_1_9.confirm_selection_blink = 0.25
					end

					var_1_9.current_selection_index = var_1_37
				end

				local var_1_38 = var_1_10:get("using_random_loadout")

				if var_1_38 and not var_1_9.random_loadout then
					var_1_9.confirm_loadout_blink = 0.25
				end

				var_1_9.random_loadout = var_1_38

				local var_1_39 = var_1_10:get("favorite_loadout_index")

				if var_1_39 < 1 then
					var_1_39 = 1
				elseif var_1_39 > 4 then
					var_1_39 = 4
				end

				var_1_9.loadout_index = var_1_39

				local var_1_40 = not var_1_10:get("loadout_done")

				if var_1_40 ~= var_1_9.enabled then
					var_1_9.confirm_loadout_blink = 1
				end

				var_1_9.enabled = var_1_40
			end
		elseif #var_1_4 > 0 and not arg_1_0.prevent_hotjoin and HotjoinManager:can_pad_join(iter_1_8) then
			array.remove_at(var_1_4, #var_1_4)

			local var_1_41 = arg_1_0.hd_gui[iter_1_8]

			var_1_41:move(Vector3.zero())
			var_1_41:set_current_font("body_large")

			local var_1_42 = LocalizationManager:string("press_cross_to_join")
			local var_1_43 = var_1_41:get_text_extents(var_1_42, nil, nil, true)

			var_1_41:text_box(var_1_42, Vector3(96 + 280 * (iter_1_8 - 1), 100 + var_1_5, arg_1_2), var_1_3, Color.white(), nil, nil, nil, "center", true)
		end

		var_1_9.y_scroll_input_mouse = nil
	end

	var_1_1:begin_layout(Vector3(arg_1_0.center_layout_offset.x, arg_1_0.button_info_y, 0), nil, "center", "bottom")

	local var_1_44 = "body_large"
	local var_1_45 = FontSettings.fonts[var_1_44].class
	local var_1_46 = FontSettings.fonts[var_1_44].font_size
	local var_1_47 = {
		to_upper_case = false,
		color = Color(255, 255, 255, 255),
		font_name = var_1_45,
		font_size = var_1_46,
		anchor = Vector2(0, 0),
	}

	var_1_1:begin_template(var_1_47)

	local var_1_48 = 0
	local var_1_49
	local var_1_50 = true
	local var_1_51

	if IS_PC then
		var_1_50 = false

		for iter_1_13, iter_1_14 in ipairs(arg_1_0.parent.players) do
			if iter_1_14.player_go:owned() and iter_1_14.pad_number ~= _G.KEYBOARD_MOUSE_PAD_NUMBER then
				var_1_50 = true
				var_1_51 = "pad" .. iter_1_14.pad_number

				break
			end
		end
	end

	local var_1_52 = 0
	local var_1_53 = Vector3(var_1_48, var_1_52, arg_1_2 + 1)

	if arg_1_0.parent.menu_info_go and arg_1_0.parent.menu_info_go:exists() then
		var_1_48 = var_1_48 + MenuScreenBase.check_and_draw_clickable_text_button(arg_1_0, var_1_1, "menu_loadout_back", "back", var_1_53, var_1_46, var_1_47.font_name, arg_1_0.current_user_pad_number)
	end

	if not arg_1_0.is_proving_ground_trial and GameSettings.get_main_pad_number() == _G.KEYBOARD_MOUSE_PAD_NUMBER then
		var_1_48 = 20 + var_1_48 + MenuScreenBase.check_and_draw_clickable_text_button(arg_1_0, var_1_1, "menu_loadout_favorites_browse_pc", "loadout_browse_button", var_1_53 + Vector3(10 + var_1_48, 0, 0), var_1_46, var_1_47.font_name, _G.KEYBOARD_MOUSE_PAD_NUMBER)
	end

	if GameSettings.get_main_pad_number() ~= _G.KEYBOARD_MOUSE_PAD_NUMBER or var_1_50 then
		local var_1_54 = LocalizationManager:string("menu_loadout_select", nil, var_1_51)

		var_1_1:draw_text(var_1_54, Vector3(var_1_48, var_1_52, arg_1_2 + 1))

		local var_1_55 = var_1_48 + var_1_1:get_text_bounds(var_1_54, var_1_46, var_1_47.font_name)
		local var_1_56 = LocalizationManager:string("menu_loadout_scroll", nil, var_1_51)

		var_1_1:draw_text(var_1_56, Vector3(var_1_55, var_1_52, arg_1_2 + 1))

		local var_1_57 = var_1_55 + var_1_1:get_text_bounds(var_1_56, var_1_46, var_1_47.font_name)

		if not arg_1_0.is_proving_ground_trial then
			local var_1_58 = LocalizationManager:string("menu_loadout_favorites_browse_console", nil, var_1_51)

			var_1_1:draw_text(var_1_58, Vector3(var_1_57, var_1_52, arg_1_2 + 1))
		end
	end

	var_1_1:end_template()
	var_1_1:end_layout()
end

function MenuScreenLoadout.draw_menu(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7, arg_1_8, arg_1_9, arg_1_10)
	arg_1_4:set_clip_region({
		10,
		100,
		arg_1_5 - 20,
		2000,
	})
	arg_1_4:set_current_font("body_large")

	local var_1_0 = arg_1_10:get("index")
	local var_1_1 = arg_1_0.parent.players[var_1_0].pad_number
	local var_1_2 = arg_1_4.ui_scale

	if not arg_1_8.submenu then
		local var_1_3 = false
		local var_1_4 = false
		local var_1_5 = false

		for iter_1_0, iter_1_1 in ipairs(arg_1_8.new_unlocks) do
			if string.find(iter_1_1, "perk_") then
				var_1_3 = true
			elseif string.find(iter_1_1, "weapon_") then
				var_1_4 = true
			elseif string.find(iter_1_1, "stratagem_") then
				var_1_5 = true
			end
		end

		local var_1_6 = Vector3(-4, -2, 0)

		arg_1_2:set_clip_region()
		arg_1_2:set_current_font("body_large")
		arg_1_2:set_ignore_size_scale(true)

		local var_1_7, var_1_8, var_1_9 = arg_1_2:get_text_extents(tostring(arg_1_9.level))

		arg_1_2:set_ignore_size_scale(false)
		arg_1_2:text(tostring(arg_1_9.level), Vector3(2, arg_1_6 - var_1_8 - 6, arg_1_7 + 100), Color(255, 240, 175, 80))

		local var_1_10 = LocalizationManager:string(arg_1_9.title)

		arg_1_2:set_ignore_size_scale(true)

		local var_1_11 = arg_1_2:get_text_box_strings(var_1_10, 210)

		arg_1_2:set_ignore_size_scale(false)

		local var_1_12 = 0

		for iter_1_2, iter_1_3 in ipairs(var_1_11) do
			arg_1_2:text(iter_1_3, Vector3(2 + var_1_7, arg_1_6 - var_1_8 - 6 + var_1_12, arg_1_7 + 100))

			var_1_12 = var_1_12 - 16
		end

		local var_1_13 = 215

		arg_1_2:image("loadout_skull_01", Vector3(0, arg_1_6 - 140, arg_1_7 - 1), Vector2(232, 120), nil, Vector2(0, 0), Vector2(-1, 1))

		local var_1_14 = arg_1_8.loadout_menu
		local var_1_15
		local var_1_16
		local var_1_17
		local var_1_18 = Vector2(45, 40)
		local var_1_19 = arg_1_6 - 60
		local var_1_20 = LocalizationManager:string("loadout_favorites_title")

		arg_1_2:set_current_font("body_large")
		arg_1_2:text(var_1_20, Vector3(10, var_1_19, arg_1_7 + 11), Color(255, 178, 178, 178))

		local var_1_21 = var_1_19 - 50
		local var_1_22 = arg_1_5 - 235
		local var_1_23 = 60

		if arg_1_0.is_proving_ground_trial then
			arg_1_2:image("listbox_01", Vector3(5, var_1_21 - 5, arg_1_7 + 15), Vector2(arg_1_5 - 10, 51), Color(160, 255, 255, 255))
		else
			arg_1_2:image("listbox_01", Vector3(5, var_1_21 - 5, arg_1_7), Vector2(arg_1_5 - 10, 51), Color(160, 255, 255, 255))
		end

		local var_1_24 = Vector3(var_1_22, var_1_21, arg_1_7 + 11)

		if arg_1_8.is_owned and arg_1_8.enabled and MenuScreenBase.is_box_selected_by_cursor(arg_1_0, arg_1_2, var_1_24, var_1_18, var_1_1) then
			arg_1_8.loadout_hover_index_cursor = var_0_2
			var_1_16 = var_1_24
		end

		local var_1_25 = "loadout_fav_closed_01"

		if not arg_1_0.is_proving_ground_trial and arg_1_8.loadout_index == var_0_2 then
			var_1_17 = var_1_24
			var_1_25 = "loadout_fav_open_01"
		end

		arg_1_2:image(var_1_25, var_1_24, var_1_18, Color(255, 255, 255, 255))

		local var_1_26 = var_1_22 + var_1_23
		local var_1_27 = Vector3(var_1_26, var_1_21, arg_1_7 + 12)

		if arg_1_8.is_owned and arg_1_8.enabled and MenuScreenBase.is_box_selected_by_cursor(arg_1_0, arg_1_2, var_1_27, var_1_18, var_1_1) then
			arg_1_8.loadout_hover_index_cursor = var_0_3
			var_1_16 = var_1_27
		end

		local var_1_28 = "loadout_fav_closed_02"

		if arg_1_8.loadout_index == var_0_3 then
			var_1_17 = var_1_27
			var_1_28 = "loadout_fav_open_02"
		end

		arg_1_2:image(var_1_28, var_1_27, var_1_18, Color(255, 255, 255, 255))

		local var_1_29 = var_1_26 + var_1_23
		local var_1_30 = Vector3(var_1_29, var_1_21, arg_1_7 + 13)

		if arg_1_8.is_owned and arg_1_8.enabled and MenuScreenBase.is_box_selected_by_cursor(arg_1_0, arg_1_2, var_1_30, var_1_18, var_1_1) then
			arg_1_8.loadout_hover_index_cursor = var_0_4
			var_1_16 = var_1_30
		end

		local var_1_31 = "loadout_fav_closed_03"

		if arg_1_8.loadout_index == var_0_4 then
			var_1_17 = var_1_30
			var_1_31 = "loadout_fav_open_03"
		end

		arg_1_2:image(var_1_31, var_1_30, var_1_18, Color(255, 255, 255, 255))

		local var_1_32 = var_1_29 + var_1_23
		local var_1_33 = Vector3(var_1_32, var_1_21, arg_1_7 + 10)

		if arg_1_8.is_owned and arg_1_8.enabled and MenuScreenBase.is_box_selected_by_cursor(arg_1_0, arg_1_2, var_1_33, var_1_18, var_1_1) then
			arg_1_8.loadout_hover_index_cursor = var_0_5
			var_1_16 = var_1_33
		end

		local var_1_34 = "loadout_random_unselected"

		if arg_1_8.loadout_index == var_0_5 then
			var_1_17 = var_1_33
			var_1_34 = "loadout_random_selected"
		end

		arg_1_2:image(var_1_34, var_1_33, var_1_18, Color(255, 255, 255, 255))

		local var_1_35 = arg_1_8.loadout_menu[var_0_6].item
		local var_1_36 = LocalizationManager:string("loadout_perk_title")
		local var_1_37 = LocalizationManager:string(var_1_35.name)
		local var_1_38 = var_1_35.icon
		local var_1_39 = Vector2(unpack(arg_1_0.perk_icon_size))
		local var_1_40 = var_1_21 - 25

		arg_1_2:set_current_font("body_large")

		local var_1_41 = FontSettings.fonts.body_large.font_size

		arg_1_2:text(var_1_36, Vector3(10, var_1_40, arg_1_7 + 11), Color(255, 178, 178, 178))

		if var_1_3 and not arg_1_0.is_proving_ground_trial then
			arg_1_2:image("icon_new", Vector3(arg_1_5 - 16, var_1_40, arg_1_7 + 11) + var_1_6, Vector2(16, 16), Color(255, 255, 255, 255))
		end

		local var_1_42 = Vector3(5, var_1_40 - 95, arg_1_7)
		local var_1_43 = Vector2(arg_1_5 - 10, 90)

		if arg_1_8.random_loadout then
			arg_1_2:image("listbox_01", Vector3(5, var_1_40 - 95, arg_1_7), Vector2(arg_1_5 - 10, 90), Color(120, 255, 255, 255))
			arg_1_2:image("loadout_random_primary", Vector3(arg_1_5 / 2 - 80, var_1_40 - 85, arg_1_7 + 1), Vector2(160, 56))
			arg_1_0:draw_selection_scroll_hd_gui(arg_1_4, arg_1_7 + 2, Vector3(10, var_1_40 - 25, 0), LocalizationManager:string("random_loadout"), (arg_1_5 - 30) * var_1_2, arg_1_8.current_selection_index == var_0_6, arg_1_1)
		else
			arg_1_2:image(var_1_38, Vector3(arg_1_5 / 2 - 120, var_1_40 - 90, arg_1_7 + 1), var_1_39)
			arg_1_2:image("listbox_01", Vector3(5, var_1_40 - 95, arg_1_7), Vector2(arg_1_5 - 10, 90), Color(120, 255, 255, 255))
			arg_1_0:draw_selection_scroll_hd_gui(arg_1_4, arg_1_7 + 2, Vector3(10, var_1_40 - 25, 0), var_1_37, (arg_1_5 - 30) * var_1_2, arg_1_8.current_selection_index == var_0_6, arg_1_1)
		end

		if arg_1_0.is_proving_ground_trial then
			arg_1_2:image("icon_lock_big", Vector3(var_1_13, var_1_40 - 30, arg_1_7 + 11), Vector2(30, 30), Color(255, 255, 255, 255))
			arg_1_2:image("listbox_01", Vector3(5, var_1_40 - 95, arg_1_7 + 10), Vector2(arg_1_5 - 10, 90), Color(120, 255, 255, 255))
		end

		if arg_1_8.current_selection_index == var_0_6 then
			var_1_15 = var_1_42
		end

		if not arg_1_0.is_proving_ground_trial and arg_1_8.is_owned and arg_1_8.enabled and MenuScreenBase.is_box_selected_by_cursor(arg_1_0, arg_1_2, var_1_42, var_1_43, var_1_1) then
			arg_1_8.current_selection_index_cursor = var_0_6
		end

		local var_1_44 = LocalizationManager:string("loadout_primary_weapon_title")
		local var_1_45 = arg_1_8.loadout_menu[var_0_7].item
		local var_1_46
		local var_1_47
		local var_1_48

		if var_1_45 then
			var_1_46 = arg_1_8.item_upgrades[var_1_45.name] or arg_1_8.loadout_menu[var_0_7].upgrade_value or 0
			var_1_47 = LocalizationManager:string(var_1_45.name)
			var_1_48 = var_1_45.icon
		else
			var_1_46 = 0
			var_1_47 = LocalizationManager:string("no_primary")
		end

		local var_1_49 = Vector2(unpack(arg_1_0.primary_weapon_icon_size))
		local var_1_50 = Vector2(unpack(arg_1_0.upgrade_icon_size))
		local var_1_51 = var_1_40 - 115

		arg_1_2:set_current_font("body_large")
		arg_1_2:text(var_1_44, Vector3(10, var_1_51, arg_1_7 + 11), Color(255, 178, 178, 178))

		if var_1_4 and not arg_1_0.is_proving_ground_trial then
			arg_1_2:image("icon_new", Vector3(arg_1_5 - 16, var_1_51, arg_1_7 + 11) + var_1_6, Vector2(16, 16), Color(255, 255, 255, 255))
		end

		local var_1_52 = Vector3(5, var_1_51 - 95, arg_1_7)
		local var_1_53 = Vector2(arg_1_5 - 10, 90)

		if arg_1_8.random_loadout then
			arg_1_2:image("listbox_01", Vector3(5, var_1_51 - 95, arg_1_7), Vector2(arg_1_5 - 10, 90), Color(120, 255, 255, 255))
			arg_1_2:image("loadout_random_primary", Vector3(arg_1_5 / 2 - 80, var_1_51 - 90, arg_1_7 + 1), Vector2(160, 56))
			arg_1_0:draw_selection_scroll_hd_gui(arg_1_4, arg_1_7 + 2, Vector3(10, var_1_51 - 25, 0), LocalizationManager:string("random_loadout"), (arg_1_5 - 30) * var_1_2, arg_1_8.current_selection_index == var_0_7, arg_1_1)
		else
			arg_1_2:image("listbox_01", var_1_52, var_1_53, Color(120, 255, 255, 255))

			if var_1_48 then
				arg_1_2:image(var_1_48, Vector3(arg_1_5 / 2 - var_1_49.x / 2 - var_1_50.x, var_1_51 - 90, arg_1_7 + 1), var_1_49)
			end

			if var_1_45 and var_1_45.upgrades then
				for iter_1_4, iter_1_5 in ipairs(var_1_45.upgrades) do
					if BitAux.is_bit_set(var_1_46, iter_1_4) then
						arg_1_2:image(iter_1_5.upgrade_icon, Vector3(arg_1_5 - var_1_50.x - 10 - (iter_1_4 - 1) * (var_1_50.x + 2), var_1_51 - 90, arg_1_7 + 1), var_1_50)
					else
						arg_1_2:image("weapon_upgrade_empty_slot", Vector3(arg_1_5 - var_1_50.x - 10 - (iter_1_4 - 1) * (var_1_50.x + 2), var_1_51 - 90, arg_1_7 + 1), var_1_50)
					end
				end
			end

			arg_1_0:draw_selection_scroll_hd_gui(arg_1_4, arg_1_7 + 2, Vector3(10, var_1_51 - 25, 0), var_1_47, (arg_1_5 - 30) * var_1_2, arg_1_8.current_selection_index == var_0_7, arg_1_1)
		end

		if arg_1_0.is_proving_ground_trial then
			arg_1_2:image("icon_lock_big", Vector3(var_1_13, var_1_51 - 30, arg_1_7 + 11), Vector2(30, 30), Color(255, 255, 255, 255))
			arg_1_2:image("listbox_01", Vector3(5, var_1_51 - 95, arg_1_7 + 10), Vector2(arg_1_5 - 10, 90), Color(120, 255, 255, 255))
		end

		if arg_1_8.current_selection_index == var_0_7 then
			var_1_15 = var_1_52
		end

		if not arg_1_0.is_proving_ground_trial and arg_1_8.is_owned and arg_1_8.enabled and MenuScreenBase.is_box_selected_by_cursor(arg_1_0, arg_1_2, var_1_52, var_1_53, var_1_1) then
			arg_1_8.current_selection_index_cursor = var_0_7
		end

		local var_1_54 = LocalizationManager:string("loadout_stratagems_title")
		local var_1_55 = var_1_51 - 115
		local var_1_56 = 10
		local var_1_57 = 10

		arg_1_2:set_current_font("body_large")
		arg_1_2:text(var_1_54, Vector3(10, var_1_55, arg_1_7 + 11), Color(255, 178, 178, 178))

		if var_1_5 and not arg_1_0.is_proving_ground_trial then
			arg_1_2:image("icon_new", Vector3(arg_1_5 - 16, var_1_55, arg_1_7 + 11) + var_1_6, Vector2(16, 16), Color(255, 255, 255, 255))
		end

		for iter_1_6, iter_1_7 in ipairs(var_1_14) do
			if iter_1_7.type == "stratagems" then
				local var_1_58 = iter_1_7.item
				local var_1_59

				if var_1_58 then
					var_1_59 = arg_1_8.item_upgrades[var_1_58.name] or iter_1_7.upgrade_value or 0
				else
					var_1_59 = 0
				end

				local var_1_60 = Vector2(unpack(arg_1_0.stratagem_icon_size))

				if arg_1_8.random_loadout then
					arg_1_2:image("loadout_random", Vector3(var_1_57, var_1_55 - 60, arg_1_7 + 10), var_1_60)
				elseif var_1_58 then
					MenuScreenBase:draw_stratagem_icon(nil, arg_1_2, var_1_58, var_1_59, Vector3(var_1_57, var_1_55 - 60, arg_1_7 + 10), var_1_60)
				end

				if arg_1_0.is_proving_ground_trial then
					arg_1_2:image("listbox_01", Vector3(var_1_57, var_1_55 - 60, arg_1_7 + 11), var_1_60, Color(125, 255, 255, 255))
					arg_1_2:image("icon_lock_small", Vector3(var_1_57 + 31, var_1_55 - 29, arg_1_7 + 12), Vector2(20, 20), Color(255, 255, 255, 255))
				end

				local var_1_61 = Vector3(var_1_57 - 4, var_1_55 - 64, arg_1_7)
				local var_1_62 = Vector2(58, 58)

				if arg_1_8.current_selection_index == iter_1_6 then
					var_1_15 = var_1_61
				end

				if not arg_1_0.is_proving_ground_trial and arg_1_8.is_owned and arg_1_8.enabled and MenuScreenBase.is_box_selected_by_cursor(arg_1_0, arg_1_2, var_1_61, var_1_62, var_1_1) then
					arg_1_8.current_selection_index_cursor = iter_1_6
				end

				var_1_57 = var_1_57 + var_1_60.x + var_1_56
			end
		end

		arg_1_2:image("listbox_01", Vector3(5, var_1_55 - 65, arg_1_7), Vector2(arg_1_5 - 10, 60), Color(120, 255, 255, 255))
		arg_1_2:set_current_font("body_large")

		if arg_1_8.enabled then
			local var_1_63

			if arg_1_10:owned() then
				var_1_63 = LocalizationManager:string("loadout_confirm_loadout")
			else
				var_1_63 = LocalizationManager:string("loadout_client_loadout_in_progress")
			end

			local var_1_64 = arg_1_2:get_text_extents(var_1_63, nil, nil, true)

			arg_1_2:text(var_1_63, Vector3(arg_1_5 / 2 - var_1_64 / 2, var_1_55 - 92, arg_1_7 + 100))
		else
			local var_1_65

			if arg_1_10:owned() then
				var_1_65 = LocalizationManager:string("loadout_change_loadout")
			else
				var_1_65 = LocalizationManager:string("loadout_client_loadout_done")
			end

			local var_1_66 = arg_1_2:get_text_extents(var_1_65, nil, nil, true)

			arg_1_2:text(var_1_65, Vector3(arg_1_5 / 2 - var_1_66 / 2, var_1_55 - 92, arg_1_7 + 100))
			arg_1_2:rect(Vector3(0, 0, arg_1_7 + 100), Vector2(arg_1_5, arg_1_6 + 30), Color(150, 0, 0, 0))
		end

		arg_1_2:image("listbox_01", Vector3(5, var_1_55 - 100, arg_1_7), Vector2(arg_1_5 - 10, 30), Color(120, 255, 255, 255))
		arg_1_2:rect(Vector3(0, 0, arg_1_7 + 91), Vector2(arg_1_5, arg_1_6 + 20), Color(100 * arg_1_8.confirm_loadout_blink, 200, 200, 200))

		local var_1_67 = Vector3(5, var_1_55 - 100, arg_1_7)
		local var_1_68 = Vector2(arg_1_5 - 10, 30)
		local var_1_69 = var_1_67

		if arg_1_8.current_selection_index == #var_1_14 then
			var_1_15 = var_1_67
		end

		if arg_1_8.is_owned and MenuScreenBase.is_box_selected_by_cursor(arg_1_0, arg_1_2, var_1_67, var_1_68, var_1_1) then
			arg_1_8.current_selection_index_cursor = #var_1_14
		end

		local var_1_70 = arg_1_0.parent.selection_blink
		local var_1_71 = arg_1_0.parent.selection_outline_blink
		local var_1_72 = var_1_14[arg_1_8.current_selection_index or 1]

		if var_1_72 == nil then
			return
		end

		local var_1_73
		local var_1_74
		local var_1_75

		if var_1_72.type == "perks" then
			var_1_73 = Vector2(arg_1_5 - 10, 90)
			var_1_74 = "selectionbox_01"
			var_1_75 = Color(200 - 80 * var_1_70, 255, 255, 255)
		elseif var_1_72.type == "primary_weapon" then
			var_1_73 = Vector2(arg_1_5 - 10, 90)
			var_1_74 = "selectionbox_01"
			var_1_75 = Color(200 - 80 * var_1_70, 255, 255, 255)
		elseif var_1_72.type == "stratagems" then
			var_1_73 = Vector2(58, 58)
			var_1_74 = "selectionbox_outline_01"
			var_1_75 = Color(255 - 120 * var_1_71, 255, 255, 255)
		elseif var_1_72.type == "button" then
			var_1_73 = Vector2(arg_1_5 - 10, 30)
			var_1_74 = "selectionbox_01"
			var_1_75 = Color(200 - 80 * var_1_70, 255, 255, 255)
		elseif var_1_72.type == "radio_button" then
			var_1_73 = Vector2(25, 25)
			var_1_74 = "selectionbox_outline_01"
			var_1_75 = Color(255 - 120 * var_1_71, 255, 255, 255)
		end

		if not arg_1_0.is_proving_ground_trial then
			arg_1_2:image(var_1_74, var_1_15, var_1_73, var_1_75)
			arg_1_2:rect(var_1_15 + Vector3(0, 0, 100), var_1_73, Color(200 * arg_1_8.confirm_selection_blink, 200, 200, 200))

			local var_1_76 = var_1_17 - Vector2(6, 4, 2)
			local var_1_77 = var_1_18 + Vector2(11, 9)

			arg_1_2:image("selectionbox_outline_01", var_1_76, var_1_77, Color(255 - 120 * var_1_71, 255, 255, 255))
			arg_1_2:rect(var_1_76 + Vector3(0, 0, 100), var_1_77, Color(50, 200, 200, 200))

			if arg_1_8.loadout_hover_index_cursor and var_1_16 then
				local var_1_78 = var_1_16 + Vector3(0, 0, 100)
				local var_1_79 = var_1_18

				arg_1_2:image("selectionbox_outline_01", var_1_78, var_1_79, Color(255 - 120 * var_1_71, 255, 255, 255))
				arg_1_2:rect(var_1_78, var_1_79, Color(50, 200, 200, 200))
			end
		else
			arg_1_2:image("selectionbox_01", Vector3(5, 5, 999), Vector3(238, 30, 0), Color(200 - 80 * var_1_70, 255, 255, 255))
			arg_1_2:rect(Vector3(5, 5, 1000), Vector3(238, 30, 0), Color(200 * arg_1_8.confirm_selection_blink, 200, 200, 200))
		end
	elseif arg_1_8.submenu == "perks" then
		arg_1_0:draw_perks(arg_1_1, arg_1_2, arg_1_3, arg_1_5, arg_1_6, arg_1_7, arg_1_8, var_1_1)
	elseif arg_1_8.submenu == "primary_weapon" then
		arg_1_0:draw_primary_weapon(arg_1_1, arg_1_2, arg_1_3, arg_1_5, arg_1_6, arg_1_7, arg_1_8, var_1_1)
	elseif arg_1_8.submenu == "stratagems" then
		arg_1_0:draw_stratagems(arg_1_1, arg_1_2, arg_1_3, arg_1_5, arg_1_6, arg_1_7, arg_1_8, var_1_1)
	end

	arg_1_0:validate_scroll()
end

function MenuScreenLoadout.draw_perks(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7, arg_1_8)
	local var_1_0 = false

	for iter_1_0, iter_1_1 in ipairs(arg_1_7.new_unlocks) do
		if string.find(iter_1_1, "perk_") then
			var_1_0 = true
		end
	end

	local var_1_1 = Vector2(0, 200)
	local var_1_2 = Vector2(arg_1_4, 220)

	arg_1_2:set_clip_region({
		var_1_1.x,
		var_1_1.y,
		var_1_2.x,
		var_1_2.y,
	})

	local var_1_3 = LocalizationManager:string("loadout_perk_title")
	local var_1_4 = Vector2(unpack(arg_1_0.perk_icon_size))

	arg_1_2:set_current_font("body_large")
	arg_1_2:text(var_1_3, Vector3(10, arg_1_5 - 34, arg_1_6), Color(255, 200, 200, 200))

	if var_1_0 then
		arg_1_2:image("icon_new", Vector3(arg_1_4 - 16 - 10, arg_1_5 - 36, arg_1_6 + 11), Vector2(16, 16), Color(255, 255, 255, 255))
	end

	arg_1_2:set_current_font("body_large")

	local var_1_5 = var_1_4.y + 10
	local var_1_6 = arg_1_7.current_selection_index - 1

	if arg_1_8 == _G.KEYBOARD_MOUSE_PAD_NUMBER then
		if arg_1_7.y_scroll_input_mouse and (arg_1_0.force_scroll_items or MenuScreenBase.is_box_selected_by_cursor(arg_1_0, arg_1_2, var_1_1, var_1_2, arg_1_8)) then
			arg_1_7.scroll_index_mouse = arg_1_7.scroll_index_mouse + arg_1_7.y_scroll_input_mouse
			arg_1_7.scroll_index_mouse = math.clamp(arg_1_7.scroll_index_mouse, 1, #arg_1_7.available_items.perks.groups - 2)
			arg_1_7.y_scroll_input_mouse = nil
		end

		var_1_6 = arg_1_7.scroll_index_mouse
	end

	local var_1_7 = math.clamp(var_1_6, 1, #arg_1_7.available_items.perks.groups - 2)
	local var_1_8 = arg_1_5 - 160 + math.max(var_1_5 * math.min(var_1_7, #arg_1_7.available_items.perks.groups), var_1_5)
	local var_1_9
	local var_1_10

	for iter_1_2, iter_1_3 in ipairs(arg_1_7.available_items.perks.groups) do
		local var_1_11 = iter_1_3.items[1]

		arg_1_2:image(var_1_11.icon, Vector3(6, var_1_8 - var_1_4.y / 2, arg_1_6), var_1_4)

		if var_1_0 then
			local var_1_12 = FontSettings.fonts.body_large.font_size

			if var_1_8 > 180 and var_1_8 < 360 then
				for iter_1_4, iter_1_5 in ipairs(arg_1_7.new_unlocks) do
					if iter_1_5 == var_1_11.name then
						arg_1_2:image("icon_new", Vector3(arg_1_4 - 16 - 10, var_1_8 + arg_1_0.perk_icon_size[2] / 2 - 16, arg_1_6 + 1), Vector2(16, 16), Color(255, 255, 255, 255))

						break
					end
				end
			end
		end

		local var_1_13 = Vector3(10, var_1_8 - arg_1_0.perk_icon_size[2] / 2, arg_1_6)
		local var_1_14 = Vector2(arg_1_4 - 20, 60)
		local var_1_15 = iter_1_2 == arg_1_7.current_selection_index

		if var_1_15 then
			var_1_9 = iter_1_3

			local var_1_16 = arg_1_0.parent.selection_blink

			arg_1_2:image("selectionbox_01", var_1_13, var_1_14, Color(200 - 80 * var_1_16, 255, 255, 255))
			arg_1_2:rect(var_1_13 + Vector3(0, 0, 100), var_1_14, Color(200 * arg_1_7.confirm_selection_blink, 200, 200, 200))
		end

		if var_1_7 <= iter_1_2 and iter_1_2 <= var_1_7 + 2 and MenuScreenBase.is_box_selected_by_cursor(arg_1_0, arg_1_2, var_1_13, var_1_14, arg_1_8) then
			var_1_10 = iter_1_3

			local var_1_17 = arg_1_0.parent.selection_blink

			arg_1_7.current_selection_index_cursor = iter_1_2

			if not var_1_15 then
				arg_1_2:image("selectionbox_mouseover_01", var_1_13, var_1_14, Color(100 - 40 * var_1_17, 255, 255, 255))
			end
		end

		arg_1_2:image("listbox_01", Vector3(10, var_1_8 - arg_1_0.perk_icon_size[2] / 2, arg_1_6 - 1), Vector2(arg_1_4 - 20, 60), Color(120, 255, 255, 255))

		var_1_8 = var_1_8 - var_1_5
	end

	var_1_9 = var_1_10 or var_1_9

	arg_1_0:draw_description(arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, var_1_9.items[1].name, var_1_9.items[1].description, var_1_9.items[1].attributes, var_1_9.items[1].upgrade_attributes, nil, nil, arg_1_7, nil, arg_1_8)

	local var_1_18 = #arg_1_7.available_items.perks.groups > 3

	arg_1_0:draw_arrows(arg_1_2, arg_1_4, arg_1_5, arg_1_6, var_1_18 and var_1_7 > 1, var_1_18 and var_1_7 < #arg_1_7.available_items.perks.groups - 2, -4, arg_1_8, arg_1_7.current_selection_index_cursor ~= nil)
end

function MenuScreenLoadout.draw_primary_weapon(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7, arg_1_8)
	local var_1_0 = false

	for iter_1_0, iter_1_1 in ipairs(arg_1_7.new_unlocks) do
		if string.find(iter_1_1, "weapon_") then
			var_1_0 = true
		end
	end

	local var_1_1 = Vector2(0, 180)
	local var_1_2 = Vector2(arg_1_4, 230)

	arg_1_2:set_clip_region({
		var_1_1.x,
		var_1_1.y,
		var_1_2.x,
		var_1_2.y,
	})

	local var_1_3 = LocalizationManager:string("loadout_primary_weapon_title")
	local var_1_4 = Vector2(unpack(arg_1_0.primary_weapon_icon_size))
	local var_1_5 = Vector2(unpack(arg_1_0.upgrade_icon_size))

	arg_1_2:set_current_font("body_large")
	arg_1_2:text(var_1_3, Vector3(10, arg_1_5 - 34, arg_1_6), Color(255, 200, 200, 200))

	if var_1_0 then
		arg_1_2:image("icon_new", Vector3(arg_1_4 - 16 - 10, arg_1_5 - 36, arg_1_6 + 11), Vector2(16, 16), Color(255, 255, 255, 255))
	end

	arg_1_2:set_current_font("body_large")

	local var_1_6 = var_1_4.y + 10
	local var_1_7 = arg_1_7.current_selection_index - 1

	if arg_1_8 == _G.KEYBOARD_MOUSE_PAD_NUMBER then
		if arg_1_7.y_scroll_input_mouse and (arg_1_0.force_scroll_items or MenuScreenBase.is_box_selected_by_cursor(arg_1_0, arg_1_2, var_1_1, var_1_2, arg_1_8)) then
			arg_1_7.scroll_index_mouse = arg_1_7.scroll_index_mouse + arg_1_7.y_scroll_input_mouse
			arg_1_7.scroll_index_mouse = math.clamp(arg_1_7.scroll_index_mouse, 1, #arg_1_7.available_items.primary_weapon.groups - 2)
			arg_1_7.y_scroll_input_mouse = nil
		end

		var_1_7 = arg_1_7.scroll_index_mouse
	end

	local var_1_8 = math.clamp(var_1_7, 1, #arg_1_7.available_items.primary_weapon.groups - 2)
	local var_1_9 = arg_1_5 - 160 + math.max(var_1_6 * math.min(var_1_8, #arg_1_7.available_items.primary_weapon.groups), var_1_6)
	local var_1_10
	local var_1_11

	for iter_1_2, iter_1_3 in ipairs(arg_1_7.available_items.primary_weapon.groups) do
		local var_1_12 = iter_1_3.items[iter_1_3.item_index]

		if iter_1_2 == arg_1_7.current_selection_index then
			var_1_10 = var_1_12
		end

		if var_1_8 <= iter_1_2 and iter_1_2 <= var_1_8 + 2 then
			local var_1_13 = arg_1_7.item_upgrades[var_1_12.name] or 0
			local var_1_14 = Vector3(arg_1_4 / 2 - var_1_4.x / 2 - var_1_5.x, var_1_9 - var_1_4.y / 2, arg_1_6)

			arg_1_2:image(var_1_12.icon, var_1_14, var_1_4)

			if var_1_12.upgrades then
				for iter_1_4, iter_1_5 in ipairs(var_1_12.upgrades) do
					if BitAux.is_bit_set(var_1_13, iter_1_4) then
						arg_1_2:image(iter_1_5.upgrade_icon, Vector3(arg_1_4 - var_1_5.x - 14 - (iter_1_4 - 1) * (var_1_5.x + 2), var_1_9 - var_1_4.y / 2 + 4, arg_1_6 + 1), var_1_5)
					else
						arg_1_2:image("weapon_upgrade_empty_slot", Vector3(arg_1_4 - var_1_5.x - 14 - (iter_1_4 - 1) * (var_1_5.x + 2), var_1_9 - var_1_4.y / 2 + 4, arg_1_6 + 1), var_1_5)
					end
				end
			end

			if var_1_0 then
				local var_1_15 = FontSettings.fonts.body_large.font_size

				if var_1_9 > 180 and var_1_9 < 360 then
					for iter_1_6, iter_1_7 in ipairs(arg_1_7.new_unlocks) do
						if iter_1_7 == var_1_12.name then
							arg_1_2:image("icon_new", Vector3(arg_1_4 - 16 - 10, var_1_9 + 32 - 16, arg_1_6 + 1), Vector2(16, 16), Color(255, 255, 255, 255))

							break
						end
					end
				end
			end

			local var_1_16 = Color(100, 128, 128, 128)
			local var_1_17 = Vector3(10, var_1_9 - arg_1_0.primary_weapon_icon_size[2] / 2, arg_1_6)
			local var_1_18 = Vector2(arg_1_4 - 20, 60)
			local var_1_19 = iter_1_2 == arg_1_7.current_selection_index

			if var_1_19 then
				var_1_10 = var_1_12

				local var_1_20 = arg_1_0.parent.selection_blink

				arg_1_2:image("selectionbox_01", var_1_17, var_1_18, Color(200 - 80 * var_1_20, 255, 255, 255))
				arg_1_2:rect(var_1_17 + Vector3(0, 0, 100), var_1_18, Color(200 * arg_1_7.confirm_selection_blink, 200, 200, 200))

				var_1_16 = Color(255, 255, 255, 255)
			end

			local var_1_21 = false

			if MenuScreenBase.is_box_selected_by_cursor(arg_1_0, arg_1_2, var_1_17, var_1_18, arg_1_8) then
				var_1_11 = var_1_12

				local var_1_22 = arg_1_0.parent.selection_blink

				arg_1_7.current_selection_index_cursor = iter_1_2

				if not var_1_19 then
					arg_1_2:image("selectionbox_mouseover_01", var_1_17, var_1_18, Color(100 - 40 * var_1_22, 255, 255, 255))
				end

				local var_1_23 = true
			end

			if var_1_19 and arg_1_8 == _G.KEYBOARD_MOUSE_PAD_NUMBER then
				var_1_16 = Color(127.5, 255, 255, 255)
			end

			if #iter_1_3.items > 1 then
				local var_1_24 = Vector2(32, 32)
				local var_1_25 = Vector3(8, var_1_14.y + 26, arg_1_6 + 2)
				local var_1_26 = Vector3(arg_1_4 - 40, var_1_14.y + 26, arg_1_6 + 2)
				local var_1_27 = var_1_16
				local var_1_28 = var_1_16

				if var_1_19 and MenuScreenBase.is_box_selected_by_cursor(arg_1_0, arg_1_2, var_1_25, var_1_24, arg_1_8) then
					arg_1_7.cursor_selection_direction = -1

					if iter_1_3.item_index > 1 then
						var_1_27 = Color(255, 255, 255, 255)
					end
				end

				if var_1_19 and MenuScreenBase.is_box_selected_by_cursor(arg_1_0, arg_1_2, var_1_26, var_1_24, arg_1_8) then
					arg_1_7.cursor_selection_direction = 1

					if iter_1_3.item_index < #iter_1_3.items then
						var_1_28 = Color(255, 255, 255, 255)
					end
				end

				if iter_1_3.item_index > 1 then
					arg_1_2:rotated_image("icon_arrow_02", var_1_25, var_1_24, math.rad(0), var_1_27)
				end

				if iter_1_3.item_index < #iter_1_3.items then
					arg_1_2:rotated_image("icon_arrow_02", var_1_26, var_1_24, math.rad(180), var_1_28)
				end
			end

			arg_1_2:image("listbox_01", Vector3(10, var_1_9 - arg_1_0.primary_weapon_icon_size[2] / 2, arg_1_6 - 1), Vector2(arg_1_4 - 20, 60), Color(120, 255, 255, 255))
		end

		var_1_9 = var_1_9 - var_1_6
	end

	var_1_10 = var_1_11 or var_1_10

	arg_1_0:draw_description(arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, var_1_10.name, var_1_10.description, var_1_10.attributes, var_1_10.upgrade_attributes, nil, nil, arg_1_7, nil, arg_1_8)

	local var_1_29 = #arg_1_7.available_items.primary_weapon.groups > 3

	arg_1_0:draw_arrows(arg_1_2, arg_1_4, arg_1_5, arg_1_6, var_1_29 and var_1_8 > 1, var_1_29 and var_1_8 < #arg_1_7.available_items.primary_weapon.groups - 2, nil, arg_1_8, arg_1_7.current_selection_index_cursor ~= nil)
end

function MenuScreenLoadout.draw_stratagems(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7, arg_1_8)
	local var_1_0 = Vector3(-4, -2, 0)
	local var_1_1 = false

	for iter_1_0, iter_1_1 in ipairs(arg_1_7.new_unlocks) do
		if string.find(iter_1_1, "stratagem_") then
			var_1_1 = true
		end
	end

	local var_1_2 = Vector2(0, 172)
	local var_1_3 = Vector2(arg_1_4, 250)

	arg_1_2:set_clip_region({
		var_1_2.x,
		var_1_2.y,
		var_1_3.x,
		var_1_3.y,
	})

	local var_1_4 = LocalizationManager:string("loadout_stratagems_title")
	local var_1_5 = Vector2(60, 60)

	arg_1_2:set_current_font("body_large")
	arg_1_2:text(var_1_4, Vector3(10, arg_1_5 - 34, arg_1_6), Color(255, 200, 200, 200))

	if var_1_1 then
		arg_1_2:image("icon_new", Vector3(arg_1_4 - 16 - 10, arg_1_5 - 36, arg_1_6 + 11), Vector2(16, 16), Color(255, 255, 255, 255))
	end

	arg_1_2:set_current_font("body_large")

	local var_1_6 = var_1_5.y + 10
	local var_1_7 = math.ceil(arg_1_7.current_selection_index / 3)
	local var_1_8 = math.ceil(#arg_1_7.available_items.stratagems.groups / 3)
	local var_1_9 = var_1_7 - 1

	if arg_1_8 == _G.KEYBOARD_MOUSE_PAD_NUMBER then
		if arg_1_7.y_scroll_input_mouse and (arg_1_0.force_scroll_items or MenuScreenBase.is_box_selected_by_cursor(arg_1_0, arg_1_2, var_1_2, var_1_3, arg_1_8)) then
			arg_1_7.scroll_index_mouse = arg_1_7.scroll_index_mouse + arg_1_7.y_scroll_input_mouse
			arg_1_7.scroll_index_mouse = math.clamp(arg_1_7.scroll_index_mouse, 1, math.ceil(#arg_1_7.available_items.stratagems.groups / 3) - 2)
			arg_1_7.y_scroll_input_mouse = nil
		end

		var_1_9 = arg_1_7.scroll_index_mouse
	end

	local var_1_10 = math.clamp(var_1_9, 1, var_1_8 - 2)
	local var_1_11 = arg_1_5 - 160 + math.max(var_1_6 * math.min(var_1_10, var_1_8), var_1_6)
	local var_1_12
	local var_1_13

	for iter_1_2, iter_1_3 in ipairs(arg_1_7.available_items.stratagems.groups) do
		local var_1_14 = math.ceil(iter_1_2 / 3)

		if iter_1_2 == arg_1_7.current_selection_index then
			var_1_12 = iter_1_3
		end

		if var_1_10 <= var_1_14 and var_1_14 <= var_1_10 + 2 then
			local var_1_15 = iter_1_3.items[1]
			local var_1_16 = (iter_1_2 - 1) % 3 * 70
			local var_1_17 = Vector3(24 + var_1_16, var_1_11 - var_1_5.y / 2, arg_1_6 + 20)
			local var_1_18 = arg_1_7.item_upgrades[var_1_15.name] or nil

			MenuScreenBase:draw_stratagem_icon(nil, arg_1_2, var_1_15, var_1_18, var_1_17, var_1_5)

			if var_1_1 then
				local var_1_19 = FontSettings.fonts.body_large.font_size

				if var_1_11 > 180 and var_1_11 < 360 then
					for iter_1_4, iter_1_5 in ipairs(arg_1_7.new_unlocks) do
						if iter_1_5 == var_1_15.name then
							arg_1_2:image("icon_new", var_1_17 + Vector3(var_1_5.x - 16, var_1_5.y - 16, 1), Vector2(16, 16), Color(255, 255, 255, 255))

							break
						end
					end
				end
			end

			local var_1_20 = var_1_17 - Vector3(5, 5, 3)
			local var_1_21 = Vector2(70, 70)
			local var_1_22 = iter_1_2 == arg_1_7.current_selection_index

			if var_1_22 then
				local var_1_23 = arg_1_0.parent.selection_outline_blink

				arg_1_2:image("selectionbox_outline_01", var_1_20, var_1_21, Color(255 - 120 * var_1_23, 255, 255, 255))
				arg_1_2:rect(var_1_20 + Vector3(0, 0, 100), var_1_21, Color(200 * arg_1_7.confirm_selection_blink, 200, 200, 200))
			end

			if MenuScreenBase.is_box_selected_by_cursor(arg_1_0, arg_1_2, var_1_20, var_1_21, arg_1_8) then
				var_1_13 = iter_1_3

				local var_1_24 = arg_1_0.parent.selection_blink

				arg_1_7.current_selection_index_cursor = iter_1_2

				if not var_1_22 then
					arg_1_2:image("selectionbox_mouseover_01", var_1_20, var_1_21, Color(200 - 80 * var_1_24, 255, 255, 255))
				end
			end
		end

		if iter_1_2 % 3 == 0 then
			var_1_11 = var_1_11 - var_1_6
		end
	end

	if var_1_13 or var_1_12 then
		var_1_12 = var_1_13 or var_1_12

		local var_1_25 = var_1_12.items[1]
		local var_1_26 = var_1_25.upgrade_name or var_1_25.name
		local var_1_27 = var_1_25.upgrade_description or var_1_25.description

		arg_1_0:draw_description(arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, var_1_26, var_1_27, var_1_25.attributes, var_1_25.upgrade_attributes, var_1_25.cooldown_time, var_1_25.num_uses, arg_1_7, var_1_25.activation_time, arg_1_8)

		local var_1_28 = var_1_8 > 3

		arg_1_0:draw_arrows(arg_1_2, arg_1_4, arg_1_5, arg_1_6 + 30, var_1_28 and var_1_10 > 1, var_1_28 and var_1_10 < var_1_8 - 2, -4, arg_1_8, arg_1_7.current_selection_index_cursor ~= nil)
	end
end

function MenuScreenLoadout.draw_description(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7, arg_1_8, arg_1_9, arg_1_10, arg_1_11, arg_1_12, arg_1_13, arg_1_14, arg_1_15)
	arg_1_7 = LocalizationManager:string(arg_1_7)
	arg_1_8 = LocalizationManager:string(arg_1_8)

	arg_1_3:set_current_font("body_large")

	local var_1_0 = FontSettings.fonts.body_large.font_size
	local var_1_1 = 146
	local var_1_2 = var_1_1
	local var_1_3 = 0
	local var_1_4 = Vector2(0, 10)
	local var_1_5 = Vector2(arg_1_4, var_1_2 + 8)
	local var_1_6 = var_1_2 + arg_1_13.y_scroll_offset

	arg_1_3:set_clip_region({
		var_1_4.x,
		var_1_4.y,
		var_1_5.x,
		var_1_5.y,
	})
	arg_1_3:set_ignore_size_scale(true)

	local var_1_7 = arg_1_3:get_text_box_height(arg_1_7, arg_1_4 - 20)

	arg_1_3:set_ignore_size_scale(false)
	arg_1_3:text_box(arg_1_7, Vector3(10, var_1_6, arg_1_6), arg_1_4 - 20)

	local var_1_8 = var_1_6 - var_1_7 + 2
	local var_1_9 = var_1_3 + var_1_7 - 2

	arg_1_3:set_current_font("body")

	local var_1_10 = FontSettings.fonts.body.font_size
	local var_1_11 = Color(255, 250, 185, 90)

	if arg_1_12 and arg_1_12 == 1 then
		local var_1_12 = LocalizationManager:string("one_use")
		local var_1_13, var_1_14, var_1_15 = arg_1_3:get_text_extents(var_1_12)

		arg_1_3:text(var_1_12, Vector3(10, var_1_8, arg_1_6), var_1_11)

		var_1_8 = var_1_8 - var_1_10
		var_1_9 = var_1_9 + var_1_10
	elseif arg_1_11 then
		local var_1_16

		if arg_1_11 > 0 then
			local var_1_17 = string.format("%s %d %s", LocalizationManager:string("loadout_cooldown"), arg_1_11, LocalizationManager:string("loadout_seconds"))
			local var_1_18, var_1_19, var_1_20 = arg_1_3:get_text_extents(var_1_17)

			arg_1_3:text(var_1_17, Vector3(10, var_1_8, arg_1_6), var_1_11)

			var_1_8 = var_1_8 - var_1_10
			var_1_9 = var_1_9 + var_1_10
		end

		if arg_1_12 then
			local var_1_21 = string.format("%s %d", LocalizationManager:string("num_uses"), arg_1_12)
			local var_1_22, var_1_23, var_1_24 = arg_1_3:get_text_extents(var_1_21)

			arg_1_3:text(var_1_21, Vector3(10, var_1_8, arg_1_6), var_1_11)

			var_1_8 = var_1_8 - var_1_10
			var_1_9 = var_1_9 + var_1_10
		end
	end

	if arg_1_14 then
		local var_1_25 = LocalizationManager:string_format("activation_time", "#TIME", string.format("%.1f", arg_1_14))

		arg_1_3:text(var_1_25, Vector3(10, var_1_8, arg_1_6), var_1_11)

		var_1_8 = var_1_8 - var_1_10
		var_1_9 = var_1_9 + var_1_10
	end

	local var_1_26 = var_1_8 - 4
	local var_1_27 = var_1_9 + 4

	if arg_1_9 then
		local var_1_28 = IS_PSVITA and 1 or 0.75
		local var_1_29 = "weapon_stats_bar"
		local var_1_30 = Vector2(102 * var_1_28, 13)

		for iter_1_0, iter_1_1 in ipairs(LoadoutSettings.ATTRIBUTE_SORT_ORDER) do
			local var_1_31 = arg_1_9[iter_1_1]

			if var_1_31 then
				local var_1_32 = type(var_1_31) == "boolean" and var_1_11 or Color(255, 255, 255, 255)
				local var_1_33 = LocalizationManager:string(iter_1_1)

				arg_1_3:text(var_1_33, Vector3(10, var_1_26, arg_1_6), var_1_32)

				local var_1_34 = type(var_1_31)

				if var_1_34 == "string" then
					local var_1_35 = LocalizationManager:string(var_1_31)
					local var_1_36, var_1_37, var_1_38 = arg_1_3:get_text_extents(var_1_35)
					local var_1_39 = arg_1_4 - 10 - var_1_38.x

					if IS_PSVITA then
						var_1_39 = 10
						var_1_26 = var_1_26 - var_1_10
						var_1_27 = var_1_27 + var_1_10
					end

					arg_1_3:text(var_1_35, Vector3(var_1_39, var_1_26, arg_1_6))
				elseif var_1_34 == "number" then
					local var_1_40 = arg_1_4 - 10 - var_1_30.x

					if IS_PSVITA then
						var_1_40 = 10
						var_1_26 = var_1_26 - var_1_10
						var_1_27 = var_1_27 + var_1_10
					end

					arg_1_3:image(var_1_29, Vector3(var_1_40, var_1_26, arg_1_6), var_1_30, nil, Vector2(0, 0), Vector2(1, 0.3333333333333333))

					local var_1_41 = var_1_31 / LoadoutSettings.WEAPON_ATTRIBUTES_VISUALIZATION_STEPS

					arg_1_3:image(var_1_29, Vector3(var_1_40, var_1_26, arg_1_6), Vector2(var_1_30.x * var_1_41, var_1_30.y), nil, Vector2(0, 0.3333333333333333), Vector2(var_1_41, 0.6666666666666666))

					if arg_1_10 and arg_1_10[iter_1_1] then
						local var_1_42 = (arg_1_10[iter_1_1] - var_1_31) / LoadoutSettings.WEAPON_ATTRIBUTES_VISUALIZATION_STEPS

						arg_1_3:image(var_1_29, Vector3(var_1_40 + var_1_30.x * var_1_41, var_1_26, arg_1_6), Vector2(var_1_30.x * var_1_42, var_1_30.y), nil, Vector2(var_1_41, 0.6666666666666666), Vector2(var_1_41 + var_1_42, 1))
					end
				elseif var_1_34 == "boolean" then
					-- block empty
				end

				var_1_26 = var_1_26 - var_1_10
				var_1_27 = var_1_27 + var_1_10
			end
		end

		var_1_26 = var_1_26 - 4
		var_1_27 = var_1_27 + 4
	end

	arg_1_3:set_current_font("body")
	arg_1_3:set_ignore_size_scale(true)

	local var_1_43 = arg_1_3:get_text_box_height(arg_1_8, arg_1_4 - 40)

	arg_1_3:set_ignore_size_scale(false)
	arg_1_3:text_box(arg_1_8, Vector3(10, var_1_26, arg_1_6), arg_1_4 - 40, Color(255, 178, 178, 178))

	local var_1_44 = var_1_27 + var_1_43

	if var_1_1 < var_1_44 then
		if arg_1_15 == _G.KEYBOARD_MOUSE_PAD_NUMBER then
			if arg_1_13.y_scroll_input_mouse and (arg_1_0.force_scroll_description or MenuScreenBase.is_box_selected_by_cursor(arg_1_0, arg_1_3, var_1_4, var_1_5, arg_1_15)) then
				arg_1_13.y_scroll_offset = arg_1_13.y_scroll_offset + arg_1_13.y_scroll_input_mouse * var_0_1
				arg_1_13.y_scroll_input_mouse = nil
			end
		else
			arg_1_13.y_scroll_offset = arg_1_13.y_scroll_offset - arg_1_13.y_scroll_input * REAL_TIME_DT * var_0_0
		end

		arg_1_13.y_scroll_offset = math.clamp(arg_1_13.y_scroll_offset, 0, var_1_44 - var_1_1)

		local var_1_45 = arg_1_4 - 20 - 12
		local var_1_46 = Vector2(32, 32)
		local var_1_47 = Color(255 - 100 * arg_1_0.arrow_blink, 255, 255, 255)

		if arg_1_13.y_scroll_offset > 0 then
			local var_1_48 = Vector3(var_1_45, var_1_1 - 10, arg_1_6 + 1)

			MenuScreenBase.check_and_draw_scroll_button(arg_1_0, arg_1_2, "scroll_up_description", var_1_48, var_1_46, math.rad(90), var_1_47, arg_1_15)
		end

		if arg_1_13.y_scroll_offset < var_1_44 - var_1_1 then
			local var_1_49 = Vector3(var_1_45 + 1, 1, arg_1_6 + 1)

			MenuScreenBase.check_and_draw_scroll_button(arg_1_0, arg_1_2, "scroll_down_description", var_1_49, var_1_46, math.rad(-90), var_1_47, arg_1_15)
		end
	end
end

function MenuScreenLoadout.draw_arrows(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7, arg_1_8, arg_1_9)
	arg_1_7 = arg_1_7 or 0

	local var_1_0 = Vector2(32, 32)
	local var_1_1 = Color(255 - 100 * arg_1_0.arrow_blink, 255, 255, 255)

	if arg_1_5 then
		local var_1_2 = Vector3(arg_1_2 / 2 - 16, arg_1_3 - 68, arg_1_4)

		MenuScreenBase.check_and_draw_scroll_button(arg_1_0, arg_1_1, "scroll_up_items", var_1_2, var_1_0, math.rad(90), var_1_1, arg_1_8, arg_1_9)
	end

	if arg_1_6 then
		local var_1_3 = Vector3(arg_1_2 / 2 - 16, 160 + arg_1_7, arg_1_4)

		MenuScreenBase.check_and_draw_scroll_button(arg_1_0, arg_1_1, "scroll_down_items", var_1_3, var_1_0, math.rad(-90), var_1_1, arg_1_8, arg_1_9)
	end
end

function MenuScreenLoadout.on_exit(arg_1_0)
	for iter_1_0, iter_1_1 in ipairs(arg_1_0.hd_gui) do
		iter_1_1:destroy()
	end

	SaveManager:set("use_proving_grounds_loadout", arg_1_0.is_proving_ground_trial)

	if arg_1_0.is_proving_ground_trial then
		SaveManager:set("proving_grounds_loadout", arg_1_0.proving_grounds_loadout)
	end

	for iter_1_2, iter_1_3 in ipairs(arg_1_0.option_menus) do
		if arg_1_0.parent.players[iter_1_2].player_go:owned() then
			local var_1_0 = arg_1_0.parent.players[iter_1_2].pad_number
			local var_1_1 = table.clone(LoadoutSettings.default_loadout)
			local var_1_2 = table.clone(LoadoutSettings.default_loadout)
			local var_1_3 = table.clone(LoadoutSettings.default_loadouts)
			local var_1_4 = iter_1_3.loadouts
			local var_1_5 = var_1_4[iter_1_3.loadout_index]

			if not arg_1_0.is_proving_ground_trial then
				for iter_1_4, iter_1_5 in ipairs(iter_1_3.loadout_menu) do
					if iter_1_5.item ~= nil then
						if arg_1_0.parent.menu_state == arg_1_0.parent.MENU_STATE_START_MISSION then
							local var_1_6 = array.find(iter_1_3.new_unlocks, iter_1_5.item.name)

							if var_1_6 then
								array.remove_at(iter_1_3.new_unlocks, var_1_6)
							end
						end

						if iter_1_3.loadout_index ~= var_0_5 then
							if iter_1_5.type == "stratagems" then
								var_1_4[iter_1_3.loadout_index].stratagems[iter_1_5.id] = iter_1_5.item.name
							elseif iter_1_5.type == "perks" then
								var_1_4[iter_1_3.loadout_index].perk = iter_1_5.item.name
							elseif iter_1_5.type == "primary_weapon" then
								var_1_4[iter_1_3.loadout_index].primary_weapon = iter_1_5.item.name
							else
								assert(false, "Invalid option type")
							end
						end
					end
				end
			end

			local var_1_7 = arg_1_0.parent.players[iter_1_2].player_go:get("using_random_loadout")

			if var_1_7 then
				local var_1_8 = iter_1_3.available_items.perks.groups[math.random(#iter_1_3.available_items.perks.groups)]

				var_1_2.perk = var_1_8.items[math.random(#var_1_8.items)].name

				local var_1_9 = iter_1_3.available_items.primary_weapon.groups[math.random(#iter_1_3.available_items.primary_weapon.groups)]

				var_1_2.primary_weapon = var_1_9.items[math.random(#var_1_9.items)].name

				local var_1_10 = {}

				for iter_1_6, iter_1_7 in ipairs(iter_1_3.available_items.stratagems.groups) do
					for iter_1_8, iter_1_9 in ipairs(iter_1_7.items) do
						array.insert_at(var_1_10, iter_1_8, iter_1_9.name)
					end
				end

				for iter_1_10 = 5, 8 do
					local var_1_11 = math.random(#var_1_10)
					local var_1_12 = var_1_10[var_1_11]

					var_1_2.stratagems[iter_1_10] = var_1_12

					array.remove_at(var_1_10, var_1_11)
				end
			end

			if IS_PS4 or var_1_0 == GameSettings.get_main_pad_number() then
				local var_1_13 = UserManager:get_user_id(var_1_0)

				SaveManager:user_set("loadout", var_1_5, var_1_13)
				SaveManager:user_set("loadouts", var_1_4, var_1_13)
				SaveManager:user_set("new_unlocks", iter_1_3.new_unlocks, var_1_13)
				SaveManager:user_set("use_random_loadout", var_1_7, var_1_13)
				SaveManager:user_set("random_loadout", var_1_2, var_1_13)
			else
				SaveManager:set("loadout_" .. tostring(var_1_0), var_1_5)
				SaveManager:set("new_unlocks_" .. tostring(var_1_0), iter_1_3.new_unlocks)
				SaveManager:set("loadouts_" .. tostring(var_1_0), var_1_4)
				SaveManager:set("use_random_loadout_" .. tostring(var_1_0), var_1_7)
				SaveManager:set("random_loadout_" .. tostring(var_1_0), var_1_2)
			end
		end
	end

	local var_1_14 = arg_1_0.parent.world_proxy:viewport("menu_viewport")

	var_1_14:remove_shading_environment_variable("dof_near_setting")
	var_1_14:remove_shading_environment_variable("dof_far_setting")
end

function MenuScreenLoadout.was_option_selected(arg_1_0, arg_1_1, arg_1_2)
	if arg_1_1.select then
		return true
	elseif arg_1_1.select_mouse then
		if arg_1_2.submenu then
			if arg_1_2.current_selection_index == arg_1_2.current_selection_index_cursor then
				return true
			end
		elseif arg_1_2.current_selection_index == arg_1_2.current_selection_index_cursor or arg_1_2.loadout_hover_index == arg_1_2.loadout_hover_index_cursor then
			return true
		end
	end

	return false
end

function MenuScreenLoadout.reset_mouse_scroll(arg_1_0, arg_1_1)
	if not arg_1_1.submenu then
		return
	end

	local var_1_0 = #arg_1_1.available_items[arg_1_1.submenu].groups
	local var_1_1 = arg_1_1.current_selection_index

	if arg_1_1.submenu == "stratagems" then
		var_1_0 = math.ceil(var_1_0 / 3)
		var_1_1 = math.ceil(var_1_1 / 3)
	end

	arg_1_1.scroll_index_mouse = math.clamp(var_1_1 - 1, 1, var_1_0 - 2)
end

function MenuScreenLoadout.handle_input(arg_1_0, arg_1_1)
	local var_1_0 = false

	if arg_1_0.parent.is_server then
		local var_1_1 = GameSettings.get_main_pad_number()

		if not InputUtility.has_player_with_pad_number(var_1_1, arg_1_0.parent.players) then
			var_1_1 = InputUtility.get_lowest_pad_number(arg_1_0.parent.players)
		end

		arg_1_0.current_user_pad_number = var_1_1

		if var_1_1 then
			local var_1_2 = MenuScreenBase.get_user_inputs(arg_1_0, arg_1_1, var_1_1)

			if var_1_2.back or MenuScreenBase.was_text_button_clicked(arg_1_0, var_1_2, "back") then
				for iter_1_0, iter_1_1 in ipairs(arg_1_0.parent.players) do
					if iter_1_1.player_go:owned() and iter_1_1.pad_number == var_1_1 then
						local var_1_3 = arg_1_0.option_menus[iter_1_0]

						if var_1_3.enabled and not var_1_3.submenu and arg_1_0.parent.menu_info_go then
							if arg_1_0.parent.menu_info_go:exists() then
								arg_1_0.parent.menu_state = arg_1_0.parent.MENU_STATE_BRIEFING

								return
							else
								local var_1_4 = {
									mission_seed = arg_1_0.mission_seed,
									specified_loadout = arg_1_0.specified_loadout,
									specified_description = arg_1_0.specified_description,
								}

								arg_1_0.parent:show_menu("mission_briefing", var_1_4)

								return
							end
						end
					end
				end
			elseif MenuScreenBase.was_text_button_clicked(arg_1_0, var_1_2, "loadout_browse_button") then
				var_1_0 = true
			end
		end
	end

	if IS_PC and arg_1_0.parent.menu_info_go and arg_1_0.parent.menu_info_go:exists() then
		for iter_1_2, iter_1_3 in ipairs(arg_1_0.option_menus) do
			if not iter_1_3.submenu and arg_1_0.parent.players[iter_1_2].player_go and arg_1_0.parent.players[iter_1_2].player_go:owned() then
				local var_1_5 = arg_1_0.parent.players[iter_1_2].pad_number

				if var_1_5 == _G.KEYBOARD_MOUSE_PAD_NUMBER and (not arg_1_0.parent.is_server or var_1_5 ~= GameSettings.get_main_pad_number()) and MenuScreenBase.get_user_inputs(arg_1_0, arg_1_1, var_1_5).menu then
					arg_1_0.parent:show_menu("main", {
						user_pad_number = var_1_5,
					})

					return
				end
			end
		end
	end

	for iter_1_4, iter_1_5 in ipairs(arg_1_0.option_menus) do
		repeat
			if arg_1_0.parent.players[iter_1_4].player_go and arg_1_0.parent.players[iter_1_4].player_go:owned() then
				local var_1_6 = arg_1_0.parent.players[iter_1_4].pad_number
				local var_1_7 = MenuScreenBase.get_user_inputs(arg_1_0, arg_1_1, var_1_6)

				if not var_1_7.is_active then
					break
				end

				if not arg_1_0.is_proving_ground_trial and (var_1_7.loadout_favorites_right_pressed or var_1_7.right_shoulder) or var_1_0 then
					local var_1_8 = (iter_1_5.loadout_index + 1) % 5

					if var_1_8 == 0 then
						var_1_8 = 1
					end

					arg_1_0:update_loadout_view(iter_1_5, var_1_8)

					var_1_0 = false
				elseif not arg_1_0.is_proving_ground_trial and var_1_7.left_shoulder then
					local var_1_9 = (iter_1_5.loadout_index - 1) % 5

					if var_1_9 == 0 then
						var_1_9 = 4
					end

					arg_1_0:update_loadout_view(iter_1_5, var_1_9)
				end

				local var_1_10 = iter_1_5.submenu ~= nil

				MenuScreenBase.handle_input_cursor(arg_1_0, var_1_7, var_1_10)

				local var_1_11 = iter_1_5.loadout_menu

				iter_1_5.y_scroll_input = 0

				local var_1_12

				if var_1_6 == _G.KEYBOARD_MOUSE_PAD_NUMBER then
					var_1_12 = MenuScreenBase.get_clicked_scroll_button(arg_1_0, var_1_7)
					arg_1_0.force_scroll_items = nil
					arg_1_0.force_scroll_description = nil
				end

				if var_1_7.back or var_1_6 == _G.KEYBOARD_MOUSE_PAD_NUMBER and MenuScreenBase.was_text_button_clicked(arg_1_0, var_1_7, "back") then
					if iter_1_5.submenu then
						arg_1_0:play_sound_back(nil, var_1_6)

						iter_1_5.current_selection_index = iter_1_5.selected_loadout_slot
						iter_1_5.submenu = nil
					elseif not iter_1_5.enabled then
						arg_1_0:play_sound_accept(nil, var_1_6)

						iter_1_5.enabled = true

						if iter_1_5.random_loadout then
							iter_1_5.current_selection_index = #iter_1_5.loadout_menu
						else
							iter_1_5.current_selection_index = 1
						end

						if arg_1_0.is_proving_ground_trial then
							iter_1_5.current_selection_index = #iter_1_5.loadout_menu
						end
					end

					iter_1_5.current_selection_index_cursor = nil
				elseif arg_1_0:was_option_selected(var_1_7, iter_1_5) then
					if var_1_7.select_mouse and iter_1_5.cursor_selection_direction then
						local var_1_13 = TempTableFactory:get()

						if iter_1_5.cursor_selection_direction == -1 then
							var_1_13.left = true
						elseif iter_1_5.cursor_selection_direction == 1 then
							var_1_13.right = true
						end

						arg_1_0:play_sound_scroll(nil, var_1_6)
						arg_1_0:update_selection(var_1_13, iter_1_5)

						iter_1_5.confirm_selection_blink = 0.25
					else
						local var_1_14 = false

						if var_1_6 == 0 and var_1_7.select == false and iter_1_5.loadout_hover_index_cursor then
							var_1_14 = true
						end

						arg_1_0:play_sound_accept(nil, var_1_6)
						arg_1_0:reset_description_scroll(iter_1_5)

						if iter_1_5.submenu then
							local var_1_15 = iter_1_5.available_items[iter_1_5.submenu].groups[iter_1_5.current_selection_index]
							local var_1_16 = var_1_15.items[var_1_15.item_index]

							iter_1_5.loadout_menu[iter_1_5.selected_loadout_slot].item = var_1_16

							if var_1_6 == _G.KEYBOARD_MOUSE_PAD_NUMBER then
								iter_1_5.current_selection_index = iter_1_5.selected_loadout_slot
								iter_1_5.current_selection_index_cursor = nil
							else
								iter_1_5.current_selection_index = math.min(iter_1_5.selected_loadout_slot + 1, #iter_1_5.loadout_menu)
							end

							iter_1_5.confirm_selection_blink = 1
							iter_1_5.submenu = nil
						elseif iter_1_5.enabled then
							if not arg_1_0.is_proving_ground_trial and var_1_14 then
								if iter_1_5.loadout_hover_index then
									arg_1_0:update_loadout_view(iter_1_5, iter_1_5.loadout_hover_index, true)
								end
							else
								local var_1_17 = iter_1_5.loadout_menu[iter_1_5.current_selection_index]

								if var_1_17.type == "button" then
									iter_1_5.enabled = false
									iter_1_5.confirm_loadout_blink = 1
								elseif not arg_1_0.is_proving_ground_trial and not iter_1_5.random_loadout then
									iter_1_5.selected_loadout_slot = iter_1_5.current_selection_index
									iter_1_5.submenu = var_1_17.type

									local var_1_18 = iter_1_5.available_items[iter_1_5.submenu].groups

									for iter_1_6, iter_1_7 in ipairs(var_1_18) do
										for iter_1_8, iter_1_9 in ipairs(iter_1_7.items) do
											if iter_1_9.name == var_1_17.item.name then
												iter_1_5.current_selection_index = iter_1_6
												iter_1_7.item_index = iter_1_8

												break
											end
										end
									end

									arg_1_0:reset_mouse_scroll(iter_1_5)
								end
							end
						else
							iter_1_5.enabled = true

							if iter_1_5.current_selection_index_cursor ~= nil and arg_1_0.is_proving_ground_trial == false then
								iter_1_5.current_selection_index = 1
							end
						end
					end
				elseif not arg_1_0.is_proving_ground_trial and iter_1_5.enabled and (var_1_7.up or var_1_7.down or var_1_7.left or var_1_7.right) then
					arg_1_0:play_sound_scroll(nil, var_1_6)
					arg_1_0:update_selection(var_1_7, iter_1_5)

					iter_1_5.confirm_selection_blink = 0.25

					arg_1_0:reset_mouse_scroll(iter_1_5)
				elseif iter_1_5.enabled and var_1_7.look and Vector3.length(var_1_7.look) > 0.1 then
					iter_1_5.y_scroll_input = var_1_7.look.y
				elseif var_1_7.scroll_up == 1 or var_1_7.scroll_down == 1 or var_1_12 then
					if var_1_7.scroll_up == 1 or var_1_12 == "scroll_up_items" or var_1_12 == "scroll_up_description" then
						iter_1_5.y_scroll_input_mouse = -1
					elseif var_1_7.scroll_down or var_1_12 == "scroll_down_items" or var_1_12 == "scroll_down_description" then
						iter_1_5.y_scroll_input_mouse = 1
					end

					if var_1_12 then
						if var_1_12 == "scroll_up_items" or var_1_12 == "scroll_down_items" then
							arg_1_0.force_scroll_items = true
						elseif var_1_12 == "scroll_up_description" or var_1_12 == "scroll_down_description" then
							arg_1_0.force_scroll_description = true
						end
					end
				end
			end

			iter_1_5.cursor_selection_direction = nil
		until true
	end

	MenuScreenBase.reset_clickable_buttons(arg_1_0)
end

function MenuScreenLoadout.update_loadout_view(arg_1_0, arg_1_1, arg_1_2, arg_1_3)
	if arg_1_2 == arg_1_1.loadout_index or arg_1_1.enabled == false or arg_1_1.submenu then
		return
	end

	if arg_1_1.loadout_index ~= var_0_5 then
		local var_1_0 = arg_1_1.loadouts[arg_1_1.loadout_index]

		for iter_1_0, iter_1_1 in ipairs(arg_1_1.loadout_menu) do
			if iter_1_1.item ~= nil then
				if iter_1_1.type == "stratagems" then
					var_1_0.stratagems[iter_1_1.id] = iter_1_1.item.name
				elseif iter_1_1.type == "perks" then
					var_1_0.perk = iter_1_1.item.name
				elseif iter_1_1.type == "primary_weapon" then
					var_1_0.primary_weapon = iter_1_1.item.name
				else
					assert(false, "Invalid option type")
				end
			end
		end
	end

	arg_1_1.loadout_index = arg_1_2

	if arg_1_3 == nil or arg_1_3 == false then
		arg_1_0:play_sound_accept(nil, 1)
	end

	if arg_1_1.loadout_index == var_0_5 then
		arg_1_1.random_loadout = true

		if arg_1_0.shown_random_loadout_hint == false and arg_1_0.parent.hint_manager then
			arg_1_0.shown_random_loadout_hint = true

			arg_1_0.parent.hint_manager:add_hint("hint_random_loadout")
		end

		if arg_1_1.current_selection_index ~= #arg_1_1.loadout_menu then
			arg_1_1.last_current_selection_index = arg_1_1.current_selection_index
			arg_1_1.current_selection_index = #arg_1_1.loadout_menu
		end
	else
		if arg_1_1.random_loadout then
			arg_1_1.current_selection_index = arg_1_1.last_current_selection_index
		end

		arg_1_1.random_loadout = false

		local var_1_1 = arg_1_1.loadouts[arg_1_1.loadout_index]

		arg_1_1.loadout_menu[var_0_6].item = table.clone(LoadoutSettings.get_item("perks", var_1_1.perk))
		arg_1_1.loadout_menu[var_0_7].item = table.clone(LoadoutSettings.get_item("primary_weapon", var_1_1.primary_weapon))

		for iter_1_2, iter_1_3 in ipairs(var_1_1.stratagems) do
			if iter_1_2 > 4 then
				local var_1_2 = table.clone(LoadoutSettings.get_item("stratagems", iter_1_3))

				arg_1_1.loadout_menu[var_0_7 + (iter_1_2 - 4)].item = var_1_2
			end
		end
	end
end

function MenuScreenLoadout.update_selection(arg_1_0, arg_1_1, arg_1_2)
	local var_1_0 = arg_1_2.submenu and arg_1_2.available_items[arg_1_2.submenu].groups or arg_1_2.loadout_menu
	local var_1_1 = var_1_0[arg_1_2.current_selection_index]

	if arg_1_1.up or arg_1_1.down or arg_1_1.left or arg_1_1.right then
		arg_1_0:reset_description_scroll(arg_1_2)
	end

	if var_1_1 then
		if arg_1_1.up then
			if var_1_1.up_index then
				arg_1_2.current_selection_index = var_1_1.up_index
			elseif arg_1_2.submenu == "stratagems" then
				local var_1_2 = arg_1_2.current_selection_index - 3

				if var_1_0[var_1_2] then
					arg_1_2.current_selection_index = var_1_2
				end
			else
				arg_1_2.current_selection_index = math.max(arg_1_2.current_selection_index - 1, 1)
			end
		elseif arg_1_1.right then
			if var_1_1.right_index then
				arg_1_2.current_selection_index = var_1_1.right_index
			else
				if arg_1_2.submenu == "primary_weapon" then
					local var_1_3 = arg_1_2.available_items[arg_1_2.submenu].groups[arg_1_2.current_selection_index]

					var_1_3.item_index = math.min(var_1_3.item_index + 1, #var_1_3.items)
				end

				if arg_1_2.submenu == "stratagems" or arg_1_2.submenu == nil and arg_1_2.current_selection_index >= var_0_7 + 1 and arg_1_2.current_selection_index <= var_0_7 + 3 then
					arg_1_2.current_selection_index = math.min(arg_1_2.current_selection_index + 1, #var_1_0)
				end
			end
		elseif arg_1_1.down then
			if var_1_1.down_index then
				arg_1_2.current_selection_index = var_1_1.down_index
			elseif arg_1_2.submenu == "stratagems" then
				local var_1_4 = arg_1_2.current_selection_index + 3

				if var_1_0[var_1_4] then
					arg_1_2.current_selection_index = var_1_4
				end
			else
				arg_1_2.current_selection_index = math.min(arg_1_2.current_selection_index + 1, #var_1_0)
			end
		elseif arg_1_1.left then
			if var_1_1.left_index then
				arg_1_2.current_selection_index = var_1_1.left_index
			else
				if arg_1_2.submenu == "primary_weapon" then
					local var_1_5 = arg_1_2.available_items[arg_1_2.submenu].groups[arg_1_2.current_selection_index]

					var_1_5.item_index = math.max(var_1_5.item_index - 1, 1)
				end

				if arg_1_2.submenu == "stratagems" or arg_1_2.submenu == nil and arg_1_2.current_selection_index >= var_0_7 + 2 and arg_1_2.current_selection_index <= var_0_7 + 4 then
					arg_1_2.current_selection_index = math.max(arg_1_2.current_selection_index - 1, 1)
				end
			end
		end
	end
end

function MenuScreenLoadout.draw_player_panel(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5)
	local var_1_0 = 16
	local var_1_1 = 256
	local var_1_2 = 2 / var_1_0
	local var_1_3 = 1 / var_1_1
	local var_1_4 = 0

	arg_1_1:image("basicbox_01", Vector3(-2, var_1_4, arg_1_5 - 1), Vector2(2, arg_1_2 + 11), arg_1_4, Vector2(0, var_1_3), Vector2(var_1_2, 1 - var_1_3))
	arg_1_1:image("basicbox_01", Vector3(-2, arg_1_2 + 10, arg_1_5 - 1), Vector2(arg_1_3 + 4, 1), arg_1_4, Vector2(var_1_2, 1 - var_1_3), Vector2(1 - var_1_2, 1))
	arg_1_1:image("basicbox_01", Vector3(arg_1_3, var_1_4, arg_1_5 - 1), Vector2(2, arg_1_2 + 11), arg_1_4, Vector2(1 - var_1_2, var_1_3), Vector2(1, 1 - var_1_3))
	arg_1_1:image("basicbox_01", Vector3(-2, var_1_4, arg_1_5 - 1), Vector2(arg_1_3 + 4, -1), arg_1_4, Vector2(var_1_2, 0), Vector2(1 - var_1_2, var_1_3))
	arg_1_1:image("basicbox_01", Vector3(0, var_1_4, arg_1_5 - 1), Vector2(arg_1_3, arg_1_2 + 10), arg_1_4, Vector2(var_1_2 * 2, var_1_3 * 2), Vector2(1 - var_1_2 * 2, 1 - var_1_3 * 2))
end

function MenuScreenLoadout.reset_description_scroll(arg_1_0, arg_1_1)
	arg_1_1.y_scroll_offset = 0
end

function MenuScreenLoadout.set_caption(arg_1_0, arg_1_1)
	arg_1_0.specified_caption = arg_1_1
end
