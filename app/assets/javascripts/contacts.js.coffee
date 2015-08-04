# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->

  window.setup_address_book = ->
    jQuery.expr[":"].Contains = jQuery.expr.createPseudo((arg) ->
      (elem) ->
        jQuery(elem).text().toUpperCase().indexOf(arg.toUpperCase()) >= 0
    )
    $("#address-book-table td:not('.first-column')").wrapInner("<div></div>")
    $("#address-book-table .first-column").wrapInner("<div class='td-truncate'></div>")
    $("#address-book-filter").change(-> $("#address-book-table").filterTable([[".address-book-contact", $("#address-book-filter").val()]])).keyup -> $(this).change()
    $("#address-book-pagination #previous").click( ->
      if parseInt($("#address-book-table").css("margin-top"), 10) < 0 && !$("#address-book-table").is(":animated")
        $("#address-book-table").animate({marginTop: "+=350"}, 150))
    $("#address-book-pagination #next").click( ->
      if Math.abs(parseInt($("#address-book-table").css("margin-top"), 10) - 350) < $("#address-book-table").height() && !$("#address-book-table").is(":animated")
        $("#address-book-table").animate({marginTop: "-=350"}, 150))
    window.recalculate_truncate_width("#address-book-table")



$(document).ready(ready)
$(document).on('page:load', ready)