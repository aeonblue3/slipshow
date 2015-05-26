Revolver.registerTransition 'default', (options, done) ->
  $(@slides).removeClass 'active'
  $(@slides[@nextSlide]).addClass 'active'
  @trigger 'transitionComplete'
  @

Revolver.registerTransition 'fade', (options, done) ->
  complete = @trigger.bind @, 'transitionComplete'
  $nextSlide = $(@slides[@nextSlide])
  $currentSlide = $(@slides[@currentSlide])
  $slides = $(@slides)

  $currentSlide
    .velocity opacity: 0,
      easing: 'ease-out'
      duration: 500
      complete: () ->
        $slides.removeClass 'active'
        $nextSlide
          .addClass 'active'
          .velocity opacity: 1,
            easing: 'ease-in'
            duration: 500
            complete: () ->
              complete()
  @

Revolver.registerTransition 'slide', (options, done) ->
  complete = @trigger.bind @, 'transitionComplete'
  $nextSlide = $(@slides[@nextSlide])
  $currentSlide = $(@slides[@currentSlide])
  $slides = $(@slides)

  $currentSlide
    .velocity 'transition.slideLeftBigOut',
      complete: () ->
        $slides.removeClass 'active'
        $nextSlide
          .addClass 'active'
          .velocity 'transition.slideRightBigIn',
            complete: complete
  @

$(document).ready () ->
  $(".slide.active").css 'opacity', 1
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

  mySlider.on "Revolver.transitionComplete", () ->
    nodes = $('ul.slides_indicator').children()
    nodes.removeClass 'active'
    return $(nodes.get($('.slide.active').index())).addClass('active')

  $(".slide_node a").click (e) ->
    e.preventDefault()
    index = $(this).parent().index()
    if index <= mySlider.lastSlide then mySlider.goTo index
