import 'package:flutter/material.dart';

///
///  extended_image_gesture_utils.dart
///  create by zmtzawqlp on 2019/4/3
///

///gesture

///whether gesture rect is out size
bool outRect(Rect rect, Rect destinationRect) {
  return destinationRect.top < rect.top ||
      destinationRect.left < rect.left ||
      destinationRect.right > rect.right ||
      destinationRect.bottom > rect.bottom;
}

class Boundary {
  bool left;
  bool right;
  bool bottom;
  bool top;
  Boundary(
      {this.left: false,
      this.right: false,
      this.top: false,
      this.bottom: false});

  @override
  String toString() {
    // TODO: implement toString
    return "left:$left,right:$right,top:$top,bottom:$bottom";
  }
}

enum InPageView {
  ///image is not in pageview
  none,

  ///image is in horizontal pageview
  horizontal,

  ///image is in vertical pageview
  vertical
}

abstract class ExtendedImageGestureState {
  GestureDetails get gestureDetails;
  set gestureDetails(GestureDetails value);
}

class GestureDetails {
  ///scale center delta
  Offset offset;

  final double scale;

//  final PageView pageView;
//  ///layout rect

//
//  ///raw rect for image.
//  Rect destinationRect;

  bool _computeHorizontalBoundary = false;
  bool _computeVerticalBoundary = false;
  bool get computeVerticalBoundary => _computeVerticalBoundary;
  bool get computeHorizontalBoundary => _computeHorizontalBoundary;

  Offset _center;

  Boundary _boundary = Boundary();
  Boundary get boundary => _boundary;

//  bool get reachHorizontalBoundary {
//    if (delta != null && delta.dx != 0.0) {
//      return (delta.dx < 0 && boundary == Boundary.Right) ||
//          (delta.dx > 0 && boundary == Boundary.Left);
//    }
//    return false;
//  }
  Rect _rect;
  bool _zooming = false;

  GestureDetails({this.offset, this.scale, GestureDetails gestureDetails}) {
    if (gestureDetails != null) {
      _computeVerticalBoundary = gestureDetails._computeVerticalBoundary;
      _computeHorizontalBoundary = gestureDetails._computeHorizontalBoundary;
      _center = gestureDetails._center;
      //boundary = gestureDetails.boundary;
      _zooming = scale != gestureDetails.scale;
      _rect = gestureDetails._rect;

      if (!_zooming && scale > 1.0) {
        if (!computeHorizontalBoundary) {
          offset = Offset(gestureDetails.offset.dx, offset.dy);
        }

        if (!computeVerticalBoundary) {
          offset = Offset(offset.dx, gestureDetails.offset.dy);
        }
      }

      //print("$offset----$scale");
    }
  }

  Offset _getCenter(Rect destinationRect) {
    //return destinationRect.center * scale + offset;
    if (scale > 1.0) {
      if (_computeHorizontalBoundary && _computeVerticalBoundary) {
        return destinationRect.center * scale + offset;
      } else if (_computeHorizontalBoundary) {
        //only scale Horizontal
        return Offset(
                destinationRect.center.dx * scale, destinationRect.center.dy) +
            Offset(offset.dx, 0.0);
      } else if (_computeVerticalBoundary) {
        //only scale Vertical
        return Offset(
                destinationRect.center.dx, destinationRect.center.dy * scale) +
            Offset(0.0, offset.dy);
      } else {
        return destinationRect.center;
      }
    } else {
      return destinationRect.center;
    }
  }

  Rect _getDestinationRect(Rect destinationRect, Offset center) {
    final double width = destinationRect.width * scale;
    final double height = destinationRect.height * scale;

    return Rect.fromLTWH(
        center.dx - width / 2.0, center.dy - height / 2.0, width, height);
  }

  Rect calculateFinalDestinationRect(Rect layoutRect, Rect destinationRect) {
    Offset center = _getCenter(destinationRect);

    ///if (_zooming && _center != null) {}
//    Offset delta = Offset.zero;
//
//    if (this._center != null) {
//      delta = center - this._center;
//    }

//    if ((!_computeHorizontalBoundary || !_computeVerticalBoundary) &&
//        _center != null) {
//      center = _center;
//    }

//    if (_center != null) {
//      print("$_center----$center");
////      if (!_computeVerticalBoundary) {
////        center = Offset(center.dx, _center.dy);
////      }
////
////      if (!_computeHorizontalBoundary) {
////        center = Offset(_center.dx, center.dy);
////      }
//    }

    Rect result = _getDestinationRect(destinationRect, center);

    if (_computeHorizontalBoundary) {
      //move right
      if (result.left >= layoutRect.left) {
        result = Rect.fromLTWH(0.0, result.top, result.width, result.height);

        offset = result.center - destinationRect.center * scale;
        _boundary.left = true;
      }

      ///move left
      if (result.right <= layoutRect.right) {
        result = Rect.fromLTWH(layoutRect.right - result.width, result.top,
            result.width, result.height);

        offset = result.center - destinationRect.center * scale;
        _boundary.right = true;
      }
    }

    if (_computeVerticalBoundary) {
      //move down
      if (result.bottom <= layoutRect.bottom) {
        result = Rect.fromLTWH(result.left, layoutRect.bottom - result.height,
            result.width, result.height);

        offset = result.center - destinationRect.center * scale;
        _boundary.bottom = true;
      }

      //move up
      if (result.top >= layoutRect.top) {
        result = Rect.fromLTWH(
            result.left, layoutRect.top, result.width, result.height);

        offset = result.center - destinationRect.center * scale;
        _boundary.top = true;
      }
    }

    _computeHorizontalBoundary =
        result.left <= layoutRect.left && result.right >= layoutRect.right;

    _computeVerticalBoundary =
        result.top <= layoutRect.top && result.bottom >= layoutRect.bottom;

    //print("$_computeHorizontalBoundary");
    //print(boundary);
    this._center = _getCenter(destinationRect);
    _rect = result;
    return result;
  }
}

class ImageGestureConfig {
  final double minScale;
  final double maxScale;
  final double speed;
  final bool cacheGesture;
  final InPageView inPageView;
  ImageGestureConfig(
      {this.minScale: 0.8,
      this.maxScale: 5.0,
      this.speed: 1.0,
      this.cacheGesture: false,
      this.inPageView: InPageView.none});
}

///gesture