(function (win) {
  'use strict';
     var screenPixelRatio = function () {
         var retVal = 1;
         if (win.devicePixelRatio) {
             retVal = win.devicePixelRatio;
         } else if ("matchMedia" in win && win.matchMedia) {
             if (win.matchMedia("(min-resolution: 2dppx)").matches || win.matchMedia("(min-resolution: 192dpi)").matches) {
                 retVal = 2;
             } else if (win.matchMedia("(min-resolution: 1.5dppx)").matches || win.matchMedia("(min-resolution: 144dpi)").matches) {
                 retVal = 1.5;
             }
         }
         return retVal;
     },

     getTrueScreenWidth = function() {
         return (win.innerWidth * screenPixelRatio());
     },

     getImageVersion = function(imageContainer) {
         var pixelRatio = screenPixelRatio()
           , width = getTrueScreenWidth()
           , imgType = (pixelRatio > 1) ? "retina" : "regular"
           , re = new RegExp(imgType, 'i')
           , temp = 0;
         $.each($(imageContainer.children[0]).data(), function(key, val) {
           var key_integer = parseInt(key, 10);
           if (width <= key_integer && !!key.match(re)) {
             if (temp === 0) {
               temp = key;
             } else if (key_integer < parseInt(temp, 10)) {
               temp = key;
             }
           }
         });
         return (temp !== 0) ? temp : "default" + imgType;
     },
     lazyloadImage = function (imageContainer) {

         var imageVersion = getImageVersion(imageContainer);

         if (!imageContainer || !imageContainer.children) { return; }
         var img = imageContainer.children[0];

         if (img) {
             var imgSRC = $(img).data(imageVersion);
             var altTxt = $(img).data("alt");
             if (imgSRC) {
                 try {
                     var imageElement = new Image();
                     imageElement.src = imgSRC;
                     imageElement.setAttribute("alt", altTxt ? altTxt : "");
                     imageElement.setAttribute("class", "r_img");
                     imageContainer.appendChild(imageElement);
                 } catch (e) {
                     console.log("img error" + e);
                 }
             }
         }
     },
     lazyLoadedImages = $(".responsive-image > div");

     $(document).ready(function(){
       setTimeout(function() {
         for (var i = 0; i < lazyLoadedImages.length; i++) {
             lazyloadImage(lazyLoadedImages[i]);
         }
       }, 300);
     });

 })(window);