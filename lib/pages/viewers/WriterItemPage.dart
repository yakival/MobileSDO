import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:myapp/database/ItemModel.dart';
import 'package:open_file_plus/open_file_plus.dart';

class WriterItemPage extends StatefulWidget {
  const WriterItemPage({
    Key? key,
  }) : super(key: key);

  @override
  State<WriterItemPage> createState() => _WriterItemPageState();
}

class _WriterItemPageState extends State<WriterItemPage> {
  String result = '';
  final HtmlEditorController controller = HtmlEditorController();
  List<Item> list_ = [];
  Item _args = Item();
  Map<String, dynamic> descr = {};

  @override
  void initState() {
    super.initState();
  }

  Future<List<Item>> getItems(Item param) async {
    list_ = [];
    if (descr["link"].isNotEmpty) {
      list_.add(
        Item(
            jsondata: "ССЫЛКА",
            name: descr["link"],
            description: descr["link"],
            localpath: descr["link"],
            type: (descr["link"]!.contains("http"))
                ? "html"
                : descr["link"]?.split(".").last),
      );
    }
    final fl = File(param.localpath!);
    var _files = fl.parent.listSync(recursive: true, followLinks: false);
    for (FileSystemEntity fl_ in _files) {
      list_.add(Item(
          jsondata: "ФАЙЛ",
          name: fl_.path.split("/").last,
          description: fl_.path.split("/").last,
          localpath: fl_.path,
          type: fl_.path.split(".").last));
    }

    return list_;
  }

  openFile(filePath) async {
    var _result = await OpenFile.open(filePath);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(_result.message),
      backgroundColor: Colors.blue,
    ));
  }

  getName(Item itm) {
    String nm = itm.name ?? "";
    if (itm.type == "WRITING") {
      nm = nm.replaceAll("%oncheck%", " [на проверке]");
      nm = nm.replaceAll("%failed%", " [возврат]");
      nm = nm.replaceAll("%passed%", " [проверено]");
    }
    return nm;
  }

  getEdit(Item item) {
    if ((item.name!.contains("%passed%")) ||
        (item.name!.contains("%oncheck%"))) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Item;
    setState(() {
      _args = args;
      descr = jsonDecode(_args.description!);
    });

    return Scaffold(
        appBar: AppBar(
          title: Text(getName(args)),
        ),
        body: Column(
            children: <Widget>[
        Padding(
        padding: const EdgeInsets.fromLTRB(
            10.0, 0.0, 0.0, 0.0),
        child: Row(
            children: <Widget>[
              const Expanded(
                child: Text('Описание:', textAlign: TextAlign.left),
              ),
              Expanded(
                child: Html(data: descr["descr"]),
              ),
            ],
          )),
    Expanded(
    child:
    FutureBuilder<List<Item>>(
            future: getItems(args),
            builder:
                (BuildContext context, AsyncSnapshot<List<Item>> snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (BuildContext context, int index) {
                      Item item = snapshot.data![index];
                      return Card(
                          child: ListTile(
                        title: Text(item.jsondata!,
                            style: const TextStyle(
                              color: Colors.black,
                            )),
                        subtitle: Column(children: [
                          Html(data: item.name),
                        ]),
                        leading: (item.type == 'pdf')
                            ? const Padding(
                                padding:
                                    EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                                child: Icon(
                                  Icons.picture_as_pdf_outlined,
                                  color: Colors.blue,
                                ))
                            : (item.type == 'png' ||
                                    item.type == 'jpg' ||
                                    item.type == 'jpeg' ||
                                    item.type == 'gif')
                                ? const Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        10.0, 0.0, 0.0, 0.0),
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.blue,
                                    ))
                                : (item.type == 'mp4')
                                    ? const Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            10.0, 0.0, 0.0, 0.0),
                                        child: Icon(
                                          Icons.video_camera_back_outlined,
                                          color: Colors.blue,
                                        ))
                                    : (item.type == 'html' ||
                                            item.type == 'CMP')
                                        ? const Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                10.0, 0.0, 0.0, 0.0),
                                            child: Icon(
                                              Icons.web_outlined,
                                              color: Colors.blue,
                                            ))
                                        : (item.type == 'doc' ||
                                                item.type == 'docx' ||
                                                item.type == 'xls' ||
                                                item.type == 'xlsx')
                                            ? const Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    10.0, 0.0, 0.0, 0.0),
                                                child: Icon(
                                                  Icons.document_scanner,
                                                  color: Colors.blue,
                                                ))
                                            : null,
                        onTap: () async {
                          if (item.type == "pdf") {
                            Navigator.pushNamed(context, '/viewPDF',
                                arguments: item);
                            return;
                          }
                          if (item.type == "mp4") {
                            Navigator.pushNamed(context, '/viewVideo',
                                arguments: item);
                            return;
                          }
                          if (item.type == "html" || item.type == 'CMP') {
                            Navigator.pushNamed(context, '/viewHtml',
                                arguments: item);
                            return;
                          }
                          if (item.type == 'png' ||
                              item.type == 'jpg' ||
                              item.type == 'jpeg' ||
                              item.type == 'gif') {
                            Navigator.pushNamed(context, '/viewPhoto',
                                arguments: item);
                            return;
                          }

                          openFile(item.localpath);
                        },
                      ));
                    });
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }),
    )
        ]),
        bottomNavigationBar:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/writer', arguments: _args);
            },
            child: (getEdit(_args))
                ? const Text('Начать выполнение')
                : const Text('Просмотр'),
          ),
          const SizedBox(
            height: 30,
            width: 30,
          ),
        ]));
  }
}
