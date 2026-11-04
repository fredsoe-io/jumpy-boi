class_name TouchControls
extends CanvasLayer
## On-screen left / right / jump buttons for touch devices (iPad, phones).
##
## Each TouchScreenButton feeds one of the existing input actions (ui_left,
## ui_right, ui_jump), so the player code never knows the buttons exist. The
## layer hides itself when there is no touchscreen, so desktop players never
## see it. It processes while paused so the jump button can restart after a win.

const MARGIN := 24.0
const GAP := 24.0

@onready var _left: TouchScreenButton = $LeftButton
@onready var _right: TouchScreenButton = $RightButton
@onready var _jump: TouchScreenButton = $JumpButton


func _ready() -> void:
	visible = DisplayServer.is_touchscreen_available()
	get_viewport().size_changed.connect(_layout)
	_layout()


## Pins the movement buttons to the bottom-left corner and jump to the
## bottom-right, whatever the viewport size. The stretch aspect is "expand",
## so a 4:3 iPad gets a taller viewport than a 16:9 monitor.
func _layout() -> void:
	var size := get_viewport().get_visible_rect().size
	var left_size := _button_size(_left)
	var y := size.y - MARGIN - left_size.y
	_left.position = Vector2(MARGIN, y)
	_right.position = Vector2(MARGIN + left_size.x + GAP, y)
	_jump.position = Vector2(size.x - MARGIN - _button_size(_jump).x, y)


static func _button_size(button: TouchScreenButton) -> Vector2:
	return button.texture_normal.get_size() * button.scale
