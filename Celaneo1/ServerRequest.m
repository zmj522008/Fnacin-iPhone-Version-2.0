//
//  ServerRequest.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ServerRequest.h"

#define SERVER @"http://91.121.68.190:88/"

@implementation ServerRequest

@synthesize asiRequest;
@synthesize delegate;

#pragma mark Request constructors
- (id) initWithMethod:(NSString*)method
{
    [super init];
    if (self != nil) {
        self.asiRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[SERVER stringByAppendingString:method]]];
        asiRequest.delegate = self;
    }
    return self;
}

- (id) initAuthentificateWithEmail:(NSString*)email withPassword:(NSString*)password
{
    [self initWithMethod:@"authentificate"];
    if (self != nil) {
        [asiRequest setPostValue:email forKey:@"Email"];
        [asiRequest setPostValue:password forKey:@"Password"];
    }
    return self;
}

#pragma mark ASIFormDataRequest delegate handling
- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching binary data
    NSData *responseData = [request responseData];
    
    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:responseData];
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    parser.delegate = self;
    [parser parse];
    
    [delegate serverRequest:self didSucceedWithObject:nil];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    
    [delegate serverRequest:self didFailWithError:nil];
}

#pragma mark Generic XML Parsing

#pragma mark Application XML Parsing
// Thanks to this guy: http://www.levelofindirection.com/journal/2009/9/24/elegant-xml-parsing-with-objective-c.html

#pragma mark lifecycle
- (void) start
{
    [asiRequest startAsynchronous];
}

- (void) cancel
{
    [asiRequest clearDelegatesAndCancel];
}

- (void) dealloc
{
    [self cancel];
    [asiRequest release];

    [super dealloc];
}
@end
