//
//  HUAutoLayout.m
//  HUAutoLayoutDemo
//
//  Created by 胡校明 on 16/3/28.
//  Copyright © 2016年 HU. All rights reserved.
//

#import "HUAutoLayout.h"

///  获取数据个数的情况
typedef NS_ENUM(NSUInteger, HUAutoLayoutAchivedCount) {
    ///  情况一: 给定一个数据
    HUAutoLayoutAchivedOneCount = 1,
    ///  情况二: 给定两个数据
    HUAutoLayoutAchivedTwoCount,
    ///  情况三: 给定三个数据
    HUAutoLayoutAchivedThreeCount,
    ///  情况四: 给定四个数据
    HUAutoLayoutAchivedFourCount,
};

@interface HUAutoLayout ()

@property ( nonatomic, assign) NSUInteger layoutCount;          //!< 属性描述: 布局个数
@property ( nonatomic, assign) CGFloat imumInteritemSpacing;    //!<属性描述: 列间距
@property ( nonatomic, assign) CGFloat imumLineSpacing;         //!<属性描述: 行间距
@property ( nonatomic, assign) CGFloat superViewWidth;          //!<属性描述: 父控件宽度
@property ( nonatomic, assign) CGFloat superViewHeight;         //!<属性描述: 父控件高度
@property ( nonatomic, assign, readonly) CGFloat maxWidth;      //!<属性描述: 最大宽度
@property ( nonatomic, assign, readonly) CGFloat maxHeight;     //!<属性描述: 最大高度

@end

@implementation HUAutoLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        _line = 0;
        _culomn = 0;
        _minimumLineSpacing = 0;
        _minimumInteritemSpacing = 0;
        _itemSize = CGSizeMake(0, 0);
        _contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}

#pragma mark - 创建单例对象,并初始化实例变量
+ (instancetype)sharedLayout {
    static HUAutoLayout *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}


#pragma mark - 九宫格布局
- (void)hu_layoutSquare:(UIView *)targetView layoutCount:(NSInteger)count layoutType:(HUAutoLayoutSquareType)type handleBlock:(HUAutoLayoutHandleBlock)handleBlock {
    
    if (count == 0) {
        handleBlock(CGRectZero, 0, [NSError errorWithDomain:@"https://github.com/huxiaoluder" code:4000 userInfo:@{@"layoutError" : @"排版数量为0, 无意义!"}]);
        [self reSetLayout];
        return;
    }
    
    _layoutCount = count;
    _imumLineSpacing = _minimumLineSpacing;
    _imumInteritemSpacing = _minimumInteritemSpacing;
    _superViewWidth = targetView.frame.size.width;
    _superViewHeight = targetView.frame.size.height;
    
    CGFloat contentWidth = 0;
    CGFloat contentHeight = 0;
    
    // 布局方式判断
    switch (type) {
        case HUSquareFlowLayoutInVertical:
            contentHeight = [self squareInVerticalPrepareForLayout:handleBlock];
            break;
        case HUSquareFlowLayoutInHorizontal:
            contentWidth = [self squareInHorizontalPrepareForLayout:handleBlock];
            break;
        case HUSquareFlowLayoutInFixedRect:
            [self squareInFixedRectPrepareForLayout:handleBlock];
            break;
        default:
            break;
    }
    
    if ([targetView isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)targetView;
        scrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
    }
    
    [self reSetLayout];
}

