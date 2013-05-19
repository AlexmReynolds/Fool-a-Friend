//
//  ResultsViewController.m
//  Full of it
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import "ResultsViewController.h"

@interface ResultsViewController ()

@end

@implementation ResultsViewController
@synthesize answers = _answers;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self){
        self.isReader = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    _showPlayerNames = NO;
    [super viewDidLoad];
    NSLog(@"add button to results");
    if (self.isReader){
        NSLog(@"inside if");
        _goVoteButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2) - 105,
                                                                     self.view.frame.size.height-70,
                                                                     100,
                                                                     44)];
        [_goVoteButton setTitle:@"Go Vote" forState:UIControlStateNormal];
        [_goVoteButton addTarget:self action:@selector(goVoteAction:) forControlEvents:UIControlEventTouchUpInside];
        _goVoteButton.backgroundColor = [UIColor redColor];
        _goVoteButton.enabled = NO;
        [self.view addSubview:_goVoteButton];
        
        _showPlayerNamesButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2) + 5,
                                                                   self.view.frame.size.height-70,
                                                                   100,
                                                                   44)];
        [_showPlayerNamesButton setTitle:@"Show Names" forState:UIControlStateNormal];
        [_showPlayerNamesButton addTarget:self action:@selector(toggleAnswerPlayerNames:) forControlEvents:UIControlEventTouchUpInside];
        _showPlayerNamesButton.backgroundColor = [UIColor blueColor];
        _showPlayerNamesButton.enabled = NO;
        [self.view addSubview:_showPlayerNamesButton];
        
    } else {
        _goVoteButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 100)/2,
                                                                   self.view.frame.size.height-70,
                                                                   100,
                                                                   44)];
        [_goVoteButton setTitle:@"Submit Vote" forState:UIControlStateNormal];
        [_goVoteButton addTarget:self action:@selector(voteAction:) forControlEvents:UIControlEventTouchUpInside];
        _goVoteButton.backgroundColor = [UIColor greenColor];
        _goVoteButton.enabled = NO;
        [self.view addSubview:_goVoteButton];
    }
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTheTableView:nil];
    [super viewDidUnload];
}

-(void)loadAnswers:(NSArray *)answers{
    _answers = answers;
}

-(void)showAnswers
{
    if(_goVoteButton){
        _goVoteButton.enabled = YES;
    }
    [self.theTableView reloadData];
}
- (void)toggleAnswerPlayerNames:(id)sender {
    NSLog(@"toggle names");
    _showPlayerNames = !_showPlayerNames;
    [self.theTableView reloadData];
}
-(void)goVoteAction:(id)sender
{
    NSLog(@"go vote");
    _showPlayerNamesButton.enabled = YES;
    [self.delegate sendAnswersToVote];
    _goVoteButton.hidden = YES;
    UIButton *nextRound = [[UIButton alloc] initWithFrame:_goVoteButton.frame];
    [nextRound setTitle:@"Next Round" forState:UIControlStateNormal];
    [nextRound addTarget:self action:@selector(goNextRound) forControlEvents:UIControlEventTouchUpInside];
    nextRound.backgroundColor = [UIColor redColor];
    [self.view addSubview:nextRound];
}
-(void) goNextRound
{
    [self.delegate beginNextRound];
}
-(void)voteAction:(id)sender
{
    _goVoteButton.enabled = NO;
    NSLog(@"selected answer si %@", _selectedAnswer);
    [self.delegate userVotedForPeer:_selectedAnswer];
}

-(void) updateVotes:(NSArray *)votes
{
    _votes = votes;
    [self.theTableView reloadData];
}

-(NSString *)getVotesForPeerID:(NSString *)peerID
{
    NSLog(@"get vote for peer in results view %@", _votes);
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
    return indexPath;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    _selectedAnswer = [[_answers objectAtIndex:indexPath.row] objectForKey:@"peerID"];
    if(!self.isReader){
        _goVoteButton.enabled = YES;
    }
}
@end
