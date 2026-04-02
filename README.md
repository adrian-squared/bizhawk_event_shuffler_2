local plugin = {}

plugin.name = "Bizhawk Event Shuffler"
plugin.author = "adrian_squared"
plugin.settings = {}

plugin.description =
[[
    This plugin is designed to switch between games once the player obtains a ring (or equivalent event depending on the game).
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
	sysid = emu.getsystemid()
	-- console.writeline(gameinfo.getromname())
	-- console.writeline(gameinfo.getromhash())
	-- console.writeline(emu.getsystemid())
end

function ring_swap()
	oldring = 1000000 -- high number to replace garbage data on game swap (to be taken into account when you're looking for a decrease in value)
	swap_game()
end

-- called each frame
function plugin.on_frame(data, settings)
	next_swap_time = next_swap_time+1000
	-- -- Sonic games
	-- Mega Drive & Mega-CD Games
	if sysid == "GEN" then
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
			if (memory.read_u16_be(0xE442,"68K RAM") < oldring) and (oldring ~= 1000000) then
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
		end
	-- 32X Games
	elseif sysid == "32X" then
		if name == "Knuckles' Chaotix (32X) (JU) [!]" or name == "Knuckles' Chaotix (32X) (E) [!]" then
			if memory.read_u16_be(0xE008,"68K RAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u16_be(0xE008,"68K RAM")
		end
	-- Master System & Game Gear Games
	elseif sysid == "SMS" or sysid == "GG" then
		if name == "Sonic The Hedgehog (UE)" or hash == "815A0E5449232CD5B5CA935D564C5C1F7EB0C514" then -- SMS Version and "Perfect System" hack
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
			if (memory.read_u8(0x125E,"Main RAM") > oldring) and (memory.read_u8(0x1FBA,"Main RAM") ~= 0) then -- to avoid constant swapping during the beginning gem scene
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x125E,"Main RAM")
		end
	-- Saturn Games
	elseif sysid == "SAT" then
		if hash == "62F6C7B8039EE5957CFEFA35CB85CBE8" or hash == "BE0EBA13E9C667F05E8C2B50F3F26887" or hash == "E58EF014C3866463BCE29A703C5BD345" then -- Sonic R (UB); Sonic R (E); Sonic R (J)
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
		end
	-- Game Boy Advance Games
	elseif sysid == "GBA" then
		if name == "Sonic Advance (USA) (En,Ja)" or name == "Sonic Advance (Japan) (En,Ja)" or name == "Sonic Advance (Europe) (En,Ja,Fr,De,Es)" then
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
		end
	-- DS Games
	elseif sysid == "NDS" then
		if name == "Sonic Rush (USA) (En,Ja,Fr,De,Es,It)" or name == "Sonic Rush (Japan) (En,Ja,Fr,De,Es,It)" or name == "Sonic Rush (Europe) (En,Ja,Fr,De,Es,It)" then
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
		end
	-- 3DS Games
	elseif sysid == "3DS" then
		if name == "Sonic Generations (USA) (En,Fr,Es)" then -- Need to add JP & EU Versions
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
		end
	-- Neo-Geo Pocket Colour Games
	elseif sysid == "NGP" then
		if hash == "5A881D8124D902B4A98D76362AD62566A86F0ABA" then -- Sonic Pocket Adventure
			if memory.read_u16_be(0x27A8,"RAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u16_be(0x27A8,"RAM")
		end
	-- Arcade Games
	elseif sysid == "Arcade" then
		if name == "SegaSonic Bros. (prototype, hack)" then
			if memory.read_u16_be(0xB0E8,"m68000 : ram : 0xE00000-0xE0FFFF") > oldring+99 then
				ring_swap()
				return
			end
			oldring = memory.read_u16_be(0xB0E8,"m68000 : ram : 0xE00000-0xE0FFFF")
		end
	-- NES Games
	elseif sysid == "NES" then
		if name == "Super Mario Bros." or hash == "CB301E125D9DCCC2D2D1678BA8C622D3B6BCE801" or hash == "47ADEB36EB595140F5E1F69A972165366E8DB7AC" or hash == "20E50128742162EE47561DB9E82B2836399C880C" or hash == "383AD8E3890A95DE9595F0A6087648F51177DA13" or hash == "08927227B6FF67F42E759505D176CD924931BD14" or hash == "B2DBC55EFCAE77ABAD6207B802C0A76D7A47ED0D" or hash == "CB9FB99B7731ED05B81D4B6BAE06E0FBF8D21FA8" or hash == "F30BDD3C556604D7EAA6D0F4864D5566E519B5D4" then --hashes (in order): 25th anniversary edition AU;JP;Lost Levels;SMB FDS;Lost Levels DV2;Lost Levels VC; Lost Levels Game & Watch; All Night Nippon
			if memory.read_u8(0x075E,"RAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x075E,"RAM")
		elseif name == "Super Mario Bros. 3" or hash == "948A29F6E64B27E6E4556ADBBB673B723E3CF393" or hash == "332FEB7522E54A36F457EE1FBDEAB4236621044B" or hash == "AF5418EBFFCAF95A3EC60F576857BE678B0E9556" then -- hashes for VC versions
			if memory.read_u8(0x1DA2,"WRAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x1DA2,"WRAM")
		elseif name == "Wrecking Crew" or hash == "F6571C49F4146C8C9E61092CCEA2B7205B8F3337" or hash == "8847D38111952C56B399F54FD622FCC395BF1752" then --hash for VC and FDS versions
			if memory.read_u8(0x0092,"RAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x0092,"RAM")
		elseif name == "Dr. Mario" then
			if memory.read_u8(0x0732,"RAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x0732,"RAM")
		elseif name == "Yoshi" or name == "Mario & Yoshi" or name == "Yoshi no Tamago" then
			if memory.read_u8(0x0532,"RAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x0532,"RAM")
		elseif name == "Yoshi's Cookie" or name == "Yoshi no Cookie" or hash == "8E1172B933ACAB32A141E17A7267AC55DA6C8BCF" or hash == "4E6F94D4689C9A70FF7E2477FCB3C1DA91D16996" then -- hashes for US and EU VC versions
			if memory.read_u8(0x040C,"RAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x040C,"RAM")
		elseif name == "Wario's Woods" or name == "Wario no Mori" then
			if memory.read_u8(0x1B60,"WRAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x1B60,"WRAM")
		elseif name == "NES Open Tournament Golf" or name == "Mario Open Golf" or hash == "982585F28F4AD585F09F0BEE199BAA06B104D896" or hash == "02795482FFDAD424C12D50115AF8FC696EAE8ACA" or hash == "76EA8F1AD837ED2BE8A096A31E7C92B4B0F13A7E" then -- hashes for VC versions U;E;J
			if memory.read_u8(0x0094,"RAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x0094,"RAM")
		elseif hash == "81F0FF0CC9BD47195E5ACC1EE4FC95ED1DDA7596" or hash == "532214DACBAC874DEB1C944F894C450FEEFFD2EB" or hash == "31EB8B7E7C867E8DD3996633AB703CA318220519" then -- Golf Japan Course, Japan Course DV2, Professional Course
			if memory.read_u8(0x0051,"RAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x0051,"RAM")
		elseif hash == "7FE5D5B21BBE6A15CE0A8D327FE4D6EEC87C184D" or hash == "D5A29613806FFD6C8FAE1D81050EA015C4476906" or hash == "BA9ACB65D9D009C08C0FDF521646FA84EBB4C69A" or hash == "F9DF95725822161784598064F50BEF3EA639967D" then -- Golf US Course, US Course DV1, US Course DV2, Special Course
			if memory.read_u8(0x006E,"RAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x006E,"RAM")
		end
	-- SNES Games
	elseif sysid == "SNES" then
		if name == "Super Mario World (USA)" or name == "Super Mario World (Europe)" or name == "Super Mario World (Europe) (Rev 1)" or name == "Super Mario World - Super Mario Bros. 4 (Japan)" or hash == "50A2312099AE7CDF7140E6E66AC0E0A44B9E4779" or hash == "84DB8080746ED75B9174FFB59028CCD1FB9F4918" then --hashes for VC/NSO versions
			if memory.read_u8(0x000DBF,"WRAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x000DBF,"WRAM")
		elseif name == "Super Mario World 2 - Yoshi's Island (USA)" or name == "Super Mario World 2 - Yoshi's Island (USA) (Rev 1)" or name == "Super Mario World 2 - Yoshi's Island (Europe) (En,Fr,De)" or name == "Super Mario World 2 - Yoshi's Island (Europe) (En,Fr,De) (Rev 1)" or name == "Super Mario - Yossy Island (Japan)" or name == "Super Mario - Yossy Island (Japan) (Rev 1)" or name == "Super Mario - Yossy Island (Japan) (Rev 2)" or hash == "1E1DC02C684652F9E927F3873AF65EA4B374BB80" then -- hash: EU Rev2
			if memory.read_u8(0x00037B,"WRAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x00037B,"WRAM")
		elseif name == "Super Mario Kart (USA)" or name == "Super Mario Kart (Japan)" or name == "Super Mario Kart (Europe)" then
			if memory.read_u8(0x000E00,"WRAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x000E00,"WRAM")
		elseif name == "Donkey Kong Country (USA)" or name == "Donkey Kong Country (USA) (Rev 1)" or name == "Donkey Kong Country (USA) (Rev 2)" or name == "Donkey Kong Country (Europe) (En,Fr,De)" or name == "Donkey Kong Country (Europe) (En,Fr,De) (Rev 1)" or name == "Super Donkey Kong (Japan)" or name == "Super Donkey Kong (Japan) (Rev 1)" or hash == "F7223A087CCA2C8D5BBF91C0BCC2D077DE6606FA" or hash == "8078B1D386CEEB2CEC4B4783AB6424938D47BBE9" then --hash for VC/NSO EU/US and JP Versions
			if memory.read_u8(0x00529,"WRAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x00529,"WRAM")
		elseif name == "Wario's Woods (USA)" or name == "Wario's Woods (Europe)" then
			if memory.read_u8(0x0120CC,"WRAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x0120CC,"WRAM")
		elseif name == "Donkey Kong Country 2 - Diddy's Kong Quest (USA) (En,Fr)" or name == "Donkey Kong Country 2 - Diddy's Kong Quest (USA) (En,Fr) (Rev 1)" or name == "Donkey Kong Country 2 - Diddy's Kong Quest (Germany) (En,De)" or name == "Donkey Kong Country 2 - Diddy's Kong Quest (Germany) (En,De) (Rev 1)" or name == "Donkey Kong Country 2 - Diddy's Kong Quest (Europe) (En,Fr) (Rev 1)" or name == "Super Donkey Kong 2 - Dixie & Diddy (Japan)" or name == "Super Donkey Kong 2 - Dixie & Diddy (Japan) (Rev 1)" or hash == "89DFA86D7A393FFB1B08438AB3D024C31D741E24" or hash == "FAA92FB3A92A8BBDBD962EE3CDB560A9FD8B614D" or hash == "50B44869EECFEBDA7602FA58BB4DB5CA44B0FAC2" or hash == "296F52379DE1967DF789FCD15C209F1AE3216DF1" or hash == "12EF9B67484DAFF20ABBBFB3278C0036B4D3AAB5" then --hashes (in order): NSO, VC US, VC DE, VC EU, VC JP
			if memory.read_u8(0x0008BC,"WRAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x0008BC,"WRAM")
		elseif name == "Donkey Kong Country 3 - Dixie Kong's Double Trouble! (USA) (En,Fr)" or name == "Donkey Kong Country 3 - Dixie Kong's Double Trouble! (Europe) (En,Fr,De)" or name == "Super Donkey Kong 3 - Nazo no Krems-tou (Japan)" or name == "Super Donkey Kong 3 - Nazo no Krems-tou (Japan) (Rev 1)" then
			if memory.read_u8(0x0005D3,"WRAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x008BC,"WRAM")
		elseif name == "Yoshi's Cookie (USA)" or name == "Yoshi's Cookie (Europe)" or name == "Yoshi no Cookie (Japan)" then
			if memory.read_u8(0x00614E,"WRAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x00614E,"WRAM")
		elseif name == "Dr. Mario (Japan) (NP)" then
			if memory.read_u8(0x000340,"WRAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x000340,"WRAM")
		end
	-- N64 Games
	elseif sysid == "N64" then
		if name == "Super Mario 64 (USA)" or name == "Super Mario 64 (Europe) (En,Fr,De)" or name == "Super Mario 64 (Japan) (Rev A) (Shindou Edition)" or name == "Super Mario 64 (Japan)" or hash == "37F5ED5394D885DE2AFF705074BD76DDC95D3CC9" then --hash for LodgeNet version
			if memory.read_u8(0x33B219,"RDRAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x33B219,"RDRAM")
		elseif name == "Yoshi's Story (USA) (En,Ja)" or name == "Yoshi Story (Japan)" or name == "Yoshi's Story (Europe) (En,Fr,De)" or hash == "F489A3CDEF729CD1ADE23996096FE88501E75079" then -- hash for LodgeNet version
			if memory.read_u8(0x0F895F,"RDRAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x0F895F,"RDRAM")
		end
	-- Game Boy & Game Boy Colour Games
	elseif sysid == "GB" or sysid == "SGB" or sysid == "GBC" then
		if name == "Super Mario Land (World)" or name == "Super Mario Land (World) (Rev A)" then
			if memory.read_u8(0x7A,"HRAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x7A,"HRAM")
		elseif name == "Dr. Mario (World)" or name == "Dr. Mario (World) (Rev A)" then
			if memory.read_u8(0x43,"HRAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x43,"HRAM")
		elseif name == "Yoshi (USA)" or name == "Yossy no Tamago (Japan)" or name == "Mario & Yoshi (Europe)" then
			if memory.read_u8(0x06D3,"WRAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x06D3,"WRAM")
		elseif name == "Super Mario Land 2 - 6 Golden Coins (USA, Europe)" or name == "Super Mario Land 2 - 6 Golden Coins (USA, Europe) (Rev A)" or name == "Super Mario Land 2 - 6 Golden Coins (USA, Europe) (Rev B)" or name == "Super Mario Land 2 - 6-tsu no Kinka (Japan)" or name == "Super Mario Land 2 - 6-tsu no Kinka (Japan) (Rev B)" or hash == "F536D4D76A22668B8672BB291E4C738ABC55D759" then --hash for Japanese RevA
			if memory.read_u8(0x0262,"CartRAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x0262,"CartRAM")
		elseif name == "Yoshi's Cookie (USA, Europe)" or name == "Yossy no Cookie (Japan)" then
			if memory.read_u8(0x013B,"WRAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x013B,"WRAM")
		elseif name == "Wario Land - Super Mario Land 3 (World)" then
			if memory.read_u8(0x097B,"CartRAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x097B,"CartRAM")
		elseif name == "Donkey Kong Land (USA, Europe)" or name == "Super Donkey Kong GB (Japan)" then
			if memory.read_u8(0x076B,"WRAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x076B,"WRAM")
		elseif name == "Donkey Kong Land 2 (USA, Europe)" or name == "Donkey Kong Land (Japan)" or name == "Donkey Kong Land III (USA, Europe)" or name == "Donkey Kong Land III (USA, Europe) (Rev A)" then
			if memory.read_u8(0x2B,"HRAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x2B,"HRAM")
		elseif name == "Wario Land II (USA, Europe)" or name == "Wario Land 2 (Japan)" then
			if memory.read_u8(0x050F,"WRAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x050F,"WRAM")
		elseif name == "Super Mario Bros. Deluxe (USA, Europe)" or name == "Super Mario Bros. Deluxe (USA, Europe) (Rev B)" or name == "Super Mario Bros. Deluxe (Japan) (NP)" or name == "Super Mario Bros. Deluxe (USA, Europe) (Rev A)" or hash == "E61D564E1FF19EB4B7C62A6CD96214F2BCA4B01D" then -- hash for Rev 1 JP
			if memory.read_u8(0x01F2,"WRAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x01F2,"WRAM")
		elseif name == "Donkey Kong GB - Dinky Kong & Dixie Kong (Japan)" then
			if memory.read_u8(0x2A,"HRAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x2A,"HRAM")
		end
	-- Virtual Boy Games
	elseif sysid == "VB" then
		if hash == "7556A778B60490BDB81774BCBAA7413FC84CB985" then -- Mario Clash
			if memory.read_u8(0x9A74,"WRAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x9A74,"WRAM")
		elseif hash == "274C328FBD904F20E69172AB826BF8F94CED1BDB" then -- VB Wario Land
			if memory.read_u8(0x87A8,"WRAM") > oldring then
				ring_swap()
				return
			end
			oldring = memory.read_u8(0x87A8,"WRAM")
		end
	end
end

return plugin
