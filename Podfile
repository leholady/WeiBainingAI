# Uncomment the next line to define a global platform for your project
# platform :ios, '15.0'

use_frameworks!
inhibit_all_warnings!
platform :ios, '15.0'

target 'WeiBainingAI' do
    pod 'WCDB.swift'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      config.build_settings['CODE_SIGN_IDENTITY'] = ''
      if config.name == 'Debug' and config.build_settings['SDKROOT'] == 'iphoneos'
        config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
      end
    end
  end
end
