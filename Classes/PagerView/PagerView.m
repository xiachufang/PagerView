//
//  PagerView.m
//  recipeHD
//
//  Created by 徐 东 on 14-3-6.
//  Copyright (c) 2014年 RuidiInteractive. All rights reserved.
//

#import "PagerView.h"

@class PagerViewDelegateWrapper;

@interface UIView (EasyFrame)
@end
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
@end

@interface PagerView ()

@property (strong,nonatomic) NSMutableArray *recyclingViews;
@property (strong,nonatomic) NSMutableDictionary *visibleViews;
@property (strong,nonatomic) PagerViewDelegateWrapper *delegateWrapper;
@property (assign,nonatomic,setter = setPageIndex:) NSUInteger currentPageIndex;//这里要用自定义的setter名，否则ReactiveCocoa会在每次为其赋值的时候都触发新的信号，但是我们希望只有在他的值变化时才触发信号
@property (assign,nonatomic) NSUInteger pageNumber;
@property (assign,nonatomic) CGSize pageSize;
@property (strong,nonatomic) NSMutableDictionary *pageMargins;

@property (assign,nonatomic) CGRect oldBounds;
@property (assign,nonatomic) CGSize oldPageSize;
@property (strong,nonatomic) NSMutableDictionary *oldPageMargins;

- (void)internalSetup;
- (UIControl *)viewForIndex:(NSUInteger)index;
- (void)updateContentSize;
- (void)updatePageSize;
- (void)updatePageNumber;
- (void)updatePageMargin;
- (void)updatePage:(UIControl *)view frameForIndex:(NSUInteger)index;
- (void)updateCurrentPageIndex;
- (void)loadVisibleViews;
- (void)unloadInvisibleViews;
- (void)unloadAllViews;
- (void)trackTouchedInsideEventForControl:(UIControl *)view;
- (void)untrackTouchedInsideEventForControl:(UIControl *)view;
- (void)touchInsideOfControl:(UIControl *)view;
- (void)selectControl:(UIControl *)view;
- (void)notifyPageSelectedWithIndex:(NSUInteger)index;
- (void)addView:(UIControl *)view;
- (void)removeView:(UIControl *)view;
- (BOOL)isNeededToLoadViews;
- (BOOL)isNeededToUnloadViews;

/**
 * 该方法用于计算由于用户操作引起ContentOffset改变后，最终的ContentOffset，新的offset是用户手指离开时的坐标左侧或右侧（左右取决于运动方向）最近的Page停靠点，或ContentOffset的最大值
 **/
- (CGPoint)calculateOnePageContentOffsetWithTargetOffset:(CGPoint)offset;
/**
 * 该方法用于计算由于程序引起ContentOffset改变后，最终的contentOffset，新的offset是targetOffset左边最大的Page停靠点或ContentOffset的最大值
 **/
- (void)updatePagingContentOffsetWithOldContentSize:(CGSize)oldSize newContentSize:(CGSize)newSize;
- (NSUInteger)calculatePageIndexWithOffset:(CGPoint)offset;
- (CGRect)calculatePageRectForIndex:(NSUInteger)index;
- (CGFloat)calculatPageLeftForIndex:(NSUInteger)index;
- (CGFloat)calculatPageRightForIndex:(NSUInteger)index;
- (CGRect)calculateVisiblePagesUnionRect;
- (CGRect)calculateVisiblePagesUnionRectWithMargins;
- (CGSize)calculateContentSize;
- (CGFloat)calculatePageLeftMarginForIndex:(NSUInteger)index;
- (CGFloat)calculatePageRightMarginForIndex:(NSUInteger)index;

