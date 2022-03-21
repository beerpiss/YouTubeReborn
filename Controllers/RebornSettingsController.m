#import "RebornSettingsController.h"
#import "../DTTJailbreakDetection/DTTJailbreakDetection.h"
#import "../Extensions/UIAlertController+Window.h"

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

@interface RebornSettingsController ()
@end

@implementation RebornSettingsController

- (id)init {
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (void)loadView {
    [super loadView];

    self.title = @"Reborn Options";
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
    return 3;
}

- (NSInteger)tableView:(UITableView*)theTableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    if (section == 1) {
        return 3;
    }
    if (section == 2) {
        return 1;
    }
    return 0;
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
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Reset Colour Options";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
        if (indexPath.section >= 1) {
            NSArray* titles = @[
                @[
                    @"Hide Overlay PIP Button",
                    @"Hide Overlay Download Button",
                    @"Hide Overlay Options Button",
                ],
                @[
                    @"Prevent Logouts For Sideloaded App",
                ],
            ];
            NSArray* titlesNames = @[
                @[
                    @"kHideRebornPIPButton",
                    @"kHideRebornDWNButton",
                    @"kHideRebornOPButton",
                ],
                @[ @"kPreventSideloadedLogouts" ],
            ];
            cell.textLabel.text = titles[indexPath.section - 1][indexPath.row];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch* toggleSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            [toggleSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
            toggleSwitch.on =
                [[NSUserDefaults standardUserDefaults] boolForKey:titlesNames[indexPath.section - 1][indexPath.row]];
            cell.accessoryView = toggleSwitch;
        }
    }
    return cell;
}

- (void)tableView:(UITableView*)theTableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kYTRebornColourOptionsV3"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            [[UIApplication sharedApplication] suspend];
            [NSThread sleepForTimeInterval:1.0];
            exit(0);
        }
    }
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1 || section == 2) {
        return 50;
    }
    return 0;
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray* sections = @[
        @"Overlay Buttons",
        @"Advanced",
    ];
    if (section > 0) {
        return sections[section - 1];
    } else
        return nil;
}

- (UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return 40;
    }
    return 0;
}

@end

@implementation RebornSettingsController (Privates)

- (void)done {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)switchToggled:(UISwitch*)sender {
    UITableViewCell* cell = (UITableViewCell*)sender.superview;
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    NSArray* titlesNames = @[
        @[
            @"kHideRebornPIPButton",
            @"kHideRebornDWNButton",
            @"kHideRebornOPButton",
        ],
        @[ @"kPreventSideloadedLogouts" ],
    ];
    // Reborn's PIP can only be used with Background Playback enabled
    if ([titlesNames[indexPath.section - 1][indexPath.row] isEqualToString:@"kHideRebornPIPButton"] &&
        ![[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableBackgroundPlayback"] && ![sender isOn]) {
        UIAlertController* alertMenu =
            [UIAlertController alertControllerWithTitle:@"Warning"
                                                message:@"Reborn's Picture in Picture requires background playback to "
                                                        @"be enabled.\nWould you like to enable it now?"
                                         preferredStyle:UIAlertControllerStyleAlert];
        [alertMenu addAction:[UIAlertAction actionWithTitle:@"Yes"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction* action) {
                                                      [[NSUserDefaults standardUserDefaults]
                                                          setBool:YES
                                                           forKey:@"kEnableBackgroundPlayback"];
                                                      [[NSUserDefaults standardUserDefaults]
                                                          setBool:[sender isOn]
                                                           forKey:titlesNames[indexPath.section - 1][indexPath.row]];
                                                    }]];
        [alertMenu addAction:[UIAlertAction actionWithTitle:@"No"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction* action) {
                                                      [sender setOn:YES animated:YES];
                                                      [[NSUserDefaults standardUserDefaults]
                                                          setBool:YES
                                                           forKey:titlesNames[indexPath.section - 1][indexPath.row]];
                                                    }]];
        [alertMenu show];

    } else if ([titlesNames[indexPath.section - 1][indexPath.row] isEqualToString:@"kPreventSideloadedLogouts"] &&
               ![DTTJailbreakDetection isJailbroken] && ![sender isOn]) {
        UIAlertController* alertMenu =
            [UIAlertController alertControllerWithTitle:@"Warning"
                                                message:@"It seems that you are sideloading YouTube.\n"
                                                        @"Disabling this option requires you to login to the app "
                                                        @"every time.\nWould you like to continue?"
                                         preferredStyle:UIAlertControllerStyleAlert];
        [alertMenu addAction:[UIAlertAction actionWithTitle:@"Yes"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction* action) {
                                                      [[NSUserDefaults standardUserDefaults]
                                                          setBool:[sender isOn]
                                                           forKey:titlesNames[indexPath.section - 1][indexPath.row]];
                                                    }]];
        [alertMenu addAction:[UIAlertAction actionWithTitle:@"No"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction* action) {
                                                      [sender setOn:YES animated:YES];
                                                      [[NSUserDefaults standardUserDefaults]
                                                          setBool:YES
                                                           forKey:titlesNames[indexPath.section - 1][indexPath.row]];
                                                    }]];
        [alertMenu show];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:[sender isOn]
                                                forKey:titlesNames[indexPath.section - 1][indexPath.row]];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
