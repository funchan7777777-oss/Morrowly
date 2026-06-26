import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:morrowly/journeys/welcome_gate/models/legal_document_marker.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LegalDocumentViewer extends StatefulWidget {
  const LegalDocumentViewer({super.key, required this.document});

  final LegalDocumentMarker document;

  @override
  State<LegalDocumentViewer> createState() => _LegalDocumentViewerState();
}

class _LegalDocumentViewerState extends State<LegalDocumentViewer> {
  late final WebViewController _controller;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) {
              setState(() => _loadingProgress = progress);
            }
          },
        ),
      )
      ..loadRequest(widget.document.uri);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: const Color(0xFF2B2225),
        body: Stack(
          children: [
            Positioned.fill(child: WebViewWidget(controller: _controller)),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _LegalViewerChrome(
                title: widget.document.title,
                progress: _loadingProgress,
                onBack: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalViewerChrome extends StatelessWidget {
  const _LegalViewerChrome({
    required this.title,
    required this.progress,
    required this.onBack,
  });

  final String title;
  final int progress;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF6E3A8B).withValues(alpha: 0.96),
            const Color(0xFF3A263F).withValues(alpha: 0.92),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          10,
          MorrowlyFrameGuard.topClearance(context, minimum: 48, extra: 8),
          16,
          12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 30,
                  ),
                  splashRadius: 22,
                ),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 3,
                value: progress >= 100 ? 0 : progress / 100,
                backgroundColor: Colors.white.withValues(alpha: 0.16),
                valueColor: const AlwaysStoppedAnimation(Color(0xFFFF49D8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
