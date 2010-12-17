/*
  AboutViewController.m
  
  Copyright (c) 2009 Sven-S. Porst, Tom Insam
  
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:
  
  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.
  
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.

  Email flame@jerakeen.org or visit http://jerakeen.org/code/flame-iphone/
  for support.
*/

#import "AboutViewController.h"

@implementation AboutViewController

-(void)viewDidLoad;
{
  NSLog(@"loadView");
  self.title = NSLocalizedString(@"Flame for iPhone", @"Full application name");

  theWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
  theWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.view addSubview:theWebView];
  [theWebView setDelegate:self];
  [self addObserver:self forKeyPath:@"view.frame" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];

  [self loadHTML];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  // called when the frame changes. Need to explicitly re-flow the web content.
  theWebView.frame = self.view.frame;
  // probably an easier way of doing it than reloading everything, of course.
  [self loadHTML];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
  if (navigationType == UIWebViewNavigationTypeLinkClicked) {
    [[UIApplication sharedApplication] openURL:request.URL];
    return false;
  }
  return true;
}
   
-(void)loadHTML;
{
  NSMutableString *htmlString = [NSMutableString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"] encoding:NSUTF8StringEncoding error:NULL];
  NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
  [htmlString replaceOccurrencesOfString:@"#{VERSION}" withString:version options:0 range:NSMakeRange(0, [htmlString length])];
  [theWebView loadHTMLString: htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
}     


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES; 
}


- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
  // Release anything that's not essential, such as cached data
  [theWebView setDelegate:nil];
  [theWebView release];
}


- (void)dealloc {
  [self removeObserver:self forKeyPath:@"view.frame"];
  [theWebView setDelegate:nil];
  [theWebView release];
  [super dealloc];
}

@end
