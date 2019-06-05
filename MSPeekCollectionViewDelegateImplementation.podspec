#
# Be sure to run `pod lib lint MSPeekCollectionViewDelegateImplementation.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MSPeekCollectionViewDelegateImplementation'
  s.version          = '1.3.0'
  s.summary          = 'A custom paging behavior that peeks the previous and next items in a collection view'
  s.swift_version    = '4.2'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Current design trends require complex designs which allow horizontal scrolling inside vertical scrolling. So to show the users that they can scroll vertically, a peeking item should be shown on the side. This library does exactly that.
I wrote this library because there's no pod that does this simple feature. Also, other libraries require me to inherit from a UICollectionViewController, which doesn't give alot of freedom if I'm inheriting from other View Controllers.
                       DESC

  s.homepage         = 'https://github.com/MaherKSantina/MSPeekCollectionViewDelegateImplementation'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Maher Santina' => 'maher.santina90@gmail.com' }
  s.source           = { :git => 'https://github.com/MaherKSantina/MSPeekCollectionViewDelegateImplementation.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9'

  s.source_files = 'MSPeekCollectionViewDelegateImplementation/Classes/**/*'
  
  # s.resource_bundles = {
  #   'MSPeekCollectionViewDelegateImplementation' => ['MSPeekCollectionViewDelegateImplementation/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
