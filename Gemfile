source "https://rubygems.org" 
ruby "2.6.6" 

gem "fastlane"
gem 'activesupport'
gem 'builder', '3.2.2'
gem 'tilt', '2.0.10'
gem "rake"
gem "fastlane-plugin-appcenter"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
