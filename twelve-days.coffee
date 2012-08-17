#
# app to display 'The Twelve Days of Christmas' in different languages.
#
url = require 'url'
{ Template, jqueryify } = window.dynamictemplate
{ localise, setLocaleCallback, loadLocale, _ } = require 'dt-localise'

# globals

redraw = ()->
    return !!(document.documentElement || 0).clientHeight
document.redraw = redraw

options = []

option = (tag, value, text) ->
  opt = tag.$option value: value, -> @text (text)
  options.push opt

class Page
  constructor: ->
    @tpl ?= null
    @page ?= null
    @content = null
    @heading = null
    @contentElts = []
    @selectElt ?= null
    # declare and instantiate the template
    console.log "initialising template"
    that = this
    @tpl = jqueryify localise new Template schema:'html5', ->
      that.page = @$div class:'page', ->
        that.heading = @$div class:'heading'
        @$div class:'contentHolder', ->
          that.content = @$div()
          that.content.ready ->
            console.log "content panel ready"
        @$div class:'bottombar', ->
          @$div ->
            that.selectElt = @$select id: "setLang", ->
              option this, 'en', "English"
              option this, 'de', "Deutsch"
            that.selectElt.ready that.selectWait
      that.page.ready ->
        @hide().show()
    @tpl.ready =>
      console.log "tpl:", @tpl
      for el in @tpl.jquery
        $('body').append el

  addContentElt: (parent, func) ->
    elt=func.bind(parent)()
    console.log "Adding element:", elt
    @contentElts.push elt

  selectWait: =>
    # select element is ready.
    @selectElt._jquery.on "change", =>
      newLocale = @selectElt._jquery[0].value
      #console.log "lang changed", newLocale
      loadLocale newLocale

  fillContent: ->
    # fill the content element
    console.log "page.fillContent", @content
    for elt in @contentElts
      elt.remove()
    @addContentElt @heading, ->
      @$h1 {class:'heading', 'data-dt-l10n-id':"heading"}, 'The Twelve Days of Christmas'
    @addContentElt @content, ->
      @$div ->
        for day in [1..12]
          ord = _("days-#{day}")
          console.log day, ord
          # the text for the first para needs to be set manually, not using dt-localise, because its translation needs a parameter (day)
          @$p _('onthe', {day:ord})
          @$p {'data-dt-l10n-id': 'mytrue'}, '-'
          for present in [day..1]
            if day is 1 and present is 1
              @$p {'data-dt-l10n-id': 'presents-1-first'}, '-'
            else
              @$p {'data-dt-l10n-id': "presents-#{present}"}, '-'
          @$p class:'break'

window.page = page = new Page()

waitOn = (test, callback)->
  # wait until test returns true before invoking callback
  if test()
    console.log "wait over"
    callback()
  else
    console.log "waiting..."
    setTimeout ->
      waitOn test, callback
    , 5

setLocaleCallback ->
  # only call this the second time (because webL10n tries to localise on loading the page when the template isn't ready).
  if @called
    page.fillContent()
  @called ?= yes

console.log "starting up"
docURL=document.URL
urlData=url.parse(docURL)
pathbits=urlData.pathname.split "/"
docPath=pathbits[0...pathbits.length-1].join "/"
loadLocale window.navigator.language
