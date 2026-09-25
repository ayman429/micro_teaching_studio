// import 'package:easy_docs_viewer/easy_docs_viewer.dart';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_pptx/flutter_pptx.dart';
// import 'package:dart_pptx/dart_pptx.dart';

import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class ShowPdf extends StatelessWidget {
  const ShowPdf({super.key, required this.pdfLink, required this.name});
  final String pdfLink, name;
  @override
  Widget build(BuildContext context) {
    log("============pdfLink: $pdfLink");
    final GlobalKey<SfPdfViewerState> pdfViewerKey = GlobalKey();

    return Scaffold(
      appBar: AppBar(title: Text(name.tr()), centerTitle: true),
      body: SfPdfViewerTheme(
          data: const SfPdfViewerThemeData(
            backgroundColor: Colors.white,
          ),
          child: pdfLink != "" && pdfLink.isNotEmpty
              ? SfPdfViewer.network(
                  pdfLink,
                  // key: _pdfViewerKey,
                  canShowPaginationDialog: false,
                )
              : const Center(
                  child: Text("الملف غير صالح"),
                )
          // SfPdfViewer.asset(
          //     Assets.assetsPdfExam2,
          //     //pdfLink,
          //     key: pdfViewerKey,
          //     canShowPaginationDialog: false,
          //   ),
          //     EasyDocsViewer(
          //   url:
          //       "https://scholar.harvard.edu/files/torman_personal/files/samplepptx.pptx",
          // ),
          ),
    );
  }
}
