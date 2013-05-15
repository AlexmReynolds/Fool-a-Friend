//
//  VotingViewController.h
//  Full of it
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"
#import "ResultsViewController.h"
@class VotingViewController;

@protocol VotingViewControllerDelegate <NSObject>

-(void)playerDidAnswer:(NSString *)answer;

@end
@interface VotingViewController : UIViewController{
    Card *_card;
    NSArray *_answers;
    ResultsViewController *_resultsViewController;
}


-(void)loadCard:(Card *)card;
@property (weak, nonatomic) IBOutlet UITableView *ipadTheTableView;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UITextView *answerTextView;
@property (weak, nonatomic) id <VotingViewControllerDelegate> delegate;
- (IBAction)submitLieAction:(id)sender;
-(void)loadAnswers:(NSArray *)answers;

@end
