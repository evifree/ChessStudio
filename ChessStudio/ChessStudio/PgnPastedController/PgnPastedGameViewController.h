//
//  PgnPastedGameViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 14/11/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PgnPasteGameViewControllerDelegate <NSObject>

@optional
- (void) saveGames:(NSArray *)pastedGames;

@end

@interface PgnPastedGameViewController : UIViewController<UIAlertViewDelegate>

@property (nonatomic, assign) id<PgnPasteGameViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UITextView *pgnGameTextView;

@property (strong, nonatomic) NSString *callingViewController;

@end
