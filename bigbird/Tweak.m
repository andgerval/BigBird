@interface PTHTweetbotPostDraft : NSObject
@property(readonly, nonatomic) unsigned long long length;
@property(copy, nonatomic) NSString *text;
@end

@interface PTHTweetbotNotice : NSObject
@property(copy, nonatomic) NSString *message;
@property(copy, nonatomic) NSString *title;
@property(nonatomic) long long type;
@end

@interface PTHTweetbotPostCounterView : UILabel
@property(retain, nonatomic) PTHTweetbotPostDraft *draft;
- (void)draftDidUpdate;
@end

@interface PTHTweetbotPostController : UIViewController
@property(retain, nonatomic) PTHTweetbotPostDraft *draft;
- (void)post:(id)arg1;
- (void)_post;
@end

@interface PTHTweetbotNoticeController : NSObject
+ (void)showNotice:(id)arg1;
@end

%hook PTHTweetbotPostController
- (void)post:(id)arg1 {
	int length = [[self draft] length];
	if (length != 0 && length <= 280) {
		[self _post];
		NSString *message = [[self draft] text];
		[self dismissViewControllerAnimated:YES completion:^{
			PTHTweetbotNotice *notice = [[%c(PTHTweetbotNotice) alloc] init];
			[notice setType:2];
			[notice setMessage:message];
			//[notice setSoundName:@"notice_success.caf"];
			[%c(PTHTweetbotNoticeController) showNotice:notice];
		}];
	} else {
		%orig;
		NSString *newMessage = @"Your tweet is over 280 characters. You can either edit down or save it as a draft to fix later.";
		[[[[[[self presentedViewController] view] subviews] firstObject] subviews][1] setText:newMessage];
	}
}
%end

%hook PTHTweetbotPostCounterView
- (void)draftDidUpdate {
    UIColor *textColor = [UIColor lightGrayColor];
    int charactersRemaining = 280 - [[self draft] length];
    if (charactersRemaining < 0) {
        textColor = [UIColor redColor];
    }
    if ([self textColor] != textColor) {[self setTextColor:textColor];}
    [self setText:[NSString stringWithFormat:@"%d", charactersRemaining]];
}
%end
