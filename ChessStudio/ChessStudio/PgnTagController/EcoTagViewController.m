//
//  EcoTagViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 19/07/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "EcoTagViewController.h"
#import "UtilToView.h"

@interface EcoTagViewController () {
    
    UIPickerView *ecoPicker;

    NSString *letterEco;
    NSString *firstNumberEco;
    NSString *secondNumberEco;

    NSInteger previousLettera;
    NSInteger previousPrimo;
    NSInteger previousSecondo;
    
    UILabel *previousEcoLabel;
    UILabel *newEcoLabel;
}

@end

@implementation EcoTagViewController

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
    
    //letterEco = @"A";
    //firstNumberEco = @"0";
    //secondNumberEco = @"0";
    
    UIView *view = [[UIView alloc] init];   //view
    view.backgroundColor = [UIColor grayColor];
    
    ecoPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
    ecoPicker.showsSelectionIndicator = YES;
    ecoPicker.delegate = self;
    [view addSubview:ecoPicker];
    self.view = view;
    
    
    if (IS_PHONE) {
        previousEcoLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 250, 200, 25)];
        previousEcoLabel.backgroundColor = [UIColor clearColor];
        previousEcoLabel.textColor = [UIColor whiteColor];
        previousEcoLabel.text = [NSLocalizedString(@"OLD ECO", nil) stringByAppendingString:_previousEco];
        [view addSubview:previousEcoLabel];
        
        newEcoLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 280, 200, 25)];
        newEcoLabel.backgroundColor = [UIColor clearColor];
        newEcoLabel.textColor = [UIColor yellowColor];
        newEcoLabel.text = [NSLocalizedString(@"NEW ECO", nil) stringByAppendingString:_selectedEco];
        [view addSubview:newEcoLabel];
    }
    

    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = @"ECO";
    
    [ecoPicker selectRow:previousLettera inComponent:0 animated:NO];
    [ecoPicker selectRow:previousPrimo inComponent:1 animated:NO];
    [ecoPicker selectRow:previousSecondo inComponent:2 animated:NO];
    
    if (!IS_PAD) {
        if (IS_PORTRAIT) {
            [ecoPicker setFrame:CGRectMake(0, 0, 320, 216)];
            [previousEcoLabel setFrame:CGRectMake(60, 250, 200, 25)];
            [newEcoLabel setFrame:CGRectMake(60, 280, 200, 25)];
        }
        else {
            if (IS_IPHONE_5) {
                [ecoPicker setFrame:CGRectMake(124.0, 0, 320, 150)];
                [previousEcoLabel setFrame:CGRectMake(184, 180, 200, 25)];
                [newEcoLabel setFrame:CGRectMake(184, 210, 200, 25)];
            }
            else {
                [ecoPicker setFrame:CGRectMake(80.0, 0, 320, 150)];
                [previousEcoLabel setFrame:CGRectMake(140, 180, 200, 25)];
                [newEcoLabel setFrame:CGRectMake(140, 210, 200, 25)];
            }
        }
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //[ecoPicker selectRow:previousLettera inComponent:0 animated:YES];
    //[ecoPicker selectRow:previousPrimo inComponent:1 animated:YES];
    //[ecoPicker selectRow:previousSecondo inComponent:2 animated:YES];
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
            [ecoPicker setFrame:CGRectMake(124.0, 0, 320, 150)];
            [previousEcoLabel setFrame:CGRectMake(184, 180, 200, 25)];
            [newEcoLabel setFrame:CGRectMake(184, 210, 200, 25)];
        }
        else {
            [ecoPicker setFrame:CGRectMake(80.0, 0, 320, 150)];
            [previousEcoLabel setFrame:CGRectMake(140, 180, 200, 25)];
            [newEcoLabel setFrame:CGRectMake(140, 210, 200, 25)];
        }
    }
    else {
        [ecoPicker setFrame:CGRectMake(0, 0, 320, 216)];
        [previousEcoLabel setFrame:CGRectMake(60, 250, 200, 25)];
        [newEcoLabel setFrame:CGRectMake(60, 280, 200, 25)];
    }
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {

}

- (void) setPreviousEco:(NSString *)previousEco {
    
    if ([previousEco hasPrefix:@"?"]) {
        previousEco = @"A00";
    }
    
    _previousEco = previousEco;
    _selectedEco = previousEco;
    
    
    letterEco = [previousEco substringToIndex:1];
    
    //const char *c = [let UTF8String];
    //unichar uc = [let characterAtIndex:0];
    
    previousLettera = [letterEco characterAtIndex:0] - 65;
    
    NSRange range = NSMakeRange(1, 1);
    firstNumberEco = [previousEco substringWithRange:range];
    range = NSMakeRange(2, 1);
    secondNumberEco = [previousEco substringWithRange:range];
    
    previousPrimo = [firstNumberEco integerValue];
    previousSecondo = [secondNumberEco integerValue];
}

#pragma mark - Metodi PickerView delegate

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return 5;
    }
    else if ((component == 1) || (component == 2)) {
        return 10;
    }
    //}
    return 0;
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return [[UtilToView getEcoLetterArray] objectAtIndex:row];
    }
    else {
        return [[UtilToView getEcoNumberArray] objectAtIndex:row];
    }
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        letterEco = [[UtilToView getEcoLetterArray] objectAtIndex:row];
    }
    else if (component == 1) {
        firstNumberEco = [[UtilToView getEcoNumberArray] objectAtIndex:row];
    }
    else {
        secondNumberEco = [[UtilToView getEcoNumberArray] objectAtIndex:row];
    }    
    _selectedEco = [[letterEco stringByAppendingString:firstNumberEco] stringByAppendingString:secondNumberEco];
    if (IS_PHONE) {
        newEcoLabel.text = [NSLocalizedString(@"NEW ECO", nil) stringByAppendingString:_selectedEco];
    }
}


@end
