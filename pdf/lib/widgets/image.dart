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

class Image extends Widget {
  final PdfImage image;
  final double aspectRatio;

  Image(this.image)
      : aspectRatio = (image.height.toDouble() / image.width.toDouble());

  @override
  void layout(BoxConstraints constraints, {parentUsesSize = false}) {
    final w = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : constraints.constrainWidth(image.width.toDouble());
    final h = constraints.hasBoundedHeight
        ? constraints.maxHeight
        : constraints.constrainHeight(image.height.toDouble());

    if (aspectRatio >= 1.0) {
      size = PdfPoint(h / aspectRatio, h);
    } else {
      size = PdfPoint(w, w / aspectRatio);
    }
  }

  @override
  void paint(Context context) {
    super.paint(context);

    context.canvas.drawImage(image, 0.0, 0.0, size.x, size.y);
  }
}

class Shape extends Widget {
  final String shape;
  final PdfColor strokeColor;
  final PdfColor fillColor;
  final double width;
  final double height;
  final double aspectRatio;

  Shape(this.shape,
      {this.strokeColor, this.fillColor, this.width = 1.0, this.height = 1.0})
      : assert(width != null && width > 0.0),
        assert(height != null && height > 0.0),
        aspectRatio = height / width;

  @override
  void layout(BoxConstraints constraints, {parentUsesSize = false}) {
    final w = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : constraints.constrainWidth(width);
    final h = constraints.hasBoundedHeight
        ? constraints.maxHeight
        : constraints.constrainHeight(height);

    if (aspectRatio >= 1.0) {
      size = PdfPoint(h / aspectRatio, h);
    } else {
      size = PdfPoint(w, w / aspectRatio);
    }
  }

  @override
  void paint(Context context) {
    super.paint(context);

    final mat = Matrix4.identity();
    mat.translate(0.0, size.y);
    mat.scale(size.x / width, -size.y / height);
    context.canvas
      ..saveContext()
      ..setTransform(mat);

    if (fillColor != null) {
      context.canvas
        ..setColor(fillColor)
        ..drawShape(shape, stroke: false)
        ..fillPath();
    }

    if (strokeColor != null) {
      context.canvas
        ..setColor(strokeColor)
        ..drawShape(shape, stroke: true);
    }

    context.canvas.restoreContext();
  }
}
