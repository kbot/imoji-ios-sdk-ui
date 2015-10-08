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

@objc public protocol IMCreateArtmojiViewDelegate {
    optional func userDidCancelCreateArtmojiView(view: IMCreateArtmojiView)
    optional func userDidFinishCreatingArtmoji(artmoji: UIImage, view: IMCreateArtmojiView)
    optional func userDidSelectImojiCollectionButtonFromArtmojiView(view: IMCreateArtmojiView)
    optional func artmojiView(view: IMCreateArtmojiView, didFinishLoadingImoji imoji: IMImojiObject)
}

public class IMCreateArtmojiView: UIView {

    // Required init properties
    public var sourceImage: UIImage!
    public var imageBundle: NSBundle
    private var session: IMImojiSession!

    // Transform variables
    private var touchCenter: CGPoint?
    private var rotationCenter: CGPoint?
    private var scaleCenter: CGPoint?

    // Artmoji Views
    private var backgroundView: UIImageView!
    private var backgroundGestureView: UIView!

    // Selected Imoji Views
    private var selectedImojiPreview: UIImageView!
    private var selectedImojis: [IMCreateArtmojiSelectedImojiView]

    private var _selectedImojiView: IMCreateArtmojiSelectedImojiView! {
        didSet {
            if _selectedImojiView != nil {
                _selectedImojiView.selected = true
                _selectedImojiView.showBorder = true

                session.renderImoji(_selectedImojiView.imoji!,
                        options: IMImojiObjectRenderingOptions(renderSize: IMImojiObjectRenderSize.Thumbnail)) { (image, error) -> Void in
                    if error == nil {
                        self.selectedImojiPreview.image = image
                        self.updateFlipImageButtonForSelectedImoji()
                    }
                }
            }

            // Hide imoji edit buttons when there isn't a selectedImoji i.e. when selectedImojis.count is 0
            flipImojiButton.hidden = selectedImojiView == nil
            selectedImojiPreview.hidden = selectedImojiView == nil
        }
    }

    private var selectedImojiView: IMCreateArtmojiSelectedImojiView! {
        get {
            return _selectedImojiView
        }
        set {
            if _selectedImojiView != newValue {
                if(_selectedImojiView != nil) {
                    _selectedImojiView.selected = false
                    _selectedImojiView.showBorder = false
                }

                _selectedImojiView = newValue
            }
        }
    }

    // Top toolbar
    private var navigationBar: UIToolbar!
    private var navigationTitle: UIButton!
    private var cancelButton: UIBarButtonItem!
    private var flipImojiButton: UIButton!

    // Bottom toolbar
    private var bottomBar: UIToolbar!
    private var doneButton: UIButton!
    private var imojiCollectionButton: UIButton!
    private var deleteImojiButton: UIButton!

    // Delegate object
    public var delegate: IMCreateArtmojiViewDelegate?

    // MARK: - Object lifecycle
    public init(session: IMImojiSession, sourceImage: UIImage, imageBundle: NSBundle) {
        selectedImojis = [IMCreateArtmojiSelectedImojiView]()
        self.session = session
        self.sourceImage = sourceImage
        self.imageBundle = imageBundle

        super.init(frame: CGRectZero)

        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        selectedImojis = [IMCreateArtmojiSelectedImojiView]()
        session = IMImojiSession()
        sourceImage = UIImage(named: "frosty-dog")
        imageBundle = IMResourceBundleUtil.assetsBundle()

        super.init(coder: aDecoder)

        setup()
    }

    // MARK: - View lifecycle
    func setup() {
        backgroundColor = UIColor(red: 48.0 / 255.0, green: 48.0 / 255.0, blue: 48.0 / 255.0, alpha: 1.0)

        // Set up title
        navigationTitle = UIButton(type: UIButtonType.Custom)
        navigationTitle.setTitle("ADD STICKERS", forState: UIControlState.Normal)
        navigationTitle.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 18.0)
        navigationTitle.sizeToFit()
        navigationTitle.userInteractionEnabled = false

