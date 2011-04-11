//
//  FirstViewController.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ArticleList.h"
#import "Celaneo1AppDelegate.h"

#define TAG_ITEM_A_LA_UNE 101
#define TAG_ITEM_PREFERE 102
#define TAG_ITEM_PODCAST 103
#define TAG_ITEM_RUBRIQUES 104
#define TAG_ITEM_DOSSIERS 105

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

- (void)viewDidLoad
{
    int tag = self.navigationController.tabBarItem.tag | self.tabBarItem.tag;
    switch (tag) {
        case TAG_ITEM_A_LA_UNE:
            break;
        case TAG_ITEM_PREFERE:
            prefere = YES;
            break;
        case TAG_ITEM_PODCAST:
            podcast = YES;
            break;
        case TAG_ITEM_RUBRIQUES:
            break;
        case TAG_ITEM_DOSSIERS:
            favoris = YES;
            break;
        default:
            break;
    }
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

- (ServerRequest*) doCreateListRequestWithStartingIndex:(int)startIndex
{
    ServerRequest* request = [[ServerRequest alloc] initArticle];
    
    if (NO) {
    if (favoris) {
        [request setParameter:@"favoris" withValue:@"1"];
    }
    if (prefere) {
        [request setParameter:@"prefere" withValue:@"1"];
    }
    if (podcast) {
        [request setParameter:@"podcast" withValue:@"1"];
    }
    if (thematiqueId > 0) {
        [request setParameter:@"thematique_id" withIntValue:thematiqueId];
    }
    if (rubriqueId > 0) {
        [request setParameter:@"rubrique_id" withIntValue:rubriqueId];
    }
    if (magasinId > 0) {
        [request setParameter:@"magasin_id" withIntValue:magasinId];
    }
    [request setParameter:@"limit_start" withIntValue:startIndex];
    [request setParameter:@"limit_end" withIntValue:startIndex + [Celaneo1AppDelegate getSingleton].articlesPerPage];

    // Disable caching for pagination
    if (resetCache || startIndex > 0) {
        [request resetCache];
        resetCache = NO;
    }
    }
    return request;
}

- (ServerRequest*) createListRequest
{
    return [self doCreateListRequestWithStartingIndex:0];
}
#pragma mark table view datasource


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellId = @"ArticleCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    if (cell == nil) {
        ArticleCellController* cellController = (ArticleCellController*) [[ArticleCellController alloc] initWithNibName:@"ArticleCell" bundle:nil];
        cell = (UITableViewCell*) cellController.view;
        NSAssert2([CellId compare:cell.reuseIdentifier] == 0, @"Cell has invalid identifier, actual: %@, expected: %@", cell.reuseIdentifier, CellId);
        cellController.article = [articles objectAtIndex:indexPath.row];
        cellController.delegate = self;
        cellController.imageLoadingQueue = self.imageLoadingQueue;
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
- (void) articleShowRubrique:(int) rId
{
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Article" 
                                                        message:[NSString stringWithFormat:@"show rubrique %d", rId] 
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorView show];
    [errorView release];
 
}
- (void) articleShowThematique:(int) tId
{
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Article" 
                                                        message:[NSString stringWithFormat:@"show thematique %d", tId]
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorView show];
    [errorView release];
    
}
- (void) article:(Article*) article makeFavoris:(BOOL) on
{
    article.favoris = on;
    
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Article" 
                                                        message:[NSString stringWithFormat:@"article %d favoris: %d", article.articleId, favoris]
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorView show];
    [errorView release];
}

@end
