//
//  ViewController.m
//

#import "ViewController.h"

#define HIDE_LOG  NO

@interface ViewController ()
{
    BPHeadset *headset;
    
    // lastDisconnect is used to detect repeated connection errors
    // so we can avoid getting stuck in a loop of disconnect/reconnect
    NSDate *lastDisconnect;
    
}

@end

// LOG out friendly name and model after connect.


@implementation ViewController
@synthesize connectButton;
@synthesize logTextView;
@synthesize clearButton;
@synthesize logLabel;
@synthesize statusLabel;
@synthesize sdkModeButton;
@synthesize bondableButton;
@synthesize enterpriseView;
@synthesize enterpriseKeyField;
@synthesize enterpriseValueField;
@synthesize enterpriseKeyGetField;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    logTextView.text = nil;
    headset = [BPHeadset sharedInstance];
    [headset addListener:self];
    
    [self checkHeadsetStatus];
    
    logLabel.hidden = clearButton.hidden = logTextView.hidden = HIDE_LOG;
    statusLabel.text = @"";
    NSString *log = [NSString stringWithFormat:@"SDK Version: %@",[[BPHeadset sharedInstance] version]];
    [self addStatus:log];
    [self logAnalyticsStatus];

    // Whenever the app is brought to the foreground, log the current state of the sendAnalytics setting:
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(logAnalyticsStatus)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) logAnalyticsStatus {
    // Analytics setting can be changed in the app's settings screen in the iOS Settings App.
    BPHeadset.sendAnalytics = [[NSUserDefaults standardUserDefaults] boolForKey:@"send_analytics"];
    NSString *log = [NSString stringWithFormat:@"Analytics Enabled: %@",BPHeadset.sendAnalytics ? @"YES" : @"NO"];
    [self addStatus:log];

}