#pragma mark - 九宫格布局条件准备
///  九宫格垂直方向上流水布局条件准备
- (CGFloat)squareInVerticalPrepareForLayout:(HUAutoLayoutHandleBlock)handleBlock {
    
    // 宽度越界判断
    if (self.maxWidth > _superViewWidth) {
        
        handleBlock(CGRectZero, 0, [NSError errorWithDomain:@"https://github.com/huxiaoluder" code:4000 userInfo:@{@"layoutError" : @" 排版宽度相对屏幕宽度越界,请检查数据安全性,重新赋值!"}]);
        
        [self reSetLayout];
        
        return 0;
    }
    
    // 数据漏缺判断
    if ((_culomn == 0 && _itemSize.width == 0) || _itemSize.height == 0) {
        
        handleBlock(CGRectZero, 0, [NSError errorWithDomain:@"https://github.com/huxiaoluder" code:4000 userInfo:@{@"layoutError" : @" 垂直方向上流水布局,必须设定 itemHeight, \nculomn 和 itemWidth 至少一个需给定数据!"}]);
        
        [self reSetLayout];
        
        return 0;
    }
    
    // 计算布局所需的必要数据
    if (_culomn == 0) {
        
        _culomn = [self calculateCulomnByItemWidth];
        
    } else if (_itemSize.width == 0) {
        
        _itemSize.width = [self calculateItemWidthByCulomn];
        
    }
        
    do {
        _imumInteritemSpacing = [self calculateImumInteritemSpacing];
        
        if (_imumInteritemSpacing < _minimumInteritemSpacing) {
            
            _culomn -= 1;
            
        } else {
            
            break;
        }
    } while (_imumInteritemSpacing >= _minimumInteritemSpacing);
    
    return [self squareFlowLayoutInVertical:handleBlock];
}

///  九宫格水平方向上流水布局条件准备
- (CGFloat)squareInHorizontalPrepareForLayout:(HUAutoLayoutHandleBlock)handleBlock {

    // 高度越界判断
    if (self.maxHeight > _superViewHeight) {
        
        handleBlock(CGRectZero, 0, [NSError errorWithDomain:@"https://github.com/huxiaoluder" code:4000 userInfo:@{@"layoutError" : @" 排版高度相对屏幕高度越界,请检查数据安全性,重新赋值!"}]);
        
        [self reSetLayout];
        
        return 0;
    }
    
    // 数据漏缺判断
    if ((_line == 0 && _itemSize.height == 0) || _itemSize.width == 0) {
        
        handleBlock(CGRectZero, 0, [NSError errorWithDomain:@"https://github.com/huxiaoluder" code:4000 userInfo:@{@"layoutError" : @" 水平方向上流水布局,必须设定 itemWidth, \nline 和 itemHeight 至少一个需给定数据!"}]);

        [self reSetLayout];
        
        return 0;
    }

    // 计算布局所需的必要数据
    if (_line == 0) {
        
        _line = [self calculateLineByItemHeight];
        
    } else if (_itemSize.height == 0) {

        _itemSize.height = [self calculateItemHeightByLine];
        
    }
        
    do {
        _imumLineSpacing = [self calculateImumLineSpacing];
        
        if (_imumLineSpacing < _minimumLineSpacing) {
            
            _line -= 1;
            
        } else {
            
            break;
        }
    } while (_imumLineSpacing >= _minimumLineSpacing);
    
    return [self squareFlowLayoutInHorizontal:handleBlock];
}

