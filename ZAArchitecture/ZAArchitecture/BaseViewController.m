//
//  ViewController.m
//  ZAArchitecture
//
//  Created by ap2 on 16/1/7.
//  Copyright © 2016年 ap2. All rights reserved.
//

#import "BaseViewController.h"
#import "ZANetWorkClient.h"
#import "UserEntity.h"

@interface BaseViewController ()<ZANetWorkClientDelegate>

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [ZANetWorkClient sharedInstance].delegate = self;
    
    [self testDB];
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

#warning mark - DBTest
- (void)testDB
{
    UserEntity *user = [[UserEntity alloc] initWithDB];
    user.pk = 10;
    user.name = @"zhangsan";
    user.age = 20;
    user.houseCount = @(50);
    [user save];
}

@end
