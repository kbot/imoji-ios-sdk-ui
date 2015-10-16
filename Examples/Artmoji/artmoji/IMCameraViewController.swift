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
import ImojiSDKUI

@objc public protocol IMCameraViewControllerDelegate {
    optional func userDidCancelCameraViewController(viewController: IMCameraViewController)
    optional func userDidFinishCreatingImoji(imoji: IMImojiObject, fromCameraViewController viewController: IMCameraViewController)
}

public class IMCameraViewController: UIViewController {

    // Required init variables
    private var session: IMImojiSession!
    private var imageBundle: NSBundle

    // PBJVision variables
    private var previewView: UIView!
    private var previewLayer: AVCaptureVideoPreviewLayer!

    // Top toolbar
    private var navigationBar: UIToolbar!
    private var navigationTitle: UIButton!
    private var cancelButton: UIBarButtonItem!

    // Bottom toolbar
    private var bottomBar: UIToolbar!
    private var captureButton: UIButton!
    private var flipButton: UIButton!
    private var photoLibraryButton: UIButton!

    // Controller type to present when picture is taken or used from photo library
    private var presentingViewControllerType: Int

    // Delegate object
    public var delegate: IMCameraViewControllerDelegate?

    // MARK: - Object lifecycle
    public init(session: IMImojiSession, imageBundle: NSBundle, controllerType: Int) {
        self.session = session
        self.imageBundle = imageBundle
        presentingViewControllerType = controllerType
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle
    override public func loadView() {
        super.loadView()

        view.backgroundColor = UIColor(red: 48.0 / 255.0, green: 48.0 / 255.0, blue: 48.0 / 255.0, alpha: 1.0)

        // Set up title
        navigationTitle = UIButton(type: UIButtonType.Custom)
        navigationTitle.setTitle(presentingViewControllerType == IMArtmojiConstants.PresentingViewControllerType.CreateArtmoji ? "ARTMOJI" : "CREATE STICKER", forState: UIControlState.Normal)
        navigationTitle.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 18.0)
        navigationTitle.sizeToFit()
        navigationTitle.userInteractionEnabled = false

        // Set up toolbar buttons
        let buttonItemFrame = CGRectMake(0, 0, IMArtmojiConstants.ButtonItemWidthHeight, IMArtmojiConstants.ButtonItemWidthHeight)
        captureButton = UIButton(type: UIButtonType.Custom)
        captureButton.setImage(UIImage(named: "Artmoji-Camera-Capture"), forState: UIControlState.Normal)
        captureButton.addTarget(self, action: "captureButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        captureButton.frame = buttonItemFrame

        let cancelButton = UIButton(type: UIButtonType.Custom)
        cancelButton.setImage(UIImage(named: "Artmoji-Cancel"), forState: UIControlState.Normal)
        cancelButton.addTarget(self, action: "cancelButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        cancelButton.frame = buttonItemFrame
        self.cancelButton = UIBarButtonItem(customView: cancelButton)

        flipButton = UIButton(type: UIButtonType.Custom)
        flipButton.setImage(UIImage(named: "Artmoji-Camera-Flip"), forState: UIControlState.Normal)
        flipButton.addTarget(self, action: "flipButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        flipButton.frame = buttonItemFrame

        photoLibraryButton = UIButton(type: UIButtonType.Custom)
        photoLibraryButton.setImage(UIImage(named: "Artmoji-Photo-Library"), forState: UIControlState.Normal)
        photoLibraryButton.addTarget(self, action: "photoLibraryButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        photoLibraryButton.frame = buttonItemFrame

        // Set up top nav bar
        navigationBar = UIToolbar()
        navigationBar.clipsToBounds = true
        navigationBar.setBackgroundImage(UIImage(), forToolbarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default)
        navigationBar.tintColor = UIColor.whiteColor()
        navigationBar.barTintColor = UIColor.clearColor()
        navigationBar.items = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
                               UIBarButtonItem(customView: navigationTitle),
                               UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)]

        determineCancelCameraButtonVisibility()

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

        // Set up PBJVision
        let vision = PBJVision.sharedInstance()
        vision.cameraDevice = PBJCameraDevice.Front
        vision.cameraMode = PBJCameraMode.Photo
        vision.previewOrientation = PBJCameraOrientation.Portrait
        vision.focusMode = PBJFocusMode.ContinuousAutoFocus
        vision.exposureMode = PBJExposureMode.ContinuousAutoExposure

        // Add subviews
        view.addSubview(navigationBar)
        view.addSubview(bottomBar)

        // Constraints
        navigationBar.mas_makeConstraints { make in
            make.top.equalTo()(self.view)
            make.left.equalTo()(self.view)
            make.right.equalTo()(self.view)
            make.height.equalTo()(IMArtmojiConstants.NavigationBarHeight)
        }

        bottomBar.mas_makeConstraints { make in
            make.bottom.equalTo()(self.view)
            make.left.equalTo()(self.view)
            make.right.equalTo()(self.view)
            make.height.equalTo()(IMArtmojiConstants.BottomBarHeight)
        }
    }

    override public func viewWillAppear(animated: Bool) {
        // Set up delegate and preview with previewLayer
        let vision = PBJVision.sharedInstance()
        vision.delegate = self

        previewView = UIView(frame: CGRectZero)
        previewView.backgroundColor = view.backgroundColor
        previewView.frame = view.frame
        
        previewLayer = PBJVision.sharedInstance().previewLayer
        previewLayer.frame = previewView.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewView.layer.addSublayer(previewLayer)
        
        // Add preview
        view.insertSubview(previewView, belowSubview: navigationBar)
        
        // Start PBJVision's preview
        vision.startPreview()
    }

    override public func viewWillDisappear(animated: Bool) {
        previewLayer.removeFromSuperlayer()
        previewView.removeFromSuperview()
        PBJVision.sharedInstance().stopPreview()
    }

    override public func prefersStatusBarHidden() -> Bool {
        return true
    }

    func determineCancelCameraButtonVisibility() {
        if let index = navigationBar.items!.indexOf(cancelButton) {
            navigationBar.items!.removeAtIndex(index)
        }
        
        if delegate?.userDidCancelCameraViewController != nil {
            navigationBar.items!.insert(cancelButton, atIndex: 0)
        }
    }

    // MARK: - Camera button logic
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
            showCaptureErrorAlertTitle("Photo Library Unavailable", message: "Yikes! There's a problem accessing your photo library.")
        }
    }

