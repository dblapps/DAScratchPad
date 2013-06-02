//
//  DAViewController.m
//  DAScratchPadExample
//
//  Created by David Levi on 5/31/13.
//  Copyright (c) 2013 Double Apps Inc. All rights reserved.
//

#import "DAViewController.h"
#import "DAScratchPadView.h"

@interface DAViewController ()
@property (unsafe_unretained, nonatomic) IBOutlet DAScratchPadView *scratchPad;
- (IBAction)setColor:(id)sender;
- (IBAction)setWidth:(id)sender;
@end

@implementation DAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidUnload {
	[self setScratchPad:nil];
	[super viewDidUnload];
}

- (IBAction)setColor:(id)sender
{
	UIButton* button = (UIButton*)sender;
	self.scratchPad.drawColor = button.backgroundColor;
}

- (IBAction)setWidth:(id)sender
{
	UISlider* slider = (UISlider*)sender;
	self.scratchPad.drawWidth = slider.value;
}

@end
