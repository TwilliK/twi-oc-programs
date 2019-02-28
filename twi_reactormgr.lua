--- Twill's Simple Extreme Reactors Control v0.1
-- A simple script to run a single extreme reactor based upon induction cell fill percentage

---- Variables ----
local comp = require("component")
local keyboard = require("keyboard")
local gpu = comp.gpu
local reactor = comp.br_reactor
local cell = comp.induction_matrix

J_to_RF_factor = 0.4 -- Induction Matrix reports in Mekanism Joules, multiply by this to get RF values
cell_cap_pct = 0.9 -- when to shutoff reactor
cell_floor_pct = 0.4 -- when to kick on reactor

---- Setup Initial State ----

reactor_enabled = reactor.getActive()
control_rod_level = reactor.getControlRodsLevels()[0] -- this script adjusts all rods simultaniously

last_cell_level = cell.getEnergy()

---- Support Functions ----

function comma_value(amount)
  local formatted = amount
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

function draw_box(pos_x, pos_y, width, height, title, color, background)
	gpu.setForeground(color)
	gpu.setBackground(background)
	local title_len = string.len(title)
	if math.fmod(title_len,2) == 1 then
		title = title .. "═"
		title_len = title_len + 1
	end
	if math.fmod(width, 2) == 0 then
		local bar_adjust = (width - (2 + title_len))/2
		local workingstr = "╔" .. string.rep("═",bar_adjust) .. title .. string.rep("═",bar_adjust) .. "╗"
		gpu.set(pos_x, pos_y, workingstr)
	elseif math.fmod(width, 2) == 1 then
		local bar_adjust = math.ceil((width - (2 + title_len))/2)
		local workingstr = "╔" .. string.rep("═",bar_adjust) .. title .. string.rep("═",bar_adjust - 1) .. "╗"
		gpu.set(pos_x, pos_y, workingstr)
	end
	--local workingstr = "╔" .. string.rep("═",(width - 2)) .. "╗"
	--gpu.set(pos_x, pos_y, workingstr)
	gpu.set(pos_x, pos_y + 1, string.rep("║",(height - 2)), true)
	gpu.set(pos_x + width - 1, pos_y + 1, string.rep("║",(height - 2)), true)
	workingstr = "╚" .. string.rep("═",(width - 2)) .. "╝"
	gpu.set(pos_x, pos_y + height - 1, workingstr)
end

-------------------
---- Main Loop  ---
-------------------

while true do
	local cell_level = cell.getEnergy() -- no convertion yet to save cycles?
	if cell_level > (cell.getMaxEnergy() * cell_cap_pct) then
		reactor.setActive(false)
		reactor_enabled = false
	elseif cell_level < (cell.getMaxEnergy() * cell_floor_pct) and reactor_enabled == false then
		reactor.setActive(true)
		reactor_enabled = true
	elseif cell_level < last_cell_level and reactor_enabled == true and control_rod_level > 0 then
		control_rod_level = control_rod_level - 1
		reactor.setAllControlRodLevels(control_rod_level - 1)
	end
	last_cell_level = cell_level -- still not converting because we really only need to for display I guess?
	
	io.write("cell level " .. comma_value(tostring(cell_level * J_to_RF_factor)) .. " RF \n")
	draw_box(1, 1, 20, 20, "abbcce", 0xffffff, 0x000000)
	os.sleep(2)
end
