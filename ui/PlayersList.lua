local playerListCache = {}

-- Surface ordering buckets (lower renders first): space platforms, then Nauvis,
-- then every other planet in the game's own order, then any non-planet surface.
local GROUP_RANK_SPACE = 0
local GROUP_RANK_NAUVIS = 1
local GROUP_RANK_PLANET = 2
local GROUP_RANK_OTHER = 3

-- Player names are always clipped (plus an ellipsis) so one long nick can't
-- widen the panel; "compact mode" clips them much shorter still.
local NAME_LIMIT = 12
local NAME_LIMIT_COMPACT = 6

PlayersList = {
  classname = "MultiplayerPlayersList"
}

function PlayersList:new(player)
  local o
  if playerListCache[player.index] then
    o = playerListCache[player.index]
    o.player = player
  else
    o = {
      player = player,
      frame = nil,
    }
    playerListCache[player.index] = o
  end

  setmetatable(o, self)
  self.__index = self
  return o
end

-- Where a player physically is. `physical_surface`/`physical_position` stay put
-- while the player looks around in remote view; fall back to the plain controller
-- surface/position for controllers that have no physical body.
function PlayersList:surfaceOf(player)
  return player.physical_surface or player.surface
end

function PlayersList:positionOf(player)
  return player.physical_position or player.position
end

-- Describe the location bucket a player belongs to and how it sorts against the
-- other buckets. Works with or without the Space Age expansion, and understands
-- planets added by other mods (any surface with an associated LuaPlanet).
function PlayersList:locationGroup(player)
  local surface = self:surfaceOf(player)
  if not (surface and surface.valid) then
    return { index = -1, rank = GROUP_RANK_OTHER, order = "", name = "?", label = "?" }
  end

  local platform = surface.platform
  if platform then
    local name = platform.name or surface.name
    return {
      index = surface.index,
      rank = GROUP_RANK_SPACE,
      order = name,
      name = name,
      label = { "", "[space-age] ", name },
    }
  end

  local planet = surface.planet
  if planet then
    local proto = planet.prototype
    return {
      index = surface.index,
      rank = planet.name == "nauvis" and GROUP_RANK_NAUVIS or GROUP_RANK_PLANET,
      order = proto.order,
      name = planet.name,
      label = { "", "[planet=" .. planet.name .. "] ", proto.localised_name },
    }
  end

  return {
    index = surface.index,
    rank = GROUP_RANK_OTHER,
    order = surface.name,
    name = surface.name,
    label = surface.localised_name or surface.name,
  }
end

function PlayersList:getArmor(player)
  Debug:debug('getArmor', player, defines.inventory)
  if not defines.inventory then
    return nil
  end
  local inventory = player.get_inventory(defines.inventory.character_armor)
  if not inventory then
    return nil
  end

  -- Factorio 2.0: LuaInventory.get_contents() returns an array of
  -- { name = ..., count = ..., quality = ... } instead of a { [name] = count } map.
  local contents = inventory.get_contents()
  if contents[1] then
    return contents[1].name
  end

  return nil
end

function PlayersList:playerElement(listBox, player)
  local userSettings = settings.get_player_settings(self.player.index);
  local showDistance = userSettings["multiplayer-ui-show-distance"].value
  local showOnlineTime = userSettings["multiplayer-ui-show-online-time"].value
  local showAfkTime = userSettings["multiplayer-ui-show-afk-time"].value
  local showGroup = userSettings["multiplayer-ui-show-group"].value
  local showArmor = userSettings["multiplayer-ui-show-armor"].value
  local compact = userSettings["multiplayer-ui-compact-mode"].value

  -- Byte-indexed clip is fine here: it is a "safe length", not an exact one, and
  -- a name cut mid-codepoint only costs a replacement glyph, never a crash.
  local name = player.name
  local nameLimit = compact and NAME_LIMIT_COMPACT or NAME_LIMIT
  if #name > nameLimit then
    name = name:sub(1, nameLimit) .. '…'
  end

  local armor = self:getArmor(player)
  Debug:debug('armor', armor)
  local armorIcon = armor and '[item=' .. armor .. ']' or '[entity=character]'
  local avatar = player.ticks_to_respawn ~= nil and '[color=red]' .. Ticks.smartFormat(player.ticks_to_respawn) .. '[/color]' or armorIcon

  local playerUI = listBox.add { type = "table", column_count = 2, style = "MULTIPLAYER_UI_PLAYER_BOX" }
  if showArmor then
    playerUI.add { type = "label", caption = avatar, style = "MULTIPLAYER_UI_PLAYER_ARMOR_LABEL" }
  end

  -- Distance is only meaningful between players standing on the same surface;
  -- across planets/platforms the grouping already conveys where they are.
  local sameSurface = self:surfaceOf(player).index == self:surfaceOf(self.player).index
  local distance = (player.connected and sameSurface)
    and math.floor(Position.distance(self:positionOf(player), self:positionOf(self.player)))
    or 0
  local color = player.chat_color.r .. ',' .. player.chat_color.g .. ',' .. player.chat_color.b
  local playerDesc = playerUI.add { type = "table", column_count = 1, style = "MULTIPLAYER_UI_PLAYER_DESC" }
  local playerTopDesc = playerDesc.add { type = "table", column_count = 2, style = "MULTIPLAYER_UI_PLAYER_DESC" }

  playerTopDesc.add { type = "label", caption = ' [color=' .. color .. '][font=default-bold]' .. name .. '[/font][/color]' }
  if distance > 0 and showDistance then
    playerTopDesc.add { type = "label", caption = '([font=technology-slot-level-font]' .. distance .. 'm[/font])' }
  elseif not player.connected then
    playerTopDesc.add { type = "label", caption = '([font=technology-slot-level-font]offline[/font])' }
  end
  local playerBottomDesc = playerDesc.add { type = "table", column_count = 2, style = "MULTIPLAYER_UI_PLAYER_DESC" }
  if showGroup and player.permission_group then
    playerBottomDesc.add { type = "label", caption = '[font=technology-slot-level-font]' .. player.permission_group.name .. '[/font]' }
  end

  if showOnlineTime then
    playerBottomDesc.add { type = "label", caption = '[font=default-small]' .. Ticks.smartFormat(player.online_time) .. '[/font]' }
  end

  if showAfkTime and (player.afk_time > 60 * 60) then
    local afk = 'zzz ' .. Ticks.smartFormat(player.afk_time)
    playerBottomDesc.add { type = "label", caption = '[font=default-small]' .. afk .. '[/font]' }
  end
  -- splayerBottomDesc.add{ type = "label", caption='[font=technology-slot-level-font]' .. player.health .. ' life[/font]' }
