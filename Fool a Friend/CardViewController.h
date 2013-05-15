//
//  CardViewController.h
//  Full of it
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"
#import "ResultsViewController.h"
@class CardViewController;

@protocol CardViewControllerDelegate <NSObject>

-(void)sendQuestionToClients:(Card *)card;
-(void)sendAnswersToVote;

@end
@interface CardViewController : UIViewController<ResultsViewControllerDelegate>{
    Card *_card;
    NSArray *_answers;
    ResultsViewController *_resultsViewController;
}
@property (weak, nonatomic) IBOutlet UIButton *showPlayerNamesButton;

@property (weak, nonatomic) IBOutlet UIButton *votingButton;
@property (weak, nonatomic) IBOutlet UITableView *theTableView;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) id <CardViewControllerDelegate> delegate;
- (IBAction)startAnswersAction:(id)sender;
- (IBAction)toggleAnswerPlayerNames:(id)sender;
- (IBAction)openVotingAction:(id)sender;

-(void)loadCard:(Card *)card;
-(void)loadAnswers:(NSArray *)answers;
@end