- (NSUInteger)calculatePageIndexWithOffset:(CGPoint)offset pageSize:(CGSize)pageSize pageMargins:(NSDictionary *)margins;
- (CGRect)calculatePageRectForIndex:(NSUInteger)index pageSize:(CGSize)pageSize pageMargins:(NSDictionary *)margins;
- (CGFloat)calculatPageLeftForIndex:(NSUInteger)index pageSize:(CGSize)pageSize pageMargins:(NSDictionary *)margins;
- (CGFloat)calculatPageRightForIndex:(NSUInteger)index pageSize:(CGSize)pageSize pageMargins:(NSDictionary *)margins;
- (CGRect)calculateVisiblePagesUnionRectWithPageSize:(CGSize)pageSize pageMargins:(NSDictionary *)margins;
- (CGRect)calculateVisiblePagesUnionRectWithMarginsWithPageSize:(CGSize)pageSize pageMargins:(NSDictionary *)margins;
- (CGSize)calculateContentSizeWithPageSize:(CGSize)pageSize pageMargins:(NSDictionary *)margins;
- (CGFloat)calculatePageLeftMarginForIndex:(NSUInteger)index pageSize:(CGSize)pageSize pageMargins:(NSDictionary *)margins;
- (CGFloat)calculatePageRightMarginForIndex:(NSUInteger)index pageSize:(CGSize)pageSize pageMargins:(NSDictionary *)margins;

#pragma mark - data source getter

- (NSUInteger)getPageNumberFromDatasource;
- (CGSize)getPageSizeFromDatasource;
- (CGRect)getPageViewFrameFromDatasourceForIndex:(NSUInteger)index;
- (UIControl *)getViewFromDatasourceForIndex:(NSUInteger)index reuseView:(UIControl *)reuseView;
- (CGSize)getPageMarginFromDatasourceForIndex:(NSUInteger)index;

@end

@interface PagerViewDelegateWrapper : NSObject<UIScrollViewDelegate>

@property (weak,nonatomic) id<UIScrollViewDelegate> scrollViewDelegate;
@property (weak,nonatomic) PagerView *pagerView;

- (id)initWithPagerView:(PagerView *)pager;

@end

@implementation PagerViewDelegateWrapper

- (id)initWithPagerView:(PagerView *)pager
{
    self = [super init];
    if (self) {
        _pagerView = pager;
    }
    return self;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.scrollViewDelegate scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.scrollViewDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [self.scrollViewDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self.scrollViewDelegate scrollViewDidEndScrollingAnimation:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.scrollViewDelegate scrollViewDidScroll:scrollView];
}

-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    [self.scrollViewDelegate scrollViewDidScrollToTop:scrollView];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return [self.scrollViewDelegate scrollViewShouldScrollToTop:scrollView];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self.scrollViewDelegate scrollViewWillBeginDecelerating:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.scrollViewDelegate scrollViewWillBeginDragging:scrollView];
}

-(void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    [self.scrollViewDelegate scrollViewWillBeginZooming:scrollView withView:view];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGPoint newOffset = [self.pagerView calculateOnePageContentOffsetWithTargetOffset:*targetContentOffset];
    [self.scrollViewDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:&newOffset];
    *targetContentOffset = newOffset;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [self.scrollViewDelegate viewForZoomingInScrollView:scrollView];
}

@end

@implementation PagerView

@synthesize pagingEnabled = _pagingEnabled;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self internalSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self internalSetup];
    }
    return self;
}

- (BOOL)isPagingEnabled
{
    NSString *caller = [NSThread callStackSymbols][1];
    if ([caller rangeOfString:@"UIKit"].location != NSNotFound) {//欺骗 UIKit
        return NO;
    }
    return _pagingEnabled;
}

- (void)setPagingEnabled:(BOOL)pagingEnabled
{
    _pagingEnabled = pagingEnabled;
}

- (void)internalSetup
{
    self.delegateWrapper = [[PagerViewDelegateWrapper alloc]initWithPagerView:self];
    super.delegate = self.delegateWrapper;
    self.pagingEnabled = YES;
    self.clipsToBounds = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.canCancelContentTouches = YES;
    self.visibleViews = [NSMutableDictionary dictionary];
    self.recyclingViews = [NSMutableArray array];
    self.pageMargins = [NSMutableDictionary dictionary];
    self.oldPageMargins = [NSMutableDictionary dictionary];
    
    [self reloadData];
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return YES;
}

