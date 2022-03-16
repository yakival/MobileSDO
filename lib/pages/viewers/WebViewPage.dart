import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:disk_space/disk_space.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http_server/http_server.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:myapp/database/ItemModel.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({Key? key}) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  HttpServer? _server;
  String _initialUrl = "";
  Item _args = Item();
  Directory _httpDirectory = Directory("");
  int _stackToView = 1;
  bool _unzipped = true;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
    _startServer();
    // Enable hybrid composition.
    //if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Item;
    setState(() {
      _args = args;
    });

    if (!_unzipped) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Нет свободного места"),
        backgroundColor: Colors.red,
      ));
    }

    if (_initialUrl == "") {
      return Scaffold(
        appBar: AppBar(
          title: Text(args.name!),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(args.name!),
        ),
        body: IndexedStack(
          index: _stackToView,
          children: [
            Column(
              children: <Widget>[
                Expanded(
                    child: WebView(
                  initialUrl: _initialUrl,
                  javascriptMode: JavascriptMode.unrestricted,
                  debuggingEnabled: true,
                  allowsInlineMediaPlayback: true,
                  zoomEnabled: true,
                  onPageStarted: (url) {
                    //await controller.evaluateJavascript(source: "window.localStorage.setItem('key', 'localStorage value!')");
                  },
                  onPageFinished: (finish) {
                    setState(() {
                      _stackToView = 0;
                    });
                  },
                  javascriptChannels: {
                    JavascriptChannel(
                        name: 'Data',
                        onMessageReceived: (JavascriptMessage message) {
                          args.jsondata = message.message;
                          var json = jsonDecode(args.jsondata!);
                          args.exec = json["complete"];
                          updateItem(args);
                        })
                  },
                )),
              ],
            ),
            const Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ));
  }

  Future _startServer() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final checkPath = await Directory('${appDir.path}/www').exists();
    if (checkPath) Directory('${appDir.path}/www').deleteSync(recursive: true);
    final Directory httpDirectory =
        await Directory('${appDir.path}/www').create(recursive: true);
    final VirtualDirectory staticFiles = VirtualDirectory(httpDirectory.path)
      ..allowDirectoryListing = true;

    _unzipped = await _setupHttpFolder(httpDirectory);
    await runZoned(() async {
      final HttpServer server =
          await HttpServer.bind(InternetAddress.loopbackIPv4, 3000);
      final String initialUrl =
          'http://${server.address.host}:${server.port}/index.htm';

      setState(() {
        _server = server;
        _httpDirectory = httpDirectory;
        _initialUrl = initialUrl;
      });
      server.listen(staticFiles.serveRequest);
    });
  }

  /// preparing http assets
  Future<bool> _setupHttpFolder(Directory parentDir) async {
    Archive archive;

    String indexContent = await rootBundle.loadString('assets/index.txt');
    indexContent = indexContent.replaceFirst('%%', _args.jsondata!);
    File indexFile = File('${parentDir.path}/index.htm');
    await indexFile.writeAsString(indexContent);

    Directory framesetDir = Directory('${parentDir.path}/');
    await framesetDir.create();
    ByteData data = await rootBundle.load('assets/Frameset.zip');
    List<int> content = List<int>.generate(data.lengthInBytes, (index) => 0);
    for (var i = 0; i < data.lengthInBytes; i++) {
      content[i] = data.getUint8(i);
    }
    archive = ZipDecoder().decodeBytes(content);
    _uncompress(archive, framesetDir);

    Directory archiveDir = Directory('${parentDir.path}/archive');
    await archiveDir.create();
    var bytes = await File(_args.localpath!).readAsBytes();
    data = bytes.buffer.asByteData();
    content = List<int>.generate(data.lengthInBytes, (index) => 0);
    for (var i = 0; i < data.lengthInBytes; i++) {
      content[i] = data.getUint8(i);
    }
    archive = ZipDecoder().decodeBytes(content);
    var _size = 0;
    for (ArchiveFile file in archive) {
      if (file.isFile) {
        _size += file.size;
      }
    }
    var _free = await DiskSpace.getFreeDiskSpace;
    _free = (_free ?? 0) * (1024.0 * 1024.0);
    if (_size > _free) {
      return false;
    }
    _uncompress(archive, archiveDir);
    return true;
  }

  /// uncompressing the example archive to app directory
  Future<void> _uncompress(Archive archive, Directory dest) async {
    for (ArchiveFile file in archive) {
      if (file.isFile) {
        List<int> data = file.content;
        File('${dest.path}/${file.name}')
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory('${dest.path}/${file.name}')..createSync(recursive: true);
      }
    }
  }

  /// stoping server and removing http assets
  Future _cleanup() async {
    await _server?.close();
    await _httpDirectory.delete(recursive: true);
  }
}
