//
//  HUTableViewCell.m
//  HUAutoLayoutDemo
//
//  Created by 胡校明 on 16/3/30.
//  Copyright © 2016年 HU. All rights reserved.
//

#import "HUTableViewCell.h"
#import "HULayoutData.h"
#import "HUAutoLayout.h"

@interface HUTableViewCell ()

@property (weak, nonatomic) IBOutlet UITextField *layoutCountField;
@property (weak, nonatomic) IBOutlet UITextField *itemWidthField;
@property (weak, nonatomic) IBOutlet UITextField *itemHeightField;
@property (weak, nonatomic) IBOutlet UITextField *culomnField;
@property (weak, nonatomic) IBOutlet UITextField *lineField;
@property (weak, nonatomic) IBOutlet UITextField *minimumInteritemSpacingField;
@property (weak, nonatomic) IBOutlet UITextField *minimumLineSpacingField;
@property (weak, nonatomic) IBOutlet UITextField *topField;
@property (weak, nonatomic) IBOutlet UITextField *bottomField;
@property (weak, nonatomic) IBOutlet UITextField *leftField;
@property (weak, nonatomic) IBOutlet UITextField *rightField;

@end

@implementation HUTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layoutData = [HULayoutData new];
}

- (IBAction)beginLayout:(UIButton *)sender {

    [self.contentView resignFirstResponder];
    _layoutData.layoutCount = [_layoutCountField.text integerValue];
    _layoutData.line = [_lineField.text integerValue];
    _layoutData.culomn = [_culomnField.text integerValue];
    _layoutData.itemWidth = [_itemWidthField.text doubleValue];
    _layoutData.itemHeight = [_itemHeightField.text doubleValue];
    _layoutData.contentInsetTop = [_topField.text doubleValue];
    _layoutData.contentInsetLeft = [_leftField.text doubleValue];
    _layoutData.contentInsetBottom = [_bottomField.text doubleValue];
    _layoutData.contentInsetRight = [_rightField.text doubleValue];
    _layoutData.minimumInteritemSpacing = [_minimumInteritemSpacingField.text doubleValue];
    _layoutData.minimumLineSpacing = [_minimumLineSpacingField.text doubleValue];
    
    switch (sender.tag) {
        case 1:
            _layoutData.layoutType = @"HUSquareFlowLayoutInVertical";
            break;
        case 2:
            _layoutData.layoutType = @"HUSquareFlowLayoutInHorizontal";
            break;
        case 3:
            _layoutData.layoutType = @"HUSquareFlowLayoutInFixedRect";
            break;
        case 4:
            _layoutData.layoutType = @"HUWaterfallFlowLayoutInVertical";
            break;
        case 5:
            _layoutData.layoutType = @"HUWaterfallFlowLayoutInHorizontal";
            break;
        default:
            break;
    }
}

@end
