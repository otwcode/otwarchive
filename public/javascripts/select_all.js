// To be included only where needed, currently tag_wranglings/index and tags/wrangle

$j(document).ready(function(){
  $j("#wrangle_all_select").click(function() {
    $j("#wrangulator").find(":checkbox[name='selected_tags[]']").each(function(index, ticky) {
        $j(ticky).prop("checked", true);
      });
  });
  $j("#wrangle_all_deselect").click(function() {
    $j("#wrangulator").find(":checkbox[name='selected_tags[]']").each(function(index, ticky) {
        $j(ticky).prop("checked", false);
      });
  });
  $j("#canonize_all_select").click(function() {
    $j("#wrangulator").find(":checkbox[name='canonicals[]']").each(function(index, ticky) {
        $j(ticky).prop("checked", true);
      });
  });
  $j("#canonize_all_deselect").click(function() {
    $j("#wrangulator").find(":checkbox[name='canonicals[]']").each(function(index, ticky) {
        $j(ticky).prop("checked", false);
      });
  });
})
