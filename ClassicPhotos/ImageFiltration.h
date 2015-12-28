

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>
#import "PhotoRecord.h"

@protocol ImageFiltrationDelegate;

@interface ImageFiltration : NSOperation

@property (nonatomic, weak) id<ImageFiltrationDelegate> delegate;

@property (nonatomic, readonly, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readonly, strong) PhotoRecord *photoRecord;

- (id)initWithPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageFiltrationDelegate>)delegate;

@end


@protocol ImageFiltrationDelegate <NSObject>

- (void)imageFiltrationDidFinish:(ImageFiltration *)filtration;

@end