local plugin = {}

plugin.name = "Sonic Ring Shuffler"
plugin.author = "adrian_squared"
plugin.settings = {}

plugin.description =
[[
    This plugin is designed to switch between games once the player obtains a ring.
]]

oldring = 0

function plugin.on_game_load(data)
	name = gameinfo.getromname()
	-- console.writeline(gameinfo.getromname())
end
-- redundant fonction in case I need to add smth later (maybe fix the sound turning off issue ?)
function ring_swap()
	swap_game()
end

-- called each frame
function plugin.on_frame(data, settings)
	next_swap_time = config.frame_count+1
	if name == "Sonic The Hedgehog (W) (REV00) [!]" or name == "Sonic The Hedgehog 3 (U) [!]" or name == "Sonic The Hedgehog 2 (W) (REV00) [!]" or name == "Sonic and Knuckles (W) [!]" then
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
	elseif name == "Sonic CD (USA)" then
		if memory.read_u16_be(0x1512,"68K RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0x1512,"68K RAM")
	elseif name == "Dr. Robotnik's Mean Bean Machine (U) [!]" then
		if memory.read_u16_be(0xE00C,"68K RAM") > oldring+39 then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0xE00C,"68K RAM")
	elseif name == "Sonic Spinball (U) [!]" then
		if memory.read_u8(0x57A0,"68K RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u8(0x57A0,"68K RAM")
	elseif name == "Sonic and Knuckles (W) [!]" then
		if memory.read_u8(0x57A0,"68K RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u8(0x57A0,"68K RAM")
	elseif name == "Knuckles' Chaotix (32X) (JU) [!]" then
		if memory.read_u16_be(0xE008,"68K RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0xE008,"68K RAM")
	elseif name == "Sonic 3D Blast (UE) [!]" then
		if memory.read_u16_be(0x0A5A,"68K RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0x0A5A,"68K RAM")
	elseif name == "Sonic and Knuckles & Sonic 1 (W) [!]" then
		if memory.read_u16_be(0xE442,"68K RAM") < oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0xE442,"68K RAM")
	elseif name == "Sonic The Hedgehog (UE)" then
		if memory.read_u8(0x12AA,"Main RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u8(0x12AA,"Main RAM")
	end
end

return plugin
