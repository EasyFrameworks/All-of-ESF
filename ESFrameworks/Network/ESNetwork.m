//
//  ESNetwork.m
//  Network
//
//  Created by Element on 2014. 6. 9..
//  Copyright (c) 2014년 Reveal. All rights reserved.
//

#import "ESNetwork.h"
#import "ESOperation.h"
#import "ESNetworkRestfulOperaton.h"

#define MAX_CONCURRENT_OPERATION_COOUNT 5   // 한번에 실행할 수 있는 오퍼레이션 수
#define AVERAGE_REQUEST_WAIT_TIME       1  // 리퀘스트 하나에 대해서 10초 기다려 줌
#define MAX_RETRY_COUNT                 2

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

-(void)sendRequestRestful:(ESNETWORK_RESTFUL_METHOD)method withUrl:(NSString *)url withParams:(NSDictionary *)params withTarget:(id<ESNetworkReceiveProtocol>)target {
    [self sendRequestRestful:method withUrl:url withParams:params withTarget:target willShowRetryAlert:NO];
}

-(void)sendRequestRestful:(ESNETWORK_RESTFUL_METHOD)method withUrl:(NSString *)url withParams:(NSDictionary *)params withTarget:(id<ESNetworkReceiveProtocol>)target willShowRetryAlert:(BOOL)willShow {
    
    ESNetworkRestfulOperaton *operation = [[ESNetworkRestfulOperaton alloc] init];
    [operation setWillShowAlert:willShow];
    [operation setUrl:url];
    [operation setParams:params];
    
    [operation setTarget:target];
    [operation setManager:self];
    [operation setAction:@selector(didFinishOperationWithResult:)];
    [self.operationQueue addOperation:operation];
}

-(void)didFinishOperationWithResult:(ESOperation *)result {
    ESOperation *oper = result;
    if (oper.error != nil && oper.retryCount < MAX_RETRY_COUNT) {
        NSLog(@"NETWORK REQUEST ERROR : %@ \n AUTO RETRY COUNT : %d", oper.error, oper.retryCount);
        [self.operationQueue addOperation:oper];
    } else if (oper.error != nil && oper.retryCount >= MAX_RETRY_COUNT) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:[NSString stringWithFormat:@"Error Code : %d\n Error Message : %@", oper.error.code, oper.error.localizedDescription] delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"Retry", nil];
        
        [alert show];
    }else if (oper.error == nil && oper.result != nil) {
        if ([oper.target respondsToSelector:@selector(didReceiveRequest:withResult:withError:)]) {
            [oper.target didReceiveRequest:oper.url withResult:oper.result withError:oper.error];
        }
    }
}

@end
