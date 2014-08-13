# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
ready = ->
  $(".alert-success").delay(2000).fadeOut 2000
  $(".expandable h5:not(:has(i))").append('<i class="fa fa-arrows-alt"></i>')

  #dropdown menu for sending
  $(document.body).on 'change', '#transfer_form input[name=currency], #transfer_form input[name=action]', (event) ->
    action = $(this).closest('form').find('input[name=action]').val()
    currency = $(this).closest('form').find('input[name=currency]').val()
    $(this).closest('form').find('input[name=amount]').attr('placeholder', "The amount of #{currency} to #{action}")

  $(document.body).on "click", "#transfer_form #currency_dropdown li", (event) ->
    $(this).closest(".input-group-btn").find("[id=\"sendlabel\"]").text($(this).text()).end().children(".dropdown-toggle").dropdown "toggle"
    $(this).parents('form').find('input[name=currency]').val($(this).text()).trigger('change')
    false

  # action selecting for transfer form
  $(document.body).on "click", "#transfer_form #transfer_action_btn_group a", (event) ->
    $(this).parent().children().removeClass('btn-primary')
    $(this).addClass('btn-primary')
    $(this).closest('form').find('input[name=action]').val($(this).text().toLowerCase()).trigger('change')
    $(this).closest('form').find('label[for=recipient]').text(if $(this).text() == 'Send' then 'Recipient' else 'Requestee')
    $(this).closest('form').attr('action', $(this).closest('form').attr('data-' + $(this).text().toLowerCase() + '-path'))
    $(this).closest('form').find('input[type=submit]').val($(this).text() + ' Money')
    false

  # action selecting for buy_sell form
  $(document.body).on "click", "#buy_sell_form #buy_sell_action_btn_group a", (event) ->
    return if $(this).parent().find('btn-primary').first().text() == $(this).text()
    $(this).parent().children().removeClass('btn-primary')
    $(this).addClass('btn-primary')
    $(this).closest('form').find('input[name=action]').val($(this).text().toLowerCase()).trigger('change')

    from = if $(this).text() == 'Buy' then 'USD' else 'BTC'
    to = if $(this).text() == 'Buy' then 'BTC' else 'USD'

    $(this).closest('form').find('input[name=amount]').attr('placeholder', from + ' amount')
    $(this).closest('form').find('input[name=preview_amount]').attr('placeholder', to + ' amount')
    $(this).closest('form').find('.input-group-addon').html(from + ' <i class="fa fa-long-arrow-right"></i> ' + to)

    t = $(this).closest('form').find('input[name=amount]').val()
    $(this).closest('form').find('input[name=amount]').val($(this).closest('form').find('input[name=preview_amount]').val())
    $(this).closest('form').find('input[name=preview_amount]').val(t)

  # calculate estimated exchange price
  $(document.body).on 'keyup', '#buy_sell_form input[name=amount], #buy_sell_form input[name=preview_amount]', (event) ->
    other = $(this).parent().find('input[name!=' + $(this).attr('name') + ']').first()
    from_to = (other.attr('name') == 'preview_amount')
    action = $(this).closest('form').find('input[name=action]').val()
    rate = parseFloat($('#buy_sell_current_rate').text())
    console.log action
    conversion = if (from_to ^ (action == 'buy')) then rate else 1.0 / rate
    other.val($(this).val() * conversion)

  $(".module.expandable h5").click ->
    path = $(this).next().attr('data-load')
    name = $(this).html().split("<i", 1)[0]
    $("#detailed-wrapper>div").load(path + "_detailed")
    $("#detailed-wrapper h5").html(name + " Detailed View")
    $("#detailed-wrapper").show()
    $("#mask").show().fadeTo(300, 0.5)

  $("#mask").click ->
  	$("#detailed-wrapper>div").html('<div class="dashboard-module-spinner-container"><i class="fa fa-circle-o-notch fa-spin fa-2x"></i></div>')
  	$("#detailed-wrapper, #mask").hide()
  	$("#mask").css("opacity", 0)

  $("#mask2").click ->
    $("#popup-card-wrapper>div").html('<div class="dashboard-module-spinner-container"><i class="fa fa-circle-o-notch fa-spin fa-2x"></i></div>')
    $("#popup-card-wrapper, #mask2").hide()
    $("#popup-card-wrapper").css "bottom", "initial"
    $("#mask2").css("opacity", 0)

  $("div[data-load]").filter(":visible").each ->
    path = $(this).attr('data-load')
    # passes the query string to sub-modules for fields pre-filling
    $(this).load(path + '?' + window.location.search.substring(1))

  # FIXME I do NOT want to pollute global namespace...
  window.setup_recipient_autocomplete = (formID) ->
    suggestion_engine = new Bloodhound({
      datumTokenizer: (d) ->
        d.tokens
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      remote: '/search_suggestions/user/%QUERY'
    });
    suggestion_engine.initialize();
    $('#' + formID + ' input[name=kerberos]').typeahead({
      minLength: 1,
    }, {
      name: 'user-dataset',
      source: suggestion_engine.ttAdapter(),
      displayKey: 'kerberos',
      templates: {
        suggestion: (d) ->
          result = '<p class="autocomplete_name">' + d.name + '</p>'
          if d.coinbase_account_linked
            result += '<p class="autocomplete-coinbase-link-status text-success">Coinbase account linked</p>'
          else
            result += '<p class="autocomplete-coinbase-link-status text-danger">No Coinbase account linked</p>'
      }
    })

  window.setup_transaction_history_paging_links = ->
    $('.paging').parent().bind('ajax:beforeSend', ->
      # FIXME ugly ugly ugly
      html = '<div><div class="dashboard-module-spinner-container"><i class="fa fa-circle-o-notch fa-spin fa-2x"></i></div></div>'

      $('#transaction_history_module').html(html)
    );

  window.bind_popup_card = ->
    $(".popuppable").children().addBack().filter($('[popup-handler-bound!="true"]')).attr('popup-handler-bound', 'true').click ->
      path = $(this).closest(".popuppable").attr('data-load')
      $("#popup-card-wrapper>div").load path, ->
        if $(this).height() + 80 > $(window).height()
          $(this).parent().css "bottom", "40px"
        return
      $("#popup-card-wrapper h5").html("Detailed View")
      $("#popup-card-wrapper").show()
      $("#mask2").show().fadeTo(300, 0.5)
      return false

$(document).ready(ready)
$(document).on('page:load', ready)