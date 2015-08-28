Pod::Spec.new do |s|

  s.name     = 'ImojiSDKUI'
  s.version  = '0.1.0'
  s.license  = 'MIT'
  s.summary  = 'iOS UI Widgets for Imoji Integration.'
  s.homepage = 'http://imoji.io/sdk'
  s.authors = {'Nima Khoshini'=>'nima@imojiapp.com', 'Jeff Wang'=>'jeffkwang@gmail.com'}

  s.source   = { :git => 'https://github.com/imojiengineering/imoji-ios-sdk-ui.git', :tag => s.version.to_s }
  s.ios.deployment_target = '7.0'

  s.requires_arc = true

  s.subspec 'CollectionView' do |ss|
    ss.dependency "ImojiSDK/Core"
    ss.dependency "Masonry"

    ss.ios.source_files = 'Source/CollectionView/**/*.{h,m}'
    ss.ios.public_header_files = 'Source/CollectionView/*.h'
  end
  
end
