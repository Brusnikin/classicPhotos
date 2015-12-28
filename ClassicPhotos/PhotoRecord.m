

#import "PhotoRecord.h"

@implementation PhotoRecord


- (BOOL)hasImage {
    return _image != nil;
}

- (BOOL)isFiltered {
    return _filtered;
}

- (BOOL)isFailed {
    return _failed;
}

@end
