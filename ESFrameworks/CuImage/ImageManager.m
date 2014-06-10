#import "ImageManager.h"
#import "ImageOperation.h"
#import "CuImageView.h"
#import <malloc/malloc.h>
#import <objc/runtime.h>
#import "CuImage.h"
#import "CuPDFViewWithZoom.h"

#define JPEG_compressionQuality COMMON_JPEGCOMPRESSIONQULITY

@implementation CacheImage

-(NSString *)description {
    
    return [NSString stringWithFormat:@"imageRef : %@, qulity : %d, size : %@, imageType : %d, refCount :%d", self.imageRef, self.qulity, NSStringFromCGSize(self.size), self.imageType, self.refCount];
}

-(UIImage *)image {
    return [UIImage imageWithData:self.imageData];
}

-(id)self {
    return (id)self.image;
}
@end

@interface ImageManager ()

@end

@implementation ImageManager
@synthesize cacheImagesList;

#pragma mark - Singleton
static ImageManager *sharedInstance;
+(ImageManager *)shareInstance {
    
    if (!sharedInstance) {
        sharedInstance = [[ImageManager alloc] init];
    }
    
    return sharedInstance;
}


#pragma mark - Initialize

-(id)init {
    if (self = [super init]) {
        
        [self initialize];
    }
    return self;
}

-(void)initialize {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    self.operationQueue = [[NSOperationQueue alloc] init];
    [self.operationQueue setMaxConcurrentOperationCount:MAX_CONCURRENT_OPERATION_COOUNT];
    
    cacheImages = [[NSMutableDictionary alloc] init];
    cacheImagesIndex = [[NSMutableArray alloc] init];
    cacheImagesList = [[NSMutableArray alloc] init];
    
    
    self.test = NO;
    //    originalImages = [[NSMutableDictionary alloc] init];
    //    originalImagesIndex = [[NSMutableArray alloc] init];
}

-(void)handleMemoryWarning:(id)sender {
    [cacheImagesList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSComparisonResult result = NSOrderedSame;
        if(((CacheImage*)obj1).refCount < ((CacheImage*)obj2).refCount)
            result = NSOrderedAscending;
        else
            result = NSOrderedDescending;
        return result;
    }];
    
    for (int i = 0; i < [cacheImagesList count] / 2; i ++) {
        [cacheImagesList removeObjectAtIndex:0];
    }
}


#pragma mark - cache methods

-(void)addCacheImageWithImageRef:(NSString *)imageRef withContext:(id)context {
    [self getImageWithRef:imageRef withTarget:self withType:CuImageTypeOriginal isImageCache:YES withContext:context];
}

#pragma mark - getters Image with ImageRef

-(BOOL)getImageWithRef:(NSString *)imageRef
            withTarget:(id)target
           withContext:(id)context {
    
    return [self getImageWithRef:imageRef
                      withTarget:target
                        withType:DEFAULT_IMAGETYPE
                     withContext:context];
}

-(BOOL)getImageWithRef:(NSString *)imageRef
            withTarget:(id)target
              withType:(CuImageType)imageType
           withContext:(id)context{
    
    return [self getImageWithRef:imageRef
                      withTarget:target
                        withType:imageType
                    isImageCache:DEFAULT_IMAGE_CACHE
                     withContext:context];
}

-(BOOL)getImageWithRef:(NSString *)imageRef
            withTarget:(id)target
              withSize:(CGSize)size
           withContext:(id)context{
    
    return [self getImageWithRef:imageRef
                      withTarget:target
                        withSize:size
                    isImageCache:DEFAULT_IMAGE_CACHE
                     withContext:context];
}

-(BOOL)getImageWithRef:(NSString*)imageRef
            withTarget:(id)target
              withType:(CuImageType)imageType
          isImageCache:(BOOL)isImageCache
           withContext:(id)context {
    
    return [self getImageWithRef:imageRef
                      withTarget:target
                        withType:imageType
                        withSize:CGSizeZero
                    isImageCache:isImageCache withContext:context];
}

