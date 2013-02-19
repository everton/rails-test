$ ->
  cart = $('#cart')
  if(cart.size() > 0)
    $('#order li').each (index, item) =>
      item       = $(item)
      quantity   = item.find('select.quantity')
      zeroOption = quantity.find('option[value=0]')
      zeroOption.hide()

      button = $('<a>')
        .attr('href', '#')
        .html('Remove from cart')
        .addClass('delete-button')
        .click (e) =>
          if(cart.find('#order > li').size() <  2)
            $(e.target)
              .attr('href', '/cart')
              .attr('data-method', 'delete')
            return true
          else
            originalValue = quantity.find('option[selected="selected"]').val()
            quantity.find('option').removeAttr('selected')

            zeroOption.attr('selected','selected')

            cart.find('form.edit_order').submit()

            return false

      quantity.after(button)
