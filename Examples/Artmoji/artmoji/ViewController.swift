//
//  ViewController.swift
//  artmoji
//
//  Created by Alex Hoang on 9/24/15.
//  Copyright (c) 2015 Imoji. All rights reserved.
//

import UIKit
import ImojiSDK

class ViewController: UIViewController {
    private var previewView: UIView!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var navigationBar: UIToolbar!
    private var bottomBar: UIToolbar!
    private var navigationTitle: UIButton!
    private var captureButton: UIButton!
    private var flipButton: UIButton!
    private var photoLibraryButton: UIButton!
    private var imojiButton: UIButton!
    private var forwardButton: UIBarButtonItem!
    private var backButton: UIBarButtonItem!
    private let imojiSession = IMImojiSession()
    private let imageBundle = IMResourceBundleUtil.assetsBundle()

    override func loadView() {
        super.loadView()

        view.backgroundColor = UIColor(red: 48.0 / 255.0, green: 48.0 / 255.0, blue: 48.0 / 255.0, alpha: 1.0)

        // Set up title
        navigationTitle = UIButton(type: UIButtonType.Custom)
        navigationTitle.setTitle("ARTMOJI", forState: UIControlState.Normal)
        navigationTitle.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 18.0)
        navigationTitle.sizeToFit()
        navigationTitle.userInteractionEnabled = false

