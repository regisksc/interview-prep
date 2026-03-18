# Flutter Widgets Challenges (80 exercises)

## Level 1 - Very Easy (15 exercises)

### Exercise 1: Hello World App

**Time**: 5 min | **Difficulty**: 1

**Description**: Create a simple app that displays "Hello World" centered on the screen.

**Starter Code**:
```dart
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement
  }
}
```

---

### Exercise 2: Column of Text Widgets

**Time**: 5 min | **Difficulty**: 1

**Description**: Display three lines of text in a vertical column.

**Examples**: "Line 1", "Line 2", "Line 3"

**Starter Code**:
```dart
class ColumnOfText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Display three Text widgets in a Column
  }
}
```

---

### Exercise 3: Row of Icons

**Time**: 5 min | **Difficulty**: 1

**Description**: Display three icons horizontally in a row.

**Starter Code**:
```dart
class RowOfIcons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Display three Icon widgets in a Row
  }
}
```

---

### Exercise 4: Centered Container

**Time**: 5 min | **Difficulty**: 1

**Description**: Create a 100x100 red container centered on screen.

**Starter Code**:
```dart
class CenteredContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Create centered 100x100 red Container
  }
}
```

---

### Exercise 5: Circular Avatar

**Time**: 5 min | **Difficulty**: 1

**Description**: Display a circular avatar with a letter inside.

**Starter Code**:
```dart
class CircularAvatarExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Create CircleAvatar with child Text
  }
}
```

---

### Exercise 6: Elevated Button

**Time**: 5 min | **Difficulty**: 1

**Description**: Create a button that prints "Clicked" when pressed.

**Starter Code**:
```dart
class MyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Create ElevatedButton with onPressed
  }
}
```

---

### Exercise 7: TextField with Decorator

**Time**: 5 min | **Difficulty**: 1

**Description**: Create a TextField with label "Enter your name".

**Starter Code**:
```dart
class NameField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Create TextField with InputDecoration
  }
}
```

---

### Exercise 8: Simple Card

**Time**: 5 min | **Difficulty**: 1

**Description**: Create a Card with title and subtitle text.

**Starter Code**:
```dart
class SimpleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Create Card with ListTile inside
  }
}
```

---

### Exercise 9: Padding Exercise

**Time**: 5 min | **Difficulty**: 1

**Description**: Add 16 pixels of padding around a text widget.

**Starter Code**:
```dart
class PaddedText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Wrap Text in Padding
  }
}
```

---

### Exercise 10: Margin Exercise

**Time**: 5 min | **Difficulty**: 1

**Description**: Add 16 pixels of margin around a container.

**Starter Code**:
```dart
class MarginedContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Add margin to Container
  }
}
```

---

### Exercise 11: Stack with Positioned

**Time**: 10 min | **Difficulty**: 2

**Description**: Create a stack with a badge positioned on top-right.

**Starter Code**:
```dart
class BadgeStack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Create Stack with Positioned badge
  }
}
```

---

### Exercise 12: Simple ListView

**Time**: 10 min | **Difficulty**: 2

**Description**: Create a ListView with 10 items.

**Starter Code**:
```dart
class SimpleListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Create ListView.builder with 10 items
  }
}
```

---

### Exercise 13: GridView Count

**Time**: 10 min | **Difficulty**: 2

**Description**: Create a 3x3 grid of colored boxes.

**Starter Code**:
```dart
class ColorGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Create GridView.count with 3x3 grid
  }
}
```

---

### Exercise 14: Simple Drawer

**Time**: 10 min | **Difficulty**: 2

**Description**: Create a Scaffold with a Drawer containing menu items.

**Starter Code**:
```dart
class DrawerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Create Scaffold with Drawer
  }
}
```

---

### Exercise 15: AppBar with Actions

**Time**: 5 min | **Difficulty**: 1

**Description**: Create an AppBar with title and two action icons.

**Starter Code**:
```dart
class AppBarWithActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Create AppBar with actions
  }
}
```

---

## Level 2 - Easy (20 exercises)

