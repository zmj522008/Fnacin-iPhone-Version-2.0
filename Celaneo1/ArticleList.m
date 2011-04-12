//
//  FirstViewController.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ArticleList.h"
#import "Celaneo1AppDelegate.h"
#import "MediaPlayer.h"

#define TAG_ITEM_A_LA_UNE 101
#define TAG_ITEM_PREFERE 102
#define TAG_ITEM_PODCAST 103
#define TAG_ITEM_RUBRIQUES 104
#define TAG_ITEM_DOSSIERS 105

@implementation ArticleList
@synthesize articles;
@synthesize table;
@synthesize favoris;
@synthesize prefere;
@synthesize podcast;
@synthesize rubriqueId;
@synthesize thematiqueId;
@synthesize magasinId;
@synthesize resetCache;

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
    [super viewDidLoad];
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
    self.articles = [NSMutableArray arrayWithCapacity:20];
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

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (favoris) {
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] 
                                                    initWithBarButtonSystemItem:UIBarButtonSystemItemTrash 
                                                        target:self action:@selector(showDelete)]];                                                                                                                                                
    }
}

- (void) showDelete
{
    [table setEditing:!table.editing animated:YES];
}

#pragma mark BaseController overrides

- (void) updateList:(ServerRequest*)request
{
    [articles removeObjectsInRange:NSMakeRange(request.limitStart, articles.count - request.limitStart)];
    if (request.articles.count) {
        [articles addObjectsFromArray:request.articles];
    }
    hasMore = [articles count] == request.limitEnd;
    hasMore = YES; // DEBUG
    [table reloadData];
}

- (ServerRequest*) doCreateListRequestWithStartingIndex:(int)startIndex
{
    ServerRequest* request = [[ServerRequest alloc] initArticle];
    
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
    int articlesPerPage = [Celaneo1AppDelegate getSingleton].articlesPerPage;
    if (articlesPerPage == 0) {
        articlesPerPage = 20;
    }
    request.limitStart = startIndex;
    request.limitEnd = startIndex + articlesPerPage;

    // Disable caching for pagination
    if (resetCache || startIndex > 0) {
        [request resetCache];
        resetCache = NO;
    }
    return request;
}

- (ServerRequest*) createListRequest
{
    return [self doCreateListRequestWithStartingIndex:0];
}
#pragma mark table view datasource


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *CellId = @"ArticleCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
        ArticleCellController* cellController;
        if (cell == nil) {
            cellController = (ArticleCellController*) [[ArticleCellController alloc] initWithNibName:@"ArticleCell" bundle:nil];
            cell = (UITableViewCell*) cellController.view;
            NSAssert2([CellId compare:cell.reuseIdentifier] == 0, @"Cell has invalid identifier, actual: %@, expected: %@", cell.reuseIdentifier, CellId);
        } else {
            cellController = [[ArticleCellController alloc] init];
            cellController.view = cell;
        }
        cellController.article = [articles objectAtIndex:indexPath.row];
        cellController.delegate = self;
        cellController.imageLoadingQueue = self.imageLoadingQueue;
        [cellController update];
        return cell;
    } else {
        static NSString *CellId = @"MoreCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
        }
        cell.textLabel.text = @"Plus d'articles...";
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? articles.count : 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return hasMore ? 2 : 1;
}

#pragma mark table view delegate 
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        ServerRequest* request = [self doCreateListRequestWithStartingIndex:articles.count];
        self.onlineRequest = request;
        onlineRequest.delegate = self;
        [onlineRequest start];
    }
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ServerRequest* changeRequest = 
            [[ServerRequest alloc] initSetFavoris:NO withArticleId:[[articles objectAtIndex:indexPath.row] articleId]];
        [changeRequest start];
        
        // Update article list: remove item
        self.resetCache = YES;
        [self doCreateListRequestWithStartingIndex:0];
        
        [articles removeObjectAtIndex:indexPath.row];
        [table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark article cell delegate
- (void) articleShowContent:(Article*) article
{
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Article" 
                                                        message:[NSString stringWithFormat:@"show article %d", article.articleId] 
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorView show];
    [errorView release];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) article:(Article*) article playMediaUrl:(NSString*) url withType:(int)type
{
    static int cnt = 0;
    if (cnt++ & 1) {
        url = @"http://www.etrezen.com/media/videos/massage_cadeau/conseils.mp4"; // DEBUG
    } else {
        url = @"http://members.dcsi.net.au/stefangr/mp3/Mr.%20Oizo%20-%20Flat%20Beat.mp3";
    }
    MediaPlayer* mediaPlayer = [[MediaPlayer alloc] initWithNibName:@"MediaPlayer" bundle:nil];
    mediaPlayer.movieUrl = [NSURL URLWithString:url];
    mediaPlayer.movieTitle = article.titre;
    [self.navigationController pushViewController:mediaPlayer animated:YES];
}

- (void) articleShowRubrique:(int) rId
{
    self.tabBarController.selectedIndex = 3;
    UINavigationController* rubriqueNavigationController = (UINavigationController*) self.tabBarController.selectedViewController;
    ArticleList* articleListController;
    if ([rubriqueNavigationController.topViewController isKindOfClass:[ArticleList class]]) {
        articleListController = (ArticleList*) rubriqueNavigationController.topViewController;
        articleListController.rubriqueId = rId;
        [articleListController refresh];
    } else {
        articleListController = [[ArticleList alloc] initWithNibName:@"ArticleList" bundle:nil];
        articleListController.rubriqueId = rId;
        [rubriqueNavigationController pushViewController:articleListController animated:YES];
    }
}

- (void) articleShowThematique:(int) tId
{
    ArticleList* articleListController = [[ArticleList alloc] initWithNibName:@"ArticleList" bundle:nil];
    articleListController.thematiqueId = tId;
    articleListController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:articleListController animated:YES];
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
