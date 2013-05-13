//
//  VotingViewController.h
//  Full of it
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"
@interface VotingViewController : UIViewController{
    Card *_card;
}


-(void)loadCard:(Card *)card;
@property (weak, nonatomic) IBOutlet UITableView *ipadTheTableView;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UITextView *answerTextView;
- (IBAction)submitLieAction:(id)sender;

@end
