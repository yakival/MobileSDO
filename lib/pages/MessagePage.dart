import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:myapp/database/NotifyModel.dart';
import 'package:myapp/widgets/config.dart';

import '../widgets/left_menu.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  //int _counter = 0;

  @override
  void initState() {
    super.initState();
  }

  void check(Notify args) async {
    if (args.dtview == null) {
      args.dtview = DateTime.now();
      args.sync = true;
      await updateNotify(args);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Notify;
    if ((args.subject!.toLowerCase().contains("назначение")) ||
        (args.subject!.toLowerCase().contains("экзамен"))) {
      if (args.dtview == null) {
        GlobalData.isReadAll = false;
      }
    }

    Future.delayed(Duration.zero, () => check(args));

    return Scaffold(
      appBar: AppBar(
        title: Text(args.subject!),
      ),
      body: Html(
        data: args.body,
      ),
    );
  }
}
