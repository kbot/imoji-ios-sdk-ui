//
//  KeyboardViewController.m
//  iOSKeyboardTemplate
//


#import "QwertyViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Masonry/View+MASAdditions.h>
#import "UIView+RoundedCorners.h"

@interface QwertyViewController () {
    
    int _shiftStatus; //0 = off, 1 = on, 2 = caps lock
    
}

//keyboard rows
@property (nonatomic, weak) IBOutlet UIView *numbersRow1View;
@property (nonatomic, weak) IBOutlet UIView *numbersRow2View;
@property (nonatomic, weak) IBOutlet UIView *symbolsRow1View;
@property (nonatomic, weak) IBOutlet UIView *symbolsRow2View;
@property (nonatomic, weak) IBOutlet UIView *numbersSymbolsRow3View;

//keys
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *letterButtonsArray;
@property (nonatomic, weak) IBOutlet UIButton *switchModeRow3Button;
@property (nonatomic, weak) IBOutlet UIButton *switchModeRow4Button;
@property (nonatomic, weak) IBOutlet UIButton *shiftButton;
@property (nonatomic, weak) IBOutlet UIButton *spaceButton;
@property (nonatomic, weak) IBOutlet UIButton *searchButton;
@property (nonatomic, weak) IBOutlet UIButton *backspaceButton1;
@property (nonatomic, weak) IBOutlet UIButton *backspaceButton2;

@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *numberButtonsArray;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *symbolButtonsArray;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *punctuationButtonsArray;

@end

@implementation QwertyViewController

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeKeyboard];
    
    NSLog(@"width: %f", self.view.frame.size.width);
    NSLog(@"height: %f", self.view.frame.size.height);
    
    for (UIView *subview in self.view.subviews)
    {
        subview.backgroundColor = [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1];
        for (UIView *subsubview in subview.subviews)
        {
            subsubview.backgroundColor = [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - TextInput methods

- (void)textWillChange:(id<UITextInput>)textInput {
    
}

- (void)textDidChange:(id<UITextInput>)textInput {
    
}

#pragma mark - initialization method

- (void) initializeKeyboard {
    [self styleAllButtons];
    
    //start with shift on
    _shiftStatus = 1;
    
    // shift all keys
    // hack
    [self shiftKeyDoubleTapped:nil];
    self.shiftButton.hidden = YES;
    
    //initialize space key double tap
    /*
    UITapGestureRecognizer *spaceDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(spaceKeyDoubleTapped:)];
    
    spaceDoubleTap.numberOfTapsRequired = 2;
    [spaceDoubleTap setDelaysTouchesEnded:NO];
    
    [self.spaceButton addGestureRecognizer:spaceDoubleTap];
    */
    
    //initialize shift key double and triple tap
    UITapGestureRecognizer *shiftDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shiftKeyDoubleTapped:)];
    UITapGestureRecognizer *shiftTripleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shiftKeyPressed:)];
    
    shiftDoubleTap.numberOfTapsRequired = 2;
    shiftTripleTap.numberOfTapsRequired = 3;
    
    [shiftDoubleTap setDelaysTouchesEnded:NO];
    [shiftTripleTap setDelaysTouchesEnded:NO];
    
    [self.shiftButton addGestureRecognizer:shiftDoubleTap];
    [self.shiftButton addGestureRecognizer:shiftTripleTap];
    
}

#pragma mark - key methods

- (IBAction) globeKeyPressed:(id)sender {
    
    //required functionality, switches to user's next keyboard
    // [self advanceToNextInputMode];
}

- (IBAction) keyPressed:(UIButton*)sender {
    
    //inserts the pressed character into the text document
    //[self.textDocumentProxy insertText:sender.titleLabel.text];
    [self.searchField insertText:sender.titleLabel.text];
    
    //if shiftStatus is 1, reset it to 0 by pressing the shift key
    if (_shiftStatus == 1) {
        [self shiftKeyPressed:self.shiftButton];
    }

}

-(IBAction) backspaceKeyPressed: (UIButton*) sender {
    
    //[self.textDocumentProxy deleteBackward];
    [self.searchField deleteBackward];
}



-(IBAction) spaceKeyPressed: (UIButton*) sender {
    
   // [self.textDocumentProxy insertText:@" "];
    [self.searchField insertText:@" "];
}


-(void) spaceKeyDoubleTapped: (UIButton*) sender {
    
    //double tapping the space key automatically inserts a period and a space
    //if necessary, activate the shift button
    //[self.textDocumentProxy deleteBackward];
    //[self.textDocumentProxy insertText:@". "];
    [self.searchField deleteBackward];
    [self.searchField insertText:@". "];
    
    if (_shiftStatus == 0) {
        [self shiftKeyPressed:self.shiftButton];
    }
}


-(IBAction) returnKeyPressed: (UIButton*) sender {
    self.setSearchCallback();
}


-(IBAction) shiftKeyPressed: (UIButton*) sender {
    
    //if shift is on or in caps lock mode, turn it off. Otherwise, turn it on
    _shiftStatus = _shiftStatus > 0 ? 0 : 1;
    
    [self shiftKeys];
}



-(void) shiftKeyDoubleTapped: (UIButton*) sender {
    
    //set shift to caps lock and set all letters to uppercase
    _shiftStatus = 2;
    
    [self shiftKeys];

}


