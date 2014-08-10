$j('form.favorite_tag').on("click", function(event) {
  event.preventDefault();
  
  var form = $j('form.favorite_tag');
  var formAction = form.attr('action');
  
  $j.ajax({
    type: 'POST',
    url: formAction,
    data: form.serialize(),
    dataType: 'json',
    error: function(xhr, textStatus, err ) {
      $j('#ajax_flash').addClass('error notice').text('Sorry, we could not save this favorite tag.');
    },
    success: function(data) { 
      if (data.favorite_tag_id) {
        $j('#ajax_flash').addClass('notice').text('You have successfully saved this favorite tag. It will be listed on your homepage.');
        $j('input.submit_favorite_tag').val('Destroy Favorite Tag (JS)');
        form.append('<input name="_method" type="hidden" value="delete">');
        form.attr('action', formAction + '/' + data.favorite_tag_id)
      } else {
        $j('#ajax_flash').addClass('notice').text('You have successfully removed this tag from your favorite tags. It will no longer be listed on your homepage.');
        $j('input.submit_favorite_tag').val('Create Favorite Tag (JS)');
        $j('form.favorite_tag input[name="_method"]').remove();
        form.attr('action', formAction.replace(/\/\d+/, ''));
      }
    }
  });
});
