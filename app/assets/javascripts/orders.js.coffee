# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'))
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
      number: $('#card_number').val()
      cvc: $('#card_code').val()
      expMonth: $('#card_month').val()
      expYear: $('#card_year').val()
    Stripe.createToken(card, order.handleStripeResponse)    
    
  handleStripeResponse: (status, response) ->
    if status == 200
      $('#order_stripe_card_token').val(response.id)
      $('#new_order')[0].submit()
    else
      $('#stripe_error').text(response.error.message)
      $('#stripe_error').show()
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
