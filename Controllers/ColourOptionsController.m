#import "ColourOptionsController.h"
#import "../Extensions/UIColor+HexString.h"

@interface ColourOptionsController ()
@end

@implementation ColourOptionsController

- (void)loadView {
    [super loadView];

    self.title = @"Colour Options";
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

    UIBarButtonItem* saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(save)];
    self.navigationItem.rightBarButtonItem = saveButton;

    self.supportsAlpha = NO;
    UIColor* color = [UIColor
        rebornColorFromHexString:[[NSUserDefaults standardUserDefaults] stringForKey:@"kYTRebornColourOptionsV3"]];
    self.selectedColor = color;
}

@end

@implementation ColourOptionsController (Privates)

- (void)done {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)save {
    [[NSUserDefaults standardUserDefaults] setObject:self.selectedColor.hexString
                                              forKey:@"kYTRebornColourOptionsV3"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    UIAlertController* alertSaved = [UIAlertController alertControllerWithTitle:@"Colour Saved"
                                                                        message:nil
                                                                 preferredStyle:UIAlertControllerStyleAlert];

    [alertSaved addAction:[UIAlertAction actionWithTitle:@"OK"
                                                   style:UIAlertActionStyleCancel
                                                 handler:^(UIAlertAction* _Nonnull action){
                                                 }]];

    [self presentViewController:alertSaved animated:YES completion:nil];
}

@end