-(BOOL)getImageWithRef:(NSString*)imageRef
            withTarget:(id)target
              withSize:(CGSize)size
          isImageCache:(BOOL)isImageCache
           withContext:(id)context{
    
    return [self getImageWithRef:imageRef
                      withTarget:target
                        withType:CuImageTypeSpecificalSize
                        withSize:size
                    isImageCache:isImageCache
                     withContext:context];
}

-(BOOL)getImageWithRef:(NSString*)imageRef
            withTarget:(id)target
              withType:(CuImageType)imageType
              withSize:(CGSize)size
          isImageCache:(BOOL)isImageCache
           withContext:(id)context{
    
    return [self getImageWithRef:imageRef
                      withTarget:target
                        withType:imageType
                        withSize:size
                withResizeQulity:DEFAULT_RESIZE_QULITY
                    isImageCache:isImageCache
                     withContext:context];
}

-(BOOL)getImageWithRef:(NSString *)imageRef
            withTarget:(id)target
              withType:(CuImageType)imageType
              withSize:(CGSize)size
      withResizeQulity:(CuImageResizeQulity)resizeQulity
          isImageCache:(BOOL)isImageCache
           withContext:(id)context {
    
    BOOL ret = YES;
    
    
    if (imageType == CuImageTypeLimitedOriginal && 3000 * 2000 < size.width * size.height) {
        CGFloat scale = ( size.width / 3000 ) > ( size.height / 2000 )? size.width / 3000 : size.height / 2000;
        size = CGSizeMake(size.width / scale, size.height / scale);

    }
    for (int i = 0; i < [cacheImagesList count]; i ++) {
        CacheImage *one = [cacheImagesList objectAtIndex:i];
        
        if (([one.imageRef isEqualToString:imageRef]
             && one.imageType == imageType
             && one.qulity == resizeQulity
             && (CGSizeEqualToSize(CGSizeMake(one.size.width / [[UIScreen mainScreen] scale] , one.size.height / [[UIScreen mainScreen] scale]), size)
                 || one.imageType == CuImageTypeOriginal))
            || (one.imageType == CuImageTypeLimitedOriginal
                && [one.imageRef isEqualToString:imageRef]
                && one.qulity == resizeQulity)) {
            
            if ([target respondsToSelector:@selector(imageManager:DidLoadImage:withContext:)]) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [NSThread sleepForTimeInterval:0.001];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [target imageManager:self DidLoadImage:one withContext:context];
                    });
                });

            }
            
            one.refCount++;
            [cacheImagesList replaceObjectAtIndex:i withObject:one];
            
            return ret;
        }
    }
    ImageOperation *operation;
    
    if (imageType == CuImageTypeOriginal) {
        operation = [ImageOperation operationManager:self withAction:@selector(didEndOperationWithResult:withContext:) withTarget:target withRef:imageRef withImageOprationType:imageType withSize:size isImageCache:isImageCache withContext:context];
        
    } else {
        UIImage *oriImage;
        for (CacheImage *one in cacheImagesList) {
            if (one.imageType == CuImageTypeOriginal && [one.imageRef isEqualToString:imageRef]) {
                oriImage = one.image;
            }
        }
        operation = [ImageResizeOperation ResizeOperationManager:self withAction:@selector(didEndOperationWithResult:withContext:) withTarget:target withRef:imageRef withImageOprationType:imageType withOriginalImage:oriImage withSize:size withResizeQulity:resizeQulity isImageCache:isImageCache withContext:context];
    }
    
    [self.operationQueue addOperation:operation];
    
    return ret;
}



