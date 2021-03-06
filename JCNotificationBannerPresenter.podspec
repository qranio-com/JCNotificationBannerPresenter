Pod::Spec.new do |s|
  s.name         = 'JCNotificationBannerPresenter'
  s.platform      = :ios, '5.0'
  s.version      = '1.1.99'
  s.summary      = 'A library for generic presentation of "banners" (e.g. to present a push notification) from anywhere inside an iOS app.'
  s.license      = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.homepage     = 'https://github.com/jcoleman/JCNotificationBannerPresenter'
  s.author       = { 'James Coleman' => 'jtc331@gmail.com' }
  s.requires_arc = true
  s.framework    = 'QuartzCore'
  s.source       = { :git => 'https://github.com/qranio-com/JCNotificationBannerPresenter.git', :tag => s.version }
  s.source_files = 'Library/*.{h,m}'
  s.dependency 'UIActivityIndicator-for-SDWebImage+UIButton'
end
