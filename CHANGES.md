# Imoji iOS UI Widgets Changes

### Version 0.1.18

* Using fetchRenderingOptions from IMImojiSession for the default size to render Imoji's in the collection views
* Updated Imoji creation to trigger callbacks before and after uploading
* Fixes a bug in which the Imoji Editor would crash loading large images.

### Version 0.1.17

* Full support for loading ImojiSDKUI as a dynamic library
* Bitcode support which now requires Xcode 7 for archiving your applications
* Fixes an issue with some images for the imoji editor not showing up on iOS 7
* Fixes a crash when switching categories rapidly in IMCollectionView
* Adds a delay setting for auto searching in IMCollectionViewController
* Ensures that the Done button is displayed when the search bar text is empty in IMCollectionViewController
* Completed Artmoji Sample!

### Version 0.1.16

* Addresses build issues with Swift projects and ImojiGraphics when loading ImojiSDKUI as a framework

### Version 0.1.15

* iOS 7 Fixes
  * Addresses crashes with collection view assertions
  * Fixed Tips in the Imoji creation view
  * Fixed misaligned category collection view cells
  * Stopped calling imageNamed:inBundle:compatibleWithTraitCollection which is not available on iOS 7
* Functionality
  * Add the ability to turn off selection animation for IMCollectionView
  * Adds a Messaging App Example
  * When saving a new Imoji, update the toolbar and show an activity indicator

### Version 0.1.14

* Collection View fixes
  * Fixes a bug in which the Imoji session passed up to IMCollectionViewController was being reset
  * Splash screens were not centering properly
  * Shows loading indicator when loading a category
  * Modularized collection view to allow subclasses to have more control
  * Collection view cells were not taking up the full width of the view, the rounding logic for the cell size was off
  * Better support for orientation changes
  * Added loadImojisFromCategory to IMCollectionView for convenience

* Editor
  * Avoid showing translucency on the image being edited until the user has selected a path

### Version 0.1.13

* Fixed some issues with portrait/landscape transitions in IMCollectionViewController
* Allows flexibility to specify the preferred displayed size of the imojis

### Version 0.1.12

* Nifty tutorials for the editor!
* Updated assets for creation and tagging
* Allow for clients to specify their own styles

### Version 0.1.11

* Many enhancements to IMCollectionViewController for customizing the toolbar contents and display
* Exposes a shared common toolbar IMToolbar for Imoji components

### Version 0.1.10

* Fixed crash that occurs in the editor when the user goes to the tag screen then goes back and makes changes to the sticker
* Panning around the Editor can now be done with one finger once the border has been drawn. Previously users had to use 2 touches.
* Refactored userDidFinishCreatingImoji:withError: in IMCreateImojiViewControllerDelegate and added the source view controller to the signature

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