///  九宫格限定范围内固定布局条件准备
- (void)squareInFixedRectPrepareForLayout:(HUAutoLayoutHandleBlock)handleBlock{
    
    // 尺寸(size)越界判断
    if (self.maxWidth > _superViewWidth || self.maxHeight > _superViewHeight) {
        
        handleBlock(CGRectZero, 0, [NSError errorWithDomain:@"https://github.com/huxiaoluder" code:4000 userInfo:@{@"layoutError" : @" 排版尺寸相对屏幕宽度尺寸,请检查数据安全性,重新赋值!"}]);
        
        [self reSetLayout];
        
        return;
    }
    
    // 数据漏缺判断
    NSArray * array = @[@(_line),@(_culomn),@(_itemSize.width),@(_itemSize.height)];
    
    __block int count = 0;
    
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj doubleValue] != 0) {
            
            count++;
        }
    }];
    
    if (count == 0) {
        
        handleBlock(CGRectZero, 0, [NSError errorWithDomain:@"https://github.com/huxiaoluder" code:4000 userInfo:@{@"layoutError" : @"限定范围内固定布局,必须设定 line, culomn, itemWidth, itemHeight 至少一个需给定数据!"}]);
        
        [self reSetLayout];
        
        return;
    }
    
    // 行,列数 与 排版总数 冲突判断
    if (_line != 0 && _culomn != 0 && _line * _culomn < _layoutCount) {
        
        handleBlock(CGRectZero, 0, [NSError errorWithDomain:@"https://github.com/huxiaoluder" code:4000 userInfo:@{@"layoutError" : @"限定范围内固定布局,必须设定 line, culomn 的乘积不能小于 layoutCount"}]);
        
        [self reSetLayout];
        
        return;
    }
    
    // 计算布局所需的必要数据
    
    ///  判断获取数据的情况
    switch (count) {
            
        case HUAutoLayoutAchivedOneCount: [self oneCountJudged]; break;
        
        case HUAutoLayoutAchivedTwoCount: [self twoCountJudged]; break;
        
        case HUAutoLayoutAchivedThreeCount: [self threeCountJudged]; break;
        
        case HUAutoLayoutAchivedFourCount: [self fourCountJudged]; break;
        
        default: break;
    }
    
    // 尺寸(size)越界判断
    if ((self.maxWidth > _superViewWidth || self.maxHeight > _superViewHeight) && _layoutCount >= _culomn) {
        
        handleBlock(CGRectZero, 0, [NSError errorWithDomain:@"https://github.com/huxiaoluder" code:4000 userInfo:@{@"layoutError" : @"限定范围内固定布局,根据给定数据计算出的布局数据超出限定范围,请给定具有合理性的数据"}]);
        
        [self reSetLayout];
        
        return;
    }
    
    [self squareFlowLayoutInFixedRect:handleBlock];
}


#pragma mark - 九宫格固定布局条件判断
///  情况一
- (void)oneCountJudged {
    
    if (_line != 0) {
        
        _itemSize.height = [self calculateItemHeightByLine];
        _culomn = [self calculateCulomnByLayoutCount];
        _itemSize.width = [self calculateItemWidthByCulomn];
        
    } else if (_culomn != 0) {
        
        _itemSize.width = [self calculateItemWidthByCulomn];
        _line = [self calculateLineByLayoutCount];
        _itemSize.height = [self calculateItemHeightByLine];
        
    } else if (_itemSize.width != 0) {
        
        _culomn = [self calculateCulomnByItemWidth];
        _imumInteritemSpacing = [self calculateImumInteritemSpacing];
        _line = [self calculateLineByLayoutCount];
        _itemSize.height = [self calculateItemHeightByLine];
        
    } else if (_itemSize.height != 0) {
        
        _line = [self calculateLineByItemHeight];
        _imumLineSpacing = [self calculateImumLineSpacing];
        _culomn = [self calculateCulomnByLayoutCount];
        _itemSize.width = [self calculateItemWidthByCulomn];
        _line = [self calculateLineByLayoutCount];
        _imumLineSpacing = [self calculateImumLineSpacing];
    }
}

///  情况二
- (void)twoCountJudged {
    
    if (_line != 0 && _culomn != 0) {
        
        _itemSize.width = [self calculateItemWidthByCulomn];
        _line = [self calculateLineByLayoutCount];
        _itemSize.height = [self calculateItemHeightByLine];
        
    } else if (_line != 0 && _itemSize.width != 0) {
        
        _itemSize.height = [self calculateItemHeightByLine];
        _culomn = [self calculateCulomnByLayoutCount];
        _imumInteritemSpacing = [self calculateImumInteritemSpacing];
        
    } else if (_line != 0 && _itemSize.height != 0) {
        
        _imumLineSpacing = [self calculateImumLineSpacing];
        _culomn = [self calculateCulomnByLayoutCount];
        _itemSize.width = [self calculateItemWidthByCulomn];
    } else if (_culomn != 0 && _itemSize.width != 0) {
        
        _imumInteritemSpacing = [self calculateImumInteritemSpacing];
        _line = [self calculateLineByLayoutCount];
        _itemSize.height = [self calculateItemHeightByLine];
        
    } else if (_culomn != 0 && _itemSize.height != 0) {
        
        _itemSize.width = [self calculateItemWidthByCulomn];
        _line = [self calculateLineByLayoutCount];
        _imumLineSpacing = [self calculateImumLineSpacing];
        
    } else if (_itemSize.width != 0 && _itemSize.height != 0) {
        
        _culomn = [self calculateCulomnByItemWidth];
        _line = [self calculateLineByLayoutCount];
        _imumInteritemSpacing = [self calculateImumInteritemSpacing];
        _imumLineSpacing = [self calculateImumLineSpacing];
    }
}

