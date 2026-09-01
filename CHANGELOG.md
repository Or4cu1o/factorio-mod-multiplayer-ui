# Changelog

## 0.2.4
- fix crash on load with Factorio 2.0: require the stdlib fork under its actual mod name (`__kry_stdlib__` instead of `__stdlib__`)
- fix armor icon detection for the Factorio 2.0 `LuaInventory.get_contents()` array format
- guard against `player.permission_group` being nil when "show group" is enabled

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