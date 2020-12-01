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
              for (var i = 0; i < glayers.length; i++) {
                glayer = glayers[i];
                if (typeof glayer.setColorScale === "function") { 
                // safe to use the function
                  glayer.setColorScale(value);
                }
              }
              url = obj.layer.getLayers()[0].options.resource_url + '.json';
              $.ajax(url,{
                type: 'PUT',
                data: {surface_layer: {color_scale: value}},
                complete: function(e){ console.log('ok'); },
                error: function(e) { console.log(e); }
              });      
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
              for (var i = 0; i < glayers.length; i++) {
                glayer = glayers[i];
                if (typeof glayer.setDisplayRange === "function") { 
                // safe to use the function
                  glayer.setDisplayRange(min, max);
                }
              }
              url = obj.layer.getLayers()[0].options.resource_url + '.json';
              $.ajax(url,{
                type: 'PUT',
                data: {surface_layer: {display_min: min}},
                complete: function(e){ console.log('ok'); },
                error: function(e) { console.log(e); }
              });      
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
              for (var i = 0; i < glayers.length; i++) {
                glayer = glayers[i];
                if (typeof glayer.setDisplayRange === "function") { 
                // safe to use the function
                  glayer.setDisplayRange(min, max);
                }
              }
              url = obj.layer.getLayers()[0].options.resource_url + '.json';
              $.ajax(url,{
                type: 'PUT',
                data: {surface_layer: {display_max: max}},
                complete: function(e){ console.log('ok'); },
                error: function(e) { console.log(e); }
              });      
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
      for (var i = 0; i < glayers.length; i++) {
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
                  var _opacity = _layer.options.opacity;
                  if (_opacity != opacity){
                    if (typeof _layer.setOpacity === "function") { 
                      _layer.setOpacity(opacity);
                    }
		                if (typeof _layer._url === 'undefined'){
		                } else {
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

L.LeafletFitsGL = L.Layer.extend({
  initialize: function (url, options) { 

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
    //this._getData();
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
        var latLngCorners = [
          self.options.world2latLng(self._rasterCorners[0]),
          self.options.world2latLng(self._rasterCorners[1]),
          self.options.world2latLng(self._rasterCorners[2]),
          self.options.world2latLng(self._rasterCorners[3]),
        ];
        var mm = Matrix.fromTriangles([0,0,width,0,width,height], [latLngCorners[0].lat,latLngCorners[0].lng,latLngCorners[1].lat,latLngCorners[1].lng,latLngCorners[2].lat,latLngCorners[2].lng]);
        var ij2latLng = mm;
        var aij = new Int32Array(new ArrayBuffer(width * height * 4 * 2));
        var cij = new Float32Array(new ArrayBuffer(width * height * 4 * 8));
        var ijArray = [];
        for(i=0; i < height; i++){
          for(j=0; j< width; j++){
            var index = (i*height+j);
            //ijArray = ijArray.concat([i,j]);
            aij[index*2] = j;
            aij[index*2 + 1] = i;
            l = j - 0.5;
            r = j + 0.5;
            u = i - 0.5;
            b = i + 0.5;
            cij[index*8 + 0] = l;
            cij[index*8 + 1] = u;
            cij[index*8 + 2] = r;
            cij[index*8 + 3] = u;
            cij[index*8 + 4] = r;
            cij[index*8 + 5] = b;
            cij[index*8 + 6] = l;
            cij[index*8 + 7] = b;
          }
        }
        var latLngArray = ij2latLng.applyToArray(aij);
        var clatLngArray = ij2latLng.applyToArray(cij);
        var latLngs = []
        for(i = 0; i < latLngArray.length/2; i++){
          latLngs[i] = [latLngArray[i*2], latLngArray[i*2+1]];
        }
        self.raster.latLngs = latLngs;
        var features = []
        for(i = 0; i < clatLngArray.length/8; i++){
          features[i] = {
            "type": "Feature", 
            "geometry":{
              "type": "Polygon", 
              "coordinates":[
                [
                  [clatLngArray[i*8+1], clatLngArray[i*8+0]],
                  [clatLngArray[i*8+3], clatLngArray[i*8+2]],
                  [clatLngArray[i*8+5], clatLngArray[i*8+4]],
                  [clatLngArray[i*8+7], clatLngArray[i*8+6]]
                ]
                //[
                //[latLngArray[1], latLngArray[0]],
                //[latLngArray[3], latLngArray[2]],
                //[latLngArray[5], latLngArray[4]],
                //[latLngArray[7], latLngArray[6]]
                //]
              ]
            }
          }          
        }
        self.raster.features = features; 
      }
      self._reset();
    };  
    this.fits = new FITS(this._url, callback);
  },
  setColorScale: function (colorScale) {
    this.options.renderer.setColorScale(colorScale);
  },  
  setDisplayRange: function (min,max) {
    this.options.renderer.setDisplayRange(min,max);
  },
  setOpacity: function (opacity) {
    this.options.opacity = opacity;
    this._reset()
  }, 
  _initPoints: function(){
    if (this.hasOwnProperty('_map')) {
      if (this._rasterBounds) {
          this._drawImage();
          if (this.raster.latLngs){
            var data = this.raster.imageData.data;
            this._points = L.glify.shapes({
                map: this._map,
                data: {
                  "type": "FeatureCollection", 
                  "features": this.raster.features    
                },
                color: function(index, feature){ 
                  i = index*4;
                  rgb = {r: data[i]/255, g:data[i+1]/255, b:data[i+2]/255};
                  return rgb; 
                },
                opacity: this.options.opacity,
                click: function(e, feature){
                  // do something when a shape is clicked
                  // return false to continue traversing
                  console.log(feature);
                }
            });
            L.Util.setOptions(this._points.layer, {visible: this.options.visible, parent: this});
          };
      };
    };
  },
  _reset: function () {
    if (this.hasOwnProperty('_map')) {
        if (this._rasterBounds) {
            this._drawImage();
            if (this.raster.latLngs){
              var data = this.raster.imageData.data;
              if (!this._points){
                this._initPoints();
              }          
              if (this._points){
                this._points.settings.color = function(index, feature){ 
                    i = index*4;
                    rgb = {r: data[i]/255, g:data[i+1]/255, b:data[i+2]/255};
                    return rgb; 
                };
                this._points.setData({
                  "type": "FeatureCollection", 
                  "features": this.raster.features    
                });
                this._points.settings.opacity = this.options.opacity;
                this._points.render();
              }
            }
        };
    };
  },
  _drawImage: function () {
    if (this.raster.hasOwnProperty('data')) {
      var args = {};
			this.options.renderer.render(this.raster, args);
    }
  },
  onAdd: function (map) {
    this._map = map;
    if (!this.fits){
      this._getData();
    }
    if (!this._points){
      this._initPoints();
    }
    if (this._points){
      this._points.addTo(map);
    }
  },  
  onRemove: function(map) {
    if (this._points){
      this._points.remove();
    }
  },
});


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

L.leafletFitsGL = function (url, options) {
  return new L.LeafletFitsGL(url, options);
};

L.LeafletFitsGL.Plotty = L.LeafletFitsRenderer.extend({

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
	
	render: function(raster, args) {
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
    var inData = rasterImageData.data;
		var inPixelsU32 = new Uint32Array(inData.buffer);

    raster.imageData = rasterImageData;
    raster.inPixelsU32 = inPixelsU32;
  }

});

L.LeafletFitsGL.plotty = function (options) {
    return new L.LeafletFitsGL.Plotty(options);
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
  }).setView([50.00, 14.44], 8);

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

  layerGroups.concat([{ name: "top", opacity: 100 }]).forEach(function(layerGroup) {
    var group = L.layerGroup(), name = layerGroup.name, opacity = layerGroup.opacity / 100.0, visible = layerGroup.visible, resource_url = layerGroup.resource_url, colorScale = layerGroup.colorScale, displayMin = layerGroup.displayMin, displayMax = layerGroup.displayMax;
    opts = {opacity: opacity, maxNativeZoom: 6, visible: visible, resource_url: resource_url};
    var flag = false;
    if (layerGroup.tiled){
      if (layerGroup.bounds){
        opts = Object.assign(opts, {bounds: worldBounds(layerGroup.bounds)});
      }
      if (layerGroup.max_zoom){
        opts = Object.assign(opts, {maxNativeZoom: layerGroup.max_zoom})
      }
      L.tileLayer(baseUrl + global_id + '/layers/' + layerGroup.id + '/{z}/{x}_{y}.png', opts).addTo(group);
      flag = true;
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
            flag = true;
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
            ploty_opts = Object.assign(ploty_opts, {colorScale: layerGroup.colorScale})
          }
          if (layerGroup.displayMin){
            ploty_opts = Object.assign(ploty_opts, {displayMin: layerGroup.displayMin})
          }
          if (layerGroup.displayMax){
            ploty_opts = Object.assign(ploty_opts, {displayMax: layerGroup.displayMax})
          }
          opts = Object.assign(opts, {
            bounds: b_bounds,
            corners: image.corners, 
            visible:visible, 
            latLng2world: latLng2world, 
            world2latLng: world2latLng,  
            renderer: L.LeafletFitsGL.plotty(ploty_opts)}
          );

          L.leafletFitsGL(image.path, opts).addTo(group);
          //L.leafletFits(image.path, {bounds: b_bounds, corners: image.corners, visible:visible, latLng2world: latLng2world, world2latLng: world2latLng,  renderer: L.LeafletFits.plotty(ploty_opts)}).addTo(group)
          flag = true;
        }        
      })
    }
    layers.push(group);
    if (layerGroup.wall){
      //group.addTo(map);
      baseMaps[name] = group;
      if (baseCount == 0){
        group.addTo(map)  
      }
      baseCount += 1;  
    } else {
      if (visible){
        group.addTo(map);
      }
      if (name === "") { name = "top"; }
      if (flag){
        overlayMaps[name] = group;
      }
    }
  });

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
    if (baseCount == 0){
      layer.addTo(map)
    }
    baseCount += 1;
    //layer.addTo(map);
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
          var options = { draggable: true, title: spot['name'], data:spot };
          var marker = new L.marker(pos, options).addTo(spotsLayer);
          var popupContent = [];
          popupContent.push("<nobr>" + spot['name_with_id'] + "</nobr>");
          var x_input = "<input type='text', id=\"spot_world_x\" value=\"" + spot['world_x'] + "\">";
          var y_input = "<input type='text', id=\"spot_world_y\" value=\"" + spot['world_y'] + "\">"
          popupContent.push("<nobr>coordinate: (" + x_input + ", " + y_input + ")</nobr>");
          if (spot['attachment_file_id']){
            var image_url = resourceUrl + '/images/' + spot['attachment_file_id'];
            popupContent.push("<nobr>image: <a href=" + image_url + ">" + spot['attachment_file_name'] +  "</a>"+ "</nobr>");
          }
          if (spot['target_uid']){
            popupContent.push("<nobr>link: " + spot['target_link'] +  "</nobr>");
          }

          var delete_btn = "<button class='marker-delete-button btn btn-danger'>Delete</button>";
          var cancel_btn = "<button class='marker-cancel-button btn btn-info'>Cancel</button>";
          var save_btn = "<button class='marker-save-button btn btn-primary'>Save</button>";

          popupContent.push('<div style="text-align:center;">' + save_btn + cancel_btn + delete_btn + '</div>');
          marker.bindPopup(popupContent.join("<br/>"), {
            maxWidth: "auto",
          });
          marker.on("popupopen", onPopupOpen)
          marker.on("popupclose", function(){
            console.log("PopupClose");
          })
          marker.on('dragend', onDragEnd);
	      });
      });
  }

  function onDragEnd() {
    console.log("DragEnd");
    var tempMarker = this;
    var spot = tempMarker.options.data;
    var world = latLng2world(tempMarker.getLatLng());
    //document.getElementById('spot_world_x').value = world.x;

    console.log(world);
  }

  function onPopupOpen() {
    console.log("PopupOpen");
    var tempMarker = this;
    //tempMarker.dragging.enable();
    var spot = tempMarker.options.data;
    var world = latLng2world(tempMarker.getLatLng());
    $("#spot_world_x").val(world[0]);
    $("#spot_world_y").val(world[1]);
    $(".marker-save-button:visible").click(function (){
      var url = spot.resource_url + ".json";
      var world_x = $("#spot_world_x").val();
      var world_y = $("#spot_world_y").val();
  
      $.ajax(url,{
        type: 'PUT',
        data: {spot:{world_x: world_x, world_y: world_y}},
        beforeSend: function(e) {console.log('saving...')},
        complete: function(e){ 
          map.removeLayer(tempMarker);
          loadMarkers();
        },
        error: function(e) {console.log(e)}
      })
    });
    $(".marker-cancel-button:visible").click(function (){
      map.closePopup();
      var pos = world2latLng([spot.world_x, spot.world_y]);
      tempMarker.setLatLng(pos);
      //map.panTo(pos);
    });
    $(".marker-delete-button:visible").click(function (){
      var url = spot.resource_url + ".json";   
      $.ajax(url,{
        type: 'DELETE',
        data: {"id":spot.id},
        beforeSend: function(e) {console.log('removing...')},
        complete: function(e){ 
          map.removeLayer(tempMarker);
        },
        error: function(e) {console.log(e)}
      })
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
          //iconUrl: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACMAAAAjCAYAAAAe2bNZAAAAAXNSR0IArs4c6QAAAAZiS0dEAP8A/wD/oL2nkwAAAAlwSFlzAAALEwAACxMBAJqcGAAAAHVJREFUWMPt1rENgDAMRNEPi3gERmA0RmAERgmjsAEjhMY0dOBIWHCWTulOL5UN8VmACpRoUdcAU1v19SQaYYQRRhhhhMmIMV//9WGuG/xudmA6C+YApGUGgNF1b0KKjithhBFGGGGE+Rtm9XfL8CHzS8340hzaXWaR1yQVAAAAAABJRU5ErkJggg==',
          iconUrl: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAPUlEQVRYw+3WwQkAMAgEQZP+e04+6eAECczawOBHq5LOm6BdwwEAAAAAAIwDVnpOv99AlocEAAAAAACgoQtVAgoyQcceMgAAAABJRU5ErkJggg==',
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
          '</form>'+
	        '<nobr><div style="text-align:center;">' +
          '<button type="submit" value="submit" class="marker-add-button btn btn-small btn-primary">Save</button>' +
          '<button type="submit" value="cancel" class="marker-delete-button btn btn-small btn-info">Cancel</button>' +
          '</div></nobr>'
        marker.bindPopup(popupContent, {
			    maxWidth: "auto",
        });     
        marker.on("popupopen", function(){
          console.log("PopupOpen");
          var tempMarker = this;

          $(".marker-delete-button:visible").click(function (){
                map.removeLayer(tempMarker);
          });

          $(".marker-add-button:visible").click(function (){
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
          });

        });
        marker.openPopup();  
        //$('body').on('submit', '#addspot-form', mySubmitFunction);
        function mySubmitFunction(e){
		      e.preventDefault();
		      console.log("didnt submit");
        }
	  }
  });
  new L.Toolbar2.Control({
    position: 'topleft',
    actions: [toolbarAction]
  }).addTo(map);
  L.control.viewMeta({position: `topleft`, enableUserInput: true, latLng2world: latLng2world, world2latLng: world2latLng, customLabelFcn: map_LabelFcn}).addTo(map);
  surfaceMap = map;
  return map;
}