///  情况三
- (void)threeCountJudged {
 
    if (_line == 0) {
        
        _line = [self calculateLineByLayoutCount];
        _imumInteritemSpacing = [self calculateImumInteritemSpacing];
        _imumLineSpacing = [self calculateImumLineSpacing];
        
    } else if (_culomn == 0) {
        
        _culomn = [self calculateCulomnByLayoutCount];
        _imumInteritemSpacing = [self calculateImumInteritemSpacing];
        _imumLineSpacing = [self calculateImumLineSpacing];
        
    } else if (_itemSize.width == 0) {
        
        _itemSize.width = [self calculateItemWidthByCulomn];
        _imumLineSpacing = [self calculateImumLineSpacing];
        
    } else if (_itemSize.height == 0) {
        
        _itemSize.height = [self calculateItemHeightByLine];
        _imumInteritemSpacing = [self calculateImumInteritemSpacing];
    }
}

///  情况四
- (void)fourCountJudged {
    
    _imumInteritemSpacing = [self calculateImumInteritemSpacing];
    _imumLineSpacing = [self calculateImumLineSpacing];
}


#pragma mark - 九宫格开始布局
///  九宫格垂直方向上流水布局
- (CGFloat)squareFlowLayoutInVertical:(HUAutoLayoutHandleBlock)handleBlock {
    
    CGRect frame = CGRectZero;
    
    for (int i = 0; i < _layoutCount; i++) {
        
        frame.origin.x = (_itemSize.width + _imumInteritemSpacing) * (i % _culomn) + _contentInset.left;
        
        frame.origin.y = (_itemSize.height + _imumLineSpacing) * (i / _culomn) + _contentInset.top;
        
        frame.size.width = _itemSize.width;
        
        frame.size.height = _itemSize.height;
        
        handleBlock(frame, i, nil);
    }
    
    return CGRectGetMaxY(frame) + _contentInset.bottom;
}

///  九宫格水平方向上流水布局
- (CGFloat)squareFlowLayoutInHorizontal:(HUAutoLayoutHandleBlock)handleBlock {

    CGRect frame = CGRectZero;
    
    for (int i = 0; i < _layoutCount; i++) {
        
        frame.origin.x = (_itemSize.width + _imumInteritemSpacing) * (i / _line) + _contentInset.left;
        
        frame.origin.y = (_itemSize.height + _imumLineSpacing) * (i % _line) + _contentInset.top;
        
        frame.size.width = _itemSize.width;
        
        frame.size.height = _itemSize.height;
        
        handleBlock(frame, i, nil);
    }
    
    return CGRectGetMaxX(frame) + _contentInset.right;
}

///  九宫格限定范围内固定布局
- (void)squareFlowLayoutInFixedRect:(HUAutoLayoutHandleBlock)handleBlock {
    
    BOOL isReasonable = NO;
    isReasonable = _line == 1 ? _imumLineSpacing == 0 : _imumLineSpacing >= _minimumLineSpacing;
    isReasonable = isReasonable && (_culomn == 1 ? _imumInteritemSpacing == 0 : _imumInteritemSpacing >= _minimumInteritemSpacing);
    isReasonable = isReasonable && (_line * _culomn >= _layoutCount);
    
    // 数据合理性判断
    if (isReasonable) {
        
        [self squareFlowLayoutInVertical:handleBlock];
        
    } else {
        
        handleBlock(CGRectZero, 0, [NSError errorWithDomain:@"https://github.com/huxiaoluder" code:4000 userInfo:@{@"layoutError" : @"限定范围内固定布局,根据给定数据计算出的布局出现重合的想象,请给定具有合理性的数据"}]);
        
        [self reSetLayout];
        
        return;
    }
}


