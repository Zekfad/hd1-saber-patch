TelemetryWwsgaManager = manager("TelemetryWwsgaManager")

local var_0_0 = 60

function TelemetryWwsgaManager.setup(arg_1_0)
	arg_1_0.events = Queue(nil, var_0_0)
	arg_1_0.tmpEventQueue = Queue(nil, var_0_0)
	arg_1_0.session_id = math.create_weak_unique_identifier()
	arg_1_0.is_sending = false
	arg_1_0.min_time_between_transmit = 30
	arg_1_0.time_since_last_transmit = arg_1_0.min_time_between_transmit
	arg_1_0.title_id = arg_1_0:get_title_id()
end

function TelemetryWwsgaManager.setup_backend_info(arg_1_0, arg_1_1, arg_1_2)
	if arg_1_0.initialized then
		return
	end

	arg_1_0.initialized = true

	if string.find(arg_1_1, "https://api.helldiversgame.com/") then
		if IS_STEAM then
			arg_1_0.game_id = ""
			arg_1_0.api_key = ""
			arg_1_0.secret_key = ""
		else
			arg_1_0.game_id = ""
			arg_1_0.api_key = ""
			arg_1_0.secret_key = ""
		end

		arg_1_0.schema_id = ""
		arg_1_0.api_endpoint = "https://helldivers.api.wwsga.me/games/" .. arg_1_0.game_id .. "/telemetry"
	else
		arg_1_0.game_id = ""
		arg_1_0.api_key = ""
		arg_1_0.secret_key = ""
		arg_1_0.schema_id = "v1.0"
		arg_1_0.api_endpoint = "https://api.dev.wwsga.me/games/" .. arg_1_0.game_id .. "/telemetry"
	end

	if IS_STEAM then
		arg_1_0.issuer_id_name = "UNKNOWN"
	else
		arg_1_0.issuer_id_name = arg_1_2 or "UNKNOWN"
	end

	local var_1_0 = BootStartDataTelemetryWwsgaEvent()

	arg_1_0:queue_event(var_1_0)
end

function TelemetryWwsgaManager.teardown(arg_1_0)
	arg_1_0.initialized = false
end

function TelemetryWwsgaManager.get_session_id(arg_1_0)
	return arg_1_0.session_id
end

function TelemetryWwsgaManager.get_issuer_id_name(arg_1_0)
	return arg_1_0.issuer_id_name
end

function TelemetryWwsgaManager.set_pad_manager(arg_1_0, arg_1_1)
	arg_1_0.pad_manager = arg_1_1
end

function TelemetryWwsgaManager.get_title_id(arg_1_0)
	local var_1_0 = "Helldivers - STEAM"

	if not IS_RELEASE then
		var_1_0 = "Helldivers - Development (PC)"
	end

	if IS_PS3 then
		var_1_0 = Application.settings().title_id.ps3
	elseif IS_PS4 then
		var_1_0 = Application.settings().title_id.ps4
	elseif IS_PSVITA then
		var_1_0 = Application.settings().title_id.psvita
	end

	return var_1_0
end

function TelemetryWwsgaManager.send_all_queued(arg_1_0)
	if arg_1_0.is_sending then
		return
	end

	local var_1_0 = {
		count = arg_1_0.events:size(),
		events = {},
	}
	local var_1_1 = {}

	for iter_1_0, iter_1_1 in arg_1_0.events:out_of_order_iterator() do
		array.insert_end(var_1_0.events, {
			header = iter_1_1.header,
			data = iter_1_1.data,
			custom_data = iter_1_1.custom_data,
		})
		array.insert_end(var_1_1, iter_1_1.type)
	end

	Log.info("TelemetryWwsgaManager", "Sending " .. array.concat_tostring(var_1_1) .. ".")

	local var_1_2 = Sjson.encode_json(var_1_0)

	Log.debug("TelemetryWwsgaManager", arg_1_0.session_id .. ": Created authentictaion for package: " .. arg_1_0:calculate_auth(var_1_2))
	Log.info("TelemetryWwsgaManager", "Sending telemetric data: \n " .. var_1_2 .. "\n\n")

	
	arg_1_0:http_request_callback(nil, 204, "No Http interface implemented", "NO CONNECTION") -- patch
	--[[
	if rawget(_G, "Http") == nil then
		arg_1_0:http_request_callback(nil, 204, "No Http interface implemented", "NO CONNECTION")

		return
	end

	local var_1_3 = Http.create_request("POST", arg_1_0.api_endpoint, callback(arg_1_0, "http_request_callback"))

	var_1_3:verify_host(true)
	var_1_3:add_header("Content-Type", "application/json")
	var_1_3:add_header("X-WWS-SCHEMA-ID", arg_1_0.schema_id)
	var_1_3:add_header("Authorization", arg_1_0:calculate_auth(var_1_2))
	var_1_3:set_body(var_1_2)
	var_1_3:send()

	arg_1_0.is_sending = true
	]]