### Exercise 16: Stateless to Stateful

**Time**: 10 min | **Difficulty**: 2

**Description**: Convert a stateless widget to stateful with a counter.

**Starter Code**:
```dart
// TODO: Convert to StatefulWidget with counter state
class Counter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      child: const Text('Click me'),
    );
  }
}
```

---

### Exercise 17: Toggle Visibility

**Time**: 10 min | **Difficulty**: 2

**Description**: Create a button that toggles visibility of text.

**Starter Code**:
```dart
class ToggleVisibility extends StatefulWidget {
  @override
  State<ToggleVisibility> createState() => _ToggleVisibilityState();
}

class _ToggleVisibilityState extends State<ToggleVisibility> {
  // TODO: Add state and toggle logic
}
```

---

### Exercise 18: Color Changer

**Time**: 10 min | **Difficulty**: 2

**Description**: Tap a container to cycle through colors.

**Starter Code**:
```dart
class ColorChanger extends StatefulWidget {
  @override
  State<ColorChanger> createState() => _ColorChangerState();
}
// TODO: Implement color cycling on tap
```

---

### Exercise 19: Simple Form

**Time**: 15 min | **Difficulty**: 2

**Description**: Create a form with name, email fields and submit button.

**Starter Code**:
```dart
class SimpleForm extends StatefulWidget {
  @override
  State<SimpleForm> createState() => _SimpleFormState();
}
// TODO: Implement form with validation
```

---

### Exercise 20: Form Validation

**Time**: 15 min | **Difficulty**: 3

**Description**: Validate email format and required name field.

**Starter Code**:
```dart
class ValidatedForm extends StatefulWidget {
  @override
  State<ValidatedForm> createState() => _ValidatedFormState();
}
// TODO: Add email regex validation and required name
```

---

### Exercise 21: Checkbox List

**Time**: 15 min | **Difficulty**: 2

**Description**: Create a list of checkboxes that track selected items.

**Starter Code**:
```dart
class CheckboxList extends StatefulWidget {
  @override
  State<CheckboxList> createState() => _CheckboxListState();
}
// TODO: Track selected items in list
```

---

### Exercise 22: Radio Group

**Time**: 10 min | **Difficulty**: 2

**Description**: Create a group of radio buttons for single selection.

**Starter Code**:
```dart
class RadioGroup extends StatefulWidget {
  @override
  State<RadioGroup> createState() => _RadioGroupState();
}
// TODO: Implement single selection radio group
```

---

### Exercise 23: Slider with Value Display

**Time**: 10 min | **Difficulty**: 2

**Description**: Create a slider that displays its current value.

**Starter Code**:
```dart
class SliderWithValue extends StatefulWidget {
  @override
  State<SliderWithValue> createState() => _SliderWithValueState();
}
// TODO: Connect slider to value display
```

---

### Exercise 24: Switch with State

**Time**: 5 min | **Difficulty**: 2

**Description**: Create a switch that updates its state.

**Starter Code**:
```dart
class SwitchExample extends StatefulWidget {
  @override
  State<SwitchExample> createState() => _SwitchExampleState();
}
// TODO: Implement switch state management
```

---

### Exercise 25: Expandable List Item

**Time**: 15 min | **Difficulty**: 2

**Description**: Create an expansion tile that expands on tap.

**Starter Code**:
```dart
class ExpandableList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Create ExpansionTile
  }
}
```

---

### Exercise 26: TabBar with TabBarView

**Time**: 15 min | **Difficulty**: 2

**Description**: Create a screen with 3 tabs and content for each.

**Starter Code**:
```dart
class TabScreen extends StatelessWidget {
  // TODO: Implement DefaultTabController with TabBar
}
```

---

### Exercise 27: Bottom Navigation Bar

**Time**: 15 min | **Difficulty**: 2

**Description**: Create a screen with bottom navigation and 3 pages.

**Starter Code**:
```dart
class BottomNavScreen extends StatefulWidget {
  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}
// TODO: Implement bottom navigation with page switching
```

---

### Exercise 28: SnackBar Display

