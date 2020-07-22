Pod::Spec.new do |spec|
  spec.name          = 'Gigya'
  spec.version       = '1.1.2'
  spec.license       = { type => 'Apache 2.0', file: 'LICENSE.txt' }
  spec.homepage      = 'https://developers.gigya.com/display/GD/Swift+SDK'
  spec.authors       = { 'Gigya SAP' }
  spec.summary       = 'The Swift SDK provides an interface for the Gigya API. The library makes it simple to integrate Gigya's service in your Swift application'
  spec.source        = { :git => 'https://github.com/SAP/gigya-swift-sdk', :tag => 'v1.1.2' }
  spec.module_name   = 'Gigya'
  spec.swift_version = '5.2'

  spec.platform = :ios
  spec.ios.deployment_target  = '10.0'

  spec.source_files       = 'GigyaSwift/*.swift'
  
  spec.framework      = 'SystemConfiguration'
  spec.ios.framework  = 'UIKit'
  spec.library = 'c++', 'z'  

end
