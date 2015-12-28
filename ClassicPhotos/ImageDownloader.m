

#import "ImageDownloader.h"

@interface ImageDownloader ()

@property (nonatomic, readwrite, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readwrite, strong) PhotoRecord *photoRecord;

@end

@implementation ImageDownloader

#pragma mark - Life Cycle
- (id)initWithPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageDownloaderDelegate>)delegate {
    if (self = [super init])
    {
        self.delegate = delegate;
        self.indexPathInTableView = indexPath;
        self.photoRecord = record;
    }
    return  self;
}

#pragma mark - Downloading image
- (void)main {
    @autoreleasepool {
        if (self.isCancelled)
        {
            return;
        }
        
        NSData *imageData = [NSData dataWithContentsOfURL:_photoRecord.URL];
        
        if (self.isCancelled)
        {
            imageData = nil;
            return;
        }
        
        if (imageData)
        {
            UIImage *downloadedImage = [UIImage imageWithData:imageData];
            _photoRecord.image = downloadedImage;
        }
        else
        {
            self.photoRecord.failed = YES;
        }

        imageData = nil;
        
        if (self.isCancelled)
        {
            return;
        }
        
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageDownloadDidFinish:) withObject:self waitUntilDone:NO];
    }
}

@end
