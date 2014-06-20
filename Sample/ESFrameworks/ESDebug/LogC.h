//
//  LogC.h
//  Sample
//
//  Created by Element on 2014. 6. 11..
//  Copyright (c) 2014년 DaehyunKim. All rights reserved.
//

#ifndef __Sample__LogC__
#define __Sample__LogC__

#include <iostream>
class Log {
public:
    static void d(char* format,...) {
        va_list argumentList;
        va_start(argumentList, format);
        printf("%s", argumentList);
        va_end(argumentList);
    };
};

#endif /* defined(__Sample__LogC__) */
