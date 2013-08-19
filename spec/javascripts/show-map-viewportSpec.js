describe('Photo', function() {
  var photo;
  var elem;

  beforeEach(function() {
    elem = '<img data-lat="100" data-lng="200" data-colors=' + JSON.stringify({"color1":"#111111","color2":"#222222","color3":"#333333","color4":"#444444","color5":"#555555","color6":"#666666"}) + ' style="height: 50px; width: 100px">'
    photo = new Photo(elem);
    photo.top = function() {
      return 200;
    };

    photo.left = function() {
      return 50;
    }
  });


  describe('$elem', function() {
    it('is a jQuery object of the DOM element', function() {
      expect(photo.$elem.html()).toEqual($(elem).html())
    })
  })

  describe('colors', function() {
    it('is an object holding six colors', function() {
      expect(photo.colors).toEqual({"color1":"#111111","color2":"#222222","color3":"#333333","color4":"#444444","color5":"#555555","color6":"#666666"})
    })
  })

  describe('lat', function() {
    it('is is the lat value', function() {
      expect(photo.lat).toEqual(100)
    })
  })

  describe('lng', function() {
    it('is the lng value', function() {
      expect(photo.lng).toEqual(200)
    })
  })

  describe('coords', function() {
    it('is an object holding lat and lng values', function() {
      expect(photo.coords).toEqual({lat: 100, lng: 200})
    })
  })

  describe('#intColorR', function() {
    it('returns the integer representation of the R portion of the photo color', function() {
      expect(photo.intColorR()).toEqual(parseInt('44', 16))
    })
  })

  describe('#intColorG', function() {
    it('returns the integer representation of the G portion of the photo color', function() {
      expect(photo.intColorG()).toEqual(parseInt('44', 16))
    })
  })

  describe('#intColorB', function() {
    it('returns the integer representation of the B portion of the photo color', function() {
      expect(photo.intColorB()).toEqual(parseInt('44', 16))
    })
  })

  describe('#height', function() {
    it('returns the height', function() {
      expect(photo.height()).toBe(50);
    });
  });

  describe('#width', function() {
    it('returns the width', function() {
      expect(photo.width()).toBe(100);
    });
  });

  describe('#vertCenter', function() {
    it('returns the vertical position of the center of the photo in pixels', function() {
      expect(photo.vertCenter()).toBe(225)
    });
  });

  describe('#vertOffset', function() {
    it('returns the vertical distance from the center of the photo in pixels', function() {
      expect(photo.vertOffset(500)).toBe(-275)
    });
  });

  describe('#lineStartCoords', function() {
    it('returns an object holding the x and y values of the right center point in pixels', function() {
      expect(photo.lineStartCoords(500, 0)).toEqual({y: -275, x: 150})
    });
  });

  describe('#showLine', function(){
    it('returns true when within bounds of where a line should be shown', function() {
      expect(photo.showLine(-900, 800)).toBe(true)
    })

    it('returns false when outside the bounds of where a line should be shown', function() {
      expect(photo.showLine(700, 800)).toBe(false)
    })
  })

  describe('#resize', function() {
    beforeEach(function() {
      $elem = $('<img data-lat="100" data-lng="200">')
      $elem.height('100px');
      $elem.width('100px');
      p = new Photo($elem);
    });

    describe('when photo height/width is greater than constraints', function() {
      describe('when constraints are smaller than photo', function() {
        it('decreases height to maxHeight', function() {
          p.resize(90, 100);
          expect(p.height()).toBe(90);
        });
      });

      describe('when constraints are larger than photo', function() {
        it('increases height to maxHeight', function() {
          p.resize(180, 200);
          expect(p.height()).toBe(180);
        });
      });
    });

    describe('when photo height/width is less than constraints', function() {
      describe('when constraints are smaller than photo', function() {
        it('decreases width to maxWidth', function() {
          p.resize(100, 90);
          expect(p.width()).toBe(90);
        });
      });

      describe('when constraints are larger than photo', function() {
        it('increases width to maxWidth', function() {
          p.resize(200, 180);
          expect(p.width()).toBe(180);
        });
      });
    });
  });
});

describe('ViewPort', function() {
  var svg, $window, fakeCoords;



  beforeEach(function() {
    fakeCoords = [
      {lat: 100, lng: 50},
      {lat: 200, lng: 100},
      {lat: 300, lng: 150},
      {lat: 400, lng: 200},
      {lat: 500, lng: 250}
    ];
    ViewPort.photos = [];
    for(var i = 0; i < 5; i++) {
      $elem = $('<img data-lat="' + (i*100 + 100) + '" data-lng="' + (i*50 + 50) + '">')
      $elem.height('100px');
      $elem.width('100px');
      p = new Photo($elem);
      ViewPort.photos.push(p);
    };

    svg = {
      selectAll: function(selector) {
        return {data: function(array) {}}
      }
    };

    $window = {
      scrollTop: function() {
        return 100;
      },
      scrollLeft: function() {
        return 150;
      },
      height: function() {
        return 200;
      },
      width: function() {
        return 250;
      }
    };
  });

  describe('onMapReady', function() {
    it('calls drawRoutes with readPhotosCoords() as param', function() {
      spyOn(ViewPort, 'drawRoutes');
      spyOn(ViewPort, 'readPhotosCoords').andCallThrough();

      ViewPort.onMapReady();

      expect(ViewPort.readPhotosCoords).toHaveBeenCalled();
      expect(ViewPort.drawRoutes).toHaveBeenCalledWith(fakeCoords);
    });
  });

  describe('#readPhotosCoords', function() {
    it('returns an array of coordinates from photos', function() {
      expect(ViewPort.readPhotosCoords()).toEqual(fakeCoords);
    });
  });

  describe('#resize', function() {
    it('calls resize on each photo', function() {
      for(i = 0; i < ViewPort.photos.length; i++) {
        spyOn(ViewPort.photos[i], 'resize');
      }
      ViewPort.resize();
      for(i = 0; i < ViewPort.photos.length; i++) {
        expect(ViewPort.photos[i].resize).toHaveBeenCalled();
      }
    });
  });
});
