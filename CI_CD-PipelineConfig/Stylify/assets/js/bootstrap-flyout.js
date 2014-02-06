/* ============================================================
 * bootstrap-flyout.js v0.0.1
  * ============================================================
 * Copyright 2013 Intuit, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ============================================================ */


!function ($) {

    "use strict"; // jshint ;_;


    /* FLYOUT CLASS DEFINITION
    * ========================= */

    var toggle = '[data-toggle=flyout]'
    , Flyout = function (element) {
        var $el = $(element).on('click.flyout.data-api', this.toggle)
        $('html').on('click.flyout.data-api', function () {
            $el.parent().removeClass('open')
        })
    }

    Flyout.prototype = {

        constructor: Flyout

  , toggle: function (e) {
      var $this = $(this)
        , $parent
        , isActive

      if ($this.is('.disabled, :disabled')) return

      $parent = getParent($this)

      isActive = $parent.hasClass('open')

      clearMenus()

      if (!isActive) {
          $parent.toggleClass('open')
          $this.focus()
      }

      return false
  }

  , keydown: function (e) {
      var $this
        , $items
        , $active
        , $parent
        , isActive
        , index

      if (!/(38|40|27)/.test(e.keyCode)) return

      $this = $(this)

      e.preventDefault()
      e.stopPropagation()

      if ($this.is('.disabled, :disabled')) return

      $parent = getParent($this)

      isActive = $parent.hasClass('open')

      if (!isActive || (isActive && e.keyCode == 27)) return $this.click()

      $items = $('[role=menu] li:not(.divider) a', $parent)

      if (!$items.length) return

      index = $items.index($items.filter(':focus'))

      if (e.keyCode == 38 && index > 0) index--                                        // up
      if (e.keyCode == 40 && index < $items.length - 1) index++                        // down
      if (! ~index) index = 0

      $items
        .eq(index)
        .focus()
  }

    }

    function clearMenus() {
        $(toggle).each(function () {
            getParent($(this)).removeClass('open')
        })
    }

    function getParent($this) {
        var selector = $this.attr('data-target')
      , $parent

        if (!selector) {
            selector = $this.attr('href')
            selector = selector && /#/.test(selector) && selector.replace(/.*(?=#[^\s]*$)/, '') //strip for ie7
        }

        $parent = $(selector)
        $parent.length || ($parent = $this.parent())

        return $parent
    }


    /* FLYOUT PLUGIN DEFINITION
    * ========================== */

    $.fn.flyout = function (option) {
        return this.each(function () {
            var $this = $(this)
        , data = $this.data('flyout')
            if (!data) $this.data('flyout', (data = new Dropdown(this)))
            if (typeof option == 'string') data[option].call($this)
        })
    }

    $.fn.flyout.Constructor = Flyout


    /* APPLY TO STANDARD FLYOUT ELEMENTS
    * =================================== */

    $(document)
    .on('click.flyout.data-api', clearMenus)
    .on('click.flyout touchstart.flyout.data-api', '.dropdown form', function (e) { e.stopPropagation() })
    .on('click.flyout.data-api touchstart.flyout.data-api', toggle, Flyout.prototype.toggle)
    .on('keydown.flyout.data-api touchstart.flyout.data-api', toggle + ', [role=menu]', Flyout.prototype.keydown)
    .on('mouseout','body .flyout.droponhover', function () {
        var $this = $(this);
        $this.removeClass("showmenu");
    })
    .on('mouseover', 'body .flyout.droponhover', function () {
        var $this = $(this);
        $this.addClass("showmenu");
    });


} (window.jQuery);