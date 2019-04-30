Ambarella RemoteCam iOS tool:

Build Install to device:
    * ckeck out git 
    * open AmbaRemoteCam/AmbarellaRemoteCam.xcodeproj in xcode
    * Run xcode>product>clean to clean the project
    * Under Xcode open AmbaRemoteCam project settings on the left side source view
    * Select "Deployment Target iOS version"
    * Select the intended Target Device "iphone or iPad"
      Based on the target device selection, make sure the Main Interface corresponds 
      to the target device storyboard: 
	For iPhone:   Main Interface: [ AmbaRemoteCamiPhone.storyboard ]
	For iPad  :   Main Interface: [ AmbaRemoteCamiPad.storyboard ]

    * Make sure the to link the following FrameWorks and libraries for the poject:
		- libavcodec.a
		- libavdevice.a
		- libavfilter.a
		- libavformat.a
		- libavutil.a
		- libswresample.a
		- libswscale.a
		- libz.dylib
		- libbz2.dylib
		- libiconv.dylib
		- MediaPlayer.framework
		- CoreVideo.framework 
		- CoreImage.framework
		- CoreMedia.framework
		- AudioToolbox.framework
		- QuartzCore.framwork
		- UIKit.framework
		- CoreGraphics.framework
		- AVFoundation.framework
		- CoreBluetooth.framework
		- Foundation.framework

    * Xcode>Product>build
    * Connect the target iOS target device to the development MAC OSX system
      Select the Target iOS device to launch the code
	 Xcode>Product>run

NOTE: 1. To install to the development target iOS device you will need a valid 
         Apple developer licence installed.
      2. Incase you wish to test the application over simulator:
         BluetoohLE feature is not supported on Apples phone simulator devices.

