Pod::Spec.new do |s|
  s.name             = 'SwiftCurrent'
  s.version          = '4.4.4'
  s.summary          = 'A library for complex workflows in Swift'
  s.description      = <<-DESC
  SwiftCurrent is a library that lets you easily manage journeys through your Swift application.
                       DESC

  s.homepage         = 'https://github.com/wwt/SwiftCurrent'
  s.license          = { :type => 'Custom', :file => 'LICENSE' }
  s.author           = { 'World Wide Technology, Inc.' => 'SwiftCurrent@wwt.com' }
  s.source           = { :git => 'https://github.com/wwt/SwiftCurrent.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.tvos.deployment_target = '14.0'
  s.swift_version = '5.1'

  s.module_name = 'SwiftCurrent'

  s.subspec 'Core' do |ss|
    ss.ios.deployment_target = '11.0'
    ss.macos.deployment_target = '11.0'
    ss.tvos.deployment_target = '14.0'
    ss.watchos.deployment_target = '7.0'
    ss.source_files = 'Sources/SwiftCurrent/**/*.{swift,h,m}'
  end
  
  s.subspec 'UIKit' do |ss|
    ss.ios.deployment_target = '11.0'
    ss.tvos.deployment_target = '14.0'
    ss.source_files = 'Sources/SwiftCurrent_UIKit/**/*.{swift,h,m}'
    ss.dependency 'SwiftCurrent/Core'
  end

  s.subspec 'BETA_SwiftUI' do |ss|
    ss.ios.deployment_target = '11.0'
    ss.macos.deployment_target = '11.0'
    ss.tvos.deployment_target = '14.0'
    ss.watchos.deployment_target = '7.0'
    ss.source_files = 'Sources/SwiftCurrent_SwiftUI/**/*.{swift,h,m}'
    ss.dependency 'SwiftCurrent/Core'
  end
  
  s.subspec 'Testing' do |ss|
    ss.ios.deployment_target = '11.0'
    ss.macos.deployment_target = '11.0'
    ss.tvos.deployment_target = '14.0'
    # ss.watchos.deployment_target = '7.0' # Xcode 12.4 is unable to lib lint this. When the pipeline is moved to 12.5 we can comment this back in.
    ss.source_files = ['Sources/SwiftCurrent_Testing/**/*.{swift,h,m}', 'Sources/SwiftCurrent_Testing_ObjC/**/*.{swift,h,m}']
    ss.exclude_files = 'Sources/SwiftCurrent_Testing_ObjC/*-Bridging-Header.h'
    ss.dependency 'SwiftCurrent/Core'
    ss.weak_framework = "XCTest"
    ss.pod_target_xcconfig = {
      'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "$(PLATFORM_DIR)/Developer/Library/Frameworks"',
    }
  end
end
