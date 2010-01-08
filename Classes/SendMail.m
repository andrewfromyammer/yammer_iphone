#import "SendMail.h"
#import "YammerAppDelegate.h"

@implementation SendMail

- (void)email {
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil) {
		if ([mailClass canSendMail])
			[self displayComposerSheet];
		else
			[self launchMailAppOnDevice];
	}
	else
		[self launchMailAppOnDevice];
}

- (NSString*)emailText {
  YammerAppDelegate *yammer = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
  return [NSString stringWithFormat:@"Hi, I'm using the Yammer App version %@ and wanted to tell you that...\n\n", [yammer version]];
}

- (void)displayComposerSheet  {
  YammerAppDelegate *yammer = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];

	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
  [picker setToRecipients:[NSArray arrayWithObject:@"iphone@yammer-inc.com"]];
	[picker setSubject:[NSString stringWithFormat:@"Yammer: Feedback on version %@", [yammer version]]];
  
	[picker setMessageBody:[self emailText] isHTML:NO];
	
	[self presentModalViewController:picker animated:YES];
  [picker release];
}

- (void)launchMailAppOnDevice {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Email"
                                                  message:@"This device cannot send email, please upgrade to latest software." delegate:self 
                                        cancelButtonTitle:@"OK" otherButtonTitles: nil];
  [alert show];
  [alert release];
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
  [self dismissModalViewControllerAnimated:YES];
}


@end
