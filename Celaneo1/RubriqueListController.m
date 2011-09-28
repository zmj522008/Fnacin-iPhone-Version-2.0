//
//  SecondViewController.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GANTracker.h"
#import "RubriqueListController.h"
#import "ServerRequest.h"
#import "ArticleList.h"

#import "Celaneo1AppDelegate.h"

@implementation RubriqueListController

@synthesize rubriques;

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

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (NSString *)pageName
{
    return @"INTRAFNAC - THEMATIQUE";
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark BaseController overrides

- (void) updateList:(ServerRequest*)request parser:(ArticleParser*)parsed onlineContent:(BOOL)onlineContent;
{    
    self.rubriques = [parsed.rubriques sortedArrayUsingSelector:@selector(compare:)];
    
    [table reloadData];
}

- (ServerRequest*) createListRequest
{
    return [[ArticleParser alloc] getRequestGetRubriques];
}

#pragma mark table view datasource


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellId = @"RubriqueCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
    }
    cell.textLabel.text = [[rubriques objectAtIndex:indexPath.row] name];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return rubriques.count;
}

#pragma mark table view delegate 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[GANTracker sharedTracker] trackEvent:@"INTRAFNAC" action:@"THEMATIQUE" label:[[rubriques objectAtIndex:indexPath.row] name] value:nil withError:nil];

    NSString* nibName = @"ArticleList";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        nibName = [nibName stringByAppendingString:@"~iPad"];
    }

    ArticleList* controller = [[ArticleList alloc] initWithNibName:nibName bundle:nil];
    controller.rubriqueId = [[rubriques objectAtIndex:indexPath.row] categoryId];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
