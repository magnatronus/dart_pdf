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

enum Axis {
  horizontal,
  vertical,
}

class Flex extends MultiChildWidget {
  Flex({
    @required this.direction,
    // this.mainAxisAlignment = MainAxisAlignment.start,
    // this.mainAxisSize = MainAxisSize.max,
    // this.crossAxisAlignment = CrossAxisAlignment.center,
    // this.textDirection,
    // this.verticalDirection = VerticalDirection.down,
    // this.textBaseline,
    List<Widget> children = const <Widget>[],
  })  : assert(direction != null),
        // assert(mainAxisAlignment != null),
        // assert(mainAxisSize != null),
        // assert(crossAxisAlignment != null),
        // assert(verticalDirection != null),
        // assert(crossAxisAlignment != CrossAxisAlignment.baseline || textBaseline != null),
        super(children: children);

  final Axis direction;

  // final MainAxisAlignment mainAxisAlignment;

  // final MainAxisSize mainAxisSize;

  // final CrossAxisAlignment crossAxisAlignment;

  // final VerticalDirection verticalDirection;

  @override
  void layout(BoxConstraints constraints, {parentUsesSize = false}) {
    final double maxMainSize = direction == Axis.horizontal
        ? constraints.maxWidth
        : constraints.maxHeight;
    final bool canFlex = maxMainSize < double.infinity;

    for (var child in children) {
      var childConstraints;
      if (direction == Axis.horizontal) {
        childConstraints = BoxConstraints(
            maxWidth: constraints.maxWidth / children.length,
            maxHeight: constraints.maxHeight);
      } else {
        childConstraints = BoxConstraints(
            maxWidth: constraints.maxWidth,
            maxHeight: constraints.maxHeight / children.length);
      }
      child.layout(childConstraints);
    }
    size = PdfPoint(constraints.maxWidth, constraints.maxHeight);
  }

  @override
  void paint(Context context) {
    super.paint(context);

    var pos = size.y;
    for (var child in children) {
      final mat = Matrix4.identity();
      mat.translate(0.0, pos - child.size.y);
      final newContext = context.transform(mat);
      child.paint(newContext);
      context.canvas.restoreContext();
      pos -= child.size.y;
    }
  }
}
