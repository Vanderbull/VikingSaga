[gd_scene load_steps=8 format=3 uid="uid://b1a2s3e4m5o6"] ; New, more unique UID

; External Resources
[ext_resource type="Script" path="res://MovingEntity.gd" id="1_abcde"] ; More descriptive ID
[ext_resource type="Texture2D" path="res://assets/entity_sprite.png" id="2_fghij"] ; More descriptive ID
; Consider adding a specific font if "Village" needs styling beyond default
; [ext_resource type="FontFile" path="res://assets/fonts/my_cool_font.ttf" id="3_klmno"]

; Sub-Resources (defined inline)
[sub_resource type="CircleShape2D" id="CircleShape2D_x1y2z"]
radius = 16.0 ; Example radius, adjust based on your sprite size

[sub_resource type="Animation" id="Animation_RESET"]
resource_name = "RESET"
length = 0.001
tracks/0/type = "value"
tracks/0/imported = false
tracks/0/enabled = true
tracks/0/path = NodePath("Sprite2D:modulate")
tracks/0/interp = 1
tracks/0/loop_wrap = true
tracks/0/keys = {
"times": PackedFloat32Array(0),
"transitions": PackedFloat32Array(1),
"update": 0,
"values": [Color(1, 1, 1, 1)]
}
tracks/1/type = "value"
tracks/1/imported = false
tracks/1/enabled = true
tracks/1/path = NodePath("Sprite2D:scale")
tracks/1/interp = 1
tracks/1/loop_wrap = true
tracks/1/keys = {
"times": PackedFloat32Array(0),
"transitions": PackedFloat32Array(1),
"update": 0,
"values": [Vector2(1, 1)]
}
; Add other properties to reset if needed

[sub_resource type="Animation" id="Animation_idle_pulse"]
resource_name = "idle_pulse"
length = 1.0
loop_mode = 1 ; 0 = None, 1 = Forward, 2 = PingPong
tracks/0/type = "value"
tracks/0/imported = false
tracks/0/enabled = true
tracks/0/path = NodePath("Sprite2D:scale")
tracks/0/interp = 2 ; Interpolation_Cubic for smoother easing
tracks/0/loop_wrap = true
tracks/0/keys = {
"times": PackedFloat32Array(0, 0.5, 1),
"transitions": PackedFloat32Array(1, 1, 1),
"update": 0,
"values": [Vector2(1, 1), Vector2(1.05, 0.95), Vector2(1, 1)]
}
tracks/1/type = "value"
tracks/1/imported = false
tracks/1/enabled = true
tracks/1/path = NodePath("Sprite2D:position") ; Example: slight bobbing
tracks/1/interp = 2
tracks/1/loop_wrap = true
tracks/1/keys = {
"times": PackedFloat32Array(0, 0.25, 0.5, 0.75, 1),
"transitions": PackedFloat32Array(1, 1, 1, 1, 1),
"update": 0,
"values": [Vector2(0, 0), Vector2(0, -2), Vector2(0, 0), Vector2(0, 2), Vector2(0, 0)]
}

[sub_resource type="AnimationLibrary" id="AnimationLibrary_a1b2c"]
_data = {
"RESET": SubResource("Animation_RESET"),
"idle_pulse": SubResource("Animation_idle_pulse")
; Add other animations like "walk", "attack", "die" here
}

; Using a SystemFont for simplicity, replace with Theme or custom FontFile if needed
[sub_resource type="SystemFont" id="SystemFont_d3e4f"]
font_names = PackedStringArray("Arial", "Helvetica", "sans-serif") ; Fallback fonts
font_size = 12

; Scene Definition
[node name="MovingEntity" type="Area2D"]
script = ExtResource("1_abcde")
collision_layer = 2 ; Example: Belongs to "entities" layer
collision_mask = 1  ; Example: Detects "world" or "player" layer
monitoring = true   ; Explicitly set if it needs to detect bodies/areas entering/exiting
monitorable = true  ; Explicitly set if it needs to be detected by other areas
metadata/_edit_group_ = true ; Makes it easier to select children in the editor

[node name="Sprite2D" type="Sprite2D" parent="."]
texture = ExtResource("2_fghij")
; offset = Vector2(0, -8) ; Optional: If your sprite's origin isn't its visual center base

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("CircleShape2D_x1y2z")
; debug_color = Color(0, 0.6, 0.7, 0.42) ; Optional: For editor visibility

[node name="NameLabel" type="Label" parent="."] ; Renamed for clarity
anchors_preset = 8 ; Center
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -40.0
offset_top = -35.0  ; Adjusted to be above the typical sprite
offset_right = 40.0
offset_bottom = -15.0 ; Adjusted height
grow_horizontal = 2
grow_vertical = 2
text = "EntityName" ; Placeholder, ideally set from script
horizontal_alignment = 1 ; Center
vertical_alignment = 1   ; Center
theme_override_fonts/font = SubResource("SystemFont_d3e4f")
; theme_override_font_sizes/font_size = 12 ; Alternative if not using SystemFont resource for size
; theme_override_colors/font_color = Color(1, 1, 0, 1) ; Example: Yellow text

[node name="AnimationPlayer" type="AnimationPlayer" parent="."]
libraries = {
"": SubResource("AnimationLibrary_a1b2c")
}
autoplay = "idle_pulse" ; Autoplay the idle animation on scene start

; --- Potential Future Enhancements (as child nodes) ---
; [node name="StateMachine" type="Node" parent="."]
; script = ExtResource("res://StateMachine.gd") ; If you use a state machine pattern

; [node name="NavigationAgent2D" type="NavigationAgent2D" parent="."] ; For pathfinding
; path_desired_distance = 4.0
; target_desired_distance = 4.0
; path_max_distance = 20.0 ; Avoids recalculating path too far from current path

; [node name="HealthComponent" type="Node" parent="."]
; script = ExtResource("res://HealthComponent.gd") ; For managing health

; [node name="Timer" type="Timer" parent="." name="ActionCooldownTimer"] ; For timed actions
; wait_time = 1.0
; one_shot = true
