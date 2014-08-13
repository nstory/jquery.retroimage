###
jquery.retroimage
###

$ = jQuery

$.fn.retroimage = (options) ->
  settings = $.extend({
    'algorithm': 'errorDifusion'
    'kernel': 'floydSteinberg'
    'shades': 1
    'color': false
  }, options)

  kernel = kernels[settings.kernel]
  quant = (v) -> Math.round(v*settings.shades)/settings.shades
  color = settings.color

  (this.filter 'img').each (_, img) ->
    canvas = imageToCanvas img
    if color
      ditheredPlanes = for i in [0...3]
        plane = extractPlane canvas, i
        ditherPlane plane, canvas.width, canvas.height, kernel, quant
      writePlanesToCanvas canvas, ditheredPlanes[0], ditheredPlanes[1], ditheredPlanes[2]
    else
      greys = canvasToGreyscale canvas
      dithered = ditherPlane greys, canvas.width, canvas.height, kernel, quant
      writePlanesToCanvas canvas, dithered, dithered, dithered
    img.src = canvas.toDataURL()

kernels =
  none: []
  oneDimensional: [[1,0,1]]
  twoDimensional: [[1,0,2/4],[0,1,1/4],[1,1,1/4]]
  floydSteinberg: [[1,0,7/16],[-1,1,3/16],[0,1,5/16],[1,1,1/16]]
  jarvisJudiceNinke: [
    [1,0,7/48],[2,0,5/48],
    [-2,1,3/48],[-1,1,5/48],[0,1,7/48],[1,1,5/48],[2,1,3/48]
    [-2,2,1/48],[-1,2,3/48],[0,2,5/48],[1,2,3/48],[2,2,1/48]
  ]
  atkinson: [
    [1,0,1/8],[2,0,1/8],
    [-1,1,1/8],[0,1,1/8],[1,1,1/8],
    [0,2,1/8]
  ]

$.fn.retroimage.ditherPlane = ditherPlane = (plane, width, height, kernel=kernels.floydSteinberg, quant = Math.round) ->
  plane = (p for p in plane) # copy
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
