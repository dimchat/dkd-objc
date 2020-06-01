#
# Be sure to run `pod lib lint dkd-objc.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'dkd-objc'
  s.version          = '0.4.1'
  s.summary          = 'A Common Message Module for Decentralized Instant Messaging'
  s.homepage         = 'https://github.com/dimchat'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dim' => 'john.chen@infothinker.com' }
  s.source           = { :git => 'https://github.com/dimchat/dkd-objc.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'

  s.source_files = 'Classes/**/*'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
