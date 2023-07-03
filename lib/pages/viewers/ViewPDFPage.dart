import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_lifecycle_aware/lifecycle.dart';
import 'package:myapp/database/ItemModel.dart';
import 'package:myapp/widgets/http_post.dart';

import '../../widgets/left_menu.dart';

import 'package:pdfx/pdfx.dart';

import '../../widgets/timer_class.dart';
//import 'package:advance_pdf_viewer/src/page_picker.dart';

class ViewPDFPage extends StatefulWidget {
  const ViewPDFPage({
    Key? key,
  }) : super(key: key);

  @override
  State<ViewPDFPage> createState() => _ViewPDFPageState();
}

class _ViewPDFPageState extends State<ViewPDFPage> with Lifecycle {
  static int _initialPage = 2;
  int _actualPageNumber = _initialPage, _allPagesCount = 0;
  PdfController? _pdfController;
  Item _args = Item();
  AViewModel model = AViewModel();

  @override
  void initState() {
    super.initState();
    getLifecycle().addObserver(model);
  }

  @override
  void dispose() {
    _pdfController?.dispose();
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
    _pdfController ??= PdfController(
      document: PdfDocument.openFile(args.localpath!),
      initialPage: _initialPage,
    );

    return Scaffold(
        appBar: AppBar(
          title: Text(args.name!),
          actions: (_pdfController != null)
              ? <Widget>[
                  IconButton(
                    icon: const Icon(Icons.navigate_before),
                    onPressed: () {
                      _pdfController?.previousPage(
                        curve: Curves.ease,
                        duration: const Duration(milliseconds: 100),
                      );
                    },
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      '$_actualPageNumber/$_allPagesCount',
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.navigate_next),
                    onPressed: () {
                      _pdfController?.nextPage(
                        curve: Curves.ease,
                        duration: const Duration(milliseconds: 100),
                      );
                    },
                  ),
                ]
              : null,
        ),
        //drawer: const LeftMenu(),
        body: PdfView(
          controller: _pdfController!,
          onDocumentLoaded: (document) {
            setState(() {
              _allPagesCount = document.pagesCount;
            });
          },
          onPageChanged: (page) {
            setState(() {
              _actualPageNumber = page;
            });
          },
        ));
  }
}
