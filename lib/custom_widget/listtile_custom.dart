import 'package:flutter/material.dart';

class ListTileCustom extends StatelessWidget {
  final String? textTitle;
  final String? textSubTitle;
  final Widget? iconTopTrailing;
  final VoidCallback? functionTopTrailingIcon;
  final Widget? iconBottomTrailing;
  final VoidCallback? functionBottomTrailingIcon;
  final VoidCallback? onTap;

  ListTileCustom({this.textTitle, this.textSubTitle, this.iconTopTrailing, this.functionTopTrailingIcon, this.iconBottomTrailing,
      this.functionBottomTrailingIcon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: Colors.grey[200],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(textTitle ?? "", style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(textSubTitle ?? ""),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if(iconTopTrailing != null)
                  IconButton(
                    onPressed: functionTopTrailingIcon,
                    icon: iconTopTrailing ?? const Icon(null),
                    style: const ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),

                  if(iconBottomTrailing != null)
                  IconButton(
                    onPressed: functionBottomTrailingIcon,
                    icon: iconBottomTrailing ?? const Icon(null),
                    style: const ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Tạo thu gọn cho IconButton
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
