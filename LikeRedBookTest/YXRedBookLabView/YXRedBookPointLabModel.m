//
//  YXRedBookPointLabModel.m
//  LikeRedBookTest
//
//  Created by ios on 2019/6/25.
//  Copyright © 2019 August. All rights reserved.
//

#import "YXRedBookPointLabModel.h"

/** 显示的类型最大数 */
static NSInteger const maxStyle = 2;

@implementation YXRedBookPointLabModel

- (instancetype)initTagModelWithTagContentsArray:(NSMutableArray *)tagContentsArray tagStyle:(YXRedBookPointLabModelType)tagStyle directionStyle:(YXDirectionStyle)directionStyle coordinate:(CGPoint)coordinate baseVC:(UIViewController *)baseVC {
    self = [super init];
    
    if (self) {
        self.tagContentsArray = tagContentsArray;
        self.tagStyle = tagStyle;
        self.directionStyle = directionStyle;
        self.coordinate = coordinate;
        _tagAngleArray = [@[] mutableCopy];
        _tagContentCount = tagContentsArray.count;
        self.baseVC = baseVC;
        [self initTagAngle];
    }
    return self;
}

- (void)changeTagViewStyle {
    
    _directionStyle = (_directionStyle + 1) % maxStyle;
    [self setTagAngle];
}

- (void)setTagAngle {
    
    NSMutableArray *angleArray = [@[] mutableCopy];
    if (_tagContentCount == 1) {
        if (_directionStyle == YXDirectionStyleRight) {
            [angleArray addObject:@0.0];
        }
        else if (_directionStyle == YXDirectionStyleLeft) {
            [angleArray addObject:@(180.0)];
        }
    }
    _tagAngleArray = angleArray;
}
- (void)initTagAngle {
    
    NSMutableArray *angleArray = [@[] mutableCopy];
    if (_tagContentCount == 1) {
        if (_directionStyle == YXDirectionStyleRight) {
            [angleArray addObject:@0.0];
        }
        else if (_directionStyle == YXDirectionStyleLeft) {
            [angleArray addObject:@(180.0)];
        }
    }
    _tagAngleArray = angleArray;
}

@end
