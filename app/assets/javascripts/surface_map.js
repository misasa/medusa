L.Surface = L.Class.extend({
  initialize: function (options) {
    L.setOptions(this, options)
    //this.createMarkerForm()
    //this.createGeometryForm()
    //this.addDOMEvents()
  },
  obj2spot: function(obj){
    var surface = this;
    obj.reload = function(options = {}){
      console.log("obj.reload...")
      var url = obj.resource_url + ".json";
      console.log(url)
      $.get(url, function(data){
        console.log(data)
        var spot = surface.obj2spot(data);
        if ('onSuccess' in options){
          options.onSuccess(spot);
        }
      });
    },
    obj.save = function(attrib, options = {}){
      var url = obj.resource_url + ".json";
      $.ajax(url,{
        type: 'PUT',
        data: {spot:attrib},
        beforeSend: function(e) {console.log('saving spot...')},
        complete: function(e){
          console.log("complete", e)
          if ('onSuccess' in options){
            console.log(options, obj)
            options.onSuccess(obj);
          }
        },
        error: function(e) {
          if ('onError' in options){
            options.onError(e);
          } else {
            console.log(e);
          }
        }
      })      
    }
    obj.delete = function(options){
      var url = obj.resource_url + ".json";
      $.ajax(url,{
        type: 'DELETE',
        data: {"id":obj.id},
        beforeSend: function(e) {console.log('removing...')},
        complete: function(e){ 
          if ('onSuccess' in options){
            options.onSuccess(e)
          }
        },
        error: function(e) {
          if ('onError' in options){
            options.onError(e);
          } else {
            console.log(e)
          }
        }
      })    
    }
    obj.circle_options = function(){
      var radius_in_um = 7.5;
      if (this.radius_in_um !== null){
        radius_in_um = this.radius_in_um;
      }
      var pos = surface.world2latLng([this.world_x, this.world_y]);
      var opts = {radius: surface.um2distance(radius_in_um, pos), surface:surface, obj:this};
      if ('stroke_color' in this && this.stroke_color !== null && this.stroke_color !== ""){
        opts.color = this.stroke_color;
      }
      if ('fill_color' in this && this.fill_color !== null && this.fill_color !== ""){
        opts.fillColor = this.fill_color;
      }
      if ('opacity' in this && this.opacity !== null && this.opacity !== ""){
        opts.fillOpacity = this.opacity;
      }
      return opts;
    }
    return obj
  },
  spots: function(options){
    var url = this.options.resourceUrl + '/spots.json';
    var surface = this;
    var obj2spot = this.obj2spot;
    $.get(url, {}, function(data){
      $(data).each(function(){
        var attrib = this;
        var spot = surface.obj2spot(attrib);
        if ('onSuccess' in options){
          options.onSuccess(spot);
        }
      });
    });
  },
  create_spot: function (attrib, options) {
    var url = this.options.resourceUrl + '/spots.json';
    var surface = this;
    $.ajax(url,{
      type: 'POST',
      data: {spot:attrib},
      beforeSend: function(e) {console.log('saving...')},
      complete: function(e){ 
        if ('onSuccess' in options){
          var obj = e.responseJSON;
          var spot = surface.obj2spot(obj);
          options.onSuccess(spot);
        }
        //marker.remove();
        //surface.loadMarkers();
      },
      error: function(e) {console.log(e)}
    })
  }
});

