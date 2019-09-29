//
//  YXRedBookPointLabView.m
//  LikeRedBookTest
//
//  Created by ios on 2019/6/25.
//  Copyright © 2019 August. All rights reserved.
//

#import "YXRedBookPointLabView.h"

@interface YXRedBookPointLabView ()
{
    BOOL _isChangeTagStyle;
}

@property (nonatomic, strong) YXRedBookPointLabModel *tagModel;
/** 中心点 */
@property (nonatomic, strong) CAShapeLayer *centerPointShapeLayer;
/** 中心点阴影 */
@property (nonatomic, strong) CAShapeLayer *shadowPointShapeLayer;
/** 拖动时的起始位置 */
@property (nonatomic, assign) CGPoint startPosition;
/** 文字下的横线 */
@property (nonatomic, strong) NSMutableArray<CAShapeLayer *> *underLineLayers;
/** 显示视图（文字、语音显示区域） */
@property (nonatomic, strong) UIView *showView;
/** 文字 */
@property (nonatomic, strong) UILabel *tagLab;
/** 语音 */
@property (nonatomic, strong) UILabel *voiceLab;
@property (nonatomic, strong) UIImageView *voiceImg;
/** 毛玻璃 */
@property (nonatomic, strong) UIVisualEffectView *visualEffectView;
/** 删除按钮 */
@property (nonatomic, strong) UIImageView *deleteImgView;

@end

@implementation YXRedBookPointLabView

- (instancetype)initWithTagModel:(YXRedBookPointLabModel *)tagModel {
    self = [super init];
    
    if (self) {
        _tagModel = tagModel;
        
        _underLineLayers = [@[] mutableCopy];
        [self setTagsViewFrame];
        [self setupGesture];
        [self setUpUI];
    }
    return self;
}

#pragma mark - 设置标签大小
- (void)setTagsViewFrame {
    
    CGSize textMaxSize = CGSizeZero;
    for (NSString *content in _tagModel.tagContentsArray) {
        UIFont *font = [UIFont systemFontOfSize:kTextFont];
        CGSize textSize = [content sizeWithAttributes:@{NSFontAttributeName:font}];
        if (textSize.width > textMaxSize.width) {
            textMaxSize = textSize;
            textMaxSize.width = textMaxSize.width + kTextLayerHorizontalPadding *2;
        }
    }
    //控件的宽度 = 分隔线长度 + 宽度间隔 + 文本宽度
    //控件的高度 = 高度间隔 + 文本高度
    CGFloat width = 0.0f;
    CGFloat height = 0.0f;
    if (_tagModel.tagStyle == YXRedBookPointLabModelTypeText) {
        width = (kIntervalLineLayerWidth + kTextLayerHorizontalPadding + textMaxSize.width) *2;
        height = kTextLayerVerticalPadding *2 + textMaxSize.height;
        self.frame = CGRectMake(0, 0, width, height);
    }
    else {
        width = (kIntervalLineLayerWidth + kTextLayerHorizontalPadding + 70) *2;
        height = kTextLayerVerticalPadding *2 + textMaxSize.height;
        self.frame = CGRectMake(0, 0, width, height);
    }
}

