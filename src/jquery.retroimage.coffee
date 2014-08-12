###
jquery.retroimage
###

$ = jQuery

$.fn.retroimage = (options) ->
  (this.filter 'img').each (_, img) ->
    canvas = imageToCanvas img
    greys = canvasToGreyscale canvas
    dithered = ditherPlane greys, canvas.width, canvas.height
    writePlanesToCanvas canvas, dithered, dithered, dithered
    img.src = canvas.toDataURL()

floydSteinberg = [[1,0,7/16],[-1,1,3/16],[0,1,5/16],[1,1,1/16]]
$.fn.retroimage.ditherPlane = ditherPlane = (plane, width, height, kernel=floydSteinberg) ->
  plane = (p for p in plane) # copy
  quant = (v) -> Math.round v
  for y in [0...height]
    for x in [0...width]
      i = y*width+x
      oldvalue = plane[i]
      newvalue = plane[i] = quant oldvalue
      err = oldvalue - newvalue
      for k in kernel
        [dx,dy,frac] = k
        nx = x+dx
        ny = y+dy
        if nx < 0 or nx >= width
          continue
        if ny < 0 or ny >= height
          continue
        plane[ny*width+nx] += err*frac
  plane

$.fn.retroimage.imageToCanvas = imageToCanvas = (img) ->
  # create a canvas of matching width and height
  canvas = ($ '<canvas />')[0]
  [canvas.width, canvas.height] = [img.width, img.height]

  # draw the original image onto the canvas
  ctx = canvas.getContext '2d'
  ctx.drawImage img, 0, 0

  canvas

$.fn.retroimage.extractPlane = extractPlane = (canvas, planeOffset) ->
  ctx = canvas.getContext '2d'
  imageData = ctx.getImageData 0,0,canvas.width,canvas.height
  for i in [0...canvas.width*canvas.height]
    imageData.data[i*4+planeOffset]/255

$.fn.retroimage.canvasToGreyscale = canvasToGreyscale = (canvas) ->
  planes = (extractPlane canvas, i for i in [0...3])
  for idx in [0...planes[0].length]
    (planes[0][idx] + planes[1][idx] + planes[2][idx])/3

$.fn.retroimage.writePlanesToCanvas = writePlanesToCanvas = (canvas, r_plane, g_plane, b_plane) ->
  ctx = canvas.getContext '2d'
  imageData = ctx.getImageData 0,0,canvas.width,canvas.height
  data = imageData.data
  for i in [0...r_plane.length]
    data[i*4] = r_plane[i]*255
    data[i*4+1] = g_plane[i]*255
    data[i*4+2] = b_plane[i]*255
    data[i*4+3] = 255
  ctx.putImageData imageData, 0, 0
