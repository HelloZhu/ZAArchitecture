//
//  ViewController.m
//  ZAArchitecture
//
//  Created by ap2 on 16/1/7.
//  Copyright © 2016年 ap2. All rights reserved.
//

#import "BaseViewController.h"
#import "ZANetWorkClient.h"

@interface BaseViewController ()<ZANetWorkClientDelegate>

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [ZANetWorkClient sharedInstance].delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ZANetWorkClientDelegate

- (void)requestSuccess:(id)responObject error:(ZAError*)error tag:(NSInteger)tag
{
    
}

- (void)requestFail:(ZAError *)error tag:(NSInteger)tag
{
    
}

@end
