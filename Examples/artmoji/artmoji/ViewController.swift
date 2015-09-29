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
    private var cameraView: UIView!
    private var previewView: UIView!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var navigationBar: UIToolbar!
    private var bottomBar: UIToolbar!
    private var navigationTitle: UIBarButtonItem!
    private var captureButton: UIButton!
    private var flipButton: UIButton!
    private var photoLibraryButton: UIButton!
    private var imojiButton: UIButton!
    private var imojiSession: IMImojiSession!
    private let imageBundle = IMResourceBundleUtil.assetsBundle()

    override func loadView() {
        super.loadView()

        imojiSession = IMImojiSession()

        // camera view
        cameraView = UIView(frame: CGRectZero)
        cameraView.backgroundColor = UIColor(red: 48 / 255, green: 48 / 255, blue: 48 / 255, alpha: 1)

        // Set up title
        navigationTitle = UIBarButtonItem(title: "Artmoji", style: UIBarButtonItemStyle.Plain, target: nil, action: "")

        // Set up toolbar buttons
        captureButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        captureButton.setImage(UIImage(named: "toolbar_collection_on", inBundle: imageBundle, compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
        captureButton.addTarget(self, action: "captureButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        captureButton.frame = CGRectMake(0, 0, 40, 40)

        flipButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        flipButton.setImage(UIImage(named: "toolbar_trending_on", inBundle: imageBundle, compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
        flipButton.addTarget(self, action: "flipButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        flipButton.frame = CGRectMake(0, 0, 40, 40)

        photoLibraryButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        photoLibraryButton.setImage(UIImage(named: "toolbar_recents_on", inBundle: imageBundle, compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
        photoLibraryButton.addTarget(self, action: "photoLibraryButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        photoLibraryButton.frame = CGRectMake(0, 0, 40, 40)

        imojiButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        imojiButton.setImage(UIImage(named: "toolbar_reactions_on", inBundle: imageBundle, compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
        imojiButton.addTarget(self, action: "imojiButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        imojiButton.frame = CGRectMake(0, 0, 40, 40)

        // Set up top nav bar
        navigationBar = UIToolbar()
        navigationBar.translucent = true
        navigationBar.barTintColor = UIColor.clearColor()
        navigationBar.items = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: ""),
                               navigationTitle,
                               UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: ""),
                               UIBarButtonItem(customView: flipButton)]

        // Set up bottom bar
        bottomBar = UIToolbar()
        bottomBar.translucent = true
        bottomBar.barTintColor = UIColor.clearColor()
        bottomBar.items = [UIBarButtonItem(customView: photoLibraryButton),
                           UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: ""),
                           UIBarButtonItem(customView: captureButton),
                           UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: ""),
                           UIBarButtonItem(customView: imojiButton)]

        // Add subviews
        view.addSubview(cameraView)
        view.addSubview(navigationBar)
        view.addSubview(bottomBar)

        // Constraints
        navigationBar.mas_makeConstraints { make in
            make.top.equalTo()(self.view)
            make.left.equalTo()(self.view)
            make.right.equalTo()(self.view)
            make.height.equalTo()(45)
        }

        bottomBar.mas_makeConstraints { make in
            make.bottom.equalTo()(self.view)
            make.left.equalTo()(self.view)
            make.right.equalTo()(self.view)
            make.height.equalTo()(65)
        }

        cameraView.mas_makeConstraints { make in
            make.edges.equalTo()(view)
        }

        // Set up PBJVision
        let vision = PBJVision.sharedInstance()
        vision.delegate = self
        vision.cameraDevice = PBJCameraDevice.Front
        vision.cameraMode = PBJCameraMode.Photo
        vision.cameraOrientation = PBJCameraOrientation.Portrait
        vision.focusMode = PBJFocusMode.ContinuousAutoFocus
        vision.exposureMode = PBJExposureMode.ContinuousAutoExposure

        previewView = UIView(frame: CGRectZero)
        previewView.backgroundColor = cameraView.backgroundColor
        previewView.frame = cameraView.frame

        previewLayer = PBJVision.sharedInstance().previewLayer
        previewLayer.frame = previewView.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewView.layer.addSublayer(previewLayer)

        cameraView.addSubview(previewView)

        PBJVision.sharedInstance().startPreview()
    }

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
        collectionViewController.backButton.addTarget(self, action:"backButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        collectionViewController.backButton.hidden = false
        collectionViewController.collectionViewControllerDelegate = self

        presentViewController(collectionViewController, animated: true, completion: nil)
    }

    func backButtonTapped() {
        dismissViewControllerAnimated(true, completion: nil)
    }

}

extension ViewController: PBJVisionDelegate {

}

extension ViewController: IMCollectionViewControllerDelegate {

}

extension ViewController: UIImagePickerControllerDelegate {

}

extension ViewController: UINavigationControllerDelegate {

}