- (void)setDelegate:(id<UIScrollViewDelegate>)delegate
{
    self.delegateWrapper.scrollViewDelegate = delegate;
}

- (id<UIScrollViewDelegate>)delegate
{
    return self.delegateWrapper.scrollViewDelegate;
}

- (void)setPageIndex:(NSUInteger)currentPageIndex
{
    NSUInteger oldIndex = _currentPageIndex;
    if (currentPageIndex != oldIndex) {
        [self willChangeValueForKey:NSStringFromSelector(@selector(currentPageIndex))];
        _currentPageIndex = currentPageIndex;
        [self didChangeValueForKey:NSStringFromSelector(@selector(currentPageIndex))];
        if (self.notifyPageIndexChangedBlock && self.pagingEnabled) {
            self.notifyPageIndexChangedBlock(self,_currentPageIndex);
        }
    }
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    CGPoint old = self.contentOffset;
    if (!CGPointEqualToPoint(old, contentOffset)) {
        if (!(self.isDragging || self.isDecelerating)) {
            NSString *caller = [NSThread callStackSymbols][1];
            if ([caller rangeOfString:@"UIKit"].location == NSNotFound || [caller rangeOfString:@"_adjustContentOffsetIfNecessary"].location == NSNotFound) {//只接受非UIKit中的方法修改ContentOffset，因为UIKit在尺寸变化前按需调整ContentOffset，但它的调整效果不是我们想要的，我们希望在尺寸变化前ContentOffset不要变，在尺寸变化后我们会重新计算正确的ContentOffset
                [super setContentOffset:contentOffset];
                if (self.pagingEnabled) {
                    [self updateCurrentPageIndex];
                }
            }
        }else {
            [super setContentOffset:contentOffset];
            if (self.pagingEnabled) {
                [self updateCurrentPageIndex];
            }
        }
    }
}

- (void)setContentSize:(CGSize)contentSize
{
    CGSize old = self.contentSize;
    [super setContentSize:contentSize];
    [self updatePagingContentOffsetWithOldContentSize:old newContentSize:contentSize];
}

