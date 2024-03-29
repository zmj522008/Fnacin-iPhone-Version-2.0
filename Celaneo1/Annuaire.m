//
//  Annuaire.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GANTracker.h"

#import "Annuaire.h"

#import "Celaneo1AppDelegate.h"
#import "annuaireDetail.h"

@implementation Annuaire

@synthesize model;
@synthesize table;
@synthesize searchBar;
@synthesize searchOverlay;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    [model release];
    [table release];
    [searchBar release];
    [searchOverlay release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.model = [Celaneo1AppDelegate getSingleton].annuaireModel;
    model.indexShown = YES;
    table.dataSource = model;
    table.canCancelContentTouches = YES;
    [table setSectionIndexMinimumDisplayRowCount:10];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.model = nil;
    self.searchOverlay = nil;
    self.searchBar = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable) name:AnnuaireModelDataStatusChange object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)pageName
{
    return @"INTRAFNAC - ANNUAIRE";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Search bar delegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)s
{
    NSLog(@"searchBarCancelButtonClicked");
    s.text = nil;
    [s resignFirstResponder];
    [self searchBar:s textDidChange:nil];
    searchOverlay.hidden = YES;
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)s
{
    NSLog(@"searchBarTextDidBeginEditing");

    model.indexShown = NO;
    searchOverlay.hidden = s.text.length > 0;
    [table reloadData];
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)s
{
    NSLog(@"searchBarTextDidEndEditing");

    model.indexShown = s.text.length == 0;
    [table reloadData];
}

- (void)searchBar:(UISearchBar *)s textDidChange:(NSString *)searchText
{
    NSLog(@"textDidChange");

    searchOverlay.hidden = searchText.length > 0;
    model.filtered = searchText.length > 0;
    
    [model setFilter:searchText];
    [table reloadData];
}

#pragma mark table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[GANTracker sharedTracker] trackEvent:@"INTRAFNAC" action:@"ANNUAIRE" label:nil value:nil withError:nil];

    Personne* p = [model detailPersonneAtIndexPath:indexPath];
    
    NSString* nibName = @"annuaireDetail";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        nibName = [nibName stringByAppendingString:@"~iPad"];
    }
    
    NSLog(@"cell clicked");
    annuaireDetail* controller = [[annuaireDetail alloc] initWithNibName:nibName bundle:nil];
    controller.personne = p;
    [model tableView:table cellForRowAtIndexPath:indexPath].highlighted = NO;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [searchBar resignFirstResponder];
    searchOverlay.hidden = YES;
    
}

- (void) refreshTable
{
    [table reloadData];
}
@end
