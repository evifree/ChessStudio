//
//  RightSideViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 27/01/15.
//  Copyright (c) 2015 Giordano Vicoli. All rights reserved.
//

#import "RightSideViewController.h"
#import "SWRevealViewController.h"

@interface RightSideViewController ()

@end

@implementation RightSideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor yellowColor];
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

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    RightSideViewController *replacement = [[RightSideViewController alloc] init];
    if (self.view.backgroundColor == [UIColor yellowColor]) {
        replacement.view.backgroundColor = [UIColor redColor];
    }
    else if (self.view.backgroundColor == [UIColor redColor]) {
        replacement.view.backgroundColor = [UIColor greenColor];
    }
    else if (self.view.backgroundColor == [UIColor greenColor]) {
        replacement.view.backgroundColor = [UIColor orangeColor];
    }
    else if (self.view.backgroundColor == [UIColor orangeColor]) {
        replacement.view.backgroundColor = [UIColor blueColor];
    }
    else if (self.view.backgroundColor == [UIColor blueColor]) {
        replacement.view.backgroundColor = [UIColor yellowColor];
    }
    
    replacement.wantsCustomAnimation = YES;
    [self.revealViewController setRightViewController:replacement animated:YES];
}

@end
