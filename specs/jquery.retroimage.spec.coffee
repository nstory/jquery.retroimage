# 2x2 image of rgb(128,128,128)
grey_png = 'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91JpzAAAAFklEQVQI12NsaGhgYGBgYmBgYGBgAAASKgGEjiuzjwAAAABJRU5ErkJggg=='

describe "jquery.retroimage", ->
  $play_area = undefined
  $img = undefined

  canvas = ->
    $img.next()

  beforeEach ->
    # all tests operate on elements under $play_area (we don't want to just
    # use body b/c Jasmine has some stuff in the DOM)
    if $play_area? then $play_area.remove()
    $play_area = ($ '<div class="test-play-area">').appendTo($ 'body')
    $img = $ '<img width="2" height="2">'
    $img.attr 'src', 'data:image/png;base64,' + grey_png
    $play_area.append $img

  it "hides the original image", ->
    $img.retroimage()
    expect($img.is ':visible').toBe false

  it "creates an adjacent canvas element", ->
    $img.retroimage()
    expect($img.next().prop 'tagName').toEqual 'CANVAS'

  it "creates one canvas per image element", ->
    $play_area.append '<img width="8" height="8">'
    ($play_area.find 'img').retroimage()
    $canvases = $play_area.find('canvas')
    expect($canvases.eq(0).width()).toEqual 2
    expect($canvases.eq(1).width()).toEqual 8

  it "canvas has same visible width and height as image element", ->
    $img.retroimage()
    expect [canvas().width(), canvas().height()]
    .toEqual [2, 2]

  # I can't get this to work! (at least in Phantom)
  xit "canvas backing is width and height of image file", ->
    $img.retroimage()
    expect [canvas()[0].width, canvas()[0].height]
    .toEqual [2,2]

  it "should convert grey to a checkerboard pattern", ->
    $img.retroimage()
    imageData = (canvas()[0].getContext '2d').getImageData 0, 0, 2, 2
    data = Array.prototype.slice.call(imageData.data)
    expect(data).toEqual [
      0,0,0,255
      255,255,255,255
      255,255,255,255
      0,0,0,255
    ]
