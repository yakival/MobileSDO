import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/widgets/config.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:myapp/database/ItemModel.dart';

class ScormSyncPage extends StatefulWidget {
  const ScormSyncPage({Key? key}) : super(key: key);

  @override
  _ScormSyncPageState createState() => _ScormSyncPageState();
}

class _ScormSyncPageState extends State<ScormSyncPage> {
  int _stackToView = 1;
  late WebViewController _myController;
  String msg_ = "-- / --";

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
          title: Text(args.name! + " (передача результатов)"),
        ),
        body: IndexedStack(
          index: _stackToView,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Visibility(
                    visible: false,
                    maintainState: true,
                    child: SizedBox(
                        height: 1,
                        child: WebView(
                          onWebViewCreated:
                              (WebViewController webViewController) {
                            _myController = webViewController;
                            Map<String, String> headers = {
                              "Authorization": "Basic " +
                                  base64Encode(utf8.encode(
                                      '${GlobalData.username}:${GlobalData.password}'))
                            };
                            webViewController.loadUrl(
                                '${GlobalData.baseUrl}/close/students/syncscorm.asp?AttemptId=${args.attempt}',
                                headers: headers);
                          },
                          javascriptMode: JavascriptMode.unrestricted,
                          debuggingEnabled: true,
                          allowsInlineMediaPlayback: true,
                          onPageStarted: (url) async {},
                          onPageFinished: (finish) async {
                            await _myController.runJavascript(
                                "window.localStorage.setItem('scorm', '" +
                                    args.jsondata! +
                                    "'); syncScorm();");
                            setState(() {
                              _stackToView = 0;
                            });
                          },
                          javascriptChannels: {
                            JavascriptChannel(
                                name: 'Data',
                                onMessageReceived: (JavascriptMessage message) {
                                  var json = jsonDecode(message.message);
                                  setState(() {
                                    msg_ = "" +
                                        json["count"] +
                                        " / " +
                                        json["total"];
                                  });
                                  if (json["count"] == json["total"]) {
                                    Navigator.pop(context);
                                  }
                                })
                          },
                        ))),
                Center(
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Text(
                        msg_,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 30),
                      ),
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ));
  }
}
