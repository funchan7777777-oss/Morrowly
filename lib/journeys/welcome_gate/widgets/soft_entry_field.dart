import 'package:flutter/material.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/welcome_artwork.dart';

class SoftEntryField extends StatelessWidget {
  const SoftEntryField({
    super.key,
    required this.label,
    required this.placeholder,
    this.controller,
    this.onChanged,
    this.trailingKind = FieldTrailingKind.none,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.height,
  });

  final String label;
  final String placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FieldTrailingKind trailingKind;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 7),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.26),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Stack(
          children: [
            Container(
              height: height ?? 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(maxLines > 1 ? 18 : 28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                maxLines: maxLines,
                keyboardType: keyboardType,
                textInputAction: textInputAction,
                textCapitalization: textCapitalization,
                obscureText: trailingKind == FieldTrailingKind.eye,
                style: const TextStyle(
                  color: Color(0xFF4D3F55),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.fromLTRB(
                    20,
                    maxLines > 1 ? 16 : 18,
                    trailingKind == FieldTrailingKind.none ? 20 : 54,
                    14,
                  ),
                  hintText: placeholder,
                  hintStyle: const TextStyle(
                    color: Color(0xFFD7CEDB),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (trailingKind != FieldTrailingKind.none)
              Positioned(
                right: 18,
                top: maxLines > 1 ? 17 : ((height ?? 54) - 22) / 2,
                child: IgnorePointer(child: _TrailingGlyph(kind: trailingKind)),
              ),
          ],
        ),
      ],
    );
  }
}

enum FieldTrailingKind { none, clear, eye, chevron }

class _TrailingGlyph extends StatelessWidget {
  const _TrailingGlyph({required this.kind});

  final FieldTrailingKind kind;

  @override
  Widget build(BuildContext context) {
    return switch (kind) {
      FieldTrailingKind.none => const SizedBox.shrink(),
      FieldTrailingKind.clear => Image.asset(
        WelcomeArtwork.fieldClear,
        width: 18,
        height: 18,
        filterQuality: FilterQuality.high,
      ),
      FieldTrailingKind.eye => Image.asset(
        WelcomeArtwork.eyeOpen,
        width: 22,
        height: 22,
        filterQuality: FilterQuality.high,
      ),
      FieldTrailingKind.chevron => const Icon(
        Icons.chevron_right,
        color: Color(0xFFD0C7D4),
        size: 24,
      ),
    };
  }
}
