# HUAutoLayout
根据给定的数据量,进行自动排版.


## 使用方法

### 实例化布局对象
```Objc
  HUAutoLayout *layout = [HUAutoLayout sharedLayout];
```

### 为布局对象赋值
```Objc
  NSUInteger culomn;               //!< 属性描述: 列数  
  NSUInteger line;                 //!< 属性描述: 行数
  UIEdgeInsets contentInset;       //! <属性描述: 内边距
  CGFloat minimumInteritemSpacing; //!< 属性描述: 列间距
  CGFloat minimumLineSpacing;      //!< 属性描述: 行间距
  CGSize itemSize;                 //!< 属性描述: 尺寸
```
### 九宫格自动布局
```Objc
  - (void) hu_layoutSquare:(UIView *)targetView layoutCount:(NSInteger)count layoutType:(HUAutoLayoutSquareType)type handleBlock:(HUAutoLayoutHandleBlock)handleBlock;
```

- 垂直方向上流水布局
必须设定 itemHeight, culomn 和 itemWidth 至少一个需给定数据.
- 水平方向上流水布局
必须设定 itemWidth, line 和 itemHeight 至少一个需给定数据.
- 限定范围内固定布局
line, culomn, itemWidth, itemHeight 至少一个需给定数据.

### 瀑布流自动布局
-必须先需要设置代理 waterfallDelegate.
```Objc
  - (void) hu_layoutWaterfall:(UIView *)targetView layoutCount:(NSInteger)count layoutType:(HUAutoLayoutWaterfallType)type handleBlock:(HUAutoLayoutHandleBlock)handleBlock;
```

- 垂直方向上流水布局
culomn 和 itemWidth 至少设置一个.
需实现代理方法:
```Objc
  - (CGFloat)layoutForItemHeight:(CGFloat)itemWith index:(NSUInteger)index;
```
- 水平方向上流水布局
line 和 itemHeight 至少一个需给定数据.
需实现代理方法:
```Objc
  - (CGFloat)layoutForItemWidth:(CGFloat)itemHeight index:(NSUInteger)index;
```

## demo演示
本demo请用: 模拟器6和6s运行,其它屏幕未作适配.<br>
  ![自动排版演示1](https://github.com/huxiaoluder/HUAutoLayout/blob/master/Sourse/自动排版演示1.gif "自动排版演示1")
  ![自动排版演示2](https://github.com/huxiaoluder/HUAutoLayout/blob/master/Sourse/自动排版演示2.gif "自动排版演示2")

## 交流邮箱
huxiaoluder@163.com, 欢迎交流.








