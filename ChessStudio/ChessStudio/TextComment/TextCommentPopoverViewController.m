//
//  TextCommentPopoverViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 03/03/15.
//  Copyright (c) 2015 Giordano Vicoli. All rights reserved.
//

#import "TextCommentPopoverViewController.h"

@interface TextCommentPopoverViewController () {

    UITextView *textView;
    NSString *tempText;
}

@end

@implementation TextCommentPopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupTextView];
    self.navigationItem.title = [NSLocalizedString(@"TEXT_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
    
    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"MENU_SAVE", nil) style:UIBarButtonItemStyleDone target:self action:@selector(saveMenuButtonPressed:)];
    
    
    [[self navigationItem] setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(doneMenuButtonPressed:)]];
    [[self navigationItem] setRightBarButtonItem:saveBarButtonItem];
    
    
    [self.navigationController setPreferredContentSize:CGSizeMake(300, 400)];
}

- (void) setupTextView {
    
    CGFloat fontSize = 15.0;
    CGRect textFrame = self.view.frame;
    textFrame = CGRectMake(0, 0, 300, 400);
    textView = [[UITextView alloc] initWithFrame:textFrame];
    textView.font = [UIFont fontWithName:@"Courier" size:fontSize];
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    textView.textColor = [UIColor blueColor];
    textView.backgroundColor = UIColorFromRGB(0xFFFFA6);
    [self.view addSubview:textView];
    
    if (tempText) {
        textView.text = tempText;
    }
    else {
        if (_textBefore) {
            textView.text = [[_pgnMove textBefore] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        else {
            textView.text = [[_pgnMove textAfter] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) doneMenuButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) saveMenuButtonPressed:(id)sender {
    
    NSString *commento = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (commento.length == 0) {
        //NSLog(@"La stringa è nulla e la interpreto come nil");
        if (_textBefore) {
            [_pgnMove setTextBefore:nil];
        }
        else {
            [_pgnMove setTextAfter:nil];
        }
    }
    else {
        NSMutableString *comment = [[NSMutableString alloc] initWithString:@"{ "];
        [comment appendString:textView.text];
        [comment appendString:@" }"];
        if (_textBefore) {
            [_pgnMove setTextBefore:comment];
        }
        else {
            [_pgnMove setTextAfter:comment];
        }
    }
    if (_delegate) {
        [_delegate aggiornaCommentoFromTextPopover];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
