//
//  ESNetwork.h
//  Network
//
//  Created by Element on 2014. 6. 9..
//  Copyright (c) 2014년 Reveal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESNetworkConfig.h"
#import "ESNetworkProtocol.h"

@interface ESNetwork : NSObject <ESNetworkProtocol> {
 }

@property (strong) NSOperationQueue *operationQueue;

+(ESNetwork *) sharedInstance;
+(void)releaseSharedInstance;

@end
