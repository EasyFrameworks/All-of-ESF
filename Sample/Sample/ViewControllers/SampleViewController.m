//
//  SampleViewController.m
//  Sample
//
//  Created by Daehyun Kim on 2014. 6. 10..
//  Copyright (c) 2014년 DaehyunKim. All rights reserved.
//

#import "SampleViewController.h"
#import "ESNetwork.h"

#define SampleList @[@"Network Sample", @"ImageView Sample", @"GridView Sample"]

@implementation SampleViewController

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    UIViewController *vc;
    switch (indexPath.row) {
        case 0:
            vc = [sb instantiateViewControllerWithIdentifier:@"ESNetworkViewController"];
            break;
        case 1:
            vc = [sb instantiateViewControllerWithIdentifier:@"ESImageSampleViewController"];
            break;
            
        case 2:
            vc = [sb instantiateViewControllerWithIdentifier:@"ESGridViewController"];
            break;
            
        default:
            break;
    }
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark -
#pragma mark - UITableView DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [SampleList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL"];
    }
    
    [[cell textLabel] setText:[SampleList objectAtIndex:indexPath.row]];
    
    return cell;
}

@end
