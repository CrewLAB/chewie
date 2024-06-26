import 'dart:math' as math;

import 'package:chewie/src/chewie_player.dart';
import 'package:chewie/src/helpers/adaptive_controls.dart';
import 'package:chewie/src/notifiers/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class PlayerWithControls extends StatelessWidget {
  const PlayerWithControls({super.key});

  @override
  Widget build(BuildContext context) {
    final ChewieController chewieController = ChewieController.of(context);

    Widget buildControls(BuildContext context, ChewieController chewieController) {
      return chewieController.showControls
          ? chewieController.customControls ?? const AdaptiveControls()
          : const SizedBox.shrink();
    }

    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return Center(
        child: Stack(
          children: <Widget>[
            if (chewieController.placeholder != null) chewieController.placeholder!,
            InteractiveViewer(
              transformationController: chewieController.transformationController,
              maxScale: chewieController.maxScale,
              panEnabled: chewieController.zoomAndPan,
              scaleEnabled: chewieController.zoomAndPan,
              child: Center(
                child: AspectRatio(
                  aspectRatio: chewieController.aspectRatio ?? chewieController.videoPlayerController.value.aspectRatio,
                  child: Builder(
                    builder: (BuildContext context) {
                      final VideoPlayer player = VideoPlayer(chewieController.videoPlayerController);
                      final int rotationCorrection = chewieController.videoPlayerController.value.rotationCorrection;
                      if (rotationCorrection == 180) {
                        return Transform.rotate(
                          angle: rotationCorrection * math.pi / 180,
                          child: player,
                        );
                      }

                      return player;
                    },
                  ),
                ),
              ),
            ),
            if (chewieController.overlay != null) chewieController.overlay!,
            if (Theme.of(context).platform != TargetPlatform.iOS)
              Consumer<PlayerNotifier>(
                builder: (
                  BuildContext context,
                  PlayerNotifier notifier,
                  Widget? widget,
                ) =>
                    Visibility(
                  visible: !notifier.hideStuff,
                  child: AnimatedOpacity(
                    opacity: notifier.hideStuff ? 0.0 : 0.8,
                    duration: const Duration(milliseconds: 250),
                    child: const DecoratedBox(
                      decoration: BoxDecoration(color: Colors.black54),
                      child: SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            SafeArea(
              bottom: !chewieController.isFullScreen,
              child: buildControls(context, chewieController),
            ),
          ],
        ),
      );
    });
  }
}
