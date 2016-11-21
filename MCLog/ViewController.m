//
//  ViewController.m
//  MCLog
//
//  Created by 常峻玮 on 16/11/16.
//  Copyright © 2016年 Mingle. All rights reserved.
//

#import "ViewController.h"
#import "MCLog.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [MCLogManager logContent:@"test" subContent:@"subtest" type:0 subType:20 userInfo:@{@"key":@"value"} line:__LINE__ function:__PRETTY_FUNCTION__ file:__FILE__];
    
//    MCLogMacro(0, 0, @{@"key":@"value"},@"test1");
//    MCLogDebug(@"Test%@",@"debug");
    // Do any additional setup after loading the view, typically from a nib.
//    NSLog(@"Begin");
//    for (int i = 0; i<100; i++) {
//        MCLogModel *lModel=[[MCLogModel alloc]init];
//        lModel.content=[NSString stringWithFormat:@"test%d",i];
//        lModel.subType=i;
//        [[MCLogManager manager] insertOrReplaceLogModel:lModel complete:^(NSError *error) {
//            NSLog(@"SQL:%i",i);
//        }];
//    }
//    NSLog(@"END");
    
//    [[MCLogManager manager] selectAllLogModelComplete:^(NSError *error, NSArray *array) {
//        NSLog(@"%@",array);
//    }];
    
    NSArray *lArray=@[];
    NSString *lString = lArray[0];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
