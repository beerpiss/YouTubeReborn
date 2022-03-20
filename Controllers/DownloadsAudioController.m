#import "DownloadsAudioController.h"
#import <MediaRemote/MediaRemote.h>
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

@interface DownloadsAudioController ()
@end

@implementation DownloadsAudioController

NSString* documentsDirectory;
NSMutableArray* filePathsAudioArray;
NSMutableArray* filePathsAudioArtworkArray;

- (void)loadView {
    [super loadView];

    [self setupLightDarkModeAudioView];

    if (@available(iOS 15.0, *)) {
        [self.tableView setSectionHeaderTopPadding:0.0f];
    }

    NSFileManager* fm = [[NSFileManager alloc] init];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];

    NSArray* filePathsList = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:documentsDirectory error:nil];
    filePathsAudioArray = [[NSMutableArray alloc] init];
    filePathsAudioArtworkArray = [[NSMutableArray alloc] init];
    for (id object in filePathsList) {
        if ([object containsString:@".m4a"]) {
            [filePathsAudioArray addObject:object];
            NSString* cut = [object substringToIndex:[object length] - 4];
            NSString* jpg = [NSString stringWithFormat:@"%@.jpg", cut];
            [filePathsAudioArtworkArray addObject:jpg];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return [filePathsAudioArray count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    static NSString* CellIdentifier = @"AudioDownloadsTableViewCell";
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
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    cell.textLabel.text = [filePathsAudioArray objectAtIndex:indexPath.row];
    return cell;
}

- (UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    MRMediaRemoteSendCommand(MRMediaRemoteCommandPause, 0);

    NSString* currentFileName = filePathsAudioArray[indexPath.row];
    NSString* filePath = [documentsDirectory stringByAppendingPathComponent:currentFileName];

    AVPlayerViewController* playerViewController = [AVPlayerViewController new];
    playerViewController.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:filePath]];
    playerViewController.allowsPictureInPicturePlayback = NO;
    if (@available(iOS 14.2, *)) {
        playerViewController.canStartPictureInPictureAutomaticallyFromInline = NO;
    }
    [playerViewController.player play];

    [self presentViewController:playerViewController animated:YES completion:nil];
}

- (void)traitCollectionDidChange:(UITraitCollection*)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self setupLightDarkModeAudioView];
    [self.tableView reloadData];
}

@end

@implementation DownloadsAudioController (Privates)

- (void)setupLightDarkModeAudioView {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
        self.view.backgroundColor = [UIColor colorWithRed:0.949 green:0.949 blue:0.969 alpha:1.0];
    } else {
        self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    }
}

@end
