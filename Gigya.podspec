Pod::Spec.new do |spec|
  spec.name          = 'Gigya'
  spec.version       = '1.1.6'
  spec.license       = 'Apache 2.0'
  spec.homepage      = 'https://developers.gigya.com/display/GD/Swift+SDK'
  spec.author       = 'Gigya SAP'
  spec.summary       = <<-DESC
			The Swift SDK provides an interface for the Gigya API.
			The library makes it simple to integrate Gigya's service in
			your Swift application
			DESC

  spec.source        = { :git => 'https://github.com/SAP/gigya-swift-sdk.git', :tag => 'core/v1.1.6' }
  spec.module_name   = 'Gigya'
  spec.swift_version = '5.3'

#  spec.platform = :ios
  spec.ios.deployment_target  = '10.0'

  spec.source_files       = 'GigyaSwift/*/*.swift', 'GigyaSwift/*/*/*.swift', 'GigyaSwift/*/*/*/*.swift', 'GigyaSwift/*/*/*/*/*.swift'
  
  spec.framework      = 'SystemConfiguration'
  spec.library = 'c++', 'z'

end
