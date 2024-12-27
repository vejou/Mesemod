
local _ = {name = "air", prob = 0}
local d = {name = "ethereal:fiery_dirt", prob = 245}
local s = {name = "default:stone", prob = 255}
local l = {name = "default:lava_source", prob = 255, force_place = true}
local f = {name = "default:lava_flowing", prob = 255}
local o = {name = "default:obsidian", prob = 215}

ethereal.volcanol = {

	size = {x = 17, y = 4, z = 15},

	yslice_prob = {
		{ypos = 0, prob = 127},
		{ypos = 1, prob = 127},
	},

	data = {

	_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,
	_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,
	_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,
	_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,

	_,_,_,_,d,d,d,d,_,_,d,_,_,_,_,_,_,
	_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,
	_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,
	_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,

	_,_,_,d,s,s,s,s,d,d,s,d,d,_,_,_,_,
	_,_,_,_,s,s,s,s,_,_,s,_,_,_,_,_,_,
	_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,
	_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,

	_,_,d,s,o,o,o,o,s,s,o,s,s,d,_,_,_,
	_,_,_,s,f,f,s,f,s,s,f,s,s,_,_,_,_,
	_,_,_,_,s,s,_,s,_,_,s,_,_,_,_,_,_,
	_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,

	_,d,s,o,s,s,s,s,o,o,s,o,o,s,d,_,_,
	_,_,s,l,l,l,l,f,s,f,f,l,l,s,_,_,_,
	_,_,_,s,f,f,s,s,o,s,o,s,s,_,_,_,_,
	_,_,_,_,o,o,o,_,_,_,o,_,_,_,_,_,_,

	_,d,s,o,s,o,o,o,s,s,o,s,s,o,s,d,_,
	_,_,s,f,l,l,l,l,l,l,l,l,l,l,s,_,_,
	_,_,_,s,f,f,f,f,f,f,l,f,l,s,_,_,_,
	_,_,_,_,o,_,_,o,o,o,_,o,o,_,_,_,_,

	_,d,s,o,s,o,s,s,o,o,s,o,s,o,s,d,_,
	_,_,s,s,l,l,l,l,l,l,l,l,l,l,s,_,_,
	_,_,_,_,o,f,f,f,f,f,f,f,l,s,_,_,_,
	_,_,_,_,_,_,_,_,_,_,_,_,o,_,_,_,_,

	_,_,d,s,o,s,o,s,s,s,s,o,s,o,s,d,_,
	_,_,_,s,l,l,l,l,l,l,l,l,l,l,s,_,_,
	_,_,_,s,f,f,f,f,f,f,f,f,l,s,_,_,_,
	_,_,_,_,o,_,_,_,_,_,_,_,s,_,_,_,_,

	_,d,s,o,s,o,o,o,o,o,o,s,o,s,d,_,_,
	_,_,s,l,l,l,l,l,l,l,l,l,l,s,_,_,_,
	_,_,_,s,f,f,f,f,f,f,f,l,s,_,_,_,_,
	_,_,_,_,o,_,_,_,_,_,_,_,o,_,_,_,_,

	_,d,s,o,s,s,s,s,s,s,o,s,o,s,d,_,_,
	_,_,s,l,l,l,l,l,l,l,l,l,l,s,_,_,_,
	_,_,_,s,f,f,f,f,l,l,f,l,s,_,_,_,_,
	_,_,_,_,o,o,_,_,_,o,_,o,_,_,_,_,_,

	_,_,d,s,o,o,o,o,o,o,s,o,s,d,_,_,_,
	_,_,_,s,s,l,f,f,f,f,l,l,s,_,_,_,_,
	_,_,_,_,s,s,s,s,s,s,f,s,_,_,_,_,_,
	_,_,_,_,_,s,o,o,o,_,s,_,_,_,_,_,_,

	_,_,_,d,s,s,s,s,s,s,o,s,d,_,_,_,_,
	_,_,_,_,s,s,s,s,s,s,l,s,_,_,_,_,_,
	_,_,_,_,_,_,_,_,_,_,s,_,_,_,_,_,_,
	_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,

	_,_,_,_,d,d,d,d,d,d,s,s,d,_,_,_,_,
	_,_,_,_,_,_,_,_,_,_,s,s,_,_,_,_,_,
	_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,
	_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,

	_,_,_,_,_,_,_,_,_,_,d,d,_,_,_,_,_,
	_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,
	_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,
	_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,

	_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,
	_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,
	_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,
	_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,

	}
}
