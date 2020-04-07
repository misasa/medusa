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

        this._layers.push({
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
          if (obj.layer && obj.layer.getLayers() && obj.layer.getLayers()[0]){
	          checked  = obj.layer.getLayers()[0].options.visible;
          }
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
          this._layerControlInputs.push(input);
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
        //container.appendChild(label);
        container.prependChild(label);
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

      if(replaceLayer){
        var newZIndex = zidx + 1;
        obj.layer.setZIndex(newZIndex);
        replaceLayer.layer.setZIndex(newZIndex - 1);
        var removed = this._layers.splice(zidx,1);
        this._layers.splice(zidx-1,0,replaceLayer);
        url = obj.layer.getLayers()[0].options.resource_url + '/move_lower.json';
        console.log('POST ' + url);
        $.ajax(url,{
          type: 'POST',
          data: {},
          complete: function(e){ console.log('ok'); },
          error: function(e) { console.log(e); }
        });
        //this._map.fire('changeorder', obj, this);
      }
      this._map.fire('changeorder', obj, this);
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

      if(replaceLayer){
        var newZIndex = zidx - 1;
        obj.layer.setZIndex(newZIndex);
        replaceLayer.layer.setZIndex(newZIndex + 1);
        var removed = this._layers.splice(newZIndex-1,1);
        this._layers.splice(newZIndex,0,replaceLayer);
        url = obj.layer.getLayers()[0].options.resource_url + '/move_higher.json';
        console.log('POST ' + url);
        $.ajax(url,{
          type: 'POST',
          data: {},
          complete: function(e){ console.log('ok'); },
          error: function(e) { console.log(e); }
        });
        //this._map.fire('changeorder', obj, this);
      }
      this._map.fire('changeorder', obj, this);
    },
    _onLayerChecked: function (obj){
      //console.log("LayerChecked.");
      if (obj.layer && obj.layer.getLayers() && obj.layer.getLayers()[0]){
        url = obj.layer.getLayers()[0].options.resource_url + '/check.json';
        console.log('PUT ' + url);
        $.ajax(url,{
          type: 'PUT',
          data: {},
          //beforeSend: function(e){ map.spin(true, {color: '#ffffff'}); console.log('saving...') },
          complete: function(e){ console.log('ok'); },
          error: function(e) { console.log(e); }
        });
      }
    },
    _onLayerUnChecked: function (obj){
      //console.log("LayerUnChecked.");
      if (obj.layer && obj.layer.getLayers() && obj.layer.getLayers()[0]){
        url = obj.layer.getLayers()[0].options.resource_url + '/uncheck.json';
        console.log('PUT ' + url);
        $.ajax(url,{
          type: 'PUT',
          data: {},
          //beforeSend: function(e){ map.spin(true, {color: '#ffffff'}); console.log('saving...') },
          complete: function(e){ console.log('ok'); },
          error: function(e) { console.log(e); }
        });
      }
    },
    _onOpacityChanged: function (obj, opacity){
      //console.log("OpacityChanged.");
      opacity = parseFloat(opacity) * 100;
      if (obj.layer && obj.layer.getLayers() && obj.layer.getLayers()[0]){
        url = obj.layer.getLayers()[0].options.resource_url + '.json';
        console.log('PUT ' + url);
        $.ajax(url,{
          type: 'PUT',
          data: {surface_layer: {opacity: opacity}},
          complete: function(e){ console.log('ok'); },
          error: function(e) { console.log(e); }
        });
      }
    },
    _onInputClick: function () {
        var i, input, obj;
        //inputs = this._form.getElementsByTagName('input');
        var inputs = this._layerControlInputs;
        var inputsLen = inputs.length;
        var addedLayers = [],
        removedLayers = [];

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
                    _opacity = _layer.options.opacity;
                    if (_opacity != opacity){
                      _layer.setOpacity(opacity);
                      this._onOpacityChanged(obj,opacity);
                    }
		              }
		            }
                continue;
            } else if (input.type == 'range' && !this._map.hasLayer(obj.layer)) {
                input.style.display = 'none';
                continue;
            }

            if (input.checked && !this._map.hasLayer(obj.layer)) {
                this._map.addLayer(obj.layer);
                if (obj.overlay){
                  obj.layer.getLayers()[0].options.visible = true;
                  this._onLayerChecked(obj);
                }
            } else if (!input.checked && this._map.hasLayer(obj.layer)) {
                this._map.removeLayer(obj.layer);
                if (obj.overlay){
                  obj.layer.getLayers()[0].options.visible = false;
                  this._onLayerUnChecked(obj);
                }
              } //end if
        } //end loop

        for (var i = inputs.length - 1; i >= 0; i--) {
          input = inputs[i];
          layer = this._getLayer(input.layerId).layer;
    
          if (input.checked) {
            addedLayers.push(layer);
          } else if (!input.checked) {
            removedLayers.push(layer);
          }
        }        

		    // Bugfix issue 2318: Should remove all old layers before readding new ones
		    for (i = 0; i < removedLayers.length; i++) {
			    if (this._map.hasLayer(removedLayers[i])) {
				    this._map.removeLayer(removedLayers[i]);
			    }
		    }
		    for (i = 0; i < addedLayers.length; i++) {
			    if (!this._map.hasLayer(addedLayers[i])) {
				    this._map.addLayer(addedLayers[i]);
			    }
		    }

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