**Time**: 5 min | **Difficulty**: 2

**Description**: Show a SnackBar when button is pressed.

**Starter Code**:
```dart
class SnackBarButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Show SnackBar on button press
  }
}
```

---

### Exercise 29: Dialog Display

**Time**: 10 min | **Difficulty**: 2

**Description**: Show an AlertDialog when button is pressed.

**Starter Code**:
```dart
class DialogButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Show AlertDialog on button press
  }
}
```

---

### Exercise 30: Modal Bottom Sheet

**Time**: 10 min | **Difficulty**: 2

**Description**: Display a modal bottom sheet with options.

**Starter Code**:
```dart
class BottomSheetButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Show modal bottom sheet
  }
}
```

---

### Exercise 31: Dismissible List Item

**Time**: 15 min | **Difficulty**: 2

**Description**: Create a list where items can be swiped to delete.

**Starter Code**:
```dart
class DismissibleList extends StatefulWidget {
  @override
  State<DismissibleList> createState() => _DismissibleListState();
}
// TODO: Implement dismissible items
```

---

### Exercise 32: RefreshIndicator

**Time**: 10 min | **Difficulty**: 2

**Description**: Add pull-to-refresh to a list.

**Starter Code**:
```dart
class RefreshableList extends StatefulWidget {
  @override
  State<RefreshableList> createState() => _RefreshableListState();
}
// TODO: Wrap ListView with RefreshIndicator
```

---

### Exercise 33: Floating Action Button

**Time**: 5 min | **Difficulty**: 2

**Description**: Add a FAB that shows a SnackBar when pressed.

**Starter Code**:
```dart
class FabScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Add FloatingActionButton to Scaffold
  }
}
```

---

### Exercise 34: Hero Animation

**Time**: 15 min | **Difficulty**: 3

**Description**: Create a hero animation between two screens.

**Starter Code**:
```dart
// TODO: Create Hero widget that animates between routes
class HeroScreen1 extends StatelessWidget {}
class HeroScreen2 extends StatelessWidget {}
```

---

### Exercise 35: Image Network

**Time**: 10 min | **Difficulty**: 2

**Description**: Load and display an image from URL with loading indicator.

**Starter Code**:
```dart
class NetworkImageExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Load image from URL with loadingBuilder
  }
}
```

---

## Level 3 - Intermediate (20 exercises)

### Exercise 36: Custom Clipper

**Time**: 15 min | **Difficulty**: 3

**Description**: Create a custom clipper for a wave effect.

**Starter Code**:
```dart
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // TODO: Create wave path
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
```

---

### Exercise 37: GestureDetector Gestures

**Time**: 10 min | **Difficulty**: 3

**Description**: Handle tap, double tap, and long press gestures.

**Starter Code**:
```dart
class GestureDemo extends StatefulWidget {
  @override
  State<GestureDemo> createState() => _GestureDemoState();
}
// TODO: Show different text based on gesture type
```

---

### Exercise 38: Draggable Widget

**Time**: 15 min | **Difficulty**: 3

**Description**: Create a draggable box that can be moved around.

**Starter Code**:
```dart
class DraggableBox extends StatefulWidget {
  @override
  State<DraggableBox> createState() => _DraggableBoxState();
}
// TODO: Implement drag functionality
```

---

### Exercise 39: DragTarget Drop Zone

**Time**: 15 min | **Difficulty**: 3

**Description**: Create a drop zone that accepts draggable items.

**Starter Code**:
```dart
class DropZone extends StatefulWidget {
  @override
  State<DropZone> createState() => _DropZoneState();
}
// TODO: Implement DragTarget with onAccept
```

---

### Exercise 40: InheritedWidget

**Time**: 20 min | **Difficulty**: 3

**Description**: Create an InheritedWidget to share data down the tree.

**Starter Code**:
```dart
class ThemeData extends InheritedWidget {
  final Color color;

  const ThemeData({
    required this.color,
    required super.child,
  });

  // TODO: Implement of() method and updateShouldNotify
}
```

---