- (void) shiftKeys {
    
    //if shift is off, set letters to lowercase, otherwise set them to uppercase
    if (_shiftStatus == 0) {
        for (UIButton* letterButton in self.letterButtonsArray) {
            [letterButton setTitle:letterButton.titleLabel.text.lowercaseString forState:UIControlStateNormal];
        }
    } else {
        for (UIButton* letterButton in self.letterButtonsArray) {
            [letterButton setTitle:letterButton.titleLabel.text.uppercaseString forState:UIControlStateNormal];
        }
    }
    
    //adjust the shift button images to match shift mode
    NSString *shiftButtonImageName = [NSString stringWithFormat:@"shift_%i.png", _shiftStatus];
    [self.shiftButton setImage:[UIImage imageNamed:shiftButtonImageName] forState:UIControlStateNormal];

    
    NSString *shiftButtonHLImageName = [NSString stringWithFormat:@"shift_%iHL.png", _shiftStatus];
    [self.shiftButton setImage:[UIImage imageNamed:shiftButtonHLImageName] forState:UIControlStateHighlighted];
    
}

-(void)styleAllButtons {
    for (UIButton* letterButton in self.letterButtonsArray) {
        [self styleButton:letterButton];
    }
    for (UIButton* numberButton in self.numberButtonsArray) {
        [self styleButton:numberButton];
    }
    for (UIButton* symbolButton in self.symbolButtonsArray) {
        [self styleButton:symbolButton];
    }
    for (UIButton* punctuationButton in self.punctuationButtonsArray) {
        [self styleButton:punctuationButton];
    }
    
    [self styleButton:self.spaceButton];
    [self styleButton:self.switchModeRow3Button];
    [self styleButton:self.switchModeRow4Button];
    [self styleButton:self.searchButton];
    [self styleButton:self.backspaceButton1];
    [self styleButton:self.backspaceButton2];
}

-(void)styleButton:(UIButton*) button {
    UIView *v = [[UIView alloc] init];
    v.frame = CGRectMake(0,0,24,24);
    v.backgroundColor = [UIColor colorWithRed:252/255.f green:252/255.f blue:252/255.f alpha:1];
    v.layer.cornerRadius = 5.f;
    v.layer.masksToBounds = YES;
    v.userInteractionEnabled = NO;
    v.layer.borderColor = [UIColor colorWithRed:194/255.f green:194/255.f blue:194/255.f alpha:1].CGColor;
    v.layer.borderWidth = 1.0f;
    v.tag = 0;
    
    v.layer.masksToBounds = NO;
    v.layer.shadowColor = [UIColor blackColor].CGColor;
    v.layer.shadowOffset = CGSizeMake(0.0f, 0.6f);
    v.layer.shadowRadius = 0.5f;
    v.layer.shadowOpacity = 0.26f;
    
    [button insertSubview:v atIndex:0];
    [button bringSubviewToFront:button.imageView];
    [button addTarget:self action:@selector(highlight:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(unhighlight:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(unhighlight:) forControlEvents:UIControlEventTouchUpOutside];
    [v mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(button.mas_left).offset(2);
        make.top.equalTo(button.mas_top).offset(5);
        make.right.equalTo(button.mas_right).offset(-2);
        make.bottom.equalTo(button.mas_bottom).offset(-5);
    }];
    
    [button setTitleColor:[UIColor colorWithRed:42/255.f green:42/255.f blue:42/255.f alpha:1.0] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
}

-(void)highlight:(UIButton*)sender {
    for (UIView *v in sender.subviews){
        if(v.tag == 0){
            v.backgroundColor = [UIColor lightGrayColor];
        }
    }
}

-(void)unhighlight:(UIButton*)sender {
    for (UIView *v in sender.subviews){
        if(v.tag == 0){
            v.backgroundColor = [UIColor colorWithRed:252/255.f green:252/255.f blue:252/255.f alpha:1];
        }
    }
}


- (IBAction) switchKeyboardMode:(UIButton*)sender {
    
    self.numbersRow1View.hidden = YES;
    self.numbersRow2View.hidden = YES;
    self.symbolsRow1View.hidden = YES;
    self.symbolsRow2View.hidden = YES;
    self.numbersSymbolsRow3View.hidden = YES;
    
    //switches keyboard to ABC, 123, or #+= mode
    //case 1 = 123 mode, case 2 = #+= mode
    //default case = ABC mode
    
    switch (sender.tag) {
            
        case 1: {
            self.numbersRow1View.hidden = NO;
            self.numbersRow2View.hidden = NO;
            self.numbersSymbolsRow3View.hidden = NO;
            
            //change row 3 switch button image to #+= and row 4 switch button to ABC
            [self.switchModeRow3Button setTitle:@"#+=" forState:UIControlStateNormal];
            self.switchModeRow3Button.tag = 2;
            [self.switchModeRow4Button setTitle:@"ABC" forState:UIControlStateNormal];
            self.switchModeRow4Button.tag = 0;
        }
            break;
            
        case 2: {
            self.symbolsRow1View.hidden = NO;
            self.symbolsRow2View.hidden = NO;
            self.numbersSymbolsRow3View.hidden = NO;
            
            //change row 3 switch button image to 123
            [self.switchModeRow3Button setTitle:@"123" forState:UIControlStateNormal];
            self.switchModeRow3Button.tag = 1;
        }
            break;
        
        default:
            //change the row 4 switch button image to 123
            [self.switchModeRow4Button setTitle:@"123" forState:UIControlStateNormal];
            self.switchModeRow4Button.tag = 1;
            break;
    }
    
}

@end