#pragma mark - 设置视图
- (void)setUpUI {
    
    self.boolShowTagsView = YES;
    
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [_underLineLayers removeAllObjects];
    _shadowPointShapeLayer = nil;
    _centerPointShapeLayer = nil;
    [self.showView removeFromSuperview];
    self.showView = nil;
    self.visualEffectView = nil;
    self.tagLab = nil;
    self.voiceLab = nil;
    self.voiceImg = nil;
    self.deleteImgView.hidden = YES;
    
    // 画线
    NSNumber *angle = _tagModel.tagAngleArray[0];
    CAShapeLayer *underLineLayer = [self setupUnderLineShapeLayerWithAngle:angle.doubleValue];
    [_underLineLayers addObject:underLineLayer];
    [self.layer addSublayer:underLineLayer];
    
    //原点阴影
    _shadowPointShapeLayer = [self setupCenterPointShapeLayerWithRadius:kShadowPointRadius];
    _shadowPointShapeLayer.fillColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.15].CGColor;
    [self.layer addSublayer:_shadowPointShapeLayer];
    _shadowPointShapeLayer.shadowColor = [UIColor darkGrayColor].CGColor;
    _shadowPointShapeLayer.shadowOpacity = 1;
    _shadowPointShapeLayer.shadowRadius = 1;
    _shadowPointShapeLayer.shadowOffset = CGSizeMake(0, 0);
    //原点
    _centerPointShapeLayer = [self setupCenterPointShapeLayerWithRadius:kCenterPointRadius];
    [self.layer addSublayer:_centerPointShapeLayer];
    
    //显示
    [self showViewWithStyle:_tagModel.directionStyle];
}
/** 设置原点位置 */
- (CAShapeLayer *)setupCenterPointShapeLayerWithRadius:(CGFloat)kCenterPointRadius {
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, kCenterPointRadius *2, kCenterPointRadius *2)].CGPath;
    shapeLayer.fillColor = [UIColor whiteColor].CGColor;
    shapeLayer.bounds = CGRectMake(0, 0, kCenterPointRadius *2, kCenterPointRadius *2);
    shapeLayer.position = CGPointMake(self.layer.bounds.size.width /2, self.layer.bounds.size.height /2);
    return shapeLayer;
}
/** 设置线条 */
- (CAShapeLayer *)setupUnderLineShapeLayerWithAngle:(CGFloat)angle {
    
    CGPoint centerPoint = CGPointMake(self.layer.bounds.size.width /2, self.layer.bounds.size.height /2);
    CGPoint startPoint = centerPoint;
    CGPoint endPoint;
    
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.strokeColor = [UIColor whiteColor].CGColor;
    lineLayer.fillColor = [UIColor clearColor].CGColor;
    lineLayer.shadowColor = [UIColor lightGrayColor].CGColor;
    lineLayer.shadowOpacity = 0.8;
    lineLayer.shadowRadius = 2;
    lineLayer.shadowOffset = CGSizeMake(0, 0);
    lineLayer.masksToBounds = NO;
    
    //绘制路径
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:centerPoint];
    //直线
    if (angle < 90.f && angle > -90.f) {
        //角度在第一四象限，向右画
        endPoint = CGPointMake(startPoint.x + kIntervalLineLayerWidth + kTextLayerHorizontalPadding, startPoint.y);
        [path addLineToPoint:endPoint];
    }
    else {
        //角度在第二三象限，向左画
        endPoint = CGPointMake(startPoint.x - kIntervalLineLayerWidth - kTextLayerHorizontalPadding, startPoint.y);
        [path addLineToPoint:endPoint];
    }
    
    lineLayer.path = path.CGPath;
    //添加这句话不显示阴影
    //lineLayer.shadowPath = path.CGPath;
    lineLayer.strokeEnd = 0;
    return lineLayer;
}
/** 设置显示 */
- (void)showViewWithStyle:(YXDirectionStyle)style {
 
    self.showView.layer.cornerRadius = self.layer.bounds.size.height /2;
    self.visualEffectView.hidden = NO;
    CGFloat width = self.layer.bounds.size.width /2 - kTextLayerHorizontalPadding - kIntervalLineLayerWidth;
    if (style == YXDirectionStyleLeft) {
        self.showView.frame = CGRectMake(0, 0, width, self.layer.bounds.size.height);
    }
    else if (style == YXDirectionStyleRight) {
        self.showView.frame = CGRectMake(self.layer.bounds.size.width /2 + kTextLayerHorizontalPadding + kIntervalLineLayerWidth, 0, width, self.layer.bounds.size.height);
    }
    
    if (_tagModel.tagStyle == YXRedBookPointLabModelTypeText) {
        self.tagLab.hidden = NO;
        self.voiceLab.hidden = self.voiceImg.hidden = YES;
        self.tagLab.text = _tagModel.tagContentsArray[0];
        self.tagLab.frame = CGRectMake(self.showView.bounds.origin.x + kTextLayerHorizontalPadding, 0, self.showView.bounds.size.width - kTextLayerHorizontalPadding *2, self.showView.bounds.size.height);
    }
    else if (_tagModel.tagStyle == YXRedBookPointLabModelTypeVoice) {
        self.tagLab.hidden = YES;
        self.voiceLab.hidden = self.voiceImg.hidden = NO;
        self.voiceLab.text = _tagModel.tagContentsArray[0];
        self.voiceLab.frame = CGRectMake(self.showView.bounds.origin.x + kTextLayerHorizontalPadding, 0, self.showView.bounds.size.width - kTextLayerHorizontalPadding *2 - 20, self.showView.bounds.size.height);
    }
}

