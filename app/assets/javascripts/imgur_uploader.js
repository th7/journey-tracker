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

	  if(numRemaining>=0){

	    $("#results").append("<p>Uploading! "+(numRemaining+1)+" images remaining...</p>")

	    /* Is the file an image? */
	    if (!files[numRemaining] || !files[numRemaining].type.match(/image.*/)) return;

	    // Alert the EXIF data (need to include the vendor files)
	    var file = files[numRemaining]
	    fr = new FileReader;
	    fr.onloadend = function() {
	      var exif = EXIF.readFromBinaryFile(new BinaryFile(this.result));  
	      date_created = (exif.DateTimeDigitized);
	      lat = (exif.GPSLatitude);
	      lon = (exif.GPSLongitude);
	      latRef = (exif.GPSLatitudeRef);
	      lonRef = (exif.GPSLongitudeRef);
	    };
	    fr.readAsBinaryString(file);

	    // /* It is! */
	    // document.body.className = "uploading";

	    /* Lets build a FormData object*/
	    var fd = new FormData(); // I wrote about it: https://hacks.mozilla.org/2011/01/how-to-develop-a-html5-image-uploader/

	    fd.append("image", files[numRemaining]); // Append the files[numRemaining]
	    var xhr = new XMLHttpRequest(); // Create the XHR (Cross-Domain XHR FTW!!!) Thank you sooooo much imgur.com
	    xhr.open("POST", "https://api.imgur.com/3/image.json"); // Boooom!
	    xhr.onload = function () {
	        response = JSON.parse(xhr.responseText).data.link;
	        $("#results").append("<p>"+response+"</p>");
	    }
	    xhr.setRequestHeader('Authorization', 'Client-ID 410a62cc1627046');

	    /* And now, we send the formdata */
	    xhr.send(fd);

	    // // addEventListener doesnt work for files, only images
	    // xhr.addEventListener("progress", updateProgress, false);
	    // function updateProgress(e) {
	    //   if (e.lengthComputable) {
	    //     var percentage = Math.round((e.loaded * 100) / e.total);
	    //     console.log(percentage);
	    //     // $('#progress').css('width',pecentage);
	    //   };
	    // };

	    xhr.addEventListener("load", transferComplete, false);
	    function transferComplete(evt) {
	      $("#results").append("<p>DONE!</p>");
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