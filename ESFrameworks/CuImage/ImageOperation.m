//
//  ImageLoadOperation.m
//  gridview
//
//  Created by Element on 13. 3. 29..
//  Copyright (c) 2013년 Element. All rights reserved.
//

#import "ImageOperation.h"
#import "CuImageView.h"

@implementation ImageOperation

+ (id)operationManager:(id)theManager
            withAction:(SEL)theAction
            withTarget:(id)theTarget
               withRef:(NSString*)theImageRef
 withImageOprationType:(CuImageType)imageType
              withSize:(CGSize)size
          isImageCache:(BOOL)isImageCache
           withContext:(id)context{

    ImageOperation *operation;
    switch (imageType) {
        case CuImageTypeOriginal:
            operation = [[ImageLoadOperation alloc] initWithManager:theManager
                                                         withAction:theAction
                                                         withTarget:theTarget
                                                            withRef:theImageRef
                                              withImageOprationType:imageType
                                                           withSize:size
                                                       isImageCache:isImageCache
                                                        withContext:context];
            break;
            
        case CuImageTypeSpecificalSize:
        case CuImageTypeResizeThumbNail:
        case CuImageTypeResize50Percent:
        case CuImageTypeResize25Percent:
            operation = [[ImageResizeOperation alloc] initWithManager:theManager
                                                           withAction:theAction
                                                           withTarget:theTarget
                                                              withRef:theImageRef
                                                withImageOprationType:imageType
                                                             withSize:size
                                                         isImageCache:isImageCache
                                                          withContext:context];
            break;
        default:
            break;
    }
    
    return operation;
}

- (id)initWithManager:(id)theManager
           withAction:(SEL)theAction
           withTarget:(id)theTarget
              withRef:(NSString*)theImageRef
withImageOprationType:(CuImageType)imageType
             withSize:(CGSize)size
         isImageCache:(BOOL)isImageCache
          withContext:(id)context {
    
    if (self = [super init]) {
        self.manager = theManager;
        self.action = theAction;
        self.target = theTarget;
        self.imageRef = theImageRef;
        self.imageType = imageType;
        self.size = size;
        self.isImageCache = isImageCache;
        self.createdTime = [NSDate date];
        self.context = context;

        
    }
    return self;
}



- (void)cancel {
    
    [super cancel];
}

- (void)main {
    
    if (!self.target || [self isCancelled]) {
        [self cancel];
        return;
    }

    if (NSOrderedAscending == [self.createdTime compare:[[NSUserDefaults standardUserDefaults] valueForKey:@"OperationCancelTime"]]) {
        [self cancel];
    }

}

//-(UIImage*)getImageFromImageRef:(NSString *)imageRef error:(NSError **)error {
//    NSString *urlString = (__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(NULL,
//                                                                                           (__bridge CFStringRef)imageRef,
//                                                                                           NULL,
//                                                                                           (__bridge CFStringRef)@"\";@&+,#[]{} ",
//                                                                                           kCFStringEncodingUTF8);
//
//    NSData *imageData;
//    NSURL *url = [NSURL URLWithString:urlString];
//    if (imageRef) {
//        imageData = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:error];
//    }
//    return [UIImage imageWithData:imageData];   
//}

-(NSData*)getImageFromImageRef:(NSString *)imageRef error:(NSError **)error {
    
    AddNetLogstr(imageRef, @"Image Get URL");

    NSURL *url = nil;
    if([CommonUtil isHttpSchemeUrl:imageRef] == YES)
        url = [NSURL URLWithString:imageRef];
    else
        url = [NSURL fileURLWithPath:imageRef isDirectory:NO];

    NSData *imageData;
    if (imageRef) {
        imageData = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedAlways error:error];
#ifdef APP_OPTION_AutoConversionPDFInManager
        imageData = [[ImageManager shareInstance] checkAndMakePngFromPDF:imageData];
#endif
    }
    return imageData;
}

-(UIImage*)resizingImage:(UIImage*)originalImage withSize:(CGSize)size withResizeQulity:(CuImageResizeQulity)resizeQulity {
    if(originalImage == nil) return nil;
    
    float scale = [[UIScreen mainScreen] respondsToSelector:@selector(scale)]?[[UIScreen mainScreen] scale]:1.0f;
    
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, size.width * scale, size.height * scale));
    
    CGImageRef imageRef = CGImageCreateCopy(originalImage.CGImage);
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));
    CGContextConcatCTM(bitmap, CGAffineTransformIdentity);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, resizeQulity);
    
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    
    //    UIImage *newImage = [UIImage imageWithData:data];
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:1.0f orientation:UIImageOrientationUp];
    
    // Clean up
    CGImageRelease(imageRef);
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    return newImage;
}


@end

@implementation ImageLoadOperation

