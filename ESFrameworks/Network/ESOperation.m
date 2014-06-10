//
//  ESOperation.m
//  Network
//
//  Created by Element on 2014. 6. 9..
//  Copyright (c) 2014년 Reveal. All rights reserved.
//

#import "ESOperation.h"

@implementation ESOperation 


- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace{
    return YES;
}
-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
}

@end
