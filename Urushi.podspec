#
# Be sure to run `pod lib lint Urushi.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Urushi'
  s.version          = '0.1.1'
  s.summary          = 'Persist `Glossy` structs.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Urushi lets you use a `Glossy` struct as a persistent store.  Your struct is JSON serialized and persisted in `UserDefaults.shared`.  Setting values in your struct will update what is stored in `UserDefaults.shared`.  Put a static instance in your `AppDelegate` or something like that.  Then just set it (the `model`) and forget it!
                       DESC

  s.homepage         = 'https://github.com/71241NW123CK/Urushi-Swift'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ryan Hiroaki Tsukamoto' => 'backward6@gmail.com' }
  s.source           = { :git => 'https://github.com/71241NW123CK/Urushi-Swift.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.3'

  s.source_files = 'Urushi/Classes/**/*'
  
  # s.resource_bundles = {
  #   'Urushi' => ['Urushi/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Gloss', '~> 2.0'
end
