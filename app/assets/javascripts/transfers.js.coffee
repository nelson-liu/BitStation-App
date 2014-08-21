# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->

  # action selecting for buy_sell form
  $(document.body).on "click", "#buy_sell_form #buy_sell_action_btn_group a", (event) ->
    return if $(this).parent().find('btn-primary').first().text() == $(this).text()
    $(this).parent().children().removeClass('btn-primary')
    $(this).addClass('btn-primary')
    $(this).closest('form').find('input[name=action]').val($(this).text().toLowerCase()).trigger('change')

    if $(this).text() == 'Buy'
      do $('#sellprice').hide
      do $('#buyprice').show
      do $('#sellpricehr').hide
      do $('#buypricehr').show
    if $(this).text() == 'Sell'
      do $('#sellprice').show
      do $('#buyprice').hide
      do $('#sellpricehr').show
      do $('#buypricehr').hide
    $("#buy_sell_form input[name=amount], #buy_sell_form input[name=preview_amount]").val("")

  # calculate estimated exchange price
  $(document.body).on 'keyup', '#buy_sell_form input[name=amount], #buy_sell_form input[name=preview_amount]', (event) ->
    other = $(this).parent().find('input[name!=' + $(this).attr('name') + ']').first()
    from_to = (other.attr('name') == 'preview_amount')
    action = $(this).closest('form').find('input[name=action]').val()
    if action == "buy" then rate = parseFloat($('#buy_current_rate').text()) else rate = parseFloat($('#sell_current_rate').text())
    conversion = if (from_to) then rate else 1.0 / rate
    other.val($(this).val() * conversion)
    $.get("/transfers/get_price", {type: action, amount: $("#buy_sell_form input[name=amount]").val()}).done( (data) -> 
      $("#table-amount-subtotal").html(data[0] + " USD")
      $("#table-amount-coinbase").html(data[1] + " USD")
      $("#table-amount-bank").html(data[2] + " USD")
      $("#table-amount-total").html(data[3] + " USD"))

$(document).ready(ready)
$(document).on('page:load', ready)