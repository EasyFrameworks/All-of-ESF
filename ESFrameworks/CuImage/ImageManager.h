//
//  ImageManager.h
//  gridview
//
//  Created by Element on 13. 3. 29..
//  Copyright (c) 2013년 Element. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CuImage-Constants.h"

/** CuImage와 CuImageView를 제어하기 위한 싱글턴 객체이다.
 
 
 매크로 상수
 MAX_CONCURRENT_OPERATION_COOUNT 최대로 사용할 오퍼레이션의 갯수
 MAX_CACHEIMAGE_COUNT 최대 이미지 캐시에 사용될 공간
 DELETED_IMAGE_COUNT_ONETIME 최대 이미지 캐시의 갯수가 넘어갈 경우 지워질 캐시의 갯수
 
 프러퍼티
 operationQueue 이미지 처리에 사용되는 오퍼레이션 큐이다.
 
 팩토리 메쏘드
 shareInstance 싱글턴 객체를 반환받기 위한 팩토리 메쏘드이다.
 
 일반 메쏘드
 removeAllOperation 현재 큐에 담겨있는 모든 오퍼레이션을 취소시킨다.
 getImageWithRef:withTarget: 비동기식으로 이미지를 처리하기 위한 메쏘드로써 imageUrl 과 해당 이미지 뷰를 파라메터값으로 받는다.
 getImageWithRef:withTarget:withType: 비동기식으로 이미지를 처리하기 위한 메쏘드로써 imageUrl과 해당 이미지뷰와 타잎을 파라메터값으로 받는다.
 
 
 */
//author Dae-hyun Kim
@class ImageManager;
@class CacheImage;
@class CuImage;

@protocol ImageManagerDelegate <NSObject>

-(void)imageManager:(ImageManager *)imageManager didFailLoadImageRef:(NSString*)imageRef withError:(NSError*)error withContext:(id)context;
-(void)imageManager:(ImageManager *)imageManager DidLoadImage:(CacheImage*)image withContext:(id)context;

@end
@interface CacheImage : NSObject

@property (nonatomic, strong) NSString *imageRef;
@property (nonatomic, assign) CuImageResizeQulity qulity;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CuImageType imageType;
@property (nonatomic, assign) NSInteger refCount;
@property (nonatomic, strong) NSData *imageData;
@property (nonatomic, strong) NSDate *timeStamp;
@end

@interface ImageManager : NSObject {
    NSMutableDictionary *cacheImages;
    NSMutableArray *cacheImagesIndex;
    NSMutableArray *cacheImagesList;
}
@property     NSMutableArray *cacheImagesList;
@property BOOL test;

@property (nonatomic, strong) NSOperationQueue *operationQueue;

+(ImageManager*)shareInstance;

-(void)removeAllOperation;
-(void)removeCacheImages;

-(void)addCacheImageWithImageRef:(NSString*)imageRef withContext:(id)context;

-(BOOL)getImageWithRef:(NSString*)imageRef
            withTarget:(id)target
           withContext:(id)context;

-(BOOL)getImageWithRef:(NSString*)imageRef
            withTarget:(id)target
              withType:(CuImageType)imageType
           withContext:(id)context;

-(BOOL)getImageWithRef:(NSString*)imageRef
            withTarget:(id)target
              withSize:(CGSize)size
           withContext:(id)context;

-(BOOL)getImageWithRef:(NSString*)imageRef
            withTarget:(id)target
              withType:(CuImageType)imageType
          isImageCache:(BOOL)isImageCache
           withContext:(id)context;

-(BOOL)getImageWithRef:(NSString*)imageRef
            withTarget:(id)target
              withSize:(CGSize)size
          isImageCache:(BOOL)isImageCache
           withContext:(id)context;

-(BOOL)getImageWithRef:(NSString*)imageRef
            withTarget:(id)target
              withType:(CuImageType)imageType
              withSize:(CGSize)size
          isImageCache:(BOOL)isImageCache
           withContext:(id)context;

-(BOOL)getImageWithRef:(NSString*)imageRef
            withTarget:(id)target
              withType:(CuImageType)imageType
              withSize:(CGSize)size
      withResizeQulity:(CuImageResizeQulity)resizeQulity
          isImageCache:(BOOL)isImageCache
           withContext:(id)context;


-(void)asynchronousImageLoadWithImageRef:(NSString *)imageRef
                               withBlock:(void(^)(NSData *image, NSError *error, BOOL success))block;

-(CacheImage*)synchronousImageLoadWithImageRef:(NSString *)imageRef
                                      withSize:(CGSize)size
                                      withType:(CuImageType)imageType
                              withResizeQulity:(CuImageResizeQulity)resizeQulity
                                  isImageCache:(BOOL)isImageCache;

//-(UIImage*)resizingImage:(UIImage*)image
//                  toSize:(CGSize)size
//       withInterpolation:(CuImageResizeQulity)resizeQulity;
//
-(void)replaceCacheImage:(CuImage *)image forImageRef:(NSString *)imageRef;
-(void)deleteCacheForImageRef:(NSString *)imageRef;
-(NSData *)checkAndMakePngFromPDF:(NSData *)data;
@end
