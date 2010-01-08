
#import <Three20/Three20.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface SendMail : TTTableViewController <MFMailComposeViewControllerDelegate> {

}

- (void)email;
- (void)displayComposerSheet ;
- (void)launchMailAppOnDevice;
- (NSString*)emailText;

@end
