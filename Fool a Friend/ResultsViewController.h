//
//  ResultsViewController.h
//  Full of it
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ResultsViewController;

@protocol ResultsViewControllerDelegate <NSObject>

-(void)sendAnswersToVote;

@end
@interface ResultsViewController : UIViewController{
    UIButton *_goVoteButton;
}

@property (nonatomic, strong) NSArray *answers;
-(void)loadAnswers:(NSArray *)answers;


@property (weak, nonatomic) IBOutlet UITableView *theTableView;
@property (assign, nonatomic) BOOL isReader;
@property (weak, nonatomic) id <ResultsViewControllerDelegate> delegate;

-(void) showAnswers;
@end