        // Set up toolbar buttons
        captureButton = UIButton(type: UIButtonType.Custom)
        captureButton.setImage(UIImage(named: "toolbar_collection_on", inBundle: imageBundle, compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
        captureButton.addTarget(self, action: "captureButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        captureButton.frame = CGRectMake(0, 0, 40.0, 40.0)

        flipButton = UIButton(type: UIButtonType.Custom)
        flipButton.setImage(UIImage(named: "toolbar_trending_on", inBundle: imageBundle, compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
        flipButton.addTarget(self, action: "flipButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        flipButton.frame = CGRectMake(0, 0, 40.0, 40.0)

        photoLibraryButton = UIButton(type: UIButtonType.Custom)
        photoLibraryButton.setImage(UIImage(named: "toolbar_recents_on", inBundle: imageBundle, compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
        photoLibraryButton.addTarget(self, action: "photoLibraryButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        photoLibraryButton.frame = CGRectMake(0, 0, 40.0, 40.0)

        forwardButton = UIBarButtonItem(image: UIImage(named: "toolbar_back", inBundle: imageBundle, compatibleWithTraitCollection: nil), style: UIBarButtonItemStyle.Plain, target: self, action: "forwardButtonTapped")

        backButton = UIBarButtonItem(image: UIImage(named: "toolbar_back", inBundle: imageBundle, compatibleWithTraitCollection: nil), style: UIBarButtonItemStyle.Plain, target: self, action: "backButtonTapped")

        imojiButton = UIButton(type: UIButtonType.Custom)
        imojiButton.setImage(UIImage(named: "toolbar_reactions_on", inBundle: imageBundle, compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
        imojiButton.addTarget(self, action: "imojiButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        imojiButton.frame = CGRectMake(0, 0, 40.0, 40.0)

        // Set up top nav bar
        navigationBar = UIToolbar()
        navigationBar.clipsToBounds = true
        navigationBar.setBackgroundImage(UIImage(), forToolbarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default)
        navigationBar.tintColor = UIColor(white: 105.0/255, alpha: 1.0)
        navigationBar.barTintColor = UIColor.clearColor()
        navigationBar.items = [backButton,
                               UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
                               UIBarButtonItem(customView: navigationTitle),
                               UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
                               forwardButton]
        navigationBar.delegate = self

        // Set up bottom bar
        bottomBar = UIToolbar()
        bottomBar.clipsToBounds = true
        bottomBar.setBackgroundImage(UIImage(), forToolbarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default)
        bottomBar.barTintColor = UIColor.clearColor()
        bottomBar.items = [UIBarButtonItem(customView: photoLibraryButton),
                           UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: ""),
                           UIBarButtonItem(customView: captureButton),
                           UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: ""),
                           UIBarButtonItem(customView: flipButton)]
        bottomBar.delegate = self

        // Set up PBJVision
        let vision = PBJVision.sharedInstance()
        vision.delegate = self
        vision.cameraDevice = PBJCameraDevice.Front
        vision.cameraMode = PBJCameraMode.Photo
        vision.previewOrientation = PBJCameraOrientation.Portrait
        vision.focusMode = PBJFocusMode.ContinuousAutoFocus
        vision.exposureMode = PBJExposureMode.ContinuousAutoExposure

        previewView = UIView(frame: CGRectZero)
        previewView.backgroundColor = view.backgroundColor
        previewView.frame = view.frame

        previewLayer = PBJVision.sharedInstance().previewLayer
        previewLayer.frame = previewView.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewView.layer.addSublayer(previewLayer)

        // Add subviews
        view.addSubview(previewView)
        view.addSubview(navigationBar)
        view.addSubview(bottomBar)

        // Constraints
        navigationBar.mas_makeConstraints { make in
            make.top.equalTo()(self.view)
            make.left.equalTo()(self.view)
            make.right.equalTo()(self.view)
            make.height.equalTo()(45.0)
        }

        bottomBar.mas_makeConstraints { make in
            make.bottom.equalTo()(self.view)
            make.left.equalTo()(self.view)
            make.right.equalTo()(self.view)
            make.height.equalTo()(65.0)
        }

        vision.startPreview()
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    // Mark: - Buton action methods
    func captureButtonTapped() {
        PBJVision.sharedInstance().capturePhoto()
    }

    func flipButtonTapped() {
        PBJVision.sharedInstance().cameraDevice = PBJVision.sharedInstance().cameraDevice == PBJCameraDevice.Back ?
                PBJCameraDevice.Front : PBJCameraDevice.Back
    }

    func photoLibraryButtonTapped() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            picker.modalPresentationStyle = UIModalPresentationStyle.CurrentContext

            presentViewController(picker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Photo Library Unavailable", message: "Photo Library Unavailable", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }

    func imojiButtonTapped() {
        let collectionViewController = IMCollectionViewController(session: imojiSession)
        collectionViewController.collectionView.collectionViewDelegate = self
        collectionViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        collectionViewController.backButton.addTarget(self, action: "collectionViewControllerBackButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        collectionViewController.backButton.hidden = false
        collectionViewController.collectionViewControllerDelegate = self

        presentViewController(collectionViewController, animated: true, completion: nil)
    }

    func forwardButtonTapped() {
        print("FORWARD!", terminator: "")
    }

    func backButtonTapped() {
        print("FALL BACK!", terminator: "")
    }

    func collectionViewControllerBackButtonTapped() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func showCaptureErrorAlert() {
        let alert = UIAlertController(title: "Problems", message: "Yikes! There's problem saving the photo", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }

}

// Mark: - PBJVisionDelegate
extension ViewController: PBJVisionDelegate {
    func vision(_: PBJVision, capturedPhoto photoDict: [NSObject:AnyObject]?, error: NSError?) {
        if error == nil {
            if let image = photoDict?[PBJVisionPhotoImageKey] as? UIImage {
                let createImojiViewController = IMCreateImojiViewController(sourceImage: image, session: imojiSession)
                createImojiViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                createImojiViewController.modalPresentationStyle = UIModalPresentationStyle.FullScreen
                presentViewController(createImojiViewController, animated: true, completion: nil)
            } else {
                showCaptureErrorAlert()
            }
        } else {
            showCaptureErrorAlert()
        }
    }
}

// Mark: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        let createImojiViewController = IMCreateImojiViewController(sourceImage: image, session: imojiSession)
        createImojiViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        createImojiViewController.modalPresentationStyle = UIModalPresentationStyle.FullScreen
        self.dismissViewControllerAnimated(true, completion: { finished in
            self.presentViewController(createImojiViewController, animated: true, completion: nil)
        })
    }
}

// Mark: - IMCollectionViewControllerDelegate
extension ViewController: IMCollectionViewControllerDelegate {

}

// Mark: - UINavigationControllerDelegate
extension ViewController: UINavigationControllerDelegate {

}



