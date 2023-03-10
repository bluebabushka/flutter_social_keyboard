import 'dart:async';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_social_keyboard/models/giphy_gif.dart';
import 'package:flutter_social_keyboard/models/keyboard_config.dart';
import 'package:flutter_social_keyboard/models/sticker.dart';
import 'package:flutter_social_keyboard/utils/giphy_gif_picker_utils.dart';
import 'package:flutter_social_keyboard/utils/sticker_picker_utils.dart';
import 'package:flutter_social_keyboard/widgets/emoji_picker_widget.dart';
import 'package:flutter_social_keyboard/widgets/search/emoji_search.dart';
import 'package:flutter_social_keyboard/widgets/gif_picker_widget.dart';
import 'package:flutter_social_keyboard/widgets/search/giphy_gif_search.dart';
import 'package:flutter_social_keyboard/widgets/search/sticker_search.dart';
import 'package:flutter_social_keyboard/widgets/sticker_picker_widget.dart';

//Bottom bar height, bg-color, icon-color, active-icon-color
//
class FlutterSocialKeyboard extends StatefulWidget {
  ///Optional keyboard configuration
  final KeyboardConfig keyboardConfig;

  /// Optional callback function for when emoji is pressed
  final void Function(Category?, Emoji)? onEmojiSelected;

  /// optional callback function for when BackSpace button is pressed
  final Function()? onBackspacePressed;

  /// optional callback function for when gif is pressed
  final Function(GiphyGif)? onGifSelected;

  /// optional callback function for when sticker is pressed
  final Function(Sticker)? onStickerSelected;

  const FlutterSocialKeyboard({
    Key? key,
    this.keyboardConfig = const KeyboardConfig(),
    this.onEmojiSelected,
    this.onGifSelected,
    this.onBackspacePressed,
    this.onStickerSelected,
  }) : super(key: key);

  @override
  State<FlutterSocialKeyboard> createState() => _FlutterSocialKeyboardState();
}

class _FlutterSocialKeyboardState extends State<FlutterSocialKeyboard> {
  final StreamController<String> scrollStream =
      StreamController<String>.broadcast();
  int _currentIndex = 0;
  bool _showBottomNav = true;

  final List<Widget> _showingWidgets = List.empty(growable: true);
  final List<String> _showingTabItems = List.empty(growable: true);

  final List<Emoji> _recentEmoji = List.empty(growable: true);
  final List<GiphyGif> _recentGif = List.empty(growable: true);
  final List<Sticker> _recentSticker = List.empty(growable: true);

