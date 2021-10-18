# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

workspace 'GigyaSwift.xcworkspace'

target 'TestApp' do
#  workspace 'GigyaSwift.xcodeproj'

  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for TestApp
  pod 'LineSDKSwift', '~> 5.0'

  pod 'GoogleSignIn', '6.0.1', :modular_headers => false
  pod 'FBSDKCoreKit', '7.0.1'
  pod 'FBSDKLoginKit', '7.0.1'

  pod 'Firebase/Analytics'
  pod 'Firebase/Messaging'


end


target 'GigyaE2ETestsApp' do
  project 'GigyaE2ETestsApp/GigyaE2ETestsApp.xcodeproj'

  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for TestApp
  pod 'GoogleSignIn', :modular_headers => false
  pod 'FBSDKCoreKit'
  pod 'FBSDKLoginKit'
  pod 'LineSDK', '~> 4.0.1'

end