#pragma mark - Received Image
-(void)didEndOperationWithResult:(NSDictionary *)result withContext:(id)context {
    id <ImageManagerDelegate> target = [result objectForKey:@"!target"];
    
    if(result == nil && [target isEqual:[NSNull null]]) return;
    
    NSError *error = [result objectForKey:@"!error"];
    if ([target isKindOfClass:[NSString class]]) {
        
        for (int i = 0; i < [cacheImagesList count]; i++) {
            CacheImage *one = [cacheImagesList objectAtIndex:i];
            if ([one.imageRef isEqualToString:[result objectForKey:@"!imageRef"]] && CGSizeEqualToSize(one.size, [[result objectForKey:@"!imageSize"] CGSizeValue])) {
                one.imageData = [result objectForKey:@"!imageData"];
                [cacheImagesList replaceObjectAtIndex:i withObject:one];
            }
        }
    }
    
    if ([error isKindOfClass:[NSError class]]) {

        if ([target respondsToSelector:@selector(imageManager:didFailLoadImageRef:withError:withContext:)]) {
            AddNetLogstr([result objectForKey:@"!imageRef"], @"Failed to Load Image");
            [target imageManager:self didFailLoadImageRef:[result objectForKey:@"!imageRef"] withError:[result objectForKey:@"!error"] withContext:[result objectForKey:@"!context"]];
        }
        
    } else {
        
        CuImageType imageType = [[result objectForKey:@"!imageType"] intValue];
        CuImageResizeQulity resizeQulity = [[result objectForKey:@"!resizeQulity"] intValue];
        CGSize size = [[result objectForKey:@"!imageSize"] CGSizeValue];
        NSString *imageRef = [result objectForKey:@"!imageRef"];
        BOOL isImageCache = [[result objectForKey:@"!isImageCache"] boolValue];
        NSData *imageData = [result objectForKey:@"!imageData"];
        
        CacheImage *image = [[CacheImage alloc] init];
        
        if(imageData == nil || imageData.length == 0) {
            AddNetLogstr([result objectForKey:@"!imageRef"], @"Failed to Load Image - iamge size is zero");
            if ([target respondsToSelector:@selector(imageManager:didFailLoadImageRef:withError:withContext:)]) {
                AddNetLogstr([result objectForKey:@"!imageRef"], @"Failed to Load Image");
                [target imageManager:self didFailLoadImageRef:[result objectForKey:@"!imageRef"] withError:[result objectForKey:@"!error"] withContext:[result objectForKey:@"!context"]];
            }

        }
        else {
            if (isImageCache) {
                [image setImageData:imageData];
                [image setImageType:imageType];
                [image setQulity:resizeQulity];
                [image setSize:size];
                [image setImageRef:imageRef];
                [image setRefCount:1];
                [cacheImagesList addObject:image];
            }
            else {
                [image setImageData:imageData];
                [image setImageType:imageType];
                [image setSize:size];
            }
            
            if ([target isKindOfClass:[CuImageView class]]) {
                CuImageView *temp = (CuImageView*)target;
                if (temp.imageRef != imageRef) {
                    return;
                }
            }
            
            if ([target respondsToSelector:@selector(imageManager:DidLoadImage:withContext:)]) {
                AddNetLogstr(imageRef, @"Success to Load Image");
                [target imageManager:self DidLoadImage:image withContext:[result objectForKey:@"!context"]];
            }
        }
    }
}

-(void)removeAllOperation {
    
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:@"OperationCancelTime"];
    
    //    [self.operationQueue cancelAllOperations];
    
    //    [self.operationQueue setSuspended:YES];
}

-(void)removeCacheImages {
    [cacheImagesList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSComparisonResult result = NSOrderedSame;
        if(((CacheImage*)obj1).refCount < ((CacheImage*)obj2).refCount)
            result = NSOrderedAscending;
        else
            result = NSOrderedDescending;
        return result;
    }];
    
    for (int i = 0; i < [cacheImagesList count] / 2; i ++) {
        [cacheImagesList removeObjectAtIndex:0];
    }
    
}

-(void)asynchronousImageLoadWithImageRef:(NSString *)imageRef
                               withBlock:(void(^)(NSData *imageData, NSError *error, BOOL success))block {

    
//    ImageOperationWithBlock *operation = [[ImageOperationWithBlock alloc] initWithManager:self withAction:@selector(didEndOperationWithResult:withContext:) withTarget:nil withRef:imageRef withImageOprationType:0 withSize:CGSizeZero isImageCache:YES withContext:nil];
//
//    [operation performSelector:@selector(blockTest:) withObject:block afterDelay:5];

    for (int i = 0; i < [cacheImagesList count]; i ++) {
        CacheImage *one = [cacheImagesList objectAtIndex:i];
        
        if ([one.imageRef isEqualToString:imageRef]
            && one.imageType == CuImageTypeOriginal ) {

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [NSThread sleepForTimeInterval:0.001];
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(one.imageData, nil, one.imageData?YES:NO);
                });
            });
            one.refCount++;
            [cacheImagesList replaceObjectAtIndex:i withObject:one];
            return;
        }
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (imageRef) {
            AddNetLogstr(imageRef, @"Image Get URL");

            NSURL *url = [NSURL URLWithString:imageRef];
            
            NSError *error;
            NSData *imageData = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedAlways error:&error];
