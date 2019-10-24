gextends Node2D

const CELLS_WIDTH = 30
const CELLS_HEIGHT = 30
const RATIO_EMPTY = 0.4
const CELLS_TO_TILE_RATIO = 5
const MAX_SPACE_WIDTH = 1
const MAX_SPACE_HEIGHT = 1
const MAX_ROOM_WIDTH = 8
const MAX_ROOM_HEIGHT = 8
const ROOM_SIZE_TEST= 20
const SPACING = 3
const HALL_WIDTH = 4
const RATIO_OF_GIVING_UP = 0.2 # i don't know what to call this
const DIMINISH = 0.002
const ADDITIONAL_DOOR = 0.2

var mapMan = []
var mapLegend = { 0: " . ", 1: " # ", 2: " | ", 3: " R ", 4:" : "}

var isStart = true

var theRoomTree

class Space:
	
	var roomWidth
	var roomHeight
	var roomX
	var roomY
	
	func _init(_roomWidth, _roomHeight, _roomX, _roomY):
		roomWidth = _roomWidth
		roomHeight = _roomHeight
		roomX = _roomX
		roomY = _roomY
		
	func setSize(_roomWidth, _roomHeight):
		roomWidth = _roomWidth
		roomHeight = _roomHeight
		
	func setPos(_roomX, _roomY):
		roomX = _roomX
		roomY = _roomY
	
	func getArea() -> int:
		return roomWidth * roomHeight

class Room:
	var roomX
	var roomY
	var roomXEnd
	var roomYEnd
	var entryPointX
	var entryPointY
	#entrances
	var left: Room = null
	var right: Room = null
	var up: Room = null
	var down: Room = null
	
	func _init(_roomX, _roomY, _roomXEnd, _roomYEnd):
		roomX = _roomX
		roomY = _roomY
		roomXEnd = _roomXEnd
		roomYEnd = _roomYEnd
		entryPointX = roomX
		entryPointY = roomY
		
	func setPos(_roomX, _roomY):
		roomX = _roomX
		roomY = _roomY
		
	func setEndPoint(_x, _y):
		roomXEnd = _x
		roomYEnd = _y
		
	func setEntry(point):
		entryPointX = point[0]
		entryPointY = point[1]

func init():
	randomize()
	mapMan = Generate_Empty_Cells()
	#Print_Map_Contents(mapMan, mapLegend)
	return
	
func _draw():
	if (theRoomTree):
		var queue = [theRoomTree]
		var count = 1
		while(queue.size() > 0):
			var cur = queue[0]
			queue.pop_front()
			if (cur.left != null):
				var theHall = Rect2(Vector2(cur.left.entryPointX + .5, cur.left.entryPointY + .5) * ROOM_SIZE_TEST - Vector2(0, (HALL_WIDTH/2)), Vector2(ROOM_SIZE_TEST, HALL_WIDTH))
				draw_rect(theHall, Color(count, count, count))
				count -= DIMINISH
				queue.append(cur.left)
			if (cur.right != null):
				var theHall = Rect2(Vector2(cur.right.entryPointX + .5, cur.right.entryPointY + .5) * ROOM_SIZE_TEST - Vector2(0, (HALL_WIDTH/2)), Vector2(-ROOM_SIZE_TEST, HALL_WIDTH))
				draw_rect(theHall, Color(count, count, count))
				count -= DIMINISH
				queue.append(cur.right)
			if (cur.up != null):
				var theHall = Rect2(Vector2(cur.up.entryPointX + .5, cur.up.entryPointY + .5) * ROOM_SIZE_TEST - Vector2((HALL_WIDTH/2), 0), Vector2(HALL_WIDTH, ROOM_SIZE_TEST))
				draw_rect(theHall, Color(count, count, count))
				count -= DIMINISH
				queue.append(cur.up)
			if (cur.down != null):
				var theHall = Rect2(Vector2(cur.down.entryPointX + .5, cur.down.entryPointY + .5) * ROOM_SIZE_TEST - Vector2((HALL_WIDTH/2), 0), Vector2(HALL_WIDTH, -ROOM_SIZE_TEST))
				draw_rect(theHall, Color(count, count, count))
				count -= DIMINISH
				queue.append(cur.down)
		
		queue = [theRoomTree]
		count = 1
		while(queue.size() > 0):
			var cur = queue[0]
			queue.pop_front()
			
			var startVec = Vector2(cur.roomX, cur.roomY) * ROOM_SIZE_TEST
			var roomSize = Vector2((cur.roomXEnd - cur.roomX + 1), (cur.roomYEnd - cur.roomY + 1)) * (ROOM_SIZE_TEST)
			var theCont = Rect2(startVec, roomSize)
			var theRect  = Rect2(startVec + Vector2(SPACING , SPACING), roomSize - Vector2(SPACING * 2, SPACING * 2))
			var col
			var startRec = Rect2(Vector2(cur.entryPointX, cur.entryPointY) * ROOM_SIZE_TEST + Vector2(SPACING * 1.5, SPACING * 1.5), Vector2(ROOM_SIZE_TEST, ROOM_SIZE_TEST) - Vector2(SPACING * 3, SPACING * 3))
			if isStart:
				col = Color(1, 0, 1)
				isStart = false
			else:
				col = Color(count, count, count)
				count -= DIMINISH
			draw_rect(theRect, col)
			#draw_rect(theCont, Color(1, 1, 1, 0.01), false)
			#draw_rect(startRec, Color(0.3, 0.3, 0.3))
			
			if (cur.left != null):
				queue.append(cur.left)
			if (cur.right != null):
				queue.append(cur.right)
			if (cur.up != null):
				queue.append(cur.up)
			if (cur.down != null):
				queue.append(cur.down)
	
