//
//  ESNetwork.m
//  Network
//
//  Created by Daehyun Kim on 2014. 6. 9..
//  Copyright (c) 2014년 Daehyun Kim. All rights reserved.
//

#import "ESNetwork.h"
#import "ESOperation.h"
#import "ESNetworkRestfulOperaton.h"

@implementation ESNetwork

static ESNetwork *instance = nil;


-(id)init {
    if (self = [super init] ) {
        self.operationQueue = [[NSOperationQueue alloc] init];
        [self.operationQueue setMaxConcurrentOperationCount:MAX_CONCURRENT_OPERATION_COOUNT];
    }
    return  self;
}
+(ESNetwork *) sharedInstance {
    @synchronized (self) {
        if (instance == nil) {
            instance = [[ESNetwork alloc] init];
            

        }
    }
    return instance;
}

+(void)releaseSharedInstance {
    @synchronized (self) {
        instance = nil;
    }
}

-(void)sendRequestRestful:(ESNETWORK_RESTFUL_METHOD)method withUrl:(NSString *)url withParams:(NSDictionary *)params withTarget:(id<ESNetworkReceiveProtocol>)target withRef:(id)ref {
    [self sendRequestRestful:method withUrl:url withParams:params withTarget:target willShowRetryAlert:NO withRef:ref];
}

-(void)sendRequestRestful:(ESNETWORK_RESTFUL_METHOD)method withUrl:(NSString *)url withParams:(NSDictionary *)params withTarget:(id<ESNetworkReceiveProtocol>)target {
    [self sendRequestRestful:method withUrl:url withParams:params withTarget:target willShowRetryAlert:NO withRef:nil];
}

-(void)sendRequestRestful:(ESNETWORK_RESTFUL_METHOD)method withUrl:(NSString *)url withParams:(NSDictionary *)params withTarget:(id<ESNetworkReceiveProtocol>)target willShowRetryAlert:(BOOL)willShow withRef:(id)ref {
    
    ESNetworkRestfulOperaton *operation = [[ESNetworkRestfulOperaton alloc] init];
    [operation setWillShowAlert:willShow];
    [operation setUrl:url];
    [operation setParams:params];
    [operation setRef:ref];
    
    [operation setTarget:target];
    [operation setManager:self];
    [operation setAction:@selector(didFinishOperationWithResult:)];
    [self.operationQueue addOperation:operation];
}

-(void)didFinishOperationWithResult:(ESOperation *)result {
    ESOperation *operation = result;
    if (operation.error != nil && operation.retryCount < MAX_RETRY_COUNT) {
        NSLog(@"NETWORK REQUEST ERROR : %@ \n AUTO RETRY COUNT : %d", operation.error, operation.retryCount);
        [self.operationQueue addOperation:operation];
    } else if (operation.error != nil && operation.retryCount >= MAX_RETRY_COUNT) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:[NSString stringWithFormat:@"Error Code : %d\n Error Message : %@", operation.error.code, operation.error.localizedDescription] delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"Retry", nil];
        
        [alert show];
    }else if (operation.error == nil && operation.result != nil) {
        if ([operation.target respondsToSelector:@selector(didReceiveRequest:withResult:withError:withRef:)]) {
            [operation.target didReceiveRequest:operation.url withResult:operation.result withError:operation.error withRef:operation.ref];
        }
    }
}

@end