#pragma mark - 属性公式算法
///  通过总数和行数,求列数
- (NSInteger)calculateCulomnByLayoutCount {
    NSInteger culomn = (_layoutCount / _line);
    return _layoutCount % _line > 0 ? ++culomn : culomn;
}
///  通过宽度,求列数
- (NSInteger)calculateCulomnByItemWidth {
    return (_superViewWidth - _contentInset.left - _contentInset.right + _imumInteritemSpacing) / (_itemSize.width + _imumInteritemSpacing);
}
///  通过总数和列数,求行数
- (NSInteger)calculateLineByLayoutCount {
    NSInteger line = (_layoutCount / _culomn);
    return _layoutCount % _culomn > 0 ? ++line : line;
}
///  通过高度,求行数
- (NSInteger)calculateLineByItemHeight {
    return (_superViewHeight - _contentInset.top - _contentInset.bottom + _imumLineSpacing) / (_itemSize.height + _imumLineSpacing);
}
///  通过列数,求宽度
- (CGFloat)calculateItemWidthByCulomn {
    return (_superViewWidth - _contentInset.left - _contentInset.right - _imumInteritemSpacing * (_culomn - 1)) / _culomn;
}
///  通过行数,求高度
- (CGFloat)calculateItemHeightByLine {
    return (_superViewHeight - _contentInset.top - _contentInset.bottom - _imumLineSpacing * (_line - 1)) / _line;
}
///  计算列间距
- (CGFloat)calculateImumInteritemSpacing {
    return (_culomn - 1) > 0 ? (_superViewWidth - _contentInset.left - _contentInset.right - _itemSize.width * _culomn) / (_culomn - 1) : 0;
}
///  计算行间距
- (CGFloat)calculateImumLineSpacing {
    return (_line - 1) > 0 ? (_superViewHeight - _contentInset.top - _contentInset.bottom - _itemSize.height * _line) / (_line - 1) : 0;
}


#pragma mark - 瀑布流布局
- (void)hu_layoutWaterfall:(UIView *)targetView layoutCount:(NSInteger)count layoutType:(HUAutoLayoutWaterfallType)type handleBlock:(HUAutoLayoutHandleBlock)handleBlock {
    
    if (count == 0) {
        handleBlock(CGRectZero, 0, [NSError errorWithDomain:@"https://github.com/huxiaoluder" code:4000 userInfo:@{@"layoutError" : @"排版数量为0, 无意义!"}]);
        [self reSetLayout];
        return;
    }
    
    _layoutCount = count;
    _imumLineSpacing = _minimumLineSpacing;
    _imumInteritemSpacing = _minimumInteritemSpacing;
    _superViewWidth = targetView.frame.size.width;
    _superViewHeight = targetView.frame.size.height;
    
    CGFloat contentWidth = 0;
    CGFloat contentHeight = 0;
    
    // 布局方式判断
    switch (type) {
        case HUWaterfallFlowLayoutInVertical:
            contentHeight = [self waterfallInVerticalPrepareForLayout:handleBlock];
            break;
        case HUWaterfallFlowLayoutInHorizontal:
            contentWidth = [self waterfallInHorizontalPrepareForLayout:handleBlock];
            break;
        default:
            break;
    }
    
    if ([targetView isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)targetView;
        scrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
    }
    
    [self reSetLayout];
}


