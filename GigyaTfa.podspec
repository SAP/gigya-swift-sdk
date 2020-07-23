Pod::Spec.new do |spec|
  spec.name          = 'GigyaTfa'
  spec.version       = '1.0.8'
  spec.license       = 'Apache 2.0'
  spec.homepage      = 'https://developers.gigya.com/display/GD/Swift+SDK'
  spec.author       = 'Gigya SAP'
  spec.summary       = <<-DESC
                        The Swift SDK provides an interface for the Gigya API.
                        The library makes it simple to integrate Gigya's service in
                        your Swift application
                        DESC

  spec.source        = { :git => 'https://github.com/SAP/gigya-swift-sdk.git', :tag => 'tfa/v1.0.8' }
  spec.module_name   = 'GigyaTfa'
  spec.swift_version = '5.2'

  spec.platform = :ios
  spec.ios.deployment_target  = '10.0'

  spec.source_files       = 'GigyaTfa/GigyaTfa/*.swift', 'GigyaTfa/GigyaTfa/*/*.swift', 'GigyaTfa/GigyaTfa/*/*/*.swift'

  spec.framework      = 'SystemConfiguration'
  spec.dependency = 'Gigya'
  spec.library = 'c++', 'z'

end

