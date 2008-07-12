
require 'echoe'

Echoe.new("ultrasphinx") do |p|
  p.project = "fauna"
  p.summary = "Ruby on Rails configurator and client to the Sphinx fulltext search engine."
  p.url = "http://blog.evanweaver.com/files/doc/fauna/ultrasphinx/"  
  p.docs_host = "blog.evanweaver.com:~/www/bax/public/files/doc/"  
  p.rdoc_pattern = /is_indexed.rb|search.rb|spell.rb|ultrasphinx.rb|^README|TODO|DEPLOY|RAKE_TASKS|CHANGELOG|^LICENSE/
  p.dependencies = "chronic"
  p.test_pattern = ["test/integration/*.rb", "test/unit/*.rb"]
  p.rcov_options << '--include-file test\/integration\/app\/vendor\/plugins\/ultrasphinx\/lib\/.*\.rb --include-file '
end

desc "Run all the tests for every database adapter" 
task "test_all" do
  ['mysql', 'postgresql'].each do |adapter|
    ENV['DB'] = adapter
    ENV['PRODUCTION'] = nil
    STDERR.puts "#{'='*80}\nDevelopment mode for #{adapter}\n#{'='*80}"
    system("rake test:multi_rails:all")
  
    ENV['PRODUCTION'] = '1'
    STDERR.puts "#{'='*80}\nProduction mode for #{adapter}\n#{'='*80}"
    system("rake test:multi_rails:all")    
  end
end