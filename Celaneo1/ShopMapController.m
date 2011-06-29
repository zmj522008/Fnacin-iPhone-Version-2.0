//
//  ShopMap.m
//  FlowCover
//
//  Created by Sebastien Chauvin on 4/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "ShopMapController.h"
#import "Magasin.h"
#import "Magasins.h"
#import "CoreLocation/CLLocation.h"

#import "SaxModelParser.h"
#import "Celaneo1AppDelegate.h"

#define URL @"http://webservice.fnacin.com/magasin"

@implementation ShopMapController
@synthesize mapView;
@synthesize table;
@synthesize details;
@synthesize shop;
@synthesize list;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    
    [mapView release];
    [table release];
    [details release];
    [list release];
    [shop release];
    
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
    [self switchToList];
    [self mapCenterOnUser];
}

- (void) viewDidUnload
{
    self.mapView = nil;
    self.table = nil;
    self.details = nil;
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
#pragma mark server request

- (void) serverRequest:(ServerRequest*)request didSucceedWithObject:(id)result
{
    self.list = [((Magasins*)result) children];
    [table reloadData];
    [mapView removeAnnotations:mapView.annotations];
    [mapView addAnnotations:list];
}

- (ServerRequest *)createListRequest
{
    ServerRequest* request = [[ServerRequest alloc] initWithUrl:URL];
    SaxModelParser* parser = [[SaxModelParser alloc] init];
    parser.serverRequest = request;
    request.xmlParserDelegate = parser;
    if (request != nil) {
        NSString* sessionId = [Celaneo1AppDelegate getSingleton].sessionId;
        if (sessionId != nil) {
            [request setParameter:@"session_id" withValue:sessionId];
        }
    }
    
    return request;
}

#pragma mark UI Buttons
- (void) mapCenterOnUser
{
}

- (NSString*) digits:(NSString*)phone
{
    NSMutableString* target = [NSMutableString stringWithCapacity:10];
    for (int i = 0; i < phone.length; i++) {
        char c = (char) [phone characterAtIndex:i];
        if (c >= '0' && c <= '9') {
            [target appendFormat:@"%c", c];
        } else if (c != '+' && c != ' ') {
            break;
        }
    }

    return target;
}

- (void) updateShopDetailWithShop:(Magasin*) s
{
    self.shop = s;
    
    NSMutableString* content = [NSMutableString stringWithCapacity:1000];
    
    [content appendFormat:@"<h2>%@</h2><p>Adresse Postale:<br/>%@<br/>%@ %@ %@ %@<br/></p>",
     [s nom], [s adresse], [s code_postal], [s ville], [s region], [s pays]];
    
    if ([[s telephone] length] > 0) {
        [content appendFormat:@"<p>telephone: <a href='tel://%@'>%@</a></p>", [self digits:[s telephone]], [s telephone]];
    }

    if ([[s email] length] > 0) {
        [content appendFormat:@"<p>email: <a href='mailto://%@'>$@</a></p>", [s email], [s email]];
    }
    if ([[s billeterie] length] > 0) {
        [content appendFormat:@"<p>%@</p>", [s billeterie]];
    }
    if ([[s ouverture] length] > 0) {
        [content appendFormat:@"<p>%@</p>", [s ouverture]];
    }
    if ([[s ouverture_exceptionnelle] length] > 0) {
        [content appendFormat:@"<p>%@</p>", [s ouverture_exceptionnelle]];
    }
    [details loadHTMLString:content baseURL:nil];
    MKCoordinateRegion newRegion;
    
    newRegion.center.latitude = shop.coordinate.latitude;
    newRegion.center.longitude = shop.coordinate.longitude;        
    newRegion.span.latitudeDelta = 0.05;
    newRegion.span.longitudeDelta = 0.05;
    
    [mapView setRegion:newRegion animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
}

#pragma mark map view delegate

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    [self updateShopDetailWithShop:view.annotation];
    [self switchToDetail];
}

#pragma mark UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.table dequeueReusableCellWithIdentifier:@"ShopCell"];
    
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"ShopCell"] autorelease];
    }
    Magasin* shop = [list objectAtIndex:indexPath.row];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [shop nom];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return list.count;
}

- (void)mapView:(MKMapView *)mv didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (shop == nil) {
        MKCoordinateRegion newRegion;

        newRegion.center.latitude = mapView.userLocation.location.coordinate.latitude;
        newRegion.center.longitude = mapView.userLocation.location.coordinate.longitude;        
        newRegion.span.latitudeDelta = 0.5;
        newRegion.span.longitudeDelta = 0.5;
        
        [mapView setRegion:newRegion animated:YES];
    }
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateShopDetailWithShop:[list objectAtIndex:indexPath.row]];
    [self switchToDetail];
}

#pragma mark changeLayout
- (void) switchToMap
{
    mapView.hidden = NO;
    table.hidden = YES;
    details.hidden = YES;
    mapView.frame = self.view.bounds;
    
    MKCoordinateRegion newRegion;

    MKUserLocation* userLoc = mapView.userLocation;
    if (userLoc.location) {
        newRegion.center.latitude = userLoc.location.coordinate.latitude;
        newRegion.center.longitude = userLoc.location.coordinate.longitude;        
        newRegion.span.latitudeDelta = 0.5;
        newRegion.span.longitudeDelta = 0.5;
        
        [mapView setRegion:newRegion animated:YES];
    }

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithCustomView:[self navButton:NAVBUTTON_PLAIN withTitle:@"Liste" action:@selector(switchToList)]];
}

- (void) switchToDetail
{
    mapView.hidden = NO;
    table.hidden = YES;
    details.hidden = NO;
    mapView.frame = CGRectMake(0, 0, mapView.frame.size.width, details.frame.origin.y);
    
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithCustomView:[self navButton:NAVBUTTON_ARROW_LEFT withTitle:@"Liste" action:@selector(switchToList)]];
}

- (void) switchToList
{
    self.shop = nil;
    
    mapView.hidden = YES;
    table.hidden = NO;
    details.hidden = YES;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithCustomView:[self navButton:NAVBUTTON_PLAIN withTitle:@"Carte" action:@selector(switchToMap)]];
    [self updateLeftBarNavigationButton];
}
@end
