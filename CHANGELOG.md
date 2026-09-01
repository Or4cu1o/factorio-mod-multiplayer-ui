# Changelog

## 0.3.0
- fix crash on load with Factorio 2.0: require the stdlib fork under its actual mod name (`__kry_stdlib__` instead of `__stdlib__`)
- fix armor icon detection for the Factorio 2.0 `LuaInventory.get_contents()` array format
- guard against `player.permission_group` being nil when "show group" is enabled
- Space Age: group the player list by location (space platforms first, then Nauvis, then the other planets in the game's own order, modded planets included) so the "nearest first" sort only ranks by distance within the same surface
- measure distance from the player's physical position/surface, so remote view no longer skews the distance readout or the sort
- add `space-age` as an optional dependency so the mod still loads with or without the expansion
- clamp the "Maximum number of players" setting to at least 1 and raise its default from 5 to 8
- stop the panel from stretching across the left side of the screen: the frame and its tables now hug their content (sizing done in style prototypes, so the game's "UI scale" setting is still respected)
- always clip player names (to 12 characters, plus an ellipsis) so one long nick can no longer widen the panel
- new per-player "Compact mode" setting: tightens the layout and clips names harder still (to 6 characters), for when the panel still gets in the way
- point users to the `slondo-ptbr` pack for the pt-BR locale from the description (not as a dependency: it already load-orders after this mod, so an optional dependency back would be a cycle)

## 0.2.3
- depend on `kry_stdlib` instead of the unmaintained `stdlib` (mod-portal-only release; the `control.lua` require path was missed)

## 0.2.1
- change thumbnail

## 0.2.0
- startup setting for debug log

## 0.1.7
- add thumbnail only

## 0.1.6
- base mod, first working version