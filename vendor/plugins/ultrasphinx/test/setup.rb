
# Setup integration system for the integration suite

Dir.chdir "#{File.dirname(__FILE__)}/integration/app/" do
  system("killall searchd")
  system("rm -rf /tmp/sphinx")
  system("rm -rf config/ultrasphinx/development.conf")
  Dir.chdir "vendor/plugins" do
    system("rm ultrasphinx; ln -s ../../../../../ ultrasphinx")
  end
  system("rake db:create")
  system("rake db:migrate db:fixtures:load")
  system("rake us:boot")
  system("rm /tmp/ultrasphinx-stopwords.txt")
  system("rake ultrasphinx:spelling:build")
end
