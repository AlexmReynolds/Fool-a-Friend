//
//  CardViewController.m
//  Full of it
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import "CardViewController.h"
#import "ResultsViewController.h"

@interface CardViewController ()

@end

@implementation CardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.categoryLabel.text = [_card getCategoryText];
    [self loadQuestion];
    NSLog(@"cat is %@",[_card getCategoryText]);
	// Do any additional setup after loading the view.
}
-(void) loadQuestion
{

    CGSize size = [_card.question sizeWithFont:self.questionLabel.font constrainedToSize:self.questionLabel.frame.size lineBreakMode:UILineBreakModeWordWrap];
    self.questionLabel.frame = CGRectMake(self.questionLabel.frame.origin.x,
                                          self.questionLabel.frame.origin.y,
                                          size.width, size.height);
    self.questionLabel.text = _card.question;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startAnswersAction:(id)sender {
    [self.delegate sendQuestionToClients:_card];
    
    if (!isIpad()){
        NSLog(@"here in init results viewc");
        _resultsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"resultsViewController"];
        _resultsViewController.delegate = self;
        _resultsViewController.isReader = YES;
        [self presentViewController:_resultsViewController animated:YES completion:nil];
    }
}

- (IBAction)toggleAnswerPlayerNames:(id)sender {
}

- (IBAction)openVotingAction:(id)sender {
    [self.delegate sendAnswersToVote];
}

-(void)loadCard:(Card *)card
{
    NSLog(@"load card %@ cat:%i", card.question, card.category);
    _card = card;

}

-(void)loadAnswers:(NSArray *)answers
{
    
    _answers = answers;
    if (isIpad()){
        [self.theTableView reloadData];
    } else {
        [_resultsViewController loadAnswers:answers];
        [_resultsViewController showAnswers];
    }
}

- (void)viewDidUnload {
    [self setQuestionLabel:nil];
    [self setCategoryLabel:nil];
    [self setTheTableView:nil];
    [self setVotingButton:nil];
    [self setShowPlayerNamesButton:nil];
    [super viewDidUnload];
}

#pragma mark - TableDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_answers){
        return [_answers count];
    } else {
        return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"here in cell for row HOST");
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [[_answers objectAtIndex:indexPath.row] objectForKey:@"answer"];
    
    return cell;
}
- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

#pragma mark - ResultsView Delegate

-(void)sendAnswersToVote
{
    NSLog(@"go vote from card view");
    [self.delegate sendAnswersToVote];
}
@end
