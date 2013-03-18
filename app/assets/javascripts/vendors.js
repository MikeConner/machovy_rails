function update_vendor_mapping() {
  data_obj = {"address_1": $('#vendor_address_1').val(), "address_2": $('#vendor_address_2').val(), 
                      "city": $('#vendor_city').val(), "state": $('#vendor_state').val(), "zip": $('#vendor_zip').val() }
                      
  jQuery.ajax({url:"/geocode.json",
               data: data_obj,
               type: "GET",
               success: function(data) { 
               	 if (data.latitude) {
	                 $('#vendor_latitude').val(data.latitude);
	                 $('#vendor_longitude').val(data.longitude);
	                 alert('Geocode updated')
	             }
	             else {
	             	alert('Could not update geocode; please enter a valid address (or enter latitude/longitude manually)')
	             }
               },
               error: function(xhr, ajaxOptions, thrownError) //{ alert('Oh noes!') },
                 { alert('error code: ' + xhr.status + ' \n'+'error:\n' + thrownError ); },
               async: false});
}
