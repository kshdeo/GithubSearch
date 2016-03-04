//
//  FilterViewController.m
//  Github Search
//
//  Created by Kshitij-Deo on 22/01/16.
//

#import "FilterViewController.h"

@interface FilterViewController ()
{
    NSMutableDictionary *settings;
}
@property (weak, nonatomic) IBOutlet UILabel *followerLabel;
@property (weak, nonatomic) IBOutlet UISlider *followerSlider;
@property (weak, nonatomic) IBOutlet UITextField *languageField;
@property (weak, nonatomic) IBOutlet UITextField *locationField;

@end

@implementation FilterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    settings = [[[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS] mutableCopy];
    if (!settings) {
        settings = [NSMutableDictionary new];
    } else {
        int followers = 10;
        if ([settings objectForKey:SETTINGS_FOLLOWERS]) {
            followers = [[settings objectForKey:SETTINGS_FOLLOWERS] intValue];
            self.followerLabel.text = [NSString stringWithFormat:@"Number of followers: %i",followers];
        }
        [self.followerSlider setValue:followers];
        [self.languageField setText:[settings objectForKey:SETTINGS_LANGUAGE]?:@""];
        [self.locationField setText:[settings objectForKey:SETTINGS_LOCATION]?:@""];
    }
}

- (IBAction)followersChanged:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    self.followerLabel.text = [NSString stringWithFormat:@"Number of followers: %i",(int)slider.value];
    [settings setObject:[NSNumber numberWithInt:(int)slider.value] forKey:SETTINGS_FOLLOWERS];
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)save:(id)sender
{
    [settings setObject:self.languageField.text forKey:SETTINGS_LANGUAGE];
    [settings setObject:self.locationField.text forKey:SETTINGS_LOCATION];
    [[NSUserDefaults standardUserDefaults] setObject:settings forKey:SETTINGS];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
