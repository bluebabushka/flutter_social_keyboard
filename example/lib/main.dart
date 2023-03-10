import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social_keyboard/flutter_social_keyboard.dart';
import 'package:flutter_social_keyboard_example/stickers_categories.dart';

void main() {
  runApp(
    const MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  Emoji? selectedEmoji;
  GiphyGif? selectedGif;
  Sticker? selectedSticker;

  void _onEmojiSelected(Category? category, Emoji emoji) {
    // Do something when emoji is tapped (optional)
    // print(emoji);
    setState(() {
      selectedEmoji = emoji;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(child: _body());
  }

  Widget _body() {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Flutter Social Keyboard'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  selectedEmoji?.emoji ?? "NO emoji selected",
                  style: const TextStyle(
                    fontSize: 40,
                  ),
                ),
                //
                const SizedBox(
                  height: 10,
                ),
                selectedGif != null
                    ? CachedNetworkImage(
                        imageUrl: selectedGif!.images!.previewGif!.url!,
                        fit: BoxFit.fitHeight,
                        height: 150,
                        errorWidget: ((context, url, error) =>
                            Text(error.toString())),
                        placeholder: ((context, url) =>
                            const CircularProgressIndicator.adaptive()),
                      )
                    : const Text(
                        "NO GIF selected",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                //
                const SizedBox(
                  height: 10,
                ),

                selectedSticker != null
                    ? CachedNetworkImage(
                        imageUrl: selectedSticker!.assetUrl,
                        fit: BoxFit.fitHeight,
                        height: 150,
                        errorWidget: ((context, url, error) =>
                            Text(error.toString())),
                        placeholder: ((context, url) =>
                          const CircularProgressIndicator.adaptive()),
                    )
                    // ? Image.asset(
                    //     selectedSticker!.assetUrl,
                    //     height: 100,
                    //   )
                    : const Text(
                        "NO Sticker selected",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
              ],
            ),
          ),
          SizedBox(
            height: 280,
            child: FlutterSocialKeyboard(
              onEmojiSelected: _onEmojiSelected,
              onGifSelected: (GiphyGif gif) {
                // Do something when gif is tapped (optional)
                // print(gif);
                setState(() {
                  selectedGif = gif;
                });
              },
              onStickerSelected: (Sticker sticker) {
                // Do something when sticker is tapped (optional)
                // print(sticker.toJson());
                setState(() {
                  selectedSticker = sticker;
                });
              },
              onBackspacePressed: () {
                // Do something when the user taps the backspace button (optional)
                // print("Backspace button pressed");
              },
              keyboardConfig: KeyboardConfig(
                useEmoji: false,
                useGif: false,
                useSticker: true,
                giphyAPIKey: "",
                gifTabs: ["Hey", "One", 'Haha', 'Sad', 'Love', 'Reaction'],
                gifHorizontalSpacing: 5,
                gifVerticalSpacing: 5,
                gifColumns: 3,
                gifLang: GiphyLanguage.english,
                stickersSource: stickersSource,
                stickerColumns: 5,
                stickerHorizontalSpacing: 5,
                stickerVerticalSpacing: 5,
                withSafeArea: true,
                emojiColumns: 9,
                emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                emojiVerticalSpacing: 0,
                emojiHorizontalSpacing: 0,
                gridPadding: EdgeInsets.zero,
                initCategory: Category.RECENT,
                bgColor: const Color(0xFFF2F2F2),
                indicatorColor: Colors.blue,
                iconColor: Colors.grey,
                iconColorSelected: Colors.blue,
                progressIndicatorColor: Colors.blue,
                backspaceColor: Colors.blue,
                skinToneDialogBgColor: Colors.white,
                skinToneIndicatorColor: Colors.grey,
                enableSkinTones: true,
                showRecentsTab: true,
                recentsLimit: 28,
                noRecents: const Text(
                  'No Recents',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black26,
                  ),
                  textAlign: TextAlign.center,
                ),
                replaceRecentOnLimitExceed: true,
                tabIndicatorAnimDuration: kTabScrollDuration,
                categoryIcons: const CategoryIcons(),
                buttonMode: ButtonMode.CUPERTINO,
                showBackSpace: false,
                showSearchButton: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