end

function TelemetryWwsgaManager.http_request_callback(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4)
	arg_1_0.is_sending = false

	local var_1_0 = "Sony Game Analytics Server responded with " .. arg_1_2 .. " \n Data: \n " .. (arg_1_3 or "") .. " \n Type: " .. (arg_1_4 or "OK")

	if arg_1_2 == 204 then
		Log.info("TelemetryWwsgaManager", var_1_0)
	else
		Log.warning("TelemetryWwsgaManager", var_1_0)
	end

	arg_1_0:dequeue_all_events()
end

function TelemetryWwsgaManager.dequeue_all_events(arg_1_0)
	arg_1_0.events:dequeue_all()

	if not arg_1_0.tmpEventQueue:empty() then
		for iter_1_0, iter_1_1 in ipairs(array.reverse(arg_1_0.tmpEventQueue:dequeue_all())) do
			arg_1_0.events:enqueue(iter_1_1)
		end
	end
end

function TelemetryWwsgaManager.queue_event(arg_1_0, arg_1_1)
	local var_1_0 = {
		header = arg_1_1:get_telemetry(arg_1_0:get_header(arg_1_0:get_np_id(), arg_1_0.session_id)),
		data = arg_1_1:get_telemetry(arg_1_1.fields),
		custom_data = arg_1_1:get_extra_data("custom"),
		type = tostring(arg_1_1),
	}

	if not arg_1_0.is_sending then
		arg_1_0.events:enqueue(var_1_0)
	else
		arg_1_0.tmpEventQueue:enqueue(var_1_0)
	end
end

function TelemetryWwsgaManager.update(arg_1_0, arg_1_1)
	if not arg_1_0.initialized then
		return
	end

	arg_1_0.time_since_last_transmit = math.min(arg_1_0.min_time_between_transmit, arg_1_0.time_since_last_transmit + arg_1_1)

	if arg_1_0.min_time_between_transmit <= arg_1_0.time_since_last_transmit and not arg_1_0.events:empty() then
		arg_1_0.time_since_last_transmit = 0

		arg_1_0:send_all_queued()
	end
end

function TelemetryWwsgaManager.calculate_auth(arg_1_0, arg_1_1)
	local var_1_0 = Hash.md5(arg_1_1)
	local var_1_1 = arg_1_0.game_id
	local var_1_2 = string.format("POST\n%s\napplication/json\n%s\n/games/%s/telemetry", var_1_0, arg_1_0.schema_id, arg_1_0.game_id)

	return arg_1_0.api_key .. ":" .. arg_1_0:calculate_signature(var_1_2)
end

function TelemetryWwsgaManager.calculate_signature(arg_1_0, arg_1_1)
	return Hash.hmacsha1(arg_1_0.secret_key, arg_1_1)
end

function TelemetryWwsgaManager.get_np_id(arg_1_0)
	local var_1_0 = "UNKNOWN"

	if IS_PS4 or IS_PSVITA or IS_PS3 then
		var_1_0 = tostring(UserManager:get_name() or "UNKNOWN")
	elseif IS_STEAM then
		var_1_0 = tostring(UserManager:get_user_id() or "UNKNOWN")
	elseif IS_DEV and IS_PC then
		var_1_0 = "DEVELOPER ON PC"
	end

	return var_1_0
end

function TelemetryWwsgaManager.get_timezone(arg_1_0)
	local var_1_0 = os.time()

	return os.difftime(var_1_0, os.time(os.date("!*t", var_1_0))) / 60
end