L.Control.ViewMeta = L.Control.extend({
  options: {
      position: `topright`,
      placeholderHTML: `-----`
  },

  onRemove: function () {
    L.DomUtil.remove(this.container);
  },

  onAdd: function (map) {
    this.map = map;

    this.container = L.DomUtil.create(`div`, `leaflet-view-meta`);  
    L.DomEvent.disableClickPropagation(this.container);
    L.DomEvent.on(this.container, `control_container`, function (e) {
        L.DomEvent.stopPropagation(e);
    });
    L.DomEvent.disableScrollPropagation(this.container);

    let table = L.DomUtil.create(
        `table`,
        `leaflet-view-meta-table`,
        this.container
    );

    // map center
    this.addDividerRow(table, `Zoom`);
    this.z_e = this.addDataRow(table, `Level`);
    this.m_e = this.addDataRow(table, `Magnification`);
    this.addDividerRow(table, `Center`);
    //this.lat_e = this.addDataRow(table, `Latitude`);
    //this.lng_e = this.addDataRow(table, `Longitude`);
    this.x_e = this.addDataRow(table, `X`);
    this.y_e = this.addDataRow(table, `Y`);
    this.addDividerRow(table, `Dimension`);
    this.w_e = this.addDataRow(table, `Width`);
    this.h_e = this.addDataRow(table, `Height`);
    this.addDividerRow(table, `Bounds`);
    //this.nb_e = this.addDataRow(table, `Northern Bound`);
    //this.sb_e = this.addDataRow(table, `Southern Bound`);
    //this.eb_e = this.addDataRow(table, `Eastern Bound`);
    //this.wb_e = this.addDataRow(table, `Western Bound`);
    this.lb_e = this.addDataRow(table, `Left`);
    this.rb_e = this.addDataRow(table, `Right`);
    this.bb_e = this.addDataRow(table, `Bottom`);
    this.tb_e = this.addDataRow(table, `Top`);

    this.map.on(`resize`, () => this.update());
    this.map.on(`zoomend`, () => this.update());
    this.map.on(`dragend`, () => this.update());

    this.urlParams = new URLSearchParams(window.location.search);
    this.parseParams();

    return this.container;
  },    

  addDividerRow: function (tableElement, labelString) {
    let tr = tableElement.insertRow();
    let tdDivider = tr.insertCell();
    tdDivider.colSpan = 2;
    tdDivider.innerText = labelString;
},

addDataRow: function (tableElement, labelString) {
    let tr = tableElement.insertRow();
    let tdLabel = tr.insertCell();
    tdLabel.innerText = labelString;
    let tdData = tr.insertCell();
    tdData.innerHTML = this.options.placeholderHTML;
    return tdData;
},

parseParams: function () {
    var opts = this.options;
    let x, y, z, lat, lng, nb, wb, sb, eb, nw_bound, se_bound, bounds;
    try {
        x = +this.urlParams.get("x").replace(/,/g, '');
        y = +this.urlParams.get("y").replace(/,/g, '');
        z = +this.urlParams.get("z");


        if (x && y && opts.world2latLng){
          ll = opts.world2latLng([x, y])
          this.map.setView(ll, z);
        } else { 
          lat = +this.urlParams.get("lat");
          lng = +this.urlParams.get("lng");          
          if (lat && lng) {
            this.map.panTo(new L.LatLng(lat, lng));
          }

          nb = +this.urlParams.get("nb");
          wb = +this.urlParams.get("wb");
          sb = +this.urlParams.get("sb");
          eb = +this.urlParams.get("eb");

          if (nb && sb && eb && wb) {
            nw_bound = L.latLng(nb, wb);
            se_bound = L.latLng(sb, eb);

            bounds = L.latLngBounds(nw_bound, se_bound);

            this.map.fitBounds(bounds);
          }
        }
    } catch (e) {
        console.log(e);
    }
  },  
  update: function () {
    var opts = this.options;
    var center_xy;
    let center = this.map.getCenter();
    let bounds = this.map.getBounds();
    let zoom = this.map.getZoom();
    let latStr = this.formatNumber(center.lat);
    let lngStr = this.formatNumber(center.lng);

    let nbStr = this.formatNumber(bounds.getNorth());
    let sbStr = this.formatNumber(bounds.getSouth());
    let ebStr = this.formatNumber(bounds.getEast());
    let wbStr = this.formatNumber(bounds.getWest());
    let zStr = String(zoom);
    this.z_e.innerText = zStr;
    //this.lat_e.innerText = latStr;
    //this.lng_e.innerText = lngStr;

    //this.nb_e.innerText = nbStr;
    //this.sb_e.innerText = sbStr;
    //this.eb_e.innerText = ebStr;
    //this.wb_e.innerText = wbStr;

    //this.urlParams.set("lat", latStr);
    //this.urlParams.set("lng", lngStr);

    //this.urlParams.set("nb", nbStr);
    //this.urlParams.set("sb", sbStr);
    //this.urlParams.set("eb", ebStr);
    //this.urlParams.set("wb", wbStr);

    if (opts.latLng2world){
      world_c = opts.latLng2world(center);
      ne = {lat: bounds.getNorth(), lng: bounds.getEast()};
      sw = {lat: bounds.getSouth(), lng: bounds.getWest()};
      world_ne = opts.latLng2world(ne);
      world_sw = opts.latLng2world(sw);
      world_w = world_ne[0] - world_sw[0];
      world_h = world_ne[1] - world_sw[1];
      mag = 120000/world_w;
      let xStr = this.formatNumber(world_c[0]);
      let yStr = this.formatNumber(world_c[1]);
      let tbStr = this.formatNumber(world_ne[1]);
      let rbStr = this.formatNumber(world_ne[0]);
      let bbStr = this.formatNumber(world_sw[1]);
      let lbStr = this.formatNumber(world_sw[0]);
      let hStr = this.formatNumber(world_h);
      let wStr = this.formatNumber(world_w);
      let mStr = this.formatNumber(mag);
      this.m_e.innerText = mStr;
      this.x_e.innerText = xStr;
      this.y_e.innerText = yStr;  
      this.w_e.innerText = wStr;
      this.h_e.innerText = hStr;  
      this.tb_e.innerText = tbStr;
      this.bb_e.innerText = bbStr;  
      this.rb_e.innerText = rbStr;
      this.lb_e.innerText = lbStr;  
      this.urlParams.set("x", xStr.replace(/,/g, ''));
      this.urlParams.set("y", yStr.replace(/,/g, ''));
      this.urlParams.set("z", zStr);
    }
    window.history.replaceState(
        {},
        "",
        `?${this.urlParams.toString()}`
    );
  },

  formatNumber: function (num) {
    return num.toLocaleString({
        minimumFractionDigits: 3,
        maximumFractionDigits: 3
    });
  }  
});  

