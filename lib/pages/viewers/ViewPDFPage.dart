import 'dart:io';

import 'package:flutter/material.dart';
import 'package:myapp/database/ItemModel.dart';

import '../../widgets/left_menu.dart';

import 'package:native_pdf_view/native_pdf_view.dart';
//import 'package:advance_pdf_viewer/src/page_picker.dart';

class ViewPDFPage extends StatefulWidget {
  const ViewPDFPage({
    Key? key,
  }) : super(key: key);

  @override
  State<ViewPDFPage> createState() => _ViewPDFPageState();
}

class _ViewPDFPageState extends State<ViewPDFPage> {
  static int _initialPage = 2;
  int _actualPageNumber = _initialPage, _allPagesCount = 0;
  PdfController? _pdfController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Item;
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
          documentLoader: const Center(child: CircularProgressIndicator()),
          pageLoader: const Center(child: CircularProgressIndicator()),
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
