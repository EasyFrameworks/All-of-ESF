//
//  CuImageView.m
//  gridview
//
//  Created by Element on 13. 3. 29..
//  Copyright (c) 2013년 Element. All rights reserved.
//

#import "CuImageView.h"
#import "CuImage.h"
#import <QuartzCore/QuartzCore.h>

@implementation CuImageView
@synthesize imageRef = _imageRef;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

#pragma mark - initialize

-(void) initialize {
    _state = CuImageViewState_Init;
    _activeIndicator = YES; //default yes
    [self setActiveIndicator:_activeIndicator];
    [self setUserInteractionEnabled:YES];
    _isImageCache = DEFAULT_IMAGE_CACHE;

}

#pragma mark - layout

-(void)layoutSubviews {
}


#pragma mark - setter / getter methods

-(void)setActiveIndicator:(BOOL)activeIndicator {
    _activeIndicator = activeIndicator;
    if (_activeIndicator && _state != CuImageViewState_ImageLoaded && _state != CuImageViewState_Empty) {
        if (!indicator) {
            indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            indicator.backgroundColor = [UIColor grayColor];
            indicator.frame = CGRectMake(0, 0, 25, 25);
            indicator.layer.cornerRadius = 3.0;
            [indicator setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
            [indicator setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin];

            [self addSubview:indicator];
            [indicator startAnimating];
        }
    } else {
        if (indicator) {
            [indicator stopAnimating];
            [indicator removeFromSuperview];
            indicator = nil;
        }
    }
}

-(void)setImage:(id)image {

    if (!image) {
        [super setImage:nil];
//        _imageRef = nil;
        _imageType = CuImageTypeOriginal;
        _state = CuImageViewState_Empty;

        [indicator removeFromSuperview];
        indicator = nil;
        return;
    }
    
    if (_delegate)
        if ([_delegate respondsToSelector:@selector(imageView:willRequestImageRef:withContext:)])
            [_delegate imageView:self willRequestImageRef:self.imageRef withContext:_context];

    if ([image isKindOfClass:[CuImage class]]) {
        CuImage *tempObj = image;
        [self setImageWithRef:tempObj.imageRef withImageType:tempObj.imageType isImageCache:tempObj.isImageCache withContext:_context];
    } else if ([image isKindOfClass:[CacheImage class]]){

        CacheImage *tempObj = image;
        NSData *imageData = tempObj.imageData;
        UIImage *tempImage = [UIImage imageWithData:imageData];
        [super setImage:tempImage];

        _state = CuImageViewState_ImageLoaded;
    } else {
        [super setImage:image];
        [self setActiveIndicator:NO];
        _state = CuImageViewState_ImageLoaded;

    }
    
}

-(void)setImageWithRef:(NSString *)imageRef withContext:(id)context {
    
    [self setImageWithRef:imageRef isImageCache:_isImageCache withContext:context];
}

-(void)setImageWithRef:(NSString *)imageRef isImageCache:(BOOL)isImageCache withContext:(id)context{
    [self setImageWithRef:imageRef withImageType:DEFAULT_IMAGETYPE withSize:self.frame.size withResizeQulity:DEFAULT_RESIZE_QULITY isImageCache:isImageCache withContext:context];
}

-(void)setImageWithRef:(NSString *)imageRef withImageType:(CuImageType)imageType withContext:(id)context{
    [self setImageWithRef:imageRef withImageType:imageType isImageCache:_isImageCache withContext:context];
}

-(void)setImageWithRef:(NSString *)imageRef withImageType:(CuImageType)imageType isImageCache:(BOOL)isImageCache withContext:(id)context{

    [self setImageWithRef:imageRef withImageType:imageType withSize:self.frame.size withResizeQulity:DEFAULT_RESIZE_QULITY isImageCache:isImageCache withContext:context];
    
}
-(void)setImageWithRef:(NSString *)imageRef withSize:(CGSize)size withContext:(id)context{
    
    [self setImageWithRef:imageRef withSize:size isImageCache:_isImageCache withContext:context];
    
}
-(void)setImageWithRef:(NSString *)imageRef withSize:(CGSize)size isImageCache:(BOOL)isImageCache withContext:(id)context{
    
    [self setImageWithRef:imageRef withImageType:DEFAULT_IMAGETYPE withSize:size withResizeQulity:DEFAULT_RESIZE_QULITY isImageCache:isImageCache withContext:context];
    
}
-(void)setImageWithRef:(NSString *)imageRef withResizeQulity:(CuImageResizeQulity)resizeQulity withContext:(id)context{
    
    [self setImageWithRef:imageRef withResizeQulity:resizeQulity isImageCache:_isImageCache withContext:context];
    
}
-(void)setImageWithRef:(NSString *)imageRef withResizeQulity:(CuImageResizeQulity)resizeQulity isImageCache:(BOOL)isImageCache withContext:(id)context{
    [self setImageWithRef:imageRef withImageType:DEFAULT_IMAGETYPE withSize:self.frame.size withResizeQulity:DEFAULT_RESIZE_QULITY isImageCache:isImageCache withContext:context];
    
}

-(void)setImageWithRef:(NSString *)imageRef withImageType:(CuImageType)imageType withSize:(CGSize)size withResizeQulity:(CuImageResizeQulity)resizeQulity isImageCache:(BOOL)isImageCache withContext:(id)context{

    [self setImage:nil];
    _state = CuImageViewState_WaitForLoadImage;
    [self setActiveIndicator:_activeIndicator];
    
    _imageType = imageType;
    _context = context;


    //----------------------------  depend on reveal
    if ([[[NSURL URLWithString:imageRef] scheme] isEqualToString:@"http"] || [[[NSURL URLWithString:imageRef] scheme] isEqualToString:@"https"]) {
        NSRange r1 = [imageRef rangeOfString:@" Rev"];
        if(r1.location != NSNotFound)
        {
            NSRange r2 = [imageRef rangeOfString:@"." options:0 range:NSMakeRange(r1.location, imageRef.length - r1.location)];
            if(r2.location != NSNotFound)
            {
                NSMutableString *newRef = [NSMutableString string];
                [newRef appendString:[imageRef substringToIndex:r1.location]];
                [newRef appendString:[imageRef substringFromIndex:r2.location]];
                imageRef = newRef;
            }
        }
    }
    _imageRef = imageRef;

    //------------------------------------------------

    DLog(@"url2 : %@", imageRef);
    [[ImageManager shareInstance] getImageWithRef:imageRef withTarget:self withType:imageType withSize:size withResizeQulity:resizeQulity isImageCache:isImageCache withContext:context];

}

-(void)setImageWithImageLoadConfig:(CuImageLoadConfig)imageConfig withContext:(id)context {
    [self setImageWithRef:imageConfig.imageRef withImageType:imageConfig.imageType withSize:self.frame.size withResizeQulity:imageConfig.resizeQulity isImageCache:imageConfig.isImageCache withContext:context];
}


-(void)imageManager:(ImageManager *)imageManager didFailLoadImageRef:(NSString *)imageRef withError:(NSError *)error withContext:(id)context {
    if (_delegate)
        if ([_delegate respondsToSelector:@selector(imageView:didFailReceiveImage:withContext:)])
            [_delegate imageView:self didFailReceiveImage:error withContext:_context];
    
    _state = CuImageViewState_Empty;
    [self setActiveIndicator:_activeIndicator];

}

-(void)imageManager:(ImageManager *)imageManager DidLoadImage:(CacheImage *)image withContext:(id)context {
    [self setImage:image];
    [self setActiveIndicator:_activeIndicator];
    
    if (_delegate)
        if ([_delegate respondsToSelector:@selector(imageView:didReceiveImage:withContext:)])
            [_delegate imageView:self didReceiveImage:image withContext:_context];
}

@end