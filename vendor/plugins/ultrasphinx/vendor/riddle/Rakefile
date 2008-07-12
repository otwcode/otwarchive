require 'rake'
require 'rake/rdoctask'
require 'spec/rake/spectask'
require 'rdoc/rdoc'
require 'rdoc/generators/html_generator'
require 'rdoc/generators/template/html/html'

module Generators
  class HtmlFile < ContextUser
    alias_method :core_attribute_values, :file_attribute_values
    
    def file_attribute_values
      core_attribute_values
      
      @values["analytics"] = @options.analytics if @options.analytics
    end
  end
  
  class HtmlClass < ContextUser
    alias_method :core_attribute_values, :class_attribute_values
    
    def class_attribute_values
      core_attribute_values
      
      @values["analytics"] = @options.analytics if @options.analytics
    end
  end
end

class Options
  attr_accessor :analytics
  
  module OptionList
    OPTION_LIST << [
      "--analytics", "-y", "code", "Google Analytics Code"
    ]
  end
  
  alias_method :core_parse, :parse
  
  def parse(argv, generators)
    core_parse(argv, generators)
    
    old_args = ARGV.dup
    ARGV.replace(argv)
        
    go = GetoptLong.new(*OptionList.options)
    go.quiet = true
    
    go.each do |opt, arg|
      case opt
      when "--analytics"
        @analytics = arg.strip
      end
    end
    
    ARGV.replace(old_args)
  end
    
end

module RDoc
  module Page
    remove_const :FOOTER
    const_set :FOOTER, %{
    <div id="validator-badges">
      <p><small><a href="http://validator.w3.org/check/referer">[Validate]</a></small></p>
    </div>
    <script src="http://www.google-analytics.com/urchin.js" type="text/javascript">
    </script>
    <script type="text/javascript">
      _uacct = "%analytics%";
      urchinTracker();
    </script>
    
    </body>
    </html>
    }
    
    remove_const :BODY
    const_set :BODY, HEADER + %{

    !INCLUDE!  <!-- banner header -->

      <div id="bodyContent">

    } +  METHOD_LIST + %{

      </div>

    } + FOOTER
  end
end

desc 'Generate documentation'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Riddle - Ruby Sphinx Client'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.options << '-y US-2475317-6'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Run Riddle's specs"
Spec::Rake::SpecTask.new do |t|
  t.libs << 'lib'
  t.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |t|
  t.libs << 'lib'
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec', '--exclude', 'gems']
end