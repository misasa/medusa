function copy_data(dd, wd){
    for(var k=0; k<dd.shape[0]; ++k) {
      for(var j=0; j<dd.shape[1]; ++j) {
        wd.set(k,j,dd.get(k,j))
      }
    }
}

function plotDataArray(id, data_array, opts = {}){
    var ndata = data_array.length;
    var width = 1000;
    var pad_x = 10;
    var pad_y = 10;
    if ('width' in opts){
      width = opts.width;
    }
    if ('padding' in opts){
      [pad_y, pad_x] = opts.padding;
    }

    var width_region = 0;
    var height_region = 0;
    for(var i =0; i < ndata; i++){
      [h,w] = data_array[i].shape;
      if (w > width_region){
        width_region = w;
      }
      if (h > height_region){
        height_region = h;
      }
    }
    var width_cell = width_region + pad_x*2;
    var height_cell = height_region + pad_y*2;
    ncol = Math.floor(width/width_cell);
    nrow = Math.ceil(ndata/ncol);
    
    var width_canvas = width_cell*ncol;
    var margin = (width - width_canvas)/2;
    var height_canvas = height_cell*nrow;
    var ad = ndarray(new Float32Array(height_cell*width*ncol*nrow), [height_canvas, width])
    var col = 0;
    var row = 0;
    for(var ii = 0; ii < ndata; ii++){
      var dd = data_array[ii];
      var start_x = col * width_cell + pad_x + margin;
      var end_x = start_x + width_cell - 1;
      var start_y = row * height_cell + pad_y; 
      var end_y = start_y + height_cell - 1;
      
      var wd = ad.hi(end_y,end_x).lo(start_y,start_x)
      copy_data(dd, wd);
  
      if (col < (ncol - 1)){
        col++
      } else {
        col = 0
        row++
      }
    }
    var cnt = 0;
    for (var row = 0; row < nrow; row++ ){
      for (var col = 0; col < ncol; col++){
        cnt++;
      }
    }
    plotty_opts = {
      canvas: document.getElementById(id),
      data: ad.data, width: ad.shape[1], height: ad.shape[0],
      domain: [-1, 1], colorScale: 'viridis'
    };
    if ('colorScale' in opts){
      plotty_opts.colorScale = opts.colorScale;
    }
    if ('domain' in opts){
      plotty_opts.domain = opts.domain;
    }
    plot = new plotty.plot(plotty_opts);
    plot.render();  
}
