# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  $(document.body).on "click", ".dropdown-menu li", (event) ->
    $target = $(event.currentTarget)
    $target.closest(".input-group-btn").find("[data-bind=\"label\"]").text($target.text()).end().children(".dropdown-toggle").dropdown "toggle"
    element = $("form input[name='currency']")
    currency = $target.text()
    element.val currency
    placeholder = $("form input[name='amount']")
    placeholder.val "The amount of #{currency} to send"
    false

  $(".module.expandable h5").click ->
    path = $(this).next().attr('data-load')
    name = $(this).html()
    $("#detailed-wrapper>div>div").load(path + "_detailed")
    $("#detailed-wrapper h5").html(name + " Detailed View")
    $("#detailed-wrapper").show()
    $("#mask").show().fadeTo(300, 0.5)
    $("html, body").animate
    	scrollTop: $("#detailed-wrapper").offset().top
    , 500

  $("#mask").click ->
  	$("#detailed-wrapper>div>div").html('<div class="dashboard-module-spinner-container"><i class="fa fa-circle-o-notch fa-spin fa-2x"></i></div>')
  	$("#detailed-wrapper, #mask").hide()
  	$("#mask").css("opacity", 0)

  $("div[data-load]").filter(":visible").each ->
    path = $(this).attr('data-load')
    $(this).load(path)

$(document).ready(ready)
$(document).on('page:load', ready)

###
#$(this).parents(".module").toggleClass("col-lg-12 col-sm-12 expanded")
#$('html, body').animate
#	scrollTop: $(this).offset().top
#, 1000
###