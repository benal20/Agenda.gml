/// @func order_create(target, handler, value)
/// @param	{any}		target	target instance id or struct
/// @param	{function}	handler handler method
/// @param	{any}		[value]	optional value passed into the handler
/// @return	{struct}	order	the newly created order
function order_create(_target, _handler, _value = undefined) {
	var _order = new __Order(_target, _handler)
	_order.__handle(_value)
	return _order
}