function initMapImageCalibrator() {
  var div = document.getElementById("surface-map");
  var baseUrl = div.dataset.baseUrl;
  var urlRoot = div.dataset.urlRoot;
  var global_id = div.dataset.globalId;
  var length = parseFloat(div.dataset.length);
  var center = JSON.parse(div.dataset.center);
  var baseImages = JSON.parse(div.dataset.baseImages);
  var layerGroups = JSON.parse(div.dataset.layerGroups);
  var images = JSON.parse(div.dataset.images);
  var g_opacity = 0.5;

  map = initSurfaceMap();
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

  imgActionArray = function(){
    return [CToggleTransparency, CToggleOutline, CToggleLock, CToggleRotateScale, CToggleOrder, CRevert, SaveImageAction];
  };

  var CToggleTransparency = L.EditAction.extend({
    initialize: function (map, overlay, options) {
var edit = overlay.editing,
  href,
  tooltip,
  symbol;

if (edit._transparent) {
  href = '<use xlink:href="#opacity"></use>';
  symbol = '<symbol viewBox="0 0 18 18" id="opacity" xmlns="http://www.w3.org/2000/svg"><path fill="#0078A8" d="M13.245 6L9 1.763 4.755 6A6.015 6.015 0 0 0 3 10.23c0 1.5.585 3.082 1.755 4.252a5.993 5.993 0 0 0 8.49 0A6.066 6.066 0 0 0 15 10.23c0-1.5-.585-3.06-1.755-4.23zM4.5 10.5c.008-1.5.465-2.453 1.32-3.3L9 3.952l3.18 3.285c.855.84 1.313 1.763 1.32 3.263h-9z"/></symbol>';
  tooltip = 'Make Image Opaque';
} else {
  href = '<use xlink:href="#opacity-empty"></use>';
  symbol = '<symbol viewBox="0 0 14 18" id="opacity-empty" xmlns="http://www.w3.org/2000/svg"><path fill="#0078A8" stroke="#0078A8" stroke-width="1.7" d="M10.708 6.25A5.113 5.113 0 0 1 12.2 9.846c0 1.275-.497 2.62-1.492 3.614a5.094 5.094 0 0 1-7.216 0A5.156 5.156 0 0 1 2 9.846c0-1.275.497-2.601 1.492-3.596L7.1 2.648l3.608 3.602zm0 0L7.1 2.648 3.492 6.25A5.113 5.113 0 0 0 2 9.846c0 1.275.497 2.62 1.492 3.614a5.094 5.094 0 0 0 7.216 0A5.156 5.156 0 0 0 12.2 9.846a5.113 5.113 0 0 0-1.492-3.596z"/></symbol>';
  tooltip = 'Make Image Transparent';
}

options = options || {};
options.toolbarIcon = {
  html: '<svg class="svg-icons">' + href + symbol + '</svg>',
  tooltip: tooltip
};

L.EditAction.prototype.initialize.call(this, map, overlay, options);
    },

    addHooks: function () {
var editing = this._overlay.editing;

//editing._toggleTransparency();
      var image = editing._overlay._image, opacity;
      editing._transparent = !editing._transparent;
      opacity = editing._transparent ? 0 : g_opacity;
      L.DomUtil.setOpacity(image, opacity);
      image.setAttribute("opacity", opacity);
      editing._showToolbar();
    }
});  


var CToggleOutline = L.EditAction.extend({
    initialize: function (map, overlay, options) {
var edit = overlay.editing,
  href,
  tooltip,
  symbol;


if (edit._outlined) {
  href = '<use xlink:href="#border_clear"></use>';
  symbol = '<symbol viewBox="0 0 18 18" id="border_clear" xmlns="http://www.w3.org/2000/svg"><path fill="#0078A8" d="M5.25 3.75h1.5v-1.5h-1.5v1.5zm0 6h1.5v-1.5h-1.5v1.5zm0 6h1.5v-1.5h-1.5v1.5zm3-3h1.5v-1.5h-1.5v1.5zm0 3h1.5v-1.5h-1.5v1.5zm-6 0h1.5v-1.5h-1.5v1.5zm0-3h1.5v-1.5h-1.5v1.5zm0-3h1.5v-1.5h-1.5v1.5zm0-3h1.5v-1.5h-1.5v1.5zm0-3h1.5v-1.5h-1.5v1.5zm6 6h1.5v-1.5h-1.5v1.5zm6 3h1.5v-1.5h-1.5v1.5zm0-3h1.5v-1.5h-1.5v1.5zm0 6h1.5v-1.5h-1.5v1.5zm0-9h1.5v-1.5h-1.5v1.5zm-6 0h1.5v-1.5h-1.5v1.5zm6-4.5v1.5h1.5v-1.5h-1.5zm-6 1.5h1.5v-1.5h-1.5v1.5zm3 12h1.5v-1.5h-1.5v1.5zm0-6h1.5v-1.5h-1.5v1.5zm0-6h1.5v-1.5h-1.5v1.5z"/></symbol>';
  tooltip = 'Remove Border';
} else {
  href = '<use xlink:href="#border_outer"></use>';
  symbol = '<symbol viewBox="0 0 18 18" id="border_outer" xmlns="http://www.w3.org/2000/svg"><path fill="#0078A8" d="M9.75 5.25h-1.5v1.5h1.5v-1.5zm0 3h-1.5v1.5h1.5v-1.5zm3 0h-1.5v1.5h1.5v-1.5zm-10.5-6v13.5h13.5V2.25H2.25zm12 12H3.75V3.75h10.5v10.5zm-4.5-3h-1.5v1.5h1.5v-1.5zm-3-3h-1.5v1.5h1.5v-1.5z" /></symbol>'
  tooltip = 'Add Border';
}

options = options || {};
options.toolbarIcon = {
  html: '<svg class="svg-icons">' + href + symbol + '</svg>',
  tooltip: tooltip
};

L.EditAction.prototype.initialize.call(this, map, overlay, options);
    },

    addHooks: function () {
var editing = this._overlay.editing;

editing._toggleOutline();
    }
});

var CDelete = L.EditAction.extend({
    initialize: function (map, overlay, options) {
var href = '<use xlink:href="#delete_forever"></use>';
var symbol = '<symbol viewBox="0 0 18 18" id="delete_forever" xmlns="http://www.w3.org/2000/svg"><path fill="#c10d0d" d="M4.5 14.25c0 .825.675 1.5 1.5 1.5h6c.825 0 1.5-.675 1.5-1.5v-9h-9v9zm1.845-5.34l1.058-1.058L9 9.443l1.59-1.59 1.058 1.058-1.59 1.59 1.59 1.59-1.058 1.058L9 11.558l-1.59 1.59-1.058-1.058 1.59-1.59-1.597-1.59zM11.625 3l-.75-.75h-3.75l-.75.75H3.75v1.5h10.5V3h-2.625z" /></symbol>';

options = options || {};
options.toolbarIcon = {
  html: '<svg class="svg-icons">' + href + symbol + '</svg>',
  tooltip: 'Delete Image'
};

L.EditAction.prototype.initialize.call(this, map, overlay, options);
    },

    addHooks: function () {
var editing = this._overlay.editing;

editing._removeOverlay();
    }
});

var CToggleLock = L.EditAction.extend({
    initialize: function (map, overlay, options) {
var edit = overlay.editing,
  href,
  tooltip,
  symbol;

if (edit._mode === 'lock') {
  href = '<use xlink:href="#unlock"></use>';
  symbol = '<symbol viewBox="0 0 18 18" id="unlock" xmlns="http://www.w3.org/2000/svg"><path fill="#0078A8" d="M13.5 6h-.75V4.5C12.75 2.43 11.07.75 9 .75 6.93.75 5.25 2.43 5.25 4.5h1.5A2.247 2.247 0 0 1 9 2.25a2.247 2.247 0 0 1 2.25 2.25V6H4.5C3.675 6 3 6.675 3 7.5V15c0 .825.675 1.5 1.5 1.5h9c.825 0 1.5-.675 1.5-1.5V7.5c0-.825-.675-1.5-1.5-1.5zm0 9h-9V7.5h9V15zM9 12.75c.825 0 1.5-.675 1.5-1.5s-.675-1.5-1.5-1.5-1.5.675-1.5 1.5.675 1.5 1.5 1.5z"/></symbol>';
  tooltip = 'Unlock';
} else {
  href = '<use xlink:href="#lock"></use>';
  symbol = '<symbol viewBox="0 0 18 18" id="lock" xmlns="http://www.w3.org/2000/svg"><path fill="#0078A8" d="M13.5 6h-.75V4.5C12.75 2.43 11.07.75 9 .75 6.93.75 5.25 2.43 5.25 4.5V6H4.5C3.675 6 3 6.675 3 7.5V15c0 .825.675 1.5 1.5 1.5h9c.825 0 1.5-.675 1.5-1.5V7.5c0-.825-.675-1.5-1.5-1.5zM6.75 4.5A2.247 2.247 0 0 1 9 2.25a2.247 2.247 0 0 1 2.25 2.25V6h-4.5V4.5zM13.5 15h-9V7.5h9V15zM9 12.75c.825 0 1.5-.675 1.5-1.5s-.675-1.5-1.5-1.5-1.5.675-1.5 1.5.675 1.5 1.5 1.5z"/></symbol>';
  tooltip = 'Lock';
}

options = options || {};
options.toolbarIcon = {
  html: '<svg class="svg-icons">' + href + symbol + '</svg>',
  tooltip: tooltip
};

L.EditAction.prototype.initialize.call(this, map, overlay, options);
    },

    addHooks: function () {
var editing = this._overlay.editing;

editing._toggleLock();
    }
});

var CToggleRotateScale = L.EditAction.extend({
    initialize: function (map, overlay, options) {
var edit = overlay.editing,
  href,
  tooltip,
  symbol;

if (edit._mode === 'rotateScale') {
  href = '<use xlink:href="#transform"></use>';
  symbol = '<symbol viewBox="0 0 18 18" id="transform" xmlns="http://www.w3.org/2000/svg"><path fill="#0078A8" d="M16.5 13.5V12H6V3h1.5L5.25.75 3 3h1.5v1.5h-3V6h3v6c0 .825.675 1.5 1.5 1.5h6V15h-1.5l2.25 2.25L15 15h-1.5v-1.5h3zM7.5 6H12v4.5h1.5V6c0-.825-.675-1.5-1.5-1.5H7.5V6z"/></symbol>';
  tooltip = 'Distort';
} else {
  href = '<use xlink:href="#crop_rotate"></use>';
  symbol = '<symbol viewBox="0 0 18 18" id="crop_rotate" xmlns="http://www.w3.org/2000/svg"><path fill="#0078A8" d="M5.603 16.117C3.15 14.947 1.394 12.57 1.125 9.75H0C.383 14.37 4.245 18 8.963 18c.172 0 .33-.015.495-.023L6.6 15.113l-.997 1.005zM9.037 0c-.172 0-.33.015-.495.03L11.4 2.888l.998-.998a7.876 7.876 0 0 1 4.477 6.36H18C17.617 3.63 13.755 0 9.037 0zM12 10.5h1.5V6A1.5 1.5 0 0 0 12 4.5H7.5V6H12v4.5zM6 12V3H4.5v1.5H3V6h1.5v6A1.5 1.5 0 0 0 6 13.5h6V15h1.5v-1.5H15V12H6z" /></symbol>';
  tooltip = 'Rotate+Scale';
}

options = options || {};
options.toolbarIcon = {
  html: '<svg class="svg-icons">' + href + symbol + '</svg>',
  tooltip: tooltip
};

L.EditAction.prototype.initialize.call(this, map, overlay, options);
    },

    addHooks: function () {
var editing = this._overlay.editing;

editing._toggleRotateScale();
    }
});

var CToggleOrder = L.EditAction.extend({
    initialize: function (map, overlay, options) {
var edit = overlay.editing,
  href,
  tooltip,
  symbol;

if (edit._toggledImage) {
  href = '<use xlink:href="#flip_to_front"></use>';
  symbol = '<symbol viewBox="0 0 18 18" id="flip_to_front" xmlns="http://www.w3.org/2000/svg"><path fill="#0078A8" d="M2.25 9.75h1.5v-1.5h-1.5v1.5zm0 3h1.5v-1.5h-1.5v1.5zm1.5 3v-1.5h-1.5a1.5 1.5 0 0 0 1.5 1.5zm-1.5-9h1.5v-1.5h-1.5v1.5zm9 9h1.5v-1.5h-1.5v1.5zm3-13.5h-7.5a1.5 1.5 0 0 0-1.5 1.5v7.5a1.5 1.5 0 0 0 1.5 1.5h7.5c.825 0 1.5-.675 1.5-1.5v-7.5c0-.825-.675-1.5-1.5-1.5zm0 9h-7.5v-7.5h7.5v7.5zm-6 4.5h1.5v-1.5h-1.5v1.5zm-3 0h1.5v-1.5h-1.5v1.5z"/></symbol>';
  tooltip = 'Stack to Front';
} else {
  href = '<use xlink:href="#flip_to_back"></use>';
  symbol = '<symbol viewBox="0 0 18 18" id="flip_to_back" xmlns="http://www.w3.org/2000/svg"><path fill="#0078A8" d="M6.75 5.25h-1.5v1.5h1.5v-1.5zm0 3h-1.5v1.5h1.5v-1.5zm0-6a1.5 1.5 0 0 0-1.5 1.5h1.5v-1.5zm3 9h-1.5v1.5h1.5v-1.5zm4.5-9v1.5h1.5c0-.825-.675-1.5-1.5-1.5zm-4.5 0h-1.5v1.5h1.5v-1.5zm-3 10.5v-1.5h-1.5a1.5 1.5 0 0 0 1.5 1.5zm7.5-3h1.5v-1.5h-1.5v1.5zm0-3h1.5v-1.5h-1.5v1.5zm0 6c.825 0 1.5-.675 1.5-1.5h-1.5v1.5zm-10.5-7.5h-1.5v9a1.5 1.5 0 0 0 1.5 1.5h9v-1.5h-9v-9zm7.5-1.5h1.5v-1.5h-1.5v1.5zm0 9h1.5v-1.5h-1.5v1.5z"/></symbol>';
  tooltip = 'Stack to Back';
}

options = options || {};
options.toolbarIcon = {
  html: '<svg class="svg-icons">' + href + symbol + '</svg>',
  tooltip: tooltip
};

L.EditAction.prototype.initialize.call(this, map, overlay, options);
    },

    addHooks: function () {
var editing = this._overlay.editing;

editing._toggleOrder();
    }
});
var CRevert = L.EditAction.extend({
    initialize: function (map, overlay, options) {
var href = '<use xlink:href="#restore"></use>';
var symbol = '<symbol viewBox="0 0 18 18" id="restore" xmlns="http://www.w3.org/2000/svg"><path fill="#058dc4" d="M15.67 3.839a.295.295 0 0 0-.22.103l-5.116 3.249V4.179a.342.342 0 0 0-.193-.315.29.29 0 0 0-.338.078L3.806 7.751v-4.63h-.002l.002-.022c0-.277-.204-.502-.456-.502h-.873V2.6c-.253 0-.457.225-.457.503l.002.026v10.883h.005c.021.257.217.454.452.455l.016-.002h.822c.013.001.025.004.038.004.252 0 .457-.225.457-.502a.505.505 0 0 0-.006-.068V9.318l6.001 3.811a.288.288 0 0 0 .332.074.34.34 0 0 0 .194-.306V9.878l5.12 3.252a.288.288 0 0 0 .332.073.34.34 0 0 0 .194-.306V4.18a.358.358 0 0 0-.09-.24.296.296 0 0 0-.218-.1z"/></symbol>';

options = options || {};
options.toolbarIcon = {
  html: '<svg class="svg-icons">' + href + symbol + '</svg>',
  tooltip: 'Restore'
};

L.EditAction.prototype.initialize.call(this, map, overlay, options);
    },

    addHooks: function () {
var editing = this._overlay.editing;

editing._revert();
    }
});

var SaveImageAction = L.EditAction.extend({
  initialize: function (map, overlay, options){
            var use = '<use xlink:href="#get_app"></use>'
            var symbol = '<symbol viewBox="0 0 18 18" id="get_app" xmlns="http://www.w3.org/2000/svg"><path fill="#058dc4" d="M14.662 6.95h-3.15v-4.5H6.787v4.5h-3.15L9.15 12.2l5.512-5.25zM3.637 13.7v1.5h11.025v-1.5H3.637z"/></symbol></svg>'

      var href = '<use xlink:href="/assets/icons/symbol/sprite.symbol.svg#get_app"></use>';
            options = options || {};
            options.toolbarIcon = {
    html: '<svg class="svg-icons">' + use + symbol + '</svg>',
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
    var corners_on_world = [];
    img._corners.forEach(function(_corner){
      corners_on_map.push(map.project(_corner,0))
corners_on_world.push(latLng2world(_corner));
    });
    $.ajax(img.resource_url + ".json",{
      type: 'PUT',
data: {surface_image: 
    {corners_on_world:
        corners_on_world[0][0] + ',' + corners_on_world[0][1] + ':' +
        corners_on_world[1][0] + ',' + corners_on_world[1][1] + ':' +
        corners_on_world[3][0] + ',' + corners_on_world[3][1] + ':' +
        corners_on_world[2][0] + ',' + corners_on_world[2][1],
    }
},
beforeSend: function(e){ map.spin(true, {color: '#ffffff'}); console.log('saving...') },
complete: function(e){ console.log('ok'); map.spin(false); },
error: function(e) { console.log(e); map.spin(false); }
    })
}; 
  var imgs = [];
  for (let name in images){
    console.log(name)
    image = images[name][0];
    var corners = [
      world2latLng(image.corners[0]),
      world2latLng(image.corners[1]),
      world2latLng(image.corners[3]),
      world2latLng(image.corners[2])
    ];
    opts = {mode: "rotateScale", actions: imgActionArray(), corners: corners}
    img = L.distortableImageOverlay(image.path,opts).addTo(map);
    L.DomUtil.setOpacity(img._image, g_opacity);
    img._image.setAttribute("opacity", g_opacity);
    imgs.push(img);
    img.warpable_id = image.id
    img.resource_url = image.resource_url
    img.addTo(map)
  }
  imgGroup = L.distortableCollection().addTo(map);
  imgs.forEach(function(img){
    imgGroup.addLayer(img);
  });

}

