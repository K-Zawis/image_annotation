import 'package:flutter/material.dart';
import 'package:image_annotation/image_annotation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Define the scaffold key as final to prevent unintentional changes.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  AnnotationOption selectedOption = AnnotationOption.line; // Default option.

// Function to handle tapping on the drawer options and update the selected option.
  void _handleDrawerOptionTap(AnnotationOption option) {
    setState(() {
      selectedOption = option;
    });
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Annotation Demo',
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Image Annotation Demo'),
          centerTitle: true,
        ),
        endDrawer: Drawer(
          child: ListView(
            children: <Widget>[
              const DrawerHeader(
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                child: UserAccountsDrawerHeader(
                  decoration: BoxDecoration(color: Colors.green),
                  accountName: Text('Image Annotation Types'),
                  accountEmail: Text('choose one option'),
                ),
              ),
              ListTile(
                title: const Text('Line'),
                onTap: () => _handleDrawerOptionTap(AnnotationOption.line),
                selected: selectedOption == AnnotationOption.line,
              ),
              ListTile(
                title: const Text('Rectangular'),
                onTap: () => _handleDrawerOptionTap(AnnotationOption.rectangle),
                selected: selectedOption == AnnotationOption.rectangle,
              ),
              ListTile(
                title: const Text('Oval'),
                onTap: () => _handleDrawerOptionTap(AnnotationOption.oval),
                selected: selectedOption == AnnotationOption.oval,
              ),
              ListTile(
                title: const Text('Text'),
                onTap: () => _handleDrawerOptionTap(AnnotationOption.text),
                selected: selectedOption == AnnotationOption.text,
              ),
            ],
          ),
        ),
        body: Center(
          child: ImageAnnotation(
            imagePath: 'assets/images/your_image.jpg',
            annotationType: selectedOption,
          ),
        ),
      ),
    );
  }
}