func Generate_Empty_Cells():
	var numEmpty = floor(CELLS_WIDTH * CELLS_HEIGHT) * RATIO_EMPTY
	var tmpMap
	var curEmpty = 0
	var listRoom = []
	while (true):
		curEmpty = 0
		tmpMap = Make_Empty_Map(CELLS_WIDTH, CELLS_HEIGHT)
		while (curEmpty < numEmpty):
			var newRoom = Space.new(0, 0, 0, 0)
			#size
			var roomWidth = floor(rand_range(1, MAX_SPACE_WIDTH)) + 1
			var roomHeight = floor(rand_range(1, MAX_SPACE_HEIGHT)) + 1
			newRoom.setSize(roomWidth, roomHeight)
			#print ("room size: ", roomWidth, ", ", roomHeight)
			
			#pick location
			var roomX = floor(rand_range(0, tmpMap.size() - roomWidth + 1))
			var roomY = floor(rand_range(0, tmpMap[0].size() - roomHeight + 1))
			newRoom.setPos(roomX, roomY)
			#print ("room placement: ", roomX, ", ", roomY)
			
			
			if (Can_Place_Space(tmpMap, newRoom)):
				#print ("room Area: " , newRoom.getArea(), ",at x: ", newRoom.roomX, ", at y: ", newRoom.roomY)
				tmpMap = Place_Space(tmpMap, newRoom)
				curEmpty += newRoom.getArea()
				listRoom.append(newRoom)
				
		if (Check_Reachable(tmpMap)):
			print("generated")
			tmpMap = Try_Generate_Dungeon(tmpMap)
			Print_Map_Contents(tmpMap, mapLegend)
			break
		else:
			print("retrying")
			
	return tmpMap

