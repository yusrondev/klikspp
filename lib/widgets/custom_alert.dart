import 'package:flutter/material.dart';

void showCustomToast({
  required BuildContext context,
  required String message,
  String? secondaryMessage,
  required ToastType type,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder:
        (context) => Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: DynamicIslandToast(
                message: message,
                secondaryMessage: secondaryMessage,
                type: type,
                duration: duration,
              ),
            ),
          ),
        ),
  );

  overlay.insert(overlayEntry);
  Future.delayed(duration, () => overlayEntry.remove());
}

class DynamicIslandToast extends StatefulWidget {
  final String message;
  final String? secondaryMessage;
  final ToastType type;
  final Duration duration;

  const DynamicIslandToast({
    required this.message,
    this.secondaryMessage,
    required this.type,
    required this.duration,
    Key? key,
  }) : super(key: key);

  @override
  _DynamicIslandToastState createState() => _DynamicIslandToastState();
}

class _DynamicIslandToastState extends State<DynamicIslandToast> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _expanded = true);
    });

    // auto collapse
    Future.delayed(widget.duration - const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _expanded = false);
    });
  }

  double _calculateTextWidth(
    BuildContext context,
    String text,
    TextStyle style,
  ) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }

  @override
  Widget build(BuildContext context) {
    final toastStyle = _getToastStyle(widget.type);
    // Hitung width dari primary + secondary message
    final double textWidth =
        _calculateTextWidth(
          context,
          widget.message,
          const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ) +
        (widget.secondaryMessage != null
            ? _calculateTextWidth(
              context,
              widget.secondaryMessage!,
              const TextStyle(fontSize: 12),
            )
            : 0);

    final double iconWidth = 20 + 8; // icon + spacing
    final double horizontalPadding = _expanded ? 32 : 0; // left+right
    final double targetWidth =
        _expanded ? textWidth + iconWidth + horizontalPadding : 120;

    return AnimatedOpacity(
      opacity: _expanded ? 1 : 0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: AnimatedScale(
        scale: _expanded ? 1 : 0.9,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
          width: targetWidth.clamp(
            300,
            MediaQuery.of(context).size.width * 0.9,
          ),
          height: _expanded ? 40 : 30,
          padding:
              _expanded
                  ? const EdgeInsets.symmetric(horizontal: 16)
                  : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child:
              _expanded
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        toastStyle.icon,
                        color: toastStyle.iconColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.message,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.secondaryMessage != null)
                              Text(
                                widget.secondaryMessage!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  )
                  : null,
        ),
      ),
    );
  }

  ToastStyle _getToastStyle(ToastType type) {
    switch (type) {
      case ToastType.success:
        return ToastStyle(
          icon: Icons.check_circle_rounded,
          iconColor: Colors.greenAccent,
        );
      case ToastType.info:
        return ToastStyle(
          icon: Icons.info_rounded,
          iconColor: Colors.blueAccent,
        );
      case ToastType.warning:
        return ToastStyle(
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.orangeAccent,
        );
      case ToastType.error:
        return ToastStyle(
          icon: Icons.error_rounded,
          iconColor: Colors.redAccent,
        );
    }
  }
}

class ToastStyle {
  final IconData icon;
  final Color iconColor;

  ToastStyle({required this.icon, required this.iconColor});
}

enum ToastType { success, info, warning, error }
