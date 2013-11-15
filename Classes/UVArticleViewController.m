//
//  UVArticleViewController.m
//  UserVoice
//
//  Created by Austin Taylor on 5/8/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UVArticleViewController.h"
#import "UVSession.h"
#import "UVContactViewController.h"
#import "UVStyleSheet.h"
#import "UVBabayaga.h"
#import "UVDeflection.h"

@implementation UVArticleViewController

- (void)loadView {
    [super loadView];
    [UVBabayaga track:VIEW_ARTICLE id:_article.articleId];
    CGFloat barHeight = IOS7 ? 32 : 40;
    self.view = [[UIView alloc] initWithFrame:[self contentFrame]];
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - barHeight)];
    NSString *html = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=\"http://cdn.uservoice.com/stylesheets/vendor/typeset.css\"/></head><body class=\"typeset\" style=\"font-family: sans-serif; margin: 1em\"><h3>%@</h3>%@</body></html>", _article.question, _article.answerHTML];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    if ([_webView respondsToSelector:@selector(scrollView)]) {
        _webView.backgroundColor = [UIColor whiteColor];
        for (UIView* shadowView in [[_webView scrollView] subviews]) {
            if ([shadowView isKindOfClass:[UIImageView class]]) {
                [shadowView setHidden:YES];
            }
        }
    }
    [_webView loadHTMLString:html baseURL:nil];
    [self.view addSubview:_webView];

    UIToolbar *helpfulBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - barHeight, self.view.bounds.size.width, barHeight)];
    helpfulBar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    if (IOS7) {
        helpfulBar.translucent = NO;
    } else {
        helpfulBar.barStyle = UIBarStyleBlack;
        helpfulBar.tintColor = [UIColor colorWithRed:1.00f green:0.99f blue:0.90f alpha:1.0f];
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, helpfulBar.bounds.size.width - 100, barHeight)];
    label.text = NSLocalizedStringFromTable(@"Was this article helpful?", @"UserVoice", nil);
    label.font = IOS7 ? [UIFont systemFontOfSize:13] : [UIFont boldSystemFontOfSize:13];
    label.textColor = [UIColor colorWithRed:0.41f green:0.42f blue:0.43f alpha:1.0f];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [helpfulBar addSubview:label];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *yesItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Yes!", @"UserVoice", nil) style:UIBarButtonItemStyleDone target:self action:@selector(yesButtonTapped)];
    yesItem.width = 50;
    if ([yesItem respondsToSelector:@selector(setTintColor:)])
        yesItem.tintColor = [UIColor colorWithRed:0.42f green:0.64f blue:0.85f alpha:1.0f];
    UIBarButtonItem *noItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"No", @"UserVoice", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(noButtonTapped)];
    noItem.width = 50;
    if ([noItem respondsToSelector:@selector(setTintColor:)])
        noItem.tintColor = [UIColor colorWithRed:0.46f green:0.55f blue:0.66f alpha:1.0f];
    helpfulBar.items = @[space, yesItem, noItem];
    [self.view addSubview:helpfulBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (_helpfulPrompt) {
        if (buttonIndex == 0) {
            [self.navigationController popViewControllerAnimated:YES];
        } else if (buttonIndex == 1) {
            [self dismissUserVoice];
        }
    } else {
        if (buttonIndex == 0) {
            [self presentModalViewController:[UVContactViewController new]];
        }
    }
}

- (void)yesButtonTapped {
    [UVBabayaga track:VOTE_ARTICLE id:_article.articleId];
    if (_instantAnswers) {
        [UVDeflection trackDeflection:@"helpful" deflector:_article];
    }
    if (_helpfulPrompt) {
        // Do you still want to contact us?
        // Yes, go to my message
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:_helpfulPrompt
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:_returnMessage, NSLocalizedStringFromTable(@"No, I'm done", @"UserVoice", nil), nil];
        [actionSheet showInView:self.view];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)noButtonTapped {
    if (_instantAnswers) {
        [UVDeflection trackDeflection:@"unhelpful" deflector:_article];
    }
    if (_helpfulPrompt) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"Would you like to contact us?", @"UserVoice", nil)
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedStringFromTable(@"No", @"UserVoice", nil)
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:NSLocalizedStringFromTable(@"Yes", @"UserVoice", nil), nil];
        [actionSheet showInView:self.view];
    }
}

@end
