garlic do
  repo 'nested_has_many_through', :path => '.'
  
  repo 'rails', :url => 'git://github.com/rails/rails'
  repo 'rspec', :url => 'git://github.com/dchelimsky/rspec'
  repo 'rspec-rails', :url => 'git://github.com/dchelimsky/rspec-rails'
  
  # target rails versions
  ['2-3-stable', '2-2-stable', '2-1-stable'].each do |rails|
    target rails, :branch => "origin/#{rails}" do
      prepare do
        plugin 'rspec'
        plugin 'rspec-rails' do
          `script/generate rspec -f`
        end
        plugin 'nested_has_many_through', :clone => true
      end

      run do
        cd "vendor/plugins/nested_has_many_through" do
          sh "rake spec:rcov:verify"
        end
      end
    end
  end
end
