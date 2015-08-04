# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
ready = ->
  # Add expandable visual cue to expandable module headers
  $(".expandable h5:not(:has(i))").append('<i class="fa fa-arrows-alt"></i>')

  $.extend
    getUrlVars: ->
      vars = []
      hash = undefined
      hashes = window.location.href.slice(window.location.href.indexOf("?") + 1).split("&")
      i = 0

      while i < hashes.length
        hash = hashes[i].split("=")
        vars.push hash[0]
        vars[hash[0]] = decodeURIComponent(hash[1])
        i++
      vars
    getUrlVar: (name) ->
      $.getUrlVars()[name]

  $.fn.filterTable = (filters) ->
    $(this).find("tr:not(.filter-exclude)").each( ->
      j = 1
      i = 0
      while i < filters.length
        if filters[i][1]
          j *= $(this).find(filters[i][0] + ":Contains(" + filters[i][1] + ")").length
        i++
      if j > 0
        $(this).find("td>div").slideDown()
      else
        $(this).find("td>div").slideUp())
    false

  $.fn.reload_module = ->
    $(this).html('<div><div class="dashboard-module-spinner-container"><i class="fa fa-circle-o-notch fa-spin fa-2x"></i></div></div>')
    path = $(this).attr('data-load')
    # passes the query string to sub-modules for fields pre-filling
    $(this).load(path + '?' + window.location.search.substring(1))

  # Open detailed view on expandable module click
  $(".module.expandable h5").click ->
    path = $(this).next().attr('data-load')
    name = $(this).html().split("<i", 1)[0]
    # TODO Revisit following line in case more modules are expandable (path doesn't quite work for account activity)
    $("#detailed-wrapper>div").load("/transactions/?detailed=true")
    $("#detailed-wrapper h5").html(name + " Detailed View")
    $("body").toggleClass("bodylock1")
    $("#detailed-wrapper").show()
    $("#mask").show().fadeTo(300, 0.5)

  # # Opens Popup card when popuppable classes are clicked
  # window.bind_popup_card = ->
  #   $(".popuppable").children().addBack().filter($('[popup-handler-bound!="true"]')).attr('popup-handler-bound', 'true').click ->
  #     path = $(this).closest(".popuppable").attr('data-load')
  #     $("#popup-card-wrapper>div").load(path, ->
  #       if $("#popup-card-wrapper>div").height() + 80 > $(window).height()
  #         $("#popup-card-wrapper>div").parent().css "bottom", "40px"
  #       )
  #     $("#popup-card-wrapper h5").html("Detailed View")
  #     window.show_popup_card()
  #     return false

  window.resize_popup = ->
    if $("#popup-card-wrapper>div").height() + 80 > $(window).height()
      $("#popup-card-wrapper>div").parent().css "bottom", "40px"

  $(document).on 'click', '.popuppable', ->
    path = $(this).closest(".popuppable").attr('data-load')
    $("#popup-card-wrapper>div").load(path, ->
      if $("#popup-card-wrapper>div").height() + 80 > $(window).height()
        $("#popup-card-wrapper>div").parent().css "bottom", "40px")
    $("#popup-card-wrapper h5").html("Detailed View")
    window.show_popup_card()
    return false

  # Opens Popup card alert when called
  window.trigger_popup_alert = (message, type) ->
    window.dismiss_popup()
    $("#popup-card-wrapper h5").html(type)
    $("#popup-card-wrapper>div").html("<div>" + message + "</div>")
    window.show_popup_card()

  # Show popup card
  window.show_popup_card = ->
    $("body").toggleClass("bodylock2")
    $("#popup-card-wrapper").show()
    $("#mask2").show().fadeTo(300, 0.5)

  # Dismiss popup card
  window.dismiss_popup = ->
    $("#popup-card-wrapper>div").html('<div class="dashboard-module-spinner-container"><i class="fa fa-circle-o-notch fa-spin fa-2x"></i></div>')
    $("body").toggleClass("bodylock2")
    $("#popup-card-wrapper, #mask2").hide()
    $("#popup-card-wrapper").css "bottom", "initial"
    $("#mask2").css("opacity", 0)

  # Dismiss detailed view
  $("#mask").click ->
    $("#detailed-wrapper>div").html('<div class="dashboard-module-spinner-container"><i class="fa fa-circle-o-notch fa-spin fa-2x"></i></div>')
    $("body").toggleClass("bodylock1")
    $("#detailed-wrapper, #mask").hide()
    $("#mask").css("opacity", 0)

  # Dismiss Popup on mask2 click
  $("#mask2").click ->
    window.dismiss_popup()

  # Load init popup
  if $.getUrlVar('popup')
    $("#popup-card-wrapper>div").load $.getUrlVar('popup')
    window.show_popup_card()

  window.load_contents = ->
    # Load modules with AJAX Priority
    for i in [1..3]
      $("div[data-load]").filter("[data-load-order=" + i + "]").filter("[data-loaded!=true]").filter(":visible").each ->
        path = $(this).attr('data-load')
        $(this).attr('data-loaded', true)
        # passes the query string to sub-modules for fields pre-filling
        $.ajax({
          url: path + '?' + window.location.search.substring(1),
          dataType: 'html',
          success: (data) =>
            $(this).html(data)
            FB.XFBML.parse()
        })

  window.load_contents()

  # Setup AJAX Pagination Links
  window.setup_paging_links = (table_name) ->
    $('.paging').parent().add('#history_activity_dropdown a').bind('ajax:beforeSend', ->
      # FIXME ugly ugly ugly
      html = '<div><div class="dashboard-module-spinner-container"><i class="fa fa-circle-o-notch fa-spin fa-2x"></i></div></div>'

      $('#account_activity_history_module').html(html)
    );
    window.recalculate_truncate_width(table_name)

  window.recalculate_truncate_width = (selector) ->
    $(selector + " .td-truncate").hide().width($(selector + " .td-truncate").parent().width() - 10).show()

  # Recalculate text overflow width on browser resize
  $(window).resize( -> window.recalculate_truncate_width("#transaction-history-table"))
  $(window).resize( -> window.recalculate_truncate_width("#transaction-history-table-detailed"))
  $(window).resize( -> window.recalculate_truncate_width("#address-book-table"))

  # FIXME find a better place for it
  window.capitalize_string = (string) ->
    string.substring(0, 1).toUpperCase() + string.substring(1, string.length);

  window.validateNumField = (evt) ->
    theEvent = evt or window.event
    key = theEvent.keyCode or theEvent.which
    key = String.fromCharCode(key)
    regex = /[0-9]|\./
    unless regex.test(key)
      theEvent.returnValue = false
      theEvent.preventDefault()  if theEvent.preventDefault
    return

$(document).ready(ready)
$(document).on('page:load', ready)