(($) ->
  options =
    animation: "fade",
    speed: 4000,
    

  slider_options =
    containerSelector: '.slideshow',
    slidesSelector: '.slide'

  mySlider = new Revolver slider_options

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
) jQuery
