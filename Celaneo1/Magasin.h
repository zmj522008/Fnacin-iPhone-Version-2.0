//
//  Shop.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <Foundation/Foundation.h>
#import "CoreLocation/CLLocation.h"

#import "BaseItem.h"

@interface Magasin : BaseItem <MKAnnotation> {
    
}

- (CLLocationCoordinate2D) coordinate;

@end
