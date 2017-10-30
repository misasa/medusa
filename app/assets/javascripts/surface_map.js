function initSurfaceMap() {
  var div = document.getElementById("surface-map");
  var radiusSelect = document.getElementById("spot-radius");
  var baseUrl = div.dataset.baseUrl;
  var global_id = div.dataset.globalId;
  var length = parseFloat(div.dataset.length);
  var attachment_files = JSON.parse(div.dataset.attachmentFiles);
  var spots = JSON.parse(div.dataset.spots);
  var layers = [];
  var baseMaps = {};
  var overlayMaps = {};
  var x = 256;
  var y = 256;
  var zoom = 1;

  var first = true;
  for(name in attachment_files) {
    var id = attachment_files[name];
    var layer = L.tileLayer(baseUrl + global_id + '/' + id + '/{z}/{x}_{y}.png', { attribution: 'Map data &copy' });
    layers.push(layer);
    if (first) {
      baseMaps[name] = layer;
      first = false;
    } else {
      overlayMaps[name] = layer;
    }
  }

  var circlesLayer = L.layerGroup();
  for(spot of spots) {
    var circle = L.circleMarker([-spot.y, spot.x], {
      color: 'red',
      fillColor: '#f03',
      fillOpacity: 0.5,
      radius: 3,
    });
    circle.id = spot.id;
    circle.on("click", function() {
      var latlng = this.getLatLng();
      this.bindPopup("x: " + latlng.lng.toFixed(2) + "<br />y: " + -latlng.lat.toFixed(2)).openPopup();
    });
    circle.addTo(circlesLayer);
  }
  layers.push(circlesLayer);

  var map = L.map('surface-map', {
    maxZoom: 8,
    minZoom: 0,
    crs: L.CRS.Simple,
    layers: layers
  });

  var gridLayer = L.layerGroup();
  for (x = 0; x <= map.getSize().x; x += 20) {
    var top = map.unproject([0, x]),
	bottom = map.unproject([map.getSize().x, x]);
    L.polyline([top, bottom], { color: 'red', weight: 1, opacity: 0.5 }).addTo(gridLayer);
  }
  for (y = 0; y <= map.getSize().y; y += 20) {
    var left = map.unproject([y, 0]),
	right = map.unproject([y, map.getSize().y]);
    L.polyline([left, right], { color: 'red', weight: 1, opacity: 0.5 }).addTo(gridLayer);
  }
  overlayMaps['grid'] = gridLayer;

  var radiusControl = L.control({position: 'bottomright'});
  radiusControl.onAdd = function (map) {
    var div = L.DomUtil.create('div', 'leaflet-control-layers'),
        range = L.DomUtil.create('input');
    range.type = 'range';
    range.min = 1;
    range.max = 10;
    range.value = 3;
    range.style = 'width:60px;margin:3px;';
    div.appendChild(range);
    L.DomEvent.on(range, 'change', function() {
      circlesLayer.eachLayer(function(layer) {
        layer.setRadius(range.value);
      });
    });
    L.DomEvent.on(range, 'input', function() {
      circlesLayer.eachLayer(function(layer) {
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
  };
  radiusControl.addTo(map);

  L.Control.CustomScale = L.Control.Scale.extend({
    _updateMetric: function(maxMeters) {
      var pixelsPerMeter = this.options.maxWidth / (maxMeters * map.getZoomScale(map.getZoom(), 0)),
	  microMetersPerPixel = length / map.getSize().x,
	  rate = pixelsPerMeter * microMetersPerPixel,
	  meters = this._getRoundNum(maxMeters * rate),
	  label = meters < 1000 ? meters + ' μm' : (meters / 1000) + ' mm';
      this._updateScale(this._mScale, label, meters / rate / maxMeters);
    }
  });
  L.control.customScale = function(options) {
    return new L.Control.CustomScale(options);
  };
  L.control.customScale({ imperial: false }).addTo(map);

  L.control.layers(baseMaps, overlayMaps).addTo(map);

  map.setView(map.unproject([x, y], zoom), zoom);
}
