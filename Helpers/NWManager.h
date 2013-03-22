//
//  NWManager.h
//  LookAround
//
//  Created by Sergey Dikarev on 2/8/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#define chLocationUpdated @"LocationUpdated"
#define chLocationMuchUpdated @"LocationMuchUpdated"
typedef void (^NWgetTwitterAroundCompletionBlock)        (NSArray *result, NSError *error);


@interface NWManager : NSObject <CLLocationManagerDelegate>


@property (nonatomic, strong) CLLocationManager *locationManager;

+(id)sharedInstance;
-(void)startUpdateLocation;
-(NSDictionary *)createDict:(NSString *)locName lat:(double)lat lng:(double)lng;
-(BOOL)isIphone5;
- (void)getTwitterAround:(double)lat lng:(double)lng completionBlock:(NWgetTwitterAroundCompletionBlock)completionBlock;
-(id)getSettingsValue:(NSString *)key;
-(void)saveToUserDefaults:(id)object key:(NSString *)key;
@end
