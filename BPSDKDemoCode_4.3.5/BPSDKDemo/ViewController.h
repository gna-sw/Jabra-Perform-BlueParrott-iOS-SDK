//
//  ViewController.h
//

#import <UIKit/UIKit.h>
#import <BPHeadset/BPHeadset.h>

@interface ViewController : UIViewController <BPHeadsetListener>
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *sdkModeButton;
@property (weak, nonatomic) IBOutlet UIButton *bondableButton;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UILabel *logLabel;
@property (weak, nonatomic) IBOutlet UITextField *enterpriseKeyGetField;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIView *enterpriseView;
@property (weak, nonatomic) IBOutlet UITextField *enterpriseValueField;
@property (weak, nonatomic) IBOutlet UITextField *enterpriseKeyField;

- (IBAction)entSetButtonTouched:(id)sender;
- (IBAction)entGetButtonTouched:(id)sender;
- (IBAction)entGetAllButtonTouched:(id)sender;

- (IBAction)connectButtonTouched:(id)sender;
- (IBAction)clearButtonTouched:(id)sender;
- (IBAction)sdkModeButtonTouched:(id)sender;
- (IBAction)bondableButtonTouched:(id)sender;

@end

