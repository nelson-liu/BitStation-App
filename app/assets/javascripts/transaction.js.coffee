# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->

  $(document.body).on 'keyup', '#transfer_form input[name=amount_usd], #transfer_form input[name=amount_btc]', (event) ->
    exchange_rate = parseFloat($('#transfer_form input[name=exchange_rate]').val())
    usd_to_btc = ($(this).attr('name') == 'amount_usd')
    rate = (if usd_to_btc then (1.0 / exchange_rate) else exchange_rate)
    other = $(this).parent().find('input[name!=' + $(this).attr('name') + ']').first()
    console.log $('#transfer_form input[name=amount_usd], #transfer_form input[name=amount_btc]').remove($(this))
    other.val(parseFloat($(this).val()) * rate)

  # Reset fee to 0 on currency, amount, or recipient change
  $(document.body).on 'change', '#transfer_form input[name=currency], #transfer_form input[name=amount], #transfer_form input[name=kerberos]', (evenet) ->
    $("#fee_amount").val(0)

  # action selecting for transfer form
  $(document.body).on "click", "#transfer_form #transfer_action_btn_group a", (event) ->
    $(this).parent().children().removeClass('btn-primary')
    $(this).addClass('btn-primary')
    $(this).closest('form').find('input[name=action]').val($(this).text().toLowerCase()).trigger('change')
    $(this).closest('form').find('label[for=recipient]').text(if $(this).text() == 'Send' then 'Recipient' else 'Requestee')
    $(this).closest('form').attr('action', $(this).closest('form').attr('data-' + $(this).text().toLowerCase() + '-path'))
    $(this).closest('form').find('input[type=submit]').val($(this).text() + ' Money')

    if $(this).text().toLowerCase() == 'send'
      $(this).closest('form').removeAttr('data-remote')
    else
      $(this).closest('form').attr('data-remote', true)

    false

  $(document.body).on "click", "#clearfilter", (event) ->
    $('#filter-date').val('')
    $('#filter-date').keyup()
    false

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

  window.setup_transfer_button = ->
    $('#transfer_form').bind('ajax:beforeSend', ->
      action = $(this).find('input[name=action]').val()
      $(this).find('input[type=submit]').prop('disabled', true)
      $(this).find('input[type=submit]').val(window.capitalize_string(action) + 'ing Money...')
    );

    $('#transfer_form').bind('ajax:complete', (event, request, ajaxOptions) ->
      action = $(this).find('input[name=action]').val()
      $(this).find('input[type=submit]').prop('disabled', false)
      $(this).find('input[type=submit]').val(window.capitalize_string(action) + ' Money')

      if request.responseText.indexOf('"success"') != -1
        $('#transfer_form').clear_transfer_form()
    );

  $.fn.clear_transfer_form = ->
    $(this).find('input[name=amount]').val('')
    $(this).find('input[name=kerberos]').val('')
    $(this).find('input[name=fee_amount]').val('')
    $(this).find('input[name=message]').val('')

$(document).ready(ready)
$(document).on('page:load', ready)