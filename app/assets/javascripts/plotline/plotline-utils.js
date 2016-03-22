var Plotline = Plotline || {};
Plotline.Utils = {
  ready: function(callback) {
    if (document.readyState != 'loading'){
      callback();
    } else {
      document.addEventListener('DOMContentLoaded', callback);
    }
  },

  // Source: https://remysharp.com/2010/07/21/throttling-function-calls
  debounce: function(fn, delay) {
    var timer = null;
    return function () {
      var context = this, args = arguments;
      clearTimeout(timer);
      timer = setTimeout(function () {
        fn.apply(context, args);
      }, delay);
    };
  },

  toggleClass: function(el, className) {
    if (el.classList) {
      el.classList.toggle(className);
    } else {
      var classes = el.className.split(' ');
      var existingIndex = classes.indexOf(className);

      if (existingIndex >= 0)
        classes.splice(existingIndex, 1);
      else
        classes.push(className);

      el.className = classes.join(' ');
    }
  }
}
