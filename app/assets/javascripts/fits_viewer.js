FitsViewer = function(id, fitsImages, options){
    data_array = [];
    displayRange = options.displayRange;
    colorScale = options.colorScale;
    this.fitsImages = fitsImages,
    this.colorScale = options.colorScale;
    this.displayRange = options.displayRange;

    this.data_array = data_array;
    this.setColorScale = function(colorScale){
        this.colorScale = colorScale;
    }
    this.setDisplayMin = function(displayMin){
        this.displayRange[0] = displayMin;
    }
    this.setDisplayMax = function(displayMax){
        this.displayRange[1] = displayMax;
    }
    var render_plot = function(){
        plotDataArray("fits-canvas", this.data_array, {
            width: 1100,
            padding: [5,5],
            domain: this.displayRange, 
            colorScale: this.colorScale
        });
    }
    this.render = render_plot
    var load_callback = function(data){
        this.data_array.push(data);
        if (this.data_array.length >= fitsImages.length){
            render_plot();
        }  
    }
    var fits_callback = function(){
        var hdu = this.getHDU();
        var header = hdu.header;
        var bitpix = header.get('BITPIX');
        var dataunit = hdu.data;
        var height = hdu.data.height;
        var width = hdu.data.width;
        var buf = dataunit.buffer;
        var dataview = new DataView(buf);
        var exampledata = new Float64Array(height * width);
        byteOffset = 0;
        for (y = 0; y < height; y++) {
            for (x = 0; x < width; x++) {
                exampledata[(y * width) + x] = dataview.getFloat64(byteOffset);
                byteOffset += 8;
            }
        }
        cnt_load++;
        load_callback(ndarray(exampledata, [height, width]));
    }
    this.loadFitsData = function(){
        var FITS = astro.FITS;
        var displayMinDefault = +Infinity, displayMaxDefault = -Infinity;      
        var fitsImages = this.fitsImages;
        cnt_load = 0;
        for (var i =0; i < fitsImages.length; i++){
            [d_r_min, d_r_max] = fitsImages[i].default_display_range;
            if (d_r_min < displayMinDefault){
                displayMinDefault = d_r_min;            
            } 
            if (d_r_max > displayMaxDefault){
                displayMaxDefault = d_r_max;            
            }
            new FITS(fitsImages[i].path, fits_callback);
        }
        this.displayMinDefault = displayMinDefault;
        this.displayMaxDefault = displayMaxDefault;
    }

    this.loadFitsData();
}
function initFitsViewer() {
    var div = document.getElementById("fits-viewer");
    var baseUrl = div.dataset.baseUrl;
    var displayMax = div.dataset.displayMax;
    var displayMin = div.dataset.displayMin;
    var colorScale = div.dataset.colorScale;
    var fitsImages = JSON.parse(div.dataset.fitsImages);
    var fits_viewer = new FitsViewer("fits-viewer", fitsImages, {
            colorScale: colorScale,
            displayRange: [displayMin, displayMax]
        });
    return fits_viewer;
}  
  