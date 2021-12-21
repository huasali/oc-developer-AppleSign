//
//  ViewController.m
//  oc-developer-AppleSign
//
//  Created by Huasali on 2021/12/21.
//

#import "ViewController.h"
#import "GNAppleSignManager.h"

@interface ViewController ()<GNAppleLogDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textview;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [GNAppleSignManager manager].delegate = self;
    // Do any additional setup after loading the view.
}
- (IBAction)loginAction:(id)sender {
    self.textview.text = @"";
    [[GNAppleSignManager manager] didAppleButton];
}
- (IBAction)logoutAction:(id)sender {
    self.textview.text = @"";
}
- (IBAction)action1:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.textview.text;
}
- (IBAction)action2:(id)sender {
    
}
- (void)didLog:(NSString *)message{
    self.textview.text = [NSString stringWithFormat:@"%@\n%@",self.textview.text,message];
    if (self.textview.contentSize.height > self.textview.frame.size.height) {
        int offset = self.textview.contentSize.height - self.textview.frame.size.height;
        [self.textview setContentOffset:CGPointMake(0, offset) animated:YES];
    }
}



@end
