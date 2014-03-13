//
//  SBContactView.h
//  Study Bunny
//
//  Created by Gregoire on 3/13/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SBContactViewDelegate <NSObject>

-(void)editModeEnteredForParseKey:(NSString *)key;

@end

@interface SBContactView : UIView<UITextFieldDelegate>

@property (nonatomic, weak) id<SBContactViewDelegate> delegate;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UITextField *input;
@property (nonatomic, strong) UIButton *control;
@property (nonatomic, strong) NSString *parseKey;


@end
