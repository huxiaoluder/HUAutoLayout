//
//  HUAutoLayout.h
//  HUAutoLayoutDemo
//
//  Created by 胡校明 on 16/3/28.
//  Copyright © 2016年 HU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

///  九宫格布局方式
typedef NS_ENUM(NSUInteger, HUAutoLayoutSquareType) {
    ///  限定范围内固定布局
    HUSquareFlowLayoutInFixedRect,
    ///  垂直方向上流水布局
    HUSquareFlowLayoutInVertical,
    ///  水平方向上流水布局
    HUSquareFlowLayoutInHorizontal,
};

///  瀑布流布局方式
typedef NS_ENUM(NSUInteger, HUAutoLayoutWaterfallType) {
    ///  垂直方向上流水布局
    HUWaterfallFlowLayoutInVertical,
    ///  水平方向上流水布局
    HUWaterfallFlowLayoutInHorizontal,
};

///  HUAutoLayout 回调block类型
typedef void (^HUAutoLayoutHandleBlock)(CGRect frame, NSInteger index, NSError *error);

///  瀑布流布局代理
@protocol HUAutoLayoutWaterfallDelegate <NSObject>

@optional

///  垂直布局,返回每个item的高度
///  @param itemWith item宽度
///  @param index    脚标
- (CGFloat)layoutForItemHeight:(CGFloat)itemWith index:(NSUInteger)index;

///  水平布局,返回每个item的宽度
///  @param itemHeight item高度
///  @param index      脚标
- (CGFloat)layoutForItemWidth:(CGFloat)itemHeight index:(NSUInteger)index;

@end

@interface HUAutoLayout : NSObject

@property ( nonatomic, assign) NSUInteger culomn;               //!< 属性描述: 列数   
@property ( nonatomic, assign) NSUInteger line;                 //!< 属性描述: 行数
//@property ( nonatomic, assign) CGFloat contentInsetTop;         //!< 属性描述: 上边距
//@property ( nonatomic, assign) CGFloat contentInsetLeft;        //!< 属性描述: 左边距
//@property ( nonatomic, assign) CGFloat contentInsetBottom;      //!< 属性描述: 下边距
//@property ( nonatomic, assign) CGFloat contentInsetRight;       //!< 属性描述: 右边距
@property ( nonatomic, assign) UIEdgeInsets contentInset;       //! <属性描述: 内边距
@property ( nonatomic, assign) CGFloat minimumInteritemSpacing; //!< 属性描述: 列间距
@property ( nonatomic, assign) CGFloat minimumLineSpacing;      //!< 属性描述: 行间距
@property ( nonatomic, assign) CGSize itemSize;                 //!< 属性描述: 尺寸
//@property ( nonatomic, assign) CGFloat itemWidth;               //!< 属性描述: 单个方格的宽
//@property ( nonatomic, assign) CGFloat itemHeight;              //!< 属性描述: 单个方格的高

///属性描述: 瀑布流布局代理
@property ( nonatomic, weak) id<HUAutoLayoutWaterfallDelegate> waterfallDelegate;

///  实例化自动布局对象(单例)
///  @param layoutCount 布局控件的数量
///  @return 返回布局对象
+ (instancetype) sharedLayout;

///  自动布局九宫格
///  @param targetView  父控件视图
///  @param layoutCount 需要布局的控件总数
///  @param options     布局方式
///  @param handleBlock 回调block
- (void) hu_layoutSquare:(UIView *)targetView layoutCount:(NSInteger)count layoutType:(HUAutoLayoutSquareType)type handleBlock:(HUAutoLayoutHandleBlock)handleBlock;

///  自动布局瀑布流
///  @param targetView  父控件视图
///  @param scales      需要布局的控件的宽高比数组(元素为宽比高)
///  @param options     布局方式
///  @param handleBlock 回调block
- (void) hu_layoutWaterfall:(UIView *)targetView layoutCount:(NSInteger)count layoutType:(HUAutoLayoutWaterfallType)type handleBlock:(HUAutoLayoutHandleBlock)handleBlock;

@end
