
(function( $ ){

  $.fn.googleFontLoader = function (f) {
                var l = document.createElement('link'); l.type = 'text/css'; l.async = true; l.rel = 'stylesheet';
                l.href = ('https:' == document.location.protocol ? 'https://' : 'http://') + 'fonts.googleapis.com/css?family='+f;
                var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(l, s);
            }
})( jQuery );