end

function PlayersList:reset()
  if self.frame then
    self.frame.destroy()
  end

  if self.player.gui.left.multiplayer_ui then
    self.player.gui.left.multiplayer_ui.destroy()
  end

  local compact = settings.get_player_settings(self.player.index)["multiplayer-ui-compact-mode"].value
  self.frame = self.player.gui.left.add {
    type = "frame",
    name = "multiplayer_ui",
    direction = "vertical",
    style = compact and "MULTIPLAYER_UI_FRAME_COMPACT" or "MULTIPLAYER_UI_FRAME",
  }
end

function PlayersList:render()
  self:reset()

  local playerSettings = settings.get_player_settings(self.player.index)
  local showOffline = playerSettings["multiplayer-ui-show-offline"].value
  local maxPlayers = playerSettings["multiplayer-ui-max-players"].value
  local listBox = self.frame.add { type = "table", column_count = 1, style = "MULTIPLAYER_UI_LIST" }

  local localSurfaceIndex = self:surfaceOf(self.player).index

  -- Bucket every visible player by the surface their physical body is on.
  local groups = {}
  local groupOrder = {}
  for _, player in pairs(game.players) do
    if player.connected or showOffline then
      local info = self:locationGroup(player)
      local group = groups[info.index]
      if not group then
        group = { info = info, players = {} }
        groups[info.index] = group
        table.insert(groupOrder, info.index)
      end
      table.insert(group.players, player)
    end
  end

  -- Order the buckets: space platforms first, then Nauvis, then every other
  -- planet in the game's own order (modded planets included), then any
  -- remaining non-planet surface.
  table.sort(groupOrder, function(a, b)
    local ia, ib = groups[a].info, groups[b].info
    if ia.rank ~= ib.rank then
      return ia.rank < ib.rank
    end
    if ia.order ~= ib.order then
      return ia.order < ib.order
    end
    return ia.name < ib.name
  end)

  local showHeaders = #groupOrder > 1
  local rendered = 0
  local first = true

  for _, surfaceIndex in ipairs(groupOrder) do
    if rendered >= maxPlayers then
      break
    end
    local group = groups[surfaceIndex]
    local sameSurface = surfaceIndex == localSurfaceIndex

    -- Nearest first, but distance only means something on our own surface;
    -- players elsewhere keep the bucket order and fall back to a name sort.
    table.sort(group.players, function(playerA, playerB)
      if playerA.connected ~= playerB.connected then
        return playerA.connected
      end
      if sameSurface then
        local origin = self:positionOf(self.player)
        local distanceA = Position.distance(self:positionOf(playerA), origin)
        local distanceB = Position.distance(self:positionOf(playerB), origin)
        if distanceA ~= distanceB then
          return distanceA < distanceB
        end
      end
      return playerA.name:lower() < playerB.name:lower()
    end)

    if showHeaders then
      if not first then
        listBox.add { type = "line" }
      end
      listBox.add { type = "label", caption = { "", "[font=default-bold]", group.info.label, "[/font]" } }
      first = false
    end

    local firstInGroup = true
    for _, player in ipairs(group.players) do
      if rendered >= maxPlayers then
        break
      end
      if not first and not firstInGroup then
        listBox.add { type = "line" }
      end
      first = false
      firstInGroup = false
      self:playerElement(listBox, player)
      rendered = rendered + 1
    end
  end
end
