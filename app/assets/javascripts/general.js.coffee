$ ->
  flash = $('#flash')
  if(flash.size() > 0)
    close = $('<a>').html('close').attr('href', '#').click (e) ->
      flash.remove()
      return false

    flash.append('... ').append(close)
