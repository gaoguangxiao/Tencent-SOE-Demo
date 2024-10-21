//
//  TableViewController.m
//  TAIDemo
//
//  Created by kennethmiao on 2019/1/17.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//

#import "TableViewController.h"
#import <GXSwiftNetwork-Swift.h>
#import "OralEvaluationViewController.h"
@interface TableViewController ()
@property (nonatomic, strong) NSMutableArray *tabs;
@end

@implementation TabInfo
@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = [NSString stringWithFormat:@"SOE Demo"];
    _tabs = [NSMutableArray array];
    
    TabInfo *info = [[TabInfo alloc] init];
    info.title = @"用户信息";
    info.className = @"ConfigViewController";
    [_tabs addObject:info];
    
    TabInfo *oral = [[TabInfo alloc] init];
    oral.title = @"口语评测V1";
    oral.classVersion = 1;
    oral.className = @"OralEvaluationViewController";
    [_tabs addObject:oral];
    
    TabInfo *oralv2 = [[TabInfo alloc] init];
    oralv2.title = @"口语评测V2";
    oralv2.className = @"OralEvaluationViewController";
    oralv2.classVersion = 2;
    [_tabs addObject:oralv2];
    
    //token信息
    [MSBApiConfig.shared setApiConfigWithApiHost:@"https://gateway-test.risekid.cn"
                                   commonHeaders:@{@"token":@"Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJCYXpoZkIxMCIsInV1aWQiOiI1ZDg2YThmYjhlNzU0YjVjOTlmZTQxOGViZjc3M2U0MCIsInRpbWVzdGFtcCI6MTcyODU0NjA1Njc5N30.IBJsvTBN7XyOMEHZEGkbQj_YH5kuHDpBpKYNCWI0xPR_-HrnuC0YdFLzP98tvvqS6MH6u3FlTsUSdxr8LdtTrg"}
                             isAddDefaultHeaders:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    UIInterfaceOrientation curOrt = [UIApplication sharedApplication].statusBarOrientation;
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tabs.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
    }
    TabInfo *tab = _tabs[indexPath.row];
    cell.textLabel.text = tab.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TabInfo *tab = _tabs[indexPath.row];
    UIViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:tab.className];
    if ([controller isKindOfClass:OralEvaluationViewController.class]) {
        OralEvaluationViewController *oralVc = (OralEvaluationViewController *)controller;
        oralVc.classVersion = tab.classVersion;
    }
    [self.navigationController pushViewController:controller animated:YES];
    
}
@end
