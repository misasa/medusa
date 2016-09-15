(function($) {
  $.widget("medusa.surfaceViewer", {
    options: {
    },
    scroll: false,
    _create: function() {
      var self = this;
      this.targetUid = this.element.find("input.target-uid").val();
      this.canvas = this.element.find("svg.surface-canvas");
      this.form = this.element.find("form");
      this.thumbnails = this.element.find("div.spot-thumbnails");
      this.options = $.extend({
        width: this.canvas.attr("width"),
        height: this.canvas.attr("height"),
        scale: this.canvas.data("scale"),
      }, this.options);
      this._initCanvas();
      this._initThumbnails();
    },
    loadImage: function(svg) {
      var self = this, spot;
      $(this.group).empty();
      this.rect = $(svg).find("rect");
      this.image = $(svg).find("image");
      this.spots = $(svg).find("circle");
      this.polylines = $(svg).find("polyline");
      spot = this.spots.filter("[data-target-uid='" + this.targetUid + "']");
      this._initTransform(this.rect.attr("width"), this.rect.attr("height"), spot.attr("cx"), spot.attr("cy"));
      svg.setAttribute("width", this.rect.attr("width"));
      svg.setAttribute("height", this.rect.attr("height"));

      this.group.appendChild(svg);
      $(this.rect).dblclick(function(e) {
        var offsetX = e.pageX - $(this).offset().left, offsetY = e.pageY - $(this).offset().top,
            x = (self.options.width) / 2 - offsetX, y = (self.options.height) / 2 - offsetY;
        self.translate(x, y);
        return false;
      });
      $(this.image).dblclick(function(e) {
        var offsetX = (e.pageX) - $(this).offset().left, offsetY = (e.pageY + 0) - $(this).offset().top,
            x = (self.options.width) / 2 - offsetX, y = (self.options.height) / 2 - offsetY;
        self.translate(x, y);
        return false;
      });

      $(this.spots).css("cursor", "pointer");
      $(this.spots).click(function(e) {
        location.href = $(this).data("spot");
      });
      $(this.polylines).css("cursor", "pointer");
      $(this.polylines).click(function(e) {
        location.href = $(this).data("spot");
      });      
    },
    center: function() {
      return { left: ((this.options.width / 2) - this.translateX) / this.scale, top: ((this.options.height / 2) - this.translateY) / this.scale };
    },
    translate: function(x, y) {
      this.transform(x, y, this.scale);
    },
    transform: function(x, y, scale) {
      this.translateX = x;
      this.translateY = y;
      this.scale = scale;
      this.group.setAttribute("transform", "translate(" + x + "," + y + ") scale(" + scale + ")");
    },
    zoomIn: function() {
      var width = parseFloat(this.options.width),
          height = parseFloat(this.options.height);
          x = (this.translateX * 2) - (width / 2), y = (this.translateY * 2) - (height / 2),
          scale = this.scale * 2;
      this.transform(x, y, scale);
    },
    zoomOut: function() {
      var width = parseFloat(this.options.width),
          height = parseFloat(this.options.height);
          x = (this.translateX + width / 2) / 2, y = (this.translateY + height / 2) / 2,
          scale = this.scale / 2;
      this.transform(x, y, scale);
    },
    _initCanvas: function() {
      var self = this;
      this._addGroup();
      this._addSight();
      this._addZoomButtons();
      if (this.canvas.data("image")) {
        $.get(this.canvas.data("image"), function(data) {
          self.loadImage(data.documentElement);
        });
      }
    },
    _initTransform: function(width, height, cx, cy) {
      var scaleX, scaleY, left, top;
      scaleX = this.options.width / width;
      scaleY = this.options.height / height;
      scale = (scaleX < scaleY) ? scaleX : scaleY;
      if (this.options.scale) {
        scale = scale * this.options.scale;
      }
      if (cx && cy) {
        left = (this.options.width / 2) - cx * scale;
        top = (this.options.height / 2) - cy * scale;
      } else {
        left = (this.options.width - width * scale) / 2;
        top = (this.options.height - height * scale) / 2;
      }
      this.transform(left, top, scale);
    },
    _addGroup: function() {
      var group = this._createSvgElement("g");
      this.group = group;
      this.canvas.append(group);
    },
    _addSight: function() {
      this.canvas.append(this._createLine({
        "x1": this.options.width / 2,
        "y1": 0,
        "x2": this.options.width / 2,
        "y2": this.options.height,
        "style": "stroke:red"
      }));
      this.canvas.append(this._createLine({
        "x1": 0,
        "y1": this.options.height / 2,
        "x2": this.options.width,
        "y2": this.options.height / 2,
        "style": "stroke:red"
      }));
    },
    _addZoomButtons: function() {
      this._addZoomInButton();
      this._addZoomOutButton();
    },
    _addZoomInButton: function() {
      var self = this;
      this.zoomInButton = this._createRect({
        "x": 10,
        "y": 10,
        "width": 30,
        "height": 30,
        "fill": "#EEFFFF"
      })
      this.canvas.append(this.zoomInButton);
      this.canvas.append(this._createLine({
        "x1": 15,
        "y1": 25,
        "x2": 35,
        "y2": 25
      }));
      this.canvas.append(this._createLine({
        "x1": 25,
        "y1": 15,
        "x2": 25,
        "y2": 35
      }));
      $(this.zoomInButton).on("click", function() { self.zoomIn(); });
    },
    _addZoomOutButton: function() {
      var self = this;
      this.zoomOutButton = this._createRect({
        "x": 10,
        "y": 50,
        "width": 30,
        "height": 30,
        "fill": "#EEFFFF"
      });
      this.canvas.append(this.zoomOutButton);
      this.canvas.append(this._createLine({
        "x1": 15,
        "y1": 65,
        "x2": 35,
        "y2": 65
      }));
      $(this.zoomOutButton).on("click", function() { self.zoomOut(); });
    },
    _createRect: function(options) {
      options = $.extend({
        "stroke-width": 1,
      }, options);
      return this._createSvgElement("rect", options);
    },
    _createLine: function(options) {
      options = $.extend({
        "stroke-width": 1,
        "style": "stroke:black"
      }, options);
      return this._createSvgElement("line", options);
    },
    _createSvgElement: function(name, options) {
      var element = document.createElementNS("http://www.w3.org/2000/svg", name);
      options = $.extend({}, options);
      $.each(options, function(key, value) {
        element.setAttribute(key, value);
      });
      return element;
    },
    _initThumbnails: function() {
      var self = this;
      $(self.thumbnails).on("ajax:success", "a.thumbnail", function(event, data, status) {
        self.loadImage(data.documentElement);
        if (self.form.length > 0) {
          var action = self.form.attr("action");
          self.form.attr("action", action.replace(/(.*attachment_files\/)\d+(\/spots)/, "$1" + self.image.data("id") + "$2"));
        }
      });
      self.thumbnails.find("a.thumbnail").first().click();
    }
  });
}) (jQuery);
