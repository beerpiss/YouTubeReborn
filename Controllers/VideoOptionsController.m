#import "VideoOptionsController.h"
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

@interface VideoOptionsController ()
@end

@implementation VideoOptionsController

- (void)loadView {
    [super loadView];

    self.title = @"Video Options";
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
            return 10;
        case 1:
            return [[NSUserDefaults standardUserDefaults] boolForKey:@"kShowWhenVideoEnds"] ? 3 : 1;
        default:
            return 0;
    }
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    static NSString* CellIdentifier = @"VideoTableViewCell";
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
            @[
                @"Enable No Ads (Video/Home screen)",
                @"Enable Background Playback",
                @"Allow HD On Cellular Data",
                @"Auto Play In Fullscreen",
                @"Disable Video End Cards",
                @"Disable Video Info Cards",
                @"Disable Video Autoplay",
                @"Disable Double Tap To Skip",
                @"Hide Channel Watermark",
                @"Always Show Player Bar",
            ],
            @[
                @"Show When Video Ends",
                @"Show Seconds",
                @"Use 24 Hour Clock",
            ],
        ];
        NSArray* titlesNames = @[
            @[
                @"kEnableNoVideoAds",
                @"kEnableBackgroundPlayback",
                @"kAllowHDOnCellularData",
                @"kAutoFullScreen",
                @"kDisableVideoEndscreenPopups",
                @"kDisableVideoInfoCards",
                @"kDisableVideoAutoPlay",
                @"kDisableDoubleTapToSkip",
                @"kHideChannelWatermark",
                @"kAlwaysShowPlayerBar",
            ],
            @[
                @"kShowWhenVideoEnds",
                @"kShowSeconds",
                @"kUse24HourClock",
            ],
        ];
        cell.textLabel.text = titles[indexPath.section][indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISwitch* toggleSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [toggleSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
        toggleSwitch.on =
            [[NSUserDefaults standardUserDefaults] boolForKey:titlesNames[indexPath.section][indexPath.row]];
        cell.accessoryView = toggleSwitch;
    }
    return cell;
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 50;
    }
    return 0;
}

- (UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

@end

@implementation VideoOptionsController (Privates)

- (void)done {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)switchToggled:(UISwitch*)sender {
    UITableViewCell* cell = (UITableViewCell*)sender.superview;
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    NSArray* titlesNames = @[
        @[
            @"kEnableNoVideoAds",
            @"kEnableBackgroundPlayback",
            @"kAllowHDOnCellularData",
            @"kAutoFullScreen",
            @"kDisableVideoEndscreenPopups",
            @"kDisableVideoInfoCards",
            @"kDisableVideoAutoPlay",
            @"kDisableDoubleTapToSkip",
            @"kHideChannelWatermark",
            @"kAlwaysShowPlayerBar",
        ],
        @[
            @"kShowWhenVideoEnds",
            @"kShowSeconds",
            @"kUse24HourClock",
        ],
    ];
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:titlesNames[indexPath.section][indexPath.row]];
    if ([titlesNames[indexPath.section][indexPath.row] isEqualToString:@"kShowWhenVideoEnds"]) {
        [self.tableView beginUpdates];
        NSArray* indexPaths = @[[NSIndexPath indexPathForRow:1 inSection:1], [NSIndexPath indexPathForRow:2 inSection:1]];
        if (![sender isOn]) {
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
        }
        else {
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
        }
        [self.tableView endUpdates];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
