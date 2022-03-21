#import "DownloadsController.h"
#ifndef __IPHONE_15_0
#import "iOS15Fix.h"
#endif
#import "DownloadsAudioController.h"
#import "DownloadsVideoController.h"

static int __isOSVersionAtLeast(int major, int minor, int patch) {
    NSOperatingSystemVersion version;
    version.majorVersion = major;
    version.minorVersion = minor;
    version.patchVersion = patch;
    return [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:version];
}

@interface DownloadsController ()
@end

@implementation DownloadsController
- (void)loadView {
    [super loadView];

    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.tabBar = [[UITabBarController alloc] init];

    DownloadsVideoController* videoViewController = [[DownloadsVideoController alloc] init];
    videoViewController.title = @"Video";
    videoViewController.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                      target:self
                                                      action:@selector(done)];
    ;
    UINavigationController* videoViewNavigation =
        [[UINavigationController alloc] initWithRootViewController:videoViewController];

    DownloadsAudioController* audioViewController = [[DownloadsAudioController alloc] init];
    audioViewController.title = @"Audio";
    audioViewController.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                      target:self
                                                      action:@selector(done)];
    UINavigationController* audioViewNavigation =
        [[UINavigationController alloc] initWithRootViewController:audioViewController];

    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
        self.view.backgroundColor = [UIColor colorWithRed:0.949 green:0.949 blue:0.969 alpha:1.0];
        [videoViewNavigation.navigationBar
            setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
        [audioViewNavigation.navigationBar
            setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    } else {
        self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
        [videoViewNavigation.navigationBar
            setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        [audioViewNavigation.navigationBar
            setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        videoViewNavigation.navigationBar.barStyle = UIBarStyleBlack;
        audioViewNavigation.navigationBar.barStyle = UIBarStyleBlack;
    }

    videoViewNavigation.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Video"
                                                                   image:[UIImage systemImageNamed:@"film"]
                                                           selectedImage:[UIImage systemImageNamed:@"film.fill"]];
    audioViewNavigation.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Audio"
                                                                   image:[UIImage systemImageNamed:@"music.note"]
                                                                     tag:0];

    self.tabBar.viewControllers = [NSArray arrayWithObjects:videoViewNavigation, audioViewNavigation, nil];

    [self.view addSubview:self.tabBar.view];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

@end

@implementation DownloadsController (Privates)

- (void)done {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
