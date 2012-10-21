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
});

// Appears in views/merchant/order/_order_form; currently commented out
function update_amount(source, destination, unit_price) {
  $('#' + destination).val($('#' + source).val() * unit_price)
}
