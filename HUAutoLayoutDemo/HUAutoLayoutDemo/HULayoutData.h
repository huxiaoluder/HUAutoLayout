//
//  HULayoutData.h
//  HUAutoLayoutDemo
//
//  Created by 胡校明 on 16/3/30.
//  Copyright © 2016年 HU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HULayoutData : NSObject

@property ( nonatomic, assign) NSUInteger layoutCount;          //!< 属性描述: 布局个数
@property ( nonatomic, assign) NSUInteger culomn;               //!< 属性描述: 列数
@property ( nonatomic, assign) NSUInteger line;                 //!< 属性描述: 行数
@property ( nonatomic, assign) CGFloat contentInsetTop;         //!< 属性描述: 上边距
@property ( nonatomic, assign) CGFloat contentInsetLeft;        //!< 属性描述: 左边距
@property ( nonatomic, assign) CGFloat contentInsetBottom;      //!< 属性描述: 下边距
@property ( nonatomic, assign) CGFloat contentInsetRight;       //!< 属性描述: 右边距
@property ( nonatomic, assign) CGFloat minimumInteritemSpacing; //!< 属性描述: 列间距
@property ( nonatomic, assign) CGFloat minimumLineSpacing;      //!< 属性描述: 行间距
@property ( nonatomic, assign) CGFloat itemWidth;               //!< 属性描述: 单个方格的宽
@property ( nonatomic, assign) CGFloat itemHeight;              //!< 属性描述: 单个方格的高
@property ( nonatomic, assign) NSString *layoutType;            //!<属性描述: 布局方式

@end
