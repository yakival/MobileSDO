import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:disk_space/disk_space.dart';
import 'package:flutter/material.dart';
import 'package:http_server/http_server.dart';
import 'package:myapp/widgets/http_post.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:myapp/database/ItemModel.dart';
import 'package:archive/archive.dart';

import 'package:flutter_lifecycle_aware/lifecycle.dart';
import '../../widgets/timer_class.dart';

class HtmlViewPage extends StatefulWidget {
  const HtmlViewPage({Key? key}) : super(key: key);

  @override
  _HtmlViewPageState createState() => _HtmlViewPageState();
}

class _HtmlViewPageState extends State<HtmlViewPage> with Lifecycle {
  HttpServer? _server;
  String _initialUrl = "";
  Item _args = Item();
  Directory _httpDirectory = Directory("");
  int _stackToView = 1;
  bool _unzipped = true;
  AViewModel model = AViewModel();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = AndroidWebView();

    final widgetsBinding = WidgetsBinding.instance;
    widgetsBinding?.addPostFrameCallback((callback) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        _args = ModalRoute.of(context)!.settings.arguments as Item;
        _startServer();
      }
    });
    getLifecycle().addObserver(model);
  }

  @override
  void dispose() {
    _cleanup();
    getLifecycle().removeObserver(model);
    model.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Item;
    model.setData(args);
    setState(() {
      _args = args;
    });
    if (_args.localpath!.contains("http")) {
      _initialUrl = _args.localpath!;
    }

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
                  onPageFinished: (finish) {
                    setState(() {
                      _stackToView = 0;
                    });
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
    if (checkPath) {
      Directory('${appDir.path}/www').deleteSync(recursive: true);
    }
    final Directory httpDirectory =
        await Directory('${appDir.path}/www').create(recursive: true);
    final VirtualDirectory staticFiles = VirtualDirectory(httpDirectory.path)
      ..allowDirectoryListing = true;

    if (_args.localpath!.contains("http")) {
      _unzipped = true;
      return;
    }

    bool exist = File(_args.localpath!).existsSync();
    if (exist) {
      Archive archive;

      /*
      var bytes = await File(_args.localpath!).readAsBytes();
      ByteData data = bytes.buffer.asByteData();
      List<int> content = List<int>.generate(data.lengthInBytes, (index) => 0);
      for (var i = 0; i < data.lengthInBytes; i++) {
        content[i] = data.getUint8(i);
      }
      archive = ZipDecoder().decodeBytes(content);
       */

      final inputStream = InputFileStream(_args.localpath!);
      archive = ZipDecoder().decodeBuffer(inputStream);

      _unzipped = true;
      var _size = 0;
      for (ArchiveFile file in archive) {
        if (file.isFile) {
          _size += file.size;
        }
      }
      var _free = await DiskSpace.getFreeDiskSpace;
      _free = (_free ?? 0) * (1024.0 * 1024.0);
      if (_size > _free) {
        _unzipped = false;
      } else {
        await _uncompress(archive, httpDirectory);
      }
    }
    await runZoned(() async {
      final HttpServer server =
          await HttpServer.bind(InternetAddress.loopbackIPv4, 3000);
      final String initialUrl =
          'http://${server.address.host}:${server.port}/index.html';

      setState(() {
        _server = server;
        _httpDirectory = httpDirectory;
        if (exist) {
          _initialUrl = initialUrl;
        }
      });
      server.listen(staticFiles.serveRequest);
    });
  }

  Future<void> _uncompress(Archive archive, Directory dest) async {
    for (ArchiveFile file in archive) {
      if (file.isFile) {
        List<int> data = file.content;
        File('${dest.path}/${file.name}')
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory('${dest.path}/${file.name}').createSync(recursive: true);
      }
    }
  }

  /// stoping server and removing http assets
  Future _cleanup() async {
    await _server?.close();
    await _httpDirectory.delete(recursive: true);
  }
}
