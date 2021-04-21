//
//  ViewController.m
//  TapResearch
//
//  Created by Sherief Gharraph on 4/21/21.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.apple.com"]];
    
    [_webView loadRequest:request];
}


@end
