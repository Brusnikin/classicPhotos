

#import "PendingOperations.h"

@implementation PendingOperations

- (NSMutableDictionary *)downloadsInProgress {
    if (!_downloadsInProgress)
    {
        _downloadsInProgress = [NSMutableDictionary dictionary];
    }
    
    return _downloadsInProgress;
}

- (NSOperationQueue *)downloadQueue {
    if (!_downloadQueue)
    {
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.name = @"Dpwnload Queue";
//        _downloadQueue.maxConcurrentOperationCount = 1;
    }
    
    return _downloadQueue;
}

- (NSMutableDictionary *)filtrationsInProgress {
    if (!_filtrationsInProgress)
    {
        _filtrationsInProgress = [NSMutableDictionary dictionary];
    }
    
    return _filtrationsInProgress;
}

- (NSOperationQueue *)filtrationQueue {
    if (!_filtrationQueue)
    {
        _filtrationQueue = [[NSOperationQueue alloc] init];
        _filtrationQueue.name = @"Image Filtration Queue";
//        _filtrationQueue.maxConcurrentOperationCount = 1;
    }
    
    return _filtrationQueue;
}

@end
