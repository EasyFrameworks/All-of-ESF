//
//  CuImage-Constants.h
//  gridview
//
//  Created by Element on 13. 3. 29..
//  Copyright (c) 2013년 Element. All rights reserved.
//

#ifndef gridview_CuImage_Constants_h
#define gridview_CuImage_Constants_h

#define DEFAULT_IMAGE_FORMAT CuImageFormatJPEG
#define DEFAULT_IMAGE_CACHE YES
#define DEFAULT_IMAGETYPE CuImageTypeSpecificalSize
#define DEFAULT_RESIZE_QULITY (CGInterpolationQuality)CuImageResizeQulityDefault
#define MAX_CONCURRENT_OPERATION_COOUNT 5
#define MAX_CACHEIMAGE_COUNT 100
#define DELETED_IMAGE_COUNT_ONETIME 10

#define MAX_ORIGINALIMAGE_CACHECOUNT 30
#define DELETED_ORIGINALIMAGE_COUNT_ONETIME 3

typedef enum {
    CuImageTypeOriginal = 0,
    CuImageTypeResize50Percent,
    CuImageTypeResize25Percent,
    CuImageTypeResizeThumbNail,
    CuImageTypeLimitedOriginal,
    CuImageTypeSpecificalSize
} CuImageType;

typedef enum CGInterpolationQuality CuImageResizeQulity;

enum CuImageResizeQulity {
    CuImageResizeQulityDefault = 0,	/* Let the context decide. */
    CuImageResizeQulityNone = 1,		/* Never interpolate. */
    CuImageResizeQulityLow = 2,		/* Low quality, fast interpolation. */
    CuImageResizeQulityMedium = 4,		/* Medium quality, slower than kCGInterpolationLow. */
    CuImageResizeQulityHigh = 3		/* Highest quality, slower than kCGInterpolationMedium. */
};


//enum CGInterpolationQuality {
//    kCGInterpolationDefault = 0,	/* Let the context decide. */
//    kCGInterpolationNone = 1,		/* Never interpolate. */
//    kCGInterpolationLow = 2,		/* Low quality, fast interpolation. */
//    kCGInterpolationMedium = 4,		/* Medium quality, slower than kCGInterpolationLow. */
//    kCGInterpolationHigh = 3		/* Highest quality, slower than kCGInterpolationMedium. */
//};

typedef struct {
    __unsafe_unretained NSString *imageRef;
    CuImageType imageType;
    CuImageResizeQulity resizeQulity;
    BOOL isImageCache;
} CuImageLoadConfig;


#endif
