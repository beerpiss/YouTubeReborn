#import "SponsorBlockOptionsController.h"
#import "../Extensions/UIColor+HexString.h"
#import "RebornTableCell.h"
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

@interface SponsorBlockOptionsController ()
@end

@implementation SponsorBlockOptionsController

- (id)init {
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (void)loadView {
    [super loadView];

    self.title = @"SponsorBlock Options";
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
    return 9;
}

- (NSInteger)tableView:(UITableView*)theTableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    if (section <= 8) {
        return 3;
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    static NSString* CellIdentifier = @"TabBarTableViewCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell.textLabel.adjustsFontSizeToFitWidth = true;
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
            cell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
            cell.textLabel.textColor = [UIColor blackColor];
        } else {
            cell.backgroundColor = [UIColor colorWithRed:0.110 green:0.110 blue:0.118 alpha:1.0];
            cell.textLabel.textColor = [UIColor whiteColor];
        }
        if (indexPath.section == 0) {
            cell.textLabel.text = @"Enable SponsorBlock";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch* toggleSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            [toggleSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
            toggleSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kRebornSponsorBlockEnabled"];
            cell.accessoryView = toggleSwitch;
        } else if (indexPath.section > 0 && indexPath.section < 9) {
            RebornTableCell* tableCell = [tableView dequeueReusableCellWithIdentifier:@"RebornTableCell2"];
            tableCell = [[RebornTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
            tableCell.textLabel.adjustsFontSizeToFitWidth = true;
            tableCell.accessoryType = UITableViewCellAccessoryNone;
            if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                tableCell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
                tableCell.textLabel.textColor = [UIColor blackColor];
            } else {
                tableCell.backgroundColor = [UIColor colorWithRed:0.110 green:0.110 blue:0.118 alpha:1.0];
                tableCell.textLabel.textColor = [UIColor whiteColor];
            }
            NSArray* titlesNames = @[
                @"kRebornSponsorBlockSponsor", @"kRebornSponsorBlockSelfPromo", @"kRebornSponsorBlockHighlight",
                @"kRebornSponsorBlockIntro", @"kRebornSponsorBlockOutro", @"kRebornSponsorBlockPreview",
                @"kRebornSponsorBlockFiller", @"kRebornSponsorBlockOffTopic"
            ];
            if (indexPath.row == 0) {
                NSArray* sponsorItemArray = @[ @"Disable", @"Auto Skip", @"Manual Skip", @"Show in Seek Bar" ];

                UISegmentedControl* sponsorSegmentedControl =
                    [[UISegmentedControl alloc] initWithItems:sponsorItemArray];

                // make it so "Show in Seek Bar" text won't be cut off on certain devices
                NSMutableArray* segments = [sponsorSegmentedControl valueForKey:@"_segments"];
                UISegment* segment = segments[3];
                UILabel* label = [segment valueForKey:@"_info"];
                label.adjustsFontSizeToFitWidth = YES;

                sponsorSegmentedControl.frame =
                    CGRectMake(0, 5, self.view.bounds.size.width, cell.bounds.size.height - 10);
                sponsorSegmentedControl.selectedSegmentIndex = [[[NSUserDefaults standardUserDefaults]
                    objectForKey:titlesNames[indexPath.section - 1]][@"status"] intValue];
                [sponsorSegmentedControl addTarget:self
                                            action:@selector(categorySegmentSelected:)
                                  forControlEvents:UIControlEventValueChanged];

                tableCell.selectionStyle = UITableViewCellSelectionStyleNone;
                [tableCell addSubview:sponsorSegmentedControl];
            } else if (1 <= indexPath.row && indexPath.row <= 2) {
                NSArray* titles = @[ @"Seek Bar Color", @"Unsubmitted Color" ];
                NSArray* colorTypes = @[ @"color", @"unsubmittedColor" ];
                tableCell.textLabel.text = titles[indexPath.row - 1];

                UIColorWell* colorWell = [[UIColorWell alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
                [colorWell addTarget:tableCell
                              action:@selector(presentColorPicker:)
                    forControlEvents:UIControlEventTouchUpInside];
                [colorWell addTarget:tableCell
                              action:@selector(colorWellValueChanged:)
                    forControlEvents:UIControlEventValueChanged];
                colorWell.selectedColor =
                    [UIColor rebornColorFromHexString:[[NSUserDefaults standardUserDefaults]
                                                          objectForKey:titlesNames[indexPath.section - 1]]
                                                          [colorTypes[indexPath.row - 1]]];
                tableCell.category = titlesNames[indexPath.section - 1];
                tableCell.colorType = colorTypes[indexPath.row - 1];
                tableCell.accessoryView = colorWell;
                tableCell.colorWell = colorWell;
            }
            return tableCell;
        }
    }
    return cell;
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray* titles = @[
        @"Sponsor", @"Unpaid/self promotion", @"Highlight", @"Intermission/Intro animation", @"Endcards/credits",
        @"Preview/recap", @"Filler", @"Music: Non-music section"
    ];
    if (section >= 1 && section <= 8)
        return titles[section - 1];
    else
        return nil;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    if (section <= 8) {
        return 50;
    }
    return 0;
}

- (UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 8) {
        return 10;
    }
    return 0;
}

@end

@implementation SponsorBlockOptionsController (Privates)

- (void)done {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)switchToggled:(UISwitch*)sender {
    UITableViewCell* cell = (UITableViewCell*)sender.superview;
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath.section == 0)
        [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:@"kRebornSponsorBlockEnabled"];
}

- (void)categorySegmentSelected:(UISegmentedControl*)sender {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSArray* titlesNames = @[
        @"kRebornSponsorBlockSponsor", @"kRebornSponsorBlockSelfPromo", @"kRebornSponsorBlockHighlight",
        @"kRebornSponsorBlockIntro", @"kRebornSponsorBlockOutro", @"kRebornSponsorBlockPreview",
        @"kRebornSponsorBlockFiller", @"kRebornSponsorBlockOffTopic"
    ];

    NSInteger idx = sender.selectedSegmentIndex;
    UITableViewCell* cell = (UITableViewCell*)sender.superview.superview;
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath.section >= 1) {
        NSMutableDictionary* categorySettings =
            [(NSDictionary*)[defaults objectForKey:titlesNames[indexPath.section - 1]] mutableCopy];
        [categorySettings setObject:[NSNumber numberWithInteger:idx] forKey:@"status"];
        [defaults setObject:categorySettings forKey:titlesNames[indexPath.section - 1]];
        [defaults synchronize];
    }
}

@end
