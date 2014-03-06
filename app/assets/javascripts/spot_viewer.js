(function($) {
  $.widget("medusa.spotViewer", {
    options: {
    },
    scroll: false,
    _create: function() {
      var self = this;
      this.options = $.extend({
        width: this.element.attr("width"),
        height: this.element.attr("height")
      }, this.options);
      self._addImage();
      self._addSight();
      self._addZoomInButton();
      self._addZoomOutButton();
      self.element.mousedown(function(e) {
        self._startScroll(e);
        return false;
      });
      self.element.mouseup(function(e) { self._stopScroll(e) });
      self.element.mouseout(function(e) { self._stopScroll(e) });
      self.element.mousemove(function(e) {
        self._scroll(e);
        return false;
      });
    },
    loadImage: function(path) {
      this.image.setAttributeNS("http://www.w3.org/1999/xlink", "href", path);
      this.image.setAttribute("x", 0);
      this.image.setAttribute("y", 0);
      this.image.setAttribute("width", this.options.width);
      this.image.setAttribute("height", this.options.height);
    },
    zoomIn: function() {
      var x = parseFloat(this.image.getAttribute("x")), y = parseFloat(this.image.getAttribute("y")),
          width = parseFloat(this.image.getAttribute("width")),
          height = parseFloat(this.image.getAttribute("height"));
      this.image.setAttribute("x", x - width / 2);
      this.image.setAttribute("y", y - height / 2);
      this.image.setAttribute("width", width * 2);
      this.image.setAttribute("height", height * 2);
    },
    zoomOut: function() {
      var x = parseFloat(this.image.getAttribute("x")), y = parseFloat(this.image.getAttribute("y")),
          width = parseFloat(this.image.getAttribute("width")),
          height = parseFloat(this.image.getAttribute("height"));
      this.image.setAttribute("x", x + width / 4);
      this.image.setAttribute("y", y + height / 4);
      this.image.setAttribute("width", width / 2);
      this.image.setAttribute("height", height / 2);
    },
    _addImage: function() {
      var image = document.createElementNS("http://www.w3.org/2000/svg", "image");
      this.image = image;
      this.element.append(image);
      this.loadImage(this.element.data("image"));
    },
    _addSight: function() {
      this.element.append(this._createLine({
        "x1": this.options.width / 2,
        "y1": 0,
        "x2": this.options.width / 2,
        "y2": this.options.height,
        "style": "stroke:red"
      }));
      this.element.append(this._createLine({
        "x1": 0,
        "y1": this.options.height / 2,
        "x2": this.options.width,
        "y2": this.options.height / 2,
        "style": "stroke:red"
      }));
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
      this.element.append(this.zoomInButton);
      this.element.append(this._createLine({
        "x1": 15,
        "y1": 25,
        "x2": 35,
        "y2": 25
      }));
      this.element.append(this._createLine({
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
      this.element.append(this.zoomOutButton);
      this.element.append(this._createLine({
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
        this.image.setAttribute("x", x + (this.pageX - e.pageX));
        this.image.setAttribute("y", y + (this.pageY - e.pageY));
        this.pageX = e.pageX;
        this.pageY = e.pageY;
      }
    }
  });
}) (jQuery);
