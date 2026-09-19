local ARX, ARY, ARW, ARH = 20, 36, 280, 164
local SIZE = 28
local MINX, MAXX = ARX + 2, ARX + ARW - SIZE - 2
local MINY, MAXY = ARY + 2, ARY + ARH - SIZE - 2
local GRID = { {1, 2}, {6, 3}, {5, 4} }
local G = 0.00130

local ball
local bx, by, vx, vy = 0, 0, 0, 0
local flash_until = 0
local sensor_missing = false
local next_update = 0
local status_label

local function led_index()
  local cx = bx + SIZE / 2
  local cy = by + SIZE / 2
  local col = cx < ARX + ARW / 2 and 1 or 2
  local row
  if cy < ARY + ARH / 3 then row = 1
  elseif cy < ARY + 2 * ARH / 3 then row = 2
  else row = 3 end
  return GRID[row][col]
end

local function show_led(r, g, b)
  badge.led.clear()
  badge.led.set(led_index(), r, g, b)
  badge.led.show()
end

function on_enter(root)
  badge.sys.wake_lock(true)
  bx = ARX + (ARW - SIZE) / 2
  by = ARY + (ARH - SIZE) / 2

  local title = badge.ui.label(root, "Gravity Ball")
  title:align("top_mid", 0, 10)

  local frame = badge.ui.box(root, ARW, ARH)
  frame:set_pos(ARX, ARY)
  frame:style({ bg_color = 0x1a1f26, border_color = 0x777777,
                border_width = 2, radius = 6 })

  ball = badge.ui.box(root, SIZE, SIZE)
  ball:style({ bg_color = 0x3cc8ff, radius = 14 })

  status_label = badge.ui.label(root, "x --   y --")
  status_label:style({ text_font = 14 })
  status_label:align("bottom_mid", 0, -34)
  local hint = badge.ui.label(root,
    "Tilt to roll   Start center   HOME exit")
  hint:style({ text_font = 14, text_align = "center" })
  hint:align("bottom_mid", 0, -14)

  ball:set_pos(math.floor(bx), math.floor(by))
  show_led(60, 200, 255)
end

function on_tick()
  local now = badge.sys.ms()
  local x, y = badge.sensor.accel()
  if x then
    if sensor_missing then
      sensor_missing = false
      status_label:set_text("x --   y --")
    end
    if now >= next_update then
      next_update = now + 100
      status_label:set_text(string.format(
        "x %d mg   y %d mg", math.floor(x), math.floor(y)))
    end
    local ax = -x * G
    local ay = y * G
    vx = (vx + ax) * 0.985
    vy = (vy + ay) * 0.985
    local MAXV = 8
    vx = math.max(-MAXV, math.min(MAXV, vx))
    vy = math.max(-MAXV, math.min(MAXV, vy))
    bx = bx + vx
    by = by + vy
    if bx < MINX then bx = MINX; vx = math.abs(vx) * 0.6; flash_until = now + 120 end
    if bx > MAXX then bx = MAXX; vx = -math.abs(vx) * 0.6; flash_until = now + 120 end
    if by < MINY then by = MINY; vy = math.abs(vy) * 0.6; flash_until = now + 120 end
    if by > MAXY then by = MAXY; vy = -math.abs(vy) * 0.6; flash_until = now + 120 end
  elseif not sensor_missing then
    sensor_missing = true
    status_label:set_text("Accelerometer unavailable")
  end
  ball:set_pos(math.floor(bx), math.floor(by))
  if now < flash_until then
    show_led(255, 255, 255)
  else
    show_led(60, 200, 255)
  end
end

function on_button(button, kind)
  if kind == badge.input.KIND.PRESSED and button == badge.input.BUTTON.START then
    vx, vy = 0, 0
    bx = ARX + (ARW - SIZE) / 2
    by = ARY + (ARH - SIZE) / 2
  end
end

function on_exit()
  badge.led.clear()
  badge.led.show()
end