### Exercise 41: ValueListenableBuilder

**Time**: 15 min | **Difficulty**: 3

**Description**: Use ValueListenableBuilder to update UI on value change.

**Starter Code**:
```dart
class CounterWithBuilder extends StatefulWidget {
  @override
  State<CounterWithBuilder> createState() => _CounterWithBuilderState();
}
// TODO: Use ValueNotifier and ValueListenableBuilder
```

---

### Exercise 42: StreamBuilder Counter

**Time**: 15 min | **Difficulty**: 3

**Description**: Use StreamBuilder to display a stream of counter values.

**Starter Code**:
```dart
class StreamCounter extends StatefulWidget {
  @override
  State<StreamCounter> createState() => _StreamCounterState();
}
// TODO: Create stream that emits counter values
```

---

### Exercise 43: FutureBuilder Data Load

**Time**: 15 min | **Difficulty**: 3

**Description**: Use FutureBuilder to load and display data.

**Starter Code**:
```dart
class FutureLoader extends StatelessWidget {
  Future<String> loadData() async {
    await Future.delayed(const Duration(seconds: 2));
    return 'Data loaded!';
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Use FutureBuilder
  }
}
```

---

### Exercise 44: AnimatedContainer

**Time**: 10 min | **Difficulty**: 3

**Description**: Animate container properties on tap.

**Starter Code**:
```dart
class AnimatedBox extends StatefulWidget {
  @override
  State<AnimatedBox> createState() => _AnimatedBoxState();
}
// TODO: Toggle size, color with AnimatedContainer
```

---

### Exercise 45: AnimatedOpacity

**Time**: 10 min | **Difficulty**: 3

**Description**: Fade in/out a widget on button press.

**Starter Code**:
```dart
class FadeWidget extends StatefulWidget {
  @override
  State<FadeWidget> createState() => _FadeWidgetState();
}
// TODO: Toggle opacity with AnimatedOpacity
```

---

### Exercise 46: SliverAppBar

**Time**: 15 min | **Difficulty**: 3

**Description**: Create a scrolling app bar that shrinks.

**Starter Code**:
```dart
class SliverApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Create CustomScrollView with SliverAppBar
  }
}
```

---

### Exercise 47: NestedScrollView

**Time**: 15 min | **Difficulty**: 3

**Description**: Create a NestedScrollView with TabBar.

**Starter Code**:
```dart
class NestedScrollExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Implement NestedScrollView with tabs
  }
}
```

---

### Exercise 48: LayoutBuilder

**Time**: 15 min | **Difficulty**: 3

**Description**: Use LayoutBuilder to create responsive layout.

**Starter Code**:
```dart
class ResponsiveLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Use LayoutBuilder for responsive design
  }
}
```

---

### Exercise 49: OrientationBuilder

**Time**: 10 min | **Difficulty**: 3

**Description**: Change layout based on portrait/landscape orientation.

**Starter Code**:
```dart
class OrientationLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Use OrientationBuilder
  }
}
```

---

### Exercise 50: MediaQuery Responsive

**Time**: 10 min | **Difficulty**: 3

**Description**: Use MediaQuery to create responsive breakpoints.

**Starter Code**:
```dart
class ResponsiveWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Use MediaQuery for breakpoints
  }
}
```

---

### Exercise 51: Custom MultiChildLayout

**Time**: 20 min | **Difficulty**: 4

**Description**: Create a custom layout with MultiChildLayoutDelegate.

**Starter Code**:
```dart
class CustomLayout extends SingleChildLayoutDelegate {
  @override
  Size getSize(BoxConstraints constraints) {
    // TODO: Implement
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // TODO: Implement
  }

  @override
  bool shouldRelayout(covariant CustomLayout oldDelegate) => false;
}
```

---

### Exercise 52: RepaintBoundary

**Time**: 15 min | **Difficulty**: 3

**Description**: Use RepaintBoundary to optimize rendering.

**Starter Code**:
```dart
class OptimizedList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Wrap expensive widget with RepaintBoundary
  }
}
```

---

