//
//  PgnPastedGameDetailViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 20/11/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "PgnPastedGameDetailViewController.h"
#import "DatabaseForCopyTableViewController.h"

@interface PgnPastedGameDetailViewController () {

}

@end

@implementation PgnPastedGameDetailViewController

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
    
    [_gameTextView setText:[PGNPastedGame getGameForTextView:_selectedGameToPast]];
    
    if ([_pastedGame getEvaluationForGame:_selectedGameToPast] != 0) {
        UIBarButtonItem *correctBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"MENU_FIX_GAME", nil) style:UIBarButtonSystemItemAction target:self action:@selector(correctGameButtonPressed)];
        self.navigationItem.rightBarButtonItem = correctBarButtonItem;
    }
    else {
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"MENU_SAVE", nil) style:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];
        self.navigationItem.rightBarButtonItem = saveButton;
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setGameTextView:nil];
    [super viewDidUnload];
}

- (void) setSelectedGameToPast:(NSString *)selectedGameToPast {
    _selectedGameToPast = selectedGameToPast;
}

- (void) correctGameButtonPressed {
    NSString *newGame = [_pastedGame correctGame:_selectedGameToPast];
    [_gameTextView setText:[PGNPastedGame getGameForTextView:newGame]];
    _selectedGameToPast = newGame;
    if (_delegate) {
        [_delegate updateTable];
    }
    if ([_pastedGame getEvaluationForGame:newGame] == 0) {
        self.navigationItem.rightBarButtonItem = nil;
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];
        self.navigationItem.rightBarButtonItem = saveButton;
    }
}

- (void) saveButtonPressed {
    
    //NSString *modifiedText = [_gameTextView text];
    //[_pastedGame replaceGame:_selectedGameToPast :modifiedText];
    
    
    if ([_callingViewController isEqualToString:@"TBDatabaseTableViewController"]) {
        DatabaseForCopyTableViewController *dctvc = [[DatabaseForCopyTableViewController alloc] initWithStyle:UITableViewStylePlain];
        [dctvc setGamesToCopyArray:[NSArray arrayWithObject:_selectedGameToPast]];
        [self.navigationController pushViewController:dctvc animated:YES];
        return;
    }
    
    if ([_callingViewController isEqualToString:@"PgnFileInfoTableViewController"]) {
        if (_delegate) {
            [_delegate saveGame:_selectedGameToPast];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    if ([_callingViewController isEqualToString:@"PgnResultGamesTableViewController"]) {
        if (_delegate) {
            [_delegate saveGame:_selectedGameToPast];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
}

@end
