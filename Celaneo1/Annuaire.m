//
//  Annuaire.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.model = nil;
    self.searchOverlay = nil;
    self.searchBar = nil;
}

- (NSString *)pageName
{
    return @"annuaire/list";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Search bar delegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)s
{
    s.text = nil;
    [s resignFirstResponder];
    [self searchBar:s textDidChange:nil];
    searchOverlay.hidden = YES;
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)s
{
    model.indexShown = NO;
    searchOverlay.hidden = s.text.length > 0;
    [table reloadData];
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)s
{
    model.indexShown = s.text.length == 0;
    [table reloadData];
}

- (void)searchBar:(UISearchBar *)s textDidChange:(NSString *)searchText
{
    searchOverlay.hidden = searchText.length > 0;
    model.filtered = searchText.length > 0;
    
    [model setFilter:searchText];
    [table reloadData];
}

#pragma mark table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Personne* p = [model detailPersonneAtIndexPath:indexPath];
    
    NSString* nibName = @"annuaireDetail";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        nibName = [nibName stringByAppendingString:@"~iPad"];
    }
    
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
@end
