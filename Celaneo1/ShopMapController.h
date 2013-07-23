//
//  ShopMap.h
//  FlowCover
//
//  Created by Sebastien Chauvin on 4/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKMapView.h>
#import "BaseController.h"

@interface ShopMapController : BaseController <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate> {
    IBOutlet MKMapView* mapView;
    IBOutlet UITableView* table;
    IBOutlet UIWebView* details;
    
    NSMutableArray* list;
    NSMutableArray *stateIndex;
    NSMutableArray *listName;
    Magasin* shop;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UIWebView *details;
@property (nonatomic, retain) NSMutableArray *list;
@property (nonatomic, retain) Magasin* shop;

- (IBAction) switchToMap;
- (IBAction) switchToDetail;
- (IBAction) switchToList;

- (void) mapCenterOnUser;

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated;
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end
