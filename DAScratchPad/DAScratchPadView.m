//
//  DAScratchpadView.m
//  DAScratchPad
//
//  Created by David Levi on 5/9/13.
//  Copyright 2013 Double Apps Inc. All rights reserved.
//

#import "DAScratchPadView.h"
#import <QuartzCore/QuartzCore.h>

@implementation DAScratchPadView
{
	CGFloat _drawOpacity;
	CALayer* drawLayer;
	UIImage* image;
	UIImage* drawImage;
	CGPoint lastPoint;
}

- (void) initCommon
{
	_drawColor = [UIColor blackColor];
	_drawWidth = 5.0f;
	_drawOpacity = 1.0f;
	drawLayer = [[CALayer alloc] init];
	drawLayer.frame = self.layer.frame;
	image = nil;
	drawImage = nil;
	[self.layer addSublayer:drawLayer];
	[self clearToColor:self.backgroundColor];
}

- (id) initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self initCommon];
	}
    return self;
}

- (id) initWithCoder:(NSCoder *)decoder
{
	if ((self = [super initWithCoder:decoder])) {
		[self initCommon];
	}
	return self;
}

- (void) layoutSubviews
{
	drawLayer.frame = self.layer.frame;
}

- (CGFloat) drawOpacity
{
	return _drawOpacity;
}

- (void) setDrawOpacity:(CGFloat)drawOpacity
{
	_drawOpacity = drawOpacity;
	drawLayer.opacity = _drawOpacity;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	
	if (!self.userInteractionEnabled) {
		return;
	}
	
	UITouch *touch = [touches anyObject];
	lastPoint = [touch locationInView:self];
	lastPoint.y = self.frame.size.height - lastPoint.y;

	UIGraphicsBeginImageContext(self.frame.size);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextScaleCTM(ctx, 1.0f, -1.0f);
	CGContextTranslateCTM(ctx, 0.0f, -self.frame.size.height);
	CGContextSetLineCap(ctx, kCGLineCapRound);
	CGContextSetLineWidth(ctx, self.drawWidth);
	CGContextSetStrokeColorWithColor(ctx, self.drawColor.CGColor);
	CGContextMoveToPoint(ctx, lastPoint.x, lastPoint.y);
	CGContextAddLineToPoint(ctx, lastPoint.x, lastPoint.y);
	CGContextStrokePath(ctx);
	CGContextFlush(ctx);
	drawImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	drawLayer.contents = (id)drawImage.CGImage;
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!self.userInteractionEnabled) {
		return;
	}

	UITouch *touch = [touches anyObject];	
	CGPoint currentPoint = [touch locationInView:self];
	currentPoint.y = self.frame.size.height - currentPoint.y;

	UIGraphicsBeginImageContext(self.frame.size);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextScaleCTM(ctx, 1.0f, -1.0f);
	CGContextTranslateCTM(ctx, 0.0f, -self.frame.size.height);
	CGRect rect = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
	CGContextDrawImage(ctx, rect, drawImage.CGImage);
	CGContextSetLineCap(ctx, kCGLineCapRound);
	CGContextSetLineWidth(ctx, self.drawWidth);
	CGContextSetStrokeColorWithColor(ctx, self.drawColor.CGColor);
	CGContextMoveToPoint(ctx, lastPoint.x, lastPoint.y);
	CGContextAddLineToPoint(ctx, currentPoint.x, currentPoint.y);
	CGContextStrokePath(ctx);
	CGContextFlush(ctx);
	drawImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	drawLayer.contents = (id)drawImage.CGImage;
	lastPoint = currentPoint;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!self.userInteractionEnabled) {
		return;
	}
	UIGraphicsBeginImageContext(self.frame.size);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextScaleCTM(ctx, 1.0f, -1.0f);
	CGContextTranslateCTM(ctx, 0.0f, -self.frame.size.height);
	CGRect rect = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
	if (image != nil) {
		CGContextDrawImage(ctx, rect, image.CGImage);
	}
	CGContextSetAlpha(ctx, self.drawOpacity);
	CGContextDrawImage(ctx, rect, drawImage.CGImage);
	image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

	self.layer.contents = (id)image.CGImage;
    drawLayer.contents = nil;
	drawImage = nil;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!self.userInteractionEnabled) {
		return;
	}
	[self touchesEnded:touches withEvent:event];
}

- (void) clearToColor:(UIColor*)color
{
	UIGraphicsBeginImageContext(self.frame.size);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGRect rect = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
	CGContextSetFillColorWithColor(ctx, color.CGColor);
	CGContextFillRect(ctx, rect);
	CGContextFlush(ctx);
	image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	self.layer.contents = image;
}


- (UIImage*) getSketch;
{
	return image;
}

- (void) setSketch:(UIImage*)sketch
{
	image = sketch;
	self.layer.contents = (id)sketch.CGImage;
}

@end