### Exercise 53: KeyedSubtree

**Time**: 10 min | **Difficulty**: 3

**Description**: Use KeyedSubtree to preserve state.

**Starter Code**:
```dart
// TODO: Explain when and how to use KeyedSubtree
```

---

### Exercise 54: WillPopScope

**Time**: 10 min | **Difficulty**: 3

**Description**: Intercept back button press.

**Starter Code**:
```dart
class ConfirmExit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Use WillPopScope to confirm exit
  }
}
```

---

### Exercise 55: FocusScope

**Time**: 15 min | **Difficulty**: 3

**Description**: Manage focus between text fields.

**Starter Code**:
```dart
class FocusManagement extends StatefulWidget {
  @override
  State<FocusManagement> createState() => _FocusManagementState();
}
// TODO: Move focus between fields on button press
```

---

## Level 4 - Hard (15 exercises)

### Exercise 56: Custom Scrollable

**Time**: 25 min | **Difficulty**: 4

**Description**: Create a custom scrollable widget.

**Starter Code**:
```dart
class CustomScrollable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Implement custom scrolling
  }
}
```

---

### Exercise 57: Physics Customization

**Time**: 20 min | **Difficulty**: 4

**Description**: Create custom scroll physics with bouncing effect.

**Starter Code**:
```dart
class CustomPhysics extends ScrollPhysics {
  const CustomPhysics({super.parent});

  @override
  CustomPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPhysics(parent: buildParent(ancestor));
  }

  // TODO: Implement simulation for custom physics
}
```

---

### Exercise 58: RenderObject Widget

**Time**: 30 min | **Difficulty**: 5

**Description**: Create a custom RenderObjectWidget.

**Starter Code**:
```dart
class CustomRenderObject extends LeafRenderObjectWidget {
  final Color color;

  const CustomRenderObject({required this.color});

  @override
  RenderObject createRenderObject(BuildContext context) {
    // TODO: Create custom RenderObject
  }
}
```

---

### Exercise 59: CustomTransition

**Time**: 20 min | **Difficulty**: 4

**Description**: Create a custom page transition.

**Starter Code**:
```dart
class CustomPageRoute<T> extends PageRouteBuilder<T> {
  CustomPageRoute({required WidgetBuilder pageBuilder})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => pageBuilder(context),
          // TODO: Add custom transitions
        );
}
```

---

### Exercise 60: ShaderMask Effect

**Time**: 15 min | **Difficulty**: 4

**Description**: Apply gradient to text using ShaderMask.

**Starter Code**:
```dart
class GradientText extends StatelessWidget {
  final String text;

  const GradientText(this.text);

  @override
  Widget build(BuildContext context) {
    // TODO: Apply gradient shader to text
  }
}
```

---

### Exercise 61: BackdropFilter Blur

**Time**: 15 min | **Difficulty**: 4

**Description**: Create frosted glass effect with BackdropFilter.

**Starter Code**:
```dart
class GlassEffect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Apply backdrop blur
  }
}
```

---

### Exercise 62: Transform Widget

**Time**: 15 min | **Difficulty**: 4

**Description**: Apply rotation, scale, and translation transforms.

**Starter Code**:
```dart
class TransformedWidget extends StatefulWidget {
  @override
  State<TransformedWidget> createState() => _TransformedWidgetState();
}
// TODO: Apply multiple transforms
```

---

### Exercise 63: Implicit Animation Builder

**Time**: 20 min | **Difficulty**: 4

**Description**: Create a custom implicit animation widget.

**Starter Code**:
```dart
class AnimatedSize extends ImplicitlyAnimatedWidget {
  // TODO: Implement custom implicit animation
}
```

---

### Exercise 64: AnimationController

**Time**: 20 min | **Difficulty**: 4

**Description**: Create explicit animation with AnimationController.

**Starter Code**:
```dart
class ExplicitAnimation extends StatefulWidget {
  @override
  State<ExplicitAnimation> createState() => _ExplicitAnimationState();
}

class _ExplicitAnimationState extends State<ExplicitAnimation>
    with SingleTickerProviderStateMixin {
  // TODO: Create and manage AnimationController
}
```

