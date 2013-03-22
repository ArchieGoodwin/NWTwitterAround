//
//  NWManager.m
//  LookAround
//
//  Created by Sergey Dikarev on 2/8/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "NWManager.h"
#import <CoreLocation/CoreLocation.h>
#import "NWtwitter.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>
#import "AFNetworking.h"
#import "AFImageRequestOperation.h"
@implementation NWManager


- (id)init {
    self = [super init];
    
    _locationManager = [[CLLocationManager alloc] init];
	//_locationManager.distanceFilter = 5;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
	
    
#if !(TARGET_IPHONE_SIMULATOR)
    
    
#else
    
    
#endif
    
    
    
    return self;
    
}


#pragma mark  - helper methods




#pragma mark - Location methods

-(id)getSettingsValue:(NSString *)key
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults ];
	NSString *ret = [userDefaults objectForKey:key];
    return ret;
}

-(void)saveToUserDefaults:(id)object key:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:object forKey:key];
	[userDefaults synchronize];
    
}


-(void)startUpdateLocation
{
    [_locationManager startUpdatingLocation];
}

-(void)stopUpdateLocation
{
    [_locationManager stopUpdatingLocation];
}




#pragma mark - Location delegates

-(void) locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    //NSLog(@"Location updated to = %@",newLocation);
    
    
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
    //NSLog(@"time: %f", locationAge);
    
    if (newLocation.horizontalAccuracy < 0) return;
    
	// Needed to filter cached and too old locations
    //NSLog(@"Location updated to = %@", newLocation);
    CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:manager.location.coordinate.latitude longitude:manager.location.coordinate.longitude];
    CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
    double distance = [loc1 distanceFromLocation:loc2];
    if(distance > 5)
    {
        NSLog(@"SIGNIFICANTSHIFT");
        [[NSNotificationCenter defaultCenter] postNotificationName:chLocationMuchUpdated object:self userInfo:nil];
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:chLocationUpdated object:self userInfo:nil];
    
    
    
}



-(NSDictionary *)createDict:(NSString *)locName lat:(double)lat lng:(double)lng
{
    // 1. "id" в Foursquare 2. "name" 3. "latitude" 4. "longitude") о выбранной (либо заданной) POI.
    NSDictionary *resultDict = [[NSDictionary alloc] initWithObjectsAndKeys: locName, @"name", [NSString stringWithFormat:@"%.7f", lat], @"latitude", [NSString stringWithFormat:@"%.7f", lng], @"longitude", nil];
    return resultDict;
}


-(BOOL)isIphone5
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            CGFloat scale = [UIScreen mainScreen].scale;
            result = CGSizeMake(result.width * scale, result.height * scale);
            
            if(result.height == 960) {
                //NSLog(@"iPhone 4 Resolution");
                return NO;
            }
            if(result.height == 1136) {
                //NSLog(@"iPhone 5 Resolution");
                //[[UIScreen mainScreen] bounds].size =result;
                return YES;
            }
        }
        else{
            // NSLog(@"Standard Resolution");
            return NO;
        }
    }
    return NO;
}



- (void)getTwitterAround:(double)lat lng:(double)lng completionBlock:(NWgetTwitterAroundCompletionBlock)completionBlock
{
    NWgetTwitterAroundCompletionBlock completeBlock = [completionBlock copy];

    NSMutableArray *result = [NSMutableArray new];
    
    SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://search.twitter.com/search.json?"] parameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%.6f,%.6f,1km", lat, lng], @"geocode", @"100", @"rpp", nil]];
    [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Check if we reached the reate limit
            if ([urlResponse statusCode] == 429) {
                NSLog(@"Rate limit reached");
                return;
            }
            // Check if there was an error
            if (error) {
                NSLog(@"Error: %@", error.localizedDescription);
                return;
            }
            // Check if there is some response data
            if (responseData) {
                NSError *error = nil;
                NSArray *TWData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                // Filter the preferred data
                NSLog(@"%@", TWData);
                
                
                NSMutableArray *results = [((NSDictionary *)TWData) objectForKey:@"results"];
                for(NSMutableDictionary *dict in results)
                {
                    NWtwitter *twi = [[NWtwitter alloc] initWithDictionary:dict];
                    [result addObject:twi];
                }
                
                completeBlock(result, nil);

            }
        });
    }];

    
}





+(id)sharedInstance
{
    static dispatch_once_t pred;
    static NWManager *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[NWManager alloc] init];
    });
    return sharedInstance;
}

- (void)dealloc
{

    abort();
}






@end
