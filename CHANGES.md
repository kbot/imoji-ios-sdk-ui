# Imoji iOS UI Widgets Changes

### Version 0.1.9

* Switched over to showing 3 Imoij Categories in Collection View
* Added ability to switch on/off auto search in collection view controller
* Improved collection view controller to handle updating content insets when keyboard is shown

### Version 0.1.8

* Adds sentence parsing functionality to the collection views!
* Adds IMCollectionViewController to facilitate integration
* Modified IMCreateImojiViewController to require IMImojiSession
* refactor ImojiCollectionViewContentType to IMCollectionViewContentType
* refactor imojiCollectionViewDidFinishSearching: to imojiCollectionView:didFinishLoadingContentType:

### Version 0.1.7

* Improvements to collection views! 
* Much of the common Imoji Keyboard Collection View functionality is now part of the base collection view
* Removed callbacks from collection views in favor of delegates

### Version 0.1.6

* Adds Imoji Editor to the SDK (Beta)!

### Version 0.1.5

* Adds loading user collections back to IMCollectionView
* Gray stock theme

### Version 0.1.4

* Support for loading imojis from a users collection if their session is synchronized
* Larger displayed images
* Adds support for specifying fonts and app group for implementors
* Addresses issue with categories not reloading when user has drilled into a category already and wants to go back

### Version 0.1.3

* Ensure that consumers of the keyboard view controller independently set the API credentials.
* Remove unused pod dependencies

### Version 0.1.2

* Adds Imoji Keyboard functionality as it's own Pod subspec

### Version 0.1.1

* Collection status view cell bug fix

### Version 0.1.0

* Introducing Imoji iOS UI components!
