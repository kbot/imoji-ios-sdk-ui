//
// Created by Nima Khoshini on 9/25/15.
//

#import "IMCreateImojiAssistantViewController.h"
#import "View+MASAdditions.h"
#import "IMResourceBundleUtil.h"
#import "IMAttributeStringUtil.h"


@interface IMCreateImojiAssistantViewController ()

@property(nonatomic, strong, nonnull, readonly) UIView *tipsView;
@property(nonatomic, strong, nonnull, readonly) UIButton *proceedButton;
@property(nonatomic, strong, nonnull, readonly) UILabel *tipTitle;
@property(nonatomic, strong, nonnull, readonly) UILabel *tipDescription;
@property(nonatomic, strong, nonnull, readonly) UIImageView *tipImage;

@end

@implementation IMCreateImojiAssistantViewController {

}

- (instancetype)initWithSession:(nonnull IMImojiSession *)session {
    self = [super initWithNibName:nil bundle:nil];

    if (self) {
        _session = session;
    }

    return self;
}

- (void)loadView {
    [super loadView];

    self.view.backgroundColor = [UIColor clearColor];

    _tipsView = [UIView new];
    _proceedButton = [UIButton new];
    _tipTitle = [UILabel new];
    _tipDescription = [UILabel new];
    _tipImage = [UIImageView new];

    [self.view addSubview:self.tipsView];
    [self.view addSubview:self.proceedButton];
    [self.view addSubview:self.tipTitle];
    [self.view addSubview:self.tipDescription];
    [self.view addSubview:self.tipImage];

    [self.tipsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view).offset(-30.0f);
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view).multipliedBy(.8f);
        make.height.equalTo(self.view).multipliedBy(.7f);
    }];

    [self.proceedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-20.f);
        make.width.height.equalTo(@60.0f);
    }];

    [self.tipTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.top.left.equalTo(self.tipsView);
        make.height.equalTo(@80.0f);
    }];

    [self.tipDescription mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.centerX.equalTo(self.tipsView);
        make.width.equalTo(self.tipsView).multipliedBy(.75f);
        make.height.equalTo(@80.0f);
    }];

    [self.tipImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(self.tipsView);
        make.top.equalTo(self.tipTitle.mas_bottom);
        make.bottom.equalTo(self.tipDescription.mas_top);
    }];

    self.tipsView.backgroundColor = [UIColor whiteColor];
    self.tipsView.layer.cornerRadius = 10.0f;

    self.tipImage.contentMode = UIViewContentModeScaleAspectFit;
    self.tipImage.image = [UIImage imageNamed:@"ImojiUIAssets.bundle/collection_view_splash_collection"];

    [self.proceedButton setImage:[IMResourceBundleUtil rightArrowButtonImage:52.f
                                                                 circleColor:[UIColor clearColor]
                                                                 borderColor:[UIColor colorWithWhite:22.f / 255.f alpha:.4f]
                                                                 strokeWidth:4.0f]
                        forState:UIControlStateNormal];

    [self.proceedButton addTarget:self
                           action:@selector(proceedButtonTapped:)
                 forControlEvents:UIControlEventTouchUpInside];

    self.tipTitle.attributedText = [IMAttributeStringUtil attributedString:@"Tips"
                                                                  withFont:[IMAttributeStringUtil defaultFontWithSize:15.f]
                                                                     color:[UIColor colorWithWhite:22.f / 255.f alpha:.4f]
                                                              andAlignment:NSTextAlignmentCenter];

    self.tipDescription.text = @"Trace what you want your sticker to be";
    self.tipDescription.font = self.tipTitle.font = [IMAttributeStringUtil defaultFontWithSize:15.f];
    self.tipDescription.textColor = self.tipTitle.textColor = [UIColor colorWithWhite:22.f / 255.f alpha:.4f];
    self.tipDescription.lineBreakMode = NSLineBreakByWordWrapping;
    self.tipDescription.textAlignment = NSTextAlignmentCenter;
    self.tipDescription.numberOfLines = 2;

    self.view.userInteractionEnabled = YES;
}

- (void)proceedButtonTapped:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

+ (instancetype)createAssistantViewControllerWithSession:(nonnull IMImojiSession *)session {
    return [[IMCreateImojiAssistantViewController alloc] initWithSession:session];
}

@end
