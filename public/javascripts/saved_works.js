$j('form.saved_work').on("click", function(event) {
  event.preventDefault();
  
  var form = $j('form.saved_work');
  var formAction = form.attr('action');
  
  $j.ajax({
    type: 'POST',
    url: formAction,
    data: form.serialize(),
    dataType: 'json',
    error: function(xhr, textStatus, err ) {
      alert('Sorry, something went wrong.');
    },
    success: function(data) { 
      if (data.saved_work_id) { 
        $j('input.submit_saved_work').val('Remove from saved list');
        form.append('<input name="_method" type="hidden" value="delete">');
        form.attr('action', formAction + '/' + data.saved_work_id)
      } else {
        $j('input.submit_saved_work').val('Add to saved list');
        $j('form.saved_work input[name="_method"]').remove();
        form.attr('action', formAction.replace(/\/\d+/, ''));
      }
    }
  });
});

$j('a.delete_saved_work').bind('ajax:complete', function() {
  $j(this).parents('li.blurb').hide();
});
