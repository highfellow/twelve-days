#
# app to display current time in words in various languages.
#
url = require 'url'
webL10n = require './lib/webL10n/l10n.js'
{ Template, jqueryify } = window.dynamictemplate

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
    @contentElts = []
    @selectElt ?= null
    # declare and instantiate the template
    console.log "initialising template"
    that = this
    @tpl = jqueryify new Template schema:'html5', ->
      that.page = @$div class:'page', ->
        @$div class:'heading', ->
          @$h1 class:'heading', 'data-l10n-id':"heading", 'The Twelve Days of Christmas'
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

  addContentElt: (func) ->
    elt=func.bind(@content)()
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
    @addContentElt ->
      @$div ->
        for day in [1..12]
          ord = _("days-#{day}")
          console.log day, ord
          @$p _('onthe', {day: ord})
          @$p _('mytrue')
          for present in [day..1]
            if day is 1 and present is 1
              @$p _("presents-1-first")
            else
              @$p _("presents-#{present}")
          @$p class:'break'

window.page = page = new Page()

loadLocale = (locale) ->
  document.webL10n.setLanguage(locale)
  console.log "Locale loading..."

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

window.addEventListener 'localized', ->
  @firstRun ?= yes
  newLang = document.documentElement.lang = document.webL10n.getLanguage()
  document.documentElement.dir = document.webL10n.getDirection()
  console.log "Localised", newLang
  if @firstRun
    loadLocale 'en'
    @firstRun = no
  else
      # TODO - a bit kludgy!
      waitOn ->
        page.content.isready
      , ->
        page.fillContent()
, false

_ = document.webL10n.get

console.log "starting up"
docURL=document.URL
urlData=url.parse(docURL)
pathbits=urlData.pathname.split "/"
docPath=pathbits[0...pathbits.length-1].join "/"
