function initMapImageCalibrator() {
  var div = document.getElementById("surface-map");
  var radiusSelect = document.getElementById("spot-radius");
  var baseUrl = div.dataset.baseUrl;
  var urlRoot = div.dataset.urlRoot;
  var global_id = div.dataset.globalId;
  var length = parseFloat(div.dataset.length);
  var matrix = JSON.parse(div.dataset.matrix);
  var addSpot = JSON.parse(div.dataset.addSpot);
  var addRadius = div.dataset.addRadius;
  var baseImages = JSON.parse(div.dataset.baseImages);
  var layerGroups = JSON.parse(div.dataset.layerGroups);
  var images = JSON.parse(div.dataset.images);
  var spots = JSON.parse(div.dataset.spots);
  if (("bounds" in div.dataset)){
    var _bounds = JSON.parse(div.dataset.bounds);
  }
  var layers = [];
  var baseMaps = {};
  var overlayMaps = {};
  var zoom = 1;

  var map = L.map('surface-map', {
    maxZoom: 14,
    minZoom: 0,
    crs: L.CRS.Simple,
  });

  if (_bounds){
    var bounds = L.latLngBounds([map.unproject(_bounds[0], 0), map.unproject(_bounds[1],0)]);
    //var layer = L.tileLayer(baseUrl + global_id + '/' + baseImage.id + '/{z}/{x}_{y}.png',{bounds: bounds});
  } else {
      //var layer = L.tileLayer(baseUrl + global_id + '/' + baseImage.id + '/{z}/{x}_{y}.png');
  }
  baseImages.forEach(function(baseImage) {
    var opts = {maxNativeZoom: 6}

    if (baseImage.bounds){
	opts = Object.assign(opts, {bounds: L.latLngBounds([map.unproject(baseImage.bounds[0], 0), map.unproject(baseImage.bounds[1],0)])});
    }
    if (baseImage.max_zoom){
	opts = Object.assign(opts, {maxNativeZoom: baseImage.max_zoom});
    }

    var layer = L.tileLayer(baseUrl + global_id + '/' + baseImage.id + '/{z}/{x}_{y}.png',opts);
    layers.push(layer);
    baseMaps[baseImage.name] = layer;
    layer.addTo(map);
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

  //overlayMaps['grid'] = L.layerGroup.grid(map, length);
  if (addRadius) {
    var radiusControl = L.control.radius(spotsLayer, {position: 'bottomright'}).addTo(map);
  }

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

  //L.control.surfaceScale({ imperial: false, length: length }).addTo(map);

  L.control.layers(baseMaps,{}).addTo(map);
  
  if (bounds){
      //var bounds = L.latLngBounds([map.unproject(_bounds[0], 0), map.unproject(_bounds[1],0)]);
    map.fitBounds(bounds);
  } else {
    map.setView(map.unproject([256 / 2, 256 / 2], 0), zoom);
  }
  map.addControl(new L.Control.Fullscreen());
  if (("zoomlabel" in div.dataset)){
    L.control.zoomLabel().addTo(map);
  }

  imgActionArray = function(){
      return [ToggleTransparency, ToggleOutline, ToggleLock, ToggleRotateScale, ToggleOrder, Restore, SaveImageAction];
  };

  
  var SaveImageAction = L.EditAction.extend({
	  initialize: function (map, overlay, options){
	      var href = '<use xlink:href="/assets/icons/symbol/sprite.symbol.svg#get_app"></use>';
              options = options || {};
              options.toolbarIcon = {
		  html: '<svg>' + href + '</svg>',
		  tooltip: 'Save Image'
	      };
	      L.EditAction.prototype.initialize.call(this, map, overlay, options);
	  },
	  addHooks: function(){
	      var img = this._overlay;
              saveImage.bind(img)();
	  }
  });
 
  saveImage = function(){
      var img = this;
      var corners_on_map = [];
      img._corners.forEach(function(_corner){
        corners_on_map.push(map.project(_corner,0))
      });
      $.ajax(img.resource_url + ".json",{
        type: 'PUT',
	data: {surface_image: 
		  {corners_on_map:
		      corners_on_map[0].x + ',' + corners_on_map[0].y + ':' +
		      corners_on_map[1].x + ',' + corners_on_map[1].y + ':' +
		      corners_on_map[3].x + ',' + corners_on_map[3].y + ':' +
		      corners_on_map[2].x + ',' + corners_on_map[2].y,
		  }
	},
	beforeSend: function(e){ console.log('saving...')},
        complete: function(e){ 'ok' },
	error: function(e) {console.log(e)}
      })
  }; 
  var imgs = [];
  layerGroups.concat([{ name: "", opacity: 100 }]).forEach(function(layerGroup) {
    var group = L.layerGroup(), name = layerGroup.name, opacity = layerGroup.opacity / 100.0;
    if (images[name]) {
      image = images[name][0];
      opts = {actions: imgActionArray(), corners: [L.latLng(map.unproject(image.corners[0],0)),L.latLng(map.unproject(image.corners[1],0)),L.latLng(map.unproject(image.corners[3],0)),L.latLng(map.unproject(image.corners[2],0))]}
      img = L.distortableImageOverlay(image.path,opts).addTo(map);
      
      //L.DomEvent.on(img._image, 'load', img.editing.enable, img.editing);
      imgs.push(img);
      img.warpable_id = image.id
      img.resource_url = image.resource_url
      img.addTo(map)
    }
  });
  imgGroup = L.distortableCollection().addTo(map);
  imgs.forEach(function(img){
    imgGroup.addLayer(img);
  });



  surfaceMap = map;
}