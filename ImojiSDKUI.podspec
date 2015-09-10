Pod::Spec.new do |s|

  s.name     = 'ImojiSDKUI'
  s.version  = '0.1.6'
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

  s.subspec 'Editor' do |ss|
    ss.dependency "ImojiSDK/Core"
    ss.dependency "Masonry"

    ss.preserve_paths = 'Frameworks/ImojiGraphics.framework'
    ss.public_header_files = 'Frameworks/ImojiGraphics.framework/Versions/A/Headers/*.h'
    ss.vendored_frameworks = 'Frameworks/ImojiGraphics.framework'

    ss.ios.resource_bundles = {'ImojiEditorAssets' => ['Source/Editor/Resources/Icons/*.png']}
  
    ss.ios.source_files = 'Source/Editor/**/*.{h,m}'
    ss.ios.public_header_files = 'Source/Editor/*.h'
    ss.ios.frameworks = ["Accelerate", "GLKit"]
    ss.libraries = 'c++'
  end

  s.subspec 'KeyboardView' do |ss|
    ss.dependency "ImojiSDKUI/CollectionView"
    
    ss.ios.source_files = 'Source/KeyboardView/Source/**/*.{h,m}'
    ss.ios.public_header_files = 'Source/KeyboardView/Source/**/*.h'
    ss.ios.resources = ["Source/KeyboardView/Resources/Fonts/*.otf", "Source/KeyboardView/Resources/StoryBoards/IMQwerty.storyboard", "Source/KeyboardView/Resources/KeyArt.xcassets"]
    ss.ios.resource_bundles = {'ImojiKeyboardAssets' => ['Source/KeyboardView/Resources/Icons/*.png']}

  end
  
end
