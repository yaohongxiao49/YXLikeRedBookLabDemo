//
//  YXRedBookPointLabView.h
//  LikeRedBookTest
//
//  Created by ios on 2019/6/25.
//  Copyright © 2019 August. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXRedBookPointLabModel.h"

#define kTextFont 12
/** 间隔线长度 */
static CGFloat const kIntervalLineLayerWidth = 16.0f;
/** 水平间距 */
static CGFloat const kTextLayerHorizontalPadding = 10.0f;
/** 垂直间距 */
static CGFloat const kTextLayerVerticalPadding = 7.0f;
/** 实心半径 */
static CGFloat const kCenterPointRadius = 3.0f;
/** 阴影半径 */
static CGFloat const kShadowPointRadius = 7.5f;

static NSString * _Nonnull const kAnimationKeyShow = @"show";

NS_ASSUME_NONNULL_BEGIN

@interface YXRedBookPointLabView : UIView

/**
 初始化视图

 @param tagModel 标签模型
 */
- (instancetype)initWithTagModel:(YXRedBookPointLabModel *)tagModel;

/** 是否初始判定显示区域 */
@property (nonatomic, assign) BOOL boolInitialDecisionDisplay;
/** 是否显示标签 */
@property (nonatomic, assign) BOOL boolShowTagsView;
/** 是否隐藏标签 */
@property (nonatomic, assign) BOOL boolHiddenTagsView;
/** 是否是编辑状态 */
@property (nonatomic, assign) BOOL boolEditDisable;

/** 显示动画 */
- (void)showTagsViewWithAnimated:(BOOL)boolAnimation;
/** 隐藏动画 */
- (void)hideTagsViewWithAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
