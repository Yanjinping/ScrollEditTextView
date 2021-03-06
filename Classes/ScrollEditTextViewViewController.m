//
//  ScrollEditTextViewViewController.m
//  ScrollEditTextView
//
//  Created by Billy Gray on 11/19/09.
//  Copyright Zetetic LLC 2009. All rights reserved.
//

#import "ScrollEditTextViewViewController.h"

@interface ScrollEditTextViewViewController (Private)
- (void)observeKeyboard;
- (void)ignoreKeyboard;
@end

@implementation ScrollEditTextViewViewController

#define VERTICAL_KEYRBOARD_MARGIN 4.0f;

@synthesize textView;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *rbi = [[[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                             style:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:@selector(stopEditing:)]
                            autorelease];
    [rbi setEnabled:NO];
    self.navigationItem.title = @"UITextView";
    self.navigationItem.rightBarButtonItem = rbi;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self observeKeyboard];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self ignoreKeyboard];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.textView = nil;
}

- (IBAction)stopEditing:(id)selector {
	[textView resignFirstResponder];
}

- (void)textViewDidBeginEditing:(UITextView	*)aTextView {
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}

- (void)textViewDidEndEditing:(UITextView *)aTextView {
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
}

- (BOOL)textView:(UITextView *)aTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    [aTextView scrollRangeToVisible:range];
    return YES;
}

#pragma mark -
#pragma mark Keyboard Handling

- (void)observeKeyboard {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)ignoreKeyboard {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    kbRect = [[self view] convertRect:kbRect fromView:nil];
    CGSize kbSize = kbRect.size;
    CGRect aRect = self.view.frame;

    /* This should work, but doesn't quite qet the job done */
//    UIEdgeInsets insets = self.textView.contentInset;
//    insets.bottom = kbSize.height;
//    self.textView.contentInset = insets;
//    
//    insets = self.textView.scrollIndicatorInsets;
//    insets.bottom = kbSize.height;
//    self.textView.scrollIndicatorInsets = insets;
    
    /* Instead, we just adjust the frame of the uitextview */
    aRect.size.height -= kbSize.height + VERTICAL_KEYRBOARD_MARGIN;
    self.textView.frame = aRect;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    if (!CGRectContainsPoint(aRect, self.textView.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, self.textView.frame.origin.y - kbSize.height);
        [self.textView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    
    /* If you're following the docs, this is how to reset the contentInsets adjusted when keyboard was shown */
    // reset the content insets to restore the text view's content area to its proper size
//    UIEdgeInsets contentInsets = self.textView.contentInset;
//    contentInsets.bottom = 0;
//    self.textView.contentInset = contentInsets;
//    self.textView.scrollIndicatorInsets = contentInsets;
    
    /* Instead, we restore the original size of the textView frame */
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    kbRect = [[self view] convertRect:kbRect fromView:nil];
    CGSize kbSize = kbRect.size;
    CGRect frame = self.textView.frame;
    frame.size.height += kbSize.height + VERTICAL_KEYRBOARD_MARGIN;
    self.textView.frame = frame;
}

- (void)dealloc {
	[textView release];
    [super dealloc];
}

@end
