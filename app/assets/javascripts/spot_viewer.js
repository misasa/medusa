(function($) {
  $.widget("medusa.spotViewer", {
    options: {
    },
    scroll: false,
    _create: function() {
      var self = this;
      this.canvas = this.element.find("svg.spot-canvas");
      this.thumbnails = this.element.find("div.spot-thumbnails");
      this.options = $.extend({
        width: this.canvas.attr("width"),
        height: this.canvas.attr("height")
      }, this.options);
      this._initCanvas();
      this._initThumbnails();
    },
    loadImage: function(path) {
      var self = this,  image = document.createElementNS("http://www.w3.org/2000/svg", "image");
      $(this.group).empty();
      this.image = image;
      this.group.appendChild(image);
      this.image.setAttributeNS("http://www.w3.org/1999/xlink", "href", path);
      this.image.setAttribute("x", 0);
      this.image.setAttribute("y", 0);
      this.image.setAttribute("width", this.options.width);
      this.image.setAttribute("height", this.options.height);
      this.translateX = 0;
      this.translateY = 0;
      this.scale = 1;
      this.group.setAttribute("transform", "translate(" + this.translateX + "," + this.translateY + ") scale(" + this.scale + ")");
      $(this.image).dblclick(function(e) {
        var offsetX = e.pageX - $(this).offset().left, offsetY = e.pageY - $(this).offset().top,
            x = (self.options.width) / 2 - offsetX, y = (self.options.height) / 2 - offsetY;
        self.translate(x, y);
        return false;
      });
    },
    addSpot: function(cx, cy, r, options) {
      var circle = this._createSvgElement("circle", $.extend({}, options, {
        cx: cx,
        cy: cy,
        r: r
      }));
      this.group.appendChild(circle);
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
      var width = parseFloat(this.image.getAttribute("width")),
          height = parseFloat(this.image.getAttribute("height"));
          x = (this.translateX * 2) - (width / 2), y = (this.translateY * 2) - (height / 2),
          scale = this.scale * 2;
      this.transform(x, y, scale);
    },
    zoomOut: function() {
      var width = parseFloat(this.image.getAttribute("width")),
          height = parseFloat(this.image.getAttribute("height"));
          x = (this.translateX + width / 2) / 2, y = (this.translateY + height / 2) / 2,
          scale = this.scale / 2;
      this.transform(x, y, scale);
    },
    _initCanvas: function() {
      var self = this;
      self._addGroup();
      self._addSight();
      self._addZoomButtons();
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
    _startScroll: function(e) {
      this.pageX = e.pageX;
      this.pageY = e.pageY;
      this.scroll = true;
    },
    _stopScroll: function() {
      this.scroll = false;
    },
    _scroll: function(e) {
      var x = parseFloat(this.image.getAttribute("x")), y = parseFloat(this.image.getAttribute("y"));
      if (this.scroll) {
        this.translateX = this.translateX + (this.pageX - e.pageX);
        this.translateY = this.translateY + (this.pageY - e.pageY);
        this.group.setAttribute("transform", "translate(" + this.translateX + "," + this.translateY + ") scale(" + this.scale + ")");
        this.pageX = e.pageX;
        this.pageY = e.pageY;
      }
    },
    _initThumbnails: function() {
      var self = this;
      $(self.thumbnails).on("ajax:success", "a.thumbnail", function(event, data, status) {
        self.loadImage($(this).find("img").attr("src"));
        $.each(data, function(index, spot) {
          self.addSpot(spot.spot_x, spot.spot_y, spot.radius_in_percent, {
            fill: spot.fill_color,
            "fill-opacity": spot.opacity,
            stroke: spot.stroke_color,
            "stroke-width": spot.stroke_width
          });
        });
      });
      self.thumbnails.find("a.thumbnail").first().click();
    }
  });
}) (jQuery);