---

### Exercise 65: CurvedAnimation

**Time**: 15 min | **Difficulty**: 4

**Description**: Apply different curves to animation.

**Starter Code**:
```dart
class CurvedAnimationExample extends StatefulWidget {
  @override
  State<CurvedAnimationExample> createState() => _CurvedAnimationState();
}
// TODO: Apply CurvedAnimation with custom curve
```

---

### Exercise 66: Tween Animation

**Time**: 20 min | **Difficulty**: 4

**Description**: Use Tween to animate between values.

**Starter Code**:
```dart
class TweenAnimationExample extends StatefulWidget {
  @override
  State<TweenAnimationExample> createState() => _TweenAnimationState();
}
// TODO: Create and animate Tween
```

---

### Exercise 67: AnimatedBuilder

**Time**: 20 min | **Difficulty**: 4

**Description**: Use AnimatedBuilder for complex animations.

**Starter Code**:
```dart
class AnimatedBuilderExample extends StatefulWidget {
  @override
  State<AnimatedBuilderExample> createState() => _AnimatedBuilderState();
}
// TODO: Use AnimatedBuilder for efficient rebuilds
```

---

### Exercise 68: StaggeredAnimation

**Time**: 25 min | **Difficulty**: 4

**Description**: Create staggered animation sequence.

**Starter Code**:
```dart
class StaggeredAnimation extends StatefulWidget {
  @override
  State<StaggeredAnimation> createState() => _StaggeredAnimationState();
}
// TODO: Animate multiple items with delay
```

---

### Exercise 69: Physics Simulation

**Time**: 25 min | **Difficulty**: 4

**Description**: Create spring simulation for animation.

**Starter Code**:
```dart
class SpringAnimation extends StatefulWidget {
  @override
  State<SpringAnimation> createState() => _SpringAnimationState();
}
// TODO: Use SpringSimulation
```

---

### Exercise 70: Pointer Events

**Time**: 20 min | **Difficulty**: 4

**Description**: Handle raw pointer events with Listener widget.

**Starter Code**:
```dart
class PointerTracker extends StatefulWidget {
  @override
  State<PointerTracker> createState() => _PointerTrackerState();
}
// TODO: Track pointer position with Listener
```

---

## Level 5 - Expert (10 exercises)

### Exercise 71: Custom Layout Engine

**Time**: 30 min | **Difficulty**: 5

**Description**: Build a complete custom layout engine.

**Starter Code**:
```dart
// TODO: Create multi-child layout with complex positioning
```

---

### Exercise 72: RenderSliver Custom

**Time**: 30 min | **Difficulty**: 5

**Description**: Create a custom RenderSliver for scrolling effects.

---

### Exercise 73: GestureArena

**Time**: 25 min | **Difficulty**: 5

**Description**: Understand and customize gesture arena.

---

### Exercise 74: Hit Testing

**Time**: 25 min | **Difficulty**: 5

**Description**: Customize hit testing behavior.

---

### Exercise 75: Intrinsic Dimensions

**Time**: 25 min | **Difficulty**: 5

**Description**: Implement intrinsic dimension calculations.

---

### Exercise 76: Baseline Metric

**Time**: 25 min | **Difficulty**: 5

**Description**: Handle baseline metrics for text alignment.

---

### Exercise 77: Relayout Boundary

**Time**: 25 min | **Difficulty**: 5

**Description**: Optimize with proper relayout boundaries.

---

### Exercise 78: PaintEfficiency

**Time**: 25 min | **Difficulty**: 5

**Description**: Optimize paint operations.

---

### Exercise 79: Compositing Layer

**Time**: 25 min | **Difficulty**: 5

**Description**: Manage compositing layers efficiently.

---

### Exercise 80: Accessibility Widget

**Time**: 20 min | **Difficulty**: 4

**Description**: Create accessible widget with semantics.

**Starter Code**:
```dart
class AccessibleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Add Semantics widget
  }
}
```

---
