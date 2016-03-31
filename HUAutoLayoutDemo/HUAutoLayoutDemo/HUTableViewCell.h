//
//  HUTableViewCell.h
//  HUAutoLayoutDemo
//
//  Created by 胡校明 on 16/3/30.
//  Copyright © 2016年 HU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HULayoutData;

@interface HUTableViewCell : UITableViewCell

@property ( nonatomic, strong) HULayoutData *layoutData;   //!< 属性描述: 布局数据的模型

@end
