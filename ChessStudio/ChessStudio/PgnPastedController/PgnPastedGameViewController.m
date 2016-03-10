//
//  PgnPastedGameViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 14/11/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "PgnPastedGameViewController.h"
#import "DatabaseForCopyTableViewController.h"
#import "PGNPastedGame.h"

@interface PgnPastedGameViewController () {

    NSArray *pastedGamesArray;
    PGNPastedGame *pastedGame;
    NSDictionary *evaluationDictionary;
}

@end

@implementation PgnPastedGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void) awakeFromNib {

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    NSString *pastedString = [pasteBoard string];
    pastedGame = [[PGNPastedGame alloc] initWithPastedString:[pasteBoard string]];
    pastedGamesArray = [pastedGame getFinalPastedGames];
    evaluationDictionary = [pastedGame getEvaluationDictionary];
    
    [_pgnGameTextView setFont:[UIFont fontWithName:@"Courier" size:15]];
    [_pgnGameTextView setText:pastedString];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPgnGameTextView:nil];
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
    /*
    BOOL ok = YES;
    if (pastedGame) {
        for (NSString *g in pastedGamesArray) {
            NSNumber *ev = [evaluationDictionary objectForKey:g];
            NSInteger val = [ev integerValue];
            if ((val != -1) && (val != 0)) {
                ok = NO;
                break;
            }
        }
        UIAlertView *noPastedGames = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NO_VALID_GAME", nil) delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [noPastedGames show];
        return;
    }
    return;
    */
    if (pastedGame) {
        if (pastedGame.getEvaluation == PARTITA_INDEFINITA) {
            UIAlertView *noPastedGames = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NO_VALID_GAME", nil) delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [noPastedGames show];
            return;
        }
        else if (pastedGame.getEvaluation == PARTITA_CON_TAG_SENZA_MOSSE) {
            UIAlertView *noPastedGames = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NO_VALID_GAME", nil) delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [noPastedGames show];
            return;
        }
        else if (pastedGame.getEvaluation == PARTITA_SENZA_TAG_CON_MOSSE) {
            UIAlertView *noTagWithMoves = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"GAMES_WITHOUT_TAGS", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"MENU_CANCEL", nil) otherButtonTitles:@"Ok", nil];
            noTagWithMoves.tag = 100;
            [noTagWithMoves show];
            return;
        }
        else if (pastedGame.getEvaluation == PARTITA_CON_TAG_INCOMPLETI_CON_MOSSE) {
            UIAlertView *noPastedGames = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NO_VALID_GAME", nil) delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [noPastedGames show];
            return;
        }
    }
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButtonPressed:(id)sender {
    PGNPastedGame  *modifiedPastedGame = [[PGNPastedGame alloc] initWithPastedString:[_pgnGameTextView text]];
    NSArray *finalPastedGames = [modifiedPastedGame getFinalPastedGames];
    
    if (modifiedPastedGame.getEvaluation == PARTITA_SENZA_TAG_CON_MOSSE) {
        UIAlertView *noTagWithMoves = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"GAMES_WITHOUT_TAGS", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"MENU_CANCEL", nil) otherButtonTitles:@"Ok", nil];
        noTagWithMoves.tag = 100;
        [noTagWithMoves show];
        return;
    }
    
    if (modifiedPastedGame.getEvaluation != PARTITA_CON_TAG_E_MOSSE) {
        UIAlertView *noPastedGames = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NO_VALID_GAME", nil) delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [noPastedGames show];
        return;
    }
    
    if ([_callingViewController isEqualToString:@"TBDatabaseTableViewController"]) {
        DatabaseForCopyTableViewController *dctvc = [[DatabaseForCopyTableViewController alloc] initWithStyle:UITableViewStylePlain];
        [dctvc setGamesToCopyArray:finalPastedGames];
        [self.navigationController pushViewController:dctvc animated:YES];
        return;
    }
    
    if ([_callingViewController isEqualToString:@"PgnResultGamesTableViewController"]) {
        if (_delegate) {
            [_delegate saveGames:finalPastedGames];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    if ([_callingViewController isEqualToString:@"PgnFileInfoTableViewController"]) {
        if (_delegate) {
            [_delegate saveGames:finalPastedGames];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100) {
        if (buttonIndex>0) {
            [pastedGame aggiungiTuttiTag];
            pastedGamesArray = [pastedGame getFinalPastedGames];
            [_pgnGameTextView setText:@""];
            [_pgnGameTextView setText:[pastedGame getGamesForTextView]];
        }
    }
}

@end
