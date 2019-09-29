//
//  YXRedBookPointLabModel.h
//  LikeRedBookTest
//
//  Created by ios on 2019/6/25.
//  Copyright © 2019 August. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, YXRedBookPointLabModelType) {
    /** 文字 */
    YXRedBookPointLabModelTypeText,
    /** 语音 */
    YXRedBookPointLabModelTypeVoice,
};

typedef NS_ENUM(NSUInteger, YXDirectionStyle) {
    /** 右 */
    YXDirectionStyleRight = 0,
    /** 左 */
    YXDirectionStyleLeft,
};

@interface YXRedBookPointLabModel : NSObject

/** 控制器 */
@property (nonatomic, weak) UIViewController *baseVC;
/** 圆心坐标 */
@property (nonatomic, assign) CGPoint coordinate;
/** 标签类型 */
@property (nonatomic, assign) YXRedBookPointLabModelType tagStyle;
/** 标签方向 */
@property (nonatomic, assign) YXDirectionStyle directionStyle;
/** 标签文本 */
@property (nonatomic, strong) NSMutableArray *tagContentsArray;
/** 标签角度 */
@property (nonatomic, strong, readonly) NSMutableArray *tagAngleArray;
/** 标签数量 */
@property (nonatomic, assign, readonly) NSInteger tagContentCount;

/**
 初始化视图

 @param tagContentsArray 文本数组
 @param tagStyle 显示类型
 @param directionStyle 方向类型
 @param coordinate 圆心相对坐标（比例）
 */
- (instancetype)initTagModelWithTagContentsArray:(NSMutableArray *)tagContentsArray tagStyle:(YXRedBookPointLabModelType)tagStyle directionStyle:(YXDirectionStyle)directionStyle coordinate:(CGPoint)coordinate baseVC:(UIViewController *)baseVC;

/** 改变方向 */
- (void)changeTagViewStyle;

@end

NS_ASSUME_NONNULL_END
