//
//  SMCoreDataHelper.h
//  zsm
//
//  Created by zsm on 14-04-21.
//  Copyright (c) 2014年 zsm. All rights reserved.
//

#import "SMCoreDataHelper.h"

@implementation SMCoreDataHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // 1.数据模型对象
        NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:MODEL_NAME withExtension:@"mom"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelUrl];
        
        // 2.创建本地持久文件对象
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
        // 设置本地数据的保存位置
        NSURL *fileUrl = [NSURL fileURLWithPath:PATH];
        
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:fileUrl options:nil error:nil];
        
        // 3.管理数据对象
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:_persistentStoreCoordinator];
        
        // 创建通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    return self;
}


// 设计成单例模式
+ (SMCoreDataHelper *)shareSMCoreDataHelper
{
    static SMCoreDataHelper *coreDataHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coreDataHelper = [[SMCoreDataHelper alloc] init];
    });
    
    return coreDataHelper;
}

// 把数据转换成model原型对象
- (id)getModelWithModelName:(NSString *)modelName
         setAttributWithDic:(NSDictionary *)params
{
    NSEntityDescription *entity = [NSEntityDescription insertNewObjectForEntityForName:modelName inManagedObjectContext:_managedObjectContext];
    
    // 遍历参数字典
    for (NSString *key in params) {
        // 修改对象的属性
        for (NSString *key in params) {
            NSString *attName = key;
            if ([key isEqualToString:@"id"]) {
                // 名字序列化
                attName = [self getAttNameWithClassName:modelName];
            }
            SEL selector = [self selWithKeyName:attName];
            if ([entity respondsToSelector:selector]) {
                [entity performSelector:selector withObject:params[attName]];
            }
        }
    }
    return entity;
}

// 异步添加数据的方法
- (void)asyncInsertDataWithModelName:(NSString *)modelName
                  setAttributWithDic:(NSDictionary *)params didFinishBlock:(DidFinishBlock)finishBlock
{
    // 1.创建一个临时的数据操作对象
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.persistentStoreCoordinator = _persistentStoreCoordinator;
    
    // CoreDate为我们提供了隐士创建多线程的方法
    [context performBlock:^{
        NSEntityDescription *entity = [NSEntityDescription insertNewObjectForEntityForName:modelName inManagedObjectContext:context];
        
        // 遍历参数字典
        for (NSString *key in params) {
            // 修改对象的属性
            for (NSString *key in params) {
                NSString *attName = key;
                if ([key isEqualToString:@"id"]) {
                    // 名字序列化
                    attName = [self getAttNameWithClassName:modelName];
                }
                SEL selector = [self selWithKeyName:attName];
                if ([entity respondsToSelector:selector]) {
                    [entity performSelector:selector withObject:params[attName]];
                }
            }
        }
        [context insertObject:entity];
        
        // 保存到本地
        [context save:nil];
        
        // 回到主线程显示数据（刷新UI）
        dispatch_async(dispatch_get_main_queue(), ^{
            if (finishBlock != nil) {
                finishBlock(YES,nil);
            }
        });
    }];
}

// 添加数据的方法
/*
    params : @{ 
                  @"name":@"张三"，
                  @"age":@20
             }
 */
- (BOOL)insertDataWithModelName:(NSString *)modelName
             setAttributWithDic:(NSDictionary *)params
{
    NSEntityDescription *entity = [NSEntityDescription insertNewObjectForEntityForName:modelName inManagedObjectContext:_managedObjectContext];
    
    // 遍历参数字典
    for (NSString *key in params) {
        // 修改对象的属性
        for (NSString *key in params) {
            NSString *attName = key;
            if ([key isEqualToString:@"id"]) {
                // 名字序列化
                attName = [self getAttNameWithClassName:modelName];
            }
            SEL selector = [self selWithKeyName:attName];
            if ([entity respondsToSelector:selector]) {
                [entity performSelector:selector withObject:params[attName]];
            }
        }
    }
    [_managedObjectContext insertObject:entity];
    
    // 保存到本地
    return [_managedObjectContext save:nil];
}