- (void)setBounds:(CGRect)bounds
{
    self.oldBounds = self.bounds;
    [super setBounds:bounds];
    if (self.oldBounds.size.width != bounds.size.width) {
        [self updateContentSize];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if ([self isNeededToLoadViews]) {
        [self loadVisibleViews];
    }
    [self unloadInvisibleViews];
}


- (void)updateContentSize
{
    [self updatePageSize];
    [self updatePageMargin];
    CGSize calculation = [self calculateContentSize];
    self.contentSize = CGSizeMake(MAX(self.bounds.size.width, calculation.width), MAX(self.bounds.size.height, calculation.height));
    [self setNeedsLayout];
}

- (void)updatePageNumber
{
    self.pageNumber = [self getPageNumberFromDatasource];
}

- (void)updatePageSize
{
    self.oldPageSize = self.pageSize;
    self.pageSize = [self getPageSizeFromDatasource];
}

- (void)updatePageMargin
{
    [self.oldPageMargins removeAllObjects];
    [self.oldPageMargins addEntriesFromDictionary:self.pageMargins];
    [self.pageMargins removeAllObjects];
    for (int i = 0 ; i < self.pageNumber; i++) {
        CGSize margin = [self getPageMarginFromDatasourceForIndex:i];
        NSValue *marginObj = [NSValue valueWithCGSize:margin];
        [self.pageMargins setObject:marginObj forKey:@(i)];
    }
}

- (void)updatePage:(UIControl *)view frameForIndex:(NSUInteger)index
{
    CGRect frameInPage = [self getPageViewFrameFromDatasourceForIndex:index];
    CGFloat frameOffset = [self calculatPageLeftForIndex:index];
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
    [view setX:frameOffset + frameInPage.origin.x];
    [view setY:frameInPage.origin.y];
    [view setWidth:frameInPage.size.width];
    [view setHeight:frameInPage.size.height];
    [CATransaction commit];
}

- (void)updateCurrentPageIndex
{
    self.currentPageIndex = [self calculatePageIndexWithOffset:self.contentOffset];
}

#pragma mark - load/unload views

- (void)loadVisibleViews
{
    CGPoint currentOffset = self.contentOffset;
    NSUInteger currentPageIndex = [self calculatePageIndexWithOffset:currentOffset];
    CGRect contentRect = {currentOffset, self.bounds.size};
    for (NSUInteger i = currentPageIndex; i < self.pageNumber; i++) {
        CGRect pageRect = [self calculatePageRectForIndex:i];
        if (CGRectIntersectsRect(contentRect, pageRect)) {
            UIControl *view = [self viewForIndex:i];
            [self updatePage:view frameForIndex:i];
            if (view && view.superview != self) {
                [self addView:view];
                [self.visibleViews[@(i)] removeFromSuperview];
                self.visibleViews[@(i)] = view;
                [self.recyclingViews removeObject:view];
            }
        }
    }
}

- (void)unloadInvisibleViews
{
    NSMutableArray *removal = [NSMutableArray array];
    [self.visibleViews enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, UIControl *obj, BOOL *stop) {
        CGRect contentRect = {self.contentOffset, self.bounds.size};
        CGRect pageRect = [self calculatePageRectForIndex:[key unsignedIntegerValue]];
        if (!CGRectIntersectsRect(contentRect, pageRect)) {
            [self removeView:obj];
            [removal addObject:key];
            [self.recyclingViews addObject:obj];
        }
    }];
    [self.visibleViews removeObjectsForKeys:removal];
}

- (void)unloadAllViews
{
    [self.visibleViews enumerateKeysAndObjectsUsingBlock:^(id key, UIControl *obj, BOOL *stop) {
        [self removeView:obj];
    }];
    [self.recyclingViews addObjectsFromArray:[self.visibleViews allValues]];
    [self.visibleViews removeAllObjects];
}

- (void)addView:(UIControl *)view
{
    [self trackTouchedInsideEventForControl:view];
    [self addSubview:view];
}

- (void)removeView:(UIControl *)view
{
    [self untrackTouchedInsideEventForControl:view];
    [view removeFromSuperview];
}

- (UIControl *)viewForIndex:(NSUInteger)index
{
    if (index >= self.pageNumber) {
        return nil;
    }
    UIControl *result;
    if (self.visibleViews.count > 0) {
        result = self.visibleViews[@(index)];
    }
    if (!result) {
        result = [self getViewFromDatasourceForIndex:index reuseView:[self.recyclingViews firstObject]];
        result.autoresizingMask = UIViewAutoresizingNone;
    }
    return result;
}

- (BOOL)isNeededToLoadViews
{
    if (self.visibleViews.count == 0 && self.pageNumber != 0) {
        return YES;
    }
    CGRect visiblePagesUnionRect = [self calculateVisiblePagesUnionRect];
    CGFloat left = CGRectGetMinX(visiblePagesUnionRect);
    CGFloat right = CGRectGetMaxX(visiblePagesUnionRect);
    CGFloat xOffset = self.contentOffset.x;
    CGFloat containerWidth = self.bounds.size.width;
    return left > xOffset || right < xOffset + containerWidth;
}

- (BOOL)isNeededToUnloadViews
{
    CGRect visiblePagesUnionRect = [self calculateVisiblePagesUnionRect];
    CGFloat left = CGRectGetMinX(visiblePagesUnionRect);
    CGFloat right = CGRectGetMaxX(visiblePagesUnionRect);
    CGFloat xOffset = self.contentOffset.x;
    CGFloat containerWidth = self.bounds.size.width;
    CGFloat pageWidth = self.pageSize.width;
    return left + pageWidth < xOffset || right - pageWidth > xOffset + containerWidth;
}

