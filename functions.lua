local functions = {}

function functions.clamp(n, nmin, nmax)
	return math.max(math.min(n, nmax), nmin)
end

function functions.getDirection(x1,y1,x2,y2)
	return math.atan2(y1-y2,x1-x2)
end

function functions.getDistance(x1,y1,x2,y2)
	return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end
function functions.checkArea(xx,yy,x1,y1,x2,y2)
	if xx >= x1 and xx <= x2 and yy >= y1 and yy <= y2 then
		return true
	else
		return false
	end
end

return functions