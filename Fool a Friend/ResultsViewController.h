//
//  ResultsViewController.h
//  Full of it
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultsViewController : UIViewController

@property (nonatomic, strong) NSArray *answers;
-(void)loadAnswers:(NSArray *)answers;


@property (weak, nonatomic) IBOutlet UITableView *theTableView;
@end
