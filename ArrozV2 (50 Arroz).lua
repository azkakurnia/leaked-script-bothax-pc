Settings = {
  DropPos = {
      32, 11 -- ( X, Y ) --
    },
  Ingredient = {
    Take = false, -- ( Auto take ingredienf ) --
    BuyPack = false, -- ( Auto Buy Cooking Pack ) --
    Make = true, -- ( Auto make ingredient ) --
  }
}

World = GetWorld().name
posx = GetLocal().pos.x // 32
posy = GetLocal().pos.y // 32

trsh = {  4572, 956, 4562, 4564, 4578, 4586, 874, 868, 4766, 4676, 4666, 822, 4582, 4618 }
ingredients = { 4602, 962, 3472, 4570, 4568, 4588 } 

local ovenid = {
    [952] = true,
    [4498] = true,
    [4618] = true,
    [4620] = true,
    [8586] = true,
    [8938] = true,
    [10820] = true
}

function Drop(id)
  SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|" .. id .. "|\nitem_count|250")
end

function drop(id)
  SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|" .. id .. "|\nitem_count|40")
end


function trash(id)
  SendPacket(2, "action|dialog_return\ndialog_name|trash\nitem_trash|" .. id .. "|\nitem_count|" .. inv(id) .. "\n")
end


function Open(x, y, z, t)
  SendPacket(2, "action|dialog_return\ndialog_name|homeoven_edit\nx|"..x.."|\ny|"..y.."|\ncookthis|"..z.."|\nbuttonClicked|"..t)
end

function Raw(t, s, v, x, y)
		pkt = {
  		type = t,
    state = s,
    value = v,
    px = x, 
    py = y,
    x = x * 32,
    y = y * 32
  }
  SendPacketRaw(false, pkt)
end

function GetGrinder()
  for _, tile in pairs(GetTiles()) do
    if tile.fg == 4582 then
      move(tile.x, tile.y)
      Sleep(300)
    end
  end
end

function GetCutting()
  for _, tile in pairs(GetTiles()) do
    if tile.fg == 3470 then
      move(tile.x - 1, tile.y)
      Sleep(300)
    end
  end
end

function find(id)
  SendPacket(2, "action|dialog_return\ndialog_name|item_search\n" .. id .. "|1")
  Sleep(300)
end

function GrindItem(id, amount)
  SendPacket(2, "action|dialog_return\ndialog_name|grinder\nx|" .. math.floor(GetLocal().pos.x / 32) .. "|\ny|" .. math.floor(GetLocal().pos.y / 32) .. "|\nitemID|" .. id .. "|\namount|" .. amount)
  Sleep(300)
end