#pragma mark - internal calculation

- (CGPoint)calculateOnePageContentOffsetWithTargetOffset:(CGPoint)offset
{
    if (self.pagingEnabled) {
        CGFloat distance = offset.x - self.contentOffset.x ;
        if (self.contentOffset.x <= 0 || self.contentOffset.x >= self.contentSize.width - self.bounds.size.width) {
            CGFloat x = MIN(self.contentSize.width - self.bounds.size.width,MAX(0,self.contentOffset.x));
            return CGPointMake(x, offset.y);
        }
        NSInteger pageOffset = distance == 0 || self.contentOffset.x < 0 ? -1 : ABS(distance)/distance;
        NSUInteger minPageIndex = [self calculatePageIndexWithOffset:self.contentOffset];
        NSUInteger resultPageIndex = pageOffset < 0 ? minPageIndex : minPageIndex + pageOffset;
        CGFloat calculatedX = [self calculatPageLeftForIndex:resultPageIndex];
        calculatedX = MIN(self.contentSize.width - self.bounds.size.width,MAX(0,calculatedX));
        return CGPointMake(calculatedX, 0);
    }
    return offset;
}

- (void)updatePagingContentOffsetWithOldContentSize:(CGSize)oldSize newContentSize:(CGSize)newSize
{
    if (oldSize.width == 0) {
        return ;
    }
    CGPoint result = CGPointZero;
    if (self.contentOffset.x <= 0) {
        result = CGPointMake(0, self.contentOffset.y);
        [self setContentOffset:CGPointMake(MIN(newSize.width - self.bounds.size.width,MAX(0,result.x)), result.y)];
        return;
    }else if (self.contentOffset.x >= oldSize.width - self.oldBounds.size.width) {
        result = CGPointMake(newSize.width - self.bounds.size.width, self.contentOffset.y);
        [self setContentOffset:CGPointMake(MIN(newSize.width - self.bounds.size.width,MAX(0,result.x)), result.y)];
        return;
    }
    
    if (self.pagingEnabled) {
        result = [self calculatePageRectForIndex:self.currentPageIndex].origin;
    }else {
        NSUInteger oldIndex = [self calculatePageIndexWithOffset:self.contentOffset pageSize:self.oldPageSize pageMargins:self.oldPageMargins];
        CGFloat oldIndexOffset = [self calculatPageLeftForIndex:oldIndex pageSize:self.oldPageSize pageMargins:self.oldPageMargins];
        CGFloat contentOffsetOffset = self.contentOffset.x - oldIndexOffset;
        CGFloat rateInSize = MIN(MAX(contentOffsetOffset / self.oldPageSize.width,0),1.);
        CGFloat oldIndexMargin = [self calculatePageRightMarginForIndex:oldIndex pageSize:self.oldPageSize pageMargins:self.oldPageMargins];
        CGFloat rateInMargin = MAX((contentOffsetOffset - self.oldPageSize.width) / oldIndexMargin,0);
        CGFloat newIndexOffset = [self calculatPageLeftForIndex:oldIndex];
        CGFloat newIndexMargin = [self calculatePageRightMarginForIndex:oldIndex];
        CGFloat newOffsetX = newIndexOffset + self.pageSize.width * rateInSize + newIndexMargin * rateInMargin;
        result = CGPointMake(newOffsetX, self.contentOffset.y);
    }
    [self setContentOffset:CGPointMake(MIN(newSize.width - self.bounds.size.width,MAX(0,result.x)), result.y)];
}

