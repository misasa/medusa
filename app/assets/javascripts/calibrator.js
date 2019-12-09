(function($) {
  var Calibrator = this.Calibrator = function(element) {
    var calibrator = Object.create(Calibrator.prototype), baseTriangle, overlayTriangle,
    baseImage, overlayImage, viewerBaseImage, viewerOverlayImage, baseOverlayImage;

    calibrator.element = $(element);
    calibrator.viewer = Calibrator.Viewer(calibrator.element.find("div.viewer"));
    calibrator.base = Calibrator.Viewer(calibrator.element.find("div.base"));
    calibrator.overlay = Calibrator.Viewer(calibrator.element.find("div.overlay"));
    calibrator.thumbnails = Calibrator.Thumbnails(calibrator.element.find("div.thumbnails"));
    calibrator.opacity = calibrator.element.find("input.opacity");
    calibrator.moveButton = calibrator.element.find("button.move");
    calibrator.calculate_affine_button = calibrator.element.find("#calc_affine");

    calibrator.anchors_on_overlay = [];
    calibrator.anchors_on_overlay.push(calibrator.element.find("#anchor_0"));
    calibrator.anchors_on_overlay.push(calibrator.element.find("#anchor_1"));
    calibrator.anchors_on_overlay.push(calibrator.element.find("#anchor_2"));
    calibrator.anchors_on_overlay.push(calibrator.element.find("#anchor_3"));
    calibrator.anchors_on_overlay.push(calibrator.element.find("#anchor_4"));
    calibrator.anchors_on_overlay.push(calibrator.element.find("#anchor_5"));
    calibrator.anchors_on_world = [];
    calibrator.anchors_on_world.push(calibrator.element.find("#anchor_w0"));
    calibrator.anchors_on_world.push(calibrator.element.find("#anchor_w1"));
    calibrator.anchors_on_world.push(calibrator.element.find("#anchor_w2"));
    calibrator.anchors_on_world.push(calibrator.element.find("#anchor_w3"));
    calibrator.anchors_on_world.push(calibrator.element.find("#anchor_w4"));
    calibrator.anchors_on_world.push(calibrator.element.find("#anchor_w5"));
    calibrator.anchors_on_image = [];
    calibrator.anchors_on_image.push(calibrator.element.find("#anchor_i0"));
    calibrator.anchors_on_image.push(calibrator.element.find("#anchor_i1"));
    calibrator.anchors_on_image.push(calibrator.element.find("#anchor_i2"));
    calibrator.anchors_on_image.push(calibrator.element.find("#anchor_i3"));
    calibrator.anchors_on_image.push(calibrator.element.find("#anchor_i4"));
    calibrator.anchors_on_image.push(calibrator.element.find("#anchor_i5"));
    calibrator.anchors_on_base = [];
    calibrator.anchors_on_base.push(calibrator.element.find("#anchor_b0"));
    calibrator.anchors_on_base.push(calibrator.element.find("#anchor_b1"));
    calibrator.anchors_on_base.push(calibrator.element.find("#anchor_b2"));
    calibrator.anchors_on_base.push(calibrator.element.find("#anchor_b3"));
    calibrator.anchors_on_base.push(calibrator.element.find("#anchor_b4"));
    calibrator.anchors_on_base.push(calibrator.element.find("#anchor_b5"));
    $(calibrator.calculate_affine_button).removeAttr('disabled');
    for (var i=0; i < 6; ++i ){
	    $(calibrator.anchors_on_world[i]).removeAttr('disabled');
    }
    calibrator.moveButton.attr('disabled',true);
    for (var i=0; i < 6; ++i ){
	    $(calibrator.anchors_on_image[i]).attr('disabled',true);
    }
    
    $(calibrator.calculate_affine_button).click(function() {
      var imageCoord = [];
      var worldCoord = [];
      for (var i=0; i < 6; ++i ){
	      imageCoord.push(Number($(calibrator.anchors_on_image[i]).val()));
	      worldCoord.push(Number($(calibrator.anchors_on_world[i]).val()));
      }
      var matrix = Matrix.fromTriangles(imageCoord, worldCoord);
      var array = [
          [matrix.a, matrix.c, matrix.e],
          [matrix.b, matrix.d, matrix.f],
          [0, 0, 1]
      ];
      for (i = 0; i < 3; i++) {
        array[i] = array[i].map(function(x) { return x.toExponential(5); }).join(",");
      }
      $(calibrator.element.find("#affine_matrix")).val("[" + array.join(";") + "]");
    });

    calibrator.viewer.addZoomControl().draggable();
    calibrator.base.addZoomControl().draggable();
    calibrator.overlay.addZoomControl().draggable();
    calibrator.overlay_image_name = calibrator.thumbnails.overlayImageName();
    var overlayImagePath = calibrator.thumbnails.overlayImagePath();
	  resizeOverlay = function() {
	    var t1 = overlayTriangle.get();
      var tt = calibrator.transformedCoord();
      var overlayCoord = calibrator.overlayTriangle.coord()
      for (var i=0; i < 6; ++i ){
        $(calibrator.anchors_on_overlay[i]).val(t1[i])
        $(calibrator.anchors_on_image[i]).val(overlayCoord[i])
        $(calibrator.anchors_on_world[i]).val(tt[i])
      }

	    var tb = baseTriangle.get();
      for (var i=0; i < 6; ++i ){
	      $(calibrator.anchors_on_base[i]).val(tb[i])
      }
      var baseCoord = calibrator.baseTriangle.coord();
      var perspT = calibrator.basePerspT();
      var basePerspTCoord = perspT.transform(baseCoord[0], baseCoord[1]);
      Array.prototype.push.apply(basePerspTCoord, perspT.transform(baseCoord[2], baseCoord[3]));
      Array.prototype.push.apply(basePerspTCoord, perspT.transform(baseCoord[4], baseCoord[5]));
      for (var i=0; i < 6; ++i ){
        $(calibrator.anchors_on_world[i]).val(basePerspTCoord[i])
      }  
      //$("#debug_info").text(baseCoord);

	    var t2 = tb.map(function(x) { return x * viewerBaseImage.scale; });
	    viewerOverlayImage.transform(Matrix.fromTriangles(t1, t2));

	    var t3 = tb.map(function(x) { return x * baseImage.scale; });
	    baseOverlayImage.transform(Matrix.fromTriangles(t1, t3));

	    $(calibrator).trigger('change');
	  };

    overlayImage = calibrator.overlay.image(overlayImagePath);
    $(overlayImage).on('loaded', function(event, image) {
      image.fit();
      overlayTriangle = calibrator.overlayTriangle = Calibrator.Triangle(calibrator.overlay.imageGroup, image);
      $(overlayTriangle).on('dragmove', resizeOverlay);
      var t1 = overlayTriangle.get();
      var tt = calibrator.transformedCoord();
      var overlayCoord = calibrator.overlayTriangle.coord()
      for (var i=0; i < 6; ++i ){
        $(calibrator.anchors_on_overlay[i]).val(t1[i])
        $(calibrator.anchors_on_image[i]).val(overlayCoord[i])
        $(calibrator.anchors_on_world[i]).val(tt[i])
      }
    });

    $(calibrator.thumbnails).on('selected', function(event, params) {
      var src = params.src, name = params.name, points = params.points, corners = params.corners;
      if (params.affine) {
        calibrator.baseAffine = params.affine;
      } else {
        calibrator.baseAffine = [1, 0, 0, 0, 1, 0];
      }
      if (baseImage) { baseImage.remove(); }
      baseImage = calibrator.base.image(src);
      if (params.corners) {
        calibrator.baseCorners = params.corners;
      }

      calibrator.base_image_name = params.name;
      $(baseImage).on('loaded', function(event, image) {
        calibrator.viewer.reset();
	      image.fit();
        for (var i=0; i < 6; ++i ){
          $(calibrator.anchors_on_world[i]).attr('disabled',true);
        }
        $(calibrator.calculate_affine_button).attr('disabled',true);
        calibrator.moveButton.removeAttr('disabled');

	      if(baseOverlayImage) { baseOverlayImage.remove() }
	      baseOverlayImage = calibrator.base.image(overlayImagePath).opacity(calibrator.opacity.val());
	      $(baseOverlayImage).on('loaded', function(event, image) {
	        image.stroke({ width: 1, color: "#f00" });
	        resizeOverlay();
	      });

	      if (baseTriangle) { baseTriangle.remove(); }
	      baseTriangle = calibrator.baseTriangle = Calibrator.Triangle(calibrator.base.imageGroup, image);
        var calibration_points_on_world = calibrator.calibration_points_on_world();
        var calibration_points_on_pixels = calibrator.world_pairs_on_base(calibration_points_on_world);
        if (calibration_points_on_pixels) {
          baseTriangle.set(calibration_points_on_pixels);
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
	        image.stroke({ width: 5, color: "#f00" });
	        resizeOverlay();
	      });
      });
    });

    $(calibrator.opacity).on('input', function(event) {
      viewerOverlayImage.opacity($(this).val());
      baseOverlayImage.opacity($(this).val());
    });

    $(calibrator.moveButton).on('mousedown', function(event) {
      var xy = {
	      left: [-1, 0],
	      right: [1, 0],
	      up: [0, -1],
	      down: [0, 1]
      },
	    moveFunction = function () {
	      if (!calibrator.direction) {
	        return;
	      }
	      baseTriangle.dmove(...xy[calibrator.direction]);
	      setTimeout(moveFunction, 100);
	    };

      calibrator.direction = $(this).data("direction");
      moveFunction();
    });

    $(calibrator.moveButton).on('mouseup', function(event) {
      calibrator.direction = undefined;
    });

    return calibrator;
  };

  Calibrator.prototype = {
    basePerspT() {
      c = this.baseCorners;
      w = this.baseTriangle.image.width;
      h = this.baseTriangle.image.height;
      l = w;
      if (h > w){ l = h }
      x = w/l/2.0 * 100.0;
      y = h/l/2.0 * 100.0;
      var srcCorners = [-x, +y, x, +y, x, -y, -x, -y];
      var dstCorners = [c[0][0], c[0][1], c[1][0], c[1][1], c[2][0], c[2][1], c[3][0], c[3][1]];
      return PerspT(srcCorners, dstCorners);
    },
    overlayPerspT() {
      c = this.thumbnails.overlayCorners();
      w = this.overlayTriangle.image.width;
      h = this.overlayTriangle.image.height;
      l = w;
      if (h > w){ l = h }
      x = w/l/2.0 * 100.0;
      y = h/l/2.0 * 100.0;
      var srcCorners = [-x, +y, x, +y, x, -y, -x, -y];
      var dstCorners = [c[0][0], c[0][1], c[1][0], c[1][1], c[2][0], c[2][1], c[3][0], c[3][1]];
      return PerspT(srcCorners, dstCorners);
    },
    affineMatrix() {
      var overlayCoord = this.overlayTriangle.coord(),baseCoord = this.baseTriangle.coord();
      var perspT = this.basePerspT();
      var basePerspTCoord = perspT.transform(baseCoord[0], baseCoord[1]);
      Array.prototype.push.apply(basePerspTCoord, perspT.transform(baseCoord[2], baseCoord[3]));
      Array.prototype.push.apply(basePerspTCoord, perspT.transform(baseCoord[4], baseCoord[5]));
      pm = Matrix.fromTriangles(overlayCoord, basePerspTCoord);
      return pm;
    },
    affine_ij2ij() {
      var _overlay_ij = [
	      this.overlayTriangle.circles[0].cx(),
        this.overlayTriangle.circles[0].cy(),
        this.overlayTriangle.circles[1].cx(),
        this.overlayTriangle.circles[1].cy(),
        this.overlayTriangle.circles[2].cx(),
        this.overlayTriangle.circles[2].cy()
      ];
      var overlay_ij = this.overlayTriangle.coord_ij();
      var _base_ij = [
	      this.baseTriangle.circles[0].cx(),
        this.baseTriangle.circles[0].cy(),
        this.baseTriangle.circles[1].cx(),
        this.baseTriangle.circles[1].cy(),
        this.baseTriangle.circles[2].cx(),
        this.baseTriangle.circles[2].cy()
      ];
      var base_ij = this.baseTriangle.coord_ij();
      return Matrix.fromTriangles(overlay_ij, base_ij);
    },
    transformedCoord(){
        var overlayCoord = this.overlayTriangle.coord();
        var overlayAffine = this.thumbnails.overlayAffine();
        if (!overlayAffine) {
	        overlayAffine = [1, 0, 0, 0, 1, 0, 0, 0, 1];
          var affine_overlay = Matrix.from(overlayAffine[0],overlayAffine[3],overlayAffine[1],overlayAffine[4],overlayAffine[2],overlayAffine[5]);
	        var transformedCoord = affine_overlay.applyToArray(overlayCoord);
        } else {
          var perspT = this.overlayPerspT();
          var transformedCoord = perspT.transform(overlayCoord[0], overlayCoord[1]);
          Array.prototype.push.apply(transformedCoord, perspT.transform(overlayCoord[2], overlayCoord[3]));
          Array.prototype.push.apply(transformedCoord, perspT.transform(overlayCoord[4], overlayCoord[5]));
    
        }
        return transformedCoord;
    },
    calibration_points_on_world(){
	    var transformedCoord = this.transformedCoord();
      return [[transformedCoord[0],transformedCoord[1]],[transformedCoord[2],transformedCoord[3]],[transformedCoord[4],transformedCoord[5]]];
    },
    pixel_from_xy(image, xy){
	    return [this.pixel_from_x(image, xy[0]), this.pixel_from_y(image, xy[1])];
    },
    pixel_from_x(image, x){
      var width = image.width, height = image.height;
      var length = width > height ? width : height;
      return x*length/100.0 + width/2.0;
    },
    pixel_from_y(image, y){
      var width = image.width, height = image.height;
      var length = width > height ? width : height;
      return height/2.0 - y*length/100.0;
    },
    world_pairs_on_base(world_pairs){
      var image = this.baseTriangle.image, width = image.width, height = image.height, length = image.length;
      baseAffine = this.baseAffine;
      perspT = this.basePerspT();        
      base_pv = perspT.transformInverse(world_pairs[0][0],world_pairs[0][1]);
      Array.prototype.push.apply(base_pv, perspT.transformInverse(world_pairs[1][0],world_pairs[1][1]));
      Array.prototype.push.apply(base_pv, perspT.transformInverse(world_pairs[2][0],world_pairs[2][1]));
      return [
	      this.pixel_from_xy(image, [base_pv[0],base_pv[1]]), 
        this.pixel_from_xy(image, [base_pv[2],base_pv[3]]),
        this.pixel_from_xy(image, [base_pv[4],base_pv[5]])
      ];
    }
  };

  Calibrator.Node = function(element) {
    var node = Object.create(Calibrator.Node.prototype);
    node.element = element;
    return node;
  };

  Calibrator.Image = function(svg, src) {
    var image = Object.create(Calibrator.Image.prototype);
    var group = image.group = svg.group();
    image.image = group.image(src).loaded(function(loader) {
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
      this.group.scale(this.scale, this.scale).translate(0, 0);
    },
    transform(matrix) {
      return this.group.transform(matrix);
    },
    remove() {
      this.group.remove();
    },
    opacity(val) {
      this.image.attr({opacity: val });
      return this;
    },
    stroke(options) {
      this.group.rect(this.width, this.height).attr({ "fill-opacity": 0 }).stroke(options);
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
      if (this.scale >= 10) { 
        return;
      } else if (this.scale < 1) {
	this.scale = this.scale + 1/10;
      } else {
        this.scale++;
      }
      this.imageGroup.scale(this.scale, this.scale);
    },
    zoomOut() {
      if (this.scale <= 0.1) {
	return;
      } else if (this.scale <= 1) {
        this.scale = this.scale - 1/10; 
      } else {
        this.scale--;
      }
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
      var base_link = $("#base_image_download_link");
      if (div.data("name")) {
        $("#base_info").text(div.data("name"));
        base_link.attr('href', div.data("path"));
        base_link.attr('title', "download " + div.data("name"));
        base_link.show();
      } else {
	$("#base_info").text("");
        base_link.attr('href', div.data("path"));
        base_link.attr('title', "download " + div.data("name"));
        base_link.hide();
        $("#blend_cmd").text("");
      }
      $(thumbnails).trigger('selected', { src: div.data("src"), name: div.data("name"), points: div.data("points"), corners: div.data("corners"), affine: div.data("affine") });
    });
    return thumbnails;
  };
  Calibrator.Thumbnails.prototype = {
    baseImagePath() {
      var div = this.element.find("div.thumbnail:first-child");
      return div.data("src");
    },
    baseImageName() {
      var div = this.element.find("div.thumbnail:first-child");
      return div.data("name");
    },
    overlayImagePath() {
      var div = this.element.find("div.thumbnail").filter(".overlay");
      return div.data("src");
    },
    overlayImageName() {
      var div = this.element.find("div.thumbnail").filter(".overlay");
      return div.data("name");
    },
    overlayAffine() {
      var div = this.element.find("div.thumbnail").filter(".overlay");
      return div.data("affine");
    },
    overlayCorners() {
      var div = this.element.find("div.thumbnail").filter(".overlay");
      return div.data("corners");
    },
  };

  Calibrator.Triangle = function(svg, image) {
    var triangle = Object.create(Calibrator.Triangle.prototype);
    triangle.image = image;
    triangle.circles = [];
    triangle.lines = [];
    var image = image, transform = image.transform(), color = "#f00",
        width = image.width * transform.scaleX, height = image.height * transform.scaleY,
        x1 = 0, y1 = 0,
        x2 = width, y2 = 0,
        x3 = width, y3 = height,
        r = 10, d = r * 2,
        //draggableOptions = { minX: -r, minY: -r, maxX: width + r, maxY: height + r },
        draggableOptions = {},
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
      var image = this.image, width = image.width, height = image.height;
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
          image = this.image, width = image.width, height = image.height,
          length = width > height ? width : height;
      return [
        (this.circles[0].cx() / scaleX - width / 2) * 100 / length,
        (height / 2 - this.circles[0].cy() / scaleY) * 100 / length,
        (this.circles[1].cx() / scaleX - width / 2) * 100 / length,
        (height / 2 - this.circles[1].cy() / scaleY) * 100 / length,
        (this.circles[2].cx() / scaleX - width / 2) * 100 / length,
        (height / 2 - this.circles[2].cy() / scaleY) * 100 / length
      ];
    },
    coord_ij() {
      var transform = this.image.transform(), scaleX = transform.scaleX, scaleY = transform.scaleY,
          image = this.image, width = image.width, height = image.height,
          length = width > height ? width : height;
      return [
	(this.circles[0].cx() / scaleX),
        (this.circles[0].cy() / scaleY),
        (this.circles[1].cx() / scaleX),
        (this.circles[1].cy() / scaleY),
        (this.circles[2].cx() / scaleX),
        (this.circles[2].cy() / scaleY)
      ];
    },
    dmove(x, y) {
      this.circles[0].dmove(x, y).fire('dragmove');
      this.circles[1].dmove(x, y).fire('dragmove');
      this.circles[2].dmove(x, y).fire('dragmove');
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
