//
//  UIView+EasyFrame.h
//  xcf-iphone
//
//  Created by 徐 东 on 12-11-20.
//
//

#import <UIKit/UIKit.h>

@interface UIView (EasyFrame)

- (CGRect)setX:(CGFloat)x;
- (CGRect)setY:(CGFloat)y;
- (CGRect)setWidth:(CGFloat)width;
- (CGRect)setHeight:(CGFloat)height;

- (CGRect)addX:(CGFloat)delta;
- (CGRect)addY:(CGFloat)delta;
- (CGRect)addWidth:(CGFloat)delta;
- (CGRect)addHeight:(CGFloat)delta;

- (CGPoint)getPosition;
- (CGSize)getSize;
- (CGFloat)getX;
- (CGFloat)getY;
- (CGFloat)getWidth;
- (CGFloat)getHeight;

@end
