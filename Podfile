# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'vivally' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for vivally
  pod 'Alamofire', '~> 5.2'
  pod 'ContextMenu'
  pod 'FSCalendar'
  pod 'IQKeyboardManagerSwift'
  pod 'SwiftKeychainWrapper'
  pod 'SQLite.swift', '~> 0.14.0'
  pod 'MaterialComponents/Slider'
  pod 'JWTDecode', '~> 2.6'
  pod 'MaterialComponents/TextControls+FilledTextAreas'
  pod 'MaterialComponents/TextControls+FilledTextFields'
  pod 'MaterialComponents/TextControls+OutlinedTextAreas'
  pod 'MaterialComponents/TextControls+OutlinedTextFields'
  pod 'lottie-ios', '~> 3.2.3'
  pod 'Charts', '~> 4.1.0'
  pod 'Firebase/Analytics'
  pod 'Firebase/Messaging'
  pod 'Toast-Swift', '~> 5.0.1'
  pod 'PhoneNumberKit', '~> 3.3'
  pod 'DropDown'
  pod 'IOSSecuritySuite'
end

target 'vivallyStaging' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for vivally
  pod 'Alamofire', '~> 5.2'
  pod 'ContextMenu'
  pod 'FSCalendar'
  pod 'IQKeyboardManagerSwift'
  pod 'SwiftKeychainWrapper'
  pod 'SQLite.swift', '~> 0.14.0'
  pod 'MaterialComponents/Slider'
  pod 'JWTDecode', '~> 2.6'
  pod 'MaterialComponents/TextControls+FilledTextAreas'
  pod 'MaterialComponents/TextControls+FilledTextFields'
  pod 'MaterialComponents/TextControls+OutlinedTextAreas'
  pod 'MaterialComponents/TextControls+OutlinedTextFields'
  pod 'lottie-ios', '~> 3.2.3'
  pod 'Charts', '~> 4.1.0'
  pod 'Firebase/Analytics'
  pod 'Firebase/Messaging'
  pod 'Toast-Swift', '~> 5.0.1'
  pod 'PhoneNumberKit', '~> 3.3'
  pod 'DropDown'
  pod 'IOSSecuritySuite'
end

target 'vivallyTests' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for vivally
  pod 'Alamofire', '~> 5.2'
  pod 'ContextMenu'
  pod 'FSCalendar'
  pod 'IQKeyboardManagerSwift'
  pod 'SwiftKeychainWrapper'
  pod 'SQLite.swift', '~> 0.14.0'
  pod 'MaterialComponents/Slider'
  pod 'JWTDecode', '~> 2.6'
  pod 'MaterialComponents/TextControls+FilledTextAreas'
  pod 'MaterialComponents/TextControls+FilledTextFields'
  pod 'MaterialComponents/TextControls+OutlinedTextAreas'
  pod 'MaterialComponents/TextControls+OutlinedTextFields'
  pod 'lottie-ios', '~> 3.2.3'
  pod 'Charts', '~> 4.1.0'
  pod 'Toast-Swift', '~> 5.0.1'
  pod 'PhoneNumberKit', '~> 3.3'
end


post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
               end
          end
   end
end
