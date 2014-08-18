// For simple forms that appear to toggle between creating and destroying records
// e.g. favorite tags, subscriptions
// <form> needs ajax-create-destroy class, data-create-value, data-destroy-value
// data-create-value: text of the button for creating, e.g. Favorite, Subscribe
// data-destroy-value: text of button for destroying, e.g. Unfavorite, Unsubscribe
// controller needs item_id and item_success_message for save success and
// item_success_message for destroy success

$j('.ajax-create-destroy').on("click", function(event) {
  event.preventDefault();

  var flashContainer = $j('#ajax_flash');  
  var form = $j(this);
  var formAction = form.attr('action');
  var formSubmit = form.find('[type="submit"]');
  var createValue = form.data('create-value');
  var destroyValue = form.data('destroy-value');
  
  $j.ajax({
    type: 'POST',
    url: formAction,
    data: form.serialize(),
    dataType: 'json',
    success: function(data) {
      flashContainer.removeClass('error').empty();
      if (data.item_id) {
        flashContainer.addClass('notice').text(data.item_success_message);
        formSubmit.val(destroyValue);
        form.append('<input name="_method" type="hidden" value="delete">');
        form.attr('action', formAction + '/' + data.item_id);
      } else {
        flashContainer.addClass('notice').text(data.item_success_message);
        formSubmit.val(createValue);
        form.find('input[name="_method"]').remove();
        form.attr('action', formAction.replace(/\/\d+/, ''));
      }
    },
    error: function(xhr, textStatus, errorThrown) {
      flashContainer.empty();
      flashContainer.addClass('error notice');
      $j.each(jQuery.parseJSON(xhr.responseText).errors, function(index, error){
        flashContainer.append(error + " ");
      });
    }
  });
});