- (void) checkHeadsetStatus {
    if (headset.connected) {
        [connectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
        sdkModeButton.hidden = NO;
        bondableButton.hidden = NO;
        enterpriseView.hidden = NO;
        if (headset.sdkModeEnabled) {
            [sdkModeButton setTitle:@"Disable SDK Mode" forState:UIControlStateNormal];
        } else {
            [sdkModeButton setTitle:@"Enable SDK Mode" forState:UIControlStateNormal];
        }
        
        if (headset.bondableEnabled == BPBondableEnabled) {
            [bondableButton setTitle:@"Disable BLE Bondable" forState:UIControlStateNormal];
        } else {
            [bondableButton setTitle:@"Enable BLE Bondable" forState:UIControlStateNormal];
        }
    } else {
        [connectButton setTitle:@"Connect" forState:UIControlStateNormal];
        sdkModeButton.hidden = YES;
        bondableButton.hidden = YES;
        enterpriseView.hidden = YES;
    }
}

#pragma mark -
#pragma mark Button Presses

- (IBAction)entSetButtonTouched:(id)sender {
    NSString *key = enterpriseKeyField.text;
    NSString *val = enterpriseValueField.text;
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *keyNum = [f numberFromString:key];
    [self.view endEditing:YES];
    if (!keyNum) {
        [self showToast:@"You must enter a number for the key"];
        return;
    }
    
    [headset setConfigValue:[keyNum unsignedIntegerValue] value:val];
    [self addStatus:@"Finished setting enterprise key"];
}


- (IBAction)entGetButtonTouched:(id)sender {
    NSString *key = self.enterpriseKeyField.text;
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *keyNum = [f numberFromString:key];
    [self.view endEditing:YES];
    if (!keyNum) {
        [self showToast:@"You must enter a number for the key"];
        return;
    }

    NSString *value = [headset getConfigValue:[key integerValue]];
    NSString *log = [NSString stringWithFormat:@"Key: %@, Value: %@", key, value];
    [self addStatus:log];
}

- (IBAction)entGetAllButtonTouched:(id)sender {
    [self.view endEditing:YES];
    [self addStatus:@"Getting enterprise keys..."];
    NSDictionary *vals = [headset getConfigValues];
    NSArray *keys = [vals allKeys];
    NSString *log = [NSString stringWithFormat:@"Got %lu keys", (unsigned long)keys.count];
    [self addStatus:log];
    NSSortDescriptor *lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    NSArray *sortedKeys = [keys sortedArrayUsingDescriptors:[NSArray arrayWithObject:lowestToHighest]];
    
    
    for (NSNumber *key in sortedKeys) {
        NSString *value = [vals objectForKey:key];
        NSString *log = [NSString stringWithFormat:@"Key: %lu, Value: %@", (unsigned long)key.unsignedIntegerValue, value];
        [self addStatus:log];
    }
}

- (IBAction)connectButtonTouched:(id)sender {
    lastDisconnect = nil;
    if (headset.connected) {
        [self addStatus:@"Disconnecting..."];
        [headset disconnect];
    } else {
        [self addStatus:@"Connecting..."];
        [headset connect];
    }
    connectButton.enabled = NO;
}

- (IBAction)clearButtonTouched:(id)sender {
    logTextView.text = nil;
}

- (IBAction)sdkModeButtonTouched:(id)sender {
    if (headset.sdkModeEnabled) {
        [headset disableSDKMode];
    } else {
        [headset enableSDKMode];
    }

}

- (IBAction)bondableButtonTouched:(id)sender {
    if (headset.bondableEnabled == BPBondableEnabled) {
        [headset setBondable:NO];
    } else {
        [headset setBondable:YES];
    }
}

#pragma mark -
#pragma mark BPHeadsetListener methods

- (void) onModeUpdate {
    [self addStatus:@"Headset mode set successfully"];
    [self checkHeadsetStatus];
}

- (void) onConnectProgress:(BPConnectProgress)status {
    switch (status) {
        case BPConnectProgressStarted:
            [self addStatus:@"Started connecting..."];
            break;
        case BPConnectProgressScanning:
            [self addStatus:@"Scanning for headsets..."];
            break;
        case BPConnectProgressFound:
            [self addStatus:@"Headset Found..."];
            break;
        case BPConnectProgressReading:
            [self addStatus:@"Reading headset values..."];
            break;

        default:
            break;
    }
}

- (void) onModeUpdateFailure:(BPModeUpdateError)error {
    [self addStatus:@"Headset mode set error"];
    [self checkHeadsetStatus];
}

- (void) onConnect {
    NSString *msg = [NSString stringWithFormat:@"Headset (%@) connected", headset.friendlyName];
    [self addStatus:msg];
}

- (void) onValuesRead {
    NSString *fw = [headset firmwareVersion];
    if (fw == nil) {
        fw = @"Unknown";
    }
    NSString *msg = [NSString stringWithFormat:@"Finished reading headset values, firmware version: %@", fw];
    [self addStatus:msg];
    msg = [NSString stringWithFormat:@"Proximity state: %ld", (long)headset.proximityState];
    [self addStatus:msg];
    msg = [NSString stringWithFormat:@"Bondable: %ld", (long)headset.bondableEnabled];
    [self addStatus:msg];
    msg = [NSString stringWithFormat:@"Headset Model: %@", headset.model];
    [self addStatus:msg];
    msg = [self describeMode];
    [self addStatus:msg];
    [self checkHeadsetStatus];
    connectButton.enabled = YES;
    lastDisconnect = nil;
}

- (void) onConnectFailure:(BPConnectError)reasonCode {
    switch (reasonCode) {
        case BPConnectErrorBluetoothDisabled:
            [self addStatus:@"Headset failed to connect - Bluetooth Disabled"];
            break;
        case BPConnectErrorSDKTooOld:
            [self addStatus:@"Headset failed to connect - SDK is too old for the headset"];
            break;
        case BPConnectErrorFirmwareTooOld:
            [self addStatus:@"Headset failed to connect - Firmware too old"];
            break;
        case BPConnectErrorUnknown:
        default:
            [self addStatus:@"Headset failed to connect - unknown reason"];
            break;
    }
    [self checkHeadsetStatus];
    connectButton.enabled = YES;
}

- (void) onDisconnect {
    [self addStatus:@"Headset disconnected"];
    [self checkHeadsetStatus];
    connectButton.enabled = YES;
    if (lastDisconnect) {
        NSTimeInterval diff = fabs([lastDisconnect timeIntervalSinceNow]);
        if (diff < 3) {
            lastDisconnect = nil;
            [headset disconnect];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:@"Headset was disconnected, possibly due to a bonding error. Try unpairing the device and pairing again."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:cancel];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    lastDisconnect = [NSDate new];
}

- (void) onTap:(BPButtonID) buttonID {
    NSString *status = [self describeButtonEvent:buttonID eventName:@"onTap"];
    [self addStatus:status];
    [self showToast:status];
}

- (void) onDoubleTap:(BPButtonID) buttonID {
    NSString *status = [self describeButtonEvent:buttonID eventName:@"onDoubleTap"];
    [self addStatus:status];
    [self showToast:status];
}

- (void) onLongPress:(BPButtonID)buttonID {
    NSString *status = [self describeButtonEvent:buttonID eventName:@"onLongPress"];
    [self addStatus:status];
    [self showToast:status];
}

- (void) onProximityChanged:(BPProximityState)proximityState {
    
    NSString *status = [NSString stringWithFormat:@"Headset proximity changed: %ld", (long)proximityState];
    [self addStatus:status];
}


- (void) onButtonDown:(BPButtonID) buttonID {
    NSString *status = [self describeButtonEvent:buttonID eventName:@"onButtonDown"];
    [self addStatus:status];
    self.view.backgroundColor = [UIColor greenColor];
}

- (void) onButtonUp:(BPButtonID) buttonID {
    NSString *status = [self describeButtonEvent:buttonID eventName:@"onButtonUp"];
    [self addStatus:status];
    self.view.backgroundColor = [UIColor whiteColor];
}


#pragma mark -
#pragma mark On Screen Logging

- (void) showToast:(NSString *) text {
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:nil
                                 message:text
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    int duration = 2; // seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void) setStatus:(NSString *)text {
    statusLabel.text = text;
    return;
}

- (void) addStatus:(NSString *)text {
    if (HIDE_LOG) {
        statusLabel.text = text;
        return;
    }
    NSLog(@"%@", text);
    
    NSString *oldText = logTextView.text;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [dateFormatter setDateFormat:@"HH:mm:ss.SSS"];
    NSDate *now = [NSDate date];
    NSString *timestamp = [dateFormatter stringFromDate:now];
    
    NSString *newLine = [NSString stringWithFormat:@"%@: %@", timestamp, text];
    
    if (oldText && oldText.length > 0) {
        oldText = [oldText stringByAppendingString:@"\n"];
    }   
    
    NSString *newText = [oldText stringByAppendingString:newLine];
    logTextView.text = newText;
    NSRange range = NSMakeRange(logTextView.text.length - 1, 1);
    [logTextView scrollRangeToVisible:range];
}

- (NSString *) describeMode {
    NSString *description = nil;
    BPButtonMode mode = headset.buttonMode;
    BOOL sdkEnabled = headset.sdkModeEnabled;
    NSString *appID = headset.appKey;
    NSString *appName = headset.appName;
    NSString *speedDial = headset.speedDialNumber;
    
    if (sdkEnabled) {
        description = [NSString stringWithFormat:@"SDK Mode, App Name: %@", appName];
        return description;
    }
    
    switch (mode) {
        case BPButtonModeApp:
            description = [NSString stringWithFormat:@"App Mode, App ID: %@, App Name: %@", appID, appName];
            break;
        case BPButtonModeMute:
            description = [NSString stringWithFormat:@"Mute Mode"];
            break;
        case BPButtonModeSpeedDial:
            description = [NSString stringWithFormat:@"Speed Dial Mode (%@)", speedDial];
            break;
        default:
            description = [NSString stringWithFormat:@"Unknown Mode (%ld)", (long)mode];
            break;
    }
    return description;
}

- (NSString *) describeButtonEvent:(BPButtonID) buttonID eventName:(NSString *)eventName{
    NSString *description = [NSString stringWithFormat:@"Headset %@", eventName];
    return description;
}


@end
