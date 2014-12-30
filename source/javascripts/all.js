//= require jquery/dist/jquery.min
//= require jquery-ui/jquery-ui.min
//= require lodash
//= require bean
//= require revolver

var mySlider = new Revolver({
  containerSelector: '.slideshow',
  slidesSelector: '.slide'
});

$(".pause, .play").click(function(e){
  e.preventDefault();

  var $icon = $(this).find('i');

  if ($icon.hasClass('icon-pause')) {
    $icon.attr('class', 'icon-play-3');
    mySlider.pause();
  } else {
    $icon.attr('class', 'icon-pause');
    mySlider.play();
  }
});

$(".prev, .next").click(function(e){
  e.preventDefault();

  var action = $(this).attr('class') === 'prev' ? "previous" : "next";
  mySlider[action]();
});