L.surface = function(options) {
  return new L.Surface(options);
}
L.SpotEditor = L.Class.extend({
  options: {
    placeholderHTML: ``
  },
  initialize: function (spot, options) {
    this.spot = spot;
    L.setOptions(this, options)
    this.inputs = Object.assign({});
    this.createUI()
    //this.createGeometryForm()
    //this.addDOMEvents()
  },
  createUI: function () {
    var container = L.DomUtil.create('div','surface-map-editor');
    //var _ui = this.createEditUI();
    this.ui = container;
    if (this.spot === undefined){
      this.editUI = this.createNewUI();
    } else {
      this.infoUI = this.createInfoUI();
      this.editUI = this.createEditUI();
    }
  },
  to_attrib: function(){
    attrib = this.input_values()
    var style_options = {};
    if ('style_options' in this){
      style_options = this.style_options;
      if ('color' in style_options){
        attrib['stroke_color'] = style_options.color;
      }
      if ('fillColor' in style_options){
        attrib['fill_color'] = style_options.fillColor;
      }
      if ('fillOpacity' in style_options){
        attrib['opacity'] = style_options.fillOpacity;
      }
    }
    return attrib;
  },
  input_values: function(){
    values = {};
    inputs = this.inputs
    Object.keys(inputs).forEach(function(data){
      values[data] = inputs[data].value
    });
    return values;
  },
  createNewUI: function(){
    var spotEditor = this;
    var surface = this.options.surface;
    var geometry = this.options.geometry;
    var container = L.DomUtil.create('div','surface-map-editor spot-editor', this.ui);
    var table = L.DomUtil.create(
      `table`,
      `surface-map-editor-table`,
      container
    );
    this.inputs['name'] = this.addInputRow(table, `Name`,"inputSpotName");
    //this.inputs['name'].value = spot.name;
    this.inputs['target_uid'] = this.addInputRow(table, `Link ID`,"inputSpotTarget");
    //this.inputs['target_uid'].value = spot.target_uid;
    this.inputs['world_x'] = this.addInputRow(table, `X (μm)`,"inputSpotWorldX");
    this.inputs['world_y'] = this.addInputRow(table, `Y (μm)`,"inputSpotWorldY");
    this.inputs['radius_in_um'] = this.addInputRow(table, `Radius (μm)`,"inputSpotRadius");
    //this.inputs['world_x'].value = L.surfaceNumberFormatter(spot.world_x);
    //this.inputs['world_y'].value = L.surfaceNumberFormatter(spot.world_y);
    //if ('radius_in_um' in spot && spot.radius_in_um !== null){
    //  this.inputs['radius_in_um'].value = L.surfaceNumberFormatter(spot.radius_in_um);
    //}
    var save_btn = L.DomUtil.create('button', 'btn btn-primary', container);
    save_btn.innerHTML = 'Save';
    L.DomEvent.on(save_btn, `click`, function (e) {
      attrib = spotEditor.to_attrib();
      surface.create_spot(attrib, {
        onSuccess: function(spot){
          geometry.closePopup();
          geometry._map.removeLayer(geometry);
          var pos = surface.world2latLng([spot.world_x, spot.world_y]);
          var circle = L.surfaceCircle(pos, spot.circle_options()).addTo(spotEditor.options.spotsLayer);
          spot.marker = circle;
        }
      });
    });
    var cancel_btn = L.DomUtil.create('button', 'btn btn-info', container);
    cancel_btn.innerHTML = 'Cancel';
    L.DomEvent.on(cancel_btn, `click`, function (e) {
      geometry.closePopup();
      geometry._map.removeLayer(geometry);
    });
  },
  createEditUI: function(){
    var spotEditor = this;
    var spot = this.spot;
    var surface = this.options.surface;
    var geometry = this.options.geometry;
    var container = L.DomUtil.create('div','surface-map-editor spot-editor', this.ui);
    var table = L.DomUtil.create(
      `table`,
      `surface-map-editor-table`,
      container
    );
    this.inputs['name'] = this.addInputRow(table, `Name`,"inputSpotName");
    this.inputs['name'].value = spot.name;
    this.inputs['target_uid'] = this.addInputRow(table, `Link ID`,"inputSpotTarget");
    this.inputs['target_uid'].value = spot.target_uid;
    this.inputs['world_x'] = this.addInputRow(table, `X (μm)`,"inputSpotWorldX");
    this.inputs['world_y'] = this.addInputRow(table, `Y (μm)`,"inputSpotWorldY");
    this.inputs['radius_in_um'] = this.addInputRow(table, `Radius (μm)`,"inputSpotRadius");
    this.inputs['world_x'].value = L.surfaceNumberFormatter(spot.world_x);
    this.inputs['world_y'].value = L.surfaceNumberFormatter(spot.world_y);
    if ('radius_in_um' in spot && spot.radius_in_um !== null){
      this.inputs['radius_in_um'].value = L.surfaceNumberFormatter(spot.radius_in_um);
    }
    var save_btn = L.DomUtil.create('button', 'btn btn-primary', container);
    save_btn.innerHTML = 'Save';
    var cancel_btn = L.DomUtil.create('button', 'btn btn-info', container);
    cancel_btn.innerHTML = 'Cancel';
    var delete_btn = L.DomUtil.create('button', 'btn btn-danger', container);
    delete_btn.innerHTML = 'Delete';
    //popupContent.push('<div style="text-align:center;">' + save_btn + cancel_btn + delete_btn + '</div>');
    L.DomEvent.on(save_btn, `click`, function (e) {
      attrib = spotEditor.to_attrib();
      spot.save(attrib,{
        onSuccess: function(e){
          console.log("spot.save onSuccess")
          geometry.closePopup();
          geometry._map.removeLayer(geometry);
          spot.reload({
            onSuccess: function(spot){
              console.log("spot.reload onSuccess")
              var pos = surface.world2latLng([spot.world_x, spot.world_y]);
              var circle = L.surfaceCircle(pos, spot.circle_options()).addTo(spotEditor.options.spotsLayer);
              spot.marker = circle;
            }
          });
        }
      });
    });
    L.DomEvent.on(cancel_btn, `click`, function (e) {
      geometry.closePopup();
      var pos = surface.world2latLng([spot.world_x, spot.world_y]);
      var opts = spot.circle_options()
      geometry.setLatLng(pos);
      geometry.setRadius(opts.radius);
      geometry.setStyle(opts);
    });
    L.DomEvent.on(delete_btn, `click`, function (e) {
      console.log('deleting...');
      console.log(container);
      console.log(e);
      spot.delete({onSuccess: function(){
        geometry.closePopup();
        geometry._map.removeLayer(geometry);
      }});
    });
    return container;
  },
  createInfoUI: function(){
    var spotEditor = this;
    if (this.spot === undefined){
      return;
    }
    var spot = this.spot;
    var surface = this.options.surface;
    var container = L.DomUtil.create('div','surface-map-editor spot-info', this.ui);
    var title = L.DomUtil.create('div', 'nowrap', container);
    title.innerHTML = spot.name_with_id;
    if (spot.attachment_file_id){
      var image_url = surface.resourceUrl + '/images/' + spot.attachment_file_id;
      var image = L.DomUtil.create('div', '', container);
      var label = L.DomUtil.create('span','',image);
      label.innerHTML = 'image: '
      var image_link = L.DomUtil.create('a','nowrap',image)
      image_link.href = image_url;
      image_link.innerHTML = spot.attachment_file_name;
    }
    if (spot.target_uid){
      var link = L.DomUtil.create('div', '', container);
      link.innerHTML = 'link: ' + spot['target_link'];
    }
    return container;
  },
  addDividerRow: function (tableElement, labelString) {
    let tr = tableElement.insertRow();
    let tdDivider = tr.insertCell();
    tdDivider.colSpan = 2;
    tdDivider.innerHTML = labelString;
  },
  addDataRow: function (tableElement, labelString, ) {
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
});
L.spotEditor = function(spot, options) {
  return new L.SpotEditor(spot, options);
}

L.surfaceNumberFormatter = function(number, opts = {digits:3}){
  return Number(number.toFixed(opts.digits));
}

L.SurfaceCircle = L.Circle.extend({
  getLatLngOnCircle: function (){
    var lng = this._latlng.lng,
        lat = this._latlng.lat,
        map = this._map,
        crs = map.options.crs;
    //console.log('getLatLngOnCircle...');

    var d = Math.PI / 180,
        latR = (this._mRadius / crs.R) / d,
        top = map.project([lat + latR, lng]),
        bottom = map.project([lat - latR, lng]),
        p = top.add(bottom).divideBy(2),
        lat2 = map.unproject(p).lat,
        lngR = Math.acos((Math.cos(latR * d) - Math.sin(lat * d) * Math.sin(lat2 * d)) /
            (Math.cos(lat * d) * Math.cos(lat2 * d))) / d;

        if (isNaN(lngR) || lngR === 0) {
          lngR = latR / Math.cos(Math.PI / 180 * lat); // Fallback for edge case, #2425
        }
        return L.latLng(lat2, lng - lngR);
  },
  _project: function () {

    var lng = this._latlng.lng,
        lat = this._latlng.lat,
        map = this._map,
        crs = map.options.crs;
 		if (true) {
  			var d = Math.PI / 180,
  			    latR = (this._mRadius / crs.R) / d,
  			    top = map.project([lat + latR, lng]),
  			    bottom = map.project([lat - latR, lng]),
  			    p = top.add(bottom).divideBy(2),
  			    lat2 = map.unproject(p).lat,
  			    lngR = Math.acos((Math.cos(latR * d) - Math.sin(lat * d) * Math.sin(lat2 * d)) /
  			            (Math.cos(lat * d) * Math.cos(lat2 * d))) / d;

  			if (isNaN(lngR) || lngR === 0) {
  				lngR = latR / Math.cos(Math.PI / 180 * lat); // Fallback for edge case, #2425
        }
  			this._point = p.subtract(map.getPixelOrigin());
  			this._radius = isNaN(lngR) ? 0 : p.x - map.project([lat2, lng - lngR]).x;
        this._radiusY = p.y - top.y;
  		} else {
  			var latlng2 = crs.unproject(crs.project(this._latlng).subtract([this._mRadius, 0]));

  			this._point = map.latLngToLayerPoint(this._latlng);
  			this._radius = this._point.x - map.latLngToLayerPoint(latlng2).x;
  	}        
    this._updateBounds();
  }
});
L.SurfaceCircle.addInitHook(function(){
  var surface = this.options.surface;
  var styleEditor = surface.styleEditor;
  var spotsLayer = surface.spotsLayer;
  var spot = this.options.obj;
  var spotEditor = L.spotEditor(spot, {surface: surface, geometry: this, spotsLayer: spotsLayer});
  this.options.spotEditor = spotEditor;
  popupContent = spotEditor.ui;
  this.bindPopup(popupContent, {
    maxWidth: "auto",
    minWidth: 200
  });
  this.on("popupopen", function(){
    var marker = this;
    var map = this._map;
    var spotEditor = this.options.spotEditor;
    console.log("PopupOpen");
    styleEditor.enable(this);
    this.pm.enable();
    var tempMarker = this;
    var world = surface.latLng2world(tempMarker.getLatLng());
    var latlng1 = tempMarker.getLatLng();
    var world1 = surface.latLng2world(latlng1);
    var latlng2 = tempMarker.getLatLngOnCircle();
    var world2 = surface.latLng2world(latlng2);
    var radius_in_um = surface.latLngDistance2um(latlng1, latlng2);
    spotEditor.inputs['world_x'].value = L.surfaceNumberFormatter(world[0]);
    spotEditor.inputs['world_y'].value = L.surfaceNumberFormatter(world[1]);
    spotEditor.inputs['radius_in_um'].value = L.surfaceNumberFormatter(radius_in_um);
  });
  this.on("popupclose", function(){
    console.log("PopupClose");
    styleEditor.disable(this);
    this.pm.disable();
  });
  this.on('pm:edit', e => {
    var target = e.target
    var spotEditor = target.options.spotEditor;
    var latlng1 = target._latlng;
    var world1 = surface.latLng2world(latlng1);
    var latlng2 = target.getLatLngOnCircle();
    var world2 = surface.latLng2world(latlng2);
    var radius_in_um = surface.latLngDistance2um(latlng1, latlng2);
    spotEditor.inputs['world_x'].value = L.surfaceNumberFormatter(world1[0]);
    spotEditor.inputs['world_y'].value = L.surfaceNumberFormatter(world1[1]);
    spotEditor.inputs['radius_in_um'].value = L.surfaceNumberFormatter(radius_in_um);
  });
});
L.surfaceCircle = function(latlng, options) {
  return new L.SurfaceCircle(latlng, options);
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
  var fitsLayers = {};
  var circleMarkers = [];
  var zoom = 1;
  
  var surface = L.surface({center_x: center[0], center_y: center[1], length: length, resourceUrl: resourceUrl, baseUrl: baseUrl});
  var map = L.map('surface-map', {
    maxZoom: 14,
    minZoom: 0,
    surface: {center_x: center[0], center_y: center[1], length: length, resourceUrl: resourceUrl},
    //crs: L.CRS.Simple,
    //    layers: layers
  }).setView([50.00, 14.44], 8);

  var latLng2world = function(latLng){
    point = map.project(latLng,0)
    ratio = 2*20037508.34/length
    x = (center[0] - length/2.0 + point.x * length/256);
    y = (center[1] + length/2.0 - point.y * length/256);
    return [x, y]
  };
  map.options.surface.latLng2world = latLng2world;
  surface.latLng2world = latLng2world;

  var world2latLng = function(world){
      x_w = world[0];
      y_w = world[1];
      x = (x_w - center[0] + length/2.0)*256/length
      y = (-y_w + center[1] + length/2.0)*256/length
      latLng = map.unproject([x,y],0)
      return latLng;
  };
  surface.world2latLng = world2latLng;
  var um2distance = function(um, latLng){
    var point = latLng2world(latLng); // on world
    var point2 = [point[0] + um, point[1]]; // on world
    var latLng2 = world2latLng(point2); // on Earth
    var distance = latLng.distanceTo(latLng2);
    return distance;
  }
  surface.um2distance = um2distance;
  var latLngDistance2um = function(latLng, latLng2){
    var world1 = latLng2world(latLng);
    var world2 = latLng2world(latLng2);
    um = Math.sqrt(Math.pow((world2[0] - world1[0]),2) - Math.pow((world2[1] - world1[1]),2));
    return um;
  }
  surface.latLngDistance2um = latLngDistance2um;
  var um2pix = function(um){
    umperpix = length/256/(map.getZoomScale(map.getZoom(),0));
    return um/umperpix
  }
  map.um2pix = um2pix;

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

  layerGroups.concat([{ name: "top", opacity: 100, visible: true }]).forEach(function(layerGroup) {
    var group = L.layerGroup(), name = layerGroup.name, opacity = layerGroup.opacity / 100.0, visible = layerGroup.visible, resource_url = layerGroup.resource_url, colorScale = layerGroup.colorScale, displayMin = layerGroup.displayMin, displayMax = layerGroup.displayMax;
    opts = {opacity: opacity, maxNativeZoom: 6, visible: visible, resource_url: resource_url};
    var flag = false;
    var group_fits = L.layerGroup();
    var flag_fits = false;

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
	        if (image.bounds){
            opts = Object.assign(opts, {bounds: worldBounds(image.bounds)});
          }
          if (image.max_zoom){
	          opts = Object.assign(opts, {maxNativeZoom: image.max_zoom})
          }
          L.tileLayer(baseUrl + global_id + '/' + image.id + '/{z}/{x}_{y}.png', opts).addTo(group);
          flag = true;
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
          //L.leafletFitsGL(image.path, 
          //  Object.assign(opts, {
          //    bounds: b_bounds,
          //    corners: image.corners, 
          //    visible:visible, 
          //    latLng2world: latLng2world, 
          //    world2latLng: world2latLng,  
          //    renderer: L.LeafletFitsGL.plotty(ploty_opts)}
          //  )  
          //).addTo(group);
          flag_fits = true;
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
      if (flag_fits){
        fitsLayers[name] = group_fits;
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
  surface.spotsLayer = spotsLayer;
  var styleEditor =  L.control.styleEditor({
    useGrouping: false,
    forms: {'geometry': {'color': true, fillColor: true, fillOpacity: true }},
  });
  surface.styleEditor = styleEditor;
  map.on('styleeditor:changed', function(element){
    console.log('styleeditor:changed');
    var options = Object.assign({}, element.options)
    if ('obj' in element.options) {
      var obj = element.options.obj;
      delete options.obj;
    }
    delete options.radius;
    if ('spotEditor' in element.options){
      var spotEditor = element.options.spotEditor;
      delete options.spotEditor;
      delete options.surface;
      spotEditor.style_options = options;
    }
  });
  map.on('pm:create', e => {
    console.log(e);
    var pos = e.layer._latlng;
    var opts = e.layer.options;
    opts.surface = surface;
    var circle = L.surfaceCircle(pos, opts).addTo(spotsLayer);
    map.removeLayer(e.layer);
    circle.openPopup();
  });

  surface.spots({
    onSuccess: function(spot){
      var pos = world2latLng([spot.world_x, spot.world_y]);
      var circle = L.surfaceCircle(pos, spot.circle_options()).addTo(spotsLayer);
      spot.marker = circle;
    }
  });

  L.control.surfaceScale({ imperial: false, length: length }).addTo(map);

  //L.control.layers(baseMaps, overlayMaps).addTo(map);
  L.control.surfaceLayers(baseMaps, overlayMaps, {collapsed:false, fitsLayers: fitsLayers}).addTo(map);
  if (bounds){
    map.fitBounds(bounds);
  } else {
    map.setView(map.unproject([256 / 2, 256 / 2], 0), zoom);
  }
  map.addControl(new L.Control.Fullscreen());
  
  map.pm.addControls({
    position: 'topleft',
    drawMarker: false,
    drawCircleMarker: false,
    drawPolyline: false,
    drawRectangle: false,
    drawPolygon: false,
    drawCircle: true,
    editMode: false,
    dragMode: false,
    cutPolygon: false,
    removalMode: false
  });
  const customTranslation = {
    tooltips: {
      //placeMarker: 'Custom Marker Translation',
      startCircle: "Click to locate spot",
      finishCircle: "Click to set radius",      
    },
    buttonTitles: {
      "drawCircleButton": "Add spot",
    }    
  };
  map.pm.setLang('customName', customTranslation, 'en');

  map.addControl(styleEditor);
  L.control.viewMeta({position: `bottomleft`, enableUserInput: true, latLng2world: latLng2world, world2latLng: world2latLng, customLabelFcn: map_LabelFcn}).addTo(map);
  map.on('zoomend', function(e) {
    var currentZoom = map.getZoom();
    //console.log("Current Zoom" + " " + currentZoom);
    for(var i=0; i<circleMarkers.length; i++){
     circleMarkers[i].setRadius(um2pix(5.0));
    }
  });  
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

