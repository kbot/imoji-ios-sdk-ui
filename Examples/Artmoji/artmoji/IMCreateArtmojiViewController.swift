//
//  ImojiSDKUI
//
//  Created by Alex Hoang
//  Copyright (C) 2015 Imoji
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

import UIKit

public class IMCreateArtmojiViewController: UIViewController {

    // Required init variables
    private var session: IMImojiSession!
    public var imageBundle: NSBundle
    public var sourceImage: UIImage!

    // Artmoji view
    private var createArtmojiView: IMCreateArtmojiView!

    // MARK: - Object lifecycle
    public init(sourceImage: UIImage, session: IMImojiSession, imageBundle: NSBundle) {
        self.sourceImage = sourceImage
        self.session = session
        self.imageBundle = imageBundle

        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle
    override public func loadView() {
        super.loadView()
        createArtmojiView = IMCreateArtmojiView(session: self.session, sourceImage: self.sourceImage, imageBundle: self.imageBundle)
        createArtmojiView.delegate = self

        view.addSubview(createArtmojiView)

        createArtmojiView.mas_makeConstraints { make in
            make.edges.equalTo()(self.view)
        }
    }
    
    override public func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // Mark: - Buton action methods
    func collectionViewControllerBackButtonTapped() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    // Mark: - UIKit.UIImagePickerController's completion selector
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafePointer<Void>) {
        if error == nil {
            let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            activityController.excludedActivityTypes = [
                UIActivityTypePrint,
                UIActivityTypeCopyToPasteboard,
                UIActivityTypeAssignToContact,
                UIActivityTypeSaveToCameraRoll,
                UIActivityTypeAddToReadingList,
                UIActivityTypePostToFlickr,
                UIActivityTypePostToVimeo
            ]
            
            presentViewController(activityController, animated: true, completion: nil)

        } else {
            let alert = UIAlertController(title: "Yikes!", message: "There was a problem saving your Artmoji to your photos.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }

}

// MARK: - IMCreateArtmojiViewDelegate
extension IMCreateArtmojiViewController: IMCreateArtmojiViewDelegate {
    public func artmojiView(view: IMCreateArtmojiView, didFinishLoadingImoji imoji: IMImojiObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    public func userDidCancelCreateArtmojiView(view: IMCreateArtmojiView) {
        dismissViewControllerAnimated(false, completion: nil)
    }

    public func userDidFinishCreatingArtmoji(artmoji: UIImage, view: IMCreateArtmojiView) {
        UIImageWriteToSavedPhotosAlbum(artmoji, self, "image:didFinishSavingWithError:contextInfo:", nil)
    }

    public func userDidSelectImojiCollectionButtonFromArtmojiView(view: IMCreateArtmojiView) {
        let collectionViewController = IMCollectionViewController(session: self.session)
        collectionViewController.topToolbar.barTintColor = UIColor(red: 55.0 / 255.0, green: 123.0 / 255.0, blue: 167.0 / 255.0, alpha: 1.0)
        collectionViewController.collectionView.collectionViewDelegate = self
        collectionViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        collectionViewController.backButton.addTarget(self, action: "collectionViewControllerBackButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        collectionViewController.backButton.hidden = false
        collectionViewController.collectionViewControllerDelegate = self

        presentViewController(collectionViewController, animated: true) { finished in
            collectionViewController.collectionView.loadFeaturedImojis()
        }
    }
}

// MARK: - IMCollectionViewControllerDelegate
extension IMCreateArtmojiViewController: IMCollectionViewControllerDelegate {

}

// MARK: - IMCollectionViewDelegate
extension IMCreateArtmojiViewController: IMCollectionViewDelegate {
    public func userDidSelectImoji(imoji: IMImojiObject, fromCollectionView collectionView: IMCollectionView) {
        createArtmojiView.addImoji(imoji)
    }
}