- (NSUInteger)calculatePageIndexWithOffset:(CGPoint)offset pageSize:(CGSize)pageSize pageMargins:(NSDictionary *)margins
{
    if (offset.x < 0 || self.pageNumber <= 1) {
        return 0;
    }
    NSUInteger i = 0;
    CGFloat leftEdgeX = 0,rightEdgeX = [self calculatPageLeftForIndex:1 pageSize:pageSize pageMargins:margins];
    while (!(offset.x >= leftEdgeX && offset.x < rightEdgeX) && i <= self.pageNumber - 1) {
        leftEdgeX = [self calculatPageLeftForIndex:i pageSize:pageSize pageMargins:margins];
        if (i == self.pageNumber - 1) {
            rightEdgeX = self.contentSize.width;
        }else {
            rightEdgeX = [self calculatPageLeftForIndex:i + 1 pageSize:pageSize pageMargins:margins];
        }
        i += 1;
    }
    return i == 0 ? 0 : i - 1;
}

- (CGFloat)calculatePageLeftMarginForIndex:(NSUInteger)index pageSize:(CGSize)pageSize pageMargins:(NSDictionary *)margins
{
    CGSize margin = [margins[@(index)] CGSizeValue];
    if (index == 0) {
        return margin.width;
    }else {
        CGSize leftPageMargin = [margins[@(index - 1)] CGSizeValue];
        return margin.width + leftPageMargin.height;
    }
}

- (CGFloat)calculatePageRightMarginForIndex:(NSUInteger)index pageSize:(CGSize)pageSize pageMargins:(NSDictionary *)margins
{
    if (index >= self.pageNumber) {
        return 0;
    }
    CGSize margin = [margins[@(index)] CGSizeValue];
    if (index == self.pageNumber - 1) {
        return margin.height;
    }else {
        CGSize rightPageMargin = [margins[@(index + 1)] CGSizeValue];
        return margin.height + rightPageMargin.width;
    }
}

- (CGRect)calculatePageRectForIndex:(NSUInteger)index pageSize:(CGSize)pageSize pageMargins:(NSDictionary *)margins
{
    CGFloat pageWidth = pageSize.width;
    CGFloat pageHeight = pageSize.height;
    CGFloat pageUnionWidth = index * pageWidth;//左侧所有page的宽度之和
    CGFloat unionMargin = 0;
    for (int i = 0; i <= index; i++) {
        unionMargin += [self calculatePageLeftMarginForIndex:i pageSize:pageSize pageMargins:margins];//左侧所有margin之和
    }
    CGRect pageRect = CGRectMake(pageUnionWidth + unionMargin, 0, pageWidth, pageHeight);
    return pageRect;
}

- (CGFloat)calculatPageLeftForIndex:(NSUInteger)index pageSize:(CGSize)pageSize pageMargins:(NSDictionary *)margins
{
    CGRect pageRect = [self calculatePageRectForIndex:index pageSize:pageSize pageMargins:margins];
    return CGRectGetMinX(pageRect);
}

- (CGFloat)calculatPageRightForIndex:(NSUInteger)index pageSize:(CGSize)pageSize pageMargins:(NSDictionary *)margins
{
    CGRect pageRect = [self calculatePageRectForIndex:index pageSize:pageSize pageMargins:margins];
    return CGRectGetMaxX(pageRect);
}

- (CGRect)calculateVisiblePagesUnionRectWithPageSize:(CGSize)pageSize pageMargins:(NSDictionary *)margins
{
    if (self.visibleViews.count == 0) {
        return CGRectZero;
    }
    NSArray *sortedKeys = [self.visibleViews.allKeys sortedArrayUsingSelector:@selector(compare:)];
    NSNumber *minIndex = [sortedKeys firstObject];
    CGRect visiblePagesUnionRect = [self calculatePageRectForIndex:minIndex.unsignedIntegerValue pageSize:pageSize pageMargins:margins];
    if (self.visibleViews.count == 1) {
        return visiblePagesUnionRect;
    }else {
        for (int i = minIndex.intValue + 1; i < minIndex.intValue + self.visibleViews.count; i++) {
            CGRect pageRect = [self calculatePageRectForIndex:i pageSize:pageSize pageMargins:margins];
            visiblePagesUnionRect = CGRectUnion(visiblePagesUnionRect, pageRect);
        }
    }
    return visiblePagesUnionRect;
}

