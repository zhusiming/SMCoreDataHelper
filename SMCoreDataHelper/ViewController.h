//
//  ViewController.h
//  SMCoreDataHelper
//
//  Created by 朱思明 on 16/7/1.
//  Copyright © 2016年 朱思明. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMCoreDataHelper.h"

@interface ViewController : UIViewController
{
    SMCoreDataHelper *_coreDataHelper;
}

- (IBAction)deleteAction:(id)sender;

- (IBAction)insertAction:(id)sender;

- (IBAction)updateAction:(id)sender;

- (IBAction)selectedAction:(id)sender;

@end

