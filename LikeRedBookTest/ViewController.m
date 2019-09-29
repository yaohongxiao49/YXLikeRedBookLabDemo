//
//  ViewController.m
//  LikeRedBookTest
//
//  Created by ios on 2019/6/25.
//  Copyright © 2019 August. All rights reserved.
//

#import "ViewController.h"
#import "YXRedBookPointLabView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    YXRedBookPointLabModel *model = [[YXRedBookPointLabModel alloc] initTagModelWithTagContentsArray:[@[@"电视剧放开手的奶粉进口"] mutableCopy] tagStyle:YXRedBookPointLabModelTypeText directionStyle:YXDirectionStyleRight coordinate:CGPointMake(0.5, 0.4) baseVC:self];
    
    YXRedBookPointLabView *view = [[YXRedBookPointLabView alloc] initWithTagModel:model];
    view.center = CGPointMake((self.view.bounds.size.width *model.coordinate.x), (self.view.bounds.size.height *model.coordinate.y));
    [view showTagsViewWithAnimated:YES];
    [self.view addSubview:view];
}


@end
