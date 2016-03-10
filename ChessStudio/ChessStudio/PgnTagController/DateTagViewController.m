//
//  DateTagViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 17/07/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "DateTagViewController.h"

@interface DateTagViewController () {

    UIDatePicker *datePicker;

    NSString *originalDate;
    UILabel *previousDateLabel;
    UILabel *newDateLabel;
    
    NSString *oggi;
    NSArray *oggiArray;
}

@end

@implementation DateTagViewController

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
    
    //NSString *buttonTitle = NSLocalizedString(@"DONE", @"Fatto");
    //UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:buttonTitle style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
    //self.navigationItem.leftBarButtonItem = doneButtonItem;
    
    //UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    //self.navigationItem.leftBarButtonItem = cancelButtonItem;
    //UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
    //self.navigationItem.rightBarButtonItem = doneButtonItem;
    
    UIView *view = [[UIView alloc] init];   //view
    view.backgroundColor = [UIColor grayColor];
    
    //UIView *contentView = [[UIView alloc] initWithFrame: [[UIScreen mainScreen] applicationFrame]];
    //[contentView setBackgroundColor: [UIColor lightGrayColor]];
    //[self setView: contentView];
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
    [datePicker setDatePickerMode: UIDatePickerModeDate];
    
    [datePicker addTarget:self action:@selector(dateChanged:)forControlEvents: UIControlEventValueChanged];
    
    [view addSubview:datePicker];                                                                                                                                                           
    self.view = view;
    
    previousDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 250, 200, 25)];
    previousDateLabel.backgroundColor = [UIColor clearColor];
    previousDateLabel.textColor = [UIColor whiteColor];
    previousDateLabel.text = [NSLocalizedString(@"OLD DATE", nil) stringByAppendingString:originalDate];
    //previousDateLabel.text = originalDate;
    [view addSubview:previousDateLabel];
    
    newDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 280, 200, 25)];
    newDateLabel.backgroundColor = [UIColor clearColor];
    newDateLabel.textColor = [UIColor yellowColor];
    [view addSubview:newDateLabel];
    
    
    NSRange range = [_previousDate rangeOfString:@"?"];
    if (range.location == NSNotFound) {
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"YYYY.MM.dd"];
        NSDate *date = [format dateFromString:_previousDate];
        [datePicker setDate:date];
    }
    

    [self dateChanged:datePicker];
    //[datePicker addTarget: self action: @selector(dateChanged:)forControlEvents: UIControlEventValueChanged];
    //[contentView addSubview: datePicker];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = NSLocalizedString(@"TAG_DATE", nil);
    
    if (!IS_PAD) {
        if (IS_PORTRAIT) {
            [datePicker setFrame:CGRectMake(0, 0, 320, 216)];
            [previousDateLabel setFrame:CGRectMake(60, 250, 200, 25)];
            [newDateLabel setFrame:CGRectMake(60, 280, 200, 25)];
        }
        else {
            if (IS_IPHONE_5) {
                [datePicker setFrame:CGRectMake(124.0, 0, 320, 150)];
                [previousDateLabel setFrame:CGRectMake(184, 180, 200, 25)];
                [newDateLabel setFrame:CGRectMake(184, 210, 200, 25)];
            }
            else {
                [datePicker setFrame:CGRectMake(80.0, 0, 320, 150)];
                [previousDateLabel setFrame:CGRectMake(140, 180, 200, 25)];
                [newDateLabel setFrame:CGRectMake(140, 210, 200, 25)];
            }
        }
    }
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (IS_PAD) {
        return;
    }
    if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) || (toInterfaceOrientation==UIInterfaceOrientationLandscapeLeft)) {
        if (IS_IPHONE_5) {
            [datePicker setFrame:CGRectMake(124.0, 0, 320, 150)];
            [previousDateLabel setFrame:CGRectMake(184, 180, 200, 25)];
            [newDateLabel setFrame:CGRectMake(184, 210, 200, 25)];
        }
        else {
            [datePicker setFrame:CGRectMake(80.0, 0, 320, 150)];
            [previousDateLabel setFrame:CGRectMake(140, 180, 200, 25)];
            [newDateLabel setFrame:CGRectMake(140, 210, 200, 25)];
        }
    }
    else {
        [datePicker setFrame:CGRectMake(0, 0, 320, 216)];
        [previousDateLabel setFrame:CGRectMake(60, 250, 200, 25)];
        [newDateLabel setFrame:CGRectMake(60, 280, 200, 25)];
    }
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {

}

- (void)dateChanged:(UIDatePicker *)sender {
    // TODO: Correct date format.
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"YYYY.MM.dd"];
    NSDate *newDate = [datePicker date];
    _nuovaData = [format stringFromDate:newDate];
    newDateLabel.text = [NSLocalizedString(@"NEW DATE", nil) stringByAppendingString:_nuovaData];
}

- (void) setPreviousDate:(NSString *)previousDate {
    
    NSDate *data = [[NSDate alloc] init];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"YYYY.MM.dd"];
    oggi = [format stringFromDate:data];
    oggiArray = [oggi componentsSeparatedByString:@"."];
    
    //NSLog(@"Oggi = %@", oggi);
    
    NSString *anno = @"";
    NSString *mese = @"";
    NSString *giorno = @"";
    
    
    //NSLog(@"PreviousDate = %@", previousDate);
    
    if (previousDate.length == 0 || [previousDate hasPrefix:@"?"]) {
        //previousDate = @"????.??.??";
        previousDate = oggi;
    }
    
    originalDate = previousDate;
    
    NSArray *previousDateArray = [previousDate componentsSeparatedByString:@"."];
    anno = [previousDateArray objectAtIndex:0];
    mese = [previousDateArray objectAtIndex:1];
    giorno = [previousDateArray objectAtIndex:2];
    
    if ([anno isEqualToString:@"????"]) {
        anno = [oggiArray objectAtIndex:0];
    }
    if ([mese isEqualToString:@"??"]) {
        mese = [oggiArray objectAtIndex:1];
    }
    if ([giorno isEqualToString:@"??"]) {
        giorno = [oggiArray objectAtIndex:2];
    }
    
    NSLog(@"anno = %@   mese = %@   giorno = %@", anno, mese, giorno);
    
    _previousDate = [[[[anno stringByAppendingString:@"."] stringByAppendingString:mese]stringByAppendingString:@"."] stringByAppendingString:giorno];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) doneButtonPressed {
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) cancelButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
