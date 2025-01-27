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

  AnnotationType selectedOption = AnnotationType.line; // Default option.

// Function to handle tapping on the drawer options and update the selected option.
  void _handleDrawerOptionTap(AnnotationType option) {
    setState(() {
      selectedOption = option;
    });
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: create a new example 
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
                onTap: () => _handleDrawerOptionTap(AnnotationType.line),
                selected: selectedOption == AnnotationType.line,
              ),
              ListTile(
                title: const Text('Rectangular'),
                onTap: () => _handleDrawerOptionTap(AnnotationType.rectangle),
                selected: selectedOption == AnnotationType.rectangle,
              ),
              ListTile(
                title: const Text('Oval'),
                onTap: () => _handleDrawerOptionTap(AnnotationType.oval),
                selected: selectedOption == AnnotationType.oval,
              ),
              ListTile(
                title: const Text('Text'),
                onTap: () => _handleDrawerOptionTap(AnnotationType.text),
                selected: selectedOption == AnnotationType.text,
              ),
            ],
          ),
        ),
        body: Center(
          child: ImageAnnotation.asset(
            'assets/images/your_image.jpg',
            annotationType: selectedOption,
          ),
        ),
      ),
    );
  }
}
