/// @param ...rest
function trace() {
	var _r = string(argument[0]);
	for (var _i = 1; _i < argument_count; _i++) {
	    _r += " " + string(argument[_i]);
	}
	show_debug_message(_r);
}