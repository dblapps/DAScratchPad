//
//  DAScratchpadView.m
//  DAScratchPad
//
//  Created by David Levi on 5/9/13.
//  Copyright 2013 Double Apps Inc. All rights reserved.
//

#import "DAScratchPadView.h"


@implementation DAScratchPadView
{
	void *data;
	CGPoint lastPoint;
	CGContextRef bitmapContext;
	UIColor* _drawColor;
	CGFloat _drawWidth;
	NSMutableArray* segments;
}

- (void) initBitmapContext
{
	size_t wd = (size_t)self.frame.size.width;
	size_t ht = (size_t)self.frame.size.height;
	data = malloc(ht*wd*4);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	bitmapContext = CGBitmapContextCreate(data, wd, ht, 8, wd*4, colorSpace, kCGImageAlphaPremultipliedLast);
	CFRelease(colorSpace);
	CGContextSetLineCap(bitmapContext, kCGLineCapRound);
	CGContextSetLineWidth(bitmapContext, _drawWidth);
	CGContextSetStrokeColorWithColor(bitmapContext, _drawColor.CGColor);
	[self clearToColor:self.backgroundColor];
}

- (void) initCommon
{
	_drawColor = [UIColor blackColor];
	_drawWidth = 5.0f;
	segments = [NSMutableArray array];
	[self initBitmapContext];
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
	CGContextRelease(bitmapContext);
	free(data);
	[self initBitmapContext];
}

- (void)drawRect:(CGRect)rect
{
	rect = CGRectIntegral(rect);
	int x = (int)rect.origin.x;
	int y = (int)(rect.origin.y);
	int wd = (int)rect.size.width;
	int ht = (int)rect.size.height;
	int fromBPR = CGBitmapContextGetBytesPerRow(bitmapContext);
	int toBPR = wd * 4;
	unsigned char* fromData = CGBitmapContextGetData(bitmapContext);
	unsigned char* toData = malloc(ht * toBPR);
	
	for (int row = 0; row < ht; row++) {
		memcpy(&toData[row*toBPR], &fromData[((row+y)*fromBPR)+(x*4)], toBPR);
	}
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, toData, ht*toBPR, NULL);
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGImageRef imageRef = CGImageCreate(wd, ht, 8, 32, toBPR, colorSpaceRef, kCGBitmapByteOrderDefault, provider, NULL, NO, kCGRenderingIntentDefault);
	CGContextDrawImage(ctx, rect, imageRef);
	CFRelease(imageRef);
}

- (UIColor*) drawColor
{
	return _drawColor;
}

- (void) setDrawColor:(UIColor *)drawColor
{
	_drawColor = drawColor;
	CGContextSetStrokeColorWithColor(bitmapContext, _drawColor.CGColor);
}

- (CGFloat) drawWidth
{
	return _drawWidth;
}

- (void) setDrawWidth:(CGFloat)drawWidth
{
	_drawWidth = drawWidth;
	CGContextSetLineWidth(bitmapContext, _drawWidth);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	
	if (!self.userInteractionEnabled) {
		return;
	}
	
	UITouch *touch = [touches anyObject];

	lastPoint = [touch locationInView:self];
	CGContextBeginPath(bitmapContext);
	CGContextMoveToPoint(bitmapContext, lastPoint.x, lastPoint.y);
	CGContextAddLineToPoint(bitmapContext, lastPoint.x, lastPoint.y);
	CGContextStrokePath(bitmapContext);

	[segments addObject:@[@(lastPoint.x),@(lastPoint.y),@(lastPoint.x),@(lastPoint.y)]];
	
	CGFloat inset = -fabsf((_drawWidth / 2.0f) + 1.0f);
	CGRect rect = CGRectInset(CGRectMake(lastPoint.x, 0.0f, 0.0f, self.frame.size.height), inset, 0);
	[self setNeedsDisplayInRect:rect];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!self.userInteractionEnabled) {
		return;
	}

	UITouch *touch = [touches anyObject];	
	CGPoint currentPoint = [touch locationInView:self];
	
	CGContextBeginPath(bitmapContext);
	CGContextMoveToPoint(bitmapContext, lastPoint.x, lastPoint.y);
	CGContextAddLineToPoint(bitmapContext, currentPoint.x, currentPoint.y);
	CGContextStrokePath(bitmapContext);

	[segments addObject:@[@(lastPoint.x),@(lastPoint.y),@(currentPoint.x),@(currentPoint.y)]];

	CGFloat inset = -fabsf((_drawWidth / 2.0f) + 1.0f);
	CGFloat x1 = MIN(lastPoint.x,currentPoint.x);
	CGFloat x2 = MAX(lastPoint.x,currentPoint.x);
	CGRect rect = CGRectInset(CGRectMake(x1, 0.0f, x2-x1, self.frame.size.height), inset, 0.0f);
	[self setNeedsDisplayInRect:rect];

	lastPoint = currentPoint;
}

- (void)dealloc {
	CGContextRelease(bitmapContext);
	free(data);
}

- (void) clearToColor:(UIColor*)color
{
	self.backgroundColor = color;
	CGContextSetFillColorWithColor(bitmapContext, color.CGColor);
	CGContextFillRect(bitmapContext, CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height));
	[self setNeedsDisplay];
}

- (UIImage*) getSketch;
{
	size_t wd = (size_t)self.frame.size.width;
	size_t ht = (size_t)self.frame.size.height;
	
	void* tmpdata = malloc(ht*wd*4);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef tmpBitmapContext = CGBitmapContextCreate(tmpdata, wd, ht, 8, wd*4, colorSpace, kCGImageAlphaPremultipliedLast);
	CFRelease(colorSpace);
	CGContextTranslateCTM(tmpBitmapContext, 0.0f, self.frame.size.height);
	CGContextScaleCTM(tmpBitmapContext, 1.0f, -1.0f);
	CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
	CGContextDrawImage(tmpBitmapContext, CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height), cgImage);
	CFRelease(cgImage);
	cgImage = CGBitmapContextCreateImage(tmpBitmapContext);
	UIImage *image = [UIImage imageWithCGImage:cgImage];
	CFRelease(cgImage);
	CGContextRelease(tmpBitmapContext);
	free(tmpdata);
	return image;
}

- (void) setSketch:(UIImage*)sketch
{
	CGContextSaveGState(bitmapContext);
	CGContextTranslateCTM(bitmapContext, 0.0f, self.frame.size.height);
	CGContextScaleCTM(bitmapContext, 1.0f, -1.0f);
	CGContextDrawImage(bitmapContext, self.bounds, sketch.CGImage);
	CGContextRestoreGState(bitmapContext);
}

@end
