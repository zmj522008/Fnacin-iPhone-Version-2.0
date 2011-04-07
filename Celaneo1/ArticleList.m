//
//  FirstViewController.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ArticleList.h"

#import "ArticleCellController.h"

@implementation ArticleList
@synthesize articles;
@synthesize request;
@synthesize table;

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void) viewWillAppear:(BOOL)animated
{
    self.request = [[ServerRequest alloc] initListALaUne];
    request.delegate = self;
    [request start];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.table = nil;
}


- (void)dealloc
{
    [table release];
    [articles release];
    [request release];
    [super dealloc];
}


#pragma mark Handle server Response

- (void) serverRequest:(ServerRequest*)aRequest didSucceedWithObject:(id)result
{
    articles = aRequest.articles;
    
    [table reloadData];
}

#pragma mark table view datasource


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellId = @"ArticleCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    if (cell == nil) {
        ArticleCellController* cellController = (ArticleCellController*) [[ArticleCellController alloc] initWithNibName:@"ArticleCell" bundle:nil];
        cell = (UITableViewCell*) cellController.view;
        cellController.article = [articles objectAtIndex:indexPath.row];
        [cellController update];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return articles.count;
}

#pragma mark table view delegate 

@end
