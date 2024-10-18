//
//  ConfigFileViewController.m
//  demo
//
//  Created by 高广校 on 2024/10/18.
//

#import "ConfigFileViewController.h"
#import <demo-Swift.h>

@interface ConfigFileViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ConfigFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _textView.text = AudioFileTool.share.orignTxt;    
}

- (IBAction)clear:(id)sender {
}

- (IBAction)save:(id)sender {
    //对粘贴的文本进行截取
    [AudioFileTool.share saveTxtWithTxt:_textView.text];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    self.isSaveAudios();
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
