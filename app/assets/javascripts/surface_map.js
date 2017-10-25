function initSurfaceMap() {
  var div = document.getElementById("surface-map");
  var radiusSelect = document.getElementById("spot-radius");
  var baseUrl = div.dataset.baseUrl;
  var global_id = div.dataset.globalId;
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
      this.bindPopup("lat: " + latlng.lat + "<br />lng: " + latlng.lng).openPopup();
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

  L.control.scale({ imperial: false }).addTo(map);

  L.control.layers(baseMaps, overlayMaps).addTo(map);

  map.setView(map.unproject([x, y], zoom), zoom);
}
