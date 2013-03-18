// Payments
//-----------------------------------------

function adjust_amount(amount_element, cb_element, amount) {
	var adjustment = $('#' + cb_element).is(':checked') ? -amount : amount;
	var new_value = parseInt($('#' + amount_element).val(), 10) + adjustment
	$('#' + amount_element).val(new_value);
	
	if (0 == new_value) {
	  $("#create_payment").attr("disabled", "disabled");		
	}
	else {
	  $("#create_payment").removeAttr("disabled");				
	}
}

function set_excluded(cb_elements, excluded_list) {
	var checkboxes = document.getElementsByName(cb_elements)
	var excluded = []
	
	if (checkboxes) {
		cnt = checkboxes.length;
		for(var i = 0; i < cnt; i++) {
			if (checkboxes[i].checked == 1) {
				excluded.push(checkboxes[i].id)
			}
		}
	}
	
	$('#' + excluded_list).val(JSON.stringify(excluded));
}