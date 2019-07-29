/**
 * Copyright (c) Roberto Perpuly.
 * Licensed under the MIT License. See LICENSE file in the project root for details.
 */

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * One item to display in the file browser. This can represent either
 * a file or a directory.
 */
@interface FileSystemItem : NSObject {
    NSString *relativePath;
    FileSystemItem *parent;
    NSMutableArray *children;
    BOOL isValid;
    BOOL isDir;
}

+ (FileSystemItem *)rootItem;
+ (NSMutableArray *)loadChildren:(FileSystemItem *)item;
- (NSInteger)numberOfChildren;                   // Returns -1 for leaf nodes
- (FileSystemItem *)childAtIndex:(NSUInteger)n;  // Invalid to call on leaf nodes
- (NSString *)fullPath;
- (NSString *)relativePath;
- (BOOL)isValidDir;

@end

/**
 * The class that the file browser uses to get the files and directories to
 * display. We need to also handle the delegate protocol because the file browser
 * is a SourceList UI control. The source list UI control has custom data cells that
 * cocoa does not know how to display.
 */
@interface FileSystemDataSource : NSObject<NSOutlineViewDataSource, NSOutlineViewDelegate>

@end

NS_ASSUME_NONNULL_END
