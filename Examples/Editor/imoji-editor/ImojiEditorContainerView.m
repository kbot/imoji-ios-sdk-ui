//
// Created by Nima Khoshini on 9/4/15.
// Copyright (c) 2015 Imoji. All rights reserved.
//

#import "ImojiEditorContainerView.h"
#import <Masonry/Masonry.h>
#import <ImojiSDKUI/IMEditorView.h>

@interface ImojiEditorContainerView () <IMEditorViewDelegate>
@property(nonatomic, strong) IMEditorView *imojiEditor;
@property(nonatomic, strong) UIButton *undoButton;
@property(nonatomic, strong) UIButton *doneButton;
@property(nonatomic, strong) UIImageView *outputImage;
@end

@implementation ImojiEditorContainerView {

}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imojiEditor = [IMEditorView new];
        self.outputImage = [UIImageView new];
        self.undoButton = [UIButton new];
        self.doneButton = [UIButton new];

        [self.undoButton setImage:[UIImage imageNamed:@"undo.png"] forState:UIControlStateNormal];
        [self.doneButton setImage:[UIImage imageNamed:@"done.png"] forState:UIControlStateNormal];

        self.doneButton.enabled = self.undoButton.enabled = NO;

        [self addSubview:self.outputImage];
        [self addSubview:self.imojiEditor];
        [self addSubview:self.undoButton];
        [self addSubview:self.doneButton];

        self.imojiEditor.editorDelegate = self;
        self.outputImage.contentMode = UIViewContentModeCenter;
        self.outputImage.hidden = YES;

        [self.imojiEditor mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        [self.outputImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        [self.undoButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.bottom.equalTo(self);
            make.width.and.height.equalTo(@50);
        }];

        [self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.and.bottom.equalTo(self);
            make.width.and.height.equalTo(@50);
        }];

        [self.undoButton addTarget:self action:@selector(performUndo) forControlEvents:UIControlEventTouchUpInside];
        [self.doneButton addTarget:self action:@selector(finishEditing) forControlEvents:UIControlEventTouchUpInside];

        [self.imojiEditor loadImage:[UIImage imageNamed:@"big-big-dog.jpg"]];
    }

    return self;
}

- (void)performUndo {
    if ([self.imojiEditor canUndo]) {
        [self.imojiEditor undo];
    }
}

- (void)finishEditing {
    if (self.imojiEditor.hidden) {
        self.undoButton.hidden = NO;
        self.outputImage.hidden = YES;
        self.imojiEditor.hidden = NO;

        [self.imojiEditor reset];

    } else if ([self.imojiEditor hasOutputImage]) {
        self.outputImage.image = [self.imojiEditor getOutputImage];
        self.undoButton.hidden = YES;
        self.imojiEditor.hidden = YES;
        self.outputImage.hidden = NO;
    }
}

- (void)userDidUpdatePathInEditorView:(IMEditorView *)editorView {
    self.undoButton.enabled = editorView.canUndo;
    self.doneButton.enabled = editorView.hasOutputImage;
}

@end
