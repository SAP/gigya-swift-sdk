Pod::Spec.new do |spec|
  spec.name          = 'GigyaAuth'
  spec.version       = '1.1.2'
  spec.license       = 'Apache 2.0'
  spec.homepage      = 'https://developers.gigya.com/display/GD/Swift+Authentication+Library'
  spec.author       = 'Gigya SAP'
  spec.summary       = <<-DESC
                        This library enables you to use additional 
                        authentication methods from the standard login flow
                        DESC

  spec.source        = { :git => 'https://github.com/SAP/gigya-swift-sdk.git', :tag => 'auth/v1.1.2' }
  spec.module_name   = 'GigyaAuth'
  spec.swift_version = '5.3'

  spec.platform = :ios
  spec.ios.deployment_target  = '11.0'

  spec.source_files       = 'GigyaAuth/GigyaAuth/*.swift', 'GigyaAuth/GigyaAuth/*/*.swift', 'GigyaAuth/GigyaAuth/*/*/*.swift'

  spec.resource_bundle = {
    "GigyaAuth_Privacy" => "GigyaAuth/PrivacyInfo.xcprivacy"
  }
  spec.framework      = 'SystemConfiguration'
  spec.dependency 'Gigya' , '>= 1.6.0'
  spec.library = 'c++', 'z'

end

