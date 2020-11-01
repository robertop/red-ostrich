/**
 * Copyright (c) Roberto Perpuly.
 * Licensed under the MIT License. See LICENSE file in the project root for details.
 */

#import "ViewController.h"
#import "FileSystemDataSource.h"
@import Scintilla;

@interface ViewController ()

/*
 * Shows the "file" browser
 */
@property(weak) IBOutlet NSOutlineView* outlineView;

/*
 * The UI control that holds the source code editing UI control.
 */
@property(weak) IBOutlet NSStackView* editorView;

/*
 * The data source tells the file browser what items to display.
 */
@property FileSystemDataSource* dataSource;

/*
 * The source code editing UI control.
 */
@property ScintillaView* scintilla;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    NSView* parentView = self.editorView;

    self.scintilla = [[ScintillaView alloc] init];
    self.scintilla.translatesAutoresizingMaskIntoConstraints = false;
    NSLayoutConstraint* topConstraint =
        [self.scintilla.topAnchor constraintEqualToAnchor:parentView.topAnchor];
    NSLayoutConstraint* leftConstraint =
        [self.scintilla.leftAnchor constraintEqualToAnchor:parentView.leftAnchor];
    NSLayoutConstraint* widthConstraint =
        [self.scintilla.widthAnchor constraintEqualToAnchor:parentView.widthAnchor];
    NSLayoutConstraint* heightConstraint =
        [self.scintilla.heightAnchor constraintEqualToAnchor:parentView.heightAnchor];
    [parentView addConstraint:topConstraint];
    [parentView addConstraint:leftConstraint];
    [parentView addConstraint:widthConstraint];
    [parentView addConstraint:heightConstraint];
    [parentView addSubview:self.scintilla];
    [self.scintilla message:SCI_GRABFOCUS wParam:0 lParam:0];

    self.dataSource = [[FileSystemDataSource alloc] init];
    self.outlineView.dataSource = self.dataSource;
    self.outlineView.delegate = self.dataSource;
    [self.outlineView expandItem: self.dataSource.projectTree];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(onItemWillExpand:)
                                               name:NSOutlineViewItemWillExpandNotification
                                             object:nil];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (IBAction)onOutlineAction:(id)sender {
    NSInteger row = [self.outlineView selectedRow];
    FileSystemItem* item = [self.outlineView itemAtRow:row];
    if (![self.outlineView isExpandable:item]) {
        NSString* fullPath = [item fullPath];
        NSData* contents = [[[NSFileManager alloc] init] contentsAtPath:fullPath];
        char* data = malloc(contents.length + 1);
        if (data) {
            strncpy(data, contents.bytes, contents.length);
            data[contents.length] = 0;
            [self.scintilla message:SCI_SETTEXT wParam:(uptr_t)0 lParam:(sptr_t)data];
            free(data);
        }
    }
}

- (void)onItemWillExpand:(NSNotification*)notification {
    if (notification.object != self.outlineView) {
        return;
    }
    FileSystemItem* item = [notification.userInfo valueForKey:@"NSObject"];
    if (item == nil) {
        return;
    }
    if (![item isKindOfClass:FileSystemItem.class]) {
        return;
    }
}

- (void)addMainDirectory:(NSURL *)url {
    const char* root = [url fileSystemRepresentation];
    NSString* rootString = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:root length:strlen(root)];
    FileSystemItem* newRootItem = [[FileSystemItem alloc] initWithMainDirectory:rootString];
    [self.dataSource addProject:newRootItem];
    [self.outlineView reloadData];
    
    NSMutableIndexSet* set = [[NSMutableIndexSet alloc] init];
    [set addIndex:[self.outlineView rowForItem:newRootItem]];
    [self.outlineView selectRowIndexes:set byExtendingSelection:NO];
    [self.outlineView scrollRowToVisible:[set firstIndex]];
    [self.outlineView expandItem:newRootItem];
}

@end
