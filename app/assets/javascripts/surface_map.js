// OpacityLayerControl
L.Control.OpacityLayers = L.Control.Layers.extend({
    _addItem: function (obj) {
        var label = L.Control.Layers.prototype._addItem.call(this, obj);

        //if (!obj.overlay || !obj.layer.setOpacity) {
	if (!obj.overlay) {
            return label;
        }

        input = document.createElement('input');
        input.type = 'range';
        input.min = 0;
        input.max = 100;
        input.value = 100;
        input.layerId = L.stamp(obj.layer);
        if (this._map.hasLayer(obj.layer)) {
            input.style.display = 'block';
        } else {
            input.style.display = 'none';
        }

        L.DomEvent.on(input, 'change', this._onInputClick, this);

        label.appendChild(input);
        return label;
    },
    _onInputClick: function () {
        var i, input, obj,
	inputs = this._form.getElementsByTagName('input');
        inputsLen = inputs.length;

        this._handlingClick = true;

        for (i = 0; i < inputsLen; i++) {
            input = inputs[i];

            //obj = this._layers[input.layerId];
	    obj = this._getLayer(input.layerId);
            
            if (input.type == 'range' && this._map.hasLayer(obj.layer)) {
                input.style.display = 'block';
		group_layers = obj.layer.getLayers();
		for (var j = 0; j < group_layers.length; j++){
		    var _layer = group_layers[j];
		    if (typeof _layer._url === 'undefined'){
		    } else {
			_layer.setOpacity(input.value / 100.0);
		    }
		}
                continue;
            } else if (input.type == 'range' && !this._map.hasLayer(obj.layer)) {
                input.style.display = 'none';
                continue;
            }

            if (input.checked && !this._map.hasLayer(obj.layer)) {
                this._map.addLayer(obj.layer);

            } else if (!input.checked && this._map.hasLayer(obj.layer)) {
                this._map.removeLayer(obj.layer);
            } //end if
        } //end loop

        this._handlingClick = false;

        this._refocusOnMap();
    }
});

L.control.opacityLayers = function (baseLayers, overlays, options) {
        return new L.Control.OpacityLayers(baseLayers, overlays, options);
};
// Customized scale control for surface.
L.Control.SurfaceScale = L.Control.Scale.extend({
  options: L.Util.extend({}, L.Control.Scale.prototype.options, { length: undefined }),
  _updateMetric: function(maxMeters) {
    var map = this._map,
	pixelsPerMeter = this.options.maxWidth / (maxMeters * map.getZoomScale(map.getZoom(), 0)),
	microMetersPerPixel = this.options.length / 256;
	rate = pixelsPerMeter * microMetersPerPixel,
	meters = this._getRoundNum(maxMeters * rate),
	label = meters < 1000 ? meters + ' μm' : (meters / 1000) + ' mm';
    this._updateScale(this._mScale, label, meters / rate / maxMeters);
  }
});
L.control.surfaceScale = function(options) {
  return new L.Control.SurfaceScale(options);
};


// Customized circle for spot.
L.circle.spot = function(map, spot, urlRoot, options) {
  var options = L.Util.extend({}, { color: 'red', fillColor: '#f03', fillOpacity: 0.5, radius: 3 }, options),
      marker = new L.circle(map.unproject([spot.x, spot.y], 0), options);
  marker.on('click', function() {
    var latlng = this.getLatLng(),
        link = '<a href=' + urlRoot + 'records/' + spot.id + '>' + spot.name + '</a><br/>';
    this.bindPopup(link + "x: " + latlng.lng.toFixed(2) + "<br />y: " + -latlng.lat.toFixed(2)).openPopup();
  });
  return marker;
};


// Radius control for Circle.
L.Control.Radius = L.Control.extend({
  initialize: function (layerGroup, options) {
    this._layerGroup = layerGroup;
    L.Util.setOptions(this, options);
  },
  onAdd: function(map) {
    var layerGroup = this._layerGroup,
	div = L.DomUtil.create('div', 'leaflet-control-layers'),
        range = this.range = L.DomUtil.create('input');
    range.type = 'range';
    range.min = 0.1;
    range.max = 10;
    range.step = 0.1;
    range.value = 3;
    range.style = 'width:60px;margin:3px;';
    div.appendChild(range);
    L.DomEvent.on(range, 'click', function(event) {
      event.preventDefault();
    });
    L.DomEvent.on(range, 'change', function() {
      layerGroup.eachLayer(function(layer) {
	layer.setRadius(range.value);
      });
    });
    L.DomEvent.on(range, 'input', function() {
      layerGroup.eachLayer(function(layer) {
	layer.setRadius(range.value);
      });
    });
    L.DomEvent.on(range, 'mouseenter', function(e) {
      map.dragging.disable()
    });
    L.DomEvent.on(range, 'mouseleave', function(e) {
      map.dragging.enable();
    });
    return div;
  },
  getValue: function() {
    return this.range.value;
  }
});
L.control.radius = function(layerGroup, options) {
  return new L.Control.Radius(layerGroup, options);
};


