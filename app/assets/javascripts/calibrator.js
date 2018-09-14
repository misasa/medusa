(function($) {
  var Calibrator = this.Calibrator = function(element) {
    var calibrator = Object.create(Calibrator.prototype), baseTriangle, overlayTriangle,
	baseImage, overlayImage, viewerBaseImage, viewerOverlayImage;

    calibrator.element = $(element);
    calibrator.viewer = Calibrator.Viewer(calibrator.element.find("div.viewer"));
    calibrator.base = Calibrator.Viewer(calibrator.element.find("div.base"));
    calibrator.overlay = Calibrator.Viewer(calibrator.element.find("div.overlay"));
    calibrator.thumbnails = Calibrator.Thumbnails(calibrator.element.find("div.thumbnails"));
    calibrator.opacity = calibrator.element.find("input.opacity");

    calibrator.viewer.addZoomControl().draggable();

    var overlayImagePath = calibrator.thumbnails.overlayImagePath(),
	resizeOverlay = function() {
	  var t1 = overlayTriangle.get(),
	      t2 = baseTriangle.get().map(function(x) { return x * viewerBaseImage.scale; })
	  viewerOverlayImage.transform(Matrix.fromTriangles(t1, t2));
	  $(calibrator).trigger('change');
	};

    overlayImage = calibrator.overlay.image(overlayImagePath);
    $(overlayImage).on('loaded', function(event, image) {
      image.fit();
      overlayTriangle = calibrator.overlayTriangle = Calibrator.Triangle(calibrator.overlay.svg, image.image);
      $(overlayTriangle).on('dragmove', resizeOverlay);
    });

    $(calibrator.thumbnails).on('selected', function(event, params) {
      var src = params.src, points = params.points;
      if (params.affine) {
        calibrator.baseAffine = params.affine;
      } else {
        calibrator.baseAffine = [1, 0, 0, 0, 1, 0];
      }
      if (baseImage) { baseImage.remove(); }
      baseImage = calibrator.base.image(src);
      $(baseImage).on('loaded', function(event, image) {
        calibrator.viewer.reset();
	image.fit();

	if (baseTriangle) { baseTriangle.remove(); }
	baseTriangle = calibrator.baseTriangle = Calibrator.Triangle(calibrator.base.svg, image.image);
        if (points) {
          baseTriangle.set(points);
        } else {
          baseTriangle.reset();
        }
	$(baseTriangle).on('dragmove', resizeOverlay);

	if(viewerBaseImage) { viewerBaseImage.remove(); }
	viewerBaseImage = calibrator.viewer.image(src);
	$(viewerBaseImage).on('loaded', function(event, image) {
	  image.fit();
	});

	if(viewerOverlayImage) { viewerOverlayImage.remove() }
	viewerOverlayImage = calibrator.viewer.image(overlayImagePath).opacity(calibrator.opacity.val());
	$(viewerOverlayImage).on('loaded', function(event, image) {
	  resizeOverlay();
	});
      });
    });

    $(calibrator.opacity).on('input', function(event) {
      viewerOverlayImage.opacity($(this).val());
    });

    return calibrator;
  };
  Calibrator.prototype = {
    affineMatrix() {
      var overlayCoord = this.overlayTriangle.coord(),
          baseCoord = this.baseTriangle.coord(),
          matrix = Matrix.from(
            this.baseAffine[0],
            this.baseAffine[3],
            this.baseAffine[1],
            this.baseAffine[4],
            this.baseAffine[2],
            this.baseAffine[5]
          ),
          transformedCoord = matrix.applyToArray(baseCoord);
      return Matrix.fromTriangles(overlayCoord, transformedCoord);
    }
  };

  Calibrator.Node = function(element) {
    var node = Object.create(Calibrator.Node.prototype);
    node.element = element;
    return node;
  };

  Calibrator.Image = function(svg, src) {
    var image = Object.create(Calibrator.Image.prototype);
    image.image = svg.image(src).loaded(function(loader) {
      image.width = loader.width;
      image.height = loader.height;
      var scale = 1;
      if (image.width > image.height) {
	scale = svg.width() / image.width;
      } else {
	scale = svg.height() / image.height;
      }
      image.scale = scale;
      $(image).trigger('loaded', image);
    });
    return image;
  };
  Calibrator.Image.prototype = {
    fit() {
      this.image.scale(this.scale, this.scale).translate(0, 0);
    },
    transform(matrix) {
      this.image.transform(matrix);
    },
    remove() {
      this.image.remove();
    },
    opacity(val) {
      this.image.attr({opacity: val });
      return this;
    }
  };

  Calibrator.Viewer = function(element) {
    var viewer = Object.create(Calibrator.Viewer.prototype),
	width = element.innerWidth(), height = element.innerHeight();
    Object.assign(viewer, Calibrator.Node(element));
    viewer.svg = SVG(viewer.element[0]).size(width, height);
    viewer.imageGroup = viewer.svg.group().size(width, height);
    viewer.controlGroup = viewer.svg.group().size(width, height);
    viewer.scale = 1;
    return viewer;
  };
  Calibrator.Viewer.prototype = {
    image(src) {
      return Calibrator.Image(this.imageGroup, src);
    },
    width() {
      return this.svg.width();
    },
    height() {
      return this.svg.height();
    },
    addZoomControl() {
      var viewer = this,
	  zoomIn = Calibrator.ZoomInButton(this.controlGroup),
	  zoomOut = Calibrator.ZoomOutButton(this.controlGroup);
      $(zoomIn).on('click', function() {
	viewer.zoomIn();
      });
      $(zoomOut).on('click', function() {
	viewer.zoomOut();
      });
      return this;
    },
    draggable() {
      this.imageGroup.draggable();
      return this;
    },
    zoomIn() {
      if (this.scale >= 8) { return; }
      this.scale++;
      this.imageGroup.scale(this.scale, this.scale);
    },
    zoomOut() {
      if (this.scale <= 1) { return; }
      this.scale--;
      this.imageGroup.scale(this.scale, this.scale);
    },
    reset() {
      this.scale = 1;
      this.imageGroup.scale(this.scale, this.scale);
      this.imageGroup.move(0, 0);
    }
  };

  Calibrator.Thumbnails = function(element) {
    var thumbnails = Object.create(Calibrator.Thumbnails.prototype);
    Object.assign(thumbnails, Calibrator.Node(element));
    thumbnails.element.on("click", function(event) {
      var div = $(event.target).parent();
      $(thumbnails).trigger('selected', { src: div.data("src"), points: div.data("points"), affine: div.data("affine") });
    });
    return thumbnails;
  };
  Calibrator.Thumbnails.prototype = {
    baseImagePath() {
      var div = this.element.find("div.thumbnail:first-child");
      return div.data("src");
    },
    overlayImagePath() {
      var div = this.element.find("div.thumbnail").filter(".hidden");
      return div.data("src");
    }
  };

  Calibrator.Triangle = function(svg, image) {
    var triangle = Object.create(Calibrator.Triangle.prototype);
    triangle.image = image;
    triangle.circles = [];
    triangle.lines = [];
    var image = image, transform = image.transform(), color = "#f00",
        width = image.width() * transform.scaleX, height = image.height() * transform.scaleY,
        x1 = 0, y1 = 0,
        x2 = width, y2 = 0,
        x3 = width, y3 = height,
        r = 10, d = r * 2,
        draggableOptions = { minX: -r, minY: -r, maxX: width + r, maxY: height + r },
	path = ["M", -r, 0, "H", r, "M", 0, -r, "V", r, "M", -r, 0, "A", r, r, 0, 1, 0, r, 0, "A", r, r, 0, 1, 0, -r, 0].join(" ");
    triangle.circles.push(svg.path(path).attr({'fill-opacity': 0}).stroke("#f00").move(x1 - r, y1 - r).draggable(draggableOptions));
    triangle.circles.push(svg.path(path).attr({'fill-opacity': 0}).stroke("#0f0").move(x2 - r, y2 - r).draggable(draggableOptions));
    triangle.circles.push(svg.path(path).attr({'fill-opacity': 0}).stroke("#00f").move(x3 - r, y3 - r).draggable(draggableOptions));
    triangle.lines.push(svg.line(x1, y1, x2, y2).stroke({ width: 1, color: color }));
    triangle.lines.push(svg.line(x2, y2, x3, y3).stroke({ width: 1, color: color }));
    triangle.lines.push(svg.line(x3, y3, x1, y1).stroke({ width: 1, color: color }));
    for (i = 0; i < triangle.circles.length; i++) {
      triangle.circles[i].on("dragmove", function(event) {
	var i = triangle.circles.findIndex(function(element) { return element.node === event.target }), j = (i + 1) % 3, k = (i + 2) % 3,
	    xi = triangle.circles[i].cx(), yi = triangle.circles[i].cy(),
	    xj = triangle.circles[j].cx(), yj = triangle.circles[j].cy(),
	    xk = triangle.circles[k].cx(), yk = triangle.circles[k].cy();
	triangle.lines[i].plot(xi, yi, xj, yj);
	triangle.lines[k].plot(xk, yk, xi, yi);
	$(triangle).trigger('dragmove');
      });
    }
    return triangle;
  };
  Calibrator.Triangle.prototype = {
    set(points) {
      var transform = this.image.transform(), scaleX = transform.scaleX, scaleY = transform.scaleY,
          x1 = points[0][0] * scaleX, y1 = points[0][1] * scaleY,
          x2 = points[1][0] * scaleX, y2 = points[1][1] * scaleY,
          x3 = points[2][0] * scaleX, y3 = points[2][1] * scaleY;
      this.circles[0].center(x1, y1);
      this.circles[1].center(x2, y2);
      this.circles[2].center(x3, y3);
      this.lines[0].plot(x1, y1, x2, y2);
      this.lines[1].plot(x2, y2, x3, y3);
      this.lines[2].plot(x3, y3, x1, y1);
    },
    reset() {
      var image = this.image, width = image.width(), height = image.height();
      this.set([
        [0, 0],
        [width, 0],
        [width, height]
      ]);
    },
    get() {
      var transform = this.image.transform(), scaleX = transform.scaleX, scaleY = transform.scaleY;
      return [
	this.circles[0].cx() / scaleX,
	this.circles[0].cy() / scaleY,
	this.circles[1].cx() / scaleX,
	this.circles[1].cy() / scaleY,
	this.circles[2].cx() / scaleX,
	this.circles[2].cy() / scaleY
      ];
    },
    remove() {
      for (i = 0; i < this.circles.length; i++) {
	this.circles[i].remove();
      }
      for (i = 0; i < this.lines.length; i++) {
	this.lines[i].remove();
      }
    },
    coord() {
      var transform = this.image.transform(), scaleX = transform.scaleX, scaleY = transform.scaleY,
          image = this.image, width = image.width(), height = image.height(),
          length = width > height ? width : height;
      return [
        (this.circles[0].cx() / scaleX - width / 2) * 100 / length,
        (height / 2 - this.circles[0].cy() / scaleY) * 100 / length,
        (this.circles[1].cx() / scaleX - width / 2) * 100 / length,
        (height / 2 - this.circles[1].cy() / scaleY) * 100 / length,
        (this.circles[2].cx() / scaleX - width / 2) * 100 / length,
        (height / 2 - this.circles[2].cy() / scaleY) * 100 / length
      ];
    }
  }

  Calibrator.ZoomInButton = function(svg) {
    var button = Object.create(Calibrator.ZoomInButton.prototype),
	trigger = function() { $(button).trigger('click'); };
    button.rect = svg.rect(30, 30).fill('#eff').move(10, 10);
    button.hLine = svg.line(15, 25, 35, 25, button.rect).stroke({ width: 1 });
    button.vLine = svg.line(25, 15, 25, 35, button.rect).stroke({ width: 1 });
    button.rect.on('click', trigger);
    button.hLine.on('click', trigger);
    button.vLine.on('click', trigger);
    return button;
  };

  Calibrator.ZoomOutButton = function(svg) {
    var button = Object.create(Calibrator.ZoomInButton.prototype),
	trigger = function() { $(button).trigger('click'); };
    button.rect = svg.rect(30, 30).fill('#eff').move(10, 50);
    button.hLine = svg.line(15, 65, 35, 65, button.rect).stroke({ width: 1 });
    button.rect.on('click', trigger);
    button.hLine.on('click', trigger);
    return button;
  };
})(jQuery);
