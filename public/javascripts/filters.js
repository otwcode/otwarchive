// Expands a group of filters options if one of that type is selected
$j(document).ready(function() {
  showFilters();
  setupMobileFilters();
});

function showFilters() {
  var filters = $j('dd.tags');
    
  filters.each(function(index, filter) {
    var tags = $j(filter).find('input');
    var node = $j(filter);
    var open_toggles = $j('.' + node.attr('id') + "_open");
    var close_toggles = $j('.' + node.attr('id') + "_close");

    tags.each(function(index, tag) {
      if($j(tag).is(':checked')) {
        $j(filter).show();
        $j(open_toggles).hide();
        $j(close_toggles).show();
      } //is checked
    }); //tags each
  });  //filters each 
}; //showfilters

function setupMobileFilters() {
  var filters = $j('form.filters');
  var show_link = $j('#go_to_filters');
  var hide_link = $j(filters).find('.close');
  
  $j(show_link).click(function(event) {
    event.preventDefault();
    $j('#outer').addClass('filtering');
    $j(filters).find(hide_link).first().focus();
  });
  
  $j(hide_link).each(function() {
    $j(this).click(function(event) {
      event.preventDefault();
      $j('#outer').removeClass('filtering');
      $j(show_link).focus();
    });
  });
}