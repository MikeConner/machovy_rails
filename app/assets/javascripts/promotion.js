// Vouchers
//-----------------------------------------

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



// Front Grid
//-----------------------------------------

$(function() {
    $('ul.categories > li').click(function (e) {
        e.preventDefault();
        // If we weren't redirecting, this is all you need to handle the selection
        // This gets lost on the redirect, though, so has to be done in the views instead
//        $('ul.nav-pills > li').removeClass('active');
//        $(this).addClass('active');          

        // Filter the results              
    jQuery.ajax({url:"/category",
                 data: "category=" + $(this).children().first().attr('id'),
               type: "GET",
               // Don't need to do anything on success
                 error: function(xhr, ajaxOptions, thrownError) //{ alert('Oh noes!') },
                   { alert('error code: ' + xhr.status + ' \n'+'error:\n' + thrownError ); },
                 async: false
    });
  });   
});

function select_mobile_category(category) {
  jQuery.ajax({url:"/category",
               data: "category=" + category,
             type: "GET",
             // Don't need to do anything on success
               error: function(xhr, ajaxOptions, thrownError) //{ alert('Oh noes!') },
                 { alert('error code: ' + xhr.status + ' \n'+'error:\n' + thrownError ); },
               async: false
  });
  
  preventDefault();
}

function hide_machovy_banner() {
  $('#machovy_banner').hide();

  jQuery.ajax({url:"/banner",
               data: "hidden=true",
             type: "PUT",
             // Don't need to do anything on success
               error: function(xhr, ajaxOptions, thrownError) //{ alert('Oh noes!') },
                 { alert('error code: ' + xhr.status + ' \n'+'error:\n' + thrownError ); },
               async: false
  });
}



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




// Promotion
//-----------------------------------------

$(function() {

  $(document).foundation();
  
  $.backstretch(["/assets/background-img.png"])

  // Define any icon actions before calling the toolbar 
      $('.toolbar-icons a').on('click', function( event ) {
        event.preventDefault(); 
      });

      $('.share-tools').toolbar({content: '#user-options', position: 'top'});

  
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
    update_width($(window).width(), true);
  });
  });

  // Send width if we're on the main page AND there's no deal content yet
  if (($('.main-wrap').length > 0) && (0 == $('#deal_content').length)) {
    update_width($(window).width(), false);
  }

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

function update_width(width, resize) {
  data_obj = {"width": width, "resize": resize}
  
  jQuery.ajax({url:"/width",
               data: data_obj,
             type: "PUT",
             // Don't need to do anything on success
               error: function(xhr, ajaxOptions, thrownError) //{ alert('Oh noes!') },
                 { alert('error code: ' + xhr.status + ' \n'+'error:\n' + thrownError ); },
               async: false
  }); 
}

