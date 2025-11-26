import 'package:flutter/material.dart';

enum FloatingMessagePosition { top, bottom }

class FloatingMessage {
  static void show(
      BuildContext context, {
        String? message,
        Color backgroundColor = Colors.black87,
        Duration duration = const Duration(seconds: 2),
        IconData? icon,
        bool textOnly = false, // 👈 opsi tambahan
        FloatingMessagePosition position = FloatingMessagePosition.bottom, // 👈 posisi default
      }) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        // 🧭 Posisi: atas atau bawah
        top: position == FloatingMessagePosition.top ? 180 : null,
        bottom: position == FloatingMessagePosition.bottom ? 80 : null,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 250),
            offset: const Offset(0, 0),
            child: Center(
              child: textOnly
              // 🟢 MODE TEXT ONLY
                  ? Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                color: Colors.transparent,
                child: Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
              // 🔵 MODE NORMAL (dengan background & shadow)
                  : Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: backgroundColor.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        message!,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // ⏳ Hapus otomatis setelah durasi tertentu
    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }
}