- (void)main {

    [super main];
    if (!self.target || [self isCancelled]) {
        [self cancel];
        return;
    }
    
    if ([self.target isKindOfClass:[CuImageView class]]) {
        CuImageView *temp = self.target;
        if (temp.imageRef != self.imageRef) {
            return;
        }
    }

    NSError *error;
    
    NSData *imageData = [self getImageFromImageRef:self.imageRef error:&error];
    UIImage *image = [UIImage imageWithData:imageData];
    
    NSDictionary *result =  @{@"!target":self.target,
                              @"!imageRef":self.imageRef,
                              @"!imageType":[NSString stringWithFormat:@"%d",self.imageType],
                              @"!imageSize":[NSValue valueWithCGSize:image.size],
                              @"!isImageCache":[NSNumber numberWithBool:self.isImageCache],
                              @"!error":error?error:[NSNull null],
                              @"!imageData":imageData?imageData:[NSData data],
                              @"!context":self.context?self.context:@""};
    if ([self.manager respondsToSelector:self.action]) {
        //[self.manager performSelectorOnMainThread:self.action withObject:result waitUntilDone:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.manager performSelector:self.action withObject:result withObject:self.context];
        });
    }
}

@end

@implementation ImageResizeOperation

+(id)ResizeOperationManager:(id)theManager
                 withAction:(SEL)theAction
                 withTarget:(id)theTarget
                    withRef:(NSString *)theImageRef
      withImageOprationType:(CuImageType)imageType
          withOriginalImage:(UIImage *)originalImage
                   withSize:(CGSize)size
           withResizeQulity:(CuImageResizeQulity)resizeQulity
               isImageCache:(BOOL)isImageCache
                withContext:(id)context {
    
    ImageResizeOperation *operation = [[ImageResizeOperation alloc] initWithManager:theManager withAction:theAction withTarget:theTarget withRef:theImageRef withImageOprationType:imageType withSize:size isImageCache:isImageCache withContext:context];
    operation.originalImage = originalImage;
    operation.resizeQulity = resizeQulity;
    operation.size = size;
    return operation;
    
}

- (void)main {
    [super main];
    
    if (!self.target || [self isCancelled]) {
        [self cancel];
        return;
    }

    if ([self.target isKindOfClass:[CuImageView class]]) {
        CuImageView *temp = self.target;
        if (temp.imageRef != self.imageRef) {
            return;
        }
    }

    NSError *error;
    UIImage *resizedImage;
    NSData *imageData;
    if (!self.originalImage) {
        
        imageData = [self getImageFromImageRef:self.imageRef error:&error];
        self.originalImage = [UIImage imageWithData:imageData];
        
        NSDictionary *result =  @{@"!target":[NSNull null],
                                  @"!imageRef":self.imageRef?self.imageRef:@"",
                                  @"!imageType":[NSString stringWithFormat:@"%d",CuImageTypeOriginal],
                                  @"!imageSize":[NSValue valueWithCGSize:self.originalImage?self.originalImage.size:self.size],
                                  @"!isImageCache":[NSNumber numberWithBool:YES],
                                  @"!error":error?error:[NSNull null],
                                  @"!imageData":imageData?imageData:[NSData data],
                                  @"!context":self.context?self.context:@""};
    if ([self.manager respondsToSelector:self.action])
//        [self.manager performSelectorOnMainThread:self.action withObject:result waitUntilDone:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.manager performSelector:self.action withObject:result withObject:self.context];
        });
    } else {
    }
    resizedImage = [self resizingImage:self.originalImage withSize:self.size withResizeQulity:self.resizeQulity];
    
    NSData *data = UIImagePNGRepresentation(resizedImage);

    NSDictionary *result =  @{@"!target":self.target?self.target:[NSNull null],
                              @"!imageRef":self.imageRef?self.imageRef:@"",
                              @"!imageType":[NSString stringWithFormat:@"%d",self.imageType],
                              @"!imageSize":[NSValue valueWithCGSize:resizedImage.size],
                              @"!isImageCache":[NSNumber numberWithBool:self.isImageCache],
                              @"!error":error?error:[NSNull null],
                              @"!imageData":data?data:@"",
                              @"!context":self.context?self.context:@"",
                              @"!resizeQulity":[NSString stringWithFormat:@"%d", self.resizeQulity]};

    if ([self.manager respondsToSelector:self.action]) {
//        [self.manager performSelectorOnMainThread:self.action withObject:result waitUntilDone:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.manager performSelector:self.action withObject:result withObject:self.context];
        });
    }


}


@end


@implementation ImageOperationWithBlock

//+ (id)operationWithBlockManager:(id)theManager
//                     withAction:(SEL)theAction
//                     withTarget:(id)theTarget
//                        withRef:(NSString*)theImageRef
//          withImageOprationType:(CuImageType)imageType
//              withOriginalImage:(UIImage*)originalImage
//                       withSize:(CGSize)size
//               withResizeQulity:(CuImageResizeQulity)resizeQulity
//                   isImageCache:(BOOL)isImageCache
//                    withContext:(id)context {
//    
//    _block;
//}

-(void)blockTest:(void (^)(UIImage *, NSError *, BOOL))block {

}

@end