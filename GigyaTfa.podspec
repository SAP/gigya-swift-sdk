Pod::Spec.new do |spec|
  spec.name          = 'GigyaTfa'
  spec.version       = '1.0.8'
  spec.license       = 'Apache 2.0'
  spec.homepage      = 'https://developers.gigya.com/display/GD/Swift+v1.x+TFA+Library'
  spec.author       = 'Gigya SAP'
  spec.summary       = <<-DESC
                        The Gigya Swift TFA package provides the ability to 
                        integrate native Two Factor Authentication flows 
                        within your Swift application without using the ScreenSets feature.
                        DESC

  spec.source        = { :git => 'https://github.com/SAP/gigya-swift-sdk.git', :tag => 'tfa/v1.0.8' }
  spec.module_name   = 'GigyaTfa'
  spec.swift_version = '5.2'

  spec.platform = :ios
  spec.ios.deployment_target  = '10.0'

  spec.source_files       = 'GigyaTfa/GigyaTfa/*.swift', 'GigyaTfa/GigyaTfa/*/*.swift', 'GigyaTfa/GigyaTfa/*/*/*.swift'

  spec.framework      = 'SystemConfiguration'
  spec.dependency 'Gigya'
  spec.library = 'c++', 'z'

end

