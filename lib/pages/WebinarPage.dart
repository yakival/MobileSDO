import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/database/WebinarModel.dart';
import 'package:myapp/widgets/bottom_menu.dart';
import 'package:myapp/widgets/config.dart';
import 'package:myapp/widgets/http_post.dart';
import 'package:url_launcher/url_launcher.dart';

class WebinarPage extends StatefulWidget {
  const WebinarPage({
    Key? key,
  }) : super(key: key);

  @override
  State<WebinarPage> createState() => _WebinarPageState();
}

class _WebinarPageState extends State<WebinarPage> {
  List<Webinar> _list = [];
  var isrun = false;

  @override
  void initState() {
    super.initState();
  }

  Future<List<Webinar>> _getData(context) async {
    if (_list.isEmpty) {
      _list = await getAllWebinar();
    }
    return _list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Вебинары'),
      ),
      bottomNavigationBar: const BottomMenu(),
      body: FutureBuilder<List<Webinar>>(
          future: _getData(context),
          builder:
              (BuildContext context, AsyncSnapshot<List<Webinar>> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    var item = snapshot.data![index];
                    return Card(
                      child: ListTile(
                          title: Text(item.name!),
                          leading: CircleAvatar(
                            backgroundColor: Colors.purple.shade800,
                            child: Text((item.type == "Openmeetings")
                                ? "OM"
                                : (item.type == "Adobe Connect")
                                    ? "AC"
                                    : "W"),
                          ),
                          subtitle: Text(
                              ((item.dtfrom!.isBefore(DateTime.now()))
                                      ? " "
                                      : "c " +
                                          DateFormat('dd.MM.yyyy HH:mm')
                                              .format(item.dtfrom!) +
                                          " ") +
                                  "по " +
                                  DateFormat('dd.MM.yyyy HH:mm')
                                      .format(item.dtto!)),
                          trailing: (item.dtfrom!.isBefore(DateTime.now()))
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.input_outlined,
                                    color: Colors.green,
                                  ),
                                  onPressed: () async {
                                    var res = await httpAPI(
                                        "close/students/mobileApp.asp",
                                        '{"command": "getWebinar", "id": "${item.eventid}"}',
                                        context) as Map<String, dynamic>;
                                    if (res["url"] != "") {
                                      await launch(res["url"]);
                                    }
                                    setState(() {});
                                  },
                                )
                              : null),
                    );
                  });
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
