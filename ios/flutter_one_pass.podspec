#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_one_pass.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_one_pass'
  s.version          = '0.0.1'
  s.summary          = 'geetest flutter onePass plugin'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'https://github.com/Mzrong/flutter_one_pass'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'zrong' => 'zengrong27@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'
  s.static_framework = true
  
  # sdk
  s.dependency 'GTOneLoginSDK'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
