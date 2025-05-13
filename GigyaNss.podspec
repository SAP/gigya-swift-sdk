Pod::Spec.new do |spec|
  spec.name          = 'GigyaNss'
  spec.version       = '1.9.8'
  spec.license       = 'Apache 2.0'
  spec.homepage      = 'https://developers.gigya.com/display/GD/Native+Screen-Sets'
  spec.author       = 'Gigya SAP'
  spec.summary       = <<-DESC
                        This library enables you to use additional 
                        authentication methods from the standard login flow
                        DESC
  spec.source        = {:http => "https://github.com/SAP/gigya-swift-sdk/releases/download/nss%2Fv#{spec.version}/GigyaNss.zip"  }

  spec.module_name   = 'GigyaNss'
  spec.swift_version = '5.2'

  spec.platform = :ios
  spec.ios.deployment_target  = '11.0'
  spec.default_subspecs = 'Core'
  

  spec.subspec 'Core' do |ss|
     ss.source_files       = 'GigyaNss/*.swift', 'GigyaNss/*/*.swift', 'GigyaNss/*/*/*.swift'
     ss.exclude_files = 'GigyaNss/services/Otp/OtpService.swift'
     ss.vendored_frameworks = 'Flutter/Debug/Flutter.xcframework', 'Flutter/Debug/App.xcframework'
     ss.dependency 'Gigya', '>= 1.7.3'
     ss.framework      = 'SystemConfiguration'
     ss.library = 'c++', 'z'
     ss.resource_bundle = {
       "GigyaNss_Privacy" => "PrivacyInfo.xcprivacy"
     }
  end

  spec.subspec 'Auth' do |ss|
     ss.source_files       = 'GigyaNss/services/*/*.swift'
     ss.dependency 'GigyaAuth'
  end

  
end

