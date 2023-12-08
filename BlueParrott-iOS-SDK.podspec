=begin
BlueParrott iOS SDK Public Podspec

This is the Podspec for the public release of the 
BlueParrott iOS SDK. It is uploaded to the Cocoapods
repository to allow clients to download and use the 
binary distribution. 
=end

Pod::Spec.new do |spec|
  spec.name           		= 'BlueParrott-iOS-SDK'
  spec.module_name           	= 'BPHeadset'
  spec.version        		= '4.3.5'
  spec.license        		= 'Apache License 2.0'
  spec.homepage       		= 'https://www.blueparrott.com/software/blueparrott-sdk'
  spec.authors        		= 'GN Audio'
  spec.summary                  = 'Jabra Perform BlueParrott iOS SDK'
  spec.description        	= 'The Jabra Perform BlueParrott iOS SDK provides developer access to the programmable BlueParrott Button™ or configurable button found on premium BlueParrott headsets or Jabra Perform Series Headsets allowing for control of select functions and activities within a mobile application directly from the headset.'
  spec.source         		= {
    :git => 'https://github.com/gna-sw/Jabra-Perform-BlueParrott-iOS-SDK.git',
    :tag => 'v4.3.5'
  }
  spec.vendored_frameworks	= 'BP_SDK_iOS*/BPHeadset.xcframework'
  spec.ios.deployment_target 	= '12.1'
end
