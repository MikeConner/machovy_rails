# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  order.setupForm()

order =
  setupForm: ->
    $('#new_order').submit ->
      # This will be visible if they're either not a customer (no saved card), or they're a customer using a new card
      if $('#card_info').is(':visible')
        $('input[type=submit]').attr('disabled', true)
        order.processCard()
      else
        $('#new_order')[0].submit()
      false

  processCard: ->
    card =
      card_number: $('#card_number').val()
      card_code: $('#card_code').val()
      card_month: $('#card_month').val()
      card_year: $('#card_year').val()
      first_name: $('#first_name').val()
      last_name: $('#last_name').val()
      address: $('#address').val()
      city: $('#city').val()
      state: $('#state').val()
      zipcode: $('#zipcode').val()
    
    $.ajax '/validate_card',
          type: 'PUT'
          data: card
          success: (data, textStatus, jqXHR) ->
            if (data == "")
              $('#new_order')[0].submit()
            else
              $('#card_error').text(data)
              $('#card_error').show()
              $('input[type=submit]').attr('disabled', false)                   
          error: (jqXHR, textStatus, errorThrown) -> 
            $('#card_error').text(textStatus + '; ' + errorThrown)
            $('#card_error').show()
            $('input[type=submit]').attr('disabled', false)
                  
# Have to make these global, or they're not accessible from outside this file!    
window.hide_card_info = ->
  $('#card_info').toggle(false)
  $('#new_card').val(false)
   
window.show_card_info = ->
  $('#card_info').toggle(true)
  $('#new_card').val(true)
    
window.set_save_card_field = ->
  $('#save_card').val(document.getElementById('cb_save_card').checked) 

window.carry_over_address = ->
  $('#order_name').val($('#first_name').val() + " " + $('#last_name').val())
  $('#order_address_1').val($('#address').val())
  $('#order_city').val($('#city').val())
  $('#order_state').val($('#state').val())
  $('#order_zipcode').val($('#zipcode').val())
