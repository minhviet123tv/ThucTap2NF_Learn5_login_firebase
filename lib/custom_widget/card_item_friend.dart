import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../home/profile_user/get_avatar_from_storage.dart';

class CardItemFriend extends StatelessWidget {
  final String? uidUser;
  final GestureTapCallback? onTapCard;
  final GestureTapCallback? onTapAvatar;
  final Widget? titleWidget;
  final Widget? subTitleWidget;
  final Widget? trailingIconTop;
  final GestureTapCallback? onTapTrailingIconTop;
  final Widget? trailingIconBottom;
  final GestureTapCallback? onTapTrailingIconBottom;
  final Color? backGroundCard;

  CardItemFriend(
      {super.key,
      this.uidUser,
      this.onTapCard,
      this.onTapAvatar,
      this.titleWidget,
      this.subTitleWidget,
      this.trailingIconTop,
      this.onTapTrailingIconTop,
      this.trailingIconBottom,
      this.onTapTrailingIconBottom,
      this.backGroundCard});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backGroundCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTapCard,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 18, top: 3, bottom: 3),
          child: Padding(
            padding: uidUser == null ? const EdgeInsets.all(10.0) : const EdgeInsets.all(0.0), // Nếu không có avatar -> tạo padding
            child: Row(
              children: [
                //1. avatar
                if(uidUser != null)
                InkWell(
                  onTap: onTapAvatar,
                  borderRadius: BorderRadius.circular(100),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ClipOval(
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: GetAvatarFromStorage(uid: uidUser!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                //2. Email và tin nhắn cuối
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleWidget ?? const SizedBox(),
                      subTitleWidget ?? const SizedBox(),
                    ],
                  ),
                ),

                //3. Số lượng tin nhắn mới chưa check và thời gian của tin nhắn cuối
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: onTapTrailingIconTop,
                      child: trailingIconTop ?? const SizedBox(),
                    ),
                    const SizedBox(height: 5),
                    InkWell(
                      onTap: onTapTrailingIconBottom,
                      child: trailingIconBottom ?? const SizedBox(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
