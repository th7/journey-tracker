var Photo = function(elem) {
  this.$elem = $(elem);
  this.lat = +this.$elem.data('lat');
  this.lng = +this.$elem.data('lng');
  this.coords = {lat: this.lat, lng: this.lng};
};

Photo.prototype.top = function() {
  return this.$elem.offset().top;
};

Photo.prototype.left = function() {
  return this.$elem.offset().left;
};

Photo.prototype.height = function() {
  return this.$elem.height();
};

Photo.prototype.width = function() {
  return this.$elem.width();
};

Photo.prototype.resize = function(maxHeight, maxWidth) {
  var photoHW = this.height() / this.width();

  if (photoHW > maxHeight / maxWidth) {
    this.$elem.css('width', 'auto');
    this.$elem.css('height', maxHeight);
  } else {
    this.$elem.css('height', 'auto');
    this.$elem.css('width', maxWidth);
  }
};

Photo.prototype.vertOffset = function(windowCenter) {
  return (this.top() + this.height() / 2) - windowCenter;
};

Photo.prototype.lineStartCoords = function(windowTop, windowLeft) {
  return {y: this.top() + this.height() / 2 - windowTop,
             x: this.left() + this.width() - windowLeft}
};

Photo.prototype.showLine = function(windowTop, windowHeight) {
  var hideBottom = windowTop + windowHeight + windowHeight * 0.5;
  var hideTop = windowTop - windowHeight * 0.5;
  if (this.top() + this.height() / 2 > hideTop && this.top() + this.height() / 2 < hideBottom) {
    return true;
  } else {
    return false;
  }
};

var ViewPort = {
  photos: [],
  svg: null,
  $window: null,

  initialize: function() {
    this.$window = $(window);
    $(document).on('scroll', ViewPort.update);
    this.$window.on('load', ViewPort.resize);
    this.$window.on('resize', ViewPort.resize);
    this.svg = d3.select("svg");
    $photos = $('.photo');
    for (var i = 0; i < $photos.length; i++) {
      ViewPort.photos.push(new Photo($photos[i]));
    }
  },

  onMapReady: function() {
    this.drawRoutes(this.readPhotosCoords());
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

    var maxHeight = this.$window.height() * 0.9;
    var maxWidth = this.$window.width() * 0.5;
    var windowHW = maxHeight / maxWidth;

    for (i=0; i<ViewPort.photos.length; i++) {
      ViewPort.photos[i].resize(maxHeight, maxWidth);
    }
  },

  update: function() {
    if (!this.$window) {
      this.$window = $(window);
    }
    var data = [];

    var windowTop = this.$window.scrollTop();
    var windowLeft = this.$window.scrollLeft();
    var windowHeight = this.$window.height();
    var windowCenter = windowTop + windowHeight / 2

    var prevPhoto = null;
    var nextPhoto = null;

    var prevOffset = -100000000;
    var nextOffset = +100000000;

    for (var i = 0; i < ViewPort.photos.length; i++) {
      img = ViewPort.photos[i];

      if (img.lat > 0) {
        var imgOffset = img.vertOffset(windowCenter);
        
        if (imgOffset < 0 && imgOffset > prevOffset) {
          prevOffset = imgOffset;
          prevPhoto = img;
        } else if (imgOffset > 0 && imgOffset < nextOffset) {
          nextOffset = imgOffset;
          nextPhoto = img;
        }

        if (img.showLine(windowTop, windowHeight)) {
          var startCoord = img.lineStartCoords(windowTop, windowLeft);
          
          var endCoord = gmap.getPixelPos(img.lat, img.lng);

          if (startCoord.x < endCoord.x) {
            data.push([startCoord, endCoord]);
          }
        }
      }
    }

    ViewPort.panBetween(prevPhoto, prevOffset, nextPhoto, nextOffset);

    ViewPort.drawLines(data);
  },

  panBetween: function(prevPhoto, prevOffset, nextPhoto, nextOffset) {
    if(!prevPhoto && nextPhoto) {
      gmap.pan(nextPhoto.lat, nextPhoto.lng)
    } else if (!nextPhoto && prevPhoto) {
      gmap.pan(prevPhoto.lat, prevPhoto.lng)
    } else {
      var offsetDiff = prevOffset - nextOffset;
      var linearMod = prevOffset / offsetDiff;
      var mod = 1 / (1 + Math.pow(Math.E, (-15*(linearMod-0.5))));

      var prevLat = prevPhoto.lat;
      var nextLat = nextPhoto.lat;
      var latDiff = nextLat - prevLat;
    
      if (Math.abs(latDiff) > 180) {
        latDiff = 360 - Math.abs(latDiff)
      }

      var newLat = prevLat + latDiff * mod;

      var prevLng = prevPhoto.lng;
      var nextLng = nextPhoto.lng;
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