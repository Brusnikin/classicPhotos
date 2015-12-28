

#import <UIKit/UIKit.h>
#import "PhotoRecord.h"
#import "PendingOperations.h"
#import "ImageDownloader.h"
#import "ImageFiltration.h"
#import "AFNetworking/AFNetworking.h"

#define kDatasourceURLString @"http://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist"

@interface ListViewController : UITableViewController <ImageDownloaderDelegate, ImageFiltrationDelegate>

@property (nonatomic, strong) NSMutableArray *photos; // main data source of controller
@property (nonatomic, strong) PendingOperations *pendingOperations;

@end
