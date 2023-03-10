function assert(_expression, _error_message){
	if !_expression {
		show_error(_error_message, true)
	}
	
	return _expression
}