    func cancelButtonTapped() {
        delegate?.userDidCancelCameraViewController?(self)
    }

    func showCaptureErrorAlertTitle(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }

}

// MARK: - PBJVisionDelegate
extension IMCameraViewController: PBJVisionDelegate {
    public func vision(_: PBJVision, capturedPhoto photoDict: [NSObject:AnyObject]?, error: NSError?) {
        if error == nil {
            if let image = photoDict?[PBJVisionPhotoImageKey] as? UIImage {
                if presentingViewControllerType == IMArtmojiConstants.PresentingViewControllerType.CreateArtmoji {
                    let createArtmojiViewController = IMCreateArtmojiViewController(sourceImage: image, session: self.session, imageBundle: self.imageBundle)
                    presentViewController(createArtmojiViewController, animated: false, completion: nil)
                } else if presentingViewControllerType == IMArtmojiConstants.PresentingViewControllerType.CreateImoji {
                    let createImojiViewController = IMCreateImojiViewController(sourceImage: image, session: self.session)
                    createImojiViewController.createDelegate = self
                    presentViewController(createImojiViewController, animated: false, completion: nil)
                }
            } else {
                showCaptureErrorAlertTitle("Problems", message: "Yikes! There was a problem taking the photo.")
            }
        } else {
            showCaptureErrorAlertTitle("Problems", message: "Yikes! There was a problem taking the photo.")
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension IMCameraViewController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        if presentingViewControllerType == IMArtmojiConstants.PresentingViewControllerType.CreateArtmoji {
            let createArtmojiViewController = IMCreateArtmojiViewController(sourceImage: image, session: self.session, imageBundle: self.imageBundle)
            createArtmojiViewController.modalPresentationStyle = UIModalPresentationStyle.FullScreen
            createArtmojiViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            picker.presentViewController(createArtmojiViewController, animated: true, completion: nil)
        } else if presentingViewControllerType == IMArtmojiConstants.PresentingViewControllerType.CreateImoji {
            let createImojiViewController = IMCreateImojiViewController(sourceImage: image, session: self.session)
            createImojiViewController.createDelegate = self
            createImojiViewController.modalPresentationStyle = UIModalPresentationStyle.FullScreen
            createImojiViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            picker.presentViewController(createImojiViewController, animated: true, completion: nil)
        }
    }
}

// MARK: - UINavigationControllerDelegate
extension IMCameraViewController: UINavigationControllerDelegate {

}

// MARK: - IMCreateImojiViewControllerDelegate
extension IMCameraViewController: IMCreateImojiViewControllerDelegate {
    public func userDidFinishCreatingImoji(imoji: IMImojiObject?, withError error: NSError?, fromViewController viewController: IMCreateImojiViewController) {
        if error == nil {
            delegate?.userDidFinishCreatingImoji?(imoji!, fromCameraViewController: self)
        }
    }

    public func userDidCancelImageEdit(viewController: IMCreateImojiViewController) {
        viewController.dismissViewControllerAnimated(false, completion: nil)
    }
}