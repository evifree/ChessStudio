//
//  PgnDownloadViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 15/03/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "PgnDownloadViewController.h"
#import "Reachability.h"
#import "ZipArchive.h"
#import "SWRevealViewController.h"

@interface PgnDownloadViewController () {
    NSURLConnection *_connection;
    
    NSString *addressDownload;
    
    NSInteger downloadSize;
    NSInteger totalDownloaded;
    
    NSMutableData *totalData;
    
    UIAlertView *alert;
    UIProgressView *progressView;
    
    NSMutableArray *linkArray;
    
    UIBarButtonItem *editButtonItem;
    UIBarButtonItem *doneButtonItem;
}

@end

@implementation PgnDownloadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.title = NSLocalizedString(@"TITLE_DOWNLOAD_DATABASE", nil);
    _downloadButton.titleLabel.text = NSLocalizedString(@"BUTTON_DOWNLOAD_DATABASE", nil);
    _saveButton.titleLabel.text = NSLocalizedString(@"BUTTON_SAVE_LINK", nil);
    
    if (IS_PAD) {
        _tfAddress.placeholder = NSLocalizedString(@"TF_PGN_DOWNLOAD_PLACEHOLDER", nil);
    }
    else {
        _tfAddress.placeholder = NSLocalizedString(@"TF_PGN_DOWNLOAD_PLACEHOLDER_PHONE", nil);
    }
    
    
    
    if (IS_IOS_7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    _downloadButton.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    //_tableView.layer.masksToBounds = YES;
    //_tableView.layer.cornerRadius = 8.0;
    //_tableView.layer.borderWidth = 1.0;
    //_tableView.layer.borderColor = [UIColor blueColor].CGColor;
    
    [self loadLinkData];
    
    
    editButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed:)];
    doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE", nil) style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed:)];
    self.navigationItem.rightBarButtonItem = editButtonItem;
    
    /*
    UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window]rootViewController];
    if ([rootViewController isKindOfClass:[SWRevealViewController class]]) {
        SWRevealViewController *revealViewController = [self revealViewController];
        [revealViewController panGestureRecognizer];
        [revealViewController tapGestureRecognizer];
        
        UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SWRevealIcon.png"] style:UIBarButtonItemStyleBordered target:revealViewController action:@selector(revealToggle:)];
        self.navigationItem.leftBarButtonItem = revealButtonItem;
    }*/
    
    [self checkRevealed];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _tfAddress.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) checkRevealed {
    UIViewController *sourceViewController = nil;
    NSInteger index = [self.navigationController.viewControllers indexOfObject:self];
    if ( index != 0 && index != NSNotFound ) {
        sourceViewController = [self.navigationController.viewControllers objectAtIndex:index-1];
    }
    if (!sourceViewController) {
        SWRevealViewController *revealViewController = [self revealViewController];
        [revealViewController panGestureRecognizer];
        [revealViewController tapGestureRecognizer];
        
        UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SWRevealIcon.png"] style:UIBarButtonItemStylePlain target:revealViewController action:@selector(revealToggle:)];
        self.navigationItem.leftBarButtonItem = revealButtonItem;
    }
}

- (void) loadLinkData {
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"link.json"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (!fileExists) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *rootPath = [paths objectAtIndex:0];
        filePath = [rootPath stringByAppendingPathComponent:@"link.json"];
        NSError *error = nil;
        NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
        [outputStream open];
        linkArray = [[NSMutableArray alloc] init];
        [NSJSONSerialization writeJSONObject:linkArray toStream:outputStream options:0 error:&error];
        NSLog(@"FILE JSON CREATO");
        [outputStream close];
        return;
    }
    NSError *error = nil;
    if (error) {
        NSLog(@"%@", error.description);
    }
    else {
        NSLog(@"File json caricato correttamente");
        NSLog(@"FilePath = %@", filePath);
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:kNilOptions error:&error];
        linkArray = data.mutableCopy;
    }
}

- (void) editButtonPressed:(UIBarButtonItem *)sender {
    if (![self.tableView isEditing]) {
        [self.tableView setEditing:YES animated:YES];
        self.navigationItem.rightBarButtonItem = doneButtonItem;
        _tfAddress.enabled = NO;
    }
}

- (void) doneButtonPressed:(UIBarButtonItem *)sender {
    if ([self.tableView isEditing]) {
        [self.tableView setEditing:NO animated:YES];
        self.navigationItem.rightBarButtonItem = editButtonItem;
        _tfAddress.enabled = YES;
    }
}

- (IBAction)downloadButton:(id)sender {
    
    if ([self.tableView isEditing]) {
        return;
    }
    
    
    [_tfAddress resignFirstResponder];
    
    Reachability  *internetReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [internetReachability currentReachabilityStatus];
    
    if (networkStatus == NotReachable) {
        UIAlertView *notReachableAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NO_INTERNET", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [notReachableAlertView show];
        return;
    }
    
    
    addressDownload = [[_tfAddress text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (addressDownload.length>0) {
        if (![addressDownload hasPrefix:@"http://"]) {
            addressDownload = [@"http://" stringByAppendingString:addressDownload];
        }
        NSLog(@"Devo scaricare il database all'indirizzo: %@", addressDownload);
        NSURL *url = [NSURL URLWithString:addressDownload];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        _connection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
        totalDownloaded = 0;
        totalData = [[NSMutableData alloc] init];
        
        NSString *detailtext = [addressDownload lastPathComponent];
        NSString *alertTitle = [NSLocalizedString(@"DATABASE_DOWNLOAD", nil) stringByAppendingString:detailtext];
        alert = [[UIAlertView alloc] initWithTitle:alertTitle message:@" " delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:nil];
        UIActivityIndicatorView *progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 40, 25, 25)];
        progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        [progress performSelectorInBackground:@selector(startAnimating) withObject:self];
        [alert addSubview:progress];
        progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        progressView.frame = CGRectMake(20, 70, 240, 5);
        progressView.progress = 0.0;
        [alert addSubview:progressView];
        [_connection start];
        [alert show];
    }
}