L.control.viewMeta = function (options) {
  return new L.Control.ViewMeta(options);
};

function initSurfaceMap() {
  var div = document.getElementById("surface-map");
  var radiusSelect = document.getElementById("spot-radius");
  var baseUrl = div.dataset.baseUrl;
  var resourceUrl = div.dataset.resourceUrl;
  var urlRoot = div.dataset.urlRoot;
  var global_id = div.dataset.globalId;
  var length = parseFloat(div.dataset.length);
  var center = JSON.parse(div.dataset.center);
  //var matrix = JSON.parse(div.dataset.matrix);
  //var addSpot = JSON.parse(div.dataset.addSpot);
  //var addRadius = div.dataset.addRadius;
  var baseImages = JSON.parse(div.dataset.baseImages);
  var layerGroups = JSON.parse(div.dataset.layerGroups);
  var images = JSON.parse(div.dataset.images);
  //var spots = JSON.parse(div.dataset.spots);
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
    //crs: L.CRS.Simple,
    //    layers: layers
  });

  var latLng2world = function(latLng){
    point = map.project(latLng,0)
    ratio = 2*20037508.34/length
    x = center[0] - length/2.0 + point.x * length/256;
    y = center[1] + length/2.0 - point.y * length/256;
    return [x, y]
  };

  var world2latLng = function(world){
      x_w = world[0];
      y_w = world[1];
      x = (x_w - center[0] + length/2.0)*256/length
      y = (-y_w + center[1] + length/2.0)*256/length
      latLng = map.unproject([x,y],0)
      return latLng;
  };

  var worldBounds = function(world_bounds){
      return L.latLngBounds([world2latLng([world_bounds[0], world_bounds[1]]),world2latLng([world_bounds[2], world_bounds[3]])]);
  };

  var map_LabelFcn = function(ll, opts){
    lng =L.NumberFormatter.round(ll.lng, opts.decimals, opts.decimalSeperator);
    lat = L.NumberFormatter.round(ll.lat, opts.decimals, opts.decimalSeperator);
    point = map.project(ll,0)
    xy_str = "x: " + point.x + " y: " + point.y;
    world = latLng2world(ll);
    gxy_str = "x_vs: " + world[0] + " y_vs: " + world[1];
    lngLat_str = "lng:" + lng + " lat:" + lat;
    str = gxy_str + " " + xy_str + " " + lngLat_str;
    return str;
  };
  //map.addControl(new L.Control.Coordinates({position: 'topright', customLabelFcn:map_LabelFcn}));

  
  if (_bounds){
      var bounds = worldBounds(_bounds);
  }
  var baseCount = 0;
  baseImages.forEach(function(baseImage) {
    var opts = {maxNativeZoom: 6}

    if (baseImage.bounds){
	    opts = Object.assign(opts, {bounds: worldBounds(baseImage.bounds)});
    }
    if (baseImage.max_zoom){
	    opts = Object.assign(opts, {maxNativeZoom: baseImage.max_zoom});
    }

    var layer = L.tileLayer(baseUrl + global_id + '/' + baseImage.id + '/{z}/{x}_{y}.png',opts);
    layers.push(layer);
    baseMaps[baseImage.name] = layer;
    baseCount += 1;
    //layer.addTo(map);
  });
  if (baseCount > 0){
    layers[baseCount - 1].addTo(map);
  }
  layerGroups.concat([{ name: "", opacity: 100 }]).forEach(function(layerGroup) {
    var group = L.layerGroup(), name = layerGroup.name, opacity = layerGroup.opacity / 100.0, visible = layerGroup.visible, resource_url = layerGroup.resource_url;
    opts = {opacity: opacity, maxNativeZoom: 6, visible: visible, resource_url: resource_url};

    if (layerGroup.tiled){
      if (layerGroup.bounds){
        opts = Object.assign(opts, {bounds: worldBounds(layerGroup.bounds)});
      }
      if (layerGroup.max_zoom){
        opts = Object.assign(opts, {maxNativeZoom: layerGroup.max_zoom})
      }
      L.tileLayer(baseUrl + global_id + '/layers/' + layerGroup.id + '/{z}/{x}_{y}.png', opts).addTo(group);
      layers.push(group);
      if (visible){
        group.addTo(map);
      }
      if (name === "") { name = "top"; }
        overlayMaps[name] = group;
    } else {
      if (images[name]) {
        images[name].forEach(function(image) {
	        if (image.bounds){
            opts = Object.assign(opts, {bounds: worldBounds(image.bounds)});
          }
          if (image.max_zoom){
	          opts = Object.assign(opts, {maxNativeZoom: image.max_zoom})
          }
	        L.tileLayer(baseUrl + global_id + '/' + image.id + '/{z}/{x}_{y}.png', opts).addTo(group);
        });
        layers.push(group);
        if (visible){
          group.addTo(map);
        }
        if (name === "") { name = "top"; }
        overlayMaps[name] = group;
      }
    }
  });

  var spotsLayer = L.layerGroup();
  map.addLayer(spotsLayer);
  loadMarkers();

  L.control.surfaceScale({ imperial: false, length: length }).addTo(map);

  //L.control.layers(baseMaps, overlayMaps).addTo(map);
  L.control.opacityLayers(baseMaps, overlayMaps).addTo(map);
  if (bounds){
    map.fitBounds(bounds);
  } else {
    map.setView(map.unproject([256 / 2, 256 / 2], 0), zoom);
  }
  map.addControl(new L.Control.Fullscreen());

  function loadMarkers() {
      var url = resourceUrl + '/spots.json';
      $.get(url, {}, function(data){
        spotsLayer.clearLayers();
	      $(data).each(function(){
		      var spot = this; 
          var pos = world2latLng([spot.world_x, spot.world_y]);
          //var options = { draggable: true, color: 'blue', fillColor: '#f03', fillOpacity: 0.5, radius: 200 };
          var options = { draggable: true, title: spot['name'] };
          var marker = new L.marker(pos, options).addTo(spotsLayer);
          var popupContent = [];
          popupContent.push("<nobr>" + spot['name_with_id'] + "</nobr>");
          popupContent.push("<nobr>coordinate: (" + spot['world_x'] + ", " + spot["world_y"] + ")</nobr>");
          if (spot['attachment_file_id']){
            var image_url = resourceUrl + '/images/' + spot['attachment_file_id'];
            popupContent.push("<nobr>image: <a href=" + image_url + ">" + spot['attachment_file_name'] +  "</a>"+ "</nobr>");
          }
          if (spot['target_uid']){
            popupContent.push("<nobr>link: " + spot['target_link'] +  "</nobr>");
          }
          marker.bindPopup(popupContent.join("<br/>"), {
            maxWidth: "auto",
          });  
	      });
      });
  }

  var marker;
  var toolbarAction = L.Toolbar2.Action.extend({
	  options: {
	    toolbarIcon: {
		    html: '<svg class="svg-icons"><use xlink:href="#restore"></use><symbol id="restore" viewBox="0 0 18 18"><path d="M18 7.875h-1.774c-0.486-3.133-2.968-5.615-6.101-6.101v-1.774h-2.25v1.774c-3.133 0.486-5.615 2.968-6.101 6.101h-1.774v2.25h1.774c0.486 3.133 2.968 5.615 6.101 6.101v1.774h2.25v-1.774c3.133-0.486 5.615-2.968 6.101-6.101h1.774v-2.25zM13.936 7.875h-1.754c-0.339-0.959-1.099-1.719-2.058-2.058v-1.754c1.89 0.43 3.381 1.921 3.811 3.811zM9 10.125c-0.621 0-1.125-0.504-1.125-1.125s0.504-1.125 1.125-1.125c0.621 0 1.125 0.504 1.125 1.125s-0.504 1.125-1.125 1.125zM7.875 4.064v1.754c-0.959 0.339-1.719 1.099-2.058 2.058h-1.754c0.43-1.89 1.921-3.381 3.811-3.811zM4.064 10.125h1.754c0.339 0.959 1.099 1.719 2.058 2.058v1.754c-1.89-0.43-3.381-1.921-3.811-3.811zM10.125 13.936v-1.754c0.959-0.339 1.719-1.099 2.058-2.058h1.754c-0.43 1.89-1.921 3.381-3.811 3.811z"></path></symbol></svg>',
		    tooltip: 'Add spot'
	    }
	  },
	  addHooks: function (){
	      if(marker !== undefined){
		      map.removeLayer(marker);
	      }
	      var pos = map.getCenter();
	      var icon = L.icon({
		      iconUrl: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACMAAAAjCAYAAAAe2bNZAAAAAXNSR0IArs4c6QAAAAZiS0dEAP8A/wD/oL2nkwAAAAlwSFlzAAALEwAACxMBAJqcGAAAAHVJREFUWMPt1rENgDAMRNEPi3gERmA0RmAERgmjsAEjhMY0dOBIWHCWTulOL5UN8VmACpRoUdcAU1v19SQaYYQRRhhhhMmIMV//9WGuG/xudmA6C+YApGUGgNF1b0KKjithhBFGGGGE+Rtm9XfL8CHzS8340hzaXWaR1yQVAAAAAABJRU5ErkJggg==',
		      iconSize:     [32, 32],
		      iconAnchor:   [16, 16]
	      });
        var world = latLng2world(pos);
	      marker = new L.marker(pos,{icon: icon, draggable:true}).addTo(map);
	      var popupContent = '<form role="form" id="addspot-form" class="form" enctype="multipart/form-data">' +
	        '<div class="form-group">' +
	        '<label class="control-label">Name:</label>' +
	        '<input type="string" placeholder="untitled spot" id="name"/>' +
	        '</div>' +
	        '<div class="form-group">' +
	        '<label class="control-label">link ID:</label>' +
	        '<input type="string" placeholder="type here" id="target_uid"/>' +
	        '</div>' +
	        '<div class="form-group">' +
	        '<div style="text-align:center;">' +
	        '<button type="submit">Save</button></div>' +
	        '</div>' +
	        '</form>';
        marker.bindPopup(popupContent, {
			    maxWidth: "auto",
		    }).openPopup();
        $('body').on('submit', '#addspot-form', mySubmitFunction);
        function mySubmitFunction(e){
		      e.preventDefault();
		      console.log("didnt submit");
		      var form = document.querySelector('#addspot-form');
          var ll = marker.getLatLng();
          var world = latLng2world(ll);
          var url = resourceUrl + '/spots.json';
		      $.ajax(url,{
			      type: 'POST',
				    data: {spot:{name: form['name'].value, target_uid: form['target_uid'].value, world_x: world[0], world_y: world[1]}},
			      beforeSend: function(e) {console.log('saving...')},
			      complete: function(e){ 
				      marker.remove();
				      loadMarkers();
			      },
			      error: function(e) {console.log(e)}
		      })
        }
	  }
  });
  new L.Toolbar2.Control({
    position: 'topleft',
    actions: [toolbarAction]
  }).addTo(map);
  var myFcn = function(center){
    console.log("hello myFcn");
    return [0,0]
  }
  L.control.viewMeta({position: `bottomleft`, latLng2world: latLng2world, world2latLng: world2latLng, customLabelFcn: map_LabelFcn}).addTo(map);
  surfaceMap = map;
}
