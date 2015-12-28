

#import <UIKit/UIKit.h>

@interface PhotoRecord : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, readonly) BOOL hasImage;
@property (nonatomic, getter=isFiltered) BOOL filtered;
@property (nonatomic, getter=isFailed) BOOL failed;

@end
