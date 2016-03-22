var Plotline = Plotline || {};

// Responsive Photosets
//
// Based heavily on/stolen from: https://medium.com/coding-design/responsive-photosets-7742e6f93d9e
Plotline.Photosets = {
  initialize: function() {
    window.addEventListener('resize', Plotline.Utils.debounce(this.align.bind(this), 100));

    Plotline.Utils.ready(function() {
      // trigger 'resize' event on window
      var event = document.createEvent('HTMLEvents');
      event.initEvent('resize', true, false);
      window.dispatchEvent(event);
    });
  },

  align: function(event) {
    var rows = document.querySelectorAll('.photoset-row');
    Array.prototype.forEach.call(rows, function(el, i){
      var $pi    = el.querySelectorAll('.photoset-item'),
          cWidth = parseInt(window.getComputedStyle(el.parentNode).width);

      var ratios = Array.prototype.map.call($pi, function(el, index) {
        return el.querySelector('img').getAttribute('data-ratio');
      });

      var sumRatios = 0, sumMargins = 0,
          minRatio  = Math.min.apply(Math, ratios);

      for (var i = 0; i < $pi.length; i++) {
        sumRatios += ratios[i] / minRatio;
      };

      Array.prototype.forEach.call($pi, function(el) {
        sumMargins += parseInt(getComputedStyle(el)['margin-left']) + parseInt(getComputedStyle(el)['margin-right']);
      });

      Array.prototype.forEach.call($pi, function(el, i) {
        var minWidth = (cWidth - sumMargins) / sumRatios;
        var img = el.querySelector('img');

        img.style.width  = (Math.ceil(minWidth / minRatio) * ratios[i]) + 'px';
        img.style.height = (Math.ceil(minWidth / minRatio)) + 'px';
      });
    });
  }
};

Plotline.Photosets.initialize();
