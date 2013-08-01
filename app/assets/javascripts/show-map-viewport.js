var Photo = function(elem) {
  this.$elem = $(elem);
  this.lat = +this.$elem.data('lat');
  this.lng = +this.$elem.data('lng');
  this.coords = {lat: this.lat, lng: this.lng};
  this.colors = this.$elem.data('colors');
};

Photo.prototype.intColorR = function() {
  var subHexR = this.colors.color4.substr(1,2);
  return parseInt(subHexR, 16);
};

Photo.prototype.intColorG = function() {
  var subHexG = this.colors.color4.substr(3,2);
  return parseInt(subHexG, 16);
};

Photo.prototype.intColorB = function() {
  var subHexB = this.colors.color4.substr(5,2);
  return parseInt(subHexB, 16);
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

Photo.prototype.vertCenter = function() {
  return this.top() + this.height() / 2;
}

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
  return (this.vertCenter()) - windowCenter;
};

Photo.prototype.lineStartCoords = function(windowTop, windowLeft) {
  return {y: this.vertCenter() - windowTop,
             x: this.left() + this.width() - windowLeft}
};

Photo.prototype.showLine = function(windowTop, windowHeight) {
  var hideBottom = windowTop + windowHeight + windowHeight * 0.5;
  var hideTop = windowTop - windowHeight * 0.5;
  if (this.vertCenter() > hideTop && this.vertCenter() < hideBottom) {
    return true;
  } else {
    return false;
  }
};

var ViewPort = {
  photos: [],
  svg: null,
  $window: null,
  $titleBar: null,

  initialize: function() {
    this.$window = $(window);
    this.$titleBar = $('.title-bar');
    $(document).on('scroll', ViewPort.update);
    this.$window.on('load', ViewPort.update);
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
    for(var i = 1; i < coords.length; i++) {
      gmap.drawRoute([coords[i-1], coords[i]])
    }
  },

  resize: function() {
    if (!this.$window) {
      this.$window = $(window);
    }

    var maxHeight = this.$window.height() * 0.9;
    var maxWidth = this.$window.width() * 0.5;

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


    // $('.line').css('opacity', opacity);

    ViewPort.drawLines(data);
    if (prevPhoto || nextPhoto) {
      ViewPort.panBetween(prevPhoto, prevOffset, nextPhoto, nextOffset);
    }
  },

  panBetween: function(prevPhoto, prevOffset, nextPhoto, nextOffset) {
    if(!prevPhoto && nextPhoto) {
      gmap.pan(nextPhoto.lat, nextPhoto.lng);
      this.$titleBar.css('background', nextPhoto.colors.color4);
      $('.line').css('stroke', nextPhoto.colors.color4);
    } else if (!nextPhoto && prevPhoto) {
      gmap.pan(prevPhoto.lat, prevPhoto.lng);
      this.$titleBar.css('background', prevPhoto.colors.color4);
      $('.line').css('stroke', nextPhoto.colors.color4);
    } else {
      var offsetDiff = prevOffset - nextOffset;
      var linearMod = prevOffset / offsetDiff;
      var positionMod = 1 / (1 + Math.pow(Math.E, (-15*(linearMod-0.5))));

      var prevLat = prevPhoto.lat;
      var nextLat = nextPhoto.lat;
      var latDiff = nextLat - prevLat;
    
      if (Math.abs(latDiff) > 180) {
        latDiff = 360 - Math.abs(latDiff)
      }

      var newLat = prevLat + latDiff * positionMod;

      var prevLng = prevPhoto.lng;
      var nextLng = nextPhoto.lng;
      var lngDiff = nextLng - prevLng;
  
      if (Math.abs(lngDiff) > 180) {
        lngDiff = 360 - Math.abs(lngDiff);
      }

      var newLng = prevLng + lngDiff * positionMod;

      gmap.pan(newLat, newLng);
      ViewPort.restyleTitleBar(prevPhoto, nextPhoto, linearMod);
    }
  },

  restyleTitleBar: function(prevPhoto, nextPhoto, linearMod) {
    var decColorR = prevPhoto.intColorR() + (nextPhoto.intColorR() - prevPhoto.intColorR()) * linearMod;
    var decColorG = prevPhoto.intColorG() + (nextPhoto.intColorG() - prevPhoto.intColorG()) * linearMod;
    var decColorB = prevPhoto.intColorB() + (nextPhoto.intColorB() - prevPhoto.intColorB()) * linearMod;

    var newColorR = Math.round(decColorR).toString(16)
    if (newColorR.length == 1) newColorR = "0" + newColorR;
    var newColorG = Math.round(decColorG).toString(16)
    if (newColorG.length == 1) newColorG = "0" + newColorG; 
    var newColorB = Math.round(decColorB).toString(16)
    if (newColorB.length == 1) newColorB = "0" + newColorB; 
    var newColor = '#' + newColorR + newColorG + newColorB;
    this.$titleBar.css('background', newColor);
    $('.line').css('stroke', newColor);
    // $('.photo').css('-moz-box-shadow', '0 0 19px ' + newColor) //wishful thinking
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