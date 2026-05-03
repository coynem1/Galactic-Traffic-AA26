shader_type spatial;

instance uniform vec4 albedo_color : source_color;
instance uniform float roughness : hint_range(0.0, 1.0) = 0.3;
instance uniform float specular : hint_range(0.0, 1.0) = 0.8;

void fragment() {
    ALBEDO = albedo_color.rgb;
	ROUGHNESS = roughness;
    SPECULAR = specular;
}