func Try_Generate_Dungeon(theMap):
	randomize()
	#just ballin'
	#find start position
	var startPos = [0, 0]
	var endPos = [0, 0]
	var startRoom
	while(true):
		startPos[0] = floor(rand_range(0, theMap.size() - 1))
		startPos[1] = floor(rand_range(0, theMap[0].size() - 1))
		endPos[0] = floor(rand_range(0, MAX_ROOM_WIDTH)) + startPos[0]
		endPos[1] = floor(rand_range(0, MAX_ROOM_HEIGHT)) + startPos[1]
		startRoom = Room.new(startPos[0], startPos[1], endPos[0], endPos[1])
		if (Can_Place_Room(theMap, startRoom)and endPos[0] + 1 <theMap.size() and endPos[1] + 1 <theMap[0].size()):
			for x in range(startPos[0], endPos[0] + 1):
				for y in range(startPos[1], endPos[1] + 1):
					theMap[x][y] = 0
			break
	print ("starting at :", startPos, ", ending at: ", endPos)
	
	theRoomTree = startRoom
	var theQueue = [theRoomTree]
	
	while (theQueue.size() > 0):
		var cur  = theQueue[0]
		theQueue.pop_front()
		# 1. scan each side to find possible room placement (no space or other room), save this point and set as entry point for new room
		# 2. once found, go diagonally:
		#		if left -> left, up/down
		#		if right -> right, up/down
		#		if up -> left/right, up
		#		if down -> left/right, down
		#	 until reach max size or reach occupied tile (room or space), save position
		# 3. create room from previous saved position to entry tile
		
		# -----------------------------------------------------------------------------------
		# LEFT
		if (cur.left == null and cur.roomX - 1 > 0):
			var new = null
			var count = cur.roomY
			while (count <= cur.roomYEnd):
				#set to 
				var newStart = [cur.roomX - 1, count]
				count += 1
				if (theMap[newStart[0]][newStart[1]] == 1 or theMap[newStart[0]][newStart[1]] == 0 or theMap[newStart[0]][newStart[1]] == 4):
					continue
				
				var newEnd = newStart
				var newEntry = newStart
				
				# EXPAND ROOM
				# width if horizontal, height if vertical
				for x in range(MAX_ROOM_WIDTH):
					randomize()
					var theRand = rand_range(0, 1)
					var tmpStart = [newStart[0], newStart[1]]
					var tmpEnd = [newEnd[0], newEnd[1]]
					tmpStart[0] -= 1
					if (theRand < RATIO_OF_GIVING_UP):
						tmpStart[1] -= 1
					elif(theRand < RATIO_OF_GIVING_UP * 2):
						tmpEnd[1] += 1
					if (!Can_Place_In_Vectors(theMap, tmpStart, tmpEnd)):
						break
					else:
						newStart = [tmpStart[0], tmpStart[1]]
						newEnd = [tmpEnd[0], tmpEnd[1]]
					
				new = Room.new(newStart[0], newStart[1], newEnd[0], newEnd[1])
				new.setEntry(newEntry)
				if (Can_Place_Room(theMap, new)):
					for x in range(newStart[0], newEnd[0] + 1):
						for y in range(newStart[1], newEnd[1] + 1):
							theMap[x][y] = 0
					break
			if (new != null):
				cur.left = new
				theQueue.append (new)
		# RIGHT
		if (cur.right == null and cur.roomXEnd + 1 < theMap.size() - 1):
			var new = null
			var count = cur.roomY
			while (count <= cur.roomYEnd):
				#set to 
				var newStart = [cur.roomXEnd + 1, count]
				count += 1
				if (theMap[newStart[0]][newStart[1]] == 1 or theMap[newStart[0]][newStart[1]] == 0 or theMap[newStart[0]][newStart[1]] == 4):
					continue
				
				var newEnd = newStart
				var newEntry = newStart
				
				# EXPAND ROOM
				# width if horizontal, height if vertical
				for x in range(MAX_ROOM_WIDTH):
					randomize()
					var theRand = rand_range(0, 1)
					var tmpStart = [newStart[0], newStart[1]]
					var tmpEnd = [newEnd[0], newEnd[1]]
					tmpEnd[0] += 1
					if (theRand < RATIO_OF_GIVING_UP):
						tmpStart[1] -= 1
					elif(theRand < RATIO_OF_GIVING_UP * 2):
						tmpEnd[1] += 1
					if (!Can_Place_In_Vectors(theMap, tmpStart, tmpEnd)):
						break
					else:
						newStart = [tmpStart[0], tmpStart[1]]
						newEnd = [tmpEnd[0], tmpEnd[1]]
					
				new = Room.new(newStart[0], newStart[1], newEnd[0], newEnd[1])
				new.setEntry(newEntry)
				if (Can_Place_Room(theMap, new)):
					for x in range(newStart[0], newEnd[0] + 1):
						for y in range(newStart[1], newEnd[1] + 1):
							theMap[x][y] = 0
					break
			if (new != null):
				cur.right = new
				theQueue.append (new)
		# UP
		if (cur.up == null and cur.roomY - 1 > 0):
			var new = null
			var count = cur.roomX
			while (count <= cur.roomXEnd):
				#set to 
				var newStart = [count, cur.roomY - 1]
				count += 1
				if (theMap[newStart[0]][newStart[1]] == 1 or theMap[newStart[0]][newStart[1]] == 0 or theMap[newStart[0]][newStart[1]] == 4):
					continue
				
				var newEnd = newStart
				var newEntry = newStart
				
				# EXPAND ROOM
				# width if horizontal, height if vertical
				for x in range(MAX_ROOM_HEIGHT):
					randomize()
					var theRand = rand_range(0, 1)
					var tmpStart = [newStart[0], newStart[1]]
					var tmpEnd = [newEnd[0], newEnd[1]]
					tmpStart[1] -= 1
					if (theRand < RATIO_OF_GIVING_UP):
						tmpStart[0] -= 1
					elif(theRand < RATIO_OF_GIVING_UP * 2):
						tmpEnd[0] += 1
					if (!Can_Place_In_Vectors(theMap, tmpStart, tmpEnd)):
						break
					else:
						newStart = [tmpStart[0], tmpStart[1]]
						newEnd = [tmpEnd[0], tmpEnd[1]]
					
				new = Room.new(newStart[0], newStart[1], newEnd[0], newEnd[1])
				new.setEntry(newEntry)
				if (Can_Place_Room(theMap, new)):
					for x in range(newStart[0], newEnd[0] + 1):
						for y in range(newStart[1], newEnd[1] + 1):
							theMap[x][y] = 0
					break
			if (new != null):
				cur.up = new
				theQueue.append (new)
		
		# DOWN
		if (cur.down == null and cur.roomYEnd + 1 < (theMap[0].size() - 1)):
			var new = null
			var count = cur.roomX
			while (count <= cur.roomXEnd):
				#set to 
				var newStart = [count, cur.roomYEnd + 1]
				count += 1
				if (theMap[newStart[0]][newStart[1]] == 1 or theMap[newStart[0]][newStart[1]] == 0 or theMap[newStart[0]][newStart[1]] == 4):
					continue
				
				var newEnd = newStart
				var newEntry = newStart
				
				# EXPAND ROOM
				# width if horizontal, height if vertical
				for x in range(MAX_ROOM_HEIGHT):
					randomize()
					var theRand = rand_range(0, 1)
					var tmpStart = [newStart[0], newStart[1]]
					var tmpEnd = [newEnd[0], newEnd[1]]
					tmpEnd[1] += 1
					if (theRand < RATIO_OF_GIVING_UP):
						tmpStart[0] -= 1
					elif(theRand < RATIO_OF_GIVING_UP * 2):
						tmpEnd[0] += 1
					if (!Can_Place_In_Vectors(theMap, tmpStart, tmpEnd)):
						break
					else:
						newStart = [tmpStart[0], tmpStart[1]]
						newEnd = [tmpEnd[0], tmpEnd[1]]
					
				new = Room.new(newStart[0], newStart[1], newEnd[0], newEnd[1])
				new.setEntry(newEntry)
				if (Can_Place_Room(theMap, new)):
					for x in range(newStart[0], newEnd[0] + 1):
						for y in range(newStart[1], newEnd[1] + 1):
							theMap[x][y] = 0
					break
			if (new != null):
				cur.down = new
				theQueue.append (new)
		theQueue = shuffleList(theQueue)
	return theMap

