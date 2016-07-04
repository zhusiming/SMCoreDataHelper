//
//  Student+CoreDataProperties.h
//  SMCoreDataHelper
//
//  Created by 朱思明 on 16/7/4.
//  Copyright © 2016年 朱思明. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Student.h"

NS_ASSUME_NONNULL_BEGIN

@interface Student (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *context;
@property (nullable, nonatomic, retain) NSNumber *stu_id;

@end

NS_ASSUME_NONNULL_END