        // Set up toolbar buttons
        doneButton = UIButton(type: UIButtonType.Custom)
        doneButton.setImage(IMCreateImojiUITheme().trimScreenFinishTraceButtonImage, forState: UIControlState.Normal)
        doneButton.addTarget(self, action: "doneButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        doneButton.frame = CGRectMake(0, 0, 40.0, 40.0)

        deleteImojiButton = UIButton(type: UIButtonType.Custom)
        deleteImojiButton.setImage(UIImage(named: "Artmoji-Delete-Imoji"), forState: UIControlState.Normal)
        deleteImojiButton.addTarget(self, action: "deleteImojiButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        deleteImojiButton.frame = CGRectMake(0, 0, 40.0, 40.0)

        cancelButton = UIBarButtonItem(image: UIImage(named: "Artmoji-Cancel"), style: UIBarButtonItemStyle.Plain, target: self, action: "cancelButtonTapped")

        imojiCollectionButton = UIButton(type: UIButtonType.Custom)
        imojiCollectionButton.setImage(UIImage(named: "toolbar_reactions_on", inBundle: imageBundle, compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
        imojiCollectionButton.addTarget(self, action: "imojiCollectionButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        imojiCollectionButton.frame = CGRectMake(0, 0, 40.0, 40.0)

        flipImojiButton = UIButton(type: UIButtonType.Custom)
        flipImojiButton.setImage(UIImage(named: "Artmoji-Flip-Imoji"), forState: UIControlState.Normal)
        flipImojiButton.addTarget(self, action: "flipImojiButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        flipImojiButton.frame = CGRectMake(0, 0, 40.0, 40.0)
        flipImojiButton.hidden = true

        // Preview of currently selected imoji
        selectedImojiPreview = UIImageView()
        selectedImojiPreview.contentMode = UIViewContentMode.ScaleAspectFit
        selectedImojiPreview.frame = CGRectMake(0, 0, 40.0, 40.0)
        selectedImojiPreview.hidden = true

        // Set up top toolbar
        navigationBar = UIToolbar()
        navigationBar.clipsToBounds = true
        navigationBar.setBackgroundImage(UIImage(), forToolbarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default)
        navigationBar.tintColor = UIColor.whiteColor()
        navigationBar.barTintColor = UIColor.clearColor()
        navigationBar.items = [cancelButton,
                               UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
                               UIBarButtonItem(customView: navigationTitle),
                               UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
                               UIBarButtonItem(customView: flipImojiButton),
                               UIBarButtonItem(customView: selectedImojiPreview)]

        // Set up bottom bar
        bottomBar = UIToolbar()
        bottomBar.clipsToBounds = true
        bottomBar.setBackgroundImage(UIImage(), forToolbarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default)
        bottomBar.barTintColor = UIColor.clearColor()
        bottomBar.items = [UIBarButtonItem(customView: deleteImojiButton),
                           UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
                           UIBarButtonItem(customView: doneButton),
                           UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
                           UIBarButtonItem(customView: imojiCollectionButton)]

        // Artmoji view
        backgroundView = UIImageView(image: sourceImage)
        backgroundView.contentMode = UIViewContentMode.ScaleAspectFill
        backgroundView.userInteractionEnabled = true

        // Background gestures
        backgroundGestureView = UIView()
        backgroundGestureView.userInteractionEnabled = true

        // Add subviews
        addSubview(backgroundView)
        addSubview(backgroundGestureView)
        addSubview(navigationBar)
        addSubview(bottomBar)

        // Constraints
        backgroundView.mas_makeConstraints { make in
            make.edges.equalTo()(self)
        }

        backgroundGestureView.mas_makeConstraints { make in
            make.edges.equalTo()(self)
        }

        navigationBar.mas_makeConstraints { make in
            make.top.equalTo()(self)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.equalTo()(50.0)
        }

        bottomBar.mas_makeConstraints { make in
            make.bottom.equalTo()(self)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.equalTo()(90.0)
        }
        
        setupGestureRecognizers()
    }

    func setupGestureRecognizers() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "imojiPanned:")
        panRecognizer.cancelsTouchesInView = false
        panRecognizer.delegate = self

        let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: "imojiRotated:")
        rotationRecognizer.cancelsTouchesInView = false
        rotationRecognizer.delegate = self

        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: "imojiPinched:")
        pinchRecognizer.cancelsTouchesInView = false
        pinchRecognizer.delegate = self

        backgroundGestureView.addGestureRecognizer(panRecognizer)
        backgroundGestureView.addGestureRecognizer(rotationRecognizer)
        backgroundGestureView.addGestureRecognizer(pinchRecognizer)
    }

    // MARK: - Artmoji editor button logic
    func doneButtonTapped() {
        let image = drawCompositionImage()
        delegate?.userDidFinishCreatingArtmoji?(image, view: self)
    }

    func deleteImojiButtonTapped() {
        if selectedImojiView != nil {
            selectedImojiView.removeFromSuperview()

            let index = selectedImojis.indexOf(selectedImojiView)!
            selectedImojis.removeAtIndex(index)
            selectedImojiView = selectedImojis.last
        }
    }

    func imojiCollectionButtonTapped() {
        delegate?.userDidSelectImojiCollectionButtonFromArtmojiView?(self)
    }

    func cancelButtonTapped() {
        delegate?.userDidCancelCreateArtmojiView?(self)
    }

    func flipImojiButtonTapped() {
        if selectedImojiView != nil {
            selectedImojiView.flipHorizontal()
            updateFlipImageButtonForSelectedImoji()
        }
    }

    func updateFlipImageButtonForSelectedImoji() {
        var image = UIImage(named: "Artmoji-Flip-Imoji")!
        if selectedImojiView.flipped {
            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            let context = UIGraphicsGetCurrentContext()

            CGContextTranslateCTM(context, image.size.width, 0)
            CGContextScaleCTM(context, -1, 1)
            image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))

            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }

