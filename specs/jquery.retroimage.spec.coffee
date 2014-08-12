# 2x2 image of rgb(128,128,128)
grey_png = 'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91JpzAAAAFklEQVQI12NsaGhgYGBgYmBgYGBgAAASKgGEjiuzjwAAAABJRU5ErkJggg=='

# helper functions
image = (data, cb) ->
  $img = $ '<img>'
  $img.load ->
    cb($img[0])
  $img.attr 'src', 'data:image/png;base64,' + data

canvasData = (canvas) ->
  ctx = canvas.getContext '2d'
  id = ctx.getImageData 0,0,canvas.width,canvas.height
  Array.prototype.slice.call(id.data)

# private functions we want to test
imageToCanvas = $.fn.retroimage.imageToCanvas
extractPlane = $.fn.retroimage.extractPlane
canvasToGreyscale = $.fn.retroimage.canvasToGreyscale
ditherPlane = $.fn.retroimage.ditherPlane
writePlanesToCanvas = $.fn.retroimage.writePlanesToCanvas

describe "jquery.retroimage", ->
  describe 'imageToCanvas', ->
    it 'converts an image to a canvas', (done) ->
      image grey_png, (img) ->
        canvas = imageToCanvas img
        data = canvasData canvas
        expect(data).toEqual [
          128,128,128,255
          128,128,128,255
          128,128,128,255
          128,128,128,255
        ]
        done()

  describe 'extractPlane', ->
    it 'extracts a single color plane as floats', (done) ->
      image grey_png, (img) ->
        canvas = imageToCanvas img
        redPlane = extractPlane canvas, 0
        expect(redPlane).toEqual [128/255, 128/255, 128/255, 128/255]
        done()

  describe 'canvasToGreyscale', ->
    it 'extracts a floating-point greyscale array', (done) ->
      image grey_png, (img) ->
        canvas = imageToCanvas img
        greys = canvasToGreyscale canvas
        expect(greys).toEqual [128/255, 128/255, 128/255, 128/255]
        done()

  describe 'ditherPlane', ->
    it 'converts 0.5 to checkerboard', ->
      dithered = ditherPlane [0.5,0.5,0.5,0.5], 2, 2
      expect(dithered).toEqual [1,0,0,1]

  describe 'writePlanesToCanvas', ->
    it 'practices detrinification', ->
      canvas = document.createElement 'canvas'
      [canvas.width, canvas.height] = [2,1]
      writePlanesToCanvas canvas, [0,1], [1,0], [0,1]
      expect(canvasData canvas).toEqual [
        0,255,0,255,
        255,0,255,255
      ]
