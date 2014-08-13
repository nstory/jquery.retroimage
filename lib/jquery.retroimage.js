
/*
jquery.retroimage
 */

(function() {
  var $, canvasToGreyscale, ditherPlane, extractPlane, imageToCanvas, kernels, writePlanesToCanvas;

  $ = jQuery;

  $.fn.retroimage = function(options) {
    var color, kernel, quant, settings;
    settings = $.extend({
      'algorithm': 'errorDifusion',
      'kernel': 'floydSteinberg',
      'shades': 1,
      'color': false
    }, options);
    kernel = kernels[settings.kernel];
    quant = function(v) {
      return Math.round(v * settings.shades) / settings.shades;
    };
    color = settings.color;
    return (this.filter('img')).each(function(_, img) {
      var canvas, dithered, ditheredPlanes, greys, i, plane;
      canvas = imageToCanvas(img);
      if (color) {
        ditheredPlanes = (function() {
          var _i, _results;
          _results = [];
          for (i = _i = 0; _i < 3; i = ++_i) {
            plane = extractPlane(canvas, i);
            _results.push(ditherPlane(plane, canvas.width, canvas.height, kernel, quant));
          }
          return _results;
        })();
        writePlanesToCanvas(canvas, ditheredPlanes[0], ditheredPlanes[1], ditheredPlanes[2]);
      } else {
        greys = canvasToGreyscale(canvas);
        dithered = ditherPlane(greys, canvas.width, canvas.height, kernel, quant);
        writePlanesToCanvas(canvas, dithered, dithered, dithered);
      }
      return img.src = canvas.toDataURL();
    });
  };

  kernels = {
    none: [],
    oneDimensional: [[1, 0, 1]],
    twoDimensional: [[1, 0, 2 / 4], [0, 1, 1 / 4], [1, 1, 1 / 4]],
    floydSteinberg: [[1, 0, 7 / 16], [-1, 1, 3 / 16], [0, 1, 5 / 16], [1, 1, 1 / 16]],
    jarvisJudiceNinke: [[1, 0, 7 / 48], [2, 0, 5 / 48], [-2, 1, 3 / 48], [-1, 1, 5 / 48], [0, 1, 7 / 48], [1, 1, 5 / 48], [2, 1, 3 / 48], [-2, 2, 1 / 48], [-1, 2, 3 / 48], [0, 2, 5 / 48], [1, 2, 3 / 48], [2, 2, 1 / 48]],
    atkinson: [[1, 0, 1 / 8], [2, 0, 1 / 8], [-1, 1, 1 / 8], [0, 1, 1 / 8], [1, 1, 1 / 8], [0, 2, 1 / 8]]
  };

  $.fn.retroimage.ditherPlane = ditherPlane = function(plane, width, height, kernel, quant) {
    var dx, dy, err, frac, i, k, newvalue, nx, ny, oldvalue, p, x, y, _i, _j, _k, _len;
    if (kernel == null) {
      kernel = kernels.floydSteinberg;
    }
    if (quant == null) {
      quant = Math.round;
    }
    plane = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = plane.length; _i < _len; _i++) {
        p = plane[_i];
        _results.push(p);
      }
      return _results;
    })();
    for (y = _i = 0; 0 <= height ? _i < height : _i > height; y = 0 <= height ? ++_i : --_i) {
      for (x = _j = 0; 0 <= width ? _j < width : _j > width; x = 0 <= width ? ++_j : --_j) {
        i = y * width + x;
        oldvalue = plane[i];
        newvalue = plane[i] = quant(oldvalue);
        err = oldvalue - newvalue;
        for (_k = 0, _len = kernel.length; _k < _len; _k++) {
          k = kernel[_k];
          dx = k[0], dy = k[1], frac = k[2];
          nx = x + dx;
          ny = y + dy;
          if (nx < 0 || nx >= width) {
            continue;
          }
          if (ny < 0 || ny >= height) {
            continue;
          }
          plane[ny * width + nx] += err * frac;
        }
      }
    }
    return plane;
  };

  $.fn.retroimage.imageToCanvas = imageToCanvas = function(img) {
    var canvas, ctx, _ref;
    canvas = ($('<canvas />'))[0];
    _ref = [img.width, img.height], canvas.width = _ref[0], canvas.height = _ref[1];
    ctx = canvas.getContext('2d');
    ctx.drawImage(img, 0, 0);
    return canvas;
  };

  $.fn.retroimage.extractPlane = extractPlane = function(canvas, planeOffset) {
    var ctx, i, imageData, _i, _ref, _results;
    ctx = canvas.getContext('2d');
    imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
    _results = [];
    for (i = _i = 0, _ref = canvas.width * canvas.height; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      _results.push(imageData.data[i * 4 + planeOffset] / 255);
    }
    return _results;
  };

  $.fn.retroimage.canvasToGreyscale = canvasToGreyscale = function(canvas) {
    var i, idx, planes, _i, _ref, _results;
    planes = (function() {
      var _i, _results;
      _results = [];
      for (i = _i = 0; _i < 3; i = ++_i) {
        _results.push(extractPlane(canvas, i));
      }
      return _results;
    })();
    _results = [];
    for (idx = _i = 0, _ref = planes[0].length; 0 <= _ref ? _i < _ref : _i > _ref; idx = 0 <= _ref ? ++_i : --_i) {
      _results.push((planes[0][idx] + planes[1][idx] + planes[2][idx]) / 3);
    }
    return _results;
  };

  $.fn.retroimage.writePlanesToCanvas = writePlanesToCanvas = function(canvas, r_plane, g_plane, b_plane) {
    var ctx, data, i, imageData, _i, _ref;
    ctx = canvas.getContext('2d');
    imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
    data = imageData.data;
    for (i = _i = 0, _ref = r_plane.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      data[i * 4] = r_plane[i] * 255;
      data[i * 4 + 1] = g_plane[i] * 255;
      data[i * 4 + 2] = b_plane[i] * 255;
      data[i * 4 + 3] = 255;
    }
    return ctx.putImageData(imageData, 0, 0);
  };

}).call(this);
