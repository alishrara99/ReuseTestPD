#
# Be sure to run `pod lib lint ReuseTestPD.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ReuseTestPD'
  s.version          = '0.1.1'
  s.summary          = 'Description of ReuseTestPD.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  "Long description of ReuseTestPD"
                       DESC

  s.homepage         = 'https://github.com/alishrara99/ReuseTestPD'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ali Shrara' => 'alishrara_99@outlook.com' }
  s.source           = { :git => 'https://github.com/alishrara99/ReuseTestPD.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'

  s.source_files = 'ReuseTestPD/Classes/**/*'
  s.swift_version = '5.0'
  
  s.platforms = {
      "ios": "13.0"
  }
  # s.resource_bundles = {
  #   'ReuseTestPD' => ['ReuseTestPD/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
