# Uncomment the next line to define a global platform for your project
#platform :ios, '13.0'

target 'LivenessMask' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks! :linkage => :static
  inherit! :search_paths

  # Pods for LivenessMask
  pod 'lottie-ios', '4.4.1'

  target 'LivenessMaskTests' do
    # Pods for testing
  end

end

use_frameworks!
target 'Sample' do
  # Comment the next line if you don't want to use dynamic frameworks
  

  # Pods for Sample

  target 'SampleTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'SampleUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
#    target.build_configurations.each do |config|
#    xcconfig_path = config.base_configuration_reference.real_path
#    xcconfig = File.read(xcconfig_path)
#    xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
#    File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
#    end
    target.build_configurations.each do |config|
      #config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
    end
  end
end
