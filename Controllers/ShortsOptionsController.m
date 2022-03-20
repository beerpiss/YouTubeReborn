#import "ShortsOptionsController.h"
#ifndef __IPHONE_15_0
    #import "iOS15Fix.h"
#endif

static int __isOSVersionAtLeast(int major, int minor, int patch) {
    NSOperatingSystemVersion version;
    version.majorVersion = major;
    version.minorVersion = minor;
    version.patchVersion = patch;
    return [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:version];
}

@interface ShortsOptionsController ()
@end

@implementation ShortsOptionsController

- (void)loadView {
    [super loadView];

    self.title = @"Shorts Options";
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
        self.view.backgroundColor = [UIColor colorWithRed:0.949 green:0.949 blue:0.969 alpha:1.0];
        [self.navigationController.navigationBar
            setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    } else {
        self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
        [self.navigationController.navigationBar
            setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    }

    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButton;

    if (@available(iOS 15.0, *)) {
        [self.tableView setSectionHeaderTopPadding:0.0f];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)theTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView*)theTableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    static NSString* CellIdentifier = @"ShortsTableViewCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell.textLabel.adjustsFontSizeToFitWidth = true;
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
            cell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
            cell.textLabel.textColor = [UIColor blackColor];
        } else {
            cell.backgroundColor = [UIColor colorWithRed:0.110 green:0.110 blue:0.118 alpha:1.0];
            cell.textLabel.textColor = [UIColor whiteColor];
        }
        NSArray* titles = @[
            @"Hide Camera Button",
            @"Hide More Actions Button",
            @"Hide Like Button",
            @"Hide Dislike Button",
            @"Hide Comments Button",
            @"Hide Share Button",
        ];
        NSArray* titlesNames = @[
            @"kHideShortsCameraButton",
            @"kHideShortsMoreActionsButton",
            @"kHideShortsLikeButton",
            @"kHideShortsDislikeButton",
            @"kHideShortsCommentsButton",
            @"kHideShortsShareButton",
        ];
        cell.textLabel.text = titles[indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISwitch* toggleSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [toggleSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
        toggleSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:titlesNames[indexPath.row]];
        cell.accessoryView = toggleSwitch;
    }
    return cell;
}

- (UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

@end

@implementation ShortsOptionsController (Privates)

- (void)done {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)switchToggled:(UISwitch*)sender {
    UITableViewCell* cell = (UITableViewCell*)sender.superview;
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    NSArray* titlesNames = @[
        @"kHideShortsCameraButton",
        @"kHideShortsMoreActionsButton",
        @"kHideShortsLikeButton",
        @"kHideShortsDislikeButton",
        @"kHideShortsCommentsButton",
        @"kHideShortsShareButton",
    ];
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:titlesNames[indexPath.row]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
