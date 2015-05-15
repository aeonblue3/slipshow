# =========================================================================================================
#
# 'Y8888888b.                                     `Y88                                        ::
#   888   Y88b                                     888
#   888   dX8P   .d888b. `Y8b      d8P  .d8888b.   888 `Y8b      d8P  .d888b.  `Y88.d88b.    `Y88  .d8888b
#   888888YK    d8P   Y8b  Y8b    d8P  d88P''Y88b  888   Y8b    d8P  d8P   Y8b  888P' 'Y8b    888  88K
#   888  'Y8b.  888888888   Y8b  d8P   88K    X88  888    Y8b  d8P   888888888  888           888  'Y8888b.
#   888    88b  Y8b.         Y8bd8P    Y88b..d88P  888     Y8bd8P    Y8b.       888           888       X88
# .d888    888   'Y888P'      Y88P      'Y8888P'   888.     Y88P      'Y888P'   888      ::   888   Y88888'
#          Y88b.                                                                             .88P
#                                                                                           d88'
# =========================================================================================================
;
'use strict'

# constructor
Revolver = (options) ->

  # setup initial values
  @currentSlide = 0
  @nextSlide = 0
  @numSlides = 0
  @lastSlide = 0
  @iteration = 0
  @intervalId = null
  @disabled = false

  # merge options
  @options = {}
  @setOptions Revolver.defaults, options

  # set container
  if @options.container
    @container = @options.container
  else if @options.containerSelector
    @container = Revolver.$(@options.containerSelector, document)[0]
  else
    @container = document

  # add all slides
  @slides = []
  slidesToAdd = @options.slides or Revolver.$(@options.slidesSelector, @container)
  _.each slidesToAdd, @addSlide, this

  # finish setting up init values
  @previousSlide = @lastSlide
  @status =
    paused: false
    playing: false
    stopped: true
  @isAnimating = false

  # Completely disable Revolver
  # if there is only one slide
  if @numSlides <= 1
    @disabled = true
    return

  # always disable isAnimating flag
  # after transition is complete
  @on 'transitionComplete', -> @isAnimating = false

  # register all event handlers
  @on 'play', @options.onPlay
  @on 'stop', @options.onStop
  @on 'pause', @options.onPause
  @on 'restart', @options.onRestart
  @on 'transitionStart', @options.transition.onStart
  @on 'transitionComplete', @options.transition.onComplete

  # fire onReady event handler
  _.bind(@options.onReady, this)()

  # begin auto play, if enabled
  @play {}, true  if @options.autoPlay

  # return instance
  this


# namespace for default options
# (gets merged with user defined
# options in the constructor)
Revolver.defaults =
  autoPlay: true          # whether or not to automatically begin playing the slides
  container: null         # dom element the contains the slides (optional)
  containerSelector: null # selector used to find the container element
  slides: null            # array of slide dom elements
  slidesSelector: null    # selector used to find all slides for this slider
  onReady: ->             # gets called when revolver is setup and ready to go
  onPlay: ->              # gets called when the play() method is called
  onStop: ->              # gets called when the stop() method is called
  onPause: ->             # gets called when the pause() method is called
  onRestart: ->           # gets called when the restart() method is called
  rotationSpeed: 4000     # how long (in milliseconds) to stay on each slide before going to the next
  transition:
    onStart: ->           # gets called when the transition animation begins
    onComplete: ->        # gets called when the animation is done
    name: 'default'       # default transition


# current version
Revolver.VERSION = '2.1.1'


# add a new slide
Revolver::addSlide = (slide, index) ->
  if !!~@slides.indexOf slide then return this
  # add new slide to the slides array
  if index
    @slides.splice index, 0, slide
  else
    @slides.push slide
  # recalculate total number of slides
  @numSlides     = @slides.length
  # recalculate which is the last slide
  @lastSlide     = (if @numSlides is 0 then 0 else @numSlides - 1)
  # recalculate which is the next slide
  currentPlusOne = @currentSlide + 1
  @nextSlide     = (if currentPlusOne > @lastSlide then 0 else currentPlusOne)
  # return instance
  this

