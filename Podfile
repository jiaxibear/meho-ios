# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'meho-ios' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for meho-ios

  pod 'AWSMobileClient', '~> 2.14.2'      # Required dependency
  pod 'AWSAuthUI', '~> 2.14.2'            # Optional dependency required to use drop-in UI
  pod 'AWSUserPoolsSignIn', '~> 2.14.2'   # Optional dependency required to use drop-in UI
  pod 'AWSAppSync', '~>3.1.3'             # Required dependency for hooking up graphQL api on aws
  pod 'AWSCore',  '~>2.14.0'
  pod 'AWSS3', '~> 2.14.2'

  pod 'Toast-Swift', '~> 5.0.1'

  # 3rd party Auth
#  pod 'AWSFacebookSignIn', '~> 2.14.2'
#  pod 'AWSGoogleSignIn', '~> 2.12.0'
#  pod 'GoogleSignIn', '~> 4.0'


  target 'meho-iosTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'meho-iosUITests' do
    # Pods for testing
  end

end
