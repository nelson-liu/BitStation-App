# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  $(".alert-success").delay(2000).fadeOut 2000

  $(document.body).on "click", ".dropdown-menu li", (event) ->
    $target = $(event.currentTarget)
    $target.closest(".input-group-btn").find("[data-bind=\"label\"]").text($target.text()).end().children(".dropdown-toggle").dropdown "toggle"
    element = $("form input[name='currency']")
    currency = $target.text()
    element.val currency
    $('input[name=amount]').attr("placeholder", "The amount of #{currency} to send");
    false

  $(".module.expandable h5").click ->
    path = $(this).next().attr('data-load')
    name = $(this).html()
    $("#detailed-wrapper>div").load(path + "_detailed")
    $("#detailed-wrapper h5").html(name + " Detailed View")
    $("#detailed-wrapper").show()
    $("#mask").show().fadeTo(300, 0.5)

  $("#mask").click ->
  	$("#detailed-wrapper>div>div").html('<div class="dashboard-module-spinner-container"><i class="fa fa-circle-o-notch fa-spin fa-2x"></i></div>')
  	$("#detailed-wrapper, #mask").hide()
  	$("#mask").css("opacity", 0)

  $("#mask2").click ->
    $("#popup-card-wrapper>div>div").html('<div class="dashboard-module-spinner-container"><i class="fa fa-circle-o-notch fa-spin fa-2x"></i></div>')
    $("#popup-card-wrapper, #mask2").hide()
    $("#mask2").css("opacity", 0)

  $("div[data-load]").filter(":visible").each ->
    path = $(this).attr('data-load')
    $(this).load(path)

  # FIXME I do NOT want to pollute global namespace...
  window.setup_recipient_autocomplete = ->
    suggestion_engine = new Bloodhound({
      datumTokenizer: (d) ->
        d.tokens
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      remote: '/search_suggestions/user/%QUERY'
    });
    suggestion_engine.initialize();
    $('#transfer_form input[name=kerberos]').typeahead({
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
    $(".popuppable").children().click ->
      path = $(this).closest(".popuppable").attr('data-load')
      $("#popup-card-wrapper>div").load(path)
      $("#popup-card-wrapper h5").html("Detailed View")
      $("#popup-card-wrapper").show()
      $("#mask2").show().fadeTo(300, 0.5)

$(document).ready(ready)
$(document).on('page:load', ready)