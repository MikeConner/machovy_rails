// Vendors
//-----------------------------------------

function find_voucher(search_element) {
    var name = $('#' + search_element).val();
	jQuery.ajax({url:"/merchant/vouchers/search",
	             data: "key=" + name,
		         type: "PUT",
	             success: function(data) { 
	               $('#' + search_element).val("")
	               if (data == '"none"') {
	                 alert('Voucher not found');
	               }
	             },
	             error: function(xhr, ajaxOptions, thrownError) //{ alert('Oh noes!') },
	               { alert('error code: ' + xhr.status + ' \n'+'error:\n' + thrownError ); },
	             async: false}); 	    	
}