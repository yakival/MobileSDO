import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart' as web;
import 'package:myapp/database/ItemModel.dart';

class FileReaderPage extends StatefulWidget {
  const FileReaderPage({Key? key}) : super(key: key);

  @override
  _FileReaderPageState createState() => _FileReaderPageState();
}

class _FileReaderPageState extends State<FileReaderPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Item;

    return Scaffold(
        appBar: AppBar(
          title: const Text("doc"),
        ),
        body: web.WebView(
          initialUrl:
              "https://docs.google.com/gview?embedded=true&url=file:///android_asset/flutter_assets/assets/example.xlsx",
        ));
  }
}
