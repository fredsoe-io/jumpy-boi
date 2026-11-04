  shader_type canvas_item;

  uniform bool active = false;
  uniform float brightness : hint_range(0.0, 1.0) = 0.5;
  uniform float saturation : hint_range(0.0, 1.0) = 0.3;

  void fragment() {
          if (!active) {
                  float grey = dot(COLOR.rgb, vec3(0.299, 0.587, 0.114));
                  COLOR.rgb = mix(vec3(grey), COLOR.rgb, saturation) * brightness;
          }
  }