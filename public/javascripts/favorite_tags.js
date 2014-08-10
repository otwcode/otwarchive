$j('#favorite_tag').on("click", function(event) {
  event.preventDefault();

  var flashContainer = $j('#ajax_flash');  
  var form = $j('#favorite_tag');
  var formAction = form.attr('action');
  var formSubmit = form.find('[type="submit"]');
  
  $j.ajax({
    type: 'POST',
    url: formAction,
    data: form.serialize(),
    dataType: 'json',
    error: function(xhr, textStatus, err ) {
      flashContainer.addClass('error notice').text('Sorry, we could not save this favorite tag.');
    },
    success: function(data) { 
      if (data.favorite_tag_id) {
        flashContainer.addClass('notice').text(data.favorite_tag_success);
        formSubmit.val('Unfavorite Tag');
        form.append('<input name="_method" type="hidden" value="delete">');
        form.attr('action', formAction + '/' + data.favorite_tag_id);
      } else {
        flashContainer.addClass('notice').text(data.favorite_tag_success);
        formSubmit.val('Favorite Tag');
        form.find('input[name="_method"]').remove();
        form.attr('action', formAction.replace(/\/\d+/, ''));
      }
    }
  });
});
