
#import <Foundation/Foundation.h>
#import "PhotoRecord.h"

@protocol ImageDownloaderDelegate;

@interface ImageDownloader : NSOperation

@property (nonatomic, weak) id<ImageDownloaderDelegate> delegate;

@property (nonatomic, readonly, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readonly, strong) PhotoRecord *photoRecord;

- (id)initWithPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageDownloaderDelegate>)delegate;

@end

@protocol ImageDownloaderDelegate <NSObject>

- (void)imageDownloadDidFinish:(ImageDownloader *)downloader;

@end