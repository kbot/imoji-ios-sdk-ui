[![Pod Version](http://img.shields.io/cocoapods/v/ImojiSDKUI.svg?style=flat)](http://cocoadocs.org/docsets/ImojiSDKUI/)
[![Pod Platform](http://img.shields.io/cocoapods/p/ImojiSDKUI.svg?style=flat)](http://cocoadocs.org/docsets/ImojiSDKUI/)
[![Pod License](http://img.shields.io/cocoapods/l/ImojiSDKUI.svg?style=flat)](https://github.com/imojiengineering/imoji-ios-sdk-ui/blob/master/LICENSE.md)

# Imoji SDK UI

A collection of powerful open source UI widgets leveraging the [Imoji SDK](https://github.com/imojiengineering/imoji-ios-sdk). 

For full documentation details, go to [developer.imoji.io](https://developer.imoji.io/#/home#platform-ios) for more info.

## Check out Samples

Our sample app demonstrates the full capabilities of integrating Imoji into your app.

Get the Source

```bash
git clone https://github.com/imojiengineering/imoji-ios-sdk-ui.git
```

Build the ImojiKit project

```bash
cd imoji-ios/sdk-ui/Examples/ImojiKit
pod install
open imoji-kit.xcworkspace
```

Launch the app to discover the various components offered by our Open Source UI Kit ImojiSDKUI.

For an example of integrating in Swift 2.0 checkout the Artmoji example.

```bash
cd imoji-ios-sdk-ui/Examples/Artmoji
pod install
open artmoji.xcworkspace
```

## Integrate

Add ImojiSDKUI to your Podfile

```bash
pod 'ImojiSDKUI'
```
Build your project

```bash
pod install
```

Initiate ImojiSDK credentials. You can add this to the 

```objective-c
application:didFinishLaunchingWithOptions: method of AppDelegate
[[ImojiSDK sharedInstance] setClientId:[[NSUUID alloc] initWithUUIDString:@"your-client-id"]
                              apiToken:@"your-client-secret"];
```

Display the Imoji Collection View Controller

```bash
IMImojiSession *session = [IMImojiSession imojiSession];
IMCollectionViewController *viewController = [IMCollectionViewController collectionViewControllerWithSession:session];
    [self presentViewController:viewController animated:YES completion:^{
        [viewController.collectionView loadImojiCategoriesWithOptions:
                [IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationTrending]
        ];
    }];
```
    

## Customize

Depending on your application, you may decide to show stickers with IMCollectionViewController or integrate the components into your view hierarchy.
For apps seeking to achieve the latter, we offer 3 different form factors for our sticker selector component:

The simplest way to display the full screen sticker picker is by creating a new IMCollectionViewController instance:

```objective-c
IMImojiSession *session = [IMImojiSession imojiSession];
IMCollectionViewController *viewController = [IMCollectionViewController collectionViewControllerWithSession:session];
viewController.collectionViewControllerDelegate = self;
 
[self presentViewController:viewController animated:YES completion:^{
  [viewController.collectionView loadImojiCategoriesWithOptions:
      [IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationTrending]
  ];
}];
```

Override **userDidSelectImoji:fromCollectionView:** from IMCollectionViewControllerDelegate to interact with the selected sticker

```objective-c
- (void)userDidSelectImoji:(IMImojiObject *)imoji fromCollectionView:(IMCollectionView *)collectionView {
  // add your logic here
}
```

### Bordered stickers or no borders? Small or large image sizes?

It's simple to fine tune the displaying options for your grid. Use the renderingOptions property to configure. You can set the default size of the image (thumbnail, 320, 512 or full size) depending on the target devices screen size.

```objective-c
collectionView.renderingOptions = [IMImojiObjectRenderingOptions optionsWithRenderSize:IMImojiObjectRenderSizeThumbnail
                                             borderStyle:IMImojiObjectBorderStyleSticker
                                             imageFormat:IMImojiObjectImageFormatPNG];
````


## Sticker Creator

The Imoji Sticker Creator allows developers to easily integrate our powerful tool to allow users to create and share their own stickers.All the uploading, tagging and displaying is done for you, just integrate the creator and let your users be creative.

By default, the Sticker Creator is not bundled into the main Podspec. You'll need to add it by updating your Podfile:

```bash
pod 'ImojiSDKUI/Editor'
```

Then, launch the Sticker Creator View Controller like so:

```objective-c
IMImojiSession* session = [IMImojiSession imojiSession];
IMCreateImojiViewController* createViewController =
      [IMCreateImojiViewController controllerWithSourceImage:image session:session];
[parentViewController presentViewController:createViewController animated:YES completion:nil];
```

Set the IMCreateImojiViewControllerDelegate property to ensure your class gets notified when the sticker creation is complete:

```objective-c
createViewController.createDelegate = self;
```

Override imojiUploadDidComplete:

```objective-c
- (void)imojiUploadDidComplete:(IMImojiObject *)localImoji
               persistentImoji:(IMImojiObject *)persistentImoji
                     withError:(NSError *)error
            fromViewController:(IMCreateImojiViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
 
    // display the newly created Imoji
}
```
