/**
 * Copyright (c) Roberto Perpuly.
 * Licensed under the MIT License. See LICENSE file in the project root for details.
 */

#import "FileSystemDataSource.h"

@implementation FileSystemItem

static FileSystemItem *rootItem = nil;
static NSMutableArray *leafNode = nil;

+ (void)initialize {
    if (self == [FileSystemItem class]) {
        leafNode = [[NSMutableArray alloc] init];
    }
}

- (id)initWithPath:(NSString *)path parent:(FileSystemItem *)parentItem {
    self = [super init];
    if (self) {
        relativePath = [[path lastPathComponent] copy];
        parent = parentItem;

        NSString *fullPath = [self fullPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        isValid = [fileManager fileExistsAtPath:fullPath isDirectory:&isDir];
    }
    return self;
}

+ (FileSystemItem *)rootItem {
    if (rootItem == nil) {
        rootItem = [[FileSystemItem alloc] initWithPath:@"/" parent:nil];
        [FileSystemItem loadChildren:rootItem];
    }
    return rootItem;
}

+ (NSMutableArray *)loadChildren:(FileSystemItem *)item {
    NSMutableArray *children;
    if (item == nil) {
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
                [[FileSystemItem alloc] initWithPath:[array objectAtIndex:i] parent:item];
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
    // If no parent, return our own relative path
    if (parent == nil) {
        return relativePath;
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
    return isValid && isDir;
}

@end

@implementation FileSystemDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    return (item == nil) ? 1 : [item numberOfChildren];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return (item == nil) ? YES : ([item isValidDir]);
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    return (item == nil) ? [FileSystemItem rootItem] : [(FileSystemItem *)item childAtIndex:index];
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
    if (item == nil) {
        cell = [outlineView makeViewWithIdentifier:@"HeaderCell" owner:self];
        cell.textField.stringValue = @"Files";
    } else {
        cell = [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
        if ([item isValidDir] || item == [FileSystemItem rootItem]) {
            cell.imageView.image = [NSImage imageNamed:NSImageNameFolder];
        } else {
            cell.imageView.image = [NSImage imageNamed:NSImageNameMultipleDocuments];
        }
        cell.textField.stringValue = [item relativePath];
    }
    return cell;
}

@end
