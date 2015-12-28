

#import "ListViewController.h"

@interface ListViewController ()

@end

@implementation ListViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    

    self.title = @"Classic Photos";
    self.tableView.rowHeight = 80;
//    self.tableView.dataSource = self;
    static NSString *kCellIdentifier = @"Cell Identifier";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    
    self.pendingOperations = nil;
}

- (void)didReceiveMemoryWarning {
    [self cancelAllOperations];
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSUInteger count = self.photos.count;
    
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *kCellIdentifier = @"Cell Identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIActivityIndicatorView *activeIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    cell.accessoryView = activeIndicatorView;
    
    PhotoRecord *record = [self.photos objectAtIndex:indexPath.row];
    
    if (record.hasImage)
    {
        [((UIActivityIndicatorView *)cell.accessoryView) startAnimating];
        cell.imageView.image = record.image;
        cell.textLabel.text = record.name;
    }
    else if (record.isFailed)
    {
        [((UIActivityIndicatorView *)cell.accessoryView) startAnimating];
        cell.imageView.image = [UIImage imageNamed:@"Failed.png"];
        cell.textLabel.text = @"Failed to load";
    }
    else
    {
        [((UIActivityIndicatorView *)cell.accessoryView) startAnimating];
        cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
        cell.textLabel.text = @"";
        
        if (!self.tableView.dragging && !self.tableView.decelerating) {
            [self startOperationsForPhotoRecord:record atIndexPath:indexPath];
        }
    }
    
    return cell;
}

- (void)startOperationsForPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath {
    if (!record.hasImage)
    {
        [self startImageDownloadingForRecord:record atIndexPath:indexPath];
    }

    if (!record.isFiltered)
    {
        [self startImageFiltrationForRecrod:record atIndexPath:indexPath];
    }
}

- (void)startImageDownloadingForRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath {
    if (![self.pendingOperations.downloadsInProgress.allKeys containsObject:indexPath])
    {
        ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithPhotoRecord:record atIndexPath:indexPath delegate:self];
        [self.pendingOperations.downloadsInProgress setObject:imageDownloader forKey:indexPath];
        [self.pendingOperations.downloadQueue addOperation:imageDownloader];
    }
}

- (void)startImageFiltrationForRecrod:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath {
    if (![self.pendingOperations.filtrationsInProgress.allKeys containsObject:indexPath])
    {
        ImageFiltration *imageFiltration = [[ImageFiltration alloc] initWithPhotoRecord:record atIndexPath:indexPath delegate:self];
        
        ImageDownloader *dependency = [self.pendingOperations.downloadsInProgress objectForKey:indexPath];
        if (dependency)
        {
            [imageFiltration addDependency:dependency];
        }
        
        [self.pendingOperations.filtrationsInProgress setObject:imageFiltration forKey:indexPath];
        [self.pendingOperations.filtrationQueue addOperation:imageFiltration];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Lazy instantiation
- (NSMutableArray *)photos {
    if (!_photos)
    {
        NSURL *dataSourceURL = [NSURL URLWithString:kDatasourceURLString];
        NSURLRequest *request = [NSURLRequest requestWithURL:dataSourceURL];
        
        AFHTTPRequestOperation *datasource_download_operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        [datasource_download_operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSData *datasource_data = (NSData *)responseObject;
            
            CFPropertyListFormat propertyListFormat;
            CFPropertyListRef plist = CFPropertyListCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)datasource_data, kCFPropertyListImmutable, &propertyListFormat, NULL);
            
            NSDictionary *datasource_dictionary = (__bridge NSDictionary *)plist;
            
            NSMutableArray *records = [NSMutableArray array];
            
            for (NSString *key in datasource_dictionary)
            {
                PhotoRecord *record = [[PhotoRecord alloc] init];
                record.URL = [NSURL URLWithString:[datasource_dictionary objectForKey:key]];
                record.name = key;
                [records addObject:record];
            }
            
            self.photos = records;
            
            CFRelease(plist);
            
            [self.tableView reloadData];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
        
        [self.pendingOperations.downloadQueue addOperation:datasource_download_operation];
    }
    
    return _photos;
}

- (PendingOperations *)pendingOperations {
    if (!_pendingOperations)
    {
        _pendingOperations = [[PendingOperations alloc] init];
    }
    
    return _pendingOperations;
}

#pragma mark - ImageDownloaderDelegate
- (void)imageDownloadDidFinish:(ImageDownloader *)downloader {
    NSIndexPath *indexPath = downloader.indexPathInTableView;
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.pendingOperations.downloadsInProgress removeObjectForKey:indexPath];
}

#pragma mark - ImageFiltrationDelegate
- (void)imageFiltrationDidFinish:(ImageFiltration *)filtration {
    NSIndexPath *indexPath = filtration.indexPathInTableView;
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.pendingOperations.filtrationsInProgress removeObjectForKey:indexPath];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self suspendAllOperations];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate)
    {
        [self loadImagesForOnscreenCells];
        [self resumeAllOperations];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenCells];
    [self resumeAllOperations];
}

#pragma mark - Cancel, Suspend, Resume, queues / operations
- (void)suspendAllOperations {
    [self.pendingOperations.downloadQueue setSuspended:YES];
    [self.pendingOperations.filtrationQueue setSuspended:YES];
}

- (void)resumeAllOperations {
    [self.pendingOperations.downloadQueue setSuspended:NO];
    [self.pendingOperations.filtrationQueue setSuspended:NO];
}

- (void)cancelAllOperations {
    [self.pendingOperations.downloadQueue cancelAllOperations];
    [self.pendingOperations.filtrationQueue cancelAllOperations];
}

- (void)loadImagesForOnscreenCells {
    NSSet *visibleRows = [NSSet setWithArray:[self.tableView indexPathsForVisibleRows]];
    
    NSMutableSet *pendingOperations = [NSMutableSet setWithArray:[self.pendingOperations.downloadsInProgress allKeys]];
    [pendingOperations addObjectsFromArray:[self.pendingOperations.filtrationsInProgress allKeys]];
    
    NSMutableSet *toBeCancelled = [pendingOperations mutableCopy];
    NSMutableSet *toBeStarted = [visibleRows mutableCopy];
    
    [toBeStarted minusSet:pendingOperations];
    [toBeCancelled minusSet:visibleRows];
    
    for (NSIndexPath *indexPath in toBeCancelled)
    {
        ImageDownloader *pendingDownload = [self.pendingOperations.downloadsInProgress objectForKey:indexPath];
        [pendingDownload cancel];
        [self.pendingOperations.downloadsInProgress removeObjectForKey:indexPath];
        
        ImageFiltration *pendingFiltration = [self.pendingOperations.filtrationsInProgress objectForKey:indexPath];
        [pendingFiltration cancel];
        [self.pendingOperations.filtrationsInProgress removeObjectForKey:indexPath];
    }
    
    for (NSIndexPath *indexPath in toBeStarted)
    {
        PhotoRecord *recordToProcess = [self.photos objectAtIndex:indexPath.row];
        [self startOperationsForPhotoRecord:recordToProcess atIndexPath:indexPath];
    }
}

@end
