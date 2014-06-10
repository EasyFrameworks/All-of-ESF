//
//  ESGridViewController.h
//  Sample
//
//  Created by Daehyun on 2014. 6. 10..
//  Copyright (c) 2014년 DaehyunKim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESGridView.h"

@interface ESGridViewController : UIViewController <ESGridViewDataSource, ESGridViewDelegate> {
    IBOutlet UIView *_container;
}

@end
