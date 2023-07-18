source "https://rubygems.org"

# CIs use following versions
# (as of Oct 2019)
# gitlab.yalantis.com uses Ruby 2.4.2 (i.e. ruby "~> 2.4")
# For any additional Ruby version please contact DevOps and then specify appropriate version here.
ruby "~> 2.4"

# You may want to select different version of the CocoaPods to match your local version if needed (i.e. 1.6)
gem "cocoapods", "~> 1.8", :groups => [:default, :local]
# You may want to select different version of the Fastlane to match your local version if needed.
gem "fastlane", "~> 2.0", :groups => [:default, :local]

# CI-related gems. Do not change versions unless approved by CI maintainers or you really know what you're doing.
gem "danger-gitlab", "~> 7.0", :groups => [:default, :ci]
gem 'danger-swiftlint', "~> 0.1", :groups => [:default, :ci]
gem "danger", "~> 6.0", :groups => [:default, :ci]

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
