import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/shared/widgets/alert_badge.dart';
import 'package:arttrip/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';

class GenreDetailPage extends StatefulWidget {
  const GenreDetailPage({super.key, required this.genreName});

  final String genreName;

  @override
  State<GenreDetailPage> createState() => _GenreDetailPageState();
}

class _GenreDetailPageState extends State<GenreDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: context.l10n.genreDetailExhibition(widget.genreName),
        actions: const [AlertBadge()],
      ),
      body: Container(),
    );
  }
}
