local plugin = {}

plugin.name = "New Event Shuffler"
plugin.author = "adrian_squared"
plugin.settings = {}

plugin.description =
[[
    This plugin is designed to switch between games once the player obtains a ring.
]]

oldring = 0
-- modified swap_game fonction to avoid sound turning off after switching within 1 frame
function swap_game(next_game)
	log_debug('swap_game(%s): running=%s', next_game, running)
	-- if a swap has already happened, don't call again
	if not running then return false end

	-- if no game provided, call get_next_game()
	next_game = next_game or get_next_game()

	-- if the game isn't changing, stop here and just update the timer
	-- (you might think we should just disable the timer at this point, but this
	-- allows new games to be added mid-run without the timer being disabled)
	if next_game == config.current_game then
		update_next_swap_time()
		return false
	end

	-- swap_game() is used for the first load, so check if a game is loaded
	if config.current_game ~= nil then
		for _,plugin in ipairs(plugins) do
			if plugin.on_game_save ~= nil then
				local pdata = config.plugins[plugin._module]
				plugin.on_game_save(pdata.state, pdata.settings)
			end
		end
	end

	-- at this point, save the game and update the new "current" game after
	save_current_game()
	config.current_game = next_game
	running = false

	-- unique game count, for debug purposes
	config.game_count = 0
	for _, _ in pairs(config.game_swaps) do
		config.game_count = config.game_count + 1
	end

	-- save an updated randomizer seed
	config.nseed = math.random(MAX_INTEGER) + config.frame_count
	save_config(config, 'shuffler-src/config.lua')

	return load_game(config.current_game)
end

function plugin.on_game_load(data) -- hash is used if game isn't in the database, else just the name is used for readability's sake
	name = gameinfo.getromname()
	hash = gameinfo.getromhash()
	-- console.writeline(gameinfo.getromname())
	-- console.writeline(gameinfo.getromhash())
end
-- redundant fonction in case I need to add smth later
function ring_swap()
	oldring = 1000000
	swap_game()
end

