----------------------------------------------------------
------- Twill's Applied Energistics 2 Auto-Supplier ------
----------------------------------------------------------

local comp = require("component")
local gpu = comp.gpu
local ae2 = comp.me_controller

-- the items array tracks the list of items you want to display/keep in stock
-- each item needs to have a filter that will be used to pull it's stock level
--------	and crafting recipe via the AE2 api
items = {
	{filter={name="minecraft:stick"},
		nicename="Stick", stock_value=0, crafter=nil, craftStatus=nil},
	{filter={name="appliedenergistics2:material",damage=17},
		nicename="Engineering Circuit", stock_value=64, crafter=nil, craftStatus=nil},
	{filter={name="appliedenergistics2:material",damage=24},
		nicename="Engineering Processor", stock_value=0, crafter=nil, craftStatus=nil},
	{filter={name="appliedenergistics2:material",damage=18},
		nicename="Logic Circuit", stock_value=0, crafter=nil, craftStatus=nil},
	{filter={name="appliedenergistics2:material",damage=22},
		nicename="Logic Processor", stock_value=0, crafter=nil, craftStatus=nil},
	{filter={name="appliedenergistics2:material",damage=10},
		nicename="Pure Certus Quartz", stock_value=0, crafter=nil, craftStatus=nil},
	{filter={name="appliedenergistics2:material",damage=16},
		nicename="Calc Circuit", stock_value=0, crafter=nil, craftStatus=nil},
	{filter={name="appliedenergistics2:material",damage=23},
		nicename="Calc Processor", stock_value=0, crafter=nil, craftStatus=nil},
}

-- how long to wait between the end of one check cycle and the beginning of the next
cycle_wait = 60 --seconds

--------------------------
---- Helper Functions ----
--------------------------

---------------------------
---- Drawing Functions ----
---------------------------
function frameDraw()
	gpu.setViewport(128, 40)
	gpu.set(1,1, "╔" .. string.rep("═",40) .. "╤" .. string.rep("═",40) .. "╤" .. string.rep("═",40) .. "╗")
	gpu.set(1,2, string.rep("║",38), true)
	gpu.set(42,2, string.rep("┃",38), true)
	gpu.set(83,2, string.rep("┃",38), true)
	gpu.set(124,2, string.rep("║",38), true)
	gpu.set(1,40, "╚" .. string.rep("═",40) .. "╧" .. string.rep("═",40) .. "╧" .. string.rep("═",40) .. "╝")
end

function itemDraw(index, item, stock, crafting)
	local maxLength = 40 -- configuration here
	local adjusted_index = index
	local col_index = 2
	while adjusted_index > 38 do
		adjusted_index = adjusted_index - 38
		col_index = col_index + 41
	end
	local output = item.nicename .. " x" .. stock
	if crafting == true then
		output = "[c]" .. output
	else
		output = "[x]" .. output
	end
	if string.len(output) > 40 then
		output = output .. string.rep(" ", 40-string.len(output))
	end
	gpu.set(col_index, adjusted_index+1, output)
end

-------------------
---- Main Loop ----
-------------------
frameDraw()

while true do
	for key, item in pairs(items) do
		local i_info = ae2.getItemsInNetwork(item.filter)[1]
		if i_info.size == nil then
			if item.stock_value ~= 0 and item.craftStatus == nil then
				if item.crafter == nil then
					item.crafter = ae2.getCraftables(item.filter)[1]
				end
				item.craftStatus = item.crafter.request(item.stock_value)
			end
			if item.craftStatus.isDone() then
				item.craftStatus = nil
			end
			if item.craftStatus == nil then
				itemDraw(key, item, 0, false)
			else
				itemDraw(key, item, 0, true)
			end
		else
			if item.stock_value ~= 0 and item.craftStatus == nil then
				if item.crafter == nil then
					item.crafter = ae2.getCraftables(item.filter)[1]
				end
				item.craftStatus = item.crafter.request(item.stock_value - i_info.size)
			end
			if item.craftStatus.isDone() then
				item.craftStatus = nil
			end
			if item.craftStatus == nil then
				itemDraw(key, item, i_info.size, false)
			else
				itemDraw(key, item, i_info.size, true)
			end
		end
	end
	os.sleep(cycle_wait)
end