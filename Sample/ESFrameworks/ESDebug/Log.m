//
//  Log.m
//  Sample
//
//  Created by Element on 2014. 6. 11..
//  Copyright (c) 2014년 DaehyunKim. All rights reserved.
//

#import "Log.h"
#define DLog(format, ...)		NSLog( @"%@", [NSString stringWithFormat:format, ## __VA_ARGS__]);

@implementation Log
//+(void)d:(NSString *)format, ... {
//
//NSLog(@"d %@", [NSString stringWithFormat:format, ## __VA_ARGS__]);
//}
static void d(NSString *format,...) {
    va_list argumentList;
    va_start(argumentList, format);
    
    NSLogv(@"%@", argumentList);
    va_end(argumentList);
}

@end
