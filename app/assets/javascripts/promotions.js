$(function() {
  $(".rslides").responsiveSlides();

  $('#tab1').click(function (e) {
    e.preventDefault();
    $(this).tab('show');
  })

  $('#tab2').click(function (e) {
    e.preventDefault();
    $(this).tab('show');
  })

  $('#tab3').click(function (e) {
    e.preventDefault();
    $(this).tab('show');
  }) 

  var $container = $('#container');
  $container.imagesLoaded( function(){
    $container.isotope({
      itemSelector : '.box',
        masonry : {
          resizable: false, // disable normal resizing
           // set columnWidth to a percentage of container width
          columnWidth: $container.width() / 100,
          gutterWidth: 2
        }
    });

  $(window).smartresize(function(){
    $container.isotope({
      // update columnWidth to a percentage of container width
      masonry: { columnWidth: $container.width() / 100 }
    });
  });
  });

  // filter items when filter link is clicked
  $('#filters a').click(function(){
    var selector = $(this).attr('data-filter');
    $container.isotope({ filter: selector });
    return false;
  });

  $('.rating_star').click(function() {
  	var star = $(this);
  	var stars = $(this).attr('data-stars');
  	var data_id = $(this).attr('data-id')
  	$('#' + data_id + "_stars").val(stars)
  	
  	for (i = 1; i <= 5; i++) {
  		if (i <= stars) {
  			$('#' + data_id + "_" + i).addClass('on');
  		}
  		else {
  			$('#' + data_id + "_" + i).removeClass('on');
  		}
  	}
  });
  
  var latitude = $('#latitude').val();
  var longitude = $('#longitude').val();
  var label = $('#vendor').val();
  
  if (latitude && longitude) {
  	var address = new google.maps.LatLng(latitude, longitude);
  	
  	var mapOptions = {
      center: address,
      zoom: 8,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    
    var map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);
    if (label) {
	    var marker = new google.maps.Marker({position: address, 
						                     map: map,
						                     title: label
						                     });   	
    }
  }
  
  // Initialize start and end dates from the date_select, and write them on change
  // This makes the jQuery datepicker transparent to the controller, which just sees the date_select fields
  $("#jq_start_date").datepicker({
  	defaultDate: new Date($('#promotion_start_date_1i').val(), $('#promotion_start_date_2i').val() - 1,$('#promotion_start_date_3i').val()),
  	onSelect: function(dateText, inst) { 
  		// 11/28/2012 format
  		fields = dateText.split('/');
		// Set year
		$('#promotion_start_date_1i').val(fields[2]);
		// Set month
		$('#promotion_start_date_2i').val(parseInt(fields[0]));
		// Set day
		$('#promotion_start_date_3i').val(parseInt(fields[1]));
  	}
  });
  $("#jq_end_date").datepicker({
  	defaultDate: new Date($('#promotion_end_date_1i').val(), $('#promotion_end_date_2i').val() - 1,$('#promotion_end_date_3i').val()),
 	onSelect: function(dateText, inst) { 
  		fields = dateText.split('/');
		// Set year
		$('#promotion_end_date_1i').val(fields[2]);
		// Set month
		$('#promotion_end_date_2i').val(parseInt(fields[0]));
		// Set day
		$('#promotion_end_date_3i').val(parseInt(fields[1]));  
	}	
  });
  
  $("#jq_fixed_end_date").datepicker({
  	defaultDate: new Date($('#fixed_end_date_1i').val(), $('#fixed_end_date_2i').val() - 1,$('#fixed_end_date_3i').val()),
 	onSelect: function(dateText, inst) { 
  		fields = dateText.split('/');
		// Set year
		$('#fixed_end_date_1i').val(fields[2]);
		// Set month
		$('#fixed_end_date_2i').val(parseInt(fields[0]));
		// Set day
		$('#fixed_end_date_3i').val(parseInt(fields[1]));  
	}	
  });
  
  // The promotion strategy appears in a tab section. "promotion_strategy" is the hidden field for the result
  // The strategy is passed in on page load; need to activate both the tab label and the content of the tab
  var active_strategy_element = $('#' + $('#promotion_strategy').val())
  if (active_strategy_element) {
  	// Make tab label active
  	active_strategy_element.parent().addClass("active")
  	// Make tab content active
  	$(active_strategy_element.attr('href')).addClass("fade in active")
  }
  
  // Set the promotion_strategy when the user clicks on a tab
  $('#promotionStrategyTab .tab a').each(function() {
    var $this = $(this);
    $this.click(function (e) {
        e.preventDefault();
        $this.tab('show');
        $('#promotion_strategy').val($this.attr('id'));
    });
  });  
  
  // Macho Bucks
  // When they choose a pre-selected amount (radio buttons), fill in the amount text field
  $('#macho_gift input').each(function() {
  	var $this = $(this);
  	$this.click(function (e) {
  		$('#gift_certificate_amount').val($this.attr('value'))
  	});
  });
});

// Appears in views/merchant/order/_order_form; currently commented out
function update_amount(source, destination, unit_price, macho_bucks) {
  var amount = Math.max(0, $('#' + source).val() * unit_price - macho_bucks)
  $('#' + destination).val(amount)
  //$('#total_cost').text(amount)
  //$('#final_total').val(amount - macho_bucks)
  // Don't show the credit card section if Macho Bucks are sufficient to pay it
  $('#credit_card_section').toggle(amount > 0)
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
	// Include this to update immediately on button press
	// Alternatively, manage.html.haml can have a submit button, and this just updates the local field
	jQuery.ajax({url:"/promotions/" + id + "/update_weight",
	             data: "promotion[grid_weight]=" + new_value,
		         type: "PUT",
	             error: function(xhr, ajaxOptions, thrownError) //{ alert('Oh noes!') },
	               { alert('error code: ' + xhr.status + ' \n'+'error:\n' + thrownError ); },
	             async: false}); 	    		
}
