# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->

  $(".module.expandable h5").click ->
  	$(this).parents(".module").toggleClass("col-lg-12 col-sm-12")

  $("div[data-load]").filter(":visible").each ->
    path = $(this).attr('data-load')
    $(this).load(path)

$(document).ready(ready)
$(document).on('page:load', ready)