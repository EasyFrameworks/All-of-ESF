//
//  ESImageSampleViewController.m
//  Sample
//
//  Created by Daehyun Kim on 2014. 6. 10..
//  Copyright (c) 2014년 DaehyunKim. All rights reserved.
//

#import "ESImageSampleViewController.h"
#import "ESImageView.h"

#define ImageList @[@"http://tv01.search.naver.net/ugc?t=252x448&q=http://dbscthumb.phinf.naver.net/2765_000_101/20131024013642846_TBJRQDPQO.jpg/1295901.jpg?type=m4500_4500_fst", @"http://tv02.search.naver.net/ugc?t=252x448&q=http://cafefiles.naver.net/20131227_145/rkdgpals99_1388141296402mKt1g_JPEG/409795754.jpg",@"http://tv02.search.naver.net/ugc?t=252x448&q=http://cafefiles.naver.net/20131227_145/rkdgpals99_1388141296402mKt1g_JPEG/409795754.jpg",@"http://tv02.search.naver.net/ugc?t=252x448&q=http://cafefiles.naver.net/20131227_145/rkdgpals99_1388141296402mKt1g_JPEG/409795754.jpg",@"http://tv02.search.naver.net/ugc?t=252x448&q=http://cafefiles.naver.net/20131227_145/rkdgpals99_1388141296402mKt1g_JPEG/409795754.jpg",@"http://tv02.search.naver.net/ugc?t=252x448&q=http://cafefiles.naver.net/20131227_145/rkdgpals99_1388141296402mKt1g_JPEG/409795754.jpg"]

@implementation ESImageSampleViewController

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

#pragma mark -
#pragma mark - UITableView DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [ImageList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL"];
        ESImageView *imageView = [[ESImageView alloc] init];
        [imageView setFrame:cell.bounds];
        [imageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [imageView setTag:10];
        NSLog(@"cell.bouns ; %@", NSStringFromCGRect(cell.bounds));
        [cell addSubview:imageView];
    }
    
    ESImageView *iv = (ESImageView*)[cell viewWithTag:10];
    [iv setImageUrl:[ImageList objectAtIndex:indexPath.row] withContext:nil];
    
    return cell;
}
@end