#ifdef APP_OPTION_AutoConversionPDFInManager
            imageData = [self checkAndMakePngFromPDF:imageData];
#endif
            
            dispatch_async(dispatch_get_main_queue(), ^{
                CacheImage *image = [[CacheImage alloc] init];
                
                [image setImageData:imageData];
                [image setImageType:CuImageTypeOriginal];
                [image setQulity:DEFAULT_RESIZE_QULITY];
                [image setSize:CGSizeMake(0, 0)];
                [image setImageRef:imageRef];
                [image setRefCount:1];
                [cacheImagesList addObject:image];
                
                block(image.imageData, nil, image.imageData?YES:NO);
            });
        }
    });
}

- (NSData *)checkAndMakePngFromPDF:(NSData *)data
{
    NSData *imageData = data;
    CuImageFormat format = [CuImage imageFormatForImageData:imageData];
    if(format == CuImageFormatPDF) {
        UIImage *tempImage = [CuPDFViewWithZoom createPageImageWithData:imageData withSize:CGSizeZero at:1];
        imageData = UIImagePNGRepresentation(tempImage);
    }
    return imageData;
}

-(CacheImage*)synchronousImageLoadWithImageRef:(NSString *)imageRef
                                      withSize:(CGSize)size
                                      withType:(CuImageType)imageType
                              withResizeQulity:(CuImageResizeQulity)resizeQulity
                                  isImageCache:(BOOL)isImageCache {
    
    NSURL *url = [NSURL URLWithString:imageRef];
    
    NSData *imageData;
    NSError *error;
    if (imageRef) {
        imageData = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedAlways error:&error];
#ifdef APP_OPTION_AutoConversionPDFInManager
        imageData = [self checkAndMakePngFromPDF:imageData];
#endif
    }
    
    CacheImage *image = [[CacheImage alloc] init];
    
    [image setImageData:imageData];
    [image setImageType:imageType];
    [image setQulity:resizeQulity];
    [image setSize:size];
    [image setImageRef:imageRef];
    [image setRefCount:1];
    
    if (isImageCache) {
        [cacheImagesList addObject:image];
    }
    
    return image;
}

-(void)replaceCacheImage:(CuImage *)image forImageRef:(NSString *)imageRef {
    
    for (int i = 0; i < [cacheImagesList count]; i++) {
        CacheImage *one = [cacheImagesList objectAtIndex:i];
        
        if ([one.imageRef isEqualToString:imageRef]) {
            if (one.imageType == CuImageTypeOriginal) {
                NSInteger index = [cacheImagesList indexOfObject:one];
                
                one.imageData = image.imageData;
                [cacheImagesList replaceObjectAtIndex:index withObject:one];
            } else {
                
                ImageOperation *operation = [ImageResizeOperation ResizeOperationManager:self withAction:@selector(didEndOperationWithResult:withContext:) withTarget:@"resize" withRef:one.imageRef withImageOprationType:one.imageType withOriginalImage:image.image withSize:one.size withResizeQulity:one.qulity isImageCache:YES withContext:nil];

                [self.operationQueue addOperation:operation];
            }
        }
    }
}

-(void)deleteCacheForImageRef:(NSString *)imageRef {
    NSMutableArray *deleteList = [NSMutableArray array];
    for (int i = 0; i < [cacheImagesList count]; i++) {
        CacheImage *one = [cacheImagesList objectAtIndex:i];
        if ([one.imageRef isEqualToString:imageRef]) {
            [deleteList addObject:one];
        }
    }
    [cacheImagesList removeObjectsInArray:deleteList];
}
@end
