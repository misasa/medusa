function initSurfaceMap() {
  var div = document.getElementById("surface-map");
  var baseUrl = div.dataset.baseUrl;
  var global_id = div.dataset.globalId;
  var attachment_files = JSON.parse(div.dataset.attachmentFiles);
  var spots = JSON.parse(div.dataset.spots);
  var layers = [];
  var baseMaps = {};
  var overlayMaps = {};
  var circles = [];
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
    var circle = L.circle([-spot.y, spot.x], {
      color: 'red',
      fillColor: '#f03',
      fillOpacity: 0.5,
      radius: 5,
    });
    circle.id = spot.id;
    circle.on("click", function() {
      target = this;
      $.get("/spots/" + this.id + "/analysis", {}, null, "json").done(function(data) {
	if(data) {
          var text = data.name;
	  $.each(data.chemistries, function(idx, chemistry) {
            text = text + "<br />" + chemistry.measurement_item.nickname + ": " + chemistry.value + chemistry.unit.html;
	  });
          target.bindPopup(text, { maxHeight: 50 }).openPopup();
        }
      });
    });
    circles.push(circle);
    circle.addTo(circlesLayer);
  }
  layers.push(circlesLayer);

  var map = L.map('surface-map', {
    maxZoom: 8,
    minZoom: 0,
    crs: L.CRS.Simple,
    layers: layers
  });
  L.control.layers(baseMaps, overlayMaps).addTo(map);
  map.setView(map.unproject([x, y], zoom), zoom);
}
