// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
  double _sliderValue = 0;
  double scaleValue = 0;
  double scaleValue2 = 0;
  int durationInSeconds = 4;
  late Animation<double> animation;
  late AnimationController _animationController;
  late Animation<double> tween;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: durationInSeconds),
      vsync: this,
    );

    // for testing purposes, to see if chaining is different
    // from using animate.
    // result: no difference so far
    animation = Tween<double>(begin: 0.5, end: 2)
        .chain(CurveTween(curve: Curves.easeInOutBack))
        .animate(_animationController);

    tween = Tween<double>(begin: 2, end: 0.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutBack,
      ),
    );

    // repeat and reverse all animations from this controller
    _animationController.repeat(reverse: true);

    /* learnings:
    you can use one controller for multiple animations
    the duration for the controller is the total time for all animations
    you can stagger the animations, using Interval to give different start and end times
    connect your animation to the controller. use the controller as parent
    connect your transition to your animation, using turns/scale/whatever as controller

    */
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.teal,
          ),
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Hello World!'),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(
                      width: 40.0,
                      height: 40.0,
                    ),
                  ),
                  // Standard Tween Animation, using AnimationBuilder
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 1, end: scaleValue),
                    duration: Duration(seconds: 2),
                    curve: Easing.standard,
                    builder: (context, scalevalue, child) {
                      return Transform.scale(
                        scale: scalevalue,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                          child: SizedBox(
                            height: 10.0,
                            width: 10.0,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  // Slider for the end value of the amber circle above
                  Slider.adaptive(
                    value: _sliderValue,
                    onChanged: (value) {
                      setState(() {
                        _sliderValue = value;
                        scaleValue = 1 + (_sliderValue * 8);
                      });
                    },
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  // Standard Animation builder with onEnd() to repeat the size change
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 1, end: scaleValue2),
                    duration: Duration(seconds: 2),
                    curve: Easing.standardDecelerate,
                    onEnd: () {
                      setState(() {
                        scaleValue2 = scaleValue2 == 8 ? 4 : 8;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(
                        height: 10.0,
                        width: 10.0,
                      ),
                    ),
                    builder: (context, scalevalue, myChild) {
                      return Transform.scale(
                        scale: scalevalue,
                        child: myChild,
                      );
                    },
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  // Using scale transitions to explicitly animate the scale.
                  ScaleTransition(
                    alignment: Alignment.center,
                    scale: animation,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(
                        height: 40.0,
                        width: 40.0,
                      ),
                    ),
                  ),
                  // also using scale transitions to explicitly animate the scale. Used for comparison
                  ScaleTransition(
                    alignment: Alignment.center,
                    scale: tween,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(
                        height: 40.0,
                        width: 40.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