// Customized layer group for spots.
L.layerGroup.spots = function(map, spots, urlRoot) {
  var group = L.layerGroup();
  for(var i = 0; i < spots.length; i++) {
    L.circle.spot(map, spots[i], urlRoot).addTo(group);
  }
  return group;
};


// Customized layer group for grid.
L.layerGroup.grid = function(map, length) {
  var group = L.layerGroup(),
      pixelsPerMiliMeter = 256 * 1000 / length,
      getFromTo = function(half, step) {
        var center = 256 / 2;
        return {
	  from: center - Math.ceil(half / step) * step,
	  to: center + Math.ceil(half / step) * step
	}
      },
      xFromTo = getFromTo(map.getSize().x / 2, pixelsPerMiliMeter),
      yFromTo = getFromTo(map.getSize().y / 2, pixelsPerMiliMeter);
  for (y = yFromTo.from; y < yFromTo.to + 1; y += pixelsPerMiliMeter) {
    var left = map.unproject([xFromTo.from, y], 0),
	right = map.unproject([xFromTo.to, y]);
    L.polyline([left, right], { color: 'red', weight: 1, opacity: 0.5 }).addTo(group);
  }
  for (x = xFromTo.from; x < xFromTo.to + 1; x += pixelsPerMiliMeter) {
    var top = map.unproject([x, yFromTo.from], 0),
	bottom = map.unproject([x, yFromTo.to]);
    L.polyline([top, bottom], { color: 'red', weight: 1, opacity: 0.5 }).addTo(group);
  }
  return group;
};


function initSurfaceMap() {
  var div = document.getElementById("surface-map");
  var radiusSelect = document.getElementById("spot-radius");
  var baseUrl = div.dataset.baseUrl;
  var urlRoot = div.dataset.urlRoot;
  var global_id = div.dataset.globalId;
  var length = parseFloat(div.dataset.length);
  var matrix = JSON.parse(div.dataset.matrix);
  var addSpot = JSON.parse(div.dataset.addSpot);
  var baseImage = JSON.parse(div.dataset.baseImage);
  var layerGroups = JSON.parse(div.dataset.layerGroups);
  var images = JSON.parse(div.dataset.images);
  var spots = JSON.parse(div.dataset.spots);
  var layers = [];
  var baseMaps = {};
  var overlayMaps = {};
  var zoom = 1;

  var layer = L.tileLayer(baseUrl + global_id + '/' + baseImage.id + '/{z}/{x}_{y}.png');
  layers.push(layer);
  baseMaps[baseImage.name] = layer;
  layerGroups.concat([{ name: "", opacity: 100 }]).forEach(function(layerGroup) {
    var group = L.layerGroup(), name = layerGroup.name, opacity = layerGroup.opacity / 100.0;
    if (images[name]) {
      images[name].forEach(function(id) {
	L.tileLayer(baseUrl + global_id + '/' + id + '/{z}/{x}_{y}.png', { opacity: opacity }).addTo(group);
      });
      layers.push(group);
      if (name === "") { name = "top"; }
      overlayMaps[name] = group;
    }
  });

  var map = L.map('surface-map', {
    maxZoom: 8,
    minZoom: 0,
    crs: L.CRS.Simple,
    layers: layers
  });
  map.getSpotPoint = function() {
    if (!addingSpot) { return; }
    var point = map.project(addingSpot.getLatLng(), 0),
	x = matrix[0][0] * point.x + matrix[0][1] * point.y + matrix[0][2],
	y = matrix[1][0] * point.x + matrix[1][1] * point.y + matrix[1][2];
    return { x: x, y: y };
  };

  var spotsLayer = L.layerGroup.spots(map, spots, urlRoot);
  map.addLayer(spotsLayer);

  overlayMaps['grid'] = L.layerGroup.grid(map, length);

  var radiusControl = L.control.radius(spotsLayer, {position: 'bottomright'}).addTo(map);

  var addingSpot;
  map.on('click', function(event) {
    if (!addSpot || event.originalEvent.defaultPrevented) { return; }
    var self = this;
    setTimeout( function() {
      var x = (event.containerPoint.x + self.getPixelBounds().min.x) / self.getZoomScale(self.getZoom(), 0),
          y = (event.containerPoint.y + self.getPixelBounds().min.y) / self.getZoomScale(self.getZoom(), 0),
          options = L.Util.extend({}, { color: 'blue', fillColor: '#30f', fillOpacity: 0.5, radius: radiusControl.getValue() }, options);
      if (addingSpot) { addingSpot.remove(); }
      addingSpot = new L.circle(map.unproject([x, y], 0), options);
      addingSpot.addTo(spotsLayer);
    }, 100);
  });

  L.control.surfaceScale({ imperial: false, length: length }).addTo(map);

  //L.control.layers(baseMaps, overlayMaps).addTo(map);
  L.control.opacityLayers(baseMaps, overlayMaps).addTo(map);
  map.setView(map.unproject([256 / 2, 256 / 2], 0), zoom);

  map.addControl(new L.Control.Fullscreen());

  surfaceMap = map;
}
