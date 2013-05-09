//
//  HomeViewController.h
//  Full of it
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HostViewController.h"
#import "JoinViewController.h"
#import "GameViewController.h"

@interface HomeViewController : UIViewController<HostViewControllerDelegate, JoinViewControllerDelegate, GameViewControllerDelegate>{
    BOOL _buttonsEnabled;
}

- (IBAction)goHostAction:(id)sender;
- (IBAction)goJoinAction:(id)sender;

@end
