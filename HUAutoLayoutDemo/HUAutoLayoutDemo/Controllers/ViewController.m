//
//  ViewController.m
//  HUAutoLayoutDemo
//
//  Created by 胡校明 on 16/3/28.
//  Copyright © 2016年 HU. All rights reserved.
//

#import "ViewController.h"
#import "HUAutoLayout.h"
#import "HULayoutData.h"

#define random(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]
#define randomColor random(arc4random_uniform(255), arc4random_uniform(255),arc4random_uniform(255), arc4random_uniform(255))

@interface ViewController ()<HUAutoLayoutWaterfallDelegate>

@property ( nonatomic, strong) NSMutableArray *scales;   //!< 属性描述: 宽高比数组

@end

@implementation ViewController

- (NSMutableArray *)scales {
    if (!_scales) {
        _scales = [NSMutableArray array];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"shop.plist" ofType:nil];
        NSMutableArray *tempArray = [NSMutableArray arrayWithContentsOfFile:path];
        [tempArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *dict = (NSDictionary *)obj;
            CGFloat scale = [dict[@"w"] doubleValue] / [dict[@"h"] doubleValue];
            [_scales addObject:@(scale)];
        }];
    }
    return _scales;
}

- (void)loadView {
    [super loadView];
    UIScrollView *scView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 64)];
    
    scView.backgroundColor = [UIColor whiteColor];
    self.view = scView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    HUAutoLayout *layout = [HUAutoLayout sharedLayout];
    layout.waterfallDelegate = self;
    layout.itemSize = CGSizeMake(_layoutData.itemWidth, _layoutData.itemHeight);
    layout.line = _layoutData.line;
    layout.culomn = _layoutData.culomn;
    layout.contentInset = UIEdgeInsetsMake(_layoutData.contentInsetTop, _layoutData.contentInsetLeft, _layoutData.contentInsetBottom, _layoutData.contentInsetRight);
    layout.minimumInteritemSpacing = _layoutData.minimumInteritemSpacing;
    layout.minimumLineSpacing = _layoutData.minimumLineSpacing;
    
    if ([_layoutData.layoutType  isEqualToString: @"HUSquareFlowLayoutInVertical"]) {

        [self squareLayout:layout layoutType:HUSquareFlowLayoutInVertical];
        
    } else if ([_layoutData.layoutType isEqualToString:@"HUSquareFlowLayoutInHorizontal"]) {
        
        [self squareLayout:layout layoutType:HUSquareFlowLayoutInHorizontal];
        
    } else if ([_layoutData.layoutType isEqualToString:@"HUSquareFlowLayoutInFixedRect"]) {
        
        [self squareLayout:layout layoutType:HUSquareFlowLayoutInFixedRect];
        
    } else if ([_layoutData.layoutType isEqualToString:@"HUWaterfallFlowLayoutInVertical"]) {
        
        [self waterfallLayout:layout layoutType:HUWaterfallFlowLayoutInVertical];
        
    } else {
        
        [self waterfallLayout:layout layoutType:HUWaterfallFlowLayoutInHorizontal];
    }
}

- (void)squareLayout:(HUAutoLayout *)layout layoutType:(HUAutoLayoutSquareType)type {
    [layout hu_layoutSquare:self.view layoutCount:_layoutData.layoutCount layoutType:type handleBlock:^(CGRect frame, NSInteger index, NSError *error) {
        
        if (error) {
            [self throwError:error];
            return;
        }
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.backgroundColor = randomColor;
        imageView.frame = frame;
        
        [self.view addSubview:imageView];
    }];
}

- (void)waterfallLayout:(HUAutoLayout *)layout layoutType:(HUAutoLayoutWaterfallType)type {
    [layout hu_layoutWaterfall:self.view layoutCount:self.scales.count layoutType:type handleBlock:^(CGRect frame, NSInteger index, NSError *error) {
        
        if (error) {
            [self throwError:error];
            return;
        }
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.backgroundColor = randomColor;
        imageView.frame = frame;
        
        [self.view addSubview:imageView];
    }];
}

- (void)throwError:(NSError *)error {
    NSLog(@"%@\n%@",error.domain,error.userInfo[@"layoutError"]);
    UILabel *lable = [UILabel new];
    lable.numberOfLines = 0;
    lable.textAlignment = NSTextAlignmentCenter;
    lable.text = error.userInfo[@"layoutError"];
    lable.textColor = [UIColor redColor];
    lable.font = [UIFont systemFontOfSize:50];
    lable.frame = self.view.bounds;
    [self.view addSubview:lable];
}

#pragma mark - HUAutoLayoutWaterfallDelegate
- (CGFloat)layoutForItemHeight:(CGFloat)itemWith index:(NSUInteger)index {
    return itemWith / [self.scales[index] doubleValue];
}

- (CGFloat)layoutForItemWidth:(CGFloat)itemHeight index:(NSUInteger)index {
    return itemHeight * [self.scales[index] doubleValue];
}

@end
