// Blog Posts
//-----------------------------------------

function update_blog_weight(id, amount) {
	var new_value = Math.max(1, parseInt($('#blog_weight_' + id).val()) + amount);
	$('#blog_weight_' + id).val(new_value)
	// Include this to update immediately on button press
	// Alternatively, index.html.haml can have a submit button, and this just updates the local field
	jQuery.ajax({url:"/blog_posts/" + id + "/update_weight",
	             data: "blog_post[weight]=" + new_value,
		         type: "PUT",
	             error: function(xhr, ajaxOptions, thrownError) //{ alert('Oh noes!') },
	               { alert('error code: ' + xhr.status + ' \n'+'error:\n' + thrownError ); },
	             async: false}); 	    		
}