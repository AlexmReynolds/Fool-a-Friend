//
//  VotingViewController.m
//  Full of it
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import "VotingViewController.h"


@interface VotingViewController ()

@end

@implementation VotingViewController

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
    CGSize size = [_card.question sizeWithFont:self.questionLabel.font constrainedToSize:self.questionLabel.frame.size lineBreakMode:UILineBreakModeWordWrap];
    self.questionLabel.frame = CGRectMake(self.questionLabel.frame.origin.x,
                                          self.questionLabel.frame.origin.y,
                                          size.width, size.height);
    self.questionLabel.text = _card.question;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.answerTextView action:@selector(resignFirstResponder)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self.answerTextView action:@selector(resignFirstResponder)],
                           nil];
    [numberToolbar sizeToFit];
    self.answerTextView.inputAccessoryView = numberToolbar;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadCard:(Card *)card
{
    _card = card;
}

- (void)viewDidUnload {
    [self setQuestionLabel:nil];
    [self setAnswerTextView:nil];
    [self setIpadTheTableView:nil];
    [super viewDidUnload];
}
- (IBAction)submitLieAction:(id)sender {
    if ([self.answerTextView.text length] > 0){
        [self.delegate playerDidAnswer:self.answerTextView.text];
    } else {
        NSLog(@"Answer not long enough");
    }
    if (!isIpad()){
        _resultsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"resultsViewController"];
        [self presentViewController:_resultsViewController animated:YES completion:nil];
    }

}

-(void)loadAnswers:(NSArray *)answers
{
    _answers = answers;
    if (!isIpad()){
        [_resultsViewController loadAnswers:answers];
    }
}

-(void) revealAnswers
{
    if (isIpad()){
        [self.ipadTheTableView reloadData];
    } else {
        [_resultsViewController showAnswers];
    }
}
#pragma mark - UITextField Delegate

-(void) textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Type your version of facts"]){
        textView.text = @"";
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
    
    cell.textLabel.text = [[_answers objectAtIndex:indexPath.row] objectForKey:@"answer"];
    
    return cell;
}
- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}
@end
