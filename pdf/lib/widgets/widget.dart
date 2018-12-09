/*
 * Copyright (C) 2017, David PHAM-VAN <dev.nfet.net@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General  License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

part of widget;

class Context {
  final PdfPage page;
  final PdfGraphics canvas;
  final Matrix4 matrix;

  const Context(this.page, this.canvas, this.matrix);

  Context copyWith({Matrix4 matrix}) {
    return Context(this.page, this.canvas, matrix ?? this.matrix);
  }

  Context transform(Matrix4 matrix) {
    canvas
      ..saveContext()
      ..setTransform(matrix);

    return copyWith(matrix: this.matrix.multiplied(matrix));
  }
}

abstract class Widget {
  PdfPoint size;

  Widget();

  @protected
  void layout(BoxConstraints constraints, {parentUsesSize = false});

  @protected
  void paint(Context context) {
    assert(() {
      if (Document.debug) debugPaint(context);
      return true;
    }());
  }

  @protected
  void debugPaint(Context context) {
    print("debugPaint ${this.runtimeType} 0, 0, $size");
    context.canvas
      ..setColor(PdfColor.purple)
      ..drawRect(0, 0, size.x, size.y)
      ..strokePath();
  }
}

abstract class StatelessWidget extends Widget {
  Widget _widget;

  Widget get child {
    if (_widget == null) _widget = build();
    return _widget;
  }

  StatelessWidget() : super();

  @override
  void layout(BoxConstraints constraints, {parentUsesSize = false}) {
    if (child != null) {
      child.layout(constraints, parentUsesSize: parentUsesSize);
      size = child.size;
    } else {
      size = PdfPoint.zero;
    }
  }

  @override
  void paint(Context context) {
    super.paint(context);

    if (child != null) {
      child.paint(context);
    }
  }

  @protected
  Widget build();
}

abstract class SingleChildWidget extends Widget {
  SingleChildWidget({this.child}) : super();

  final Widget child;

  @override
  void paint(Context context) {
    super.paint(context);

    if (child != null) {
      final mat = Matrix4.identity();
      mat.translate(0.0, size.y - child.size.y);
      final newContext = context.transform(mat);
      child.paint(newContext);
      context.canvas.restoreContext();
    }
  }
}

abstract class MultiChildWidget extends Widget {
  MultiChildWidget({this.children = const <Widget>[]}) : super();

  final List<Widget> children;
}

class LimitedBox extends SingleChildWidget {
  LimitedBox({
    this.maxWidth = double.infinity,
    this.maxHeight = double.infinity,
    Widget child,
  })  : assert(maxWidth != null && maxWidth >= 0.0),
        assert(maxHeight != null && maxHeight >= 0.0),
        super(child: child);

  final double maxWidth;

  final double maxHeight;

  BoxConstraints _limitConstraints(BoxConstraints constraints) {
    return BoxConstraints(
        minWidth: constraints.minWidth,
        maxWidth: constraints.hasBoundedWidth
            ? constraints.maxWidth
            : constraints.constrainWidth(maxWidth),
        minHeight: constraints.minHeight,
        maxHeight: constraints.hasBoundedHeight
            ? constraints.maxHeight
            : constraints.constrainHeight(maxHeight));
  }

  @override
  void layout(BoxConstraints constraints, {parentUsesSize = false}) {
    if (child != null) {
      child.layout(_limitConstraints(constraints), parentUsesSize: true);
      size = constraints.constrain(child.size);
    } else {
      size = _limitConstraints(constraints).constrain(PdfPoint(0.0, 0.0));
    }

    return null;
  }
}
