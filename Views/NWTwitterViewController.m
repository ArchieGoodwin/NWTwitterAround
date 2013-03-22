//
//  NWTwitterViewController.m
//  LookAround
//
//  Created by Sergey Dikarev on 2/12/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "NWTwitterViewController.h"
#import "NWtwitter.h"
#import "NWTwitterCell.h"
#import "AFNetworking.h"
#import "NWLabel.h"
#import "NWManager.h"
#define NWHelper (NWManager *)[NWManager sharedInstance]
@interface NWTwitterViewController ()
{
    UIView *viewForLabel;
}
@end

@implementation NWTwitterViewController




- (void)showMessageView {
    viewForLabel = [[UIView alloc] initWithFrame:CGRectMake(20, 200, 280, 40)];
    viewForLabel.backgroundColor = [UIColor whiteColor];
    UILabel *lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 40)] ;
    lblMessage.backgroundColor = [UIColor clearColor];
    lblMessage.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    lblMessage.text = @"There are no tweets around there";
    lblMessage.textColor = [UIColor blackColor];
    lblMessage.textAlignment = NSTextAlignmentCenter;
    lblMessage.alpha = 0;
    [viewForLabel addSubview:lblMessage];
    [self.view addSubview:viewForLabel];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:2];
    [UIView setAnimationDelegate:self];
    
    lblMessage.alpha = 1;
    
    [UIView commitAnimations];
    
    
}


-(void)hideMessageView
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:3];
    [UIView setAnimationDelegate:self];
    
    viewForLabel.alpha = 0;
    
    [UIView commitAnimations];
    
    
}

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(realInit) name:chLocationUpdated object:nil];
    
    [super viewDidLoad];

}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(_tweets.count == 0)
    {
        [self showMessageView];
        [self hideMessageView];
    }
}

-(void)realInit
{
    
    [NWHelper getTwitterAround:[NWHelper locationManager].location.coordinate.latitude lng:[NWHelper locationManager].location.coordinate.longitude completionBlock:^(NSArray *result, NSError *error) {
        
        _tweets = result;
        
        [self.tableView reloadData];
        
       
        
    }];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:chLocationUpdated object:nil];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _tweets.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NWTwitterCell *cell = [tableView  dequeueReusableCellWithIdentifier:@"TweetMessage"];
    
    
    if(cell == nil)
    {
        NSArray *toplevel = [[NSBundle mainBundle ] loadNibNamed:@"TwitterCell" owner:nil options:nil];
        for(id cObject in toplevel)
        {
            if([cObject isKindOfClass:[UITableViewCell class]])
            {
                cell = (NWTwitterCell *)cObject;
                break;
            }
        }
    }
    
    
    NWtwitter *tweet = _tweets[indexPath.row];
    
    cell.lblText.text = tweet.message;
    
    cell.lblDate.text =  [NSDateFormatter localizedStringFromDate:tweet.dateCreated dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
    cell.lblAuthor.text = tweet.author;

    UIImage* image = [UIImage imageNamed:@"Placeholder.png"];
    [cell.imgProfile setImageWithURL:[NSURL URLWithString:tweet.iconUrl] placeholderImage:image];
    
    return cell;

}


#pragma mark - Table view delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:actionSheet.title]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    NWtwitter *tweet = _tweets[indexPath.row];
    
    if(tweet.author)
    {
        [[[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"https://twitter.com/%@", tweet.author] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Open Link in Safari", nil), nil] showInView:self.view];
        
    }
    

}

@end