function GetOven()
  local found = {}
  local pos = {GetLocal().pos.x // 32, GetLocal().pos.y // 32}
  for y = pos[2] - 4, pos[2] + 4 do
    for x = pos[1] - 4, pos[1] + 4 do
      local tile = GetTile(x, y)
      if tile and ovenid[tile.fg] then
        table.insert(found, {x, y})
        if #found >= 50 then
          return found
        end
      end
    end
  end
  return found
end

function inv(id)
  local count = 0
  for _, itm in pairs(GetInventory()) do
    if itm.id == id then
      count = count + itm.amount
    end
  end
  return count
end

function move(tx, ty)
  local function dir(a, b) return (b - a) / math.max(1, math.abs(b - a)) end
  local function ease(t) return t * t * (3 - 2 * t) end  

  while true do
    local x, y = GetLocal().pos.x // 32, GetLocal().pos.y // 32
    if x == tx and y == ty then break end

    local nx, ny = x + dir(x, tx), y + dir(y, ty)
    FindPath(nx, ny)
    Sleep(30 + ease(math.abs(nx - tx + ny - ty)) * 20)
  end
end

function BuySpray()
  repeat
    SendPacket(2,"action|buy\nitem|buy_deluxegspray")
    Sleep(200)
  until inv(1778) >= 100
end

function Grind()
  repeat
    if inv(4584) >= 200 then
      GrindItem(4584, 2)
    else
      find(4584)
    end
    if inv(4566) >= 200 then
      GrindItem(4566, 2)
    else
      find(4566)
    end
  until inv(4568) >= 100 and inv(4570) >= 100
  return
end

function Splice()
  repeat
    if inv(455) < 10 then
      find(455)
    end
    if inv(1105) < 10 then
      find(1105)
    end
    Raw(3, 0, 455, math.floor(GetLocal().pos.x / 32), math.floor(GetLocal().pos.y / 32))
    Sleep(200)
    Raw(3, 0, 1105, math.floor(GetLocal().pos.x / 32), math.floor(GetLocal().pos.y / 32))
    Sleep(200)
    Raw(3, 0, 1778, math.floor(GetLocal().pos.x / 32), math.floor(GetLocal().pos.y / 32))
    Sleep(200)
    Raw(3, 0, 1778, math.floor(GetLocal().pos.x / 32), math.floor(GetLocal().pos.y / 32))
    Sleep(200)
    Raw(3, 0, 18, math.floor(GetLocal().pos.x / 32), math.floor(GetLocal().pos.y / 32))
    Sleep(200)
  until inv(4602) >= 50
end

function Cut()
  if inv(872) < 10 then
    find(872)
  end
  Drop(872)
  Sleep(700)
  Raw(3, 0, 18, math.floor(GetLocal().pos.x / 32 + 1), math.floor(GetLocal().pos.y / 32))
  Sleep(700)
  move(math.floor(GetLocal().pos.x / 32 + 1), math.floor(GetLocal().pos.y / 32))
end

function MakeIngredient()
  if inv(962) < 50 then
    GetDropped()
  end
  if inv(4570) < 100 or inv(4568) < 100 then
    GetGrinder()
    Sleep(300)
    Grind()
    Sleep(200)
  end
  if inv(1778) < 100 then
    BuySpray()
    Sleep(200)
  end
  if inv(4602) < 50 then
    GetCutting()
    Sleep(300)
    Splice()
    Sleep(200)
  end
  if inv(4588) < 50 then
    GetCutting()
    Sleep(300)
    Cut()
    Sleep(200)
  end
return
end

function BuyPack()
  for _, tr in pairs(trsh) do
    local co = inv(tr)
    if co > 100 then
      trash(tr)
      Sleep(200)
      return BuyPack()
    end
  end
  for _, ing in pairs(ingredients) do
    local co = inv(ing)
    if co < 60 then
      SendPacket(2, "action|buy\nitem|buy_cookingpack")
      Sleep(100)
      return BuyPack()
    end
    if co > 230 then
      move(posx, posy -1)
      drop(ing)
      Sleep(300)
    end
  end
end

function GetDropped()
  for _, id in pairs(ingredients) do
    if inv(id) < 100 then
      for _, obj in pairs(GetObjectList()) do
        if obj.id == id then
          move(obj.pos.x // 32, obj.pos.y // 32)
          Sleep(300)
          return GetDropped()
        end
      end
    end
  end
end
 
function DropArroz()
  for attempts = 1, 24 do
    if inv(4604) >= 250 then
      Log("Dropping Arroz Attempt: ["..attempts.." / 24]")
      Drop(4604)
      Sleep(400)
    else
      return
    end
  end
  if inv(4604) >= 250 then
    Settings.DropPos[2] = Settings.DropPos[2] - 1
    move(Settings.DropPos[1], Settings.DropPos[2])
    Sleep(400)
    Drop(4604)
    return
  end
end

Oven = GetOven()

function PlaceIngredient(id, delay)
  for _, ov in pairs(Oven) do
    if GetWorld() == nil or GetWorld().name ~= World then
      return
    else
      Raw(3, 0, id, ov[1], ov[2])
      Sleep(delay or 300)
    end
  end
end

function Place2Ingredient(id, id2, delay)
  for _, ov in pairs(Oven) do
    if GetWorld() == nil or GetWorld().name ~= World then
      return
    else
      Raw(3, 0, id, ov[1], ov[2])
      Sleep(delay or 150)
      Raw(3, 0, id2, ov[1], ov[2])
      Sleep(300)
    end
  end
end

function Rice()
  for _, ov in pairs(Oven) do
    if GetWorld() == nil or GetWorld().name ~= World then
      return
    else
      Open(ov[1], ov[2], 3472, "low")
      Sleep(300)
    end
  end
end

function Main()
  if GetWorld() == nil or GetWorld().name ~= World then
    return
  else
    Rice()
    PlaceIngredient(4568, 300)
    Sleep(((33700-(#Oven*300))/1) - (#Oven*300))
    
    Place2Ingredient(4602, 4588, 150)
    PlaceIngredient(4570, 300)
    Sleep(((36300-(#Oven*300))/1) - (#Oven*300))

    PlaceIngredient(962, 300)
    PlaceIngredient(4570, 300)
    Sleep(((30000-(#Oven*300))/1) - (#Oven*300))
    
    PlaceIngredient(18, 300)
  end
end

function Log(x)
		LogToConsole("`0[`cAwZka`0] [`cSTATUS`0] "..x)
end

function Join(w)
		SendPacket(3, "action|join_request\nname|".. w .."|\ninvitedWorld|0")
end
dc = false

while true do
  Sleep(3000)
  if GetWorld() == nil or GetWorld().name ~= World then
    Log("Disconnected!? Trying to reconnect..")
    Join(World)
    Sleep(5000)
    dc = true
  end
  if inv(4604) >= 250 then
    move(Settings.DropPos[1], Settings.DropPos[2])
    Sleep(500)
    DropArroz()
    Sleep(500)
  end
  for _, ing in pairs(ingredients) do
    local co = inv(ing)
    if co < 100 and Settings.Ingredient.Take then
      GetDropped()
    elseif co < 60 and Settings.Ingredient.BuyPack then      
      BuyPack()
    elseif co < 100 and Settings.Ingredient.Make then
      MakeIngredient()
    end
    if inv(3472) < 50 then
      find(3472)
    end
  end
  if dc then
    PlaceIngredient(18, 300)
    Sleep(500)
    dc = false
  end
  Sleep(500)
  move(posx, posy)
  Sleep(450)
  Main()
end