#pragma mark - 添加手势
- (void)setupGesture {
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    
    [self addGestureRecognizer:tapGesture];
    [self addGestureRecognizer:longPressGesture];
    [self addGestureRecognizer:panGesture];
}

#pragma mark - 单击
- (void)didTap:(UITapGestureRecognizer *)recognizer {
    
    //非编辑状态
    if (self.boolEditDisable == YES || self.boolShowTagsView == NO) {
        return;
    }
    CGPoint position = [recognizer locationInView:self];
    CGPoint pointPosition = [recognizer locationInView:self.superview];
    //点击圆心，判断点触范围是否在延展中心圆范围
    if ([self centerContainsPoint:position]) {
        if (_tagModel.directionStyle == YXDirectionStyleLeft) {
            if (pointPosition.x + self.layer.bounds.size.width /2 >= [[UIScreen mainScreen] bounds].size.width) {
                self.center = CGPointMake([[UIScreen mainScreen] bounds].size.width - self.layer.bounds.size.width /2, pointPosition.y);
            }
        }
        else if (_tagModel.directionStyle == YXDirectionStyleRight) {
            if (pointPosition.x - self.layer.bounds.size.width /2 <= 0) {
                self.center = CGPointMake(self.layer.bounds.size.width /2, pointPosition.y);
            }
        }
        
        //切换风格
        _isChangeTagStyle = YES;
        [_tagModel changeTagViewStyle];
        [self setUpUI];
        self.boolShowTagsView = YES;
    }
}
#pragma mark - 长按
- (void)longPress:(UILongPressGestureRecognizer *)recognizer {
    
    //非编辑状态
    if (self.boolEditDisable == YES || self.boolShowTagsView == NO) {
        return;
    }
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            CGPoint position = [recognizer locationInView:self];
            if ([self centerContainsPoint:position]) {
                
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            
            break;
        }
        case UIGestureRecognizerStateEnded: {
            
            break;
        }
        default:
            break;
    }
}
#pragma mark - 拖拽
- (void)didPan:(UIPanGestureRecognizer *)recognizer {
    
    //非编辑状态
    if (self.boolEditDisable == YES || self.boolShowTagsView == NO) {
        return;
    }
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            self.deleteImgView.hidden = NO;
            //保存初始点击位置
            _startPosition = [recognizer locationInView:self.superview];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            //移动
            CGPoint position = [recognizer locationInView:self.superview];
            if (_tagModel.directionStyle == YXDirectionStyleLeft) {
                if (position.x >= [[UIScreen mainScreen] bounds].size.width) {
                    return;
                }
                else if (position.x - self.bounds.size.width /2 <= 0) {
                    return;
                }
            }
            else if (_tagModel.directionStyle == YXDirectionStyleRight) {
                if (position.x + self.bounds.size.width /2 >= [[UIScreen mainScreen] bounds].size.width) {
                    return;
                }
                else if (position.x <= 0) {
                    return;
                }
            }
            self.center = position;
            break;
        }
        case UIGestureRecognizerStateEnded: {
            if (self.deleteImgView.isHidden) {
                //最后保存中心点的相对坐标
                CGFloat x, y;
                x = self.center.x /self.superview.bounds.size.width;
                y = self.center.y /self.superview.bounds.size.height;
                CGPoint coordinate = CGPointMake(x, y);
                _tagModel.coordinate = coordinate;
            }
            else {
                if ((self.center.x >= self.deleteImgView.frame.origin.x) && (self.center.x <= (self.deleteImgView.frame.origin.x + self.deleteImgView.frame.size.width)) && (self.center.y >= self.deleteImgView.frame.origin.y) && (self.center.y <= (self.deleteImgView.frame.origin.y + self.deleteImgView.frame.size.height))) {
                    self.deleteImgView.hidden = YES;
                    [self removeFromSuperview];
                }
                else {
                    self.deleteImgView.hidden = YES;
                }
            }
            break;
        }
        default:
            break;
    }
}

/** 点position是否在半径值的中心圆内 */
- (BOOL)centerContainsPoint:(CGPoint)position {
    
    CGPoint centerPosition = CGPointMake(self.layer.bounds.size.width /2, self.layer.bounds.size.height /2);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:centerPosition radius:(kShadowPointRadius + kCenterPointRadius) startAngle:0 endAngle:2 *M_PI clockwise:YES];
    return [path containsPoint:position];
}

