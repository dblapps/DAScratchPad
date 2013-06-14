DAScratchPad
=======================

#### Author

David B. Levi (https://github.com/dblapps)


#### Overview

DAScratchPad is a small UIView subclass that provides a simple drawing interface.  It provides both a painting and airbrushing capability.  You can put this view anywhere in your UI, and your user can draw in it.  You can add UI controls to change drawing color, line width, opacity, select painting or airbrushing, and set airbrush flow.  You can also get the current image from the scratch pad, clear the current image, or replace the current image.

An example xcode project is included that demonstrates simple usage. 

DAScratchPad is compatible with iOS4.3+.


#### License

DAScratchPad is available under the MIT license. See the LICENSE file for more info.


#### How To Use

Copy the contents of the DAScratchPad directory to your xcode project.

Import DAScratchPad.h in appropriate places.

Add the QuartzCore frameworks to your project.

Add instance of DAScratchPad in interface builder, or add them programatically:

	DAScratchPad* scratchpad = [[DAScratchPad alloc] initWithFrame:CGRectMake(30.0f, 30.0f, 150.0f, 150.0f)];
	[self.view addSubview:scratchpad];

Change properties to control color, line width, and opacity:

	scratchpad.drawColor = [UIColor greenColor];
	scratchpad.drawWidth = 15.0f;
	scratchpad.drawOpacity = 0.5f; // range is 0.0f through 1.0f

Select painting or airbrushing, and set airbrush rate and flow:

	scratchpad.toolType = DAScratchPadToolTypePaint;
	scratchpad.toolType = DAScratchPadToolTypeAirBrush;
	scratchpad.airBrushFlow = 0.7f; // range is 0.0f through 1.0f

Use 'getSketch' to retrieve the current image:

	UIImage* sketch = [scratchpad getSketch];

Use 'setSketch:' to replace the current image:

	UIImage* image = [UIImage imageNamed:@"SavedImage.jpg"];
	[scratchpad setSketch:image];

Use 'clearToColor:' to clear the current image:

	[scratchpad clearToColor:[UIColor whiteColor]];