#pragma mark - 瀑布流布局条件准备
///  瀑布流垂直方向上布局
- (CGFloat)waterfallInVerticalPrepareForLayout:(HUAutoLayoutHandleBlock)handleBlock {
    
    // 宽度越界判断
    if (self.maxWidth > _superViewWidth) {
        
        handleBlock(CGRectZero, 0, [NSError errorWithDomain:@"https://github.com/huxiaoluder" code:4000 userInfo:@{@"layoutError" : @" 排版宽度相对屏幕宽度越界,请检查数据安全性,重新赋值!"}]);
        
        [self reSetLayout];
        
        return 0;
    }
    
    // 数据漏缺判断
    if (_culomn == 0 && _itemSize.width == 0) {
        
        handleBlock(CGRectZero, 0, [NSError errorWithDomain:@"https://github.com/huxiaoluder" code:4000 userInfo:@{@"layoutError" : @" 垂直方向上流水布局,culomn 和 itemWidth 至少设置一个"}]);
        
        [self reSetLayout];
        
        return 0;
    }
    
    // 计算布局所需的必要数据
    if (_culomn == 0) {
        
        _culomn = [self calculateCulomnByItemWidth];
        
    } else if (_itemSize.width == 0) {
        
        _itemSize.width = [self calculateItemWidthByCulomn];
        
    }
    
    do {
        _imumInteritemSpacing = [self calculateImumInteritemSpacing];
        
        if (_imumInteritemSpacing < _minimumInteritemSpacing) {
            
            _culomn -= 1;
            
        } else {
            
            _line = [self calculateLineByLayoutCount];
            
            break;
        }
    } while (_imumInteritemSpacing >= _minimumInteritemSpacing);
    
    // 实例化一个缓存数组, 保存当前最后一行的 数据
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:_culomn];
    
    // 创建一个变量,保存具有最小x值的frame
    __block NSUInteger index = 0;
    
    // 创建变量作为中转
    __block CGRect frame = CGRectZero;
    __block CGRect frameM = CGRectZero;
    
    // 计算第一行的frame
    for (int i = 0; i < _layoutCount; i++) {
        
        // 利用代理动态设置高度
        if (_waterfallDelegate && [_waterfallDelegate respondsToSelector:@selector(layoutForItemHeight:index:)]) {
            _itemSize.height = [_waterfallDelegate layoutForItemHeight:_itemSize.width index:i];
        } else if (_waterfallDelegate) {
            handleBlock(CGRectZero, 0, [NSError errorWithDomain:@"https://github.com/huxiaoluder" code:4000 userInfo:@{@"layoutError" : @"请正确使用代理!"}]);
            [self reSetLayout];
            return 0;
        }
        
        if (i < _culomn) {
            
            frame.origin.x = (_itemSize.width + _imumInteritemSpacing) * (i % _culomn) + _contentInset.left;
            frame.origin.y = _contentInset.top;
            frame.size.width = _itemSize.width;
            frame.size.height = _itemSize.height;
            handleBlock(frame, i, nil);
            [tempArray addObject:[NSValue valueWithCGRect:frame]];
            
        } else {
            
            // 遍历数组得到布局位置
            frameM = [tempArray[index] CGRectValue];
            [tempArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                frame = [obj CGRectValue];
                if (CGRectGetMaxY(frameM) > CGRectGetMaxY(frame)) {
                    frameM = frame;
                    index = idx;
                }
            }];
            
            // 计算frame
            frame.origin.x = frameM.origin.x;
            frame.origin.y = CGRectGetMaxY(frameM) + _imumLineSpacing;
            frame.size.width = _itemSize.width;
            frame.size.height = _itemSize.height;
            handleBlock(frame, i, nil);
            tempArray[index] = [NSValue valueWithCGRect:frame];
        }
    }
    
    [tempArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        frame = [obj CGRectValue];
        if (CGRectGetMaxY(frameM) < CGRectGetMaxY(frame)) {
            frameM = frame;
        }
    }];
    
    return CGRectGetMaxY(frameM) + _contentInset.bottom;
}

