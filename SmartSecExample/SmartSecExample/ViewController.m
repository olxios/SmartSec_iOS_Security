//
//  ViewController.m
//  SmartSecExample
//
//  Created by Olga Dalton on 15/02/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "ViewController.h"

#import <SmartSec/SmartSec.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "TestEntity1.h"
#import "AppDelegate.h"
#import "SecondViewController.h"

@interface ViewController () <NSURLConnectionDelegate>
{
    IBOutlet UIImageView *_localImageView;
    IBOutlet UIImageView *_remoteImageView;
    
    IBOutlet UITextField *_testTextField;
}

@end

@implementation ViewController

#pragma mark -
#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    [self loadLocalImage];
    [self loadRemoteImage];
    [self accessCoreData];
    [self performURLRequest];
    
    [self performSelector:@selector(showSecondViewController)
               withObject:nil
               afterDelay:30.0f];
}

#pragma mark - 
#pragma mark - General methods

- (void)accessCoreData
{    
    TestEntity1 *entity = (TestEntity1 *)[TestEntity1 insertNewObjectIfNeeded:@"test2"];
    entity.itemID = @"test2";
    entity.attribute1 = @(8);
    entity.attribute4 = [[NSDecimalNumber alloc] initWithMantissa:100 exponent:23 isNegative:NO];
    entity.attribute6 = @(7.6f);
    entity.attribute7 = @"testing attributes :)";
    entity.attribute9 = [NSDate date];
    entity.attribute10 = [@"testing data attribute" dataUsingEncoding:NSUTF8StringEncoding];
    [DELEGATE saveContext];
    
    NSLog(@"Decimal number value: %@", entity.attribute4);
    NSLog(@"Date value: %@", entity.attribute9);
    
    TestEntity1 *entity2 = (TestEntity1 *)[TestEntity1 itemWithID:@"test2"];
    
    NSLog(@"ItemId = %@", entity2.itemID);
    NSLog(@"Attribute1 = %@, %@", entity2.attribute1, [entity2.attribute1 class]);
    NSLog(@"Attribute4 = %@, %@", entity2.attribute4, [entity2.attribute4 class]);
    NSLog(@"Attribute6 = %@, %@", entity2.attribute6, [entity2.attribute6 class]);
    NSLog(@"Attribute7 = %@, %@", entity2.attribute7, [entity2.attribute7 class]);
    NSLog(@"Attribute9 = %@, %@", entity2.attribute9, [entity2.attribute9 class]);
    NSLog(@"Attribute10 = %@, %@", [[NSString alloc] initWithData:entity2.attribute10 encoding:NSUTF8StringEncoding], [entity2.attribute10 class]);
}

- (void)loadLocalImage
{
    // The image could be loaded directly from the images
    // But the purpose of this test is to check image saving+encryption and loading back+decryption
    NSURL *docsUrl = [DELEGATE applicationDocumentsDirectory];
    NSString *path = [[docsUrl path] stringByAppendingPathComponent:@"test_image.png"];
    
    UIImage *image = [UIImage imageNamed:@"test_image"];
    
    NSData *data = UIImagePNGRepresentation(image);
    [data writeToFile:path atomically:YES];
    
    UIImage *resultImage2 = [UIImage imageWithContentsOfFile:path];
    _localImageView.image = resultImage2;
}

- (void)loadRemoteImage
{
    // Checking remote images compatibility
    [_remoteImageView sd_setImageWithURL:[NSURL URLWithString:@"http://swiftiostutorials.com/cat_pic.png"]
                      placeholderImage:nil];
}

- (void)showSecondViewController
{
    //enableDebuggerChecks();
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SecondViewController *controller = [storyBoard instantiateViewControllerWithIdentifier:@"SecondViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)dismissKeyboard:(id)sender
{
    [sender resignFirstResponder];
}

#pragma mark -
#pragma mark - Network request

- (void)performURLRequest
{
    //NSString *requestUrl = @"https://www.google.ee";
    //NSString *requestUrl = @"https://kosmos.infohaiku.com";
    NSString *requestUrl = @"https://twitter.com";
    NSURL *url = [NSURL URLWithString:requestUrl];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:5.0f];
    
    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}

#pragma mark -
#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    ReleaseLog(@"Connection did fail with error: %@/%@", connection, error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    ReleaseLog(@"Connection did finish loading %@", connection);
}

/*
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    ReleaseLog(@"Will send request for auth challenge: %@", challenge);
    
    NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    [challenge.sender useCredential:credential
         forAuthenticationChallenge:challenge];
}*/

@end
