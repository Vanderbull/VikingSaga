[gd_scene load_steps=3 format=3 uid="uid://moving_entity"]

[ext_resource type="Script" path="res://MovingEntity.gd" id="1"]
[ext_resource type="Texture2D" path="res://assets/entity_sprite.png" id="2"]

[node name="MovingEntity" type="Area2D"]
script = ExtResource("1")

[node name="Sprite2D" type="Sprite2D" parent="."]
texture = ExtResource("2")

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("CircleShape2D_abc")  # Add appropriate shape

[node name="Identity" type="Label" parent="."]
offset_left = -20.0
offset_top = -30.0
offset_right = 20.0
offset_bottom = -10.0
text = "Village"
horizontal_alignment = 1

[node name="AnimationPlayer" type="AnimationPlayer" parent="."]
libraries = {
    "": SubResource("AnimationLibrary_xyz")
}
