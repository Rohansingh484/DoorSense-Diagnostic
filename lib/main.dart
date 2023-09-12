import 'package:flutter/material.dart';
enum StatusCheck {idle,loading,success,failure} //declare state check
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Home Screen'),
    );
  }
}
// work in my home page
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
final StatusCheck status = StatusCheck.idle;

Widget leadingIconState(StatusCheck status) {
  switch (status) {
    case StatusCheck.idle:
      return Text("-");
    case StatusCheck.loading:
      return CircularProgressIndicator();
    case StatusCheck.success:
      return Icon(Icons.check_box, color: Colors.green,);
    case StatusCheck.failure:
      return Icon(Icons.highlight_off, color: Colors.red,);
    default:
      return Text("-");
  }
}
// can be edited
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
           ListTile(leading: leadingIconState(status), title: Text("Step 1: Init bluetooth "), trailing: Icon(Icons.arrow_forward_ios_outlined),),

            ListTile(leading: leadingIconState(status), title: Text("Step 2: Connect to bluetooth"), trailing: Icon(Icons.arrow_forward_ios_outlined),),

            ListTile(leading: leadingIconState(status), title: Text("Step 3: Register fingerprint"), trailing: Icon(Icons.arrow_forward_ios_outlined),),

            ListTile(leading: leadingIconState(status), title: Text("Step 4: Show bluetooth hash"), trailing: Icon(Icons.arrow_forward_ios_outlined),),

            ListTile(leading: leadingIconState(status), title: Text("Step 5: Store hash"), trailing: Icon(Icons.arrow_forward_ios_outlined),),

            ListTile(leading: leadingIconState(status), title: Text("Step 6: Unlock actuator"), trailing: Icon(Icons.arrow_forward_ios_outlined),),

            ListTile(leading: leadingIconState(status), title: Text(""), trailing: Icon(Icons.arrow_forward_ios_outlined),)
          ],
        ),
      ),

    );
  }
}