function TelemetryWwsgaManager.get_header(arg_1_0, arg_1_1)
	assert(arg_1_1, "Did not get user_id")

	return {
		{
			description = "",
			key = "user_id",
			required = true,
			type = "string",
			value = arg_1_1,
		},
		{
			description = "",
			key = "psn_account",
			required = false,
			type = "string",
		},
		{
			description = "",
			key = "title_id",
			required = true,
			type = "string",
			value = arg_1_0:get_title_id(),
		},
		{
			description = "",
			key = "client_timestamp",
			required = true,
			type = "number",
			value = os.time(),
		},
		{
			description = "",
			key = "client_timezone",
			required = false,
			type = "number",
			value = arg_1_0:get_timezone(),
		},
		{
			description = "",
			key = "server_timestamp",
			required = false,
			type = "number",
		},
		{
			description = "",
			key = "server_ipaddress",
			required = false,
			type = "string",
		},
		{
			description = "",
			key = "client_ipaddress",
			required = false,
			type = "string",
		},
		{
			description = "",
			key = "session_id",
			required = true,
			type = "string",
			value = arg_1_0.session_id,
		},
	}
end

TelemetryEvent = class("TelemetryEvent")

function TelemetryEvent.get_telemetry(arg_1_0, arg_1_1)
	local var_1_0 = {}

	for iter_1_0, iter_1_1 in ipairs(arg_1_1) do
		if iter_1_1.required and iter_1_1.value == nil then
			Log.error("Telemetry", "key: %s (%s) is missing value of type %s", iter_1_1.key or "", iter_1_1.description or "", iter_1_1.type or "")
		end

		if iter_1_1.value and array.find({
			"string",
			"boolean",
			"number",
			"int",
		}, iter_1_1.type) then
			local var_1_1

			if iter_1_1.type == "int" then
				var_1_1 = math.is_int(iter_1_1.value)
			else
				var_1_1 = type(iter_1_1.value) == iter_1_1.type
			end

			Log.cond_error(not var_1_1, "Telemetry", "Field %s is of type %s but got type %s. ", iter_1_1.key or "", iter_1_1.type or "", type(iter_1_1.value))
		end

		var_1_0[iter_1_1.key] = iter_1_1.value
	end

	return var_1_0
end

function TelemetryEvent.set_extra_data(arg_1_0, arg_1_1, arg_1_2)
	if not arg_1_0.extra_data then
		arg_1_0.extra_data = {}
	end

	arg_1_0.extra_data[arg_1_1] = arg_1_2
end

function TelemetryEvent.get_extra_data(arg_1_0, arg_1_1)
	return arg_1_0.extra_data and arg_1_0.extra_data[arg_1_1]
end

TelemetryWwsgaEvent = class("TelemetryWwsgaEvent", "TelemetryEvent")
BootStartDataTelemetryWwsgaEvent = class("BootStartDataTelemetryWwsgaEvent", "TelemetryWwsgaEvent")

function BootStartDataTelemetryWwsgaEvent.init(arg_1_0, arg_1_1, arg_1_2)
	arg_1_0:set_extra_data("custom", arg_1_2)

	local var_1_0 = Application.settings().communication_id
	local var_1_1 = ""

	if IS_PSVITA then
		var_1_1 = "PSVITA"
	elseif IS_PS3 then
		var_1_1 = "PS3"
	elseif IS_PS4 then
		var_1_1 = "PS4"
	elseif IS_PC then
		var_1_1 = "PC"
	end

	arg_1_0.fields = {
		{
			description = "Enum(BootStart)",
			key = "event_type",
			required = true,
			type = "string",
			value = "BootStart",
		},
		{
			description = "One of [boot, liveTile, resume]",
			key = "launch_method",
			type = "string",
		},
		{
			description = "PSN TitleId, for example CUSA12345",
			key = "title_id",
			required = true,
			type = "string",
			value = TelemetryWwsgaManager:get_title_id(),
		},
		{
			description = "Name for the title, for example Killzone Shadow Fall",
			key = "title_name",
			required = true,
			type = "string",
			value = "Helldivers",
		},
		{
			description = "NP Communication ID in use by the title, for example CUSA12345_00",
			key = "np_communication_id",
			required = true,
			type = "string",
			value = var_1_0,
		},
		{
			description = "IssuerId or NP Environment, for example np, spi-int",
			key = "issuer_id",
			required = true,
			type = "string",
			value = TelemetryWwsgaManager:get_issuer_id_name(),
		},
		{
			description = "Unique disc Id if available",
			key = "disc_id",
			type = "string",
		},
		{
			description = "Build version, for example v5.11",
			key = "build_version",
			required = true,
			type = "string",
			value = BUILD_GAME_INFORMATION .. " " .. BUILD_ENGINE_INFORMATION,
		},
		{
			description = "true | false",
			key = "is_trial",
			required = true,
			type = "boolean",
			value = IS_DEV or false,
		},
		{
			description = "",
			key = "boot_session_id",
			required = true,
			type = "string",
			value = TelemetryWwsgaManager:get_session_id(),
		},
		{
			description = "One of: PS3, PS4, PSNOW, PSVITA, Android, iOS",
			key = "platform",
			required = false,
			type = "string",
			value = var_1_1,
		},
	}
