

#import "ImageFiltration.h"

@interface ImageFiltration ()

@property (nonatomic, readwrite, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readwrite, strong) PhotoRecord *photoRecord;

@end

@implementation ImageFiltration

#pragma mark - Life Cycle
- (id)initWithPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageFiltrationDelegate>)delegate {
    if (self = [super init])
    {
        self.photoRecord = record;
        self.indexPathInTableView = indexPath;
        self.delegate = delegate;
    }
    
    return self;
}

#pragma mark - Main operation
- (void)main {
    @autoreleasepool {
        if (self.isCancelled)
        {
            return;
        }
        
        if (!self.photoRecord.hasImage)
        {
            return;
        }
        
        UIImage *rawImage = self.photoRecord.image;
        UIImage *processedImage = [self applySepiaFilterToImage:rawImage];
        
        if (self.isCancelled)
        {
            return;
        }
        
        if (processedImage)
        {
            _photoRecord.image = processedImage;
            _photoRecord.filtered = YES;
            
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageFiltrationDidFinish:) withObject:self waitUntilDone:NO];
        }
    }
}

- (UIImage *)applySepiaFilterToImage:(UIImage *)image
{
    CIImage *inputImage = [CIImage imageWithData:UIImagePNGRepresentation(image)];
    
    if (self.isCancelled)
    {
        return nil;
    }
    
    UIImage *sepiaImage = nil;
    CIContext *context = [CIContext contextWithOptions:nil];
    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone" keysAndValues:kCIInputImageKey, inputImage, @"inputIntensity", [NSNumber numberWithFloat:0.8], nil];
    CIImage *outputImage = [filter outputImage];
    
    if (self.isCancelled)
    {
        return nil;
    }
    
    CGImageRef outputImageRef = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    if (self.isCancelled)
    {
        return nil;
    }
    
    sepiaImage = [UIImage imageWithCGImage:outputImageRef];
    CGImageRelease(outputImageRef);
    
    return sepiaImage;
}

@end
