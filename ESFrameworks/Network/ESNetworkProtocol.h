//
//  ESNetworkProtocol.h
//  Network
//
//  Created by Element on 2014. 6. 9..
//  Copyright (c) 2014년 Reveal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESNetworkConfig.h"
#import "ESNetworkReceiveProtocol.h"

@protocol ESNetworkProtocol <NSObject>

-(void)sendRequestRestful:(ESNETWORK_RESTFUL_METHOD) method
                  withUrl:(NSString *) url
               withParams:(NSDictionary *) params
               withTarget:(id<ESNetworkReceiveProtocol>) target;

-(void)sendRequestRestful:(ESNETWORK_RESTFUL_METHOD) method
                  withUrl:(NSString *) url
               withParams:(NSDictionary *) params
               withTarget:(id<ESNetworkReceiveProtocol>) target
       willShowRetryAlert:(BOOL)willShow;

@end
