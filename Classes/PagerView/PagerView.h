//
//  PagerView.h
//  recipeHD
//
//  Created by 徐 东 on 14-3-6.
//  Copyright (c) 2014年 RuidiInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>

struct PWMargin {
    CGFloat left;
    CGFloat right;
};
typedef struct PWMargin PWMargin;

static inline PWMargin PWMarginMake(CGFloat left, CGFloat right)
{
    PWMargin margin;
    margin.left = left;
    margin.right = right;
    return margin;
}

/**
 * 该类用于实现横向Pager效果
 *相对于UIScrollView有以下优点
 *   1 可以指定PageSize
 *   2 可以像TableView一样重用cell
 *相对于SwipeView有以下优点
 *   1 可以兼容autoLayout
 *   2 滚动动画没做任何trick，完全使用UIScrollViewDelegate实现，性能和效果都更好
 * 并且该类数据接口都由block实现
 */
@interface PagerView : UIScrollView

/**
 * 当前正在展示的Page位置索引，当Paging为NO时，该值没有意义。
 * 该值变化时会调用  notifyPageIndexChangedBlock
 **/
@property (assign,nonatomic,readonly) NSUInteger currentPageIndex;
/**
 * page数量，每次 reloadData由 getPageNumberBlock获取一次
 **/
@property (assign,nonatomic,readonly) NSUInteger pageNumber;
/**
 * page尺寸，每次 reloadData由 getPageSizeBlock获取的值计算一次
 @note 该值不一定和 getPageSizeBlock中返回的值相同，因为该值会被重新计算一次以取得 getPageSizeBlock中返回的值最近的整数值
 **/
@property (assign,nonatomic,readonly) CGSize pageSize;
/**
 * 当当前page索引变化时调用的block
 **/
@property (copy,nonatomic) void(^notifyPageIndexChangedBlock)(PagerView *pager, NSUInteger index);
/**
 * 当page被选中时调用的block
 **/
@property (copy,nonatomic) void(^notifyPageSelectedBlock)(PagerView *pager, NSUInteger index);
/**
 * 当PagerView需要获得page数量时调用的block
 **/
@property (copy,nonatomic) NSUInteger(^pageNumberBlock)(PagerView *pager);
/**
 * 当PagerView需要获得page尺寸时调用的block
 **/
@property (copy,nonatomic) CGSize(^pageSizeBlock)(PagerView *pager);
/**
 * 当PagerView需要page间距时调用的block
 **/
@property (copy,nonatomic) PWMargin(^pageMarginBlock)(PagerView *pager,NSUInteger index);
/**
 * 当PagerView布局子View时调用的block，该block应该返回index对应的view在其page坐标系中的frame，而非PagerView坐标系
 **/
@property (copy,nonatomic) CGRect(^pageViewFrameBlock)(PagerView *pager,NSUInteger index,CGRect pageBounds);
/**
 * 当PagerView加载一个view进可视区域时调用的block
 **/
@property (copy,nonatomic) UIControl *(^pageViewBlock)(PagerView *pager,NSUInteger index,UIControl *reuseView);

//follow setters are tricky,see http://stackoverflow.com/questions/18486209/how-to-get-the-correct-autocomplete-in-xcode-for-a-block-variable
- (void)setNotifyPageIndexChangedBlock:(void (^)(PagerView *pager, NSUInteger index))notifyPageIndexChangedBlock;
- (void)setNotifyPageSelectedBlock:(void (^)(PagerView *pager, NSUInteger index))notifyPageSelectedBlock;
- (void)setPageNumberBlock:(NSUInteger (^)(PagerView *pager))getPageNumberBlock;
- (void)setPageSizeBlock:(CGSize (^)(PagerView *pager))getPageSizeBlock;
- (void)setPageMarginBlock:(PWMargin (^)(PagerView *pager,NSUInteger index))pageMarginBlock;
- (void)setPageViewFrameBlock:(CGRect (^)(PagerView *pager,NSUInteger index,CGRect pageBounds))getPageViewFrameBlock;
- (void)setPageViewBlock:(UIControl *(^)(PagerView *view, NSUInteger index, UIControl *reuseView))getPageViewBlock;

- (void)reloadData;
- (void)scrollPageToVisible:(NSUInteger)pageIndex animated:(BOOL)animated;
- (void)deselectAllPages;
- (void)deselectAllPagesExceptForIndex:(NSUInteger)index;
- (void)deselectAllPagesExceptForView:(UIControl *)view;

@end
