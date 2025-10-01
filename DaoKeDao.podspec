#
# Be sure to run `pod lib lint dkd-objc.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name                  = 'DaoKeDao'
    s.version               = '1.0.0'
    s.summary               = 'Decentralized Instant Messaging'
    s.description           = <<-DESC
            A Common Message Module for Decentralized Instant Messaging
                              DESC
    s.homepage              = 'https://github.com/dimchat/dkd-objc'
    s.license               = { :type => 'MIT', :file => 'LICENSE' }
    s.author                = { 'Albert Moky' => 'albert.moky@gmail.com' }
    s.source                = { :git => 'https://github.com/dimchat/dkd-objc.git', :tag => s.version.to_s }
    # s.platform            = :ios, "12.0"
    s.ios.deployment_target = '12.0'

    s.source_files          = 'Classes', 'Classes/**/*.{h,m}'
    # s.exclude_files       = 'Classes/Exclude'
    s.public_header_files   = 'Classes/**/*.h'

    # s.frameworks          = 'Security'
    # s.requires_arc        = true

    s.dependency 'MingKeMing', '~> 1.0.0'
end
