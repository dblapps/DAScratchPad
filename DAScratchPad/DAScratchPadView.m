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
	CGFloat _airBrushFlow;
	CGFloat _airBrushRate;
	CALayer* drawLayer;
	UIImage* mainImage;
	UIImage* drawImage;
	CGPoint lastPoint;
	CGPoint currentPoint;
	NSTimer* airBrushTimer;
	UIImage* airBrushImage;
}

- (void) initCommon
{
	_toolType = DAScratchPadToolTypePaint;
	_drawColor = [UIColor blackColor];
	_drawWidth = 5.0f;
	_drawOpacity = 1.0f;
	_airBrushFlow = 0.5f;
	_airBrushRate = 0.5f;
	drawLayer = [[CALayer alloc] init];
	drawLayer.frame = self.layer.frame;
	mainImage = nil;
	drawImage = nil;
	airBrushTimer = nil;
	airBrushImage = nil;
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

- (CGFloat) airBrushFlow
{
	return _airBrushFlow;
}

- (void) setAirBrushFlow:(CGFloat)airBrushFlow
{
	_airBrushFlow = MIN(MAX(airBrushFlow, 0.0f), 1.0f);
}

- (CGFloat) airBrushRate
{
	return _airBrushRate;
}

- (void) setAirBrushRate:(CGFloat)airBrushRate
{
	_airBrushRate = MIN(MAX(airBrushRate, 0.0f), 1.0f);
}

- (void) drawLineFrom:(CGPoint)from to:(CGPoint)to width:(CGFloat)width
{
	UIGraphicsBeginImageContext(self.frame.size);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextScaleCTM(ctx, 1.0f, -1.0f);
	CGContextTranslateCTM(ctx, 0.0f, -self.frame.size.height);
	if (drawImage != nil) {
		CGRect rect = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
		CGContextDrawImage(ctx, rect, drawImage.CGImage);
	}
	CGContextSetLineCap(ctx, kCGLineCapRound);
	CGContextSetLineWidth(ctx, width);
	CGContextSetStrokeColorWithColor(ctx, self.drawColor.CGColor);
	CGContextMoveToPoint(ctx, from.x, from.y);
	CGContextAddLineToPoint(ctx, to.x, to.y);
	CGContextStrokePath(ctx);
	CGContextFlush(ctx);
	drawImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	drawLayer.contents = (id)drawImage.CGImage;
}

- (void) drawImage:(UIImage*)image at:(CGPoint)point
{
	UIGraphicsBeginImageContext(self.frame.size);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextScaleCTM(ctx, 1.0f, -1.0f);
	CGContextTranslateCTM(ctx, 0.0f, -self.frame.size.height);
	if (drawImage != nil) {
		CGRect rect = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
		CGContextDrawImage(ctx, rect, drawImage.CGImage);
	}
	CGRect rect = CGRectMake(point.x - (image.size.width / 2.0f),
							 point.y - (image.size.height / 2.0f),
							 image.size.width, image.size.height);
	CGContextDrawImage(ctx, rect, image.CGImage);
	CGContextFlush(ctx);
	drawImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	drawLayer.contents = (id)drawImage.CGImage;
}

- (void) commitDrawingWithOpacity:(CGFloat)opacity
{
	UIGraphicsBeginImageContext(self.frame.size);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextScaleCTM(ctx, 1.0f, -1.0f);
	CGContextTranslateCTM(ctx, 0.0f, -self.frame.size.height);
	CGRect rect = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
	if (mainImage != nil) {
		CGContextDrawImage(ctx, rect, mainImage.CGImage);
	}
	CGContextSetAlpha(ctx, opacity);
	CGContextDrawImage(ctx, rect, drawImage.CGImage);
	mainImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
	self.layer.contents = (id)mainImage.CGImage;
    drawLayer.contents = nil;
	drawImage = nil;
}

- (void)paintTouchesBegan
{
	drawLayer.opacity = self.drawOpacity;
	[self drawLineFrom:lastPoint to:lastPoint width:self.drawWidth];
}

- (void)paintTouchesMoved
{
	[self drawLineFrom:lastPoint to:currentPoint width:self.drawWidth];
}

- (void) paintTouchesEnded
{
	[self commitDrawingWithOpacity:self.drawOpacity];
}

- (void) airBrushTimerExpired:(NSTimer*)timer
{
	[self drawImage:airBrushImage at:lastPoint];
}

- (void) airBrushTouchesBegan
{
	UIGraphicsBeginImageContext(CGSizeMake(self.drawWidth, self.drawWidth));
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(ctx, self.drawColor.CGColor);
	CGContextSetAlpha(ctx, 0.005f + (self.airBrushFlow / 50.0f));
	for (CGFloat wd = 0.0f; wd <= self.drawWidth; wd += 1.0f) {
		CGFloat mid = (self.drawWidth - wd) / 2.0f;
		CGContextFillEllipseInRect(ctx, CGRectMake(mid, mid, wd, wd));
	}
	CGContextFlush(ctx);
	airBrushImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	airBrushTimer = [NSTimer scheduledTimerWithTimeInterval:(9.0f - (self.airBrushRate * 8.0f)) / 60.0f
													 target:self
												   selector:@selector(airBrushTimerExpired:)
												   userInfo:nil
													repeats:YES];
}

- (void) airBrushTouchesMoved
{
}

- (void) airBrushTouchesEnded
{
	[airBrushTimer invalidate];
	airBrushTimer = nil;
	airBrushImage = nil;
	[self commitDrawingWithOpacity:self.drawOpacity];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!self.userInteractionEnabled) {
		[super touchesBegan:touches withEvent:event];
		return;
	}
	
	UITouch *touch = [touches anyObject];
	lastPoint = [touch locationInView:self];
	lastPoint.y = self.frame.size.height - lastPoint.y;
	
	if (self.toolType == DAScratchPadToolTypePaint) {
		[self paintTouchesBegan];
	}
	if (self.toolType == DAScratchPadToolTypeAirBrush) {
		[self airBrushTouchesBegan];
	}
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!self.userInteractionEnabled) {
		[super touchesMoved:touches withEvent:event];
		return;
	}

	UITouch *touch = [touches anyObject];	
	currentPoint = [touch locationInView:self];
	currentPoint.y = self.frame.size.height - currentPoint.y;

	if (self.toolType == DAScratchPadToolTypePaint) {
		[self paintTouchesMoved];
	}
	if (self.toolType == DAScratchPadToolTypeAirBrush) {
		[self airBrushTouchesMoved];
	}

	lastPoint = currentPoint;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!self.userInteractionEnabled) {
		[super touchesEnded:touches withEvent:event];
		return;
	}
	
	if (self.toolType == DAScratchPadToolTypePaint) {
		[self paintTouchesEnded];
	}
	if (self.toolType == DAScratchPadToolTypeAirBrush) {
		[self airBrushTouchesEnded];
	}
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!self.userInteractionEnabled) {
		[super touchesCancelled:touches withEvent:event];
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
	mainImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	self.layer.contents = mainImage;
}


- (UIImage*) getSketch;
{
	return mainImage;
}

- (void) setSketch:(UIImage*)sketch
{
	mainImage = sketch;
	self.layer.contents = (id)sketch.CGImage;
}

@end
