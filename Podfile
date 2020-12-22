# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'meho-ios' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for meho-ios

  pod 'AWSMobileClient', '~> 2.15.0'      # Required dependency
  pod 'AWSAuthUI', '~> 2.15.0'            # Optional dependency required to use drop-in UI
  pod 'AWSUserPoolsSignIn', '~> 2.15.0'   # Optional dependency required to use drop-in UI
  pod 'AWSAppSync', '~>3.1.5'             # Required dependency for hooking up graphQL api on aws
  pod 'AWSCore',  '~>2.15.0'
  pod 'AWSS3', '~> 2.15.0'
  pod 'Amplify', '~> 1.2.0'
  pod 'AmplifyPlugins/AWSCognitoAuthPlugin', '~> 1.2.0'
  pod 'AmplifyPlugins/AWSS3StoragePlugin', '~> 1.2.0'
  pod 'AmplifyPlugins/AWSCognitoAuthPlugin', '~> 1.2.0'

  pod 'Toast-Swift', '~> 5.0.1'
  pod 'Kingfisher', '~> 5.15'

  # add the Firebase pod for Google Analytics
  pod 'Firebase/Analytics'
  # add pods for any other desired Firebase products
  # https://firebase.google.com/docs/ios/setup#available-pods

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
