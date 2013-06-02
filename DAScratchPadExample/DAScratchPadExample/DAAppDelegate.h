//
//  DAAppDelegate.h
//  DAScratchPadExample
//
//  Created by David Levi on 5/31/13.
//  Copyright (c) 2013 Double Apps Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DAViewController;

@interface DAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) DAViewController *viewController;

@end
