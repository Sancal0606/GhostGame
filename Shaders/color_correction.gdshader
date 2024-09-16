shader_type canvas_item;

uniform float contrast_value = 1;
uniform float brightness_value = 0;
uniform float saturation_value = 1;
uniform float gamma_value = 1;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec2 vignette_position = vec2(0.5, 0.5);
uniform float smoothness = 0.5;

void fragment() {
	vec3 source_col = texture(screen_texture, SCREEN_UV).rgb;
	float colorR = pow(source_col.r, 1.0 / 2.2);
	float colorG = pow(source_col.g, 1.0 / 2.2);
	float colorB = pow(source_col.b, 1.0 / 2.2);
	
	//contrast and bright
	vec3 linear_colors = vec3(colorR,colorG,colorB);
	vec3 valueTemp = vec3(0.5,0.5,0.5);
	vec3 contrast = contrast_value * (source_col - valueTemp) +  valueTemp + brightness_value;
	vec3 contrast_clamp = clamp(contrast,0,1);
	
	//saturation
	float gray_scale = dot(contrast_clamp,vec3(0.299,0.587,0.114));
	float saturated_r = mix(gray_scale, contrast_clamp.r, saturation_value);
	float saturated_g = mix(gray_scale, contrast_clamp.g, saturation_value);
	float saturated_b = mix(gray_scale, contrast_clamp.b, saturation_value);
	vec3 saturated = vec3(saturated_r,saturated_g,saturated_b);
	vec3 saturated_clamp = clamp(saturated,0,1);
	
	//gamma correction
	float gamma_r = pow(saturated_clamp.r,gamma_value);
	float gamma_g = pow(saturated_clamp.g,gamma_value);
	float gamma_b = pow(saturated_clamp.b,gamma_value);
	vec3 gamma = vec3(gamma_r,gamma_g,gamma_b);
	COLOR.rgb = gamma;
	
	//vignette
	float position = distance(vec2(UV.x, UV.y),vignette_position);
	float vignette = smoothstep(1.0,smoothness,position);
	vec3 vignette_vec = vec3(vignette);
	vec3 multiplyingColor = vignette_vec * gamma;
	COLOR.rgb = multiplyingColor;
}


