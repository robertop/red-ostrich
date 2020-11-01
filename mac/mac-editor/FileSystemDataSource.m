/**
 * Copyright (c) Roberto Perpuly.
 * Licensed under the MIT License. See LICENSE file in the project root for details.
 */

#import "FileSystemDataSource.h"

@implementation FileSystemItem

static NSMutableArray *leafNode = nil;

+ (void)initialize {
    if (self == [FileSystemItem class]) {
        leafNode = [[NSMutableArray alloc] init];
    }
}

- (id)initWithMainDirectory:(NSString *)path {
    self = [super init];
    if (self) {
        relativePath = [[path lastPathComponent] copy];
        rootPath = path;
        parent = nil;
        type = FS_MAIN_DIRECTORY;
        children = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithPathAndParent:(NSString *)path parent:(FileSystemItem *)parentItem {
    self = [super init];
    if (self) {
        relativePath = [[path lastPathComponent] copy];
        parent = parentItem;
        rootPath = nil;
        type = FS_FILE;

        NSString *fullPath = [self fullPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isValid = false;
        BOOL isDir = false;
        isValid = [fileManager fileExistsAtPath:fullPath isDirectory:&isDir];
        if (isValid && isDir) {
            type = FS_DIRECTORY;
        }
    }
    return self;
}

- (id)initWithProjectsList {
    self = [super init];
    if (self) {
        type = FS_PROJECTS_LIST;
        relativePath = @"Directories";
        parent = nil;
        children = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (NSMutableArray *)loadChildren:(FileSystemItem *)item {
    NSMutableArray *children;
    if (item == nil) {
        return children;
    }
    if (item->type == FS_PROJECTS_LIST) {
        return children;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fullPath = [item fullPath];

    if ([item isValidDir]) {
        NSArray *array = [fileManager contentsOfDirectoryAtPath:fullPath error:NULL];
        NSUInteger numChildren, i;

        numChildren = [array count];
        children = [[NSMutableArray alloc] initWithCapacity:numChildren];

        for (i = 0; i < numChildren; i++) {
            FileSystemItem *newChild =
                [[FileSystemItem alloc] initWithPathAndParent:[array objectAtIndex:i] parent:item];
            [children addObject:newChild];
        }
        [children sortUsingComparator:^NSComparisonResult(id a, id b) {
          return [[a relativePath] caseInsensitiveCompare:[b relativePath]];
        }];
    } else {
        children = leafNode;
    }
    item->children = children;
    return children;
}

- (NSString *)relativePath {
    return relativePath;
}

- (NSString *)fullPath {
    if (type == FS_MAIN_DIRECTORY) {
        return rootPath;
    }
    if (type == FS_PROJECTS_LIST) {
        return @"Projects";
    }

    // recurse up the hierarchy, prepending each parent’s path
    return [[parent fullPath] stringByAppendingPathComponent:relativePath];
}

- (FileSystemItem *)childAtIndex:(NSUInteger)n {
    return [children objectAtIndex:n];
}

- (NSInteger)numberOfChildren {
    NSArray *tmp = children;
    return (tmp == leafNode) ? (-1) : [tmp count];
}

- (BOOL)isValidDir {
    return type == FS_DIRECTORY || type == FS_MAIN_DIRECTORY;
}

- (enum FileSystemTypes) getType {
    return type;
}

- (void)addChild:(FileSystemItem*)item {
    if (children == nil) {
        children = [[NSMutableArray alloc] init];
    }
    [children addObject:item];
}

@end

@implementation FileSystemDataSource

- (instancetype)init {
    self = [super init];
    if (self) {
        self.projectTree = [[FileSystemItem alloc] initWithProjectsList];
    }
    return self;
}

- (void)addProject:(FileSystemItem*) item {
    [self.projectTree addChild:item];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (item == nil) {
        return 1;
    }
    // TODO(roberto): this is a file system operation and may block; not sure how to
    // re-architect the code to prevent UI freezes.
    [FileSystemItem loadChildren:item];
    return [item numberOfChildren];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if (item == nil) {
        return YES;
    }
    if ([item getType] == FS_PROJECTS_LIST) {
        return [item numberOfChildren] >= 0;
    }
    // TODO(roberto): this is a file system operation and may block; not sure how to
    // re-architect the code to prevent UI freezes.
    [FileSystemItem loadChildren:item];
    return [item isValidDir];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    // TODO(roberto): this is a file system operation and may block; not sure how to
    // re-architect the code to prevent UI freezes.
    [FileSystemItem loadChildren:item];
    return (item == nil) ? self.projectTree : [(FileSystemItem *)item childAtIndex:index];
}

- (id)outlineView:(NSOutlineView *)outlineView
    objectValueForTableColumn:(NSTableColumn *)tableColumn
                       byItem:(id)item {
    // does not seem to make a difference for Source Lists
    return (item == nil) ? @"/" : [item relativePath];
}

// This is the magic function that makes source lists work properly. A source list contains its own
// widgets that we need to set. NSOutlineView does not do this by default; it assumes each item
// in the outline view is a single cell. This is actually needed for the NSOutlineViewDelegate
// protocol not the NSOutlineViewDataSource protocol.
- (NSView *)outlineView:(NSOutlineView *)outlineView
     viewForTableColumn:(NSTableColumn *)tableColumn
                   item:(id)item {
    NSTableCellView *cell;
    if ([item getType] == FS_PROJECTS_LIST) {
        cell = [outlineView makeViewWithIdentifier:@"HeaderCell" owner:self];
        cell.textField.stringValue = [item relativePath];
    } else {
        cell = [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
        if ([item isValidDir] || [item getType] == FS_MAIN_DIRECTORY) {
            cell.imageView.image = [NSImage imageNamed:NSImageNameFolder];
        } else {
            cell.imageView.image = [NSImage imageNamed:NSImageNameMultipleDocuments];
        }
        cell.textField.stringValue = [item relativePath];
    }
    return cell;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item{
    return [item getType] != FS_PROJECTS_LIST;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item{
    return [item getType] == FS_PROJECTS_LIST;
}

@end
