$j('#favorite_tag').on("click", function(event) {
  event.preventDefault();

  var flashContainer = $j('#ajax_flash');  
  var form = $j('#favorite_tag');
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
      if (data.favorite_tag_id) {
        flashContainer.addClass('notice').text(data.favorite_tag_success);
        flashContainer.text(data.favorite_tag_success);
        formSubmit.val(destroyValue);
        form.append('<input name="_method" type="hidden" value="delete">');
        form.attr('action', formAction + '/' + data.favorite_tag_id);
      } else {
        flashContainer.addClass('notice').text(data.favorite_tag_success);
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
