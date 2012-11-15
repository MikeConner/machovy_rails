function update_blog_weight(id, amount) {
	var new_value = Math.max(1, parseInt($('#blog_weight_' + id).val()) + amount);
	$('#blog_weight_' + id).val(new_value)
}