// 异步查看
- (void)asyncSelectDataWithModelName:(NSString *)modelName
                     predicateString:(NSString *)predicateString
                                sort:(NSArray *)identifers
                           ascending:(BOOL)ascending
                      didFinishBlock:(DidFinishBlock)finishBlock
{
    // 1.创建一个临时的数据操作对象
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.persistentStoreCoordinator = _persistentStoreCoordinator;
    
    // CoreDate为我们提供了隐士创建多线程的方法
    [context performBlock:^{
        // 1.创建实体对象
        NSEntityDescription *entity = [NSEntityDescription entityForName:modelName inManagedObjectContext:context];
        
        // 2.创建一个查询对象
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        // 告诉查询对象你要查询的数据类型
        [request setEntity:entity];
        
        // 添加查询条件
        if (predicateString != nil || [predicateString isEqualToString:@""]) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
            [request setPredicate:predicate];
        }
        
        
        // 3.设置排序
        NSMutableArray *sortDescriptors = [NSMutableArray array];
        for (NSString *identifer in identifers) {
            // 创建排序对象
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:identifer ascending:ascending];
            // 把排序对象添加到数组中
            [sortDescriptors addObject:sortDescriptor];
        }
        // 把排序对象设置到查询对象里面
        [request setSortDescriptors:sortDescriptors];
        
        // 3.开始查询
        NSArray *result = [context executeFetchRequest:request error:nil];
        
        // 回到主线程显示数据（刷新UI）
        dispatch_async(dispatch_get_main_queue(), ^{
            if (finishBlock != nil) {
                finishBlock(YES,result);
            }
        });
    }];
}

// 查看
/*
 modelName           :实体对象类的名字
 predicateString     :谓词条件
 identifers          :排序字段集合
 ascending           :是否升序
 */
- (NSArray *)selectDataWithModelName:(NSString *)modelName
                     predicateString:(NSString *)predicateString
                                sort:(NSArray *)identifers
                           ascending:(BOOL)ascending
{
    // 1.创建实体对象
    NSEntityDescription *entity = [NSEntityDescription entityForName:modelName inManagedObjectContext:_managedObjectContext];
    
    // 2.创建一个查询对象
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    // 告诉查询对象你要查询的数据类型
    [request setEntity:entity];
    
    // 添加查询条件
    if (predicateString != nil || [predicateString isEqualToString:@""]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
        [request setPredicate:predicate];
    }
    
    
    // 3.设置排序
    NSMutableArray *sortDescriptors = [NSMutableArray array];
    for (NSString *identifer in identifers) {
        // 创建排序对象
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:identifer ascending:ascending];
        // 把排序对象添加到数组中
        [sortDescriptors addObject:sortDescriptor];
    }
    // 把排序对象设置到查询对象里面
    [request setSortDescriptors:sortDescriptors];
    
    // 3.开始查询
    NSArray *array = [_managedObjectContext executeFetchRequest:request error:nil];
    return array;
}


// 修改
- (BOOL)updateDataWithModelName:(NSString *)modelName
                predicateString:(NSString *)predicateString
             setAttributWithDic:(NSDictionary *)params
{
    // 获取所有需要修改实体对象
    NSArray *entitys = [self selectDataWithModelName:modelName predicateString:predicateString sort:nil ascending:NO];
    
    // 遍历所有的实体对象
    for (NSEntityDescription *entity in entitys) {
        // 修改对象的属性
        for (NSString *key in params) {
            // 修改对象的属性
            for (NSString *key in params) {
                NSString *attName = key;
                if ([key isEqualToString:@"id"]) {
                    // 名字序列化
                    attName = [self getAttNameWithClassName:modelName];
                }
                SEL selector = [self selWithKeyName:attName];
                if ([entity respondsToSelector:selector]) {
                    [entity performSelector:selector withObject:params[attName]];
                }
            }
        }
    }
    
    return [_managedObjectContext save:nil];
}