- (IBAction)saveButtonPressed:(UIButton *)sender {
    
    if ([self.tableView isEditing]) {
        return;
    }
    
    [_tfAddress resignFirstResponder];
    addressDownload = [[_tfAddress text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (addressDownload.length>0) {
        
        if (!linkArray) {
            linkArray = [[NSMutableArray alloc] init];
        }
        
        if ([linkArray containsObject:addressDownload]) {
            return;
        }
        
        [linkArray addObject:addressDownload];
        
        
        [self saveLinkToFile];
        
        //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        //NSString *rootPath = [paths objectAtIndex:0];
        //NSString *filePath = [rootPath stringByAppendingPathComponent:@"link.json"];
        //NSError *error = nil;
        //NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
        //[outputStream open];
        //[NSJSONSerialization writeJSONObject:linkArray toStream:outputStream options:0 error:&error];
        //[outputStream close];
        
        
        [_tableView reloadData];
    }
}

- (void) saveLinkToFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *rootPath = [paths objectAtIndex:0];
    NSString *filePath = [rootPath stringByAppendingPathComponent:@"link.json"];
    NSError *error = nil;
    NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    [outputStream open];
    [NSJSONSerialization writeJSONObject:linkArray toStream:outputStream options:0 error:&error];
    [outputStream close];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)viewDidUnload {
    [self setTfAddress:nil];
    [super viewDidUnload];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return linkArray.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell TBDownload";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.textLabel.text = [linkArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _tfAddress.text = [linkArray objectAtIndex:indexPath.row];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //NSLog(@"Devo eliminare la riga %d", indexPath.row);
        [linkArray removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
        [self saveLinkToFile];
        [_tfAddress setText:@""];
    }
}


#pragma mark - Download delegate

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [httpResponse statusCode];
    if (statusCode == 404) {
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        [_connection cancel];
        UIAlertView *noTwicAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DATABASE ND", nil) message:NSLocalizedString(@"DATABASE ND1", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [noTwicAlertView show];
        return;
    }
    NSString *contentLengthString = [[httpResponse allHeaderFields] objectForKey:@"Content-length"];
    //NSLog(@"ContentLength: %@", contentLengthString);
    downloadSize = [contentLengthString integerValue];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    totalDownloaded += [data length];
    //NSLog(@"Ricevuto dati %d", totalDownloaded);
    [totalData appendData:data];
    
    float percentByteDownloaded = 1.*totalDownloaded/downloadSize;
    //float percentByteDownloaded = 100.0*totalDownloaded/downloadSize;
    //NSLog(@"Percentuale scaricata = %f", percentByteDownloaded);
    [progressView setProgress:percentByteDownloaded];
    
    //NSNumber *twicSizeNumber = [NSNumber numberWithFloat:percentByteDownloaded];
    //NSString *twicSizeString = [NSString stringWithFormat:@"%@%%", [numberFormatter stringFromNumber:twicSizeNumber]];
    //hud.detailsLabelText = twicSizeString;
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSString *errore = NSLocalizedString(@"ERROR", nil);
    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:errore message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [errorAlertView show];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex:0];
    NSString *finalDatabasePath = [documentPath stringByAppendingPathComponent:[addressDownload lastPathComponent]];
    //NSLog(@"File 0 %@", finalDatabasePath);
    [totalData writeToFile:finalDatabasePath atomically:YES];
    
    if (totalData.length == 0) {
        NSLog(@"Non hai scaricato un piffero");
    }
    
    NSString *lastPathFile = [finalDatabasePath substringFromIndex:[finalDatabasePath length] - 3];
    if ([lastPathFile caseInsensitiveCompare:@"ZIP"] == NSOrderedSame) {
        ZipArchive *zipArchive = [[ZipArchive alloc] init];
        if ([zipArchive UnzipOpenFile:finalDatabasePath]) {
            if ([zipArchive UnzipFileTo:documentPath overWrite:YES] != NO) {
                [[NSFileManager defaultManager] removeItemAtPath:finalDatabasePath error:nil];
            }
        }
        else {
            UIAlertView *noTwicAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DATABASE ND", nil) message:NSLocalizedString(@"DATABASE ND1", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [noTwicAlertView show];
            [[NSFileManager defaultManager] removeItemAtPath:finalDatabasePath error:nil];
            [alert dismissWithClickedButtonIndex:0 animated:YES];
        }
    }
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    //[MBProgressHUD hideHUDForView:self.view animated:YES];
    
}

#pragma mark - AlertView delegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"Annullo il download");
    [_connection cancel];
}

@end
