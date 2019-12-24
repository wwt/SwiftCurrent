source 'https://cdn.cocoapods.org/'
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def shared_pods
  pod 'Swinject'
end

target 'Workflow' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  shared_pods
  
  target 'WorkflowTests' do
    inherit! :search_paths
    shared_pods
    pod 'UIUTest'
    pod 'CwlPreconditionTesting', :git => 'https://github.com/mattgallagher/CwlPreconditionTesting.git', :tag => '1.2.0'
    pod 'CwlCatchException', :git => 'https://github.com/mattgallagher/CwlCatchException.git', :tag => '1.2.0'
    # Pods for testing
  end
  
  target 'DependencyInjectionTests' do
    shared_pods
  end
  
end

target 'WorkflowExample' do
  use_frameworks!
  
  pod 'DynamicWorkflow', :path => '.'
  pod 'DynamicWorkflow/Swinject', :path => '.'
  
  target 'WorkflowExampleTests' do
    pod 'DynamicWorkflow', :path => '.'
    pod 'UIUTest'
  end
  
end