-- called each frame
function plugin.on_frame(data, settings)
	next_swap_time = next_swap_time+1000
	-- -- Sonic games
	-- Mega Drive Games
	if name == "Sonic The Hedgehog (W) (REV00) [!]" or name == "Sonic The Hedgehog (W) (REV01) [!]" or name == "Sonic The Hedgehog 2 (W) (REV00) [!]" or name == "Sonic The Hedgehog 2 (W) (REV01) [!]" or name == "Sonic The Hedgehog 3 (U) [!]" or name == "Sonic The Hedgehog 3 (J) [!]" or name == "Sonic The Hedgehog 3 (E) [!]" or name == "Sonic and Knuckles (W) [!]" or name == "Sonic and Knuckles & Sonic 2 (W) [!]" or name == "Sonic & Knuckles + Sonic The Hedgehog 3 (E)" or name == "Sonic & Knuckles + Sonic The Hedgehog 3 (J)" or name == "Sonic and Knuckles & Sonic 3 (W) [!]" then
		if memory.read_u16_be(0xFE20,"68K RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0xFE20,"68K RAM")
	elseif name == "Sonic Eraser (SN) (J) [!]" then
		if memory.read_u16_be(0xC710,"68K RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0xC710,"68K RAM")
	elseif name == "Dr. Robotnik's Mean Bean Machine (U) [!]" or name == "Dr. Robotnik's Mean Bean Machine (E) [!]" then
		if memory.read_u16_be(0xE00C,"68K RAM") > oldring+39 then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0xE00C,"68K RAM")
	elseif name == "Sonic Spinball (U) [!]" or name == "Sonic Spinball (J) [!]" or name == "Sonic Spinball (E) [!]" then
		if memory.read_u8(0x57A0,"68K RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u8(0x57A0,"68K RAM")
	elseif name == "Sonic 3D Blast (UE) [!]" then
		if memory.read_u16_be(0x0A5A,"68K RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0x0A5A,"68K RAM")
	elseif hash == "4072D34E119E199131B839D338F1FC38E472203A" then -- 3D Blast Director's Cut
		if memory.read_u16_be(0x0AA2,"68K RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0x0AA2,"68K RAM")
	elseif name == "Sonic and Knuckles & Sonic 1 (W) [!]" or hash == "252FDD1E3F1DC630E13A5FF51162BB454E6FED34" then -- Blue Spheres
		if memory.read_u16_be(0xE442,"68K RAM") < oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0xE442,"68K RAM")
	-- Mega-CD Games
	elseif hash == "AFC5F20CEFD2AADFC8C146EB27623F75" or hash == "BBA401CFF383AD7946978A600E756561" or hash == "D0E2A628A5DA9F72402559B2535C05D1" then -- in order: Sonic CD (J);Sonic CD (U);Sonic CD (E)
		if memory.read_u16_be(0x1512,"68K RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0x1512,"68K RAM")
	-- 32X Games
	elseif name == "Knuckles' Chaotix (32X) (JU) [!]" or name == "Knuckles' Chaotix (32X) (E) [!]" then
		if memory.read_u16_be(0xE008,"68K RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0xE008,"68K RAM")
	-- Master System & Game Gear Games
	elseif name == "Sonic The Hedgehog (UE)" or hash == "815A0E5449232CD5B5CA935D564C5C1F7EB0C514" then -- SMS Version and "Perfect System" hack
		if memory.read_u8(0x12AA,"Main RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u8(0x12AA,"Main RAM")
	elseif name == "Sonic The Hedgehog (W) (Rev 1)" or name == "Sonic The Hedgehog (J)" then -- Game Gear Version
		if memory.read_u8(0x12A9,"Main RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u8(0x12A9,"Main RAM")
	elseif name == "Sonic The Hedgehog 2 (E)" or name == "Sonic The Hedgehog 2 (E) (Rev 1)" or name == "Sonic The Hedgehog 2 (W)" then -- SMS & Game Gear Versions
		if memory.read_u8(0x1299,"Main RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u8(0x1299,"Main RAM")
	elseif name == "Sonic Chaos (E)" then -- SMS Version
		if memory.read_u8(0x129A,"Main RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u8(0x129A,"Main RAM")
	elseif name == "Sonic Chaos (UE)" or name == "Sonic & Tails (J) (En)" then -- Game Gear Versions
		if memory.read_u8(0x129C,"Main RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u8(0x129C,"Main RAM")
	elseif name == "Dr. Robotnik's Mean Bean Machine (E)" or name == "Dr. Robotnik's Mean Bean Machine (UE)" then -- SMS & Game Gear Versions
		if memory.read_u8(0x0CC0,"Main RAM") > oldring+39 then
			ring_swap()
			return
		end
		oldring = memory.read_u8(0x0CC0,"Main RAM")
	elseif name == "Sonic Drift (J)" then
		if memory.read_u8(0x1A00,"Main RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u8(0x1A00,"Main RAM")
	elseif name == "Sonic Spinball (E)" then -- SMS Version
		if memory.read_u8(0x1E84,"Main RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u8(0x1E84,"Main RAM")
	elseif name == "Sonic Spinball (UE)" then -- Game Gear Version
		if memory.read_u8(0x1E6A,"Main RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u8(0x1E6A,"Main RAM")
	elseif name == "Sonic The Hedgehog - Triple Trouble (UE)" or name == "Sonic & Tails 2 (J)" or hash == "4E3CB96724E353F8744FA3F46B39D73324456F93" then -- Game Gear Versions and SMS hack
		if memory.read_u8(0x1159,"Main RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u8(0x1159,"Main RAM")
	elseif name == "Sonic Drift 2 (JU)" then
		if memory.read_u8(0x1CC3,"Main RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u8(0x1CC3,"Main RAM")
	elseif name == "Sonic Blast (B)" or name == "Sonic Blast (W)" then -- SMS and Game Gear Versions
		if memory.read_u8(0x125E,"Main RAM") > oldring and memory.read_u8(0x1FBA,"Main RAM") ~= 0 then -- to avoid constant swapping during the beginning gem scene
			ring_swap()
			return
		end
		oldring = memory.read_u8(0x125E,"Main RAM")
	-- Saturn Games
	elseif hash == "62F6C7B8039EE5957CFEFA35CB85CBE8" or hash == "BE0EBA13E9C667F05E8C2B50F3F26887" or hash == "E58EF014C3866463BCE29A703C5BD345" then -- Sonic R (UB); Sonic R (E); Sonic R (J)
		if memory.read_u16_be(0x00B3F0,"Work Ram High") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0x00B3F0,"Work Ram High")
	elseif hash == "CAF83E879EC362D01845A950E0DA7826" or hash == "3F17253534A9877B1D24B5E46A2489E8" or hash == "76C4F65FA7BE4E5C2CD1D8D405EBF577" then -- Sonic 3D Blast (U); Sonic 3D Blast (E); Sonic 3D Blast (J)
		if memory.read_u16_be(0x09800C,"Work Ram High") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0x09800C,"Work Ram High")
	elseif hash == "396F24E2C149B04A368CA0CE66286833" or hash == "44C29A96FA15DE6FBD9E040173223F22" or hash == "230AB7AC987E373EF26219B2CD64BA35" or hash == "7547BDD9EC4CFAADDFC4EA9160F4D70E" then -- Sonic Jam
		if memory.read_u16_be(0x0FFD26,"Work Ram High") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0x0FFD26,"Work Ram High")
	-- Game Boy Advance Games
	elseif name == "Sonic Advance (USA) (En,Ja)" or name == "Sonic Advance (Japan) (En,Ja)" or name == "Sonic Advance (Europe) (En,Ja,Fr,De,Es)" then
		if memory.read_u16_be(0x4FEC,"IWRAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0x4FEC,"IWRAM")
	elseif name == "Sonic Advance 2 (USA) (En,Ja,Fr,De,Es,It)" or name == "Sonic Advance 2 (Japan) (En,Ja,Fr,De,Es,It)" or name == "Sonic Advance 2 (Europe) (En,Ja,Fr,De,Es,It)" then
		if memory.read_u16_be(0x53F0,"IWRAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0x53F0,"IWRAM")
	elseif name == "Sonic Advance 3 (USA) (En,Ja,Fr,De,Es,It)" or name == "Sonic Advance 3 (Japan) (En,Ja,Fr,De,Es,It)" or name == "Sonic Advance 3 (Europe) (En,Ja,Fr,De,Es,It)" then
		if memory.read_u16_be(0x094C,"IWRAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0x094C,"IWRAM")
	-- DS Games
	elseif name == "Sonic Rush (USA) (En,Ja,Fr,De,Es,It)" or name == "Sonic Rush (Japan) (En,Ja,Fr,De,Es,It)" or name == "Sonic Rush (Europe) (En,Ja,Fr,De,Es,It)" then
		if memory.read_u16_be(0x090B6E,"Main RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0x090B6E,"Main RAM")
--	elseif name == "Sonic Rush Adventure (USA) (En,Ja,Fr,De,Es,It)" or name == "Sonic Rush Adventure (Japan) (En,Ja,Fr,De,Es,It)" or name == "Sonic Rush Adventure (Europe) (En,Ja,Fr,De,Es,It)" or name == "Sonic Rush Adventure (Europe) (En,Ja,Fr,De,Es,It) (Rev 1)" or name == "Sonic Rush Adventure (K)" then
--		if memory.read_u16_be(0x18F6BE,"Main RAM") > oldring then
--			ring_swap()
--			return
--		end
--		oldring = memory.read_u16_be(0x18F6BE,"Main RAM") -- commented out until I figure out how to detect when not in a level
	elseif name == "Sonic Colors (USA) (En,Ja,Fr,De,Es,It)" or name == "Sonic Colors (Japan) (En,Ja,Fr,De,Es,It)" or name == "Sonic Colours (Europe) (En,Ja,Fr,De,Es,It)" then
		if memory.read_u16_be(0x19B936,"Main RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0x19B936,"Main RAM")
	-- 3DS Games
	elseif name == "Sonic Generations (USA) (En,Fr,Es)" then -- Need to add JP & EU Versions
		if memory.read_u16_be(0x077E5934,"FCRAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0x077E5934,"FCRAM")
	elseif name == "Sonic - Lost World (USA) (En,Fr,Es)" then -- Need to add JP & EU Versions
		if memory.read_u16_be(0x06D13900,"FCRAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0x06D13900,"FCRAM")
	-- Neo-Geo Pocket Colour Games
	elseif hash == "5A881D8124D902B4A98D76362AD62566A86F0ABA" then -- Sonic Pocket Adventure
		if memory.read_u16_be(0x27A8,"RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0x27A8,"RAM")
	-- Arcade Games
	elseif name == "SegaSonic Bros. (prototype, hack)" then
		if memory.read_u16_be(0xB0E8,"m68000 : ram : 0xE00000-0xE0FFFF") > oldring+9 then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0xB0E8,"m68000 : ram : 0xE00000-0xE0FFFF")
	end
	
	-- -- Mario Games
	-- NES Games
	elseif name == "Super Mario Bros." then
		if memory.read_u8(0x075E,"RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u8(0x075E,"RAM")
	end
end

return plugin
