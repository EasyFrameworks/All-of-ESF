//
//  CuImage.m
//  gridview
//
//  Created by Element on 13. 3. 29..
//  Copyright (c) 2013년 Element. All rights reserved.
//

#import "CuImage.h"
@interface CuImage (private)


//@property (nonatomic, assign) CuImageFormat imageFormat;
//@property (nonatomic, strong) UIImage *image;
@end


@implementation CuImage
@synthesize imageRef = __imageRef;
@synthesize imageType = _imageType;
@synthesize imageFormat = _imageFormat;

-(id)self {
    return (CuImage *)_image;
}

+(CuImage*)imageForImageRef:(NSString*)imageRef withContext:(id)context{
    return [self imageForImageRef:imageRef withImageType:CuImageTypeOriginal withContext:context];
}

+(CuImage*)imageForImageRef:(NSString*)imageRef withImageType:(CuImageType)imageType withContext:(id)context{
    return [self imageForImageRef:imageRef withImageType:CuImageTypeOriginal isImageCache:DEFAULT_IMAGE_CACHE withContext:context];
}

+(CuImage *)imageForImageRef:(NSString *)imageRef withImageType:(CuImageType)imageType isImageCache:(BOOL)isImageCache withContext:(id)context{
    CuImage *image = [[CuImage alloc] init];
//    [image setImageRef:imageRef withImageType:CuImageTypeOriginal isImageCache:isImageCache withContext:context];
//    [image setImageRef:imageRef withImageType:CuImageTypeOriginal isImageCache:isImageCache withContext:context];

    [image setImageWithRef:imageRef withImageType:CuImageTypeOriginal withSize:CGSizeZero withResizeQulity:DEFAULT_RESIZE_QULITY isImageCache:DEFAULT_IMAGE_CACHE withContext:nil];
    return image;
}

-(id)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

-(id)initWithUIImage:(UIImage *)image {
    if (self = [super init]) {
        [self initialize];
        [self setImage:image];
    }
    return self;
}

-(void)initialize {
    _imageFormat = DEFAULT_IMAGE_FORMAT;

    _isImageCache = DEFAULT_IMAGE_CACHE;
    _imageType = CuImageTypeOriginal; // default original
}

#pragma mark - setter / getter Methods
-(void)setImageWithRef:(NSString *)imageRef withContext:(id)context {
    
    [self setImageWithRef:imageRef isImageCache:_isImageCache withContext:context];
}

-(void)setImageWithRef:(NSString *)imageRef isImageCache:(BOOL)isImageCache withContext:(id)context{
    [self setImageWithRef:imageRef withImageType:DEFAULT_IMAGETYPE withSize:self.size withResizeQulity:DEFAULT_RESIZE_QULITY isImageCache:isImageCache withContext:context];
}

-(void)setImageWithRef:(NSString *)imageRef withImageType:(CuImageType)imageType withContext:(id)context{
    [self setImageWithRef:imageRef withImageType:imageType isImageCache:_isImageCache withContext:context];
}

-(void)setImageWithRef:(NSString *)imageRef withImageType:(CuImageType)imageType isImageCache:(BOOL)isImageCache withContext:(id)context{
    
    [self setImageWithRef:imageRef withImageType:imageType withSize:self.size withResizeQulity:DEFAULT_RESIZE_QULITY isImageCache:isImageCache withContext:context];
    
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
    [self setImageWithRef:imageRef withImageType:DEFAULT_IMAGETYPE withSize:self.size withResizeQulity:DEFAULT_RESIZE_QULITY isImageCache:isImageCache withContext:context];
    
}

-(void)setImageWithRef:(NSString *)imageRef withImageType:(CuImageType)imageType withSize:(CGSize)size withResizeQulity:(CuImageResizeQulity)resizeQulity isImageCache:(BOOL)isImageCache withContext:(id)context{
    
//    [self setImage:nil];
//    _state = CuImageViewState_WaitForLoadImage;
//    [self setActiveIndicator:_activeIndicator];
//    
//    _imageRef = imageRef;
//    _imageType = imageType;
//    _context = context;
    
    
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
    //------------------------------------------------
    
    [[ImageManager shareInstance] getImageWithRef:imageRef withTarget:self withType:imageType withSize:size withResizeQulity:resizeQulity isImageCache:isImageCache withContext:context];
    
}


+(CuImage*)imageWithData:(NSData *)imageData {
    
    CuImage *returnImage = [[CuImage alloc] init];
    
    returnImage.imageFormat = [CuImage imageFormatForImageData:imageData];
    
    [returnImage setImage:[UIImage imageWithData:imageData]];
    
    return returnImage;
}

+(CuImageFormat)imageFormatForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    CuImageFormat ret = CuImageFormatUnknown;
    switch (c) {
        case 0xFF:
            ret = CuImageFormatJPEG;
            break;
        case 0x89:
            ret = CuImageFormatPNG;
            break;
        case 0x47:
            ret = CuImageFormatGIF;
            break;
        case 0x49:
        case 0x4D:
            ret = CuImageFormatTIFF;
            break;
        case 0x25: { //"%PDF"
            char buffer[4];
            [data getBytes:buffer length:4];
            if(buffer[1] == 0x50 && buffer[2] == 0x44 && buffer[3] == 0x46)
                ret = CuImageFormatPDF;
            break;
        }
    }
    return ret;
}

-(void)isImageCache:(BOOL)isImageCache {
    _isImageCache = isImageCache;
    
}
-(CuImageFormat)imageFormat {
    if (!_imageFormat) {
        _imageFormat = CuImageFormatJPEG;
    }
    return _imageFormat;
}

-(NSData *)imageData {
    NSData *ret;
    switch (self.imageFormat) {
        case CuImageFormatJPEG:
            ret = UIImageJPEGRepresentation(self.image, COMMON_JPEGCOMPRESSIONQULITY);
            break;
        case CuImageFormatTIFF:
        case CuImageFormatPNG:
            ret = UIImagePNGRepresentation(self.image);
        default:
            break;
    }
    return ret;
}

-(CGSize)size {
    return self.image.size;
}

#pragma mark - ImageManager Delegate


-(void)imageManager:(ImageManager *)imageManager didFailLoadImageRef:(NSString *)imageRef withError:(NSError *)error withContext:(id)context{
}

-(void)imageManager:(ImageManager *)imageManager DidLoadImage:(CacheImage *)image withContext:(id)context {
    _image = [UIImage imageWithData:image.imageData];
}

@end