        flipImojiButton.setImage(image, forState: UIControlState.Normal)
    }

    // MARK: - Touch overrides
    func handleTouches(touches: Set<UITouch>) {
        self.touchCenter = CGPointZero
        if touches.count < 2 {
            return
        }

        for touch in touches {
            let viewForGesture = selectedImojiView ?? touch.view
            let touchLocation = touch.locationInView(viewForGesture)
            self.touchCenter = CGPointMake(self.touchCenter!.x + touchLocation.x, self.touchCenter!.y + touchLocation.y)
        }

        self.touchCenter = CGPointMake(self.touchCenter!.x / CGFloat(touches.count), self.touchCenter!.y / CGFloat(touches.count))
    }

    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        handleTouches(event!.allTouches()!)
    }

    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        handleTouches(event!.allTouches()!)
    }

    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        handleTouches(event!.allTouches()!)
    }

    // MARK: - Gestures
    func imojiTapped(recognizer: UITapGestureRecognizer) {
        if recognizer.view!.isKindOfClass(IMCreateArtmojiSelectedImojiView) {
            selectedImojiView = recognizer.view as! IMCreateArtmojiSelectedImojiView
        }
    }

    func imojiPanned(recognizer: UIPanGestureRecognizer) {
        // when the user pans an imoji they are selecting it for editing
        if recognizer.view!.isKindOfClass(IMCreateArtmojiSelectedImojiView) {
            selectedImojiView = recognizer.view as! IMCreateArtmojiSelectedImojiView
        }

        if let viewForGesture = selectedImojiView {
            let translation = recognizer.translationInView(viewForGesture)
            let transform = CGAffineTransformTranslate(viewForGesture.transform, translation.x, translation.y)
            viewForGesture.transform = transform
            recognizer.setTranslation(CGPointZero, inView: viewForGesture)
        }
    }

    func imojiRotated(recognizer: UIRotationGestureRecognizer) {
        if let viewForGesture = selectedImojiView {
            if recognizer.state == UIGestureRecognizerState.Began {
                self.rotationCenter = self.touchCenter
            }

            let deltaX = self.rotationCenter!.x - viewForGesture.bounds.size.width / 2
            let deltaY = self.rotationCenter!.y - viewForGesture.bounds.size.height / 2

            var transform = CGAffineTransformTranslate(viewForGesture.transform, deltaX, deltaY)
            transform = CGAffineTransformRotate(transform, recognizer.rotation)
            transform = CGAffineTransformTranslate(transform, -deltaX, -deltaY)
            viewForGesture.transform = transform
            recognizer.rotation = 0
        }
    }

    func imojiPinched(recognizer: UIPinchGestureRecognizer) {
        if let viewForGesture = selectedImojiView {
            if recognizer.state == UIGestureRecognizerState.Began {
                self.scaleCenter = self.touchCenter
            }

            let deltaX = self.scaleCenter!.x - viewForGesture.bounds.size.width / 2.0
            let deltaY = self.scaleCenter!.y - viewForGesture.bounds.size.height / 2.0

            var transform = CGAffineTransformTranslate(viewForGesture.transform, deltaX, deltaY)
            transform = CGAffineTransformScale(transform, recognizer.scale, recognizer.scale)
            transform = CGAffineTransformTranslate(transform, -deltaX, -deltaY)
            viewForGesture.transform = transform

            recognizer.scale = 1
        }
    }

    // MARK: - Image & Imoji logic
    func addImoji(imoji: IMImojiObject) {
        let selectedImojiView = IMCreateArtmojiSelectedImojiView(imoji: imoji, session: self.session)

        if selectedImojis.count == 0 {
            insertSubview(selectedImojiView, aboveSubview: backgroundGestureView)
        } else {
            insertSubview(selectedImojiView, aboveSubview: selectedImojis.last!)
        }

        self.selectedImojiView = selectedImojiView

        let panRecognizer = UIPanGestureRecognizer(target: self, action: "imojiPanned:")
        panRecognizer.cancelsTouchesInView = false
        panRecognizer.delegate = self

        let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: "imojiRotated:")
        rotationRecognizer.cancelsTouchesInView = false
        rotationRecognizer.delegate = self

        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: "imojiPinched:")
        pinchRecognizer.cancelsTouchesInView = false
        pinchRecognizer.delegate = self

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "imojiTapped:")
        tapGestureRecognizer.cancelsTouchesInView = false
        tapGestureRecognizer.delegate = self

        selectedImojiView.userInteractionEnabled = true
        selectedImojiView.addGestureRecognizer(panRecognizer)
        selectedImojiView.addGestureRecognizer(rotationRecognizer)
        selectedImojiView.addGestureRecognizer(pinchRecognizer)
        selectedImojiView.addGestureRecognizer(tapGestureRecognizer)

        selectedImojis.append(selectedImojiView)

        delegate?.artmojiView?(self, didFinishLoadingImoji: imoji)
    }

    func drawCompositionImage() -> UIImage {
        let imageSize = CGSizeMake(self.backgroundView.bounds.size.width, self.backgroundView.bounds.size.height)
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        let context = UIGraphicsGetCurrentContext()

        CGContextSaveGState(context)
        CGContextTranslateCTM(context, self.backgroundView.center.x, self.backgroundView.center.y)
        CGContextConcatCTM(context, self.backgroundView.transform)
        CGContextTranslateCTM(context,
                -self.backgroundView.bounds.size.width * self.backgroundView.layer.anchorPoint.x,
                -self.backgroundView.bounds.size.height * self.backgroundView.layer.anchorPoint.y)
        self.backgroundView.layer.renderInContext(context!)
        CGContextRestoreGState(context)

        for imoji in self.selectedImojis {
            CGContextSaveGState(context)
            CGContextTranslateCTM(context, imoji.center.x, imoji.center.y)
            CGContextConcatCTM(context, imoji.transform)
            CGContextTranslateCTM(context, -imoji.bounds.size.width * imoji.layer.anchorPoint.x, -imoji.bounds.size.height * imoji.layer.anchorPoint.y)
            imoji.layer.renderInContext(context!)
            CGContextRestoreGState(context)
        }

        let watermarkImage = UIImage(named:"Artmoji-Share-Watermark")!
        watermarkImage.drawInRect(CGRectMake(imageSize.width - watermarkImage.size.width, imageSize.height - watermarkImage.size.height, watermarkImage.size.width, watermarkImage.size.height))

        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}

// MARK: - UIGestureRecognizerDelegate
extension IMCreateArtmojiView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}