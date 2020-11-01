/**
 * Copyright (c) Roberto Perpuly.
 * Licensed under the MIT License. See LICENSE file in the project root for details.
 */

#import "AppDelegate.h"
#import "ViewController.h"

/*
 * The application delegate is where cocoa notifies us about UI or application
 * events. These are events related to the operating system and UI widgets, not
 * events of our "domain model" (editor events).
 */

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification {
}

- (void)applicationWillTerminate:(NSNotification*)aNotification {
}
- (IBAction)onFolderOpen:(id)sender {
    NSWindow* window = [NSApp mainWindow];
    ViewController* viewController = (ViewController*)[window contentViewController];

    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    openPanel.canCreateDirectories = false;
    openPanel.canChooseFiles = false;
    openPanel.canChooseDirectories = true;
    NSModalResponse response = [openPanel runModal];
    if (response == NSModalResponseOK) {
        NSArray* urls = [openPanel URLs];
        NSURL* url = [urls firstObject];
        if (url != nil) {
            [viewController addMainDirectory:url];
        }
    }
}

@end
