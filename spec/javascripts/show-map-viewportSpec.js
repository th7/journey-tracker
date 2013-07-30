describe('Photo', function() {
  var photo;

  beforeEach(function() {
    $elem = $('<img data-lat="100" data-lng="200">')
    $elem.height('50px');
    $elem.width('100px');
    photo = new Photo($elem[0]);
  });

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

  describe('#lat', function() {
    it('holds the latitude', function() {
      expect(photo.lat).toBe(100);
    });
  });

  describe('#lng', function() {
    it('holds the longitude', function() {
      expect(photo.lng).toBe(200);
    });
  });

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
  var svg, $window, fakeCoords, gmap;

  fakeCoords = [
    {lat: 100, lng: 100},
    {lat: 100, lng: 100},
    {lat: 100, lng: 100},
    {lat: 100, lng: 100},
    {lat: 100, lng: 100}
  ];

  beforeEach(function() {
    ViewPort.photos = [];
    for(var i = 0; i < 5; i++) {
      $elem = $('<img data-lat="100" data-lng="100">')
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
    

    gmap = {};
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

  describe('#drawRoutes', function() {
    it('calls gmap.drawRoute with each consequtive pair of coords', function() {
      gmap.drawRoute = jasmine.createSpy('drawRoute');
      ViewPort.drawRoutes(fakeCoords);
      expect(gmap.drawRoute.calls.length).toEqual(fakeCoords.length-1);
    });
  });
});