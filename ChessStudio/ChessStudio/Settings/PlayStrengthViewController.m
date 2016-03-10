//
//  PlayStrengthViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 13/12/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "PlayStrengthViewController.h"
#import "Options.h"

@interface PlayStrengthViewController ()

@end

@implementation PlayStrengthViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    UIView *contentView;
    CGRect r = [[UIScreen mainScreen] applicationFrame];
    
    [self setTitle: NSLocalizedString(@"ENGINE_STRENGTH", nil)];
    
    contentView = [[UIView alloc] initWithFrame: r];
    [contentView setBackgroundColor: [UIColor whiteColor]];
    [self setView: contentView];
    UIPickerView *picker = nil;
    
    if (IS_PAD) {
        picker = [[UIPickerView alloc] initWithFrame: CGRectMake(110.0f, 64.0f, 320.0f, 220.0f)];
    }
    else {
        picker = [[UIPickerView alloc] initWithFrame: CGRectMake(0.0f, 64.0f, 320.0f, 220.0f)];
    }
    
    [picker setDelegate: self];
    [picker setDataSource: self];
    [picker setShowsSelectionIndicator: YES];
    [picker selectRow: 80 - (([[Options sharedOptions] strength] - 500) / 25) inComponent: 0 animated: NO];
    [contentView addSubview: picker];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 81;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    //return [NSString stringWithFormat: @"%d", 20 - (int)row];
    return [NSString stringWithFormat:@"%d", (int)(500 + (80 -row) * 25)];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //[[Options sharedOptions] setStrength: 20 - (int)row];
    [[Options sharedOptions] setStrength: (int)(500 + (80 - row) * 25)];
    if (_delegate) {
        [_delegate aggiornaPlayStrengthInTable];
    }
    //NSLog(@"new strength: %d", [[Options sharedOptions] strength]);
    //[parentController updateTableCells];
}

@end
