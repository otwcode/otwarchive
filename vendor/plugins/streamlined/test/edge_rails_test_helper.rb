module EdgeRailsTestHelper
  # prepare our test environment by doing stuff that normally happens via the plugin init process
  def self.bootstrap_test_environment_for_edge
    ActionView::Base.send(:include, Streamlined::Helper)
    ActionController::Base.view_paths = [File.join(RAILS_ROOT, 'app', 'views')]

    %W(#{STREAMLINED_ROOT}/templates
       #{STREAMLINED_ROOT}/templates/shared
       #{STREAMLINED_ROOT}/templates/generic_views
       #{STREAMLINED_ROOT}/templates/relationships/edit_views
       #{STREAMLINED_ROOT}/templates/relationships/edit_views/filter_select
       #{STREAMLINED_ROOT}/templates/relationships/show_views
     ).each do |path|
       ActionController::Base.append_view_path(path)
     end
  end
end