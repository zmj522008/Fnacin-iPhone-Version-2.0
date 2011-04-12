//
//  SecondViewController.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PrefereEditController.h"
#import "ServerRequest.h"

@implementation PrefereEditController
@synthesize rubriques;
@synthesize selectedRubriques;
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
    [rubriques release];
    [selectedRubriques release];
    [table release];
    [super dealloc];
}

#pragma mark BaseController overrides

- (void) updateList:(ServerRequest*)request
{
    self.rubriques = request.rubriques;
    
    [table reloadData];
}

- (ServerRequest*) createListRequest
{
    return [[ServerRequest alloc] initGetRubriques];
}

#pragma mark table view datasource


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellId = @"PrefereEditCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
    }
    cell.textLabel.text = [[rubriques objectAtIndex:indexPath.row] name];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.editing = YES;
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
    [tableView cellForRowAtIndexPath:indexPath].accessoryType ^= UITableViewCellAccessoryCheckmark;
}

@end