- (CGRect)calculateVisiblePagesUnionRectWithMarginsWithPageSize:(CGSize)pageSize pageMargins:(NSDictionary *)margins
{
    if (self.visibleViews.count == 0) {
        return CGRectZero;
    }
    NSArray *sortedKeys = [self.visibleViews.allKeys sortedArrayUsingSelector:@selector(compare:)];
    NSNumber *minIndex = [sortedKeys firstObject];
    NSNumber *maxIndex = [sortedKeys lastObject];
    CGFloat marginLeft = [self calculatePageLeftMarginForIndex:minIndex.unsignedIntegerValue pageSize:pageSize pageMargins:margins],marginRight = [self calculatePageRightMarginForIndex:minIndex.unsignedIntegerValue pageSize:pageSize pageMargins:margins];
    CGRect visiblePagesUnionRect = [self calculatePageRectForIndex:minIndex.unsignedIntegerValue pageSize:pageSize pageMargins:margins];
    if (self.visibleViews.count > 1) {
        for (int i = minIndex.intValue + 1; i <= maxIndex.intValue; i++) {
            CGRect pageRect = [self calculatePageRectForIndex:i pageSize:pageSize pageMargins:margins];
            visiblePagesUnionRect = CGRectUnion(visiblePagesUnionRect, pageRect);
        }
    }
    visiblePagesUnionRect = CGRectMake(visiblePagesUnionRect.origin.x - marginLeft,visiblePagesUnionRect.origin.y,visiblePagesUnionRect.size.width + marginLeft + marginRight,visiblePagesUnionRect.size.height);
    return visiblePagesUnionRect;
}

- (CGSize)calculateContentSizeWithPageSize:(CGSize)pageSize pageMargins:(NSDictionary *)margins
{
    CGFloat allPageWidth = self.pageNumber * pageSize.width;
    __block CGFloat allMargin = 0;
    [margins enumerateKeysAndObjectsUsingBlock:^(id key, NSValue *obj, BOOL *stop) {
        CGSize margin = [obj CGSizeValue];
        allMargin += margin.width + margin.height;
    }];
    return CGSizeMake(allPageWidth + allMargin, pageSize.height);
}

- (NSUInteger)calculatePageIndexWithOffset:(CGPoint)offset
{
    return [self calculatePageIndexWithOffset:offset pageSize:self.pageSize pageMargins:self.pageMargins];
}
- (CGRect)calculatePageRectForIndex:(NSUInteger)index
{
    return [self calculatePageRectForIndex:index pageSize:self.pageSize pageMargins:self.pageMargins];
}
- (CGFloat)calculatPageLeftForIndex:(NSUInteger)index
{
    return [self calculatPageLeftForIndex:index pageSize:self.pageSize pageMargins:self.pageMargins];
}
- (CGFloat)calculatPageRightForIndex:(NSUInteger)index
{
    return [self calculatPageRightForIndex:index pageSize:self.pageSize pageMargins:self.pageMargins];
}
- (CGRect)calculateVisiblePagesUnionRect
{
    return [self calculateVisiblePagesUnionRectWithPageSize:self.pageSize pageMargins:self.pageMargins];
}
- (CGRect)calculateVisiblePagesUnionRectWithMargins
{
    return [self calculateVisiblePagesUnionRectWithMarginsWithPageSize:self.pageSize pageMargins:self.pageMargins];
}
- (CGSize)calculateContentSize
{
    return [self calculateContentSizeWithPageSize:self.pageSize pageMargins:self.pageMargins];
}
- (CGFloat)calculatePageLeftMarginForIndex:(NSUInteger)index
{
    return [self calculatePageLeftMarginForIndex:index pageSize:self.pageSize pageMargins:self.pageMargins];
}
- (CGFloat)calculatePageRightMarginForIndex:(NSUInteger)index
{
    return [self calculatePageRightMarginForIndex:index pageSize:self.pageSize pageMargins:self.pageMargins];
}

