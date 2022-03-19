#import "CreditsController.h"
#import "iOS15Fix.h"

static int __isOSVersionAtLeast(int major, int minor, int patch) {
    NSOperatingSystemVersion version;
    version.majorVersion = major;
    version.minorVersion = minor;
    version.patchVersion = patch;
    return [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:version];
}

@interface CreditsController ()
@end

@implementation CreditsController

- (void)loadView {
    [super loadView];

    self.title = @"Credits";
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
    return 5;
}

- (NSInteger)tableView:(UITableView*)theTableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    if (section == 1) {
        return 15;
    }
    if (section == 2) {
        return 3;
    }
    if (section == 3) {
        return 1;
    }
    if (section == 4) {
        return 13;
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    static NSString* CellIdentifier = @"CreditsTableViewCell";
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
                cell.textLabel.text = @"Lillie";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
        if (indexPath.section == 1) {
            NSArray* titles = @[
                @"Drama_Binny",
                @"cameren",
                @"Capt Inc.",
                @"Emma",
                @"Emy",
                @"evln",
                @"hmuy",
                @"Lans",
                @"Nick Chan",
                @"PoomSmart",
                @"Rick",
                @"Rosie",
                @"Sarah",
                @"Sloopie",
                @"Worf",
            ];
            cell.textLabel.text = titles[indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if (indexPath.section == 2) {
            NSArray* titles = @[
                @"Lillie",
                @"Sarah H",
                @"Zoey",
            ];
            cell.textLabel.text = titles[indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if (indexPath.section == 3) {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Alpha_Stream";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
        if (indexPath.section == 4) {
            NSArray* titles = @[
                @"Burnt Toast",
                @"cameren",
                @"Capt Inc.",
                @"Carlos C",
                @"Hayden",
                @"Kabir",
                @"MTAC",
                @"n3d",
                @"PoomSmart",
                @"PJ09",
                @"Rick",
                @"Swaggo",
                @"tale",
            ];
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
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/LillieWeeb001"]
                                               options:@{}
                                     completionHandler:nil];
        }
    }
    if (indexPath.section == 1) {
        NSArray* urls = @[
            @"https://twitter.com/drama_binny", @"https://twitter.com/cameren0", @"https://github.com/captinc",
            @"https://twitter.com/nikoyagamer", @"https://github.com/Emy", @"https://twitter.com/eveiyneee",
            @"https://twitter.com/hmuy0608", @"https://twitter.com/imlans10", @"https://twitter.com/riscv64",
            @"https://twitter.com/PoomSmart", @"https://twitter.com/sahmoee", @"https://twitter.com/deluxe_rosie",
            @"https://twitter.com/Banaantje04", @"https://twitter.com/Sloooopie", @"https://github.com/Worf1337"
        ];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urls[indexPath.row]]
                                           options:@{}
                                 completionHandler:nil];
    }
    if (indexPath.section == 2) {
        NSArray* urls = @[
            @"https://github.com/LillieWeeb001",
            @"https://github.com/SarahH12099",
            @"https://twitter.com/smolzoey",
        ];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urls[indexPath.row]]
                                           options:@{}
                                 completionHandler:nil];
    }
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/Kutarin_"]
                                               options:@{}
                                     completionHandler:nil];
        }
    }
    if (indexPath.section == 4) {
        NSArray* urls = @[
            @"https://twitter.com/btoastt",
            @"https://twitter.com/cameren0",
            @"https://github.com/captinc",
            @"https://twitter.com/KoukoCarlos",
            @"https://github.com/Diatrus",
            @"https://twitter.com/kabiroberai",
            @"https://twitter.com/MTAC8",
            @"https://twitter.com/45h20",
            @"https://twitter.com/PoomSmart",
            @"https://twitter.com/PJZeroNine",
            @"https://twitter.com/sahmoee",
            @"https://twitter.com/Swaggggggo",
            @"https://twitter.com/aarnavtale",
        ];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urls[indexPath.row]]
                                           options:@{}
                                 completionHandler:nil];
    }
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Developers";
    }
    if (section == 1) {
        return @"Special Thanks";
    }
    if (section == 2) {
        return @"Developers (v2)";
    }
    if (section == 3) {
        return @"Icon Designer (v2)";
    }
    if (section == 4) {
        return @"Special Thanks (v2)";
    }
    return nil;
}

- (void)tableView:(UITableView*)tableView willDisplayHeaderView:(UIView*)view forSection:(NSInteger)section {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
        view.tintColor = [UIColor colorWithRed:0.949 green:0.949 blue:0.969 alpha:1.0];
    } else {
        view.tintColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    }
    UITableViewHeaderFooterView* header = (UITableViewHeaderFooterView*)view;
    [header.textLabel setTextColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"tableSection"]]];
    [header.textLabel setFont:[UIFont systemFontOfSize:14]];
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0 || section == 1 || section == 2 || section == 3 || section == 4) {
        return 50;
    }
    return 0;
}

- (UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 4) {
        return 50;
    }
    return 0;
}

@end

@implementation CreditsController (Privates)

- (void)done {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