  bool _isSearching = false;
  @override
  void initState() {
    super.initState();

    if (widget.keyboardConfig.useEmoji) {
      _showingWidgets.add(
          //Emoji
          EmojiPickerWidget(
        keyboardConfig: widget.keyboardConfig,
        onBackspacePressed: widget.onBackspacePressed,
        onEmojiSelected: widget.onEmojiSelected,
      ));
      _showingTabItems.add("emoji");
    }

    if (widget.keyboardConfig.useGif) {
      _showingWidgets.add(
        //Gif
        GifPickerWidget(
          keyboardConfig: widget.keyboardConfig,
          onGifSelected: widget.onGifSelected,
          scrollStream: scrollStream,
        ),
      );
      _showingTabItems.add("gif");
    }

    if (widget.keyboardConfig.useSticker) {
      _showingWidgets.add(
        //Sticker
        StickerPickerWidget(
          keyboardConfig: widget.keyboardConfig,
          onStickerSelected: widget.onStickerSelected,
          scrollStream: scrollStream,
        ),
      );
      _showingTabItems.add("sticker");
    }

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      scrollStream.stream.listen((event) {
        if (event == "hideNav") {
          if (_showBottomNav) {
            setState(() {
              _showBottomNav = false;
            });
          }
        } else {
          if (!_showBottomNav) {
            setState(() {
              _showBottomNav = true;
            });
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: widget.keyboardConfig.withSafeArea && _showBottomNav,
      top: widget.keyboardConfig.withSafeArea,
      left: widget.keyboardConfig.withSafeArea,
      right: widget.keyboardConfig.withSafeArea,
      child: _isSearching
          ? _showingTabItems[_currentIndex].contains("emoji")
              ? EmojiSearch(
                  emojiSize: 24,
                  recents: _recentEmoji,
                  keyboardConfig: widget.keyboardConfig,
                  onEmojiSelected: (Emoji emoji) {
                    widget.onEmojiSelected!(Category.RECENT, emoji);
                  },
                  onCloseSearch: () {
                    setState(() {
                      _isSearching = false;
                    });
                  },
                )
              : _showingTabItems[_currentIndex].contains("emoji")
                  ? EmojiSearch(
                      emojiSize: 24,
                      recents: _recentEmoji,
                      keyboardConfig: widget.keyboardConfig,
                      onEmojiSelected: (Emoji emoji) {
                        if (widget.onEmojiSelected != null) {
                          widget.onEmojiSelected!(Category.RECENT, emoji);
                        }
                      },
                      onCloseSearch: () {
                        setState(() {
                          _isSearching = false;
                        });
                      },
                    )
                  : _showingTabItems[_currentIndex].contains('sticker')
                      ? StickerSearch(
                          recents: _recentSticker,
                          keyboardConfig: widget.keyboardConfig,
                          onStickerSelected: (Sticker sticker) {
                            if (widget.onStickerSelected != null) {
                              widget.onStickerSelected!(sticker);
                            }
                          },
                          onCloseSearch: () {
                            setState(() {
                              _isSearching = false;
                            });
                          },
                        )
                      : GiphyGifSearch(
                          recents: _recentGif,
                          keyboardConfig: widget.keyboardConfig,
                          onGifSelected: (GiphyGif giphyGif) {
                            if (widget.onGifSelected != null) {
                              widget.onGifSelected!(giphyGif);
                            }
                          },
                          onCloseSearch: () {
                            setState(() {
                              _isSearching = false;
                            });
                          },
                        )
          : Column(
              children: [
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _showingWidgets,
                  ),
                ),
                //Bottom navigation
                Visibility(
                  visible: _showBottomNav,
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: widget.keyboardConfig.bgColor,
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(43, 52, 69, .1),
                          offset: Offset(0, -5),
                          spreadRadius: 10,
                          blurRadius: 200,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Opacity(
                            opacity:
                                widget.keyboardConfig.showSearchButton ? 1 : 0,
                            child: IconButton(
                              onPressed: () async {
                                if (!widget.keyboardConfig.showSearchButton) {
                                  return;
                                }

                                setState(() => _isSearching = true);

                                String tab = _showingTabItems[_currentIndex];
                                if (tab.contains('emoji')) {
                                  _recentEmoji.clear();
                                  _recentEmoji.addAll((await EmojiPickerUtils()
                                          .getRecentEmojis())
                                      .map((e) => e.emoji)
                                      .toList());
                                } else if (tab.contains('sticker')) {
                                  _recentSticker.clear();
                                  _recentSticker.addAll(
                                      (await StickerPickerUtils()
                                              .getRecentStickers())
                                          .map((e) => e.sticker)
                                          .toList());
                                } else {
                                  _recentGif.clear();
                                  _recentGif.addAll((await GiphyGifPickerUtils()
                                          .getRecentGiphyGif())
                                      .map((e) => e.gif)
                                      .toList());
                                }
                              },
                              icon: const Icon(
                                Icons.search,
                              ),
                            ),
                          ),
                          const Spacer(),
                          ..._showingTabItems
                              .map((e) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7.5),
                                    child: _getImgIcon(
                                      image: e,
                                      index: _showingTabItems.indexOf(e),
                                      size: e.contains("gif") ? 26 : 22,
                                    ),
                                  ))
                              .toList(),
                          const Spacer(),
                          Opacity(
                            opacity: widget.keyboardConfig.showBackSpace &&
                                    _showingTabItems[_currentIndex]
                                        .contains("emoji")
                                ? 1
                                : 0,
                            child: IconButton(
                              onPressed: () {
                                if (!_showingTabItems[_currentIndex]
                                        .contains("emoji") ||
                                    !widget.keyboardConfig.showBackSpace &&
                                        widget.onBackspacePressed == null) {
                                  return;
                                }
                                widget.onBackspacePressed!();
                              },
                              icon: const Icon(
                                Icons.backspace_outlined,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _getImgIcon({
    required String image,
    double size = 22,
    required int index,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Image.asset(
        "icons/$image.png",
        package: 'flutter_social_keyboard',
        width: size,
        height: size,
        color: _currentIndex == index
            ? widget.keyboardConfig.iconColorSelected
            : widget.keyboardConfig.iconColor,
      ),
    );
  }
}
