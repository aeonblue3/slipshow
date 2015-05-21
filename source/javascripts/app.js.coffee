methods =
  resizeContainer: () ->
    next_slide =
      width: parseInt $(@slides[@currentSlide]).outerWidth(), 10
      height: parseInt $(@slides[@currentSlide]).outerHeight(), 10
    container_width = parseInt $(@container).outerWidth(), 10
    height = (container_width * next_slide.height) / next_slide.width

Revolver.registerTransition 'fade', (options, done) ->
  complete = @trigger.bind @, 'transitionComplete'
  $nextSlide = $(@slides[@nextSlide])
  $currentSlide = $(@slides[@currentSlide])

  $currentSlide.velocity opacity: 0,
    easing: 'ease-out'
    duration: 500
  .css {position: 'absolute', float: 'none'}
  $nextSlide
  .css {position: 'relative', float: 'left', z_index: @currentSlide}
  .velocity opacity: 1,
    easing: 'ease-in'
    duration: 500
    complete: complete()

Revolver.registerTransition 'slide', (options, done) ->
  complete = @trigger.bind @, 'transitionComplete'
  $nextSlide = $(@slides[@nextSlide])
  $currentSlide = $(@slides[@currentSlide])
  if $('.slides_container')[0].style.height is ""
    $('.slides_container').outerHeight $('.slide.active').outerHeight()
  $('.slides_container').outerHeight $nextSlide.outerHeight()
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
    autoPlay: $(".slideshow").data('autoplay') || false,
    speed: $(".slideshow").data('rotationspeed') || "3500",
    transition:
      name: $(".slideshow").data('transition') || "default"


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

  regex = new RegExp "(first|previous|stop|play|next|last|restart)", "i"
  $('[class*="coffee-slider-"]').click (e)->
    e.preventDefault()
    command = $(this).attr('class').match(regex)[0]
    mySlider[command]()

  mySlider.on "transitionComplete", () ->
    nodes = $('ul.slides_indicator').children()
    nodes.removeClass 'active'
    return $(nodes.get(this.currentSlide)).addClass('active')

  $(".slide_node a").click (e) ->
    e.preventDefault()
    index = $(this).parent().index()
    if index <= mySlider.lastSlide then mySlider.goTo index