#pragma mark - 动画
/** 显示动画 */
- (void)showTagsViewWithAnimated:(BOOL)boolAnimation {
    
    __weak typeof(self) weakSelf = self;
    CGFloat duration = 0.3f;
    [UIView animateWithDuration:3 *duration animations:^{
        
        NSTimeInterval currentTime = CACurrentMediaTime();
        CAAnimationGroup *animationGrop = [CAAnimationGroup animation];
        animationGrop.removedOnCompletion = NO;
        animationGrop.duration = 1;
        animationGrop.fillMode = kCAFillModeForwards;
        //相同时间只执行一个动画
        //原点
        CABasicAnimation *basicAnimation = [CABasicAnimation animation];
        basicAnimation.beginTime = 0;
        basicAnimation.keyPath = @"opacity";
        basicAnimation.duration = duration;
        basicAnimation.removedOnCompletion = NO;
        basicAnimation.fillMode = kCAFillModeForwards;
        basicAnimation.fromValue = @0;
        basicAnimation.toValue = @1;
        
        if (self->_isChangeTagStyle == YES) {
            
            CAKeyframeAnimation *scaleKeyframeAnimation = [CAKeyframeAnimation animation];
            scaleKeyframeAnimation.beginTime = duration;
            scaleKeyframeAnimation.keyPath = @"transform.scale";
            scaleKeyframeAnimation.keyTimes = @[@0, @0.2, @0.4];
            scaleKeyframeAnimation.values = @[@1, @1.5, @1];
            animationGrop.animations = @[basicAnimation, scaleKeyframeAnimation];
        }
        else {
            animationGrop.animations = @[basicAnimation];
        }
        [weakSelf.centerPointShapeLayer addAnimation:animationGrop forKey:kAnimationKeyShow];
        [weakSelf.shadowPointShapeLayer addAnimation:animationGrop forKey:kAnimationKeyShow];
        
        //下划线
        CABasicAnimation *lineAnimation = [CABasicAnimation animation];
        lineAnimation.beginTime = currentTime + duration;
        lineAnimation.keyPath = @"strokeEnd";
        lineAnimation.duration = duration;
        lineAnimation.removedOnCompletion = NO;
        lineAnimation.fillMode = kCAFillModeBoth;
        lineAnimation.fromValue = @0;
        lineAnimation.toValue = @1;
        for (CAShapeLayer *shapeLayer in weakSelf.underLineLayers) {
            [shapeLayer addAnimation:lineAnimation forKey:kAnimationKeyShow];
        }
        self.showView.hidden = NO;
        self.showView.alpha = 1;
    } completion:^(BOOL finished) {
        
        self->_isChangeTagStyle = NO;
        weakSelf.boolHiddenTagsView = NO;
    }];
}
/** 隐藏动画 */
- (void)hideTagsViewWithAnimated:(BOOL)animated {
 
    __weak typeof(self) weakSelf = self;
    CGFloat duration = 0.3f;
    [UIView animateWithDuration:3 *duration animations:^{
        
        //原点
        NSTimeInterval currentTime = CACurrentMediaTime();
        CABasicAnimation *basicAnimation = [CABasicAnimation animation];
        basicAnimation.beginTime = 0;
        basicAnimation.keyPath = @"opacity";
        basicAnimation.duration = duration;
        basicAnimation.removedOnCompletion = NO;
        basicAnimation.fillMode = kCAFillModeForwards;
        basicAnimation.fromValue = @1;
        basicAnimation.toValue = @0;
        [weakSelf.centerPointShapeLayer addAnimation:basicAnimation forKey:kAnimationKeyShow];
        [weakSelf.shadowPointShapeLayer addAnimation:basicAnimation forKey:kAnimationKeyShow];
        
        //下划线
        CABasicAnimation *lineAnimation = [CABasicAnimation animation];
        lineAnimation.beginTime = currentTime+duration;
        lineAnimation.keyPath = @"strokeEnd";
        lineAnimation.duration = duration;
        lineAnimation.removedOnCompletion = NO;
        lineAnimation.fillMode = kCAFillModeBoth;
        lineAnimation.fromValue = @1;
        lineAnimation.toValue = @0;
        for (CAShapeLayer *shapeLayer in weakSelf.underLineLayers) {
            [shapeLayer addAnimation:lineAnimation forKey:kAnimationKeyShow];
        }
     } completion:^(BOOL finished) {
        
        weakSelf.boolHiddenTagsView = YES;
    }];
}

