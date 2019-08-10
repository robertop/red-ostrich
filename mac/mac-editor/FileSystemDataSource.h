/**
 * Copyright (c) Roberto Perpuly.
 * Licensed under the MIT License. See LICENSE file in the project root for details.
 */

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * The type of item in the file system hierarchy.
 *
 * FS_PROJECTS_LIST: The root of the hierarchy
 * FS_MAIN_DIRECTORY: A directory that the user chose.
 * FS_DIRECTORY: A sub-directory of one of the main directories.
 * FS_FILE: A file.
 */
enum FileSystemTypes { FS_DIRECTORY, FS_FILE, FS_PROJECTS_LIST, FS_MAIN_DIRECTORY };

/**
 * One item to display in the file browser. This can represent either
 * a file or a directory.
 */
@interface FileSystemItem : NSObject {
    NSString *relativePath;
    NSString *rootPath;
    FileSystemItem *parent;
    NSMutableArray *children;
    enum FileSystemTypes type;
}

/*
 * Loads the children of item. Will perform disk access so it
 * may be slow.
 * There is no caching; calling loadChildren on the same item
 * twice will result in the disk being accessed twice.
 * The caller is in charge of caching as it sees fit.
 */
+ (NSMutableArray *)loadChildren:(FileSystemItem *)item;
- (id)initWithProjectsList;
- (id)initWithMainDirectory:(NSString *)path;
- (id)initWithPathAndParent:(NSString *)path parent:(FileSystemItem *)parentItem;
- (NSInteger)numberOfChildren;                   // Returns -1 for leaf nodes
- (FileSystemItem *)childAtIndex:(NSUInteger)n;  // Invalid to call on leaf nodes
- (NSString *)fullPath;
- (NSString *)relativePath;
- (BOOL)isValidDir;
- (enum FileSystemTypes)getType;
- (void)addChild:(FileSystemItem *)item;

@end

/**
 * The class that the file browser uses to get the files and directories to
 * display. We need to also handle the delegate protocol because the file browser
 * is a SourceList UI control. The source list UI control has custom data cells that
 * cocoa does not know how to display.
 */
@interface FileSystemDataSource : NSObject<NSOutlineViewDataSource, NSOutlineViewDelegate>

/**
 * The projects list. You can add items here  and they will be displayed in the directories list.
 */
@property FileSystemItem *projectTree;

/**
 * Initialize the data source.
 */
-(instancetype)init;

/**
 * Add a project to the files list. Once added, the caller needs to reload the
 * data in the outline view in order for the new directory to be shown.
 */
- (void)addProject:(FileSystemItem *)item;

@end

NS_ASSUME_NONNULL_END
