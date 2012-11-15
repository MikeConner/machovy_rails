$(function() {
  $('#revenue_slider').slider({
  	// min should match Promotion::MINIMUM_REVENUE_SHARE
  	min: 5,
  	max: 80,
  	// Initialize it (for edit)
  	value: $('#promotion_revenue_shared').val(),
  	change: function(event, ui) {
  		// Set both the hidden field and the slider indicator
  		$('#slider_value').html(ui.value + '%')
  		$('#promotion_revenue_shared').val(ui.value)
  	}
  });
  
  $(".rslides").responsiveSlides();

  $('#tab1').click(function (e) {
    e.preventDefault();
    $(this).tab('show');
  })

  $('#tab2').click(function (e) {
    e.preventDefault();
    $(this).tab('show');
  })  
	//$('.carousel').carousel() Calls bootstrap slider
});

// Appears in views/merchant/order/_order_form; currently commented out
function update_amount(source, destination, unit_price) {
  $('#' + destination).val($('#' + source).val() * unit_price)
}

function munge_affiliate_url(source, destination) {
    var raw_url = $('#' + source).val();
    // Ruby still parses the arguments out; doesn't matter for our purposes
    //var escaped_url = jQuery('<div/>').text(raw_url).html()
    
	jQuery.ajax({url:"/affiliate_url",
	             data: "url=" + raw_url,
		         type: "GET",
	             success: function(data) { 
	               $('#' + destination).val(data)
	               if (data == "") {
	                 alert("Unable to convert url")
	               }
	             },
	             error: function(xhr, ajaxOptions, thrownError) //{ alert('Oh noes!') },
	               { alert('error code: ' + xhr.status + ' \n'+'error:\n' + thrownError ); },
	             async: false}); 	    		
}

function update_grid_weight(id, amount) {
	var new_value = Math.max(1, parseInt($('#grid_weight_' + id).val()) + amount);
	$('#grid_weight_' + id).val(new_value)
}