func Place_Space(theMap, theRoom: Space):
	
	for x in range(theRoom.roomWidth):
		for y in range(theRoom.roomHeight):
			theMap[x + theRoom.roomX][y + theRoom.roomY] = 1
			#print("placing at: ", x + roomX, ", ", y + roomY)
	return theMap

func Can_Place_Space(theMap, theRoom:Space) -> bool:
	for x in range(theRoom.roomWidth):
		for y in range(theRoom.roomHeight):
			if (theMap[x + theRoom.roomX][y + theRoom.roomY] == 1):
				#print ("cant place room, retrying")
				return false
			#print("placing at: ", x + roomX, ", ", y + roomY)
	return true

func Can_Place_Room(theMap, theRoom:Room) -> bool:
	for x in range(theRoom.roomX, theRoom.roomXEnd):
		for y in range(theRoom.roomY, theRoom.roomYEnd):
			if (theRoom.roomXEnd > theMap.size() - 1 or theRoom.roomYEnd > theMap[0].size() - 1 or theRoom.roomX < 0 or theRoom.roomY < 0 or theMap[x][y] != 2):
				#print ("cant place room, retrying")
				return false
			#print("placing at: ", x + roomX, ", ", y + roomY)
	return true
	
func Can_Place_In_Vectors(theMap, startPos, endPos):
	for x in range(startPos[0], endPos[0] + 1):
		for y in range(startPos[1], endPos[1] + 1):
			if (x < 0 or x > theMap.size() - 1 or y < 0 or y > theMap[0].size() - 1 or theMap[x][y] != 2):
				#print ("cant place room, retrying")
				return false
			#print("placing at: ", x + roomX, ", ", y + roomY)
	return true