# Remove an existing slide
Revolver::removeSlide = (index) ->
  return undefined if index < 0 or index >= @numSlides

  new_slide_index = if index is @lastSlide then 0 else index + 1

  new_slide = @slides[new_slide_index]

  @goTo new_slide_index, @options

  @slides.splice index, 1

  # recalculate total number of slides
  @numSlides     = @slides.length
  # recalculate which is the last slide
  @lastSlide     = (if @numSlides is 0 then 0 else @numSlides - 1)
  # recalculate which is the next slide
  @currentSlide  = @slides.indexOf new_slide
  currentPlusOne = @currentSlide + 1
  @nextSlide     = (if currentPlusOne > @lastSlide then 0 else currentPlusOne)
  # return instance
  this

# Move a slide in slides array
Revolver::moveSlide = (src_index, dest_index) ->
  # If the destination index is greater than the array length, 0
  if dest_index >= @slides.length then dest_index = 0
  # If the destination index is less than 0, use array length - 1
  if dest_index < 0 then dest_index = @slides.length - 1

  # Copy slide in destination spot
  temp = @slides[dest_index]
  # Move source slide to destination
  @slides[dest_index] = @slides[src_index]
  # Move temp to old src_index
  @slides[src_index] = temp
  # Goto the new destination
  @goTo dest_index, @options


# set options
Revolver::setOptions = () ->
  # add existing options to beginning of arguments array
  args = Array.prototype.slice.call arguments, 0
  args.unshift @options
  # merge new options with the existing options
  _.merge.apply null, args
  # return instance
  this


# changes the status of the slider
Revolver::changeStatus = (newStatus) ->
  # loop over all statuses and set all as true or false
  _.each @status, ((val, key) ->
    @status[key] = key is newStatus
    true
  ), this
  # return instance
  this


# do transition
Revolver::transition = (options) ->
  # if slider isn't disabled and it isn't current in transition already
  if @disabled is false and @isAnimating is false
    options = _.merge({}, @options.transition, options)
    @isAnimating = true
    # start transition
    transition = _.bind Revolver.transitions[options.name], this
    done = _.bind @trigger, this, 'transitionComplete'
    transition options, done
    # update current, previous, next, and iteration
    @currentSlide = @nextSlide
    @previousSlide = (if @currentSlide is 0 then @lastSlide else @currentSlide - 1)
    @nextSlide = (if @currentSlide is @lastSlide then 0 else @currentSlide + 1)
    @iteration++
    # execute transitionStart event handlers
    @trigger 'transitionStart'
  # return instance
  this


# play the slider
Revolver::play = (options, firstTime) ->
  # if slider isn't disabled and it's not already playing
  if @disabled is false and not @status.playing
    # change status
    @changeStatus 'playing'
    # trigger all registered 'play' event listeners
    @trigger 'play'
    # do transition immediately unless it's first run
    @transition options unless firstTime
    # start the loop
    @intervalId = setInterval _.bind(@transition, this), parseFloat(@options.rotationSpeed)
  # return instance
  this

# internal method used for stopping the
# loop that is created by the play method
Revolver::_clearInterval = ->
  # if the intervalId has been set
  if @intervalId isnt null
    # stop the loop
    clearInterval @intervalId
    # delete the reference to the loop
    @intervalId = null
  # return instance
  this


# pause the slider
Revolver::pause = ->
  # if slider isn't disabled and not already paused
  if @disabled is false and not @status.paused
    # change status to paused
    @changeStatus 'paused'
    # fire all 'pause' event listeners
    @trigger 'pause'
    # stop the loop
    @_clearInterval()
  # return instance
  this


# stop the slider
Revolver::stop = ->
  # if slider isn't disabled and not currently stopped
  if @disabled is false and not @status.stopped
    # change status to stopped
    @changeStatus 'stopped'
    # fire all 'stop' event listeners
    @trigger 'stop'
    # stop the loop
    @_clearInterval()
    # queue up first slide as next
    @reset()
  # return instance
  this


