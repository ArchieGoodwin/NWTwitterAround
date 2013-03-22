//
//  NWAppDelegate.h
//  NWTwitterAround
//
//  Created by Sergey Dikarev on 03/22/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NWTwitterViewController.h"

@class NWViewController;

@interface NWAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NWTwitterViewController *viewController;

@end