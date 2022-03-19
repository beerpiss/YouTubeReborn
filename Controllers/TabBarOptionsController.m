#import "TabBarOptionsController.h"
#import "iOS15Fix.h"
#import "StartupPageOptionsController.h"

static int __isOSVersionAtLeast(int major, int minor, int patch) {
    NSOperatingSystemVersion version;
    version.majorVersion = major;
    version.minorVersion = minor;
    version.patchVersion = patch;
    return [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:version];
}

@interface TabBarOptionsController ()
@end

@implementation TabBarOptionsController

- (void)loadView {
    [super loadView];

    self.title = @"TabBar Options";
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
    return 2;
}

- (NSInteger)tableView:(UITableView*)theTableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideTabBar"] ? 1 : 6;
        default:
            return 0;
    }
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    static NSString* CellIdentifier = @"TabBarTableViewCell";
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
        if (indexPath.section == 0) {
            cell.textLabel.text = @"Startup Page";
            NSArray* titles =
                @[ @"Home", @"Explore", @"Shorts", @"Create/Upload (+)", @"Subscriptions", @"Library", @"Trending" ];
            int selectedTab = [[NSUserDefaults standardUserDefaults] integerForKey:@"kStartupPageInt"];
            cell.detailTextLabel.text = titles[selectedTab];
        }
        if (indexPath.section == 1) {
            NSArray* titles = @[
                @"Hide Tab Bar",
                @"Hide Tab Bar Labels",
                @"Hide Shorts/Explore Tab",
                @"Hide Create/Upload (+) Tab",
                @"Hide Subscriptions Tab",
                @"Hide Library Tab",
            ];
            NSArray* titlesNames = @[
                @"kHideTabBar",
                @"kHideTabBarLabels",
                @"kHideExploreTab",
                @"kHideUploadTab",
                @"kHideSubscriptionsTab",
                @"kHideLibraryTab",
            ];
            cell.textLabel.text = titles[indexPath.row];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch* toggleSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            [toggleSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
            toggleSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:titlesNames[indexPath.row]];
            cell.accessoryView = toggleSwitch;
        }
    }
    return cell;
}

- (void)tableView:(UITableView*)theTableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            StartupPageOptionsController* startupPageOptionsController = [[StartupPageOptionsController alloc] init];
            UINavigationController* startupPageOptionsControllerView =
                [[UINavigationController alloc] initWithRootViewController:startupPageOptionsController];
            startupPageOptionsControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

            [self presentViewController:startupPageOptionsControllerView animated:YES completion:nil];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 1:
            return 50;
        default:
            return 0;
    }
}

- (UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section {
    switch (section) {
        case 1:
            return 10;
        default:
            return 0;
    }
}

@end

@implementation TabBarOptionsController (Privates)
- (void)done {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)switchToggled:(UISwitch*)sender {
    UITableViewCell* cell = (UITableViewCell*)sender.superview;
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    NSArray* titlesNames = @[
        @"kHideTabBar",
        @"kHideTabBarLabels",
        @"kHideExploreTab",
        @"kHideUploadTab",
        @"kHideSubscriptionsTab",
        @"kHideLibraryTab",
    ];
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:titlesNames[indexPath.row]];
    if ([titlesNames[indexPath.row] isEqualToString:@"kHideTabBar"])
        [self.tableView reloadData];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
