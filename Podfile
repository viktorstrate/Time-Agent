# Uncomment the next line to define a global platform for your project
platform :osx, '10.13'

target 'Time Agent' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  pod 'Sync', '~> 5'
  pod 'Stencil', '~> 0.13.1'

  # Pods for Time Agent

  target 'Time AgentUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CONFIGURATION_BUILD_DIR'] = '$PODS_CONFIGURATION_BUILD_DIR'
    end
  end
end