// 异步修改
- (void)asyncUpdateDataWithModelName:(NSString *)modelName
                     predicateString:(NSString *)predicateString
                  setAttributWithDic:(NSDictionary *)params
                      didFinishBlock:(DidFinishBlock)finishBlock
{
    // 1.创建一个临时的数据操作对象
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.persistentStoreCoordinator = _persistentStoreCoordinator;
    
    // CoreDate为我们提供了隐士创建多线程的方法
    [context performBlock:^{
        // 一、获取所有需要修改实体对象
        // 1.创建实体对象
        NSEntityDescription *entity = [NSEntityDescription entityForName:modelName inManagedObjectContext:context];
        
        // 2.创建一个查询对象
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        // 告诉查询对象你要查询的数据类型
        [request setEntity:entity];
        
        // 添加查询条件
        if (predicateString != nil || [predicateString isEqualToString:@""]) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
            [request setPredicate:predicate];
        }
        
        // 3.开始查询
        NSArray *entitys = [context executeFetchRequest:request error:nil];
        
        // 二、遍历所有的实体对象
        for (NSEntityDescription *entity in entitys) {
            // 修改对象的属性
            for (NSString *key in params) {
                NSString *attName = key;
                if ([key isEqualToString:@"id"]) {
                    // 名字序列化
                    attName = [self getAttNameWithClassName:modelName];
                }
                SEL selector = [self selWithKeyName:attName];
                if ([entity respondsToSelector:selector]) {
                    [entity performSelector:selector withObject:params[attName]];
                }
            }
        }
        
        [context save:nil];
        // 回到主线程显示数据（刷新UI）
        dispatch_async(dispatch_get_main_queue(), ^{
            if (finishBlock != nil) {
                finishBlock(YES,nil);
            }
        });
    }];

}




// 删除
- (BOOL)deleteDataWithModelName:(NSString *)modelName
                predicateString:(NSString *)predicateString
{
    // 获取所有需要修改实体对象
    NSArray *entitys = [self selectDataWithModelName:modelName predicateString:predicateString sort:nil ascending:NO];
    
    // 遍历所有的实体对象
    for (NSEntityDescription *entity in entitys) {
        // 删除对象
        [_managedObjectContext deleteObject:entity];
        
    }
    
    return [_managedObjectContext save:nil];
}

// 异步删除
- (void)asyncDeleteDataWithModelName:(NSString *)modelName
                     predicateString:(NSString *)predicateString
                      didFinishBlock:(DidFinishBlock)finishBlock
{
    // 1.创建一个临时的数据操作对象
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.persistentStoreCoordinator = _persistentStoreCoordinator;
    
    // CoreDate为我们提供了隐士创建多线程的方法
    [context performBlock:^{
        // 一、获取所有需要修改实体对象
        // 1.创建实体对象
        NSEntityDescription *entity = [NSEntityDescription entityForName:modelName inManagedObjectContext:context];
        
        // 2.创建一个查询对象
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        // 告诉查询对象你要查询的数据类型
        [request setEntity:entity];
        
        // 添加查询条件
        if (predicateString != nil || [predicateString isEqualToString:@""]) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
            [request setPredicate:predicate];
        }
        
        // 3.开始查询
        NSArray *entitys = [context executeFetchRequest:request error:nil];
        
        // 二、遍历所有的实体对象
        for (NSEntityDescription *entity in entitys) {
            // 删除对象
            [context deleteObject:entity];
            
        }
        // 保存
        [context save:nil];
        
        // 回到主线程显示数据（刷新UI）
        dispatch_async(dispatch_get_main_queue(), ^{
            if (finishBlock != nil) {
                finishBlock(YES,nil);
            }
        });
    }];
}


// 通过一个字符串反回一个set方法
- (SEL)selWithKeyName:(NSString *)keyName
{
    NSString *first = [[keyName substringToIndex:1] uppercaseString];
    NSString *end = [keyName substringFromIndex:1];
    NSString *selString = [NSString stringWithFormat:@"set%@%@:",first,end];
    return NSSelectorFromString(selString);
}

// id序列化
- (NSString *)getAttNameWithClassName:(NSString *)className
{
    NSString *first = [[className substringToIndex:1] lowercaseString];
    NSString *end = [className substringFromIndex:1];
    return [NSString stringWithFormat:@"%@%@Id",first,end];
}

#pragma mark - context保存到本地后接受到的通知
- (void)notificationDidSave:(NSNotification *)notification
{
    NSManagedObjectContext *context = notification.object;
    
    // 判断当前的context是不是是主线程的数据操作对象
    if (context == _managedObjectContext) {
        return;
    }
    
    if ([NSThread isMainThread]) {
        NSLog(@"当前是主线程");
    }else {
        NSLog(@"当前是多线程");
    }
    
    // 说明当前context是多线程里面的数据操作对象（临时操作对象）
    dispatch_async(dispatch_get_main_queue(), ^{
        // 数据的合并
        [_managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    });
    
}







@end
