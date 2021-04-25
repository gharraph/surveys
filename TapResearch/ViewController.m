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


- (void)checkForSurvey {
    NSURLComponents *urlCompenent = [[NSURLComponents alloc] initWithString:@"https://www.tapresearch.com/supply_api/surveys/offer"];
    
    urlCompenent.queryItems = [NSArray arrayWithObjects:
                               [NSURLQueryItem queryItemWithName:@"device_identifier" value:@"IDFA"],
                               [NSURLQueryItem queryItemWithName:@"api_token" value:@"f47e5ce81688efee79df771e9f9e9994"],
                               [NSURLQueryItem queryItemWithName:@"user_identifier" value:@"codetest123"], nil];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:urlCompenent.URL];
    request.HTTPMethod = @"POST";
    
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        } else if (data) {
            id jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@", jsonResponse);
            BOOL isSurveyAvailable = jsonResponse[@"has_offer"];
            if (isSurveyAvailable) {
                NSString *offerURL = jsonResponse[@"offer_url"];
                NSURLRequest *offerRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:offerURL]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->_webView loadRequest:offerRequest];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *successAlert = [UIAlertController alertControllerWithTitle:@"no Survey Available." message:@"" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Okay", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                        [self.navigationController popViewControllerAnimated:self];
                    }];
                    
                    [successAlert addAction:okAction];
                    [self presentViewController:successAlert animated:YES completion:nil];
                });
            }
        }
    }]
     resume];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self checkForSurvey];
}


@end
