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
  return @"";
}

- (void)displayComposerSheet  {
  YammerAppDelegate *yammer = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];

	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
  [picker setToRecipients:[NSArray arrayWithObject:@"iphone@yammer-inc.com"]];
	[picker setSubject:[NSString stringWithFormat:@"Version %@", [yammer version]]];
  
	[picker setMessageBody:[self emailText] isHTML:NO];
	
	[self presentModalViewController:picker animated:YES];
  [picker becomeFirstResponder];

  [picker release];
  
}

- (void) logSubviewsOfUIView:(UIView*)view depth:(NSInteger)depth {
  for (UIView *item in view.subviews) {
    NSString *tabs = @"";
    for (int i=0;i<depth;i++) {
      tabs = [tabs stringByAppendingString:@"\t"];
    }
    NSLog(@"%@%@ canBecomeFirstResponder %i", tabs, [item class], ([item respondsToSelector:@selector(canBecomeFirstResponder)] ? YES : NO));
    if ([item.subviews count] > 0) {
      [self logSubviewsOfUIView:item depth:depth+1];
    }
  }
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
