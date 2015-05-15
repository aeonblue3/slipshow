suite 'Instance Methods', ->

  # revolver instance
  slider = undefined
  originalSlider = undefined
  setup ->
    slider = new Revolver
      containerSelector: '#myslider'
      slidesSelector: '.slide'
    originalSlider = _.clone(slider)
  suiteTeardown ->
    slider = originalSlider = null


  # addSlide
  suite '#addSlide()', ->
    test 'adds one more to this.slides array', ->
      numSlides = slider.slides.length
      slider.addSlide document.createElement('div')
      assert.strictEqual slider.slides.length, numSlides + 1
    test 'adds slide at correct position', ->
      slide = document.createElement('div')
      slider.addSlide slide, 1
      assert.strictEqual slider.slides.indexOf(slide), 1
    test 'recalculates this.numSlides correctly', ->
      slider.addSlide document.createElement('div')
      assert.strictEqual slider.numSlides, slider.slides.length
    test 'recalculates this.nextSlide correctly', ->
      nextSlide = (if slider.currentSlide is slider.lastSlide then 0 else slider.currentSlide + 1)
      slider.addSlide document.createElement('div')
      assert.strictEqual slider.nextSlide, nextSlide
    test 'does not add slide if already added', ->
      numSlides = slider.slides.length
      slide = document.getElementsByClassName('slide')[0]
      slider.addSlide slide
      assert.strictEqual slider.slides.length, numSlides


  # removeSlide
  suite '#removeSlide()', ->
    test 'remove a slide from this.slides array', ->
      numSlides = slider.slides.length
      slider.removeSlide 0
      assert.strictEqual slider.slides.length, numSlides - 1
    test 'remove the right slide from this.slides array', ->
      slideIndex = 1
      slide = document.getElementsByClassName('slide')[slideIndex]
      slider.removeSlide slideIndex
      assert.strictEqual slider.slides.indexOf(slide), -1
    test 'recalculates this.numSlides correctly', ->
      slider.removeSlide 1
      assert.strictEqual slider.numSlides, slider.slides.length
    test 'recalculates this.nextSlide correctly', ->
      nextSlide = (if slider.currentSlide is slider.lastSlide then 0 else slider.currentSlide + 1)
      slider.removeSlide 0
      assert.strictEqual slider.nextSlide, nextSlide
    test 'recalculates this.currentSlide correctly', ->
      numSlides = slider.slides.length
      slider.removeSlide 0
      assert.strictEqual slider.currentSlide, 0
    test 'activate next slide upon delete', ->
      slide = slider.slides[1]
      slider.removeSlide 0
      assert.strictEqual slider.slides.indexOf(slide), 0

  #moveSlide
  suite '#moveSlide()', ->
    test 'increment slide position in this.slides array', ->
      slide = slider.slides[1]
      slider.moveSlide 1, 2
      assert.strictEqual slider.slides.indexOf(slide), 2
    test 'decrement slide position in this.slides array', ->
      slide = slider.slides[2]
      slider.moveSlide 2, 1
      assert.strictEqual slider.slides.indexOf(slide), 1
    test 'last slide moves to first', ->
      slide = slider.slides[3]
      slider.moveSlide 3, 0
      assert.strictEqual slider.slides.indexOf(slide), 0
    test 'first slide moves to last', ->
      slide = slider.slides[0]
      slider.moveSlide 0, 3
      assert.strictEqual slider.slides.indexOf(slide), 3
    test 'last slide moves to first when destination is out of bounds', ->
      slide = slider.slides[3]
      slider.moveSlide 3, 4
      assert.strictEqual slider.slides.indexOf(slide), 0
    test 'first slide moves to last when destination is less than zero', ->
      slide = slider.slides[0]
      slider.moveSlide 0, -1
      assert.strictEqual slider.slides.indexOf(slide), 3
    test 'currentSlide points to new slide position', ->
      slider.moveSlide 0, 1
      assert.strictEqual slider.currentSlide, 1

  # changeStatus
  suite '#changeStatus()', ->
    test 'plays', ->
      slider.changeStatus 'playing'
      assert.strictEqual slider.status.playing, true
      assert.strictEqual slider.status.paused, false
      assert.strictEqual slider.status.stopped, false
    test 'pauses', ->
      slider.changeStatus 'paused'
      assert.strictEqual slider.status.playing, false
      assert.strictEqual slider.status.paused, true
      assert.strictEqual slider.status.stopped, false
    test 'stops', ->
      slider.changeStatus 'stopped'
      assert.strictEqual slider.status.playing, false
      assert.strictEqual slider.status.paused, false
      assert.strictEqual slider.status.stopped, true


  # pause
  suite '#pause()', ->
    test 'changes status to paused if playing or stopped', ->
      # from stopped
      slider.stop()
      slider.pause()
      assert.strictEqual slider.status.paused, true
      # from playing
      slider.play()
      slider.pause()
      assert.strictEqual slider.status.paused, true
    test 'this.intervalId is null', ->
      slider.pause()
      assert.strictEqual slider.intervalId, null


  # play
  suite '#play()', ->
    test 'changes status to playing if paused or stopped', ->
      # from stopped
      slider.stop()
      slider.play()
      assert.strictEqual slider.status.playing, true
      # from paused
      slider.pause()
      slider.play()
      assert.strictEqual slider.status.playing, true
    test 'this.intervalId isnt null', ->
      slider.play()
      assert.notStrictEqual slider.intervalId, null


  # reset
  suite '#reset()', ->
    test 'only sets this.nextSlide to 0 if this.currentSlide doesnt equal 0', ->
      slider.pause()
      slider.reset()
      assert.notStrictEqual slider.nextSlide, 0
      slider.goTo 1
      slider.reset()
      assert.strictEqual slider.nextSlide, 0


  # restart
  suite '#restart()', ->
    setup ->
      slider.restart()
    #    test('this.currentSlide equals 0', function () {
    #      assert.strictEqual(slider.currentSlide, 0);
    #    });
    test 'slider is playing', ->
      assert.strictEqual slider.status.playing, true
      assert.strictEqual slider.status.paused, false
      assert.strictEqual slider.status.stopped, false


  # setOptions
  suite '#setOptions()', ->
    test 'sets a new option', ->
      slider.setOptions foo: 'bar'
      assert.strictEqual slider.options.foo, 'bar'
    test 'overrides existing options', ->
      slider.setOptions slidesSelector: '.mySlides'
      assert.strictEqual slider.options.slidesSelector, '.mySlides'


  # stop
  suite '#stop()', ->
    test 'changes status to stopped if paused or playing', ->
      # from playing
      slider.play()
      slider.stop()
      assert.strictEqual slider.status.stopped, true
      # from paused
      slider.pause()
      slider.stop()
      assert.strictEqual slider.status.stopped, true
    test 'this.intervalId is null', ->
      slider.stop()
      assert.strictEqual slider.intervalId, null


  # stop
  suite '#goTo()', ->
    test 'does nothing if disabled', ->
      slider.goTo 0
      slider.disabled = true
      slider.goTo slider.lastSlide
      assert.strictEqual slider.currentSlide, 0
    test 'goes to intended slide', ->
      nextSlide = slider.nextSlide
      slider.goTo nextSlide
      assert.strictEqual slider.currentSlide, nextSlide
    test 'recalculates this.nextSlide correctly', ->
      nextSlide = slider.nextSlide
      slider.goTo nextSlide
      assert.strictEqual slider.nextSlide, nextSlide + 1


# Static Methods
suite 'Static Methods', ->

  # registerTranistion
  suite '#registerTransition()', ->
    handler = ->
    new_handler = ->
      true
    result = Revolver.registerTransition('test', handler)
    test 'saves the handler in the transitions namespace', ->
      assert.strictEqual Revolver.transitions.test, handler
    test 'returns the Revolver global object', ->
      assert.strictEqual result, Revolver
    test 'update transition to new handler', ->
      new_result = Revolver.registerTransition('test', new_handler)
      assert.strictEqual Revolver.transitions.test, new_handler

  # deregisterTransition
  suite '#deregisterTransition()', ->
    handler = ->
    result = Revolver.registerTransition('transient', handler)
    test 'deregister the transition from transitions namespace', ->
      Revolver.deregisterTransition('transient')
      assert.isUndefined Revolver.transitions.transient, 'no test defined'
  # setSelectorEngine
  # suite '#setSelectorEngine()', ->
  #   new$ = ->
  #   old$ = Revolver.$
  #   Revolver.setSelectorEngine(new$)
  #   test 'saves the handler in the $ namespace', ->
  #     assert.strictEqual Revolver.$, new$
  #   Revolver.$ = old$
