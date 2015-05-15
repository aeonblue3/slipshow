Revolver.registerTransition 'fade', (options, done) ->
  complete = @trigger.bind @, 'transitionComplete'
  $container = $(@container);
  $nextSlide = $(@slides[@nextSlide]);
  $prevSlide = $(@slides[@previousSlide]);
  $currentSlide = $(@slides[@currentSlide]);
  if $('.slides_container')[0].style.height is ""
    $('.slides_container').height $('.slide.active').height()
  $('.slides_container').height $nextSlide.height()
  $currentSlide.velocity 'fadeOut',
    duration: 500,
    complete: () ->
      $nextSlide.velocity 'fadeIn',
          duration: 500,
          complete: complete

Revolver.registerTransition 'slide', (options, done) ->
  complete = @trigger.bind @, 'transitionComplete'
  $nextSlide = $(@slides[@nextSlide])
  $currentSlide = $(@slides[@currentSlide])
  if $('.slides_container')[0].style.height is ""
    $('.slides_container').height $('.slide.active').height()
  $('.slides_container').height $nextSlide.height()
  $currentSlide.velocity 'transition.slideLeftBigOut',
    duration: 500
    complete: () ->
      $nextSlide.velocity 'transition.slideRightBigIn',
        duration: 500
        complete: complete

$(document).ready () ->
  options =
    containerSelector: '.slides_container',
    slidesSelector: '.slide',
    autoPlay: false,
    speed: 4000,
    transition: 
      name: "fade"
  

  mySlider = new Revolver options

  if not mySlider.status.playing
    $(".icon-pause").attr "class", "icon-play-3"
  $(".pause, .play").click (e) ->
    e.preventDefault()

    $icon = $(@).find('i')

    if $icon.hasClass('icon-pause')
      $icon.attr('class', 'icon-play-3')
      mySlider.pause()
    else
      $icon.attr('class', 'icon-pause')
      mySlider.play()

  $(".prev, .next").click (e) ->
    e.preventDefault()

    action = if $(this).attr('class') is 'prev' then "previous" else "next"
    mySlider[action]()
  mySlider.on "transitionComplete", () ->
    nodes = $('ul.slides_indicator').children()
    nodes.removeClass 'active'
    return $(nodes.get(this.currentSlide)).addClass('active')