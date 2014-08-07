###
jquery.retroimage
TODO: do nothing if canvas is unavailable
###

$ = jQuery

# FIXME: this should give the natural width and height!
imageDimensions = (img) ->
  [img.width, img.height]

dither = (imageData) ->
  for y in [0...imageData.height]
    for x in [0...imageData.width]
      i = (y*imageData.width + x)*4

$.fn.retroimage = (options) ->
  (this.filter 'img').each (_, element) ->
    $e= $(element)

    # create a canvas adjacent to the image
    canvas = ($canvas = $ '<canvas />')[0]

    # set width and height on the page to match that of the img element
    $canvas.width($e.width())
    $canvas.height($e.height())

    # set width & height of the backing buffer to match that of the image file
    [canvas.width, canvas.height] = imageDimensions element

    $e.after($canvas)

    # draw the original image onto the canvas
    ctx = canvas.getContext '2d'
    ctx.drawImage element, 0, 0

    # extract the image data, dither, write dithered data back to canvas
    imageData = ctx.getImageData 0,0,canvas.width,canvas.height
    dither imageData
    ctx.putImageData imageData, 0, 0

    # hide the original image tag
    $e.hide()
