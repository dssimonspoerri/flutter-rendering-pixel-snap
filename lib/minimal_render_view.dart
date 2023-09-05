import 'dart:ui' as ui;

import 'package:pixel_snapping/images/test_image_v2.dart';
import 'package:pixel_snapping/sandbox/stubs/simple_none_view.dart'
    if (dart.library.html) 'package:pixel_snapping/sandbox/simple_html_view.dart';
import 'package:flutter/material.dart';

/// A [MinimalRenderView] is a very minimal render view which displays
/// video or an image.
class MinimalRenderView extends StatefulWidget {
  /// Creates an instance of [MinimalRenderView].
  const MinimalRenderView({
    required this.showImageValueNotifier,
    Key? key,
  }) : super(key: key);

  /// If it should show the image or the video
  final ValueNotifier<bool> showImageValueNotifier;

  @override
  State<MinimalRenderView> createState() =>
      MinimalRenderViewState(showImageValueNotifier);
}

/// State for a [MinimalRenderView] widget.
class MinimalRenderViewState extends State<MinimalRenderView> {
  /// Creates an instance of [MinimalRenderViewState].
  MinimalRenderViewState(this._showImageValueNotifier);

  // Holds the last decoded image of the renderView
  // Setting this to null causes flickering.
  ui.Image? _screenshotImage;

  /// If it should show the image or the video
  final ValueNotifier<bool> _showImageValueNotifier;
  _ShowImgVideoState _showImage = _ShowImgVideoState.showVideo;

  @override
  void initState() {
    super.initState();
    TestImageV2.loadImage().then((ui.Image image) {
      setState(() => _screenshotImage = image);
    });
    _showImageValueNotifier.addListener(() => setState(() {
          if (_showImageValueNotifier.value) {
            _showImage = _ShowImgVideoState.showImage;
          } else {
            _showImage = _ShowImgVideoState.TransitionImageToVideo;
            Future.delayed(
                const Duration(milliseconds: 100),
                () => setState(() {
                      _showImage = _ShowImgVideoState.showVideo;
                    }));
          }
        }));
  }

  @override
  void dispose() {
    super.dispose();
    _screenshotImage?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget screenshotWidget = RawImage(
      image: _screenshotImage,
      width: 640,
      height: 386,
      fit: BoxFit.contain,
      alignment: Alignment.topLeft,
      isAntiAlias: true,
      filterQuality: FilterQuality.none,
    );

    // minimal widget to show video as an HTML video element
    const videoWidget = HtmlVideoView(
        videoUrl:
            'https://storage.googleapis.com/render-instance-testdata/demo_blur_video.mp4');

    final children = <Widget>[];
    if (_showImage == _ShowImgVideoState.showImage ||
        _showImage == _ShowImgVideoState.TransitionImageToVideo) {
      children.add(screenshotWidget);
    }
    if (_showImage == _ShowImgVideoState.showVideo ||
        _showImage == _ShowImgVideoState.TransitionImageToVideo) {
      children.add(videoWidget);
    }

    return Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
            constraints: BoxConstraints.tight(const Size(640, 386)),
            child: Stack(
                fit: StackFit.passthrough,
                alignment: Alignment.topLeft,
                children: children)));
  }
}

enum _ShowImgVideoState { showVideo, showImage, TransitionImageToVideo }