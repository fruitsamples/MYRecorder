//
//  MyRecorderController.m
//  MyRecorder

 /*

Disclaimer: IMPORTANT:  This Apple software is supplied to you by 
Apple Inc. ("Apple") in consideration of your agreement to the
following terms, and your use, installation, modification or
redistribution of this Apple software constitutes acceptance of these
terms.  If you do not agree with these terms, please do not use,
install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software. 
Neither the name, trademarks, service marks or logos of Apple Inc. 
may be used to endorse or promote products derived from the Apple
Software without specific prior written permission from Apple.  Except
as expressly stated in this notice, no other rights or licenses, express
or implied, are granted by Apple herein, including but not limited to
any patent rights that may be infringed by your derivative works or by
other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2007 Apple Inc. All Rights Reserved.  

*/

#import "MyRecorderController.h"

@implementation MyRecorderController

- (void)awakeFromNib
{

// Create the capture session

	mCaptureSession = [[QTCaptureSession alloc] init];

// Connect inputs and outputs to the session	

	BOOL success;
	NSError *error;
	
// Find a video device  

QTCaptureDevice *device = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
	if (device) {
		success = [device open:&error];
		if (!success) {
			// Handle error
		}


// If a video input device can't be opened, try to find and open a muxed input device

	if (!success) {
		[mVideoInputDevice release];
		mVideoInputDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeMuxed];
		success = [mVideoInputDevice open:&error];
		
		}
		
		if (!success) {
			[mVideoInputDevice release];
			mVideoInputDevice = nil;
			// Handle error
			
		}

//Add the video device to the session as a device input
		
		mCaptureDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:device];
		success = [mCaptureSession addInput:mCaptureDeviceInput error:&error];
		if (!success) {
			// Handle error
		}
		
		[mCaptureSession startRunning];
		
// If the video device doesn't also supply audio, add an audio device input to the session

if (![mVideoInputDevice hasMediaType:QTMediaTypeSound] && ![mVideoInputDevice hasMediaType:QTMediaTypeMuxed]) {

	mAudioInputDevice = [[QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeSound] retain];
	success = [mAudioInputDevice open:&error];
	
	if (!success) {
		[mAudioInputDevice release];
		mAudioInputDevice = nil;
		// Handle error
	}
	
	success = [mCaptureSession addInput:[QTCaptureDeviceInput deviceInputWithDevice:mAudioInputDevice] error:&error];
	if (!success) {
		// Handle error
	}

}
	
// Create the movie file output and add it to the session

	mCaptureMovieFileOutput = [[QTCaptureMovieFileOutput alloc] init];
	success = [mCaptureSession addOutput:mCaptureMovieFileOutput error:&error];
	if (!success) {
		// Handle error
	}
    
	[mCaptureMovieFileOutput setDelegate:self];

// Associate the capture view in the UI with the session
	
	[mCaptureView setCaptureSession:mCaptureSession];
	
	
			[mCaptureSession startRunning];

	}

}

// Handle window closing notifications for your device input

- (void)windowWillClose:(NSNotification *)notification
{
	
	[mCaptureSession stopRunning];
	[[mCaptureDeviceInput device] close];

}

// Handle deallocation of memory for your capture objects

- (void)dealloc
{
	[mCaptureSession release];
	[mCaptureDeviceInput release];
	[mCaptureMovieFileOutput release];
	
	[super dealloc];
}

#pragma mark-

// Add these start and stop recording actions, and specify the output destination for your recorded media. The output is a QuickTime movie.

- (IBAction)startRecording:(id)sender
{
	[mCaptureMovieFileOutput recordToOutputFileURL:[NSURL fileURLWithPath:@"/Users/Shared/My Recorded Movie.mov"]];
}

- (IBAction)stopRecording:(id)sender
{
	[mCaptureMovieFileOutput recordToOutputFileURL:nil];
}

// Do something with your QuickTime movie at the path you've specified at /Users/Shared/My Recorded Movie.mov"

- (void)captureOutput:(QTCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error
{
	[[NSWorkspace sharedWorkspace] openURL:outputFileURL];
}


@end
