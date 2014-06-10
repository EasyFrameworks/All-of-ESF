//
//  ESNetworkReceiveProtocol.h
//  Network
//
//  Created by Element on 2014. 6. 9..
//  Copyright (c) 2014년 Reveal. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ESNetworkReceiveProtocol <NSObject>

-(void)didReceiveRequest:(NSString *) url withResult:(NSObject *)result withError:(NSError *)error;

@end