#pragma mark - get data from datasource

- (NSUInteger)getPageNumberFromDatasource
{
    if (self.pageNumberBlock) {
        return self.pageNumberBlock(self);
    }
    return 0;
}

- (CGSize)getPageSizeFromDatasource
{
    if (self.pageSizeBlock) {
        CGSize pageSize = self.pageSizeBlock(self);
        return CGSizeMake(lroundf(pageSize.width), lroundf(pageSize.height));
    }
    return CGSizeZero;
}

- (CGRect)getPageViewFrameFromDatasourceForIndex:(NSUInteger)index
{
    if (self.pageViewFrameBlock) {
        return self.pageViewFrameBlock(self,index,CGRectMake(0, 0, self.pageSize.width, self.pageSize.height));
    }else {
        return CGRectMake(0, 0, self.pageSize.width, self.pageSize.height);
    }
    return CGRectZero;
}

- (UIControl *)getViewFromDatasourceForIndex:(NSUInteger)index reuseView:(UIControl *)reuseView
{
    if (self.pageViewBlock) {
        return self.pageViewBlock(self,index,reuseView);
    }
    return nil;
}

- (CGSize)getPageMarginFromDatasourceForIndex:(NSUInteger)index
{
    if (self.pageMarginBlock) {
        PWMargin margin = self.pageMarginBlock(self,index);
        return CGSizeMake(lroundf(margin.left), lroundf(margin.right));
    }
    return CGSizeZero;
}

#pragma mark - track control interaction
- (void)trackTouchedInsideEventForControl:(UIControl *)view
{
    [self untrackTouchedInsideEventForControl:view];
    [view addTarget:self action:@selector(touchInsideOfControl:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)untrackTouchedInsideEventForControl:(UIControl *)view
{
    [view removeTarget:self action:@selector(touchInsideOfControl:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)touchInsideOfControl:(UIControl *)view
{
    [self deselectAllPagesExceptForView:view];
    [self selectControl:view];
}
- (void)selectControl:(UIControl *)view
{
    NSArray *keys = [self.visibleViews allKeysForObject:view];
    if (keys.count > 0) {
        view.selected = YES;
        NSNumber *indexNumber = [keys firstObject];
        NSUInteger index = [indexNumber unsignedIntegerValue];
        [self notifyPageSelectedWithIndex:index];
    }
}
- (void)notifyPageSelectedWithIndex:(NSUInteger)index {
    if (self.notifyPageSelectedBlock) {
        self.notifyPageSelectedBlock(self,index);
    }
}

#pragma mark - public API
- (void)reloadData
{
    [self unloadAllViews];
    [self updatePageNumber];
    [self updateContentSize];
    [self loadVisibleViews];
}

- (void)scrollPageToVisible:(NSUInteger)pageIndex animated:(BOOL)animated
{
    if (pageIndex >= self.pageNumber) {
        return;
    }
    CGRect frame = [self calculatePageRectForIndex:pageIndex];
    [self scrollRectToVisible:frame animated:animated];
}

- (void)deselectAllPages
{
    [self.visibleViews enumerateKeysAndObjectsUsingBlock:^(id key, UIControl *obj, BOOL *stop) {
        if (obj.isSelected) {
            obj.selected = NO;
        }
    }];
}

- (void)deselectAllPagesExceptForIndex:(NSUInteger)index
{
    [self.visibleViews enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, UIControl *obj, BOOL *stop) {
        if (index != key.unsignedIntegerValue && obj.isSelected) {
            obj.selected = NO;
        }
    }];
}

- (void)deselectAllPagesExceptForView:(UIControl *)view
{
    [self.visibleViews enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, UIControl *obj, BOOL *stop) {
        if (![view isEqual:obj] && obj.isSelected) {
            obj.selected = NO;
        }
    }];
}

@end
