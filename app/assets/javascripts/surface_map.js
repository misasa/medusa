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
          var detail = document.createElement('div');
          label.appendChild(detail);
          detail.className = 'leaflet-control-layers-detail';
          detail.setAttribute('leaflet_id', obj.layer._leaflet_id);
          if (this._map.hasLayer(obj.layer)) {
            detail.style.display = 'block';
          } else {
            detail.style.display = 'none';
          }

          input = document.createElement('input');
          input.type = 'range';
          input.className = 'leaflet-control-layers-opacity';
          input.setAttribute('leaflet_id', obj.layer._leaflet_id);
          input.min = 0;
          input.max = 100;
          if (obj.layer && obj.layer.getLayers() && obj.layer.getLayers()[0]){
	          input.value = 100 * obj.layer.getLayers()[0].options.opacity
          } else {
            input.value = 100;
          }
          this._layerControlInputs.push(input);
          input.layerId = L.stamp(obj.layer);
          L.DomEvent.on(input, 'change', this._onInputClick, this);

          detail.appendChild(input);
          glayers = Object.values(obj.layer._layers);
          if (glayers.some(layer => typeof layer.setColorScale === "function")){
            fits_layres = glayers.filter(layer => typeof layer.options.renderer !== 'undefined');
            var ploty_options = fits_layres[0].options.renderer.options;
            var select = document.createElement("select");
            select.layerId = L.stamp(obj.layer);
            select.className = 'leaflet-control-layers-colorScale';
            select.setAttribute('leaflet_id', obj.layer._leaflet_id);  
            select.add( (new Option("Rainbow","rainbow")) );
            select.add( (new Option("Viridis","viridis")) );
            select.add( (new Option("Greys","greys")) );
            select.value = ploty_options.colorScale;
            //L.DomEvent.on(select, 'change', this._onSelectClick, this);
            select.onchange = function (e){
              var value = select.value;
              //obj.layer.getLayers(select.layerId)[0].setColorScale(value);
              glayers =  obj.layer.getLayers(select.layerId);
              for (i = 0; i < glayers.length; i++) {
                glayer = glayers[i];
                if (typeof glayer.setColorScale === "function") { 
                // safe to use the function
                  glayer.setColorScale(value);
                }
              }
            }
            detail.appendChild(select);

            var displayMin = document.createElement("input");
            displayMin.type = 'textinput';
            displayMin.value = ploty_options.displayMin;
            displayMin.layerId = L.stamp(obj.layer);
            displayMin.style.cssText = 'width: 50px; height: 19px';
            displayMin.onchange = function (e){
              var min = displayMin.value;
              var max = displayMax.value;
              glayers =  Object.values(obj.layer._layers);
              for (i = 0; i < glayers.length; i++) {
                glayer = glayers[i];
                if (typeof glayer.setDisplayRange === "function") { 
                // safe to use the function
                  glayer.setDisplayRange(min, max);
                }
              }        
            }
            detail.appendChild(displayMin);

            var displayMax = document.createElement("input");
            displayMax.type = 'textinput';
            displayMax.value = ploty_options.displayMax;
            displayMax.style.cssText = 'width: 50px; height: 19px';
            displayMax.onchange = function (e){
              var max = displayMax.value;
              var min = displayMin.value;
              glayers =  Object.values(obj.layer._layers);
              for (i = 0; i < glayers.length; i++) {
                glayer = glayers[i];
                if (typeof glayer.setDisplayRange === "function") { 
                // safe to use the function
                  glayer.setDisplayRange(min, max);
                }
              }        
            }
            detail.appendChild(displayMax);

          }
        }

        var container = obj.overlay ? this._overlaysList : this._baseLayersList;
        //container.appendChild(label);
        container.prependChild(label);
        this._checkDisabledLayers();


        return label;
    },
    _onChangeDisplayRange: function(obj, min, max){
      glayers =  Object.values(obj.layer._layers);
      for (i = 0; i < glayers.length; i++) {
        glayer = glayers[i];
        if (typeof glayer.setDisplayRange === "function") { 
        // safe to use the function
          glayer.setDisplayRange(min, max);
        }
      }
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
      $(".leaflet-control-layers-detail[leaflet_id='" + obj.layer._leaflet_id + "']").css('display','block')
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
      $(".leaflet-control-layers-detail[leaflet_id='" + obj.layer._leaflet_id + "']").css('display','none')
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
    _onInputClick: function (e) {
      var layerId = e.currentTarget.layerId;
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
                //input.style.display = 'none';
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
    this.addDividerRow(table, `Current View`);
    if (this.options.enableUserInput){
      this.ix_e = this.addInputRow(table, `X (μm)`, "inputX");
      this.iy_e = this.addInputRow(table, `Y (μm)`,"inputY");
    } else {
      this.x_e = this.addDataRow(table, `X (μm)`);
      this.y_e = this.addDataRow(table, `Y (μm)`);  
    }
    //this.addDividerRow(table, `Zoom`);
    if (this.options.enableUserInput){
      this.iz_e = this.addInputRow(table, `Zoom (level)`, "inputZ");
    } else {
      this.z_e = this.addDataRow(table, `Zoom (level)`);
    }
    this.w_e = this.addDataRow(table, `Width (μm)`);
    this.h_e = this.addDataRow(table, `Height (μm)`);
    this.m_e = this.addDataRow(table, `Magnification`);
    //this.addDividerRow(table, `Dimension`);
    //this.addDividerRow(table, `Bounds`);
    //this.nb_e = this.addDataRow(table, `Northern Bound`);
    //this.sb_e = this.addDataRow(table, `Southern Bound`);
    //this.eb_e = this.addDataRow(table, `Eastern Bound`);
    //this.wb_e = this.addDataRow(table, `Western Bound`);
    //this.lb_e = this.addDataRow(table, `Left`);
    //this.rb_e = this.addDataRow(table, `Right`);
    //this.bb_e = this.addDataRow(table, `Bottom`);
    //this.tb_e = this.addDataRow(table, `Top`);
    if (this.options.enableUserInput){
      L.DomEvent.on(this.iz_e, 'keyup', this._handleKeypress, this);
      L.DomEvent.on(this.iz_e, 'blur', this._handleSubmit, this);
      L.DomEvent.on(this.ix_e, 'keyup', this._handleKeypress, this);
      L.DomEvent.on(this.ix_e, 'blur', this._handleSubmit, this);
      L.DomEvent.on(this.iy_e, 'keyup', this._handleKeypress, this);  
      L.DomEvent.on(this.iy_e, 'blur', this._handleSubmit, this);
    }
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

addInputRow: function (tableElement, labelString, classname) {
  let tr = tableElement.insertRow();
  let tdLabel = tr.insertCell();
  tdLabel.innerText = labelString;
  let tdData = tr.insertCell();
  _inputcontainer = L.DomUtil.create("span", "uiElement input", tdData);
	var input = L.DomUtil.create("input", classname, _inputcontainer);
	input.type = "text";
	L.DomEvent.disableClickPropagation(input);
  input.value = this.options.placeholderHTML;
  return input;
},

_handleKeypress: function(e) {
  console.log("handleKeypress")
  switch (e.keyCode) {
    case 27: //Esc
      break;
    case 13: //Enter
      this._handleSubmit();
      break;
    default: //All keys
      //this._handleSubmit();
      break;
  }
},

_handleSubmit: function() {
  var opts = this.options;
  let x, y, z, lat, lng;
  try {
      x = +this.ix_e.value.replace(/,/g, '');
      y = +this.iy_e.value.replace(/,/g, '');
      z = +this.iz_e.value

      if (x && y && z && opts.world2latLng){
        ll = opts.world2latLng([x, y])
        this.map.setView(ll, z);
        this.urlParams.set("x", x);
        this.urlParams.set("y", y);
        this.urlParams.set("z", z);
        window.history.replaceState(
          {},
          "",
          `?${this.urlParams.toString()}`
        );
      }
  } catch (e) {
      console.log(e);
  }
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
    if (this.options.enableUserInput){
      this.iz_e.value = zStr;
    } else {
      this.z_e.innerText = zStr;
    }

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
      if (this.options.enableUserInput){  
        this.ix_e.value = xStr;
        this.iy_e.value = yStr;    
      } else {
        this.x_e.innerText = xStr;
        this.y_e.innerText = yStr;  
      }
      this.w_e.innerText = wStr;
      this.h_e.innerText = hStr;  
      //this.tb_e.innerText = tbStr;
      //this.bb_e.innerText = bbStr;  
      //this.rb_e.innerText = rbStr;
      //this.lb_e.innerText = lbStr;
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

L.LeafletFits = L.ImageOverlay.extend({
	options: {
		arrowSize: 20,
		band: 0,
		image: 0,
		renderer: null
  },
  initialize: function (url, options) { 
    //if(typeof(GeoTIFF) === 'undefined'){
    //    throw new Error("GeoTIFF not defined");
    //};

    this._url = url;
    this.raster = {};
    L.Util.setOptions(this, options);

    if (this.options.bounds) {
        //this._rasterBounds = L.latLngBounds(options.bounds);
        this._rasterBounds = options.bounds;
    }
    if (this.options.corners) {
        this._rasterCorners = options.corners;
    }
    if (this.options.renderer) {
      this.options.renderer.setParent(this);
    }
    this._getData();
  },

  onAdd: function (map) {
    this._map = map;
    if (!this._image) {
        this._initImage();
    }

    map._panes.overlayPane.appendChild(this._image);

    map.on('moveend', this._reset, this);
    
    if (map.options.zoomAnimation && L.Browser.any3d) {
        map.on('zoomanim', this._animateZoom, this);
    }

    this._reset();
  },  
  _getData: function() {
    var self = this;
    // Initialize a new FITS File object
    var FITS = astro.FITS;
    // Define a callback function for when the FITS file is received
    var callback = function() {
      // Get the first header-dataunit containing a dataunit
      var hdu = this.getHDU();
      // Get the first header
      var header = hdu.header;
      //var w = wcs();
      //w.init(header);
      // Read a card from the header
      var bitpix = header.get('BITPIX');
      // Get the dataunit object
      var dataunit = hdu.data;
      // Do some wicked client side processing ...
      var height = hdu.data.height;
      var width = hdu.data.width;
      var buf = dataunit.buffer;
      var dataview = new DataView(buf);
      var exampledata = new Float64Array(height * width);
      byteOffset = 0;
      for (y = 0; y < height; y++) {
        for (x = 0; x < width; x++) {
          exampledata[(y*width)+x] = dataview.getFloat64(byteOffset);
          byteOffset += 8;
        }
      }

      self.raster.data = exampledata;
      self.raster.width = width;
      self.raster.height = height;
      if (self._rasterCorners){
        var m = Matrix.fromTriangles([0,0,width,0,width,height], [self._rasterCorners[0],self._rasterCorners[1],self._rasterCorners[2]].flat());
        self.raster.ij2world = m;
        self.raster.world2ij = m.inverse()
      }
      self._reset();
    };  
    var fits = new FITS(this._url, callback);
  },
  setColorScale: function (colorScale) {
    this.options.renderer.setColorScale(colorScale);
  },  
  setDisplayRange: function (min,max) {
    this.options.renderer.setDisplayRange(min,max);
  },  
  _reset: function () {
    if (this.hasOwnProperty('_map')) {
        if (this._rasterBounds) {
            topLeft = this._map.latLngToLayerPoint(this._map.getBounds().getNorthWest()),
            size = this._map.latLngToLayerPoint(this._map.getBounds().getSouthEast())._subtract(topLeft);

            L.DomUtil.setPosition(this._image, topLeft);
            this._image.style.width  = size.x + 'px';
            this._image.style.height = size.y + 'px';

            this._drawImage();
        };
    };
  },
  _drawImage: function () {
    if (this.raster.hasOwnProperty('data')) {
      var args = {};
      topLeft = this._map.latLngToLayerPoint(this._map.getBounds().getNorthWest()),
      size = this._map.latLngToLayerPoint(this._map.getBounds().getSouthEast())._subtract(topLeft);
      args.rasterPixelBounds = L.bounds(this._map.latLngToContainerPoint(this._rasterBounds.getNorthWest()),this._map.latLngToContainerPoint(this._rasterBounds.getSouthEast()));
      args.xStart = (args.rasterPixelBounds.min.x>0 ? args.rasterPixelBounds.min.x : 0);
      args.xFinish = (args.rasterPixelBounds.max.x<size.x ? args.rasterPixelBounds.max.x : size.x);
      args.yStart = (args.rasterPixelBounds.min.y>0 ? args.rasterPixelBounds.min.y : 0);
      args.yFinish = (args.rasterPixelBounds.max.y<size.y ? args.rasterPixelBounds.max.y : size.y);
      args.plotWidth = args.xFinish-args.xStart;
      args.plotHeight = args.yFinish-args.yStart;
      if ((args.plotWidth<=0) || (args.plotHeight<=0)) {
        console.log(this.options.name,' is off screen.');
        var plotCanvas = document.createElement("canvas");
        plotCanvas.width = size.x;
        plotCanvas.height = size.y;
        var ctx = plotCanvas.getContext("2d");
        ctx.clearRect(0, 0, plotCanvas.width, plotCanvas.height);
        this._image.src = plotCanvas.toDataURL();
        return;
      }

      args.xOrigin = this._map.getPixelBounds().min.x+args.xStart;
      args.yOrigin = this._map.getPixelBounds().min.y+args.yStart;
      args.lngSpan = (this._rasterBounds._northEast.lng - this._rasterBounds._southWest.lng)/this.raster.width;
      args.latSpan = (this._rasterBounds._northEast.lat - this._rasterBounds._southWest.lat)/this.raster.height;
      //Draw image data to canvas and pass to image element
      var plotCanvas = document.createElement("canvas");
      plotCanvas.width = size.x;
      plotCanvas.height = size.y;
      var ctx = plotCanvas.getContext("2d");
      ctx.clearRect(0, 0, plotCanvas.width, plotCanvas.height);

			this.options.renderer.render(this.raster, plotCanvas, ctx, args);
      //Draw clipping polygon
      if (this.options.clip) {
        this._clipMaskToPixelPoints();
        ctx.globalCompositeOperation = 'destination-out';
        ctx.rect(args.xStart-10,args.yStart-10,args.plotWidth+20,args.plotHeight+20);
        //Draw vertices in reverse order
        for (var i = this._pixelClipPoints.length-1; i >= 0; i--) {
          var pix = this._pixelClipPoints[i];
          ctx['lineTo'](pix.x, pix.y);
        }
        ctx.closePath();
        ctx.fill();
      }
      this._image.src = String(plotCanvas.toDataURL());   
    }
  },  
  transform: function(rasterImageData, args) {
		//Create image data and Uint32 views of data to speed up copying
		var imageData = new ImageData(args.plotWidth, args.plotHeight);
		var outData = imageData.data;
		var outPixelsU32 = new Uint32Array(outData.buffer);
		var inData = rasterImageData.data;
		var inPixelsU32 = new Uint32Array(inData.buffer);
    var outWorldsF64 = new Float64Array(new ArrayBuffer(args.plotWidth * args.plotHeight * 8 * 2));
		var zoom = this._map.getZoom();
		var scale = this._map.options.crs.scale(zoom);
		var d = 57.29577951308232; //L.LatLng.RAD_TO_DEG;

		var transformationA = this._map.options.crs.transformation._a;
		var transformationB = this._map.options.crs.transformation._b;
		var transformationC = this._map.options.crs.transformation._c;
		var transformationD = this._map.options.crs.transformation._d;
		if (L.version >= "1.0") {
			transformationA = transformationA*this._map.options.crs.projection.R;
			transformationC = transformationC*this._map.options.crs.projection.R;
    }
		for (var y=0;y<args.plotHeight;y++) {
			var yUntransformed = ((args.yOrigin+y) / scale - transformationD) / transformationC;
			var currentLat = (2 * Math.atan(Math.exp(yUntransformed)) - (Math.PI / 2)) * d;
			for (var x=0;x<args.plotWidth;x++) {
        //Location to draw to
				var index = (y*args.plotWidth+x);
				//Calculate lat-lng of (x,y)
				//This code is based on leaflet code, unpacked to run as fast as possible
				//Used to deal with TIF being EPSG:4326 (lat,lon) and map being EPSG:3857 (m E,m N)
				var xUntransformed = ((args.xOrigin+x) / scale - transformationB) / transformationA;
				var currentLng = xUntransformed * d;
        var world = this.options.latLng2world(L.latLng(currentLat, currentLng))
        outWorldsF64[index*2] = world[0];
        outWorldsF64[index*2 + 1] = world[1];
			}
    }
    var outijs = this.raster.world2ij.applyToArray(outWorldsF64);
		for (var y=0;y<args.plotHeight;y++) {
			for (var x=0;x<args.plotWidth;x++) {
        var index = (y*args.plotWidth+x);
        var oi = outijs[index*2];
        var oj = outijs[index*2 + 1];
        var rasterX = Math.floor(oi);
        var rasterY = Math.ceil(oj);
        if (rasterY >= 0 && rasterY <= this.raster.height && rasterX >= 0 && rasterX <= this.raster.width){
          var rasterIndex = (rasterY*this.raster.width+rasterX);
          outPixelsU32[index] = inPixelsU32[rasterIndex];
        }
      }
    }
		return imageData;
	},
});

L.leafletFits = function (url, options) {
  return new L.LeafletFits(url, options);
};

L.LeafletFitsRenderer = L.Class.extend({
	
	initialize: function(options) {		
        L.setOptions(this, options);
	},

	setParent: function(parent) {
		this.parent = parent;
	},

	render: function(raster, canvas, ctx, args) {
		throw new Error('Abstract class');
	}

});

L.LeafletFits.Plotty = L.LeafletFitsRenderer.extend({

	options: {
		colorScale: 'viridis',
		clampLow: true,
		clampHigh: true,
		displayMin: 0,
		displayMax: 1
	},

	initialize: function(options) {
		if (typeof (plotty) === 'undefined') {
			throw new Error("plotty not defined");
		}
		this.name = "Plotty";
		
        L.setOptions(this, options);
		
		this._preLoadColorScale();
	},

    setColorScale: function (colorScale) {
        this.options.colorScale = colorScale;
        this.parent._reset();
    },

    setDisplayRange: function (min,max) {
        this.options.displayMin = min;
        this.options.displayMax = max;
        this.parent._reset();
    },

    _preLoadColorScale: function () {
        var canvas = document.createElement('canvas');
        var plot = new plotty.plot({
            canvas: canvas,
			      data: [0],
            width: 1, height: 1,
            domain: [this.options.displayMin, this.options.displayMax], 
            colorScale: this.options.colorScale,
            clampLow: this.options.clampLow,
            clampHigh: this.options.clampHigh,
        });
        this.colorScaleData = plot.colorScaleCanvas.toDataURL();            
    },
	
	render: function(raster, canvas, ctx, args) {
		var plottyCanvas = document.createElement("canvas");
		var plot = new plotty.plot({
			data: raster.data,
			width: raster.width, height: raster.height,
			domain: [this.options.displayMin, this.options.displayMax], 
			colorScale: this.options.colorScale,
			clampLow: this.options.clampLow,
			clampHigh: this.options.clampHigh,
			canvas: plottyCanvas,
			useWebGL: false
		});
		plot.setNoDataValue(-9999); 
		plot.render();

		this.colorScaleData = plot.colorScaleCanvas.toDataURL();

		var rasterImageData = plottyCanvas.getContext("2d").getImageData(0, 0, plottyCanvas.width, plottyCanvas.height);
		var imageData = this.parent.transform(rasterImageData, args);
		ctx.putImageData(imageData, args.xStart, args.yStart); 
	}

});

L.LeafletFits.plotty = function (options) {
    return new L.LeafletFits.Plotty(options);
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
  map.addControl(new L.Control.Coordinates({position: 'topright', customLabelFcn:map_LabelFcn}));

  
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
  layerGroups.concat([{ name: "top", opacity: 100 }]).forEach(function(layerGroup) {
    var group = L.layerGroup(), name = layerGroup.name, opacity = layerGroup.opacity / 100.0, visible = layerGroup.visible, resource_url = layerGroup.resource_url, colorScale = layerGroup.colorScale, displayMin = layerGroup.displayMin, displayMax = layerGroup.displayMax;
    opts = {opacity: opacity, maxNativeZoom: 6, visible: visible, resource_url: resource_url};

    if (layerGroup.tiled){
      if (layerGroup.bounds){
        opts = Object.assign(opts, {bounds: worldBounds(layerGroup.bounds)});
      }
      if (layerGroup.max_zoom){
        opts = Object.assign(opts, {maxNativeZoom: layerGroup.max_zoom})
      }
      L.tileLayer(baseUrl + global_id + '/layers/' + layerGroup.id + '/{z}/{x}_{y}.png', opts).addTo(group);
    } else {
      if (images[name]) {
        images[name].forEach(function(image) {
          if (!image.fits_file){
	          if (image.bounds){
              opts = Object.assign(opts, {bounds: worldBounds(image.bounds)});
            }
            if (image.max_zoom){
	            opts = Object.assign(opts, {maxNativeZoom: image.max_zoom})
            }
            L.tileLayer(baseUrl + global_id + '/' + image.id + '/{z}/{x}_{y}.png', opts).addTo(group);
          }
        });
      }
    }
    //for fits file
    if (images[name]) {
      images[name].forEach(function(image) {
        if (image.fits_file){
          var b_bounds = L.latLngBounds([
            world2latLng([image.bounds[0], image.bounds[1]]),
            world2latLng([image.bounds[2], image.bounds[3]])
          ]);
          ploty_opts = {colorScale: 'rainbow', displayMin: 0, displayMax: 30};
          if (layerGroup.colorScale){
            opts = Object.assign(opts, {colorScale: layerGroup.colorScale})
          }
          if (layerGroup.displayMin){
            opts = Object.assign(opts, {displayMin: layerGroup.displayMin})
          }
          if (layerGroup.displayMax){
            opts = Object.assign(opts, {colorScale: layerGroup.displayMax})
          }

          L.leafletFits(image.path, {bounds: b_bounds, corners: image.corners, visible:visible, latLng2world: latLng2world, world2latLng: world2latLng,  renderer: L.LeafletFits.plotty(ploty_opts)}).addTo(group)
        }        
      })
    }

    layers.push(group);
    if (visible){
      group.addTo(map);
    }
    if (name === "") { name = "top"; }
    overlayMaps[name] = group;
  });

  var spotsLayer = L.layerGroup();
  map.addLayer(spotsLayer);
  loadMarkers();

  L.control.surfaceScale({ imperial: false, length: length }).addTo(map);

  //L.control.layers(baseMaps, overlayMaps).addTo(map);
  L.control.opacityLayers(baseMaps, overlayMaps, {collapsed:false}).addTo(map);
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
  L.control.viewMeta({position: `bottomleft`, enableUserInput: true, latLng2world: latLng2world, world2latLng: world2latLng, customLabelFcn: map_LabelFcn}).addTo(map);
  surfaceMap = map;
}
