//
//  DAScratchpadView.h
//  DAScratchPad
//
//  Created by David Levi on 5/9/13.
//  Copyright 2013 Double Apps Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface DAScratchPadView : UIControl

@property (strong,nonatomic) UIColor* drawColor;
@property (assign) CGFloat drawWidth;

- (void) clearToColor:(UIColor*)color;

- (UIImage*) getSketch;
- (void) setSketch:(UIImage*)sketch;

@end
