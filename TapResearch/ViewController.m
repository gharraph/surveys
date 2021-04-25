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

@synthesize apiRequest;

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didComeFromBackground) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self checkForSurvey];
    
}

- (void)checkForSurvey {
    NSURLComponents *urlCompenent = [[NSURLComponents alloc] initWithString:@"https://www.tapresearch.com/supply_api/surveys/offer"];
    
    urlCompenent.queryItems = [NSArray arrayWithObjects:
                               [NSURLQueryItem queryItemWithName:@"device_identifier" value:@"IDFA"],
                               [NSURLQueryItem queryItemWithName:@"api_token" value:@"f47e5ce81688efee79df771e9f9e9994"],
                               [NSURLQueryItem queryItemWithName:@"user_identifier" value:@"codetest123"], nil];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    apiRequest = [[NSMutableURLRequest alloc] initWithURL:urlCompenent.URL];
    apiRequest.HTTPMethod = @"POST";
    
    
    [[session dataTaskWithRequest:apiRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
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
                [self alertWithSurveyUnavailable];
            }
        }
    }]
     resume];
}


- (void)alertWithSurveyUnavailable {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *successAlert = [UIAlertController alertControllerWithTitle:@"no Survey Available." message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Okay", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self.navigationController popViewControllerAnimated:self];
        }];
        
        [successAlert addAction:okAction];
        [self presentViewController:successAlert animated:YES completion:nil];
    });
}


-(void)didComeFromBackground {
    NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:apiRequest];
    NSHTTPURLResponse *httpCacheResponse = (NSHTTPURLResponse *)cachedResponse.response;
    
    NSString *responseDateString = [httpCacheResponse valueForHTTPHeaderField:@"Date"];
    NSString *responseDateStringTrimmed = [[responseDateString componentsSeparatedByString:@","] objectAtIndex:1];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM yyyy HH:mm:ss zzz"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"GMT"]];
    NSDate *responseDate = [dateFormatter dateFromString: responseDateStringTrimmed];
    NSDate *thirtySecondsOldResponseDate = [responseDate dateByAddingTimeInterval:30];
    NSDate *currentDate = [NSDate date];
    
    if ([currentDate compare:thirtySecondsOldResponseDate] == NSOrderedDescending) {
        // currentDate is later than thirtySecondsOldResponse
        [self checkForSurvey];
    }
}


@end
