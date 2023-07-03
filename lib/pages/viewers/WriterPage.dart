import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:myapp/database/CourseModel.dart';
import 'package:myapp/database/ItemModel.dart';
import 'package:myapp/widgets/http_post.dart';

class WriterPage extends StatefulWidget {
  const WriterPage({
    Key? key,
  }) : super(key: key);

  @override
  State<WriterPage> createState() => _WriterPageState();
}

class _WriterPageState extends State<WriterPage> {
  String result = '';
  Item _args = Item();
  final HtmlEditorController controller = HtmlEditorController();

  @override
  void initState() {
    super.initState();
  }

  void setText(context) async {
    controller.setText(_args.jsondata!);
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
    args.sync = false;
    updateItem(args);

    setState(() {
      _args = args;
    });

    Future.delayed(const Duration(milliseconds: 2000), () => setText(context));

    return Scaffold(
        appBar: AppBar(
          title: Text(getName(args)),
        ),
        body: HtmlEditor(
          controller: controller, //required
          htmlEditorOptions: const HtmlEditorOptions(
            autoAdjustHeight: true,
            initialText: "text content initial, if any",
          ),
          otherOptions: const OtherOptions(),
        ),
        bottomNavigationBar:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton(
            onPressed: () async {
              if (getEdit(_args)) {
                _args.jsondata = await controller.getText();
                await updateItem(_args);
              }
              Navigator.of(context).pop();
            },
            child: (getEdit(args))
                ? const Text('Сохранить черновик')
                : const Text('Назад'),
          ),
          const SizedBox(
            height: 30,
            width: 30,
          ),
          (getEdit(args))
              ? ElevatedButton(
                  onPressed: () async {
                    _args.jsondata = await controller.getText();
                    await updateItem(_args);
                    if (args.name!.contains("%oncheck%")) {
                      return;
                    }
                    var isOnline = await hasNetwork(context);
                    if (!isOnline || (args.jsondata ?? "") == "") {
                      return;
                    }
                    args.sync = true;
                    await updateItem(args);
                    setState(() {});
                    String? fpath;
                    await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Выбрать файл?'),
                            content: const Text(
                                "Будет закреплён к ответу на писменную работу."),
                            actions: [
                              ElevatedButton(
                                  onPressed: () async {
                                    FilePickerResult? result =
                                        await FilePicker.platform.pickFiles();
                                    if (result != null) {
                                      fpath = result.files.single.path;
                                    }
                                    //setState(() {});
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Выбрать')),
                              ElevatedButton(
                                  onPressed: () {
                                    //setState(() {});
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Отмена')),
                            ],
                          );
                        });
                    await httpAPI(
                        "close/students/sync.asp",
                        '{"id":"' +
                            args.guid! +
                            '", "type":"WRITING~1", "data":"' +
                            args.jsondata!.replaceAll('"', "&quot;") +
                            '"}',
                        context);
                    await httpAPIMultipart(
                        "close/students/sync.asp",
                        '{"id":"' + args.guid! + '", "type":"WRITING~2"}',
                        fpath,
                        context);
                    args.name = args.name!.split(" %")[0] + " %oncheck%";
                    args.sync = false;
                    await updateItem(args);
                    //setState(() {});
                    Navigator.pushNamed(context, '/items',
                        arguments: await getCourse(args.courseid!));
                  },
                  child: const Text('Отправить'),
                )
              : const SizedBox(
                  height: 30,
                  width: 0,
                ),
        ]));
  }
}