///  瀑布流水平方向上布局
- (CGFloat)waterfallInHorizontalPrepareForLayout:(HUAutoLayoutHandleBlock)handleBlock {
    
    // 高度越界判断
    if (self.maxHeight > _superViewHeight) {
        
        handleBlock(CGRectZero, 0, [NSError errorWithDomain:@"https://github.com/huxiaoluder" code:4000 userInfo:@{@"layoutError" : @" 排版高度相对屏幕高度越界,请检查数据安全性,重新赋值!"}]);
        
        [self reSetLayout];
        
        return 0;
    }
    
    // 数据漏缺判断
    if (_line == 0 && _itemSize.height == 0) {
        
        handleBlock(CGRectZero, 0, [NSError errorWithDomain:@"https://github.com/huxiaoluder" code:4000 userInfo:@{@"layoutError" : @" 水平方向上流水布局,line 和 itemHeight 至少一个需给定数据!"}]);
        
        [self reSetLayout];
        
        return 0;
    }
    
    // 计算布局所需的必要数据
    if (_line == 0) {
        
        _line = [self calculateLineByItemHeight];
        
    } else if (_itemSize.height == 0) {
        
        _itemSize.height = [self calculateItemHeightByLine];
        
    }
        
    do {
        _imumLineSpacing = [self calculateImumLineSpacing];
        
        if (_imumLineSpacing < _minimumLineSpacing) {
            
            _line -= 1;
            
        } else {
            
            _culomn = [self calculateCulomnByLayoutCount];
            
            break;
        }
    } while (_imumInteritemSpacing >= _minimumInteritemSpacing);
    
    // 实例化一个缓存数组, 保存当前最后一行的 数据
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:_line];
    
    // 创建一个变量,保存具有最小x值的frame
    __block NSUInteger index = 0;
    
    // 创建变量作为中转
    __block CGRect frame = CGRectZero;
    __block CGRect frameM = CGRectZero;
    
    // 计算第一行的frame
    for (int i = 0; i < _layoutCount; i++) {
        
        // 利用代理动态设置宽度
        if (_waterfallDelegate && [_waterfallDelegate respondsToSelector:@selector(layoutForItemWidth:index:)]) {
            _itemSize.width = [_waterfallDelegate layoutForItemWidth:_itemSize.height index:i];
        } else if (_waterfallDelegate) {
            handleBlock(CGRectZero, 0, [NSError errorWithDomain:@"https://github.com/huxiaoluder" code:4000 userInfo:@{@"layoutError" : @"请正确使用代理!"}]);
            [self reSetLayout];
            return 0;
        }
        
        if (i < _line) {
            
            frame.origin.x = _contentInset.left;
            frame.origin.y = (_itemSize.height + _imumLineSpacing) * (i % _line) + _contentInset.top;
            frame.size.width = _itemSize.width;
            frame.size.height = _itemSize.height;
            handleBlock(frame, i, nil);
            [tempArray addObject:[NSValue valueWithCGRect:frame]];
            
        } else {

            // 遍历数组得到布局位置
            frameM = [tempArray[index] CGRectValue];
            [tempArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                frame = [obj CGRectValue];
                if (CGRectGetMaxX(frameM) > CGRectGetMaxX(frame)) {
                    frameM = frame;
                    index = idx;
                }
            }];
            
            // 计算frame
            frame.origin.x = CGRectGetMaxX(frameM) + _imumInteritemSpacing;
            frame.origin.y = frameM.origin.y;
            frame.size.width = _itemSize.width;
            frame.size.height = _itemSize.height;
            handleBlock(frame, i, nil);
            tempArray[index] = [NSValue valueWithCGRect:frame];
        }
    }
    
    [tempArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        frame = [obj CGRectValue];
        if (CGRectGetMaxX(frameM) < CGRectGetMaxX(frame)) {
            frameM = frame;
        }
    }];
    
    return CGRectGetMaxX(frameM) + _contentInset.right;
}

#pragma mark - 计算型属性
- (CGFloat)maxWidth {
    return _culomn * _itemSize.width + _imumInteritemSpacing * (_culomn - 1) + _contentInset.left + _contentInset.right;
}

- (CGFloat)maxHeight {
    return _line * _itemSize.height + _imumLineSpacing * (_line - 1) + _contentInset.top + _contentInset.bottom;
}

#pragma mark - 重置布局对象
- (void)reSetLayout {
    _line = 0;
    _culomn = 0;
    _minimumLineSpacing = 0;
    _minimumInteritemSpacing = 0;
    _itemSize = CGSizeMake(0, 0);
    _contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

@end
