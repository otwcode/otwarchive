// Expands a group of filters options if one of that type is selected
$j(document).ready(function() {
  showFilters();
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
} //showfilters
