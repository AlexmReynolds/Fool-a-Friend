//
//  CardViewController.h
//  Full of it
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"
@class CardViewController;

@protocol CardViewControllerDelegate <NSObject>

-(void)sendQuestionToClients:(Card *)card;

@end
@interface CardViewController : UIViewController{
    Card *_card;
}

@property (weak, nonatomic) IBOutlet UITableView *theTableView;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) id <CardViewControllerDelegate> delegate;
- (IBAction)startAnswersAction:(id)sender;
- (IBAction)toggleAnswerPlayerNames:(id)sender;

-(void)loadCard:(Card *)card;
@end
