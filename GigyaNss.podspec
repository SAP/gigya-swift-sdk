Pod::Spec.new do |spec|
  spec.name          = 'GigyaNss'
  spec.version       = '1.9.1'
  spec.license       = 'Apache 2.0'
  spec.homepage      = 'https://developers.gigya.com/display/GD/Native+Screen-Sets'
  spec.author       = 'Gigya SAP'
  spec.summary       = <<-DESC
                        This library enables you to use additional 
                        authentication methods from the standard login flow
                        DESC

  spec.source        = { :git => 'https://github.com/SAP/gigya-swift-sdk.git', :tag => 'nss/v1.9.1' }
  spec.module_name   = 'GigyaNss'
  spec.swift_version = '5.2'

  spec.platform = :ios
  spec.ios.deployment_target  = '11.0'
  spec.default_subspecs = 'Core'
  

  spec.subspec 'Core' do |ss|
     ss.source_files       = 'GigyaNss/GigyaNss/*.swift', 'GigyaNss/GigyaNss/*/*.swift', 'GigyaNss/GigyaNss/*/*/*.swift'
     ss.exclude_files = 'GigyaNss/GigyaNss/services/Otp/OtpService.swift'

     ss.dependency 'Gigya', '>= 1.5.7'
     ss.framework      = 'SystemConfiguration'
     ss.library = 'c++', 'z'
     ss.vendored_frameworks = 'GigyaNss/Flutter/Debug/Flutter.xcframework', 'GigyaNss/Flutter/Debug/App.xcframework'
  end

  spec.subspec 'Auth' do |ss|
     ss.source_files       = 'GigyaNss/GigyaNss/services/*/*.swift'
     ss.dependency 'GigyaAuth'
  end



  
end

