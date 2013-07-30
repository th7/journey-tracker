var imgur_uploader = function(){

	/* Drag'n drop stuff */
	window.ondragover = function(e) {e.preventDefault()}
	window.ondrop = function(e) {e.preventDefault(); dropHandler(e.dataTransfer.files); }

	self.dropHandler = function(files){
	  uploadImage(files,files.length-1);
	}

	self.uploadImage = function(files,numRemaining) {

	      date_created = null;
	      lat = null;
	      lon = null;
	      latRef = null;
	      lonRef = null;
	      response = null;
	      dataUrl = null;

	  if(numRemaining>=0){

	    /* Is the file an image? */
	    if (!files[numRemaining].type.match(/image.*/)) uploadImage(files,numRemaining-1);

	    $("#counter").html("<p>Uploading! "+(numRemaining+1)+" images remaining...</p>")
	    console.log(numRemaining)
	    console.log(files[numRemaining])

	    var file = files[numRemaining]
	    fr = new FileReader;
	    
	    // Preview image
	    disp = new FileReader;
	    disp.onload = function(e) {
	    	var $preview_area = $('#preview_area')
			  var $img = ($preview_area.append("<div class='uploading_image'><img class='image_preview'></div>").children().children().last());
			  $preview_area.children().last().append("<div class='loader'><img src='http://www.nasa.gov/offices/oct/partnership/videogallery/ajax-loader.gif'></div>");
				$img.attr('src', e.target.result);
	    }
	    disp.readAsDataURL(file);


	    fr.onloadend = function() {
	      var exif = EXIF.readFromBinaryFile(new BinaryFile(this.result));  
	      date_created = (exif.DateTimeDigitized);
	      lat = (exif.GPSLatitude);
	      lon = (exif.GPSLongitude);
	      latRef = (exif.GPSLatitudeRef);
	      lonRef = (exif.GPSLongitudeRef);
	    };
	    fr.readAsBinaryString(file);


	    /* Lets build a FormData object*/
	    var fd = new FormData(); // I wrote about it: https://hacks.mozilla.org/2011/01/how-to-develop-a-html5-image-uploader/

	    fd.append("image", file); // Append the file
	    var xhr = new XMLHttpRequest(); // Create the XHR (Cross-Domain XHR FTW!!!) Thank you sooooo much imgur.com
	    xhr.open("POST", "https://api.imgur.com/3/image.json"); // Boooom!
	    xhr.onload = function () {
	        response = JSON.parse(xhr.responseText).data.link;
	        $('.loader').last().hide();
	    }
	    xhr.setRequestHeader('Authorization', 'Client-ID 410a62cc1627046');

	    /* And now, we send the formdata */
	    xhr.send(fd);
	    xhr.addEventListener("load", transferComplete, false);
	    function transferComplete(evt) {
	      $.ajax({
	        url: "/photos",
	        type: "post",
	        data: {url: response,
	              date: date_created,
	              lat: lat,
	              lon: lon,
	              latRef: latRef,
	              lonRef: lonRef
	        }
	      });
	      uploadImage(files,numRemaining-1);
	    }
	  };
	};
};