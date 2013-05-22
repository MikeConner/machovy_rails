// Promotion
//-----------------------------------------

$(function() {

  $(document).foundation();

  $('#teaserBD').Jcrop({
    onChange: update_cropBD,
    onSelect: update_cropBD,
    setSelect: [0, 0, 600, 297],
    aspectRatio: 2.0212766
  });
  $('#teaserLD').Jcrop({
    onChange: update_cropLD,
    onSelect: update_cropLD,
    setSelect: [0, 0, 600, 549],
    aspectRatio: 1.093023
  });

  $('#promo1').Jcrop({
    onChange: update_cropI2,
    onSelect: update_cropI2,
    setSelect: [0, 0, 600, 549],
    aspectRatio: 1.093023
  });

  $('#promo2').Jcrop({
    onChange: update_cropI3,
    onSelect: update_cropI3,
    setSelect: [0, 0, 600, 549],
    aspectRatio: 1.093023
  });

 $('#mapclick').mouseout(function (e) {
    fix_map(map);
  })
  // For product promotions
    
  jQuery(function() {
	jQuery.support.placeholder = false;
	test = document.createElement('input');
	if('placeholder' in test) jQuery.support.placeholder = true;

	if(!$.support.placeholder) { 
		var active = document.activeElement;
		$(':input:not(:password)').focus(function () {
			if ($(this).attr('placeholder') != '' && $(this).val() == $(this).attr('placeholder')) {
				$(this).val('').removeClass('hasPlaceholder');
			}
		}).blur(function () {
			if ($(this).attr('placeholder') != '' && ($(this).val() == '' || $(this).val() == $(this).attr('placeholder'))) {
				$(this).val($(this).attr('placeholder')).addClass('hasPlaceholder');
			}
		});
		$(':input:not(:password)').blur();
		$(active).focus();
		$('form').submit(function () {
			$(this).find('.hasPlaceholder').each(function() { $(this).val(''); });
		});
	}
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
    active_strategy_element.click();
  }
  
  // Set the promotion_strategy when the user clicks on a tab
  $('#promotionStrategyTab .title a').each(function() {
    var $this = $(this);
    $this.click(function (e) {
        e.preventDefault();
        $('#promotion_strategy').val($this.attr('id'));
        $this.tab('show');
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


function update_cropBD(coords) {
  var rx = 100/coords.w;
  var ry = 100/coords.h;
  var ratio = 1;
  $("#BDcrop_x").val(Math.round(coords.x * ratio));
  $("#BDcrop_y").val(Math.round(coords.y * ratio));
  $("#BDcrop_w").val(Math.round(coords.w * ratio));
  $("#BDcrop_h").val(Math.round(coords.h * ratio));
}
function update_cropLD(coords) {
  var rx = 100/coords.w;
  var ry = 100/coords.h;

  var ratio = 1;
  $("#LDcrop_x").val(Math.round(coords.x * ratio));
  $("#LDcrop_y").val(Math.round(coords.y * ratio));
  $("#LDcrop_w").val(Math.round(coords.w * ratio));
  $("#LDcrop_h").val(Math.round(coords.h * ratio));

}

function update_cropI2(coords) {
  var rx = 100/coords.w;
  var ry = 100/coords.h;
  var ratio = 1;
  $("#I2crop_x").val(Math.round(coords.x * ratio));
  $("#I2crop_y").val(Math.round(coords.y * ratio));
  $("#I2crop_w").val(Math.round(coords.w * ratio));
  $("#I2crop_h").val(Math.round(coords.h * ratio));
}


function update_cropI3(coords) {
  var rx = 100/coords.w;
  var ry = 100/coords.h;
  var ratio = 1;
  $("#I3crop_x").val(Math.round(coords.x * ratio));
  $("#I3crop_y").val(Math.round(coords.y * ratio));
  $("#I3crop_w").val(Math.round(coords.w * ratio));
  $("#I3crop_h").val(Math.round(coords.h * ratio));
}

function fix_map(map) {
  google.maps.event.trigger(map, "resize");
  var latitude = $('#latitude').val();
  var longitude = $('#longitude').val();

  if (latitude && longitude) {
    var address = new google.maps.LatLng(latitude, longitude);
    map.setCenter(address);
  } 
}

// Appears in views/merchant/order/_order_form
function update_amount(quantity, unit_price, macho_bucks) {
  var gross_total = $('#' + quantity).val() * unit_price;
  var net_total = gross_total;
  $('#gross_total').text("$" + gross_total.toFixed(2));
  if (macho_bucks > 0) {
      var credit_used = Math.min(macho_bucks, gross_total);
      $('#credit_used').text("$" + credit_used.toFixed(2));
      $('#macho_balance').text("$" + (macho_bucks - credit_used).toFixed(2)); 
      net_total = gross_total - credit_used;  
  }
  $('#balance_due').text("$" + net_total.toFixed(2));
  
  // Don't show the credit card section if Macho Bucks are sufficient to pay it
  $('#credit_card_section').toggle(net_total > 0);
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
