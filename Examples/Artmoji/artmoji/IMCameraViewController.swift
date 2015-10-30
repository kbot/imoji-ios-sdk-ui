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
import AVFoundation
import CoreMotion

@objc public protocol IMCameraViewControllerDelegate {
    optional func userDidCancelCameraViewController(viewController: IMCameraViewController)
    optional func userDidFinishCreatingImoji(imoji: IMImojiObject, fromCameraViewController viewController: IMCameraViewController)
}

public class IMCameraViewController: UIViewController {

    // Required init variables
    private var session: IMImojiSession!
    private var imageBundle: NSBundle

    // AVFoundation variables
    private var captureSession: AVCaptureSession!
    private var backCameraDevice: AVCaptureDevice!
    private var frontCameraDevice: AVCaptureDevice!
    private var stillCameraOutput: AVCaptureStillImageOutput!
    private var captureMotionManager: CMMotionManager!
    private var currentOrientation: UIImageOrientation!
    private var captureSessionQueue: dispatch_queue_t!
    private var previewView: UIView!
    private var previewLayer: AVCaptureVideoPreviewLayer!

    // Top toolbar
    private var navigationBar: UIToolbar!
    private var cancelButton: UIBarButtonItem!

    // Bottom buttons
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

        // Create queue for AVCaptureSession
        captureSessionQueue = dispatch_queue_create("com.sopressata.artmoji.capture_session", DISPATCH_QUEUE_SERIAL)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle
    override public func loadView() {
        super.loadView()

        view.backgroundColor = UIColor(red: 48.0 / 255.0, green: 48.0 / 255.0, blue: 48.0 / 255.0, alpha: 1.0)

        // Set up toolbar buttons
        captureButton = UIButton(type: UIButtonType.Custom)
        captureButton.setImage(UIImage(named: "Artmoji-Circle"), forState: UIControlState.Normal)
        captureButton.addTarget(self, action: "captureButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)

        let cancelButton = UIButton(type: UIButtonType.Custom)
        cancelButton.setImage(UIImage(named: "Artmoji-Cancel"), forState: UIControlState.Normal)
        cancelButton.addTarget(self, action: "cancelButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        cancelButton.imageEdgeInsets = UIEdgeInsetsMake(IMArtmojiConstants.DefaultButtonItemInset, IMArtmojiConstants.DefaultButtonItemInset, IMArtmojiConstants.DefaultButtonItemInset, IMArtmojiConstants.DefaultButtonItemInset)
        cancelButton.frame = CGRectMake(0, 0, IMArtmojiConstants.DefaultButtonItemWidthHeight, IMArtmojiConstants.DefaultButtonItemWidthHeight)
        self.cancelButton = UIBarButtonItem(customView: cancelButton)

        flipButton = UIButton(type: UIButtonType.Custom)
        flipButton.setImage(UIImage(named: "Artmoji-Camera-Flip"), forState: UIControlState.Normal)
        flipButton.addTarget(self, action: "flipButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)

        photoLibraryButton = UIButton(type: UIButtonType.Custom)
        photoLibraryButton.setImage(UIImage(named: "Artmoji-Photo-Library"), forState: UIControlState.Normal)
        photoLibraryButton.addTarget(self, action: "photoLibraryButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)

        // Set up top nav bar
        navigationBar = UIToolbar()
        navigationBar.clipsToBounds = true
        navigationBar.setBackgroundImage(UIImage(), forToolbarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default)
        navigationBar.tintColor = UIColor.whiteColor()
        navigationBar.barTintColor = UIColor.clearColor()

        determineCancelCameraButtonVisibility()

        // Setup AVCaptureSession
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto

        // Get available devices and save reference to front and back cameras
        let availableCameraDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for device in availableCameraDevices as! [AVCaptureDevice] {
            if device.position == AVCaptureDevicePosition.Back {
                backCameraDevice = device
            }
            else if device.position == AVCaptureDevicePosition.Front {
                frontCameraDevice = device
            }
        }

        do {
            self.captureSession.beginConfiguration()
            let cameraInput = try AVCaptureDeviceInput(device: self.frontCameraDevice)
            do {
                try cameraInput.device.lockForConfiguration()
                
                if cameraInput.device.isExposureModeSupported(AVCaptureExposureMode.ContinuousAutoExposure) {
                    cameraInput.device.exposureMode = AVCaptureExposureMode.ContinuousAutoExposure
                }
                
                if cameraInput.device.isFocusModeSupported(AVCaptureFocusMode.ContinuousAutoFocus) {
                    cameraInput.device.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
                }
                
                cameraInput.device.unlockForConfiguration()
            } catch let error as NSError {
                NSLog("error trying to lock camera for configuration in setup(): \(error)")
            }
            
            if self.captureSession.canAddInput(cameraInput) {
                self.captureSession.addInput(cameraInput)
            }
            self.captureSession.commitConfiguration()
        } catch let error as NSError {
            NSLog("error while performing camera configuration: \(error)")
        }

        // Add the still image capture to AVCaptureSession
        stillCameraOutput = AVCaptureStillImageOutput()
        if captureSession.canAddOutput(stillCameraOutput) {
            captureSession.addOutput(stillCameraOutput)
        }

        // Add subviews
        view.addSubview(navigationBar)
        view.addSubview(photoLibraryButton)
        view.addSubview(flipButton)
        view.addSubview(captureButton)

        // Constraints
        navigationBar.mas_makeConstraints { make in
            make.top.equalTo()(self.view)
            make.left.equalTo()(self.view)
            make.right.equalTo()(self.view)
            make.height.equalTo()(IMArtmojiConstants.NavigationBarHeight)
        }

        photoLibraryButton.mas_makeConstraints { make in
            make.bottom.equalTo()(self.view).offset()(-IMArtmojiConstants.CameraViewBottomButtonBottomOffset)
            make.left.equalTo()(self.view).offset()(34)
        }
        
        flipButton.mas_makeConstraints { make in
            make.bottom.equalTo()(self.view).offset()(-IMArtmojiConstants.CameraViewBottomButtonBottomOffset)
            make.right.equalTo()(self.view).offset()(-30)
        }
        
        captureButton.mas_makeConstraints { make in
            make.bottom.equalTo()(self.view).offset()(-IMArtmojiConstants.CaptureButtonBottomOffset)
            make.centerX.equalTo()(self.view)
        }
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Start tracking accelerometer data
        captureMotionManager = CMMotionManager()
        captureMotionManager.accelerometerUpdateInterval = 0.2
        captureMotionManager.startAccelerometerUpdatesToQueue(NSOperationQueue()) { accelerometerData, error in
            if let data = accelerometerData {
                // Set the image orientation based on device orientation
                // This will work even if the orientation is locked on the device
                self.currentOrientation = abs(data.acceleration.y) < abs(data.acceleration.x)
                                          ? data.acceleration.x > 0 ? UIImageOrientation.Right : UIImageOrientation.Left
                                          : data.acceleration.y > 0 ? UIImageOrientation.Down : UIImageOrientation.Up
            }
        }

        // Reset preview
        previewView = UIView(frame: CGRectZero)
        previewView.backgroundColor = view.backgroundColor
        previewView.frame = view.frame

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = previewView.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewView.layer.addSublayer(previewLayer)

        // Add preview
        view.insertSubview(previewView, belowSubview: navigationBar)

        // Start AVCaptureSession
        #if (arch(i386) || arch(x86_64)) && os(iOS)
        #else
        if checkAuthorizationStatus() == AVAuthorizationStatus.Authorized {
            dispatch_async(captureSessionQueue) {
                self.captureSession.startRunning()
            }
        }
        #endif
    }

    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        // Stop tracking accelerometer
        captureMotionManager.stopAccelerometerUpdates()

        // Remove preview from the view
        previewLayer.removeFromSuperlayer()
        previewView.removeFromSuperview()

        // Stop running AVCaptureSession
        #if (arch(i386) || arch(x86_64)) && os(iOS)
        #else
        if checkAuthorizationStatus() == AVAuthorizationStatus.Authorized {
            dispatch_async(captureSessionQueue) {
                self.captureSession.stopRunning()
            }
        }
        #endif
    }

    override public func prefersStatusBarHidden() -> Bool {
        return true
    }

    func checkAuthorizationStatus() -> AVAuthorizationStatus {
        var authorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        switch authorizationStatus {
            case .NotDetermined:
                // permission dialog not yet presented, request authorization
                AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { granted in
                    if granted {
                        authorizationStatus = .Authorized
                    } else {
                        // user denied, nothing much to do
                        authorizationStatus = .Denied
                    }
                }
                break
            case .Authorized:
                // go ahead
                break
            case .Denied, .Restricted:
                // the user explicitly denied camera usage or is not allowed to access the camera devices
                break
        }
        
        return authorizationStatus
    }

    func determineCancelCameraButtonVisibility() {
        if let _ = navigationBar.items, let index = navigationBar.items!.indexOf(cancelButton) {
            navigationBar.items!.removeAtIndex(index)
        }
        
        if delegate?.userDidCancelCameraViewController != nil {
            navigationBar.items = [cancelButton]
        }
    }

    // MARK: - Camera button logic
    func captureButtonTapped() {
        dispatch_async(captureSessionQueue) {
            let connection = self.stillCameraOutput.connectionWithMediaType(AVMediaTypeVideo)
            self.stillCameraOutput.captureStillImageAsynchronouslyFromConnection(connection) { sampleBuffer, error in
                if error == nil {
                    // if the session preset .Photo is used, or if explicitly set in the device's outputSettings
                    // we get the data already compressed as JPEG
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    
                    // the sample buffer also contains the metadata, in case we want to modify it
//                    let metadata = CMCopyDictionaryOfAttachments(nil, sampleBuffer, CMAttachmentMode(kCMAttachmentMode_ShouldPropagate))//.takeUnretainedValue()

                    if var image = UIImage(data: imageData) {
                        if let currentCameraInput = self.captureSession.inputs.first as? AVCaptureDeviceInput {
                            if currentCameraInput.device.position == AVCaptureDevicePosition.Front {
                                image = IMDrawingUtils().flipImage(image)
                            }
                        }
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            if self.presentingViewControllerType == IMArtmojiConstants.PresentingViewControllerType.CreateArtmoji {
                                let createArtmojiViewController = IMCreateArtmojiViewController(sourceImage: image, capturedImageOrientation: self.currentOrientation, session: self.session, imageBundle: self.imageBundle)
                                self.presentViewController(createArtmojiViewController, animated: false, completion: nil)
                            } else if self.presentingViewControllerType == IMArtmojiConstants.PresentingViewControllerType.CreateImoji {
                                let createImojiViewController = IMCreateImojiViewController(sourceImage: image, session: self.session)
                                createImojiViewController.createDelegate = self
                                self.presentViewController(createImojiViewController, animated: false, completion: nil)
                            }
                        }
                    }
                }
                else {
                    NSLog("error while capturing still image: \(error)")
                    self.showCaptureErrorAlertTitle("Problems", message: "Yikes! There was a problem taking the photo.")
                }
            }
        }
    }

    func flipButtonTapped() {
        dispatch_async(captureSessionQueue) {
            self.captureSession.beginConfiguration()

            if let currentCameraInput = self.captureSession.inputs.first as? AVCaptureDeviceInput {
                self.captureSession.removeInput(currentCameraInput)

                do {
                    let cameraInput = try AVCaptureDeviceInput(device: currentCameraInput.device.position == AVCaptureDevicePosition.Front ? self.backCameraDevice : self.frontCameraDevice)
                    do {
                        try cameraInput.device.lockForConfiguration()
                        
                        if cameraInput.device.isExposureModeSupported(AVCaptureExposureMode.ContinuousAutoExposure) {
                            cameraInput.device.exposureMode = AVCaptureExposureMode.ContinuousAutoExposure
                        }
                        
                        if cameraInput.device.isFocusModeSupported(AVCaptureFocusMode.ContinuousAutoFocus) {
                            cameraInput.device.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
                        }
                        
                        cameraInput.device.unlockForConfiguration()
                    } catch let error as NSError {
                        NSLog("error while locking camera for configuration in flipButtonTapped(): \(error)")
                    }
                    
                    if self.captureSession.canAddInput(cameraInput) {
                        self.captureSession.addInput(cameraInput)
                    }
                } catch let error as NSError {
                    NSLog("error while flipping camera: \(error)")
                }
            }

            self.captureSession.commitConfiguration()
        }
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

// MARK: - UIImagePickerControllerDelegate
extension IMCameraViewController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        if presentingViewControllerType == IMArtmojiConstants.PresentingViewControllerType.CreateArtmoji {
            let createArtmojiViewController = IMCreateArtmojiViewController(sourceImage: image, capturedImageOrientation: nil, session: self.session, imageBundle: self.imageBundle)
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