#pragma mark - 是否显示动画
- (void)setBoolShowTagsView:(BOOL)boolShowTagsView {
    
    _boolShowTagsView = boolShowTagsView;
    
    if (_boolShowTagsView) {
        [self showTagsViewWithAnimated:YES];
    }
    else {
        [self hideTagsViewWithAnimated:NO];
    }
}

#pragma mark - 初始判定显示区域
- (void)setBoolInitialDecisionDisplay:(BOOL)boolInitialDecisionDisplay {
    
    _boolInitialDecisionDisplay = boolInitialDecisionDisplay;
    
    if (_boolInitialDecisionDisplay) {
        if (_tagModel.directionStyle == YXDirectionStyleLeft) {
            if (self.center.x - self.layer.bounds.size.width /2 <= 0) {
                self.center = CGPointMake(self.layer.bounds.size.width /2, self.center.y);
            }
        }
        else if (_tagModel.directionStyle == YXDirectionStyleRight) {
            if (self.center.x + self.layer.bounds.size.width /2 >= [[UIScreen mainScreen] bounds].size.width) {
                //切换风格
                _isChangeTagStyle = YES;
                [_tagModel changeTagViewStyle];
                [self setUpUI];
                self.boolShowTagsView = YES;
            }
        }
    }
}

#pragma mark - 懒加载
- (UIView *)showView {
    
    if (!_showView) {
        _showView = [UIView new];
        _showView.layer.borderWidth = 1;
        _showView.layer.borderColor = [UIColor whiteColor].CGColor;
        _showView.layer.masksToBounds = YES;
        _showView.layer.cornerRadius = 16;
        _showView.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.15];
        _showView.hidden = YES;
        _showView.alpha = 0;
        [self addSubview:_showView];
    }
    return _showView;
}
- (UIVisualEffectView *)visualEffectView {
    
    if (!_visualEffectView) {
        //实现模糊效果
        UIBlurEffect *blurEffrct = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        //毛玻璃视图
        _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffrct];
        _visualEffectView.alpha = 0.9;
        _visualEffectView.frame = self.showView.bounds;
        [self.showView insertSubview:_visualEffectView atIndex:0];
    }
    return _visualEffectView;
}
- (UILabel *)tagLab {
    
    if (!_tagLab) {
        _tagLab = [UILabel new];
        _tagLab.textAlignment = NSTextAlignmentLeft;
        _tagLab.font = [UIFont systemFontOfSize:12];
        _tagLab.textColor = [UIColor whiteColor];
        [self.showView addSubview:_tagLab];
    }
    return _tagLab;
}
- (UILabel *)voiceLab {
    
    if (!_voiceLab) {
        _voiceLab = [UILabel new];
        _voiceLab.textAlignment = NSTextAlignmentLeft;
        _voiceLab.font = [UIFont systemFontOfSize:12];
        _voiceLab.textColor = [UIColor whiteColor];
        [self.showView addSubview:_voiceLab];
    }
    return _voiceLab;
}
- (UIImageView *)voiceImg {
    
    if (!_voiceImg) {
        _voiceImg = [[UIImageView alloc] initWithFrame:CGRectMake(self.showView.bounds.size.width - 16 - 4, 4, 16, 16)];
        [_voiceImg setImage:[UIImage imageNamed:@"YXVoicePlayImg"]];
        _voiceImg.center = CGPointMake(_voiceImg.center.x, self.showView.center.y);
        _voiceImg.layer.masksToBounds = YES;
        _voiceImg.layer.cornerRadius = 16 /2;
        [self.showView addSubview:_voiceImg];
    }
    return _voiceImg;
}
- (UIImageView *)deleteImgView {
    
    if (!_deleteImgView) {
        _deleteImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        _deleteImgView.center = CGPointMake(_tagModel.baseVC.view.center.x, _tagModel.baseVC.view.bounds.size.height - 64 - 50);
        [_deleteImgView setImage:[UIImage imageNamed:@""]];
        _deleteImgView.hidden = YES;
        _deleteImgView.layer.masksToBounds = YES;
        _deleteImgView.layer.cornerRadius = 50 /2;
        _deleteImgView.backgroundColor = [UIColor redColor];
        [_tagModel.baseVC.view addSubview:_deleteImgView];
    }
    return _deleteImgView;
}

@end
