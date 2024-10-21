//
//  TableViewController.h
//  TAIDemo
//
//  Created by kennethmiao on 2019/1/17.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabInfo : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *className;
@property (nonatomic, assign) NSInteger classVersion;
@end

@interface TableViewController : UITableViewController

@end
