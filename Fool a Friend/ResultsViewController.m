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
    [super viewDidLoad];
    NSLog(@"add button to results");
    if (self.isReader){
        NSLog(@"inside if");
        _goVoteButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 100)/2,
                                                                     self.view.frame.size.height-70,
                                                                     100,
                                                                     44)];
        [_goVoteButton setTitle:@"Go Vote" forState:UIControlStateNormal];
        [_goVoteButton addTarget:self action:@selector(goVoteAction:) forControlEvents:UIControlEventTouchUpInside];
        _goVoteButton.backgroundColor = [UIColor redColor];
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
-(void)goVoteAction:(id)sender
{
    NSLog(@"go vote");
    [self.delegate sendAnswersToVote];
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
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}
@end
