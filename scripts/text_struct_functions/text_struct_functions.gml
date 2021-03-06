
enum TB_EFFECT_ENTER_MOVE {
	FALL,
	RISE,
	NONE
}

enum TB_EFFECT_ENTER_ALPHA {
	FADE,
	NONE
}

enum TB_EFFECT_MOVE {
	OFFSET,
	WAVE,
	FLOAT,
	SHAKE,
	WSHAKE,
	NONE
}

enum TB_EFFECT_ALPHA {
	ALPHA,
	PULSE,
	BLINK,
	NONE
}

enum TB_EFFECT_COLOR {
	CHROMATIC,
	NONE
}

/// @desc Create textbox text struct.
/// @func JTT_Text(*text, *effects, *index)
function JTT_Text() constructor {
	text = (argument_count > 0) ? argument[0] : "";
	
	var has_fx = (argument_count > 1) ? true : false; // effects is another text struct
	var effects = (has_fx) ? argument[1] : undefined;
	
	font = (has_fx) ? effects.font : global.JTT_DEFAULT_FONT;
	
	/* We keep track of the index because it lets us easily offset different
	effects from other characters if necessary. The wave is a good example. */
	index = (argument_count > 2) ? argument[2] : 0;
	
	text_color = (has_fx) ? effects.text_color : global.JTT_DEFAULT_COLOR;
	draw_color = text_color;
	width = 0;
	height = 0;
	calculate_width = true; // marked when text changed
	calculate_height = true;
	draw_mod_x = 0;
	draw_mod_y = 0;
	effect_m = (has_fx) ? effects.effect_m : global.JTT_DEFAULT_EFFECT_MOVE;
	effect_a = (has_fx) ? effects.effect_a : global.JTT_DEFAULT_EFFECT_ALPHA;
	effect_c = (has_fx) ? effects.effect_c : global.JTT_DEFAULT_EFFECT_COLOR;
	effect_enter_m = (has_fx) ? effects.effect_enter_m : global.JTT_DEFAULT_EFFECT_ENTER_MOVE;
	effect_enter_a = (has_fx) ? effects.effect_enter_a : global.JTT_DEFAULT_EFFECT_ENTER_ALPHA;
	alpha = 1;
	
	chirp = (has_fx) ? effects.chirp : global.JTT_DEFAULT_TYPING_CHIRP;
	chirp_gain = (has_fx) ? effects.chirp_gain : global.JTT_DEFAULT_TYPING_CHIRP_GAIN;
	
	// other modifier values for entry effects
	draw_mod_entry_x = 0;
	draw_mod_entry_y = 0;
	alpha_entry = 1; // note that this value is multiplied with the end alpha, not replaces.
	
	/* This flag is set true by the typing code in the textbox. It determines whether the entry
	effects should be updated. */
	typed = false;
	
	/*
	Although we're calling these "text" structs, they have the ability to display sprites.
	If this value is filled, the struct will draw a sprite here instead of text. The width 
	and height functions have to account for the width/height of the sprite instead of the
	text if this variable is filled.
	*/
	sprite = undefined;
	sprite_scale = 1;
	
	// ENTRY EFFECTS
	// movement
	fall_magnitude = (has_fx) ? effects.fall_magnitude : global.JTT_DEFAULT_FALL_MAGNITUDE;
	fall_increment = (has_fx) ? effects.fall_increment : global.JTT_DEFAULT_FALL_INCREMENT;
	fall_offset = fall_magnitude;
	
	rise_magnitude = (has_fx) ? effects.rise_magnitude : global.JTT_DEFAULT_RISE_MAGNITUDE;
	rise_increment = (has_fx) ? effects.rise_increment : global.JTT_DEFAULT_RISE_INCREMENT;
	rise_offset = rise_magnitude;
	
	// alpha
	fade_alpha_start = (has_fx) ? effects.fade_alpha_start : global.JTT_DEFAULT_FADE_ALPHA_START;
	fade_alpha_end = (has_fx) ? effects.fade_alpha_end : global.JTT_DEFAULT_FADE_ALPHA_END;
	fade_alpha_increment = (has_fx) ? effects.fade_alpha_increment : global.JTT_DEFAULT_FADE_ALPHA_INCREMENT;
	fade_alpha = fade_alpha_start;
	
	// NORMAL EFFECTS
	// movement effects
	position_offset_x = (has_fx) ? effects.position_offset_x : global.JTT_DEFAULT_OFFSET_X;
	position_offset_y = (has_fx) ? effects.position_offset_y : global.JTT_DEFAULT_OFFSET_Y;
	
	float_magnitude = (has_fx) ? effects.float_magnitude : global.JTT_DEFAULT_FLOAT_MAGNITUDE;
	float_increment = (has_fx) ? effects.float_increment : global.JTT_DEFAULT_FLOAT_INCREMENT;
	float_value = 0;
	
	wave_magnitude = (has_fx) ? effects.wave_magnitude : global.JTT_DEFAULT_WAVE_MAGNITUDE;
	wave_increment = (has_fx) ? effects.wave_increment: global.JTT_DEFAULT_WAVE_INCREMENT;
	wave_offset = (has_fx) ? effects.wave_offset : global.JTT_DEFAULT_WAVE_OFFSET;
	wave_value = 0;
	
	shake_magnitude = (has_fx) ? effects.shake_magnitude : global.JTT_DEFAULT_SHAKE_MAGNITUDE; // x/y offset will be between negative and positive of this value, inclusive
	shake_time = (has_fx) ? effects.shake_time : global.JTT_DEFAULT_SHAKE_TIME; // number of shakes per update
	shake_value = 0;
	
	// alpha effects
	alpha_set = (has_fx) ? effects.alpha_set : global.JTT_DEFAULT_ALPHA_SET;
	
	pulse_alpha_max = (has_fx) ? effects.pulse_alpha_max : global.JTT_DEFAULT_PULSE_ALPHA_MAX;
	pulse_alpha_min = (has_fx) ? effects.pulse_alpha_min : global.JTT_DEFAULT_PULSE_ALPHA_MIN;
	pulse_increment = (has_fx) ? effects.pulse_increment : global.JTT_DEFAULT_PULSE_INCREMENT;
	
	blink_alpha_on = (has_fx) ? effects.blink_alpha_on : global.JTT_DEFAULT_BLINK_ALPHA_ON;
	blink_alpha_off = (has_fx) ? effects.blink_alpha_off : global.JTT_DEFAULT_BLINK_ALPHA_OFF;
	blink_time_on = (has_fx) ? effects.blink_time_on : global.JTT_DEFAULT_BLINK_TIME_ON;
	blink_time_off = (has_fx) ? effects.blink_time_off : global.JTT_DEFAULT_BLINK_TIME_OFF;
	blink_time = blink_time_on;
	
	// color effects
	chromatic_increment = (has_fx) ? effects.chromatic_increment : global.JTT_DEFAULT_CHROMATIC_INCREMENT;
	chromatic_max = (has_fx) ? effects.chromatic_max : global.JTT_DEFAULT_CHROMATIC_MAX;
	chromatic_min = (has_fx) ? effects.chromatic_min : global.JTT_DEFAULT_CHROMATIC_MIN;
	chromatic_r = chromatic_max;
	chromatic_g = chromatic_min;
	chromatic_b = chromatic_min;
	chromatic_state = 0;
	
	add_text = function(new_text) {
		text += new_text;
		calculate_width = true;
		calculate_height = true;
	}
	
	set_text = function(new_text) {
		text = new_text;
		calculate_width = true;
		calculate_height = true;
	}
	
	get_width = function() {
		if (calculate_width) {
			if (sprite == undefined) {
				draw_set_font(font);
				width = string_width(text);
			} else {
				width = sprite_get_width(sprite) * sprite_scale;
			}
			calculate_width = false;
		}
		return width;
	}
	
	get_height = function() {
		if (calculate_height) {
			if (sprite == undefined) {
				draw_set_font(font);
				height = string_height(text);
			} else {
				height = sprite_get_height(sprite) * sprite_scale;
			}
			calculate_height = false;
		}
		return height;
	}
	
	update = function() {
		
		// ENTRY EFFECTS	
		if (typed) {
			// movement
			if (effect_m == TB_EFFECT_ENTER_MOVE.NONE) {
				draw_mod_entry_x = 0;
				draw_mod_entry_y = 0;
			}
			if (effect_enter_m == TB_EFFECT_ENTER_MOVE.FALL) {
				draw_mod_entry_x = 0;
				fall_offset = floor(fall_offset * fall_increment);
				if (fall_offset <= 1) { 
					fall_offset = 0;
				} 
				draw_mod_entry_y = fall_offset * -1;
			}
			if (effect_enter_m == TB_EFFECT_ENTER_MOVE.RISE) {
				draw_mod_entry_x = 0;
				rise_offset = floor(rise_offset * rise_increment);
				if (rise_offset <= 1) { 
					rise_offset = 0;
				} 
				draw_mod_entry_y = rise_offset;
			}
			
			//alpha
			if (effect_enter_a == TB_EFFECT_ENTER_ALPHA.NONE) {
				alpha_entry = 1;
			}
			if (effect_enter_a == TB_EFFECT_ENTER_ALPHA.FADE) {
				if (fade_alpha_start < fade_alpha_end) fade_alpha += fade_alpha_increment;
				else fade_alpha -= fade_alpha_increment;
				
				if (fade_alpha_start < fade_alpha_end && fade_alpha >= fade_alpha_end) {
					fade_alpha = fade_alpha_end;
				}
				
				if (fade_alpha_start > fade_alpha_end && fade_alpha <= fade_alpha_end) {
					fade_alpha = fade_alpha_end;
				}
				alpha_entry = fade_alpha;
			}
		}
		
		// NORMAL EFFECTS	
		// movement effects
		if (effect_m == TB_EFFECT_MOVE.NONE) {
			draw_mod_x = 0;
			draw_mod_y = 0;
		}
		
		if (effect_m == TB_EFFECT_MOVE.OFFSET) {
			draw_mod_x = position_offset_x;
			draw_mod_y = position_offset_y;
		}
		
		if (effect_m == TB_EFFECT_MOVE.FLOAT) {
			draw_mod_x = 0;
			float_value += float_increment;
			draw_mod_y = floor(sin(float_value) * float_magnitude + 0.5);
		}
		
		if (effect_m == TB_EFFECT_MOVE.WAVE) {
			draw_mod_x = 0;
			wave_value += wave_increment;
			/* The wave value is how we keep track of the offset between characters. Offset is designed
			to be the position in the sine function you want the next character to be in terms of pi. 
			So if your offset is 1, then when a character is at 3pi, the next character will be at 4pi,
			the next at 5pi, and so on.*/
			//wave_value += wave_offset; 
			
			/* Notice the index modifier in the sin function. This ensures that each character using this
			effect recieves different position. The -1 ensures the values move through in reverse, which
			makes the first character look like it's "leading" the wave. */
			draw_mod_y = floor(sin((index * -1 * wave_offset + wave_value)) * wave_magnitude + 0.5);
		}
		
		if ((effect_m == TB_EFFECT_MOVE.SHAKE) || (effect_m == TB_EFFECT_MOVE.WSHAKE)) {
			shake_value += shake_time;
			while (shake_value >= 1) {
				shake_value -= 1;
				if (shake_magnitude > 0) {
					draw_mod_x = irandom_range(shake_magnitude * -1, shake_magnitude);
					draw_mod_y = irandom_range(shake_magnitude * -1, shake_magnitude);
				} else {
					draw_mod_x = irandom_range(0, 1);
					draw_mod_y = irandom_range(0, 1);
				}
			}
		}
		
		// alpha effects
		if (effect_a == TB_EFFECT_ALPHA.NONE) {
			alpha = 1;
		}
		
		if (effect_a == TB_EFFECT_ALPHA.ALPHA) {
			alpha = alpha_set;
		}
		
		if (effect_a == TB_EFFECT_ALPHA.PULSE) {
			alpha += pulse_increment;
			if (alpha >= pulse_alpha_max) {
				alpha = pulse_alpha_max;
				pulse_increment *= -1;
			}
			if (alpha <= pulse_alpha_min) {
				alpha = pulse_alpha_min;
				pulse_increment *= -1;
			}
		}
		
		if (effect_a == TB_EFFECT_ALPHA.BLINK) {
			/*
			Blink time will be set positive when counting time 
			on, and negative when counting time off
			*/
			if (blink_time > 0) {
				alpha = blink_alpha_on;
				blink_time -= 1;
				if (blink_time <= 0) {
					blink_time = blink_time_off * -1;
				}
			} else {
				alpha = blink_alpha_off;
				blink_time += 1;
				if (blink_time >= 0) {
					blink_time = blink_time_on;
				}
			}
		}
		
		// color effects
		if (effect_c == TB_EFFECT_COLOR.NONE) {
			draw_color = text_color;
		}
		
		if (effect_c == TB_EFFECT_COLOR.CHROMATIC) {
			
			if (chromatic_state == 0) {
				chromatic_g += chromatic_increment;
				if (chromatic_g >= chromatic_max) {
					chromatic_g = chromatic_max;
					chromatic_state += 1;
				}
			} else if (chromatic_state == 1) {
				chromatic_r -= chromatic_increment;
				if (chromatic_r <= chromatic_min) {
					chromatic_r = chromatic_min;
					chromatic_state += 1;
				}
			} else if (chromatic_state == 2) {
				chromatic_b += chromatic_increment;
				if (chromatic_b >= chromatic_max) {
					chromatic_b = chromatic_max;
					chromatic_state += 1;
				}
			} else if (chromatic_state == 3) {
				chromatic_g -= chromatic_increment;
				if (chromatic_g <= chromatic_min) {
					chromatic_g = chromatic_min;
					chromatic_state += 1;
				}
			} else if (chromatic_state == 4) {
				chromatic_r += chromatic_increment;
				if (chromatic_r >= chromatic_max) {
					chromatic_r = chromatic_max;
					chromatic_state += 1;
				}
			} else if (chromatic_state == 5) {
				chromatic_b -= chromatic_increment;
				if (chromatic_b <= chromatic_min) {
					chromatic_b = chromatic_min;
					chromatic_state = 0;
				}
			}
			draw_color = make_color_rgb(chromatic_r, chromatic_g, chromatic_b);
		}
		
	}
	
	draw = function(x, y, alpha_mod) {
		
		// count is how many characters in the text string we draw.
		var _count = (argument_count > 3) ? argument[3] : string_length(text);
		var _draw_text = string_copy(text, 1, _count);
		
		var original_color = draw_get_color();
		var original_alpha = draw_get_alpha();
		var original_font = draw_get_font();
		
		draw_set_font(font);
		draw_set_color(draw_color);
		draw_set_alpha(alpha * alpha_entry * alpha_mod);
		
		x += draw_mod_x;
		y += draw_mod_y;
		
		x += draw_mod_entry_x;
		y += draw_mod_entry_y;
		
		if (sprite == undefined) {
			draw_text(x, y, _draw_text);
		} else {
			draw_sprite_ext(sprite, 0, x, y, sprite_scale, sprite_scale, 0, -1, alpha * alpha_entry * alpha_mod);
		}
		
		draw_set_color(original_color);
		draw_set_alpha(original_alpha);
		draw_set_font(original_font);
	}
}