end

UserProfileDataTelemetryEvent = class("UserProfileDataTelemetryEvent", "TelemetryWwsgaEvent")

function UserProfileDataTelemetryEvent.init(arg_1_0, arg_1_1, arg_1_2)
	arg_1_0:set_extra_data("custom", arg_1_2)

	arg_1_0.fields = {
		{
			description = "None",
			key = "event_type",
			type = "Enum(UserProfile)",
			value = "UserProfile",
		},
		{
			description = "NpOnlineId or “handle” for the player",
			key = "np_online_id",
			required = true,
			type = "string",
			value = arg_1_1.np_online_id,
		},
		{
			description = "NpAccountId which is the unique identifier for a player on PSN",
			key = "np_account_id",
			required = true,
			type = "int",
			value = arg_1_1.np_account_id,
		},
		{
			description = "If available, whether the user is a guest on this console true | false",
			key = "is_guest",
			required = false,
			type = "boolean",
			value = arg_1_1.is_guest,
		},
		{
			description = "Whether the user is a PS Plus subscriber true | false",
			key = "is_psplus_subscriber",
			required = false,
			type = "boolean",
			value = arg_1_1.is_psplus_subscriber,
		},
		{
			description = "Whether the user is a PSN sub account true | false",
			key = "is_sub_account",
			required = false,
			type = "string",
			value = arg_1_1.is_sub_account,
		},
		{
			description = "The age of the user as provided by the information in the ticket or WebAPI.",
			key = "age",
			required = true,
			type = "int",
			value = arg_1_1.age,
		},
		{
			description = "Date of birth if available, in the format “YYYY-MM-DD”",
			key = "dob",
			required = false,
			type = "string",
			value = arg_1_1.dob,
		},
		{
			description = "The value of restrictChat",
			key = "restrict_chat",
			required = false,
			type = "boolean",
			value = arg_1_1.restrict_chat,
		},
		{
			description = "The value of restrictUGM",
			key = "restrict_ugm",
			required = false,
			type = "boolean",
			value = arg_1_1.restrict_ugm,
		},
		{
			description = "The value of restrictStoreContent",
			key = "restrict_store_content",
			required = false,
			type = "boolean",
			value = arg_1_1.restrict_store_content,
		},
		{
			description = "The ISO 3166-1 country code for the PSN account, for example us, au",
			key = "region",
			required = true,
			type = "string",
			value = arg_1_1.region,
		},
		{
			description = "The language code for the PSN account decide format",
			key = "language",
			required = true,
			type = "string",
			value = arg_1_1.language,
		},
		{
			description = "Used",
			key = "languages_used",
			required = false,
			type = "Array[string]",
			value = arg_1_1.languages_used,
		},
		{
			description = "avatar",
			key = "avatar_url",
			required = false,
			type = "string",
			value = arg_1_1.avatar_url,
		},
		{
			description = "PSN about me text",
			key = "about_me",
			required = false,
			type = "string",
			value = arg_1_1.about_me,
		},
	}
end

GameStartDataTelemetryEvent = class("GameStartDataTelemetryEvent", "TelemetryWwsgaEvent")

function GameStartDataTelemetryEvent.init(arg_1_0, arg_1_1, arg_1_2)
	arg_1_0:set_extra_data("custom", arg_1_2)

	arg_1_0.fields = {
		{
			description = "None",
			key = "event_type",
			required = true,
			type = "Enum(GameStart)",
			value = "GameStart",
		},
		{
			description = "None",
			key = "game_id",
			required = true,
			type = "string",
			value = arg_1_1.game_id,
		},
		{
			description = "None",
			key = "mode",
			required = false,
			type = "string",
			value = arg_1_1.mode,
		},
		{
			description = "None",
			key = "level_id",
			required = false,
			type = "string",
			value = arg_1_1.level_id,
		},
		{
			description = "None",
			key = "entry_point",
			required = true,
			type = "string",
			value = arg_1_1.entry_point,
		},
	}
