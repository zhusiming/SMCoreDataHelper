//
//  SMCoreDataHelper.h
//  zsm
//
//  Created by zsm on 14-04-21.
//  Copyright (c) 2014年 zsm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// 本地文件存储的路径
#define PATH [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/sqlite.db"]

#define MODEL_NAME @"MyModel"

typedef void(^DidFinishBlock)(BOOL isOK,NSArray *result);

@interface SMCoreDataHelper : NSObject

// 1.数据模型对象
@property (nonatomic ,strong) NSManagedObjectModel *managedObjectModel;
    
// 2.创建本地持久文件对象
@property (nonatomic ,strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
    
// 3.管理数据对象
@property (nonatomic ,strong) NSManagedObjectContext *managedObjectContext;


// 设计成单例模式
+ (SMCoreDataHelper *)shareSMCoreDataHelper;

// 把数据转换成model原型对象
- (id)getModelWithModelName:(NSString *)modelName
         setAttributWithDic:(NSDictionary *)params;

// 异步添加数据的方法
- (void)asyncInsertDataWithModelName:(NSString *)modelName
             setAttributWithDic:(NSDictionary *)params didFinishBlock:(DidFinishBlock)finishBlock;

// 添加数据的方法
- (BOOL)insertDataWithModelName:(NSString *)modelName
          setAttributWithDic:(NSDictionary *)params;

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
                           ascending:(BOOL)ascending;

// 异步查看
- (void)asyncSelectDataWithModelName:(NSString *)modelName
                     predicateString:(NSString *)predicateString
                                sort:(NSArray *)identifers
                           ascending:(BOOL)ascending
                      didFinishBlock:(DidFinishBlock)finishBlock;

// 修改
- (BOOL)updateDataWithModelName:(NSString *)modelName
                predicateString:(NSString *)predicateString
             setAttributWithDic:(NSDictionary *)params;

// 异步修改
- (void)asyncUpdateDataWithModelName:(NSString *)modelName
                     predicateString:(NSString *)predicateString
                  setAttributWithDic:(NSDictionary *)params
                      didFinishBlock:(DidFinishBlock)finishBlock;

// 删除
- (BOOL)deleteDataWithModelName:(NSString *)modelName
                predicateString:(NSString *)predicateString;

// 异步删除
- (void)asyncDeleteDataWithModelName:(NSString *)modelName
                     predicateString:(NSString *)predicateString
                      didFinishBlock:(DidFinishBlock)finishBlock;










@end
