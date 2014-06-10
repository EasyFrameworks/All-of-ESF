//
//  CuImage.h
//  gridview
//
//  Created by Element on 13. 3. 29..
//  Copyright (c) 2013년 Element. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CuImage-Constants.h"
#import "ImageManager.h"

/** 커스텀 UIImage 로써 ImageManager에서 제어한다.
프러퍼티
    imageRef 현재 이미지의 레퍼런스 값을 담는다.
    imageType 현재 이미지의 type 정보를 담는다.
 
팩토리 메쏘드
    imageForRef: 레퍼런스에 해당하는 이미지를 리턴한다.
    imageForRef:withImageType: 래펀런스에 해당하는 이미지를 리턴한다.
 
일반 메쏘드
    setImageRef: 해당하는 레퍼런스 값으로 세팅한다.
    setImageType: 해당하는 타입으로 세팅한다.
    setImageRefwithImageType: 해당하는 레퍼런스와 타잎으로 세팅한다.
    모두 비동기 식으로 해당하는 래퍼런스를 받아와 저장한다.
 
현재 CuImage 는 구현된 인터페이스만 작동한다.
 
 */
//author Dae-hyun Kim



typedef enum {
    CuImageFormatUnknown,
    CuImageFormatJPEG,
    CuImageFormatPNG,
    CuImageFormatGIF,
    CuImageFormatTIFF,
    CuImageFormatPDF
} CuImageFormat;


@interface CuImage : UIImage <ImageManagerDelegate> {
    NSDictionary *dic; // 현재 미구현 CuImage 하나로 타입별 이미지를 저장하기 위한 공간
}
@property (nonatomic, assign) CuImageFormat imageFormat;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, copy) NSString *imageRef;
@property (nonatomic, assign) CuImageType imageType;
@property (nonatomic, assign, setter = isImageCache:) BOOL isImageCache;

-(id)initWithUIImage:(UIImage *)image;

+(CuImage *)imageForImageRef:(NSString *)imageRef withContext:(id)context;
+(CuImage *)imageForImageRef:(NSString *)imageRef withImageType:(CuImageType)imageType withContext:(id)context;
+(CuImage *)imageForImageRef:(NSString *)imageRef withImageType:(CuImageType)imageType isImageCache:(BOOL)isImageCache withContext:(id)context;

//-(void)setImageRef:(NSString *)imageRef withContext:(id)context;
//-(void)setImageType:(CuImageType)imageType withContext:(id)context;
//-(void)setImageRef:(NSString *)imageRef withImageType:(CuImageType)imageType withContext:(id)context;
//-(void)setImageRef:(NSString *)imageRef withImageType:(CuImageType)imageType isImageCache:(BOOL)isImageCache withContext:(id)context;

-(void)setImageWithRef:(NSString *)imageRef withContext:(id)context;
-(void)setImageWithRef:(NSString *)imageRef isImageCache:(BOOL)isImageCache withContext:(id)context;
-(void)setImageWithRef:(NSString *)imageRef withImageType:(CuImageType)imageType withContext:(id)context;
-(void)setImageWithRef:(NSString *)imageRef withImageType:(CuImageType)imageType isImageCache:(BOOL)isImageCache withContext:(id)context;
-(void)setImageWithRef:(NSString *)imageRef withSize:(CGSize)size withContext:(id)context;
-(void)setImageWithRef:(NSString *)imageRef withSize:(CGSize)size isImageCache:(BOOL)isImageCache withContext:(id)context;
-(void)setImageWithRef:(NSString *)imageRef withResizeQulity:(CuImageResizeQulity)resizeQulity withContext:(id)context;
-(void)setImageWithRef:(NSString *)imageRef withResizeQulity:(CuImageResizeQulity)resizeQulity isImageCache:(BOOL)isImageCache withContext:(id)context;

-(void)setImageWithRef:(NSString *)imageRef withImageType:(CuImageType)imageType withSize:(CGSize)size withResizeQulity:(CuImageResizeQulity)resizeQulity isImageCache:(BOOL)isImageCache withContext:(id)context;


+(CuImage*)imageWithData:(NSData*)imageData;
+(CuImageFormat)imageFormatForImageData:(NSData *)data;

-(void)isImageCache:(BOOL)isImageCache;
-(NSData*)imageData;

@end