end

PlayerJoinDataTelemetryEvent = class("PlayerJoinDataTelemetryEvent", "TelemetryWwsgaEvent")

function PlayerJoinDataTelemetryEvent.init(arg_1_0, arg_1_1, arg_1_2)
	arg_1_0:set_extra_data("custom", arg_1_2)

	arg_1_0.fields = {
		{
			description = "None",
			key = "event_type",
			required = true,
			type = "Enum(PlayerJoin)",
			value = "PlayerJoin",
		},
		{
			description = "None",
			key = "game_id",
			required = true,
			type = "string",
			value = arg_1_1.game_id,
		},
		{
			description = "None",
			key = "np_online_id",
			required = true,
			type = "string",
			value = arg_1_1.np_online_id,
		},
		{
			description = "None",
			key = "player_type",
			required = false,
			type = "string",
			value = arg_1_1.player_type,
		},
		{
			description = "None",
			key = "peripheral_usage",
			required = false,
			type = "string",
			value = arg_1_1.peripheral_usage,
		},
	}
end

PlayerLeaveDataTelemetryEvent = class("PlayerLeaveDataaTelemetryEvent", "TelemetryWwsgaEvent")

function PlayerLeaveDataTelemetryEvent.init(arg_1_0, arg_1_1, arg_1_2)
	arg_1_0:set_extra_data("custom", arg_1_2)

	arg_1_0.fields = {
		{
			description = "None",
			key = "event_type",
			required = true,
			type = "Enum(PlayerLeave)",
			value = "PlayerLeave",
		},
		{
			description = "None",
			key = "game_id",
			required = true,
			type = "string",
			value = arg_1_1.game_id,
		},
		{
			description = "None",
			key = "level_id",
			required = true,
			type = "string",
			value = arg_1_1.level_id,
		},
		{
			description = "None",
			key = "duration_secs",
			required = true,
			type = "int",
			value = arg_1_1.duration_secs,
		},
		{
			description = "None",
			key = "np_online_id",
			required = false,
			type = "string",
			value = arg_1_1.np_online_id,
		},
		{
			description = "None",
			key = "outcome",
			required = false,
			type = "string",
			value = arg_1_1.outcome,
		},
		{
			description = "None",
			key = "mode",
			required = false,
			type = "string",
			value = arg_1_1.mode,
		},
		{
			description = "None",
			key = "player_count",
			required = false,
			type = "int",
			value = arg_1_1.player_count,
		},
	}
end

GameEndDataTelemetryEvent = class("GameEndDataTelemetryEvent", "TelemetryWwsgaEvent")

function GameEndDataTelemetryEvent.init(arg_1_0, arg_1_1, arg_1_2)
	arg_1_0:set_extra_data("custom", arg_1_2)

	arg_1_0.fields = {
		{
			description = "None",
			key = "event_type",
			required = true,
			type = "Enum(GameEnd)",
			value = "GameEnd",
		},
		{
			description = "None",
			key = "game_id",
			required = true,
			type = "string",
			value = arg_1_1.game_id,
		},
		{
			description = "None",
			key = "end_reason",
			required = false,
			type = "string",
			value = arg_1_1.end_reason,
		},
		{
			description = "None",
			key = "mode",
			required = true,
			type = "string",
			value = arg_1_1.mode,
		},
		{
			description = "None",
			key = "level_id",
			required = true,
			type = "string",
			value = arg_1_1.level_id,
		},
		{
			description = "None",
			key = "local_player_count",
			required = true,
			type = "int",
			value = arg_1_1.local_player_count,
		},
		{
			description = "None",
			key = "player_count",
			required = true,
			type = "int",
			value = arg_1_1.player_count,
		},
		{
			description = "None",
			key = "duration_secs",
			required = true,
			type = "int",
			value = arg_1_1.duration_secs,
		},
		{
			description = "None",
			key = "is_completed",
			required = true,
			type = "boolean",
			value = arg_1_1.is_completed,
		},
	}
end