func Check_Reachable(theMap) -> bool:
	var flag = true
	var startPos = [0, 0]
	var theQueue = []
	#find a start position
	while (theMap[startPos[0]][startPos[1]] != 0):
		startPos[0] = floor(rand_range(0, theMap.size()))
		startPos[1] = floor(rand_range(0, theMap[0].size()))
		
	theQueue.append(startPos)
	while (theQueue.size() > 0):
		#Print_Map_Contents(theMap, mapLegend)
		var cell = theQueue[0]
		theQueue.pop_front()
		#traverse all direction:
		# X-
		if (cell[0] > 0 and theMap[cell[0] - 1][cell[1]] == 0):
			var newCell = [cell[0] - 1, cell[1]]
			theMap[newCell[0]][newCell[1]] = 2
			theQueue.append(newCell)
		# X+
		if (cell[0] < theMap.size() - 1 and theMap[cell[0] + 1][cell[1]] == 0):
			var newCell = [cell[0] + 1, cell[1]]
			theMap[newCell[0]][newCell[1]] = 2
			theQueue.append(newCell)
		# Y-
		if (cell[1] > 0 and theMap[cell[0]][cell[1] - 1] == 0):
			var newCell = [cell[0], cell[1] - 1]
			theMap[newCell[0]][newCell[1]] = 2
			theQueue.append(newCell)
		# Y+
		if (cell[1] < theMap[0].size() - 1 and theMap[cell[0]][cell[1] + 1] == 0):
			var newCell = [cell[0], cell[1] + 1]
			theMap[newCell[0]][newCell[1]] = 2
			theQueue.append(newCell)
		
	for x in range(theMap.size()):
		for y in range(theMap[0].size()):
			if (theMap[x][y] == 0):
				flag = false
	return flag

func Print_Map_Contents(theMap, mapLegend):
	var width = theMap.size()
	var height = theMap[0].size()
	var border = ""
	for i in range(CELLS_WIDTH):
		border += "---"
	print (border)
	for y in range(height):
		var outputLine = ""
		for x in range(width):
			outputLine += mapLegend.get(theMap[x][y], " N ")
		print (outputLine)
	print (border)

func shuffleList(list):
	var shuffledList = []
	var indexList = range(list.size())
	for i in range(list.size()):
		var x = randi()%indexList.size()
		shuffledList.append(list[indexList[x]])
		indexList.remove(x)
	return shuffledList

func Make_Empty_Map(width: int, height: int):
	var theMap = []
	for x in range(width):
		theMap.append([])
		for y in range(height):
			theMap[x].append(0)
	return theMap

func _on_Timer_timeout():
	isStart = true
	mapMan = Generate_Empty_Cells()
	update() 
	pass # Replace with function body.
