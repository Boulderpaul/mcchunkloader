ChunkSizeY = 256
ChunkSizeZ = 16
ChunkSizeX = 16

cubeCount =0

class ChunkView
  constructor: (options) -> 
    @nbt = options.nbt
    @rotcent = true
    @filled = []
    @sminx = options.sminx
    @sminz = options.sminz
    @smaxx = options.smaxx
    @smaxz = options.smaxz

  getBlockAt: (x, y, z) =>
    if not @nbt.root.Level.Sections? then return
    sectionnum = Math.floor (y / 16)
    blockpos = y*16*16 + z*16 + x 
    section = @nbt.root.Level.Sections[sectionnum]
    if not section? or (not section?.Blocks?)
      return -1
    else
      return section.Blocks[blockpos]

  transNeighbors: (x, y, z) =>
    for i in [x-1..x+1] 
      if i >= ChunkSizeX then continue
      for j in [y-1..y+1] 
        for k in [z-1..z+1]
          if k >= ChunkSizeZ then continue
          if not (i is x and j is y and k is z)
            blockID = getBlockAt x, y, z
            if blockID is 0 then return true
    return false

  extractChunk: =>
    @vertices = []
    @colors = []
    @indices = []
    @textcoords = []
    @filled = []

    for x in [0..ChunkSizeX-1]
      for z in [0..ChunkSizeZ-1]
        for y in [@ymin..255]
          blockID = getBlockAt x, y, z          
          if not blockID? then blockID = 0
          blockType = blockInfo['_-1']
          blockID = '_' + blockID.toString()
           
          if blockInfo[blockID]?
            blockType = blockInfo[blockID]
          else
            blockType = blockInfo['_-1']
          show = false

          if y<60 and @showStuff is 'diamondsmoss'
            show = ( blockType.id is 48 or blockType.id is 56 or blockType.id is 4 )
          else if blockType.id isnt 0 then show = this.transNeighbors x, y, z
          
          if show then @addBlock [x,y,z]
    @renderPoints()

  @addBlock: (position) =>
    verts = [position[0], position[1], position[2]]
    @filled.push verts

  @calcPoint: (pos) =>
    verts = []
    if @rotcent
      xmod = 15 * ChunkSizeX
      zmod = 15 * ChunkSizeZ
    else
      xmod = (@sminx + (@smaxx - @sminx) / 2.0) * ChunkSizeX
      zmod = (@sminz + (@smaxz - @sminz) / 2.0) * ChunkSizeZ
    verts.push ((-1 * xmod) + pos[0] + (@pos.x) * ChunkSizeX * 1.00000) / 40.00
    verts.push ((pos[1] + 1) * 1.0) / 40.0
    verts.push ((-1 * zmod) + pos[2] + (@pos.z) * ChunkSizeZ * 1.00000) / 40.00
    verts

  @renderPoints: =>
    i = 0

    while i < @filled.length
      verts = @filled[i]
      @addTexturedBlock verts
      i++

  @getBlockType: (x, y, z) =>
    blockType = blockInfo["_-1"]
    id = getBlockAt x, y, z
    blockID = "_-1"
    if id? then blockID = "_" + id.toString()  
    if blockInfo[blockID]? then blockType = blockInfo[blockID]  
    blockType

  @getBlockInfo: (p) =>
    blockType = blockInfo["_-1"]
    id = getBlockAt x, y, z
    blockID = "_-1"
    if id? then blockID = "_" + id.toString()
    if blockInfo[blockID]
      blockInfo[blockID]
    else
      blockInfo["_-1"]

  @getColor: (pos) =>
    t = @getBlockType pos[0], pos[1], pos[2]
    t.rgba

  @hasNeighbor: (p, offset0, offset1, offset2) =>
    n = [p[0] + offset0, p[1] + offset1, p[2] + offset2]
    info = @getBlockType(n[0], n[1], n[2])
    info.id > 0

  @addTexturedBlock: (p) =>
    a = p
    blockInfo = @getBlockInfo(p)
    
    #front face
    @addCubePoint a, -1.0, -1.0, 1.0
    @addCubePoint a, 1.0, -1.0, 1.0
    @addCubePoint a, 1.0, 1.0, 1.0
    @addCubePoint a, -1.0, 1.0, 1.0
    
    #back face
    @addCubePoint a, -1.0, -1.0, -1.0
    @addCubePoint a, -1.0, 1.0, -1.0
    @addCubePoint a, 1.0, 1.0, -1.0
    @addCubePoint a, 1.0, -1.0, -1.0
    
    #top face
    @addCubePoint a, -1.0, 1.0, -1.0
    @addCubePoint a, -1.0, 1.0, 1.0
    @addCubePoint a, 1.0, 1.0, 1.0
    @addCubePoint a, 1.0, 1.0, -1.0
    
    #bottom face
    @addCubePoint a, -1.0, -1.0, -1.0
    @addCubePoint a, 1.0, -1.0, -1.0
    @addCubePoint a, 1.0, -1.0, 1.0
    @addCubePoint a, -1.0, -1.0, 1.0
    
    #right face
    @addCubePoint a, 1.0, -1.0, -1.0
    @addCubePoint a, 1.0, 1.0, -1.0
    @addCubePoint a, 1.0, 1.0, 1.0
    @addCubePoint a, 1.0, -1.0, 1.0
    
    #left face
    @addCubePoint a, -1.0, -1.0, -1.0
    @addCubePoint a, -1.0, -1.0, 1.0
    @addCubePoint a, -1.0, 1.0, 1.0
    @addCubePoint a, -1.0, 1.0, -1.0
    @addFaces @cubeCount * 24, blockInfo, p #24
    @cubeCount++

  @addCubePoint: (a, xdelta, ydelta, zdelta) =>
    p2 = [a[0] + xdelta * 0.5, a[1] + ydelta * 0.5, a[2] + zdelta * 0.5]
    p3 = @calcPoint(p2)
    
    @vertices.push p3[0]
    @vertices.push p3[1]
    @vertices.push p3[2]

  @typeToCoords: (type) =>
    if type.t
      x = type.t[0]
      y = type.t[1]
      [x / 16.0, y / 16.0, (x + 1.0) / 16.0, y / 16.0, (x + 1.0) / 16.0, (y + 1.0) / 16.0, x / 16.0, (y + 1.0) / 16.0]
    else
      [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

  @addFaces: (i, blockInfo, p) =>
    coords = @typeToCoords(blockInfo)
    show = {}
    show.front = not (@hasNeighbor(p, 0, 0, 1))
    show.back = not (@hasNeighbor(p, 0, 0, -1))
    show.top = not (@hasNeighbor(p, 0, 1, 0))
    show.bottom = not (@hasNeighbor(p, 0, -1, 0))
    show.left = not (@hasNeighbor(p, -1, 0, 0))
    show.right = not (@hasNeighbor(p, 1, 0, 0))
    totfaces = 0
    totfaces++  if show.front
    totfaces++  if show.back
    totfaces++  if show.top
    totfaces++  if show.bottom
    totfaces++  if show.left
    totfaces++  if show.right

    @indices.push.apply @indices, [i + 0, i + 1, i + 2, i + 0, i + 2, i + 3]  if show.front # Front face
    @indices.push.apply @indices, [i + 4, i + 5, i + 6, i + 4, i + 6, i + 7]  if show.back # Back face
    @indices.push.apply @indices, [i + 8, i + 9, i + 10, i + 8, i + 10, i + 11]  if show.top #,  // Top face
    @indices.push.apply @indices, [i + 12, i + 13, i + 14, i + 12, i + 14, i + 15]  if show.bottom # Bottom face
    @indices.push.apply @indices, [i + 16, i + 17, i + 18, i + 16, i + 18, i + 19]  if show.right # Right face
    @indices.push.apply @indices, [i + 20, i + 21, i + 22, i + 20, i + 22, i + 23]  if show.left #y/ Left face
    
    #if (show.front) 
    @textcoords.push.apply @textcoords, coords
    
    #if (show.back) 
    @textcoords.push.apply @textcoords, coords
    
    #if (show.top) 
    @textcoords.push.apply @textcoords, coords
    
    #if (show.bottom) 
    @textcoords.push.apply @textcoords, coords
    
    #if (show.right) 
    @textcoords.push.apply @textcoords, coords
    
    #if (show.left) 
    @textcoords.push.apply @textcoords, coords
  
  convertColors()

