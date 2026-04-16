import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';

class CurationDetailPage extends StatefulWidget {
  const CurationDetailPage({super.key, required this.title});

  final String title;

  @override
  State<CurationDetailPage> createState() => _CurationDetailPageState();
}

class _CurationDetailPageState extends State<CurationDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: widget.title.isEmpty ? context.l10n.curationTitle : widget.title,
      ),
    );
  }
}
