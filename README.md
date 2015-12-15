# Imoji SDK UI

A collection of powerful open source UI widgets leveraging the [Imoji SDK](https://github.com/imojiengineering/imoji-ios-sdk). 

## Create

Add the ability to create new Imoji Stickers with ease into your application! Simply launch IMCreateImojiViewController and allow the editor to do the work for you: 

```objective-c
IMImojiSession* session = [IMImojiSession imojiSession];
 
IMCreateImojiViewController* createViewController = [IMCreateImojiViewController controllerWithSourceImage:image session:session];
 
[parentViewController presentViewController:createViewController animated:YES completion:nil];
```

![alt tag](https://s3.amazonaws.com/imoji-external/imoji-create-ios.gif)

## Search

Display a view controller to search Imoji's database of stickers. Specify a delegate to receive the selection of the Imoji

```objective-c
IMImojiSession* session = [IMImojiSession imojiSession];
 
IMCollectionViewController* collectionViewController = [IMCollectionViewController collectionViewControllerWithSession:session];
 
[parentViewController presentViewController:collectionViewController animated:YES completion:nil];
```

![alt tag](https://s3.amazonaws.com/imoji-external/imoji-search.gif)

## Sentence Parsing

Send complete sentences to the IMCollectionViewController and watch it find results for you in real time by matching keywords in your sentence. 

```objective-c
IMImojiSession* session = [IMImojiSession imojiSession];
 
IMCollectionViewController* collectionViewController = [IMCollectionViewController collectionViewControllerWithSession:session];
 
[parentViewController presentViewController:collectionViewController animated:YES completion:nil];
```

![alt tag](https://s3.amazonaws.com/imoji-external/imoji-sentence-parser.gif)


## Categories

Display **trending** or **reactions** to your users with the IMCollectionViewController as well:


```objective-c
IMImojiSession* session = [IMImojiSession imojiSession];
 
IMCollectionViewController *viewController = [IMCollectionViewController collectionViewControllerWithSession:session];
viewController.searchField.hidden = YES;

[parentViewController presentViewController:viewController animated:YES completion:^{
     [viewController.collectionView loadImojiCategories:IMImojiSessionCategoryClassificationTrending];
     [viewController updateViewConstraints];
}];
```

![alt tag](https://s3.amazonaws.com/imoji-external/imoji-trending-ios.gif)


## Animated Stickers!!
![alt tag](https://compass.imoji.io/10e/10ee60f8-6c68-43f8-9e2c-fca6e2b285ed-thumb.gif)

Animated stickers loaded by default in versions 2.0.2 and higher. You're application will need to either use YYAnimatedImageView instead of UIImageView's or extract the contents of the animated gif into your own view (ex: FLAnimatedImage). 

To extract animated content, you can perform the following:

```objective-c
IMImojiObject *imoji;
IMImojiObjectRenderingOptions *options = [IMImojiObjectRenderingOptions optionsWithRenderSize:IMImojiObjectRenderSizeThumbnail];
options.renderAnimatedIfSupported = YES;

[imojiSession renderImoji:imoji
                  options:options
                 callback:^(UIImage *image, NSError *renderError) {
                     if (imoji.supportsAnimation && [image isKindOfClass:[YYImage class]]) {
                         YYImage *yyImage = (YYImage *) image;
                         NSData *animatedImageData = yyImage.animatedImageData;
                         // load animated data into view
                     }
                 }
];

```

## Samples 

Check out the sample apps to get up to speed on the services!

https://github.com/imojiengineering/imoji-ios-sdk-ui/tree/master/Examples
