//
//  CuImageView.h
//  gridview
//
//  Created by Element on 13. 3. 29..
//  Copyright (c) 2013년 Element. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CuImage-Constants.h"
#import "ImageManager.h"

/** 커스텀 UIImageView 로써 비동기식 이미지 세팅과 인디케이터 실패 메세지 등을 지원하고 ImageManager에서 제어한다.
 
 프러퍼티
 imageRef 현재 이미지의 레퍼런스 값을 담는다.
 activeIndicator 인디케이터 사용 여부 변수다. 기본 YES이며 NO 로 설정할경우 인디케이터는 나타나지 않는다.
 state 상태값 Init, Empty, WaitForLoadImage, ImageLoaded 의 값을 갖는다.
 failedMessage (구현중) 실패시에 나타날 메세지를 담은 label 이다.
 imageType 현재 이미지의 type 정보를 담는다.
 
 팩토리 메쏘드
 
 일반 메쏘드
 setActiveIndicator: 활성화를 시키게 되면 이미지 로딩시 인디케이터가 나타난다.
 setImage: UIImage의 메쏘드의 오버라이드된 메쏘드이다. 이미지를 세팅할 수 있다. CuImage 객체를 넘기게 되면 비동기식으로 이미지가 세팅된다.
 setImageWithRef: 이미지 레퍼런스 정보만 넘기게 된다. Url 을 파라메터값으로 받게 되면 비동기식으로 이미지가 세팅된다.
 setImageRef:withImageType: 이미지 레퍼런스와 이미지 타잎을 파라메터값으로 넘겨주게 되면 비동기식으로 이미지가 세팅된다.
 
 */
//author Dae-hyun Kim


@class CuImageView;
@class CacheImage;
@protocol CuImageViewDelegate <NSObject>

@optional
-(void)imageView:(CuImageView*)imageView willRequestImageRef:(NSString*)imageRef withContext:(id)context;

@required
-(void)imageView:(CuImageView*)imageView didReceiveImage:(CacheImage*)cacheImage withContext:(id)context;
-(void)imageView:(CuImageView*)imageView didFailReceiveImage:(NSError*)error withContext:(id)context;

@end

enum CuImageViewState {
    CuImageViewState_Init,
    CuImageViewState_Empty,
    CuImageViewState_WaitForLoadImage,
    CuImageViewState_ImageLoaded,
};

@class CuImage;

@interface CuImageView : UIImageView <ImageManagerDelegate> {
    UIActivityIndicatorView *indicator;
}

@property (nonatomic, copy, setter = setImageWithRef:) NSString *imageRef;
@property (nonatomic, assign) CuImageType imageType;
@property (nonatomic, assign) BOOL activeIndicator;
@property (readonly) enum CuImageViewState state;
@property (nonatomic, assign, setter = isImageCache:) BOOL isImageCache;
@property (nonatomic, weak) id <CuImageViewDelegate> delegate;
@property (nonatomic, strong) id context;

-(void)setActiveIndicator:(BOOL)activeIndicator;
-(void)setImage:(id)image;
-(void)setImageWithRef:(NSString *)imageRef withContext:(id)context;
-(void)setImageWithRef:(NSString *)imageRef isImageCache:(BOOL)isImageCache withContext:(id)context;
-(void)setImageWithRef:(NSString *)imageRef withImageType:(CuImageType)imageType withContext:(id)context;
-(void)setImageWithRef:(NSString *)imageRef withImageType:(CuImageType)imageType isImageCache:(BOOL)isImageCache withContext:(id)context;
-(void)setImageWithRef:(NSString *)imageRef withSize:(CGSize)size withContext:(id)context;
-(void)setImageWithRef:(NSString *)imageRef withSize:(CGSize)size isImageCache:(BOOL)isImageCache withContext:(id)context;
-(void)setImageWithRef:(NSString *)imageRef withResizeQulity:(CuImageResizeQulity)resizeQulity withContext:(id)context;
-(void)setImageWithRef:(NSString *)imageRef withResizeQulity:(CuImageResizeQulity)resizeQulity isImageCache:(BOOL)isImageCache withContext:(id)context;
-(void)setImageWithRef:(NSString *)imageRef withImageType:(CuImageType)imageType withSize:(CGSize)size withResizeQulity:(CuImageResizeQulity)resizeQulity isImageCache:(BOOL)isImageCache withContext:(id)context;
-(void)setImageWithImageLoadConfig:(CuImageLoadConfig)imageConfig withContext:(id)context;

@end
