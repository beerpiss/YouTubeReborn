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

- (id)init {
    return [super initWithStyle:UITableViewStyleGrouped];
}

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

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    if (@available(iOS 15.0, *)) {
        [self.tableView setSectionHeaderTopPadding:0.0f];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)theTableView {
    return 5;
}

- (NSInteger)tableView:(UITableView*)theTableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
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
        NSArray* titles = @[
            @[
                @"Lillie",
                @"beerpsi",
            ],
            @[
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
            ],
            @[
                @"Lillie",
                @"Sarah H",
                @"Zoey",
            ],
            @[
                @"Alpha_Stream",
            ],
            @[
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
            ],
        ];
        cell.textLabel.text = titles[indexPath.section][indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void)tableView:(UITableView*)theTableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray* urls = @[
        @[
            @"https://github.com/LillieWeeb001",
            @"https://github.com/beerpiss",
        ],
        @[
            @"https://twitter.com/drama_binny", @"https://twitter.com/cameren0", @"https://github.com/captinc",
            @"https://twitter.com/nikoyagamer", @"https://github.com/Emy", @"https://twitter.com/eveiyneee",
            @"https://twitter.com/hmuy0608", @"https://twitter.com/imlans10", @"https://twitter.com/riscv64",
            @"https://twitter.com/PoomSmart", @"https://twitter.com/sahmoee", @"https://twitter.com/deluxe_rosie",
            @"https://twitter.com/Banaantje04", @"https://twitter.com/Sloooopie", @"https://github.com/Worf1337"
        ],
        @[
            @"https://github.com/LillieWeeb001",
            @"https://github.com/SarahH12099",
            @"https://twitter.com/smolzoey",
        ],
        @[
            @"https://twitter.com/Kutarin_",
        ],
        @[
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
        ],
    ];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urls[indexPath.section][indexPath.row]]
                                       options:@{}
                             completionHandler:nil];
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray* sections = @[
        @"Developers",
        @"Special Thanks",
        @"Developers (v2)",
        @"Icon Designer (v2)",
        @"Special Thanks (v2)",
    ];
    return sections[section];
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
