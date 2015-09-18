//
//  ViewController.m
//  ImagePickerAndPublisher
//
//  Created by Ankur Oberoi on 9/17/15.
//  Copyright © 2015 Ankur Oberoi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) OTSession* session;
@property (strong, nonatomic) OTPublisher* publisher;
@property (weak, nonatomic) IBOutlet UIView *publisherViewContainer;
@property (weak, nonatomic) IBOutlet UIButton *captureButton;
@property (weak, nonatomic) IBOutlet UIButton *publishButton;

@end

@implementation ViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *configurationPath = [[NSBundle mainBundle] pathForResource:@"Configuration" ofType:@"plist"];
    NSDictionary *configuration = [[NSDictionary alloc] initWithContentsOfFile:configurationPath];
    
    self.session = [[OTSession alloc] initWithApiKey:[configuration objectForKey:@"IPAPAPIKey"]
                                           sessionId:[configuration objectForKey:@"IPAPSessionID"]
                                            delegate:self];
    
    OTError *connectError;
    [self.session connectWithToken:[configuration objectForKey:@"IPAPToken"] error:&connectError];
    
    if (connectError) {
        NSLog(@"Session connect failed synchronously");
        return;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)captureStillImage:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *pickerViewController = [[UIImagePickerController alloc] init];
        pickerViewController.delegate = self;
        pickerViewController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:pickerViewController animated:YES completion:nil];
    } else {
        NSLog(@"Camera not supported");
    }
}

- (IBAction)publish:(id)sender {
    
    if (!self.publisher) {
        
        self.publisher = [[OTPublisher alloc] initWithDelegate:self];
        self.publisher.view.frame = CGRectInset(self.publisherViewContainer.bounds, 0, 0);
        [self.publisherViewContainer addSubview:self.publisher.view];
        
        OTError *publishError;
        [self.session publish:self.publisher error:&publishError];
        
        if (publishError) {
            NSLog(@"Publish failed synchronously");
            return;
        }
        
    }
}


#pragma mark - Image Picker Controller Delegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,
                               id> *)info
{
    NSLog(@"Image picked");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Session Delegate

- (void)sessionDidConnect:(OTSession*)session
{
    NSLog(@"Session connected");
    
    self.captureButton.enabled = YES;
    self.publishButton.enabled = YES;
}

- (void)sessionDidDisconnect:(OTSession*)session
{
    NSLog(@"Session disconnected");
    
    [self.publisher.view removeFromSuperview];
    self.publisher = nil;
    
    self.captureButton.enabled = NO;
    self.publishButton.enabled = NO;
}

- (void)session:(OTSession*)session didFailWithError:(OTError*)error
{
    NSLog(@"Session connect failed asynchronously");
}

- (void)session:(OTSession*)session streamCreated:(OTStream*)stream
{
    NSLog(@"Stream created");
}

- (void)session:(OTSession*)session streamDestroyed:(OTStream*)stream
{
    NSLog(@"Stream destroyed");
}

#pragma mark - Publisher Delegate

- (void)publisher:(OTPublisherKit*)publisher didFailWithError:(OTError*)error
{
    NSLog(@"Publisher failed asynchronously");
}

- (void)publisher:(OTPublisherKit*)publisher streamCreated:(OTStream*)stream
{
    NSLog(@"Publisher stream created");
}


- (void)publisher:(OTPublisherKit*)publisher streamDestroyed:(OTStream*)stream
{
    NSLog(@"Publisher stream destroyed");
}

@end
