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
    _showPlayerNames = NO;
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
    _showPlayerNames = !_showPlayerNames;
    [self.theTableView reloadData];
}

- (IBAction)openVotingAction:(id)sender {
    [self.delegate sendAnswersToVote];
    self.votingButton.hidden = YES;
    
    UIButton *nextRoundBtn = [[UIButton alloc] initWithFrame:self.votingButton.frame];
    [nextRoundBtn setTitle:@"Next Round" forState:UIControlStateNormal];
    [nextRoundBtn addTarget:self action:@selector(goNextRound) forControlEvents:UIControlEventTouchUpInside];
    nextRoundBtn.backgroundColor = [UIColor redColor];
    [self.view addSubview:nextRoundBtn];
}
-(void) goNextRound
{
    [self.delegate beginNextRound];
    [self dismissViewControllerAnimated:NO completion:nil];
}
-(void)beginNextRound
{
    [self.delegate beginNextRound];
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
-(void)updateVotes:(NSArray *)votes
{
    _votes = votes;
    if (isIpad()){
        [self.theTableView reloadData];
    } else {
        [_resultsViewController updateVotes:votes];
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
-(NSString *)getVotesForPeerID:(NSString *)peerID
{
    NSLog(@"get votes from card view controller %@", _votes);
        NSLog(@"peer ID is %@", peerID);
    NSString *votesString = @"";
    if (_votes){
        for (NSDictionary *vote in _votes){
            NSLog(@"in loop");
            if ([[vote objectForKey:@"peerID"] isEqualToString:peerID]){
                NSLog(@"found player %@ votes:%@", [vote objectForKey:peerID], [vote objectForKey:@"votes"]);
                votesString = [NSString stringWithFormat:@"(%@)",[vote objectForKey:@"votes"]];
                
            }
        }
    }
        NSLog(@"vote string is %@", votesString);
    return votesString;
}

-(void) gameTurnEnded:(void (^) (BOOL finished))completion{
    if (nil != _resultsViewController){
        [_resultsViewController dismissViewControllerAnimated:NO completion:nil];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
    if (completion){
        completion(YES);
    }
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
    NSString *answer = [[_answers objectAtIndex:indexPath.row] objectForKey:@"answer"];
    NSString *peerID = [[_answers objectAtIndex:indexPath.row] objectForKey:@"peerID"];
    NSString *name = _showPlayerNames ?  [[_answers objectAtIndex:indexPath.row] objectForKey:@"name"] : @"";
    NSString *votes = [self getVotesForPeerID:peerID];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ %@", answer, votes, name];
    
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
