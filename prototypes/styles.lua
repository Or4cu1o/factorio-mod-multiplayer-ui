local default_gui = data.raw["gui-style"].default

-- All sizing is expressed with style-prototype fields (unscaled pixels), so the
-- engine keeps applying the player's "UI scale" setting. Nothing here is
-- stretchable: the panel hugs its content instead of spanning the whole left
-- side of the screen.

default_gui.MULTIPLAYER_UI_FRAME = {
    type = "frame_style",
    parent = "frame",
    padding = 4,
    horizontally_stretchable = "off",
    vertically_stretchable = "off",
    maximal_width = 300,
}

-- "Compact mode" fix: a hard clamp for when the panel is still in the way.
default_gui.MULTIPLAYER_UI_FRAME_COMPACT = {
    type = "frame_style",
    parent = "MULTIPLAYER_UI_FRAME",
    padding = 2,
    maximal_width = 170,
}

default_gui.MULTIPLAYER_UI_LIST = {
    type = "table_style",
    horizontal_spacing = 0,
    vertical_spacing = 4,
    horizontally_stretchable = "off",
}

default_gui.MULTIPLAYER_UI_PLAYER_BOX = {
    type = "table_style",
    horizontal_spacing = 6,
    vertical_spacing = 0,
    horizontally_stretchable = "off",
}

default_gui.MULTIPLAYER_UI_PLAYER_DESC = {
    type = "table_style",
    horizontal_spacing = 4,
    vertical_spacing = 0,
    horizontally_stretchable = "off",
}

default_gui.MULTIPLAYER_UI_PLAYER_ARMOR_LABEL = {
    type = "label_style",
    parent = "label",
    minimal_width = 24,
    horizontal_align = "center",
}
