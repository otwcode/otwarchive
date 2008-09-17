Gem::Specification.new do |s|
  s.name = %q{thinking-sphinx}
  s.version = "0.9.9"

  s.specification_version = 2 if s.respond_to? :specification_version=

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Pat Allan"]
  s.date = %q{2008-08-22}
  s.description = %q{A concise and easy-to-use Ruby library that connects ActiveRecord to the Sphinx search daemon, managing configuration, indexing and searching.}
  s.email = %q{pat@freelancing-gods.com}
  s.files = ["lib/riddle/client/filter.rb", "lib/riddle/client/message.rb", "lib/riddle/client/response.rb", "lib/riddle/client.rb", "lib/riddle.rb", "lib/test.rb", "lib/thinking_sphinx/active_record/delta.rb", "lib/thinking_sphinx/active_record/has_many_association.rb", "lib/thinking_sphinx/active_record/search.rb", "lib/thinking_sphinx/active_record.rb", "lib/thinking_sphinx/association.rb", "lib/thinking_sphinx/attribute.rb", "lib/thinking_sphinx/collection.rb", "lib/thinking_sphinx/configuration.rb", "lib/thinking_sphinx/field.rb", "lib/thinking_sphinx/index/builder.rb", "lib/thinking_sphinx/index/faux_column.rb", "lib/thinking_sphinx/index.rb", "lib/thinking_sphinx/rails_additions.rb", "lib/thinking_sphinx/search.rb", "lib/thinking_sphinx.rb", "LICENCE", "README", "tasks/thinking_sphinx_tasks.rb", "tasks/thinking_sphinx_tasks.rake", "spec/unit/thinking_sphinx/active_record/delta_spec.rb", "spec/unit/thinking_sphinx/active_record/has_many_association_spec.rb", "spec/unit/thinking_sphinx/active_record/search_spec.rb", "spec/unit/thinking_sphinx/active_record_spec.rb", "spec/unit/thinking_sphinx/association_spec.rb", "spec/unit/thinking_sphinx/attribute_spec.rb", "spec/unit/thinking_sphinx/configuration_spec.rb", "spec/unit/thinking_sphinx/field_spec.rb", "spec/unit/thinking_sphinx/index/builder_spec.rb", "spec/unit/thinking_sphinx/index/faux_column_spec.rb", "spec/unit/thinking_sphinx/index_spec.rb", "spec/unit/thinking_sphinx/search_spec.rb", "spec/unit/thinking_sphinx_spec.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://ts.freelancing-gods.com}
  s.rdoc_options = ["--title", "Thinking Sphinx -- Rails/Merb Sphinx Plugin", "--line-numbers"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{thinking-sphinx}
  s.rubygems_version = %q{1.1.1}
  s.summary = %q{A concise and easy-to-use Ruby library that connects ActiveRecord to the Sphinx search daemon, managing configuration, indexing and searching.}
  s.test_files = ["spec/unit/thinking_sphinx/active_record/delta_spec.rb", "spec/unit/thinking_sphinx/active_record/has_many_association_spec.rb", "spec/unit/thinking_sphinx/active_record/search_spec.rb", "spec/unit/thinking_sphinx/active_record_spec.rb", "spec/unit/thinking_sphinx/association_spec.rb", "spec/unit/thinking_sphinx/attribute_spec.rb", "spec/unit/thinking_sphinx/configuration_spec.rb", "spec/unit/thinking_sphinx/field_spec.rb", "spec/unit/thinking_sphinx/index/builder_spec.rb", "spec/unit/thinking_sphinx/index/faux_column_spec.rb", "spec/unit/thinking_sphinx/index_spec.rb", "spec/unit/thinking_sphinx/search_spec.rb", "spec/unit/thinking_sphinx_spec.rb"]
end
