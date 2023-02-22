import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_social_keyboard/models/keyboard_config.dart';
import 'package:flutter_social_keyboard/models/recent_sticker.dart';
import 'package:flutter_social_keyboard/models/sticker.dart';
import 'package:flutter_social_keyboard/models/category_sticker.dart';
import 'package:flutter_social_keyboard/utils/sticker_picker_internal_utils.dart';

extension ImageTool on ImageProvider {
  Future<Uint8List?> getBytes(BuildContext context, {ImageByteFormat format = ImageByteFormat.rawRgba}) async {
    final imageStream = resolve(createLocalImageConfiguration(context));
    final Completer<Uint8List?> completer = Completer<Uint8List?>();
    final ImageStreamListener listener = ImageStreamListener(
          (imageInfo, synchronousCall) async {
        final bytes = await imageInfo.image.toByteData(format: format);
        if (!completer.isCompleted) {
          completer.complete(bytes?.buffer.asUint8List());
        }
      },
    );
    imageStream.addListener(listener);
    final imageBytes = await completer.future;
    imageStream.removeListener(listener);
    return imageBytes;
  }
}

class StickerDisplay extends StatefulWidget {
  final CategorySticker stickerModel;
  final KeyboardConfig keyboardConfig;
  final Function(Sticker)? onStickerSelected;
  final StreamController<String> scrollStream;
  final Function(List<RecentSticker>, bool) onUpdateRecent;
  const StickerDisplay({
    Key? key,
    required this.stickerModel,
    required this.keyboardConfig,
    this.onStickerSelected,
    required this.scrollStream,
    required this.onUpdateRecent,
  }) : super(key: key);

  @override
  State<StickerDisplay> createState() => _StickerDisplayState();
}

class _StickerDisplayState extends State<StickerDisplay> {
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.addListener(() {
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          // print("Show Keyboard");
          widget.scrollStream.add("showNav");
        } else if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          // print("Hide Keyboard");
          widget.scrollStream.add("hideNav");
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return widget.stickerModel.stickers.isEmpty
        ? const Center(
            child: Text(
              "There was an error, try again!",
            ),
          )
        : GridView.builder(
            itemCount: widget.stickerModel.stickers.length,
            scrollDirection: Axis.vertical,
            controller: _scrollController,
            padding: widget.keyboardConfig.gridPadding,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.keyboardConfig.stickerColumns,
              crossAxisSpacing: widget.keyboardConfig.stickerHorizontalSpacing,
              mainAxisSpacing: widget.keyboardConfig.stickerVerticalSpacing,
            ),
            itemBuilder: (context, index) {

              return GestureDetector(
                onTap: () {
                  if (widget.keyboardConfig.showRecentsTab) {
                    StickerPickerInternalUtils()
                        .addStickerToRecentlyUsed(
                            sticker: widget.stickerModel.stickers[index],
                            config: widget.keyboardConfig)
                        .then((newRecentEmoji) => {
                              // we don't want to rebuild the widget if user is currently on
                              // the RECENT tab, it will make emojis jump since sorting
                              // is based on the use frequency
                              widget.onUpdateRecent(
                                  newRecentEmoji,
                                  widget.stickerModel.stickers[index]
                                          .category !=
                                      "Recents")
                            });
                  }
                  if (widget.onStickerSelected != null) {
                    widget.onStickerSelected!(
                        widget.stickerModel.stickers[index]);
                  }
                },
                // child: CachedNetworkImage(
                //   imageUrl: widget.stickerModel.stickers[index].assetUrl,
                //   placeholder: (context, url) =>
                //   const CircularProgressIndicator.adaptive(),
                //   errorWidget: (context, url, error) =>
                //   const Icon(Icons.error),
                //   fit: BoxFit.cover,
                // ),
                child: CachedNetworkImage(
                  imageUrl: widget.stickerModel.stickers[index].assetUrl,
                  imageBuilder: (context, imageProvider) {
                    final format = widget.stickerModel.stickers[index].assetUrl.toLowerCase().contains('png') ? ImageByteFormat.png : ImageByteFormat.rawRgba;
                    imageProvider.resolve(const ImageConfiguration())
                        .addListener(
                      ImageStreamListener(
                            (info, _) async {
                              final _image = info.image;
                              widget.stickerModel.stickers[index].width = _image.width;
                              widget.stickerModel.stickers[index].height = _image.height;
                            },
                    ),);
                    imageProvider.getBytes(context, format: format).then((imageBytes) {
                      if (imageBytes != null && imageBytes.isNotEmpty) {
                        // DO WHAT YOU WANT WITH YOUR BYTES
                        widget.stickerModel.stickers[index].size = imageBytes.length;
                      }
                    });
                    return Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                          ),
                        )
                    );
                  },
                  placeholder: (context, url) => const CircularProgressIndicator.adaptive(),
                  errorWidget: (context, url, dynamic error) => const Icon(Icons.error_outline),
                )



                // Image.asset(
                //   widget.stickerModel.stickers[index].assetUrl,
                //   errorBuilder: ((context, error, stackTrace) =>
                //       const Icon(Icons.error)),
                //   fit: BoxFit.cover,
                // ),
              );
            },
          );
  }
}
