// OpacityLayerControl
L.Control.OpacityLayers = L.Control.Layers.extend({
    onAdd: function (map) {
      this._initLayout();
      this._update();

      this._map = map;
      map.on('zoomend', this._checkDisabledLayers, this);
      map.on('changeorder', this._onLayerChange, this);
      for (var i = 0; i < this._layers.length; i++) {
        this._layers[i].layer.on('add remove', this._onLayerChange, this);
      }

      return this._container;
    },
    onRemove: function () {
      this._map.off('zoomend', this._checkDisabledLayers, this);
      this._map.off('changeorder', this._onLayerChange, this);
      for (var i = 0; i < this._layers.length; i++) {
        this._layers[i].layer.off('add remove', this._onLayerChange, this);
      }
    },
    _initLayout: function(){
        L.Control.Layers.prototype._initLayout.call(this);
        base = $(this._container).find(".leaflet-control-layers-base");
        overlays = $(this._container).find(".leaflet-control-layers-overlays");
        separator = $(this._container).find(".leaflet-control-layers-separator");
        overlays.after(separator);
        separator.after(base);
    },
    _addLayer: function (layer, name, overlay) {
        if (this._map) {
          layer.on('add remove', this._onLayerChange, this);
        }

        this._layers.unshift({
          layer: layer,
          name: name,
          overlay: overlay
        });

        if (this.options.sortLayers) {
          this._layers.sort(Util.bind(function (a, b) {
            return this.options.sortFunction(a.layer, b.layer, a.name, b.name);
          }, this));
        }

        if (this.options.autoZIndex && layer.setZIndex) {
          this._lastZIndex++;
          layer.setZIndex(this._lastZIndex);
        }
        this._expandIfNotCollapsed();
    },
    _update: function() {
        if (!this._container) { return this; }

        L.DomUtil.empty(this._baseLayersList);
        L.DomUtil.empty(this._overlaysList);

        this._layerControlInputs = [];
        var baseLayersPresent, overlaysPresent, i, obj, baseLayersCount = 0;

        for (i = 0; i < this._layers.length; i++) {
          obj = this._layers[i];
          this._addItem(obj);
	  overlaysPresent = overlaysPresent || obj.overlay;
	  baseLayersPresent = baseLayersPresent || !obj.overlay;
          baseLayersCount += !obj.overlay ? 1 : 0;
        }

        // Hide base layers section if there's only one layer.
        if (this.options.hideSingleBase) {
          baseLayersPresent = baseLayersPresent && baseLayersCount > 1;
          this._baseLayersList.style.display = baseLayersPresent ? '' : 'none';
        }
        this._separator.style.display = overlaysPresent && baseLayersPresent ? '' : 'none';
        return this;
    },
    _addItem: function (obj) {
	//var row = L.DomUtil.create('div','leaflet-row');
        var label = document.createElement('label'),
            checked = this._map.hasLayer(obj.layer),
            input;

        if (obj.overlay) {
          input = document.createElement('input');
          input.type = 'checkbox';
          input.className = 'leaflet-control-layers-selector';
          input.defaultChecked = checked;
        } else {
          input = this._createRadioElement('leaflet-base-layers', checked);
        }

        this._layerControlInputs.push(input);
        input.layerId = L.Util.stamp(obj.layer);

        L.DomEvent.on(input, 'click', this._onInputClick, this);

        var name = document.createElement('span');
        name.innerHTML = ' ' + obj.name;
        //var col = L.DomUtil.create('div','leaflet-input');
        //col.appendChild(input);
        //row.appendChild(col);
        //var col = L.DomUtil.create('div', 'leaflet-name');
        //label.htmlFor = input.id;
        //col.appendChild(label);
        //row.appendChild(col);
        //label.appendChild(name);
        // Helps from preventing layer control flicker when checkboxes are disabled
        // https://github.com/Leaflet/Leaflet/issues/2771
        var holder = document.createElement('div');
        label.appendChild(holder);
        holder.appendChild(input);
        holder.appendChild(name);

        if (obj.overlay) {
          var up = L.DomUtil.create('div','leaflet-up');
          L.DomEvent.on(up, 'click', this._onUpClick, this);
          up.layerId = input.layerId;
          holder.appendChild(up);
          var down = L.DomUtil.create('div','leaflet-down');
          L.DomEvent.on(down, 'click', this._onDownClick, this);
          down.layerId = input.layerId;
          holder.appendChild(down);

          input = document.createElement('input');
          input.type = 'range';
          input.min = 0;
          input.max = 100;
          if (obj.layer && obj.layer.getLayers() && obj.layer.getLayers()[0]){
	      input.value = 100 * obj.layer.getLayers()[0].options.opacity
          } else {
            input.value = 100;
          }
          input.layerId = L.stamp(obj.layer);
          if (this._map.hasLayer(obj.layer)) {
              input.style.display = 'block';
          } else {
              input.style.display = 'none';
          }

          L.DomEvent.on(input, 'change', this._onInputClick, this);

          label.appendChild(input);

          
        }

        var container = obj.overlay ? this._overlaysList : this._baseLayersList;
        container.appendChild(label);

        this._checkDisabledLayers();


        return label;
    },
    _onUpClick: function(e){
      var layerId = e.currentTarget.layerId;
      var obj = this._getLayer(layerId);
      if(!obj.overlay){
        return;
      }
      replaceLayer = null;
      var zidx = this._getZIndex(obj);
      for(var i=0; i < this._layers.length; i++){
         ly = this._layers[i];
         var auxIdx = this._getZIndex(ly);
         if(ly.overlay && (zidx + 1) === auxIdx){
           replaceLayer = ly;
           break;
         }
      }

      var newZIndex = zidx + 1;
      if(replaceLayer){
        obj.layer.setZIndex(newZIndex);
        replaceLayer.layer.setZIndex(newZIndex - 1);
        this._layers.splice(i,1);
        this._layers.splice(i+1,0,replaceLayer);
        this._map.fire('changeorder', obj, this);
      }
    },
    _onDownClick: function(e){
      var layerId = e.currentTarget.layerId;
      var obj = this._getLayer(layerId);
      if(!obj.overlay){
        return;
      }
      replaceLayer = null;
      var zidx = this._getZIndex(obj);
      for(var i=0; i < this._layers.length; i++){
         ly = this._layers[i];
         layerId = L.Util.stamp(ly.layer);
         var auxIdx = this._getZIndex(ly);
         if(ly.overlay && (zidx - 1) === auxIdx){
           replaceLayer = ly;
           break;
         }
      }

      var newZIndex = zidx - 1;
      if(replaceLayer){
        obj.layer.setZIndex(newZIndex);
        replaceLayer.layer.setZIndex(newZIndex + 1);
        this._layers.splice(i,1);
        this._layers.splice(i-1,0,replaceLayer);
        this._map.fire('changeorder', obj, this);
      }
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
                opacity = input.value / 100.0;
		group_layers = obj.layer.getLayers();
		for (var j = 0; j < group_layers.length; j++){
		    var _layer = group_layers[j];
		    if (typeof _layer._url === 'undefined'){
		    } else {
			_layer.setOpacity(opacity);
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
	},
        _getZIndex: function(ly){
	  var zindex = 9999999999;
          if(ly.layer.options && ly.layer.options.zIndex){
	      zindex = ly.layer.options.zIndex;
          } else if (ly.layer.getLayers && ly.layer.eachLayer){
              ly.layer.eachLayer(function(lay){
	        if(lay.options && lay.options.zIndex){
		    zindex = Math.min(lay.options.zIndex, zindex);
                }
              });
          }
          return zindex;
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
  var addRadius = div.dataset.addRadius;
  var baseImage = JSON.parse(div.dataset.baseImage);
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
    //    layers: layers
  });
  
  if (_bounds){
    var bounds = L.latLngBounds([map.unproject(_bounds[0], 0), map.unproject(_bounds[1],0)]);
    //var layer = L.tileLayer(baseUrl + global_id + '/' + baseImage.id + '/{z}/{x}_{y}.png',{bounds: bounds});
  } else {
      //var layer = L.tileLayer(baseUrl + global_id + '/' + baseImage.id + '/{z}/{x}_{y}.png');
  }
  var layer = L.tileLayer(baseUrl + global_id + '/' + baseImage.id + '/{z}/{x}_{y}.png',{maxNativeZoom: 6});
  layers.push(layer);
  baseMaps[baseImage.name] = layer;
  layer.addTo(map);
  layerGroups.concat([{ name: "", opacity: 100 }]).forEach(function(layerGroup) {
    var group = L.layerGroup(), name = layerGroup.name, opacity = layerGroup.opacity / 100.0;
    if (images[name]) {
      images[name].forEach(function(id) {
	opts = {};
	if (bounds){
	    opts = {opacity: opacity, bounds: bounds, maxNativeZoom: 6};
        } else {
	    opts = {opacity: opacity, maxNativeZoom: 6}
        }
	L.tileLayer(baseUrl + global_id + '/' + id + '/{z}/{x}_{y}.png', opts).addTo(group);
      });
      layers.push(group);
      group.addTo(map);
      if (name === "") { name = "top"; }
      overlayMaps[name] = group;
    }
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

  L.control.surfaceScale({ imperial: false, length: length }).addTo(map);

  //L.control.layers(baseMaps, overlayMaps).addTo(map);
  L.control.opacityLayers(baseMaps, overlayMaps, {hideSingleBase: false}).addTo(map);
  
  if (bounds){
      //var bounds = L.latLngBounds([map.unproject(_bounds[0], 0), map.unproject(_bounds[1],0)]);
    map.fitBounds(bounds);
  } else {
    map.setView(map.unproject([256 / 2, 256 / 2], 0), zoom);
  }
  map.addControl(new L.Control.Fullscreen());

  surfaceMap = map;
}