# queues up the first slide
Revolver::reset = ->
  # reset only if not already on the first slide
  @nextSlide = 0  if @currentSlide isnt 0
  # return instance
  this


# restart the slider
Revolver::restart = (options) ->
  # bail out if slider is disabled
  return this if @disabled is true
  # fire all 'restart' event listeners
  @trigger 'restart'
  # stop and then play the
  # slider from the beginning
  @stop().play options
  # return instance
  this


# go to a specific slide
Revolver::goTo = (i, options) ->
  # keep transition arithmetic from breaking
  i = parseInt(i)
  # bail out if already on the intended slide
  return this  if @disabled is true or @slides[i] is @slides[@currentSlide]
  # queue up i as the next slide
  @nextSlide = i
  # if slider is playing, pause() and play()
  # (which will transition immediately and restart the loop)
  # if not play, simply transition() straight to it
  (if not @status.playing then @transition(options) else @pause().play(options))


# CONVENIENCE METHODS (for building slider controls)

# go to the first slide
Revolver::first = (options) -> @goTo 0, options

# go to the previous slide
Revolver::previous = (options) -> @goTo @previousSlide, options

# go to the next slide
Revolver::next = (options) -> @goTo @nextSlide, options

# go to the last slide
Revolver::last = (options) -> @goTo @lastSlide, options


# EVENTS

addNamespaces = (eventString) ->
  namespace = 'revolver'
  eventStringDelimiter = ' '
  events = eventString.split eventStringDelimiter
  _.each events, (eventName, i) ->
    events[i] = namespace.concat '.', events[i]
  events.join eventStringDelimiter

# attach an event listener
Revolver::on = (eventString, callback) ->
  # bind revolver instance to callback
  callback = _.bind callback, this
  # add revolver namespace to event(s)
  eventString = addNamespaces eventString
  # call bean.on
  bean.on this, eventString, callback
  # return instance
  this

# alias for on() except that the handler will removed after the first execution
Revolver::one = (eventString, callback) ->
  # bind revolver instance to callback
  callback = _.bind callback, this
  # add revolver namespace to event(s)
  eventString = addNamespaces eventString
  # call bean.on
  bean.one this, eventString, callback
  # return instance
  this

# remove an event listener using
Revolver::off = (eventString, callback) ->
  # bind revolver instance to callback
  callback = _.bind callback, this
  # add revolver namespace to event(s)
  eventString = addNamespaces eventString
  # call bean.on
  bean.off this, eventString, callback
  # return instance
  this

# execute all listeners for the given event
Revolver::trigger = (eventString) ->
  # add revolver namespace to event(s)
  eventString = addNamespaces eventString
  # call bean.on
  bean.fire this, eventString
  # return instance
  this


# SELECTOR ENGINE

# use querySelectorAll out of the box
Revolver.$ = (selector, root) ->
  root = document if root is undefined
  root.querySelectorAll selector

# override the default selector engine
# (ex jQuery.find, Qwery, Sel, Sizzle, NWMatcher)
Revolver.setSelectorEngine = (e) ->
  bean.setSelectorEngine e
  Revolver.$ = e
  this


# TRANSITIONS

# namespace for all transitions
Revolver.transitions = {}

# a default transition
Revolver.transitions['default'] = (options) ->
  # hide current slide
  @slides[@currentSlide].setAttribute 'style', 'display: none'
  # show next slide
  @slides[@nextSlide].setAttribute 'style', 'display: block'
  # fire all 'transitionComplete' event listeners
  @trigger 'transitionComplete'
  # return instance
  this

Revolver.registerTransition = (name, fn) ->
  Revolver.transitions[name] = fn
  this

Revolver.deregisterTransition = (name) ->
  delete Revolver.transitions[name]
  this


# return the Revolver object globally available
window.Revolver = Revolver

# support AMD
if typeof window.define is "function" && window.define.amd
  window.define "revolver", [], -> window.Revolver
