//
//  AppDelegate.m
//  TestWaxPod
//
//  Created by junzhan on 15/10/15.
//  Copyright © 2015年 test.jz.com. All rights reserved.
//

#import "AppDelegate.h"
//#import "lauxlib.h"
#import "wax.h"
#import "ZipArchive.h"
#import "MainViewController.h"

#define WAX_PATCH_URL @"http://127.0.0.1/patch.zip"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (id)init {
    if(self = [super init]) {
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *dir = [doc stringByAppendingPathComponent:@"lua"];
        [[NSFileManager defaultManager] removeItemAtPath:dir error:NULL];
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:NULL];
        
        NSString *pp = [[NSString alloc ] initWithFormat:@"%@/patch/?.lua;%@/?/init.lua;", dir, dir];
        setenv(LUA_PATH, [pp UTF8String], 1);
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    wax_start(nil, nil);
//    wax_runLuaString("print('hello wax')");
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[MainViewController alloc] init];
    [self.window makeKeyAndVisible];
    
    [[[UIAlertView alloc] initWithTitle:@"WaxPatch" message:@"This is the obj-c impl of a simple table view. Press [Load] button to load the wax patch and run from lua." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Load", nil] show];
    
    
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == [alertView firstOtherButtonIndex]) {
        // you probably want to change this url before run
        NSURL *patchUrl = [NSURL URLWithString:WAX_PATCH_URL];
        NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:patchUrl] returningResponse:NULL error:NULL];
        if(data) {
            NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            NSString *patchZip = [doc stringByAppendingPathComponent:@"patch.zip"];
            [data writeToFile:patchZip atomically:YES];
            
            NSString *dir = [doc stringByAppendingPathComponent:@"lua"];
            [[NSFileManager defaultManager] removeItemAtPath:dir error:NULL];
            [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:NULL];
            
            ZipArchive *zip = [[ZipArchive alloc] init];
            [zip UnzipOpenFile:patchZip];
            [zip UnzipFileTo:dir overWrite:YES];
            
            NSString *pp = [[NSString alloc ] initWithFormat:@"%@/patch/?.lua;%@/?/init.lua;", dir, dir];
            setenv(LUA_PATH, [pp UTF8String], 1);
            wax_start("patch", nil);
            
//            wax_runLuaString("print('hello wax')");
            // reinit MainViewController again
            self.window.rootViewController = [[MainViewController alloc] init];
            [self.window makeKeyAndVisible];
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Fail to download wax patch from %@", patchUrl] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
