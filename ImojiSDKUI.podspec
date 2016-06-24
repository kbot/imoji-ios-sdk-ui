Pod::Spec.new do |s|

  s.name     = 'ImojiSDKUI'
  s.version  = '2.1.2'
  s.license  = 'MIT'
  s.summary  = 'iOS UI Widgets for Imoji Integration. Integrate Stickers and custom emojis into your applications easily!'
  s.homepage = 'https://imoji.io/developers'
  s.authors = {'Alex Hoang'=>'alex@imojiapp.com', 'Nima Khoshini'=>'nima@imojiapp.com', 'Jeff Wang'=>'jeffkwang@gmail.com'}

  s.source   = { :git => 'https://github.com/imojiengineering/imoji-ios-sdk-ui.git', :tag => s.version.to_s }
  s.ios.deployment_target = '7.0'

  s.requires_arc = true
  s.default_subspec = 'CollectionView'

  s.subspec 'CollectionView' do |ss|
    ss.dependency "YYImage/WebP", "~> 1.0"
    ss.dependency "ImojiSDK/Core"
    ss.dependency "ImojiSDKUI/Common"
    ss.dependency "Masonry", "1.0.0"

    ss.ios.source_files = 'Source/CollectionView/**/*.{h,m}'
    ss.ios.public_header_files = 'Source/CollectionView/*.h'
  end

  s.subspec 'Editor' do |ss|
    ss.dependency "ImojiSDK/Core"
    ss.dependency "ImojiSDKUI/Common"
    ss.dependency "Masonry", "1.0.0"

    ss.vendored_frameworks = 'Frameworks/ImojiGraphics.framework'

    ss.ios.resource_bundles = {'ImojiEditorAssets' => ['Source/Editor/Resources/Icons/*.png', 'Source/Editor/Resources/Images/*.png']}
  
    ss.ios.source_files = 'Source/Editor/**/*.{h,m}'
    ss.ios.public_header_files = 'Source/Editor/*.h'
    ss.ios.frameworks = ["Accelerate", "GLKit"]
    ss.libraries = 'c++'
  end

  s.subspec 'Common' do |ss|
    ss.ios.source_files = 'Source/Common/Source/**/*.{h,m}'
    ss.ios.resource_bundles = {'ImojiUIStrings' => ['Source/Common/Resources/Localization/*.lproj'], 'ImojiUIAssets' => ['Source/Common/Resources/Images/*.*'], 'ImojiUIFonts' => ["Source/Common/Resources/Fonts/*.otf"]}

  end
  
end
