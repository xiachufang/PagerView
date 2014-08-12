//
//  UIView+EasyFrame.m
//  xcf-iphone
//
//  Created by 徐 东 on 12-11-20.
//
//

#import "UIView+EasyFrame.h"

@implementation UIView (EasyFrame)

- (CGRect)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
    return self.frame;
}

- (CGRect)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
    return self.frame;
}

- (CGRect)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
    return self.frame;
}

- (CGRect)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
    return self.frame;
}

- (CGRect)addX:(CGFloat)delta
{
    return [self setX:[self getX] + delta];
}

- (CGRect)addY:(CGFloat)delta
{
    return [self setY:[self getY] + delta];
}

- (CGRect)addWidth:(CGFloat)delta
{
    return [self setWidth:[self getWidth] + delta];
}

- (CGRect)addHeight:(CGFloat)delta
{
    return [self setHeight:[self getHeight] + delta];
}

- (CGPoint)getPosition
{
    return self.frame.origin;
}

- (CGSize)getSize
{
    return self.frame.size;
}

- (CGFloat)getX
{
    return self.frame.origin.x;
}

- (CGFloat)getY
{
    return self.frame.origin.y;
}

- (CGFloat)getWidth
{
    return self.frame.size.width;
}

- (CGFloat)getHeight
{
    return self.frame.size.height;
}

@end
