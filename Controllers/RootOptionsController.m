#import "RootOptionsController.h"
#import "../DTTJailbreakDetection/DTTJailbreakDetection.h"
#import "iOS15Fix.h"
#import "ColourOptionsController.h"
#import "CreditsController.h"
#import "DownloadsController.h"
#import "OverlayOptionsController.h"
#import "RebornSettingsController.h"
#import "SearchOptionsController.h"
#import "ShortsOptionsController.h"
#import "SponsorBlockOptionsController.h"
#import "TabBarOptionsController.h"
#import "UnderVideoOptionsController.h"
#import "VideoOptionsController.h"

static int __isOSVersionAtLeast(int major, int minor, int patch) {
    NSOperatingSystemVersion version;
    version.majorVersion = major;
    version.minorVersion = minor;
    version.patchVersion = patch;
    return [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:version];
}

@interface RootOptionsController ()
@end

@implementation RootOptionsController

- (id)init {
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (void)loadView {
    [super loadView];

    self.title = @"Options";
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
    self.navigationItem.leftBarButtonItem = doneButton;

    UIBarButtonItem* applyButton = [[UIBarButtonItem alloc] initWithTitle:@"Apply"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(apply)];
    self.navigationItem.rightBarButtonItem = applyButton;

    if (@available(iOS 15.0, *)) {
        [self.tableView setSectionHeaderTopPadding:0.0f];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)theTableView {
    return 5;
}

- (NSInteger)tableView:(UITableView*)theTableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    if (section == 1) {
        BOOL canOpenInFiles = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UISupportsDocumentBrowser"];
        BOOL canOpenInFilza = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"filza://"]];
        return 1 + canOpenInFiles + canOpenInFilza;
    }
    if (section == 2) {
        return 7;
    }
    if (section == 3) {
        return 9;
    }
    if (section == 4) {
        return 2;
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    static NSString* CellIdentifier = @"RootTableViewCell";
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
                cell.textLabel.text = @"Donate";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
        if (indexPath.section == 1) {
            NSMutableArray* titles = [NSMutableArray array];
            [titles addObject:@"View Downloads"];
            if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"UISupportsDocumentBrowser"]) {
                [titles addObject:@"View Downloads In Files"];
            }
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"filza://"]]) {
                [titles addObject:@"View Downloads In Filza"];
            }
            cell.textLabel.text = titles[indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if (indexPath.section == 2) {
            NSArray* titles = @[
                @"Video Options", @"Under-Video Options", @"Overlay Options", @"Tab Bar Options", @"Colour Options",
                @"Search Options", @"Shorts Options",
                @"SponsorBlock Options",  // TODO: Actually implement SponsorBlock
            ];
            cell.textLabel.text = titles[indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if (indexPath.section == 3) {
            NSArray* titles = @[
                @"Enable iPad Style On iPhone",
                @"Unlock UHD Quality",
                @"No Cast Button",
                @"No Notification Button",
                @"No Search Button",
                @"Disable YouTube Kids",
                @"Disable Hints",
                @"Hide YouTube Logo",
                @"Use Native Share Sheet",
            ];
            NSArray* titlesNames = @[
                @"kEnableiPadStyleOniPhone",
                @"kUnlockUHDQuality",
                @"kNoCastButton",
                @"kNoNotificationButton",
                @"kNoSearchButton",
                @"kDisableYouTubeKidsPopup",
                @"kDisableHints",
                @"kHideYouTubeLogo",
                @"kUseNativeShareSheet",
            ];
            cell.textLabel.text = titles[indexPath.row];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch* toggleSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            [toggleSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
            toggleSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:titlesNames[indexPath.row]];
            cell.accessoryView = toggleSwitch;
        }
        if (indexPath.section == 4) {
            NSArray* titles = @[ @"Reborn Settings", @"Credits" ];
            cell.textLabel.text = titles[indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    return cell;
}

- (void)tableView:(UITableView*)theTableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.patreon.com/lillieweeb"]
                                               options:@{}
                                     completionHandler:nil];
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            DownloadsController* downloadsController = [[DownloadsController alloc] init];
            UINavigationController* downloadsControllerView =
                [[UINavigationController alloc] initWithRootViewController:downloadsController];
            downloadsControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

            [self presentViewController:downloadsControllerView animated:YES completion:nil];
        }
        if (indexPath.row == 1 || indexPath.row == 2) {
            NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString* documentsDirectory = [paths objectAtIndex:0];
            BOOL canOpenInFiles = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UISupportsDocumentBrowser"];
            BOOL canOpenInFilza = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"filza://"]];
            if (canOpenInFiles && canOpenInFilza) {
                if (indexPath.row == 1) {
                    NSString* path = [NSString stringWithFormat:@"shareddocuments://%@", documentsDirectory];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:path]
                                                       options:@{}
                                             completionHandler:nil];
                }
                if (indexPath.row == 2) {
                    NSString* path = [NSString stringWithFormat:@"filza://view%@", documentsDirectory];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:path]
                                                       options:@{}
                                             completionHandler:nil];
                }
            } else if (canOpenInFiles) {
                if (indexPath.row == 1) {
                    NSString* path = [NSString stringWithFormat:@"shareddocuments://%@", documentsDirectory];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:path]
                                                       options:@{}
                                             completionHandler:nil];
                }
            } else if (canOpenInFilza) {
                if (indexPath.row == 1) {
                    NSString* path = [NSString stringWithFormat:@"filza://view%@", documentsDirectory];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:path]
                                                       options:@{}
                                             completionHandler:nil];
                }
            } else {
                // If you reach this place, then I guess View Downloads is your only option
            }
        }
    }
    if (indexPath.section == 2) {
        id optionsController;
        switch (indexPath.row) {
            case 0:
                optionsController = [[VideoOptionsController alloc] init];
                break;
            case 1:
                optionsController = [[UnderVideoOptionsController alloc] init];
                break;
            case 2:
                optionsController = [[OverlayOptionsController alloc] init];
                break;
            case 3:
                optionsController = [[TabBarOptionsController alloc] init];
                break;
            case 4:
                optionsController = [[ColourOptionsController alloc] init];
                break;
            case 5:
                optionsController = [[SearchOptionsController alloc] init];
                break;
            case 6:
                optionsController = [[ShortsOptionsController alloc] init];
                break;
            case 7:
                optionsController = [[SponsorBlockOptionsController alloc] init];
                break;
            default:
                break;
        }
        UINavigationController* optionsControllerView =
            [[UINavigationController alloc] initWithRootViewController:optionsController];
        optionsControllerView.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:optionsControllerView animated:YES completion:nil];
    }
    if (indexPath.section == 4) {
        id controller;
        switch (indexPath.row) {
            case 0:
                controller = [[RebornSettingsController alloc] init];
                break;
            case 1:
                controller = [[CreditsController alloc] init];
                break;
            default:
                break;
        }
        UINavigationController* controllerView = [[UINavigationController alloc] initWithRootViewController:controller];
        controllerView.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:controllerView animated:YES completion:nil];
    }
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray* sections = @[
        @"Downloads",
        @"Options",
        @"General Preferences",
        @"Others",
    ];
    if (section > 0) {
        return sections[section-1];
    }
    else return nil;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1 || section == 2 || section == 3 || section == 4) {
        return 40;
    }
    return 0;
}

- (NSString*)tableView:(UITableView*)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 4) {
        return @"Version: @YOUTUBE_REBORN_VERSION@";
    }
    return nil;
}

- (void)tableView:(UITableView*)tableView willDisplayFooterView:(UIView*)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView* footer = (UITableViewHeaderFooterView*)view;
    footer.textLabel.textAlignment = NSTextAlignmentCenter;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 4) {
        return 50;
    }
    return 0;
}

@end

@implementation RootOptionsController (Privates)

- (void)done {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)apply {
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[UIApplication sharedApplication] suspend];
    [NSThread sleepForTimeInterval:1.0];
    exit(0);
}

- (void)switchToggled:(UISwitch*)sender {
    UITableViewCell* cell = (UITableViewCell*)sender.superview;
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    NSArray* titlesNames = @[
        @"kEnableiPadStyleOniPhone",
        @"kUnlockUHDQuality",
        @"kNoCastButton",
        @"kNoNotificationButton",
        @"kNoSearchButton",
        @"kDisableYouTubeKidsPopup",
        @"kDisableHints",
        @"kHideYouTubeLogo",
        @"kUseNativeShareSheet",
    ];
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:titlesNames[indexPath.row]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