/// @desc Return true if given text requires 1 struct per character
function jtt_text_req_ind_struct(text_struct) {
	if (text_struct.effect_m == TB_EFFECT_MOVE.SHAKE) return true;
	if (text_struct.effect_m == TB_EFFECT_MOVE.WAVE) return true;
	if (text_struct.effect_enter_m != TB_EFFECT_ENTER_MOVE.NONE) return true;
	if (text_struct.effect_enter_a != TB_EFFECT_ENTER_ALPHA.NONE) return true;
	return false;
}

/// @desc Return true if effect values of given text structs are equal
function jtt_text_fx_equal(a, b) {
	// entry
	if (a.effect_enter_m != b.effect_enter_m) return false;
	if (a.effect_enter_a != b.effect_enter_a) return false;
	if (a.fall_magnitude != b.fall_magnitude) return false;
	if (a.fall_increment != b.fall_increment) return false;
	if (a.rise_magnitude != b.rise_magnitude) return false;
	if (a.rise_increment != b.rise_increment) return false;
	if (a.fade_alpha_start != b.fade_alpha_start) return false;
	if (a.fade_alpha_end != b.fade_alpha_end) return false;
	if (a.fade_alpha_increment != b.fade_alpha_increment) return false;
	
	// normal
	if (a.chirp != b.chirp) return false;
	if (a.chirp_gain != b.chirp_gain) return false;
	if (a.font != b.font) return false;
	if (a.text_color != b.text_color) return false;
	if (a.effect_m != b.effect_m) return false;
	if (a.effect_a != b.effect_a) return false;
	if (a.effect_c != b.effect_c) return false;
	if (a.position_offset_x != b.position_offset_x) return false;
	if (a.position_offset_y != b.position_offset_y) return false;
	if (a.float_magnitude != b.float_magnitude) return false;
	if (a.float_increment != b.float_increment) return false;
	if (a.wave_magnitude != b.wave_magnitude) return false;
	if (a.wave_increment != b.wave_increment) return false;
	if (a.wave_offset != b.wave_offset) return false;
	if (a.shake_magnitude != b.shake_magnitude) return false;
	if (a.shake_time != b.shake_time) return false;
	if (a.pulse_alpha_max != b.pulse_alpha_max) return false;
	if (a.pulse_alpha_min != b.pulse_alpha_min ) return false;
	if (a.pulse_increment != b.pulse_increment) return false;
	if (a.blink_alpha_on != b.blink_alpha_on) return false;
	if (a.blink_alpha_off != b.blink_alpha_off) return false;
	if (a.blink_time_on != b.blink_time_on) return false;
	if (a.blink_time_off != b.blink_time_off) return false;
	if (a.chromatic_increment != b.chromatic_increment) return false;
	if (a.chromatic_max != b.chromatic_max) return false;
	if (a.chromatic_min != b.chromatic_min) return false;
	return true;
}

/* string_pos_ext appears to be bugged in html builds for now. It behaves like
string_pos, and ignores the starting index. */
/// @desc same as string_pos_ext
function htmlsafe_string_pos_ext(substr, str, startpos) {
	var rest_of_string = string_delete(str, 1, startpos)
	var pos = string_pos(substr, rest_of_string);
	if (pos == 0) return 0;
	return pos + startpos;
}
