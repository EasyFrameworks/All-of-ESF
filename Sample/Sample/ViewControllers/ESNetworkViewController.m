//
//  ESNetworkViewController.m
//  Sample
//
//  Created by Daehyun Kim on 2014. 6. 10..
//  Copyright (c) 2014년 DaehyunKim. All rights reserved.
//

#import "ESNetworkViewController.h"

@interface ESNetworkViewController ()

@end

@implementation ESNetworkViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[ESNetwork sharedInstance] sendRequestRestful:ESNETWORK_RESTFUL_GET withUrl:@"http://echo.jsontest.com/key/value/one/two" withParams:nil withTarget:self withRef:@"ref"];

    // Do any additional setup after loading the view.
}

-(void)didReceiveRequest:(NSString *)url withResult:(id)result withError:(NSError *)error  withRef:(id)ref {
    if (error != nil) {
        NSLog(@"error : %@", error);
    } else {
        NSLog(@"\nURL : %@\nRef : %@\nresult : %@", url, ref ,result);
    }
}

@end
