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
  var zoom = 1;
  
  var map = L.map('surface-map', {
    maxZoom: 14,
    minZoom: 0,
    surface: {center_x: center[0], center_y: center[1], length: length},
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
  loadMarkers();

  L.control.surfaceScale({ imperial: false, length: length }).addTo(map);

  //L.control.layers(baseMaps, overlayMaps).addTo(map);
  L.control.surfaceLayers(baseMaps, overlayMaps, {collapsed:false, fitsLayers: fitsLayers}).addTo(map);
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
  //L.control._viewMeta({position: `topleft`, enableUserInput: true, latLng2world: latLng2world, world2latLng: world2latLng, customLabelFcn: map_LabelFcn}).addTo(map);
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

