var Photo = function(elem) {
  this.$elem = $(elem);
  this.lat = +this.$elem.data('lat');
  this.lng = +this.$elem.data('lng');
  this.coords = {lat: this.lat, lng: this.lng};
};

Photo.prototype.resize = function(maxHeight, maxWidth) {
  var photoHW = this.$elem.height() / this.$elem.width();

  if (photoHW > maxHeight / maxWidth) {
    this.$elem.css('width', 'auto');
    this.$elem.css('height', maxHeight);
  } else {
    this.$elem.css('height', 'auto');
    this.$elem.css('width', maxWidth);
  }
};

var ViewPort = {
  initialize: function() {
    this.$window = $(window);
    $(document).on('scroll', ViewPort.update);
    this.$window.on('load', ViewPort.resize);
    this.$window.on('resize', ViewPort.resize);
    this.svg = d3.select("svg");
    ViewPort.$photos = $('.photo');
    for (var i = 0; i < ViewPort.$photos.length; i++) {
      ViewPort.photos.push(new Photo(ViewPort.$photos[i]));
    }
    this.initialized = true;
  },

  $photos: null,
  photos: [],
  svg: null,
  $window: null,
  initialized: false,

  onMapReady: function() {
    if (this.initialized) {
      this.drawRoutes(this.readPhotosCoords());
    } else {
      console.log('onMapReady before intialized, retrying in 100ms');
      setTimeout(onMapReady, 100);
    }
  },

  readPhotosCoords: function() {
    var coords = [];
    for (var i = 0; i < ViewPort.photos.length; i++) {
      img = ViewPort.photos[i];

      if (img.lat > 0) {
        coords.push(img.coords);
      }
    }
    return coords;
  },

  drawRoutes: function(coords) {
    for(i in coords) {
      if (i > 0) {
        gmap.drawRoute([coords[i-1], coords[i]])
      }
    }
  },

  resize: function() {
    if (!this.$window) {
      this.$window = $(window);
    }
    // var $window = $(window);
    // var $document= $(document);
    var maxHeight = this.$window.height() * 0.9;
    var maxWidth = this.$window.width() * 0.5;
    // var scrollMod = $window.scrollTop() / ($document.height() - $window.height());
    var windowHW = maxHeight / maxWidth;

    for (i=0; i<ViewPort.$photos.length; i++) {
      ViewPort.photos[i].resize(maxHeight, maxWidth);
    }
    // var newScrollTop = scrollMod * ($document.height() - $window.height());
    // $window.scrollTop(newScrollTop);
  },

  update: function() {
    if (!this.$window) {
      this.$window = $(window);
    }
    var data = [];
    // this.$window = $(window);

    var windowTop = this.$window.scrollTop();
    var windowLeft = this.$window.scrollLeft();
    var windowHeight = this.$window.height();
    var hideBottom = windowTop + windowHeight + windowHeight * 0.5;
    var hideTop = windowTop - windowHeight * 0.5;

    var $prevPhoto = null;
    var $nextPhoto = null;

    var prevOffset = -100000000;
    var nextOffset = +100000000;

    for (var i = 0; i < ViewPort.$photos.length; i++) {
      $img = $(ViewPort.$photos[i]);

      var imgTop = $img.offset().top;
      var imgLeft = $img.offset().left;
      var imgHeight = $img.height();
      var imgWidth = $img.width();

      if ($img.data('lat')) {
        var divOffset = (imgTop + imgHeight / 2) - (windowTop + windowHeight / 2);
        
        if (divOffset < 0 && divOffset > prevOffset) {
          prevOffset = divOffset;
          $prevPhoto = $img;
        } else if (divOffset > 0 && divOffset < nextOffset) {
          nextOffset = divOffset;
          $nextPhoto = $img;
        }

        if (imgTop + imgHeight / 2 > hideTop && imgTop + imgHeight / 2 < hideBottom) {
          var startCoord = 
            {"y": imgTop + imgHeight / 2 - windowTop,
             "x": imgLeft + imgWidth - windowLeft};
          
          var endCoord = 
            gmap.getPixelPos(+$img.data('lat'), +$img.data('lng'));

          if (startCoord.x < endCoord.x) {
            data.push([startCoord, endCoord]);
          }
        }
      }
    }

    ViewPort.panBetween($prevPhoto, prevOffset, $nextPhoto, nextOffset);

    ViewPort.drawLines(data);
  },

  panBetween: function($prevPhoto, prevOffset, $nextPhoto, nextOffset) {
    if(!$prevPhoto && $nextPhoto) {
      gmap.pan(+$nextPhoto.data('lat'), +$nextPhoto.data('lng'))
    } else if (!$nextPhoto && $prevPhoto) {
      gmap.pan(+$prevPhoto.data('lat'), +$prevPhoto.data('lng'))
    } else {
      var offsetDiff = prevOffset - nextOffset;
      var linearMod = prevOffset / offsetDiff;
      var mod = 1 / (1 + Math.pow(Math.E, (-15*(linearMod-0.5))));

      var prevLat = $prevPhoto.data('lat');
      var nextLat = $nextPhoto.data('lat');
      var latDiff = nextLat - prevLat;
    
      if (Math.abs(latDiff) > 180) {
        latDiff = 360 - Math.abs(latDiff)
      }

      var newLat = prevLat + latDiff * mod;

      var prevLng = $prevPhoto.data('lng');
      var nextLng = $nextPhoto.data('lng');
      var lngDiff = nextLng - prevLng;
  
      if (Math.abs(lngDiff) > 180) {
        lngDiff = 360 - Math.abs(lngDiff)
      }

      var newLng = prevLng + lngDiff * mod;

      gmap.pan(newLat, newLng);
    }
  },

  drawLines: function(data) {
    var line = d3.svg.line()
      .interpolate(ViewPort.interpolateSankey)
      .x(function(d) { return d.x; })
      .y(function(d) { return d.y; });

    var path = ViewPort.svg.selectAll('path').data(data);

    path.attr('d', line);

    path.enter().append('path')
        .attr('class', 'line')
        .attr('d', line);

    path.exit().remove();
  },

  // http://bl.ocks.org/mbostock/3960741
  interpolateSankey: function(points) {
    var x0 = points[0][0], y0 = points[0][1], x1, y1, x2,
        path = [x0, ",", y0],
        i = 0,
        n = points.length;
    while (++i < n) {
      x1 = points[i][0], y1 = points[i][1], x2 = (x0 + x1) / 2;
      path.push("C", x2, ",", y0, " ", x2, ",", y1, " ", x1, ",", y1);
      x0 = x1, y0 = y1;
    }
    return path.join("");
  }  
};