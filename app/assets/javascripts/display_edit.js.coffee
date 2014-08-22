ready = ->
  $.fn.show_edit_error = (error) ->
    $(this).find('[data-display-role=error]').show()
    $(this).find('[data-display-role=error]').html(error)

  $.fn.init_edit = ->
    $(this).end_edit()

  $.fn.begin_edit = ->
    $(this).find('[data-display-role=display]').hide()
    $(this).find('[data-display-role=begin]').hide()
    $(this).find('[data-display-role=edit]').show()
    $(this).find('[data-display-role=submit]').show()
    $(this).find('[data-display-role=cancel]').show()

  $.fn.end_edit = ->
    $(this).find('[data-display-role=display]').show()
    $(this).find('[data-display-role=begin]').show()
    $(this).find('[data-display-role=edit]').hide()
    $(this).find('[data-display-role=submit]').hide()
    $(this).find('[data-display-role=error]').hide()
    $(this).find('[data-display-role=cancel]').hide()

  $.fn.update_edit_field = (field, value) ->
    $(this).find('[data-display-role=edit][data-display-field=' + field + ']').val(value);
    $(this).find('[data-display-role=display][data-display-field=' + field + ']').text(value);

$(document).ready(ready)
$(document).on('page:load', ready)