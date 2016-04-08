# From http://www.ibm.com/developerworks/library/wa-coffeescriptcanvas/

class GameOfLife
  currentCellGeneration: null
  cellSize: 10
  numberOfRows: 50
  numberOfColumns: 50
  seedProbability: 0.5
  tickLength: 100
  canvas: null
  drawingContext: null
  run: false

  constructor: ->
    @createCanvas()
    @resizeCanvas()
    @createDrawingContext()
    @seed() # Random dead or alive
    @tick() # do it.

  createCanvas: ->
    @canvas = document.createElement 'canvas'
    document.body.appendChild @canvas
    @canvas.addEventListener "click", (e) => @click(e) #console.log "Click"

  resizeCanvas: ->
    @canvas.height = @cellSize * @numberOfRows
    @canvas.width = @cellSize * @numberOfColumns

  createDrawingContext: ->
    @drawingContext = @canvas.getContext '2d'

  seed: ->
    @currentCellGeneration = []

    for row in [0...@numberOfRows]
      @currentCellGeneration[row] = []

      for column in [0...@numberOfColumns]
        seedCell = @createSeedCell row, column
        @currentCellGeneration[row][column] = seedCell

  createSeedCell: (row, column) ->
    isAlive: Math.random() < @seedProbability
    row: row
    column: column

  tick: =>
    @drawGrid()
    @evolveCellGeneration()
    if @run
      # console.log "Ticking"
      setTimeout @tick, @tickLength
    else
      console.log "Not running"

  drawGrid: ->
    for row in [0...@numberOfRows]
      for column in [0...@numberOfColumns]
        @drawCell @currentCellGeneration[row][column]

  drawCell: (cell) ->
    x = cell.column * @cellSize
    y = cell.row * @cellSize

    if cell.isAlive
      fillStyle = 'rgb(242, 198, 65)'
    else
      fillStyle = 'rgb(38, 38, 38)'

    @drawingContext.strokeStyle = 'rgba(242, 198, 65, 0.5)'
    @drawingContext.strokeRect x, y, @cellSize, @cellSize

    @drawingContext.fillStyle = fillStyle
    @drawingContext.fillRect x, y, @cellSize, @cellSize

  evolveCellGeneration: ->
    newCellGeneration = []

    for row in [0...@numberOfRows]
      newCellGeneration[row] = []

      for column in [0...@numberOfColumns]
        evolvedCell = @evolveCell @currentCellGeneration[row][column]
        newCellGeneration[row][column] = evolvedCell

    @currentCellGeneration = newCellGeneration

  evolveCell: (cell) ->
    evolvedCell =
      row: cell.row
      column: cell.column
      isAlive: cell.isAlive

    numberOfAliveNeighbors = @countAliveNeighbors cell

    if cell.isAlive or numberOfAliveNeighbors is 3
      evolvedCell.isAlive = 1 < numberOfAliveNeighbors < 4

    evolvedCell

  countAliveNeighbors: (cell) ->
    lowerRowBound = Math.max cell.row - 1, 0
    upperRowBound = Math.min cell.row + 1, @numberOfRows - 1
    lowerColumnBound = Math.max cell.column - 1, 0
    upperColumnBound = Math.min cell.column + 1, @numberOfColumns - 1
    numberOfAliveNeighbors = 0

    for row in [lowerRowBound..upperRowBound]
      for column in [lowerColumnBound..upperColumnBound]
        continue if row is cell.row and column is cell.column

        if @currentCellGeneration[row][column].isAlive
          numberOfAliveNeighbors++

    numberOfAliveNeighbors

  start: ->
    console.log "Start"
    @run = true
    setTimeout @tick, @tickLength

  stop: ->
    console.log "Stop"
    @run = false

  clear: ->
    for row in [0...@numberOfRows]
      for column in [0...@numberOfColumns]
        @currentCellGeneration[row][column].isAlive = 0
    @drawGrid()

  reseed: ->
    @seed()
    @drawGrid()

  click: (e) ->
    #x = cell.column * @cellSize
    #y = cell.row * @cellSize
    x = e.clientX - @canvas.offsetLeft
    y = e.clientY - @canvas.offsetTop - 2 # Not sure why we need the 2.
    row = Math.floor y / @cellSize
    col = Math.floor x / @cellSize
    console.log e
    console.log "Click! " + col + ', ' + row
    # Toggle cell
    @currentCellGeneration[row][col].isAlive = !@currentCellGeneration[row][col].isAlive
    @drawGrid()

window.GameOfLife = GameOfLife
