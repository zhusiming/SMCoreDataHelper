//
//  ViewController.m
//  SMCoreDataHelper
//
//  Created by 朱思明 on 16/7/1.
//  Copyright © 2016年 朱思明. All rights reserved.
//

#import "ViewController.h"
#import "Student.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 初始化数据操作对象单利
    _coreDataHelper = [SMCoreDataHelper shareSMCoreDataHelper];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)deleteAction:(id)sender {
    // 删除数据
    /*
    BOOL isOK = [_coreDataHelper deleteDataWithModelName:@"Student" predicateString:@"self.name like '*张*'"];
    NSLog(@"删除%@",isOK == YES ? @"成功" : @"失败");
     */
    
    [_coreDataHelper asyncDeleteDataWithModelName:@"Student" predicateString:@"self.name like '*张*'" didFinishBlock:^(BOOL isOK, NSArray *result) {
         NSLog(@"删除%@",isOK == YES ? @"成功" : @"失败");
    }];
}

- (IBAction)insertAction:(id)sender {
    /*
     Student *stu = [NSEntityDescription insertNewObjectForEntityForName:@"" inManagedObjectContext:_coreDataHelper.managedObjectContext];
     stu.stu_id = @123456;
     stu.name = @"张三";
     stu.context = @"描述";
     
     if ([_coreDataHelper.managedObjectContext save:nil]) {
     NSLog(@"保存成功");
     } else {
     NSLog(@"保存失败");
     }
     */
    
    /*
    NSDictionary *params = @{@"sut_id":@123456,@"name":@"张三",@"context":@"描述"};
    BOOL isOK = [_coreDataHelper insertDataWithModelName:@"Student" setAttributWithDic:params];
    NSLog(@"保存%@",isOK == YES ? @"成功" : @"失败");
     */
    
    NSDictionary *params = @{@"sut_id":@123456,@"name":@"张三",@"context":@"描述"};
    [_coreDataHelper asyncInsertDataWithModelName:@"Student" setAttributWithDic:params didFinishBlock:^(BOOL isOK, NSArray *result) {
        NSLog(@"保存%@",isOK == YES ? @"成功" : @"失败");

    }];
}

- (IBAction)updateAction:(id)sender {
    /*
    BOOL isOK = [_coreDataHelper updateDataWithModelName:@"Student" predicateString:@"self.name like '*张*'" setAttributWithDic:@{@"context":@"修改了12"}];
     NSLog(@"修改%@",isOK == YES ? @"成功" : @"失败");
     */
    
    [_coreDataHelper asyncUpdateDataWithModelName:@"Student" predicateString:@"self.name like '*张*'" setAttributWithDic:@{@"context":@"修改了11"} didFinishBlock:^(BOOL isOK, NSArray *result) {
        NSLog(@"修改%@",isOK == YES ? @"成功" : @"失败");
    }];
    
}

- (IBAction)selectedAction:(id)sender {
//    NSArray *result = [_coreDataHelper selectDataWithModelName:@"Student" predicateString:@"self.name like '*张*'" sort:nil ascending:NO];
//    NSLog(@"result:%@",result);
    
    [_coreDataHelper asyncSelectDataWithModelName:@"Student" predicateString:@"self.name like '*张*'" sort:nil ascending:YES didFinishBlock:^(BOOL isOK, NSArray *result) {
        NSLog(@"result:%@",result);
    }];
}
@end
