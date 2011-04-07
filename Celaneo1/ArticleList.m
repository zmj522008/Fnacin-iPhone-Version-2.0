//
//  FirstViewController.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ArticleList.h"

@implementation ArticleList
@synthesize articles;
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.table = nil;
}


- (void)dealloc
{
    [table release];
    [articles release];
    [super dealloc];
}


#pragma mark BaseController overrides

- (void) updateList:(ServerRequest*)request
{
    articles = request.articles;
    
    [table reloadData];
}

- (ServerRequest*) createListRequest
{
    return [[ServerRequest alloc] initListALaUne];
}

#pragma mark table view datasource


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellId = @"ArticleCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    if (cell == nil) {
        ArticleCellController* cellController = (ArticleCellController*) [[ArticleCellController alloc] initWithNibName:@"ArticleCell" bundle:nil];
        cell = (UITableViewCell*) cellController.view;
        cellController.article = [articles objectAtIndex:indexPath.row];
        cellController.delegate = self;
        [cellController update];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return articles.count;
}

#pragma mark table view delegate 

#pragma mark article cell delegate
- (void) articleShowContent:(Article*) article
{
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Article" 
                                                        message:[NSString stringWithFormat:@"show article %d", article.articleId] 
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorView show];
    [errorView release];
}
- (void) articlePlayMediaUrl:(NSString*) url withType:(int)type
{
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Article" 
                                                        message:[NSString stringWithFormat:@"play url %d %@", type, url] 
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorView show];
    [errorView release];    
}
- (void) articleShowRubrique:(int) rubriqueId
{
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Article" 
                                                        message:[NSString stringWithFormat:@"show rubrique %d", rubriqueId] 
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorView show];
    [errorView release];
 
}
- (void) articleShowThematique:(int) thematiqueId
{
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Article" 
                                                        message:[NSString stringWithFormat:@"show thematique %d", thematiqueId]
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorView show];
    [errorView release];
    
}
- (void) article:(Article*) article makeFavoris:(BOOL) favoris
{
    article.favoris = favoris;
    
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Article" 
                                                        message:[NSString stringWithFormat:@"article %d favoris: %d", article.articleId, favoris]
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorView show];
    [errorView release];
}

@end
