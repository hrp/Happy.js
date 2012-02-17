(($) ->
  trim = (el) ->
    (if ("".trim) then el.val().trim() else $.trim(el.val()))
  $.fn.isHappy = (config) ->
    getError = (error) ->
      $ "<span id=\"" + error.id + "\" class=\"unhappyMessage\">" + error.message + "</span>"
    handleSubmit = ->
      errors = false
      i = undefined
      l = undefined
      i = 0
      l = fields.length

      while i < l
        errors = true  unless fields[i].testValid(true)
        i += 1
      if errors
        config.unHappy()  if isFunction(config.unHappy)
        false
      else if config.testMode
        console.warn "would have submitted"  if window.console
        false
    isFunction = (obj) ->
      !!(obj and obj.constructor and obj.call and obj.apply)
    processField = (opts, selector) ->
      field = $(selector)
      error =
        message: opts.message
        id: selector.slice(1) + "_unhappy"

      errorEl = (if $(error.id).length > 0 then $(error.id) else getError(error))
      fields.push field
      field.testValid = (submit) ->
        val = undefined
        el = $(this)
        gotFunc = undefined
        error = false
        temp = undefined
        required = !!el.get(0).attributes.getNamedItem("required") or opts.required
        password = (field.attr("type") is "password")
        arg = (if isFunction(opts.arg) then opts.arg() else opts.arg)
        if isFunction(opts.clean)
          val = opts.clean(el.val())
        else if not opts.trim and not password
          val = trim(el)
        else
          val = el.val()
        el.val val
        gotFunc = (val.length > 0 or required is "sometimes") and isFunction(opts.test)
        if submit is true and required is true and val.length is 0
          error = true
        else error = not opts.test(val, arg)  if gotFunc
        if error
          el.addClass("unhappy").before errorEl
          false
        else
          temp = errorEl.get(0)
          temp.parentNode.removeChild temp  if temp.parentNode
          el.removeClass "unhappy"
          true

      field.bind config.when or "blur", field.testValid
    fields = []
    item = undefined
    for item of config.fields
      processField config.fields[item], item
    if config.submitButton
      $(config.submitButton).click handleSubmit
    else
      @bind "submit", handleSubmit
    this
) @jQuery or @Zepto