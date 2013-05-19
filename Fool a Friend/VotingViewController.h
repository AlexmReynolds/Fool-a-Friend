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
-(void)userVotedForPeer:(NSString *)peerID;

@end
@interface VotingViewController : UIViewController<ResultsViewControllerDelegate>{
    Card *_card;
    NSArray *_answers;
    ResultsViewController *_resultsViewController;
    NSString *_selectedAnswer;
}


-(void)loadCard:(Card *)card;
@property (weak, nonatomic) IBOutlet UITableView *ipadTheTableView;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UITextView *answerTextView;
@property (weak, nonatomic) id <VotingViewControllerDelegate> delegate;
- (IBAction)submitLieAction:(id)sender;
-(void)loadAnswers:(NSArray *)answers;
-(void)revealAnswers;
- (IBAction)voteAction:(id)sender;
-(void) gameTurnEnded:(void (^) (BOOL finished))completion;

@property (weak, nonatomic) IBOutlet UIButton *voteButton;
@end
