pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
  -- list of all mobs+player
mobs={}


-- camera
c={
	x = 0, -- camera position
	y = 0,
	px = 0, 
	py = 0
}

-- size of world
wmap_w = 128 -- w map tile wid
wmap_h = 32
wmap_pw = wmap_w*8 -- pixel wid
wmap_ph = wmap_h*8

-- time
gt = time() -- game time in 30ths
dt = 1/30	-- delta time per update
lmb_time = 0
rmb_time = 0

function _init()

	-- enable extended kyb and mouse
	-- 
	-- 0x1 enable
	-- 0x2 mouse buttons trigger btn(4)..btn(6)
	-- 0x4 pointer lock (use stat 38..39 to read movements)
	flags = 7
	poke(0x5f2d, flags)
	
	--player
	p=new_mob(1)
	add(mobs,p)
	p.x,p.y=64,64

	for i=1,1 do
		spawn_mob(2+flr(rnd(2),x,y))
	end
-- music(0,1000,15)

	init_ui()
end	

function init_ui()
	make_inv_window()
end

function handle_keyboard(key)
	--item
	if key=="r" then
		--pickup
	elseif key=="q" then
		itemwind = get_window("item")
		if itemwind then
			close_window_name("item")
		else
			text = {"item window",
					"",
					"has a few things",
					"",
					"and stuff"}
			new_window("item",20,50,100,30,text)
		end
	elseif key=="\t" then
		invwind = get_window("inv")
		if invwind then
			invwind.m_visible = not invwind.m_visible
		end
	end
end

keys={
	a =   {cur=false, prev=false, code=4}, -- sdl_scancode_a = 4
	d =   {cur=false, prev=false, code=7}, -- sdl_scancode_d = 7
	w =   {cur=false, prev=false, code=26}, -- sdl_scancode_w = 26
	s =   {cur=false, prev=false, code=22}, -- sdl_scancode_s = 22
	q =   {cur=false, prev=false, code=20}, -- sdl_scancode_q = 20
	e =   {cur=false, prev=false, code=8}, -- sdl_scancode_e = 8
	sp =  {cur=false, prev=false, code=44}, -- sdl_scancode_space = 44
	lsh = {cur=false, prev=false, code=225}, -- sdl_scancode_lshift = 225
	tab = {cur=false, prev=false, code=43}, -- sdl_scancode_tab = 43
	n1 =  {cur=false, prev=false, code=30},
	n2 =  {cur=false, prev=false, code=31},
	n3 =  {cur=false, prev=false, code=32},
	n4 =  {cur=false, prev=false, code=33},
	n5 =  {cur=false, prev=false, code=34},
	n6 =  {cur=false, prev=false, code=35},
	n7 =  {cur=false, prev=false, code=36},
	n8 =  {cur=false, prev=false, code=37},
}

function debounce()
	for x in all(keys) do
		
	end
end

function readkeys()
	for name,key in pairs(keys) do
		key.prev = key.cur
		key.cur = stat(28,key.code)
	end
end

function update_input()
	-- read mouse
	mx = stat(32) -- mouse x
	my = stat(33) -- mouse y
	mdx = stat(38) -- mouse dx
	mdy = stat(39) -- mouse dy
	mb = stat(34) -- mouse buttons
	lmb = band(mb,1)
	rmb = band(mb,2)
	
	readkeys()
	
    -- read keyboard
	--[[ keys["a"] = stat(28, 4) -- sdl_scancode_a = 4 ]]
	--[[ keys["d"] = stat(28, 7) -- sdl_scancode_d = 7 ]]
	--[[ keys["w"] = stat(28, 26) -- sdl_scancode_w = 26 ]]
	--[[ keys["s"] = stat(28, 22) -- sdl_scancode_s = 22 ]]
	
	--[[ keys["q"] = stat(28, 20) -- sdl_scancode_q = 20 ]]
	--[[ keys["e"] = stat(28, 8) -- sdl_scancode_e = 8 ]]

	--[[ keys["sp"] = stat(28, 44) -- sdl_scancode_space = 44 ]]
	--[[ keys["lsh"] = stat(28, 225) -- sdl_scancode_lshift = 225 ]]

	--[[ keys["tab"] = stat(28, 43) -- sdl_scancode_tab = 43 ]]

	--[[ keys["n1"] = stat(28, 30) ]]
	--[[ keys["n2"] = stat(28, 31) ]]
	--[[ keys["n3"] = stat(28, 32) ]]
	--[[ keys["n4"] = stat(28, 33) ]]
	--[[ keys["n5"] = stat(28, 34) ]]
	--[[ keys["n6"] = stat(28, 35) ]]
	--[[ keys["n7"] = stat(28, 36) ]]
	--[[ keys["n8"] = stat(28, 37) ]]
		
	-- read keyboard keypresses
	key = -1
	if	stat(30) then
		 key = stat(31)
		 handle_keyboard(key)
	end
	
	--b_l = btn(0,1)
	--b_r = btn(1,1)
	--b_u = btn(2,1)
	--b_d = btn(3,1)

	b_l = keys["a"].cur
	b_r = keys["d"].cur
	b_u = keys["w"].cur
	b_d = keys["s"].cur
	
	if lmb != 0 then
		if lmb_time > 0 then
		 lmb=0
		end
		lmb_time+=dt
	else
		lmb_time=0
	end
	
	if keys["sp"].cur and not keys["sp"].prev then
		printh("dodge");
		p.vx += -p.fx * 2
		p.vy += -p.fy * 2
	end
	
end

function update_ply_cam_pos()
	-- add input to player velocity
	if (b_l) p.vx-=p.v*dt
	if (b_r) p.vx+=p.v*dt
	if (b_u) p.vy-=p.v*dt
	if (b_d) p.vy+=p.v*dt

    -- face movement direction
	if mag2d(p.vx,p.vy) > 0 then
		p.fx,p.fy = norm2d(p.vx,p.vy)
	end
	
	p.fx,p.fy = norm2d(mx - (p.x-c.x), my - (p.y-c.y))
	
	-- do player position update
	update_mob(p)

	-- keep player in bounds
	p.x=min(max(0,p.x),128*128)
	p.y=min(max(0,p.y),128*32)

	-- point camera at player 
	-- and keep in bounds of map
	c.x = min(max(0,p.x-64),wmap_pw-128)
	c.y = min(max(0,p.y-64),wmap_ph-128)
end

function player_attack()
	local stamina_cost = 4
	if (p.stamina - stamina_cost < 0) return
	if do_attack(p,1) then
		sfx(0)
		p.stamina -= stamina_cost
	end
end

function update_player()
	update_input()
	update_ply_cam_pos()
	
	local s_atfeet = sget(p.x+4,p.y+7)
	local t_atfeet = mget(p.x+4,p.y+7)

	if lmb != 0 then
		if not window_click(mx,my,lmb,rmb) then
			player_attack(p)
		end
	end
	
	if p.vx + p.vy > 0.1 then
		play_anim(p, "wlk")
	else
		play_anim(p,"idl")
	end
	
	-- stamina regen
	p.stamina = min(p.stamina+0.05, p.mdata.stamina_max)
--	p.health = min(p.health+0.05, p.mdata.health_max)
	update_animation(p)
	update_attack(p)
end

function update_blood()
	for b in all(blood) do
		b.x+=b.vx
		b.y+=b.vy
		b.vx /= 2
		b.vy /= 2
		b.t -= dt
		b.radius-=0.01
	end
	for b in all(blood) do
		if b.t<=0 then
			del(blood,b)
		end
	end
end


function _update()
	--player handled specially
	update_blood()
	
	--update remaining all mobs
	for m in all(mobs) do
		if(m!=p) update_mob(m)
	end

	update_player()
	
	dt=time()-gt
	gt=time()
end

function draw_mob(m)
	local f=m.curframes[m.animframe]
	local flipped = m.fx < 0

	-- flash if status
	if m.flash_frames>0 then
		if m.flash_frames%2 then
			circfill (m.x,m.y,m.radius,m.flash_color)
		end
		m.flash_frames -= 1
	end

	local dead=false
	if (m.health <=0) dead=true
	
	local linecol = 0
	if (dead)linecol=8
	
	line(m.x-3, m.y+3, m.x+3,m.y+3,linecol)
	
	spr(f,m.x-4,m.y-4,1,1,flipped,dead)

	draw_attack(m)
end

function debug_draw_mob(m)
--	line(m.x,m.y,m.x+m.fx*5,m.y+m.fy*5,7)
end

function draw_blood()
	for b in all(blood) do
		circfill(b.x,b.y,b.radius,8)
	end
end

function draw_mobs()
	for m in all(mobs) do
		if m!=p then
			draw_mob(m)
			debug_draw_mob(m)
		end
	end
end

function draw_damage()
	for d in all(floating_text) do
		print(d.txt,d.x,d.y-4,d.c)
		d.t -= 1
		d.y -= 1
		if (d.t<=0) del(floating_text,d)
	end
end

function _draw()
	cls()
	camera(c.x,c.y)
	map(0,0,0,0)
	
	palt(0,false)
	palt(2,true)
	
	draw_blood()

	draw_mobs()
	
	draw_mob(p)
	
	draw_damage()
	
	palt(0,true)
	palt(2,false)

	
	draw_ui()

	draw_debug()
end

function draw_hud()
	-- health
	local height=22
	local bottom=122
	local top = bottom - height * p.health / p.mdata.health_max
	rect(8,100,11,122,0)
	rectfill(8,top,11,bottom,8)
	
	-- food
	rect(2,106,6,110,0)
	rect(2,112,6,116,0)
	rect(2,118,6,122,0)
	
	-- stamina
	local width = 16
	local left = 56
	local right = left + width * p.stamina/p.mdata.stamina_max
	rect(56,120, 72,122,0)
	rectfill(left,120,right,122,10)
	
end

function draw_ui()
	camera(0, 0)
	
	-- toolbar
	rectfill(0,0,6*10,10,5)
	rect(1,1,9,9,0)
	spr(48,2,2)
	rect(11,1,19,9,0)
	spr(49,12,2)
	rect(21,1,29,9,0)
	spr(50,22,2)
	rect(31,1,39,9,0)
	spr(51,32,2)
	rect(41,1,49,9,0)
	spr(52,42,2)
	rect(51,1,59,9,0)
	spr(53,52,2)
	
	draw_hud()
	
	draw_windows()
end

function draw_debug()
	-- draw mouse
	spr(16,mx,my)
	
	-- draw debug text
	color(7)
	print("gt:"..gt,0,16)
-- print("dt:"..dt)
-- print("b :"..#blood)
-- print("c :"..c.x..","..c.y) 
-- print("p :"..p.x..","..p.y) 
-- print("pv:"..p.vx..","..p.vy) 
-- print("pa:"..p.animframe..","..p.curanim[p.animframe])
-- print("m :"..m.x..","..m.y) 
-- print("mv:"..m.vx..","..m.vy)
-- print("ma:"..m.animframe..":"..m.curanim[m.animframe]) 
-- print()
	print("mo:"..mx..","..my..":"..mdx..","..mdy..":"..mb)
	
	-- player debug
	--local sx,sy = p.x-c.x,p.y-c.y
	--line(sx, sy, sx+p.fx*10, sy+p.fy*10, 8)
	
end

-----------------------------------------------------------------------------------------------------------------------------

-->8
-- windows

windowlist = {}

function insetrect(x1,y1,x2,y2)
	return x1+1,y1+1,x2-1,y2-1
end

function pointinrect(x,y,x1,y1,x2,y2)
	if (x>=x1 and x<x2 and y>=y1 and y<y2) return true
	return false
end

function new_window(name, 
					x, y, w, h,
					text, 
					draw, click)
	local wind = {
		m_name = name,
		m_x = x,
		m_y = y,
		m_w = w,
		m_h = h,
		m_text = text,
		m_visible = true,
		m_draw = nil,
		m_click = nil,
	}
	wind.m_draw = draw
	wind.m_click = click
	add(windowlist, wind)
	return wind
end

function close_window(wind)
	del(windowlist, wind)
end

function close_window_name(name)
	local wind=get_window(name)
	if (wind) close_window(wind)
end

function draw_window(wind)
	local x1=wind.m_x
	local y1=wind.m_y
	local x2=x1 + wind.m_w
	local y2=y1 + wind.m_h

	local height = #wind.m_text
	
	rect(x1,y1,x2,y2,7)
	x1,y1,x2,y2 = insetrect(x1,y1,x2,y2)
	rectfill(x1,y1,x2,y2,4)
	x1,y1,x2,y2 = insetrect(x1,y1,x2,y2)

	local i=0
	for text in all(wind.m_text) do
		print(text,x1,y1+i*5,15)
		i+=dt
	end
	
	if (wind.m_draw != nil) wind.m_draw()
end

function draw_windows()
	for wind in all(windowlist) do
--		printh(wind.m_name)
		if (wind.m_visible) draw_window(wind)
	end
end

function get_window(name)
	for wind in all(windowlist) do
		 if wind.m_name == name then
		  return wind
		 end
	end
	return nil
end

function close_windows()
	for wind in all(windowlist) do
		 close_window(wind)
	end
end

function draw_inv_window()
	local wx = inv_wind.m_x+2
	local wy = inv_wind.m_y+2
	for y=0,3 do
		for x=0,7 do
			local x1=wx + x*8
			local y1=wy + y*8
			local x2=x1 + 8
			local y2=y1 + 8
			rect(x1,y1,x2,y2,0)
		end
	end
end

function click_inv_window(wind, _x, _y, _lmb, _rmb)
	printh("click "..wind.m_name.." ".._x..",".._y)

end

function make_inv_window()
	inv_wind = new_window("inv", 0, 10, 64+4, 32+4, "", draw_inv_window, click_inv_window)
end

function window_click(_mx,_my,_rmb,_lmb)
	for wind in all(windowlist) do
		if wind.m_visible then
			if pointinrect(_mx, _my, wind.m_x, wind.m_y, wind.m_x+wind.m_w, wind.m_y+wind.m_h) then
				printh(wind.m_name.." ".._mx..",".._my)
				if (wind.m_click) wind.m_click(wind, _mx, _my, _rmb, _lmb)
				return true
			end
		end
	end
	
	return false
end

-----------------------------------------------------------------------------------------------------------------------------

-->8
floating_text = {}
blood={}

--combat and animations
function update_animation(m)
	m.curframes = m.anim.frames

-- if (m.anim.name!="wlk" or mag2d(m.vx, m.vy) > 0.1) then
		if gt>=m.animnext then
			m.animframe+=1
			m.animnext=gt+0.3
			f=m.curframes[m.animframe]
			if (f==-1) then
				m.animframe=#m.curframes-1
			elseif (f==0) then
				m.animframe=1
			end
		end
--	end
end

function play_anim(m, name)
	if (m.animname==name) return
	for anim in all(m.animset) do
		if (anim.name==name) then
			m.anim=anim
			m.animname = name
			m.animframe=1
		end
	end
end

function bleed(_x,_y,dx,dy,amt)
	for i=1,rnd(amt+5) do
		add(blood,
			{x=_x+rnd(5)-3,
				y=_y+rnd(5)-3,
				vx=dx*3,vy=dy*3,
			t=7,radius=rnd(2)})
	end
end

function die(m)
	force_state(m,"dead")
	spawn_loot(m)
end

function take_damage(m,dmg)
	m.flash_frames=4
	m.flash_color=7
	add(floating_text,
					{txt=dmg,x=m.x,y=m.y,t=10,c=7})
	m.health-=dmg
	if m.health<=0 then
		m.health=0
		die(m)
	end
end

function do_damage(a,atk,d)
	if not a.hitting then
		local ox,oy=d.x-a.x,d.y-a.y
		ox,oy=norm2d(ox,oy)
		d.vx += ox*atk.knockback
		d.vy += oy*atk.knockback
--		printh(atk.knockback)
		bleed(d.x,d.y,ox,oy,a.damage)
		
		take_damage(d,a.damage*atk.dam_mult)
		sfx(2)
		a.hitting = true
	end
end


function do_attack(m,id)
	printh("doattack")
	if m.attacking then
		local ratio = m.atk_progress/m.cur_atk.dur
		-- can we combo?
		if m.combo_index < #m.attacks.atks and 
				ratio > m.cur_atk.comstart
				and ratio <= 1.0 then
			m.combo_index += 1
		else
			return false
		end
	end
	m.cur_atk = m.attacks.atks[m.combo_index]
	m.atk_progress = 0
	m.attacking = true
	m.hitting = false
	
	return true
end

function update_attack(m)
	if (not m.attacking) return

	local atk=m.cur_atk
	local dur = atk.dur
	local prog = m.atk_progress/dur
	local rx,ry=atk.rad,0

	-- start at facing angle
	local f_ang=atan2(m.fx,m.fy) -- facing

	-- get angle between start/end
	ang = f_ang+atk.ang1+(atk.ang2-atk.ang1)*prog
	m.ax,m.ay = rotate2d(rx,ry,ang)
	local overlaps = get_overlaps(m.x+m.ax,m.y+m.ay)
	--add(overlaps, get_overlaps(m.x+m.ax/2,m.y+m.ay/2))
	for omob in all(overlaps) do
		if (omob != m) then
			do_damage(m,atk,omob)
		end
	end
	
	-- update attack progress
	m.atk_progress += dt
	if m.atk_progress>dur+atk.coold then
		m_cur_atk = nil
		m.attacking = false
		m.atk_progress=0
		m.combo_index=1
	end
end

function draw_attack(m)
	if m.cur_atk and m.attacking and m.atk_progress<=m.cur_atk.dur then
		line(m.x,m.y,m.x+m.ax,m.y+m.ay,7)
	end
end

-----------------------------------------------------------------------------------------------------------------------------

-->8
-- util
function mag2d(_x,_y)
	return sqrt(_x*_x+_y*_y)
end

function dist2d(x1,y1,x2,y2)
	local dx,dy=x2-x1,y2-y1
	return mag2d(dx,dy)
end

function norm2d(_x,_y)
	local mag = mag2d(_x,_y)
	if (mag<=0) return 0,0
	return _x/mag, _y/mag
end

function toangle(dx,dy)
	return atan2(dx,dy)
end

function dot2d(x1,y1,x2,y2)
	return atan2(x1*y2-x2*y1,x1*y1+x2*y2)
end

function rotate2d(x1,y1,rot)
	sn = sin(rot)
	cs = cos(rot)
	x2 = x1 * cs - y1 * sn
	y2 = x1 * sn - y1 * cs
	return x2,y2
end

-- t from 0 to 1
function lerp(_a,_b,_t)
	return _a+(_b-_a)*_t
end

function overlap_circles(x1,y1,r1,x2,y2,r2)
	local dist=dist2d(x1,y1,x2,y2)
	return dist < r1+r2
end

function get_overlaps(x,y)
	local overlaps = {}
	
	for m in all(mobs) do
		if overlap_circles(x,y,0,
			m.x,m.y,m.radius) then
			
			add(overlaps, m)
		end
	end
	
	return overlaps
end

-----------------------------------------------------------------------------------------------------------------------------

-->8
-- mobs

function mobdist(m1,m2)
	return dist2d(m1.x,m1.y,m2.x,m2.y)
end

function aware(m1, m2)
	local dist = mobdist(m1,m2)
	
	-- in hear radius?
	if dist < m1.ai.hear_radius then
		return true
	end
	
	-- in sight radius?
--	if dist < m1.ai.sight_radius then
--		local dx,dy = m2.x-m1.x,m2.y-m1.y
--		local dirx,diry=norm2d(dx,dy)
--		if dot2d(m1.fx,m1.fy,dirx,diry) < m1.ai.sight_cone then
--			return true
--		end
--	end
	return false
end

function getmovedir(m)
	local deltax = m.ai_destx-m.x
	local deltay = m.ai_desty-m.y

	return norm2d(deltax,deltay)
end

function moveto(m,x,y)
	m.ai_destx = x
	m.ai_desty = y
end

function face_move(m)
	-- compute facing
	m.fx,m.fy = getmovedir(m)
end

function find_flee_pos(m)
	local dx,dy=m.x-p.x,m.y-p.y
	local dirx,diry=norm2d(dx,dy)
	return m.x+dirx*10,m.y+diry*10
end

function ai_init(m)
	-- init params for this ai
	m.ai_destx=m.x
	m.ai_desty=m.y

	force_state(m,"idle")
end


function ai_idle_ent(m)
	play_anim(m, "idl")
end

function ai_idle_upd(m)
	if rnd(1)<0.2 then
		change_state(m,"wander")
	end
end

function ai_wander_ent(m)
	local ang = rnd(1)
	local movetox=m.x+sin(ang)*5
	local movetoy=m.y+cos(ang)*5
	m.v=m.mdata.vel
	printh("wdst("..movetox..","..movetoy..")")
	moveto(m,movetox,movetoy)
	play_anim(m, "wlk")
end

function ai_wander_upd(m)
	local dist = dist2d(m.x,m.y,
				m.ai_destx,m.ai_desty)
	face_move(m)
--	printh("wander dist:"..dist)
--	printh("mob("..m.x..","..m.y..")")
--	printh("dst("..m.ai_destx..","..m.ai_desty..")")
	if dist <= 1 then
		change_state(m,"idle")
	end
end

function ai_investig(m)
end

function ai_engage_ent(m)
	play_anim(m,"wlk")
	m.v=m.mdata.vel_fast
end

function ai_engage_upd(m)
	moveto(m,p.x,p.y)
	local destx,desty = getmovedir(m)
	destx = -destx * 4 + p.x
	desty = -desty * 4 + p.y
	moveto(m,destx,desty)
	face_move(m)
	if dist2d(m.x,m.y,destx,desty) < 4	 then
		change_state(m,"attack")
	end
end

function ai_attack_ent(m)
	sfx(m.mdata.attack_sound)
	m.telegraph_timer = 0.35
end

function ai_attack_upd(m)
	printh(m.telegraph_timer)
	if m.telegraph_timer > 0 then
		m.telegraph_timer -= m.ai.ai_uprate
		if m.telegraph_timer <= 0 then
			do_attack(m,1)
			play_anim(m,"atk")
		end
	else
		if not m.attacking then
			change_state(m,"fleeing")
			printh("flee")
		end
	end
end

function ai_alerted_ent(m)
	play_anim(m,"wlk")
	m.ai_alerted=true
	add(floating_text,
				{txt="!",x=m.x,y=m.y,t=10,c=8})
	if rnd(1)<0.0 then
		change_state(m,"fleeing")
	else
		m.ai_aggroed = true
		change_state(m,"engage")
	end
end

function ai_alerted_upd(m)
end

function ai_fleeing_ent(m)
	local fx,fy = find_flee_pos(m)
	moveto(m, fx, fy)
	m.v=m.mdata.vel_fast
	play_anim(m,"wlk")
end

function ai_fleeing_upd(m)
	face_move(m)
	if not aware(m,p) then
		m.ai_alerted = false
		if (m.ai_aggroed) then
			change_state(m,"engage")
		else
			change_state(m,"idle")
		end
		return
	else
		local fx,fy = find_flee_pos(m)
		moveto(m, fx, fy)
	end
end

function ai_dead_ent(m)
	play_anim(m,"ded")
	m.v=0
	m.vx,m.vy=0,0
	m.ai_destx,m.ai_desty=m.x,m.y
	m.attacking=false
	m.ai_nextup = -1
end

function change_state(m,state)
--	printh(trace("cs:"..state))
	printh("cs:"..state)
	local newstate = ai_states[state]
	m.ai_nextstate = newstate
	m.ai_nextstatename = state
end

function force_state(m,state)
	printh("fs:"..state)
	local newstate = ai_states[state]
	local oldstate = m.ai_curstate

	-- exit old state
	if (oldstate and oldstate.ext) oldstate.ext(m)

	m.ai_curstate = newstate
	m.ai_curstatename = state
	
	local ent = m.ai_curstate.ent
	if (ent) ent(m)
end

function update_mob(m)
	if m.health > 0 then
		if m.ai then
			if aware(m,p) and not m.ai_alerted and not m.ai_aggroed then
				force_state(m,"alerted")
			end
		
			-- if it's time, update state
			if m.ai_nextup >=0 and
						gt>=m.ai_nextup	then
			 local cur = m.ai_curstate;
				if (cur and cur.upd) cur.upd(m)
				if(m.ai_nextstate != cur) then
					-- exit old state
					if (cur and cur.ext) cur.ext(m)

					local new=m.ai_nextstate
					m.ai_curstate=new
					-- enter new state
					if (new and new.ent) m.ai_curstate.ent(m)
					m.ai_curstatename = m.ai_nextstatename
					m.ai_nextup=gt
				else
					m.ai_nextup=gt+m.ai.ai_uprate + rnd(0.2)
				end
			end
			
			if dist2d(m.x,m.y,
						m.ai_destx,m.ai_desty) >= 1.0 then
						
				local dirx,diry=getmovedir(m)
				m.vx+=dirx*m.v*dt
				m.vy+=diry*m.v*dt
			end
		end
		-- compute new position
		m.x+=m.vx
		m.y+=m.vy
		
		-- decay velocity
		m.vx *= m.vd
		m.vy *= m.vd
	end
	
	update_animation(m)
	update_attack(m)
end


-- create one
function new_mob(m_id)
	local _mdata=mob_data[m_id]
	local m = {
		mdata=_mdata,
		x=0, -- pos
		y=0,
		vx=0, -- velocity
		vy=0,
		v=_mdata.vel, -- max vel
		vd=_mdata.v_decay, -- vel decay
		fx=1, -- facing
		fy=0,
		radius=4,
		
		-- anims
		animframe = 1,
		curanim = {},
		animset = _mdata.animset,
		anim = _mdata.animset[1],
		animname="",
		flash_frames = 0, -- for timed flashing
		flash_color = 0,
		animnext=gt,
		telegraph_timer = 0,
		
		-- combat
		attacking = false,
		attacks = _mdata.attacks,
		atk_progress = 0,
		cur_atk = nil,
		ax=1,ay=0, -- attack x,y
		hitting = false,
		combo_index=1,
		damage=1,
		health=_mdata.health_max,
		hit_react=0,
		stamina = _mdata.stamina_max,
		
		-- ai
		ai=_mdata.ai,
		ai_curstate = nil,
		ai_curstatename="",
		ai_nextstate=nil,
		ai_nextstatename="",
		ai_nextup=gt,
		ai_destx=0, -- destination x,y
		ai_desty=0,
		ai_alerted=false,
		ai_aggroed=false,
	}

	ai_init(m)
	
	return m
end

function spawn_mob(index, x, y)
		local mm=new_mob(index)
		add(mobs,mm)
		mm.x,mm.y=rnd(128),rnd(128)
		mm.ai_destx=mm.x
		mm.ai_desty=mm.y
end



-- ai state table referring to
-- update functions
ai_states={
	init = {ent=ai_init_ent, upd=ai_init, ext=ai_init_ext},
	idle = {ent=ai_idle_ent, upd=ai_idle_upd, ext=ai_idle_ext},
	wander = {ent=ai_wander_ent, upd=ai_wander_upd, ext=ai_wander_ext},
	investig = {ent=ai_investig_ent, upd=investig_upd, ext=investig_ext},
	engage = {ent=ai_engage_ent, upd=ai_engage_upd, ext=ai_engage_ext},
	attack = {ent=ai_attack_ent, upd=ai_attack_upd, ext=ai_attack_ext},
	alerted = {ent=ai_alerted_ent, upd=ai_alerted_upd, ext=ai_alerted_ext},
	fleeing = {ent=ai_fleeing_ent, upd=ai_fleeing_upd, ext=ai_fleeing_ext},
	dead = {ent=ai_dead_ent, upd=ai_dead_upd, ext=ai_dead_ext},
}

-----------------------------------------------------------------------------------------------------------------------------

-->8
--data

-- anims data

-- 1 - idle
-- 2 - walk
-- 3 - attack
-- 4 - hit react

anims=
{
	-- player
		{
			{name="idl", fps=4, frames={1,3,0},},
			{name="wlk", fps=4,	frames={1,2,3,4,0},},
			{name="atk", fps=2,	frames={1,2,3,4,0},},
			{name="hit", fps=2,	frames={1,2,3,4,0},},
			{name="ded", fps=2,	frames={1,2,3,4,0},},
		}, 
	-- pig
		{
			{name="idl", fps=4, frames={12,14,0},},
			{name="wlk", fps=4, frames={12,13,14,15,0},},
			{name="atk", fps=2, frames={12,13,-1},},
			{name="hit", fps=2, frames={12,14,-1},},
			{name="ded", fps=2, frames={13,15,-1},},
		},
	-- deer
		{
			{name="idl", fps=4, frames={28,30,0},},
			{name="wlk", fps=4, frames={28,29,30,31,0},},
			{name="atk", fps=2, frames={28,29,-1},},
			{name="hit", fps=2, frames={28,30,-1},},
			{name="ded", fps=2, frames={29,31,-1},},
		},
}

attack_data=
{
	{
		num=3,
		atks=
		{
			{
				dur=0.7,		  	-- atk duration
				forward=1, 	-- forward impulse
				coold=0.2,   -- cooldown
				rad=5,					  -- attack radius
				ang1=-0.20,  -- start angle
				ang2=0.20,   -- end angle
				comstart=0.7,-- percent of anim
				dam_mult=1.0,-- damage multiplier
				knockback=1  -- knockback impulse
			},
			{
				dur=0.7,
				forward=1, 	-- forward impulse
				coold=0.2,   -- cooldown
				rad=5,
				ang1=0.25,
				ang2=-0.25,
				comstart=0.7,
				dam_mult=1.0,
				knockback=2
			},
			{
				dur=0.7,
				forward=1, 	-- forward impulse
				coold=0.2,   -- cooldown
				rad=5,
				ang1=-0.35,
				ang2=0.35,
				comstart=0.7,
				dam_mult=1.0,
				knockback=3
			},
		},
	},
	{
		num=1,
		atks=
		{
			{
				dur=0.1,
				forward=2, 	-- forward impulse
				coold=0.2,   -- cooldown
				rad=2,
				ang1=-0.1,
				ang2=0.1,
				comstart=1.0,
				dam_mult=1.0,
				knockback=3
			},
		},
	}
}

ai_data = 
{
	{
		sight_radius = 40.0,
		sight_cone = 0.2,
		hear_radius = 30.0,
		ai_uprate=0.2,
		flee_dist = 20,
	}
}

--mob_data
mob_data=
{
	{
		--player
		ai=nil,
		vel=4,
		vel_fast=4,
		v_decay=0.8,
		health_max = 10,
		stamina_max = 20,
		animset = anims[1],
		attacks = attack_data[1],
		attack_sound = 1,
	},
	{
		-- boar
		ai=ai_data[1],
		vel=3,
		vel_fast=4,
		v_decay=0.8,
		health_max = 5,
		stamina_max = 20,
		animset=anims[2],
		attacks = attack_data[2],
		attack_sound = 1,
	},
	{
		-- deer
		ai=ai_data[1],
		vel=4,
		vel_fast=4.1,
		v_decay=0.8,
		health_max = 5,
		stamina_max = 20,
		animset=anims[3],
		attacks = attack_data[2],
		attack_sound = 1,
	}
}

-----------------------------------------------------------------------------------------------------------------------------

-->8
-- items

function spawn_loot(m)
end
  
__gfx__
00000000220022222200222222002222220022220000000000000000000000000000600000000000000060000000000022222222222222222222222222222222
00000000201102222011022220110222201102220000000000000000000000000006960000006000000696000000600022222222222222222222222222222222
00700700201c0222201c0222201c0222201c02220000000000000000000000000000600000069600000060000006960022202022222222222220202222222222
0007700020f40f222ff4ff2220f40f222ff4ff220000000000000000000000000006060000006000000606000000600020040402222020222204040222202022
000770002f41f222204102222f41f2222041022200000000000000000000000000606060006606000060606000660600044444e000040402200444e000040402
00700700201402222014022220140222201402220000000000000000000000000006000000606060000600000060606004444402444444e004444402444444e0
00000000012210222012102201221022012102220000000000000000000000000060060000060600006006000006060040444022044444024444402204444002
00000000010010222010102201001022010102220000000000000000000000000060060000060060006006000006006020400402240040220400040220400402
0550000000000000000000000000000000000000000000000000000000000000000cc00000000000000cc0000000000022222222222222222222222222222222
0575000000000000000000000000000000000000000000000000000000000000000c9c00000cc000000c9c00000cc00022225022222222222222502222222222
057750000000000000000000000000000000000000000000000000000000000000ccc000000c9c0000ccc000000c9c0022220402222250222222040222225022
05677500000000000000000000000000000000000000000000000000000000000ccc4c0000ccc0000ccc4c0000ccc00022204502222224022220450222200402
05677755000000000000000000000000000000000000000000000000000000000c04c0c00c0c4c000c04c0c00c0c4c0040440440224445024044044040440502
0566777500000000000000000000000000000000000000000000000000000000044cc0c000c4cc00044cc0c000c4cc0024444022444444402444402224444440
056655550000000000000000000000000000000000000000000000000000000040c0c00004400c0040c0c00004400c0024022402240224022402240224022402
05550000000000000000000000000000000000000000000000000000000000000cc00cc040cc0cc00cc00cc040cc0cc024022402224040222402240220424022
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022222222222222222222222222222222
00000040000000000000000000000400000000000000000000000000000000000000000000000000000000000000000022424242222222222242424222222222
000044f400008000000000000000ff4004444440000000000000000000000000000000000000000000000000000000002224c422224242422224c40222424242
0044f444000898000444444400044ff40ffffff000000000000000000000000000000000000000000000000000000000244444022224c402222444402224c402
44f44400000999000040904004444440044654400000000000000000000000000000000000000000000000000000000022244040224444022242404022444440
044400040009a9000049a94044444450044444400000000000000000000000000000000000000000000000000000000022244022222440402224402224244022
40400000000565000040604004444000044444400000000000000000000000000000000000000000000000000000000022402402224040222240240222240402
00400000005050500045054000450000000000000000000000000000000000000000000000000000000000000000000022402402224024022240240222402402
00000000000000000000000000000444000000000066000000000000000000000000000000000000000000000000000022222222222222222222222222222222
00004000000000700000044000044006000000400000660000000000000000000000000000000000000000000000000022222222222222222222222222222222
00044400000007000000444000400060000004600000046000000000000000000000000000000000000000000000000022223322222222222222332222222222
00004440000040000000440004000600000046670000406000000000000000000000000000000000000000000000000022233632222233222223363222223322
00040400000400000004000004006000000400700004000600000000000000000000000000000000000000000000000022223330222336322222333022233632
00400000004000000040000040060000004000000040000600000000000000000000000000000000000000000000000022233302222333302223330222233330
04000000040000000400000040600000040000000400000000000000000000000000000000000000000000000000000022333302223333022233330222333302
00000000000000000000000046000000000000004000000000000000000000000000000000000000000000000000000023303030330303022330303023030302
333333333b3333333b333333343343434444444444444444230b3032024032322222222222222222000000000000000000000000000000000000000000000000
333333333333b3334343b4333344b443344444344454445434b34b40330343402222222222222222000000000000000000000000000000000000000000000000
3333333333b3333b43b3433b43b3443b44344544444444444243530326643623222b0222222b0222000000000000000000000000000000000000000000000000
33333333b333b333b343b343b444b34444444444443444443423535032346430223230b0223830b0000000000000000000000000000000000000000000000000
3333333333333333334334333434344344543444444544442b254530222653022b0b23022b8b8302000000000000000000000000000000000000000000000000
3333333333b333b334b433b343b434b3444444444444444422545502222760222232b3022238b802000000000000000000000000000000000000000000000000
3333333333333333343333433443443443445444454434542225402222265022230b3030238b8230000000000000000000000000000000000000000000000000
33333333b333b333b333b333b4334343444444344444444422245022222560222230230222302302000000000000000000000000000000000000000000000000
4444444444444444ccccccc44cccccccccccccccccccccccb3354034333760333b3550333b3555033b3333333b3333333b333333333333330000000000000000
44544454c4544454ccccc454445ccccccc6ccccc1c161dcc343450b33336503b3355550333354503355555503333b3333333b333333333330000000000000000
4444444cc4444444ccc4444444444ccccccccccccccccccc434540333b3560333355550b335545503555555033b3333b33b3333b335555330000000000000000
434444cccc444344cc444434444444cccccccc6cd1ccd1613b4444043306540335558550b3555550b3555503b333b333b335503335dd55530000000000000000
444544cccc454444cc454444434544cccccccccccccccccc443333433434333335585850335555503350350335555550335555035d5555550000000000000000
44444cccccc44444c44444444444444ccccccccc161d1dcc3433b33bb3333b333555855033555550335035033350350333555503555555510000000000000000
454cccccccccc454c54444544544445cc6cccccccccccccc33333343334333433555555033555550335035033350350333555503555555150000000000000000
4cccccccccccccc44444444444444444cccccccc61dcc1d1b3b33333333b3333b333b333b333b333b333b333b333b333b333b333355551500000000000000000
44444444444cc4444444c44444444444444c444444444444202222622e2222222222222200000000000000000000000000000000000000000000000000000000
44544454445c4454445cc45444544454445cc45444543454d50226dde08222226545654900000000000000000000000000000000000000000000000000000000
44dcc444444cc44444cc4444444444444444cc444444444455026d50280222225454545900000000000000000000000000000000000000000000000000000000
cccccc444444c444cc4444344444444443444ccc4444444c0022d022222222220000000000000000000000000000000000000000000000000000000000000000
cd454ccc4445c44444454444cc45444444454444444544cc22222222222222222222222200000000000000000000000000000000000000000000000000000000
444444444444c4444444444444cc44444444444444444cc422242e8022222222d6d66d6f00000000000000000000000000000000000000000000000000000000
45434454454c445445444454454c4454454444544544cc5424402880222222225d65d65f00000000000000000000000000000000000000000000000000000000
44444444444c444444444444444c4444444444444444c44440042660222222220000000000000000000000000000000000000000000000000000000000000000
__map__
5555555555555555545454545454545454545452434141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141410054
5555555554545454545454545454545454545443434141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141410054
5555545454545245455354545454545454545451434141414156414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141410054
5554545454524544444553545454545454545462434141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141410054
5454545452454444444444454443444444446144434141414141414141474141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414154
54545452454444434343444444444443444464444e4141414141414156414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414154
5452454444434242414243414344434242436562434341414141414141414141414141415641414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414154
5245444343424341414241424343414141416241414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414154
6563444341414241434343424241414141414141414141415641414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414154
6464634141414242434242424241414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414154
4344644241414142424242424241414141414141414141414141414156414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414154
4444656043414141414141414241414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414154
6060624141414141434141414241414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414154
41434341414142434343414141414141414141414e4141564141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414154
4141414141414242424141414141414141414141414141414141414141414141414141564141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414154
4141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414154
4141414145414141414141414141414141414141414141414141414141414156414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414154
4141414541414141414141414141414141414545454141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414154
4141414541414141414141414156414141454141454141414141414141415741414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414154
4141454141414141414141564141414141414141414541414156564157414141564141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414154
4141414141414141415656415641414141414141414141415656415641564141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414154
4141454141414141414141414141454541414141414541414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414154
4141414141414141414145454141454141454541414541414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414154
4141454141414141414541414141454545414541414541414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414154
4141454141414141414541414156414141414541414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414154
4141414141414141414541414141414141414545454141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414154
4141414541414141414145454141414141454541414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414154
4141414145414141414141414145454141414541414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414154
4141414141414541414541414541414145454141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414154
4141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414154
4141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414154
5454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454
__sfx__
000100003f61726617030071b0001800717007140011300211007110021d6020e0070d0070b0000a0070900707007070070500705007040070400704007030070300502005010070100600007000071f00710000
00010000231502f1500d3500040703407007073eb073eb07007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001c65021650056500165000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003d05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003d05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003e05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003e05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003f05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003f05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003b05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003d05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003d05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003c05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003d05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003b05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003c05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003d05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003d05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003d05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003e05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003e05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003c05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003d05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003d05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
482000001302013020130201302013020130201302013020130201302013020130201302013020130201302013020130201302013020130201302013020130250000000000000000000000000000000000000000
c0200000070251c02515025110250e025150250e0251c02507025150250e02515025070251c02515025110250e025150250e0251c02507025150250e02515025070251c02515025110250e025150250e0251c025
48200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001572015720157221c7201c7201c7221c7201c7201c7201c720
482000000000000000000000000000000000000000000000000000000000000000001502015025180201802516020160201602515020150201504500000000000000000000000000000000000000000000000000
c020000007025150250e02515025070251c02515025110250e025150250e0251c02507025150250e02515025070251d02515025110250e025150250e0251c02507025150250e02515025070251c0251502511045
482000001c7401c7401c7401c7401c7421d7401d7401d7421f7401f7401f7422274022740227421c7401c7401c7421d7401d7401d7422174021740217402174021740217421a7401a7401a7401a7401a7401a740
482000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000015040150451804018045
c02000000e045150450e0451c04507045150450e04515045070451c04515045110450e045150450e0451c04507045150450e04515045070451c04515045110450e045150450e0451c04507045150450e04515045
482000001a7401a7401a7401a74221740217422674026740267422974029740297422274022740227402274022742217402274022740227422b7402b7402b7422474024740247422674026740267402674026740
482000001604016040160451504015040150450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0200000070451d04515045110450e045150450e0451c04507045150450e04515045070451c04515045110450e045150450e0451c04507045150450e04515045070451c04515045110450e045150450e0451c045
482000002674026740267421f74021740217402174021740217402174021740217421d7401d7401d7401d7421c7401c7401c7421a7401a7401a7421f7401f7401f7401f7401f7401f7401f7401f7401f7421c740
482000000000000000180401804018040180401804018040180401804500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000015040130401104013040
482000001c7401c7421d7401d7401d7422674026740267422174021740217402174021740217402174021740217402174021740217422174021740217421f7401f7401f7421a7401a7401a7421c7401c7401c742
4820000013040130401304500000000000000000000000000000000000000000000000000000000000000000000001a0401a04518040180401804018040180401804018040180451504015045180401804018040
002000000000000000000000000000000000001a7401a7421a7452174021742217422174221742217422174221742217451d7401d7421d7451f7401f7421f7451c7401c7421c7421c7421c7451d7401a7401a742
482000001804513040130401304013040130401304013040130401304013040130401304013040130401304013040130401304013040130401304013040130401304500000000000000000000000000000000000
002000001a7421a7421a7421a74500000000000000000000000000000000000000001a740187401a7402474024742247422474526740267452174021742217422174221742217422174221742217422174221742
482000000000000000000000000000000000000000000000000000000000000000000000015040150451804018045160401604016045150401504015045000000000000000000000000000000000000000000000
0020000021745227402974022740217401f7401f7451d7401c7401f740217402174221742217451f7401a7401a7421a7421a7421a7421a7450000000000000000000000000000001574016740187401a7401c740
482000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000150401504518040
002000001d7401f74021740227402274222742227451f7401f7452674026742267422674226742267452d7402b74029740287402874228742287452674028740297402b740297402874026740247402674026742
482000001804516040160401604515040150401504500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002000002674500000000001f74021740217422174221745000001a7401874018742187451a7401a7421a7421a7421a7421a74500000000000000000000000000000000000000000000000000000000000000000
4820000000000000000000018040180401804018040180401804018040180451504015045180401804515040150451304013040130451504015040150450e0400e0400e0400e0400e0400e045000000000000000
c020000007045150450e04515045070451c04515045110450e045150450e0451c04507045150450e04515045070451c04515045110450e045150450e0451c04507045150450e04515045070451c0451504511045
482000001504015040150401504015040150401504518040180451504015040150401504015040150401504015040150401504015040150450000000000000000000000000000000000000000150401504518040
482005001804515040150401504015045014000140001400014000140001400014000140001400014000140001400014000140001400014000140001400014000140001400014000140001400014000140001400
c02000000904510045100450e0450704515045070451004515045100450e0450704510045150450e04509045150450e0450e045070450e045150450e04507045150450e04509045150450e0451c045090450e045
48200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001574015740157401574015740157421c7401c7401c7401c740
c020000007045070450e045100451c0450e045150450e04513045150450e04507045100450e0450e0400e045150450e04515045100450e0450704507045150450e045100450e0450904511045110450e04507045
482000001c7401c7421a7401a7401a7401a7401a7401a7420000000000000000000000000000001c7401c7421a7401a7401a7401a74221740217402174021740217402174021740217421e7401e7401e7401e742
c020000015045070451104515045110450e0450704511045150450e04509045150450e0450e045070450e045150450e04507045150450e04509045150450e0451c045090450704509045090450e045100451c045
482000001f7401f7401f7401f7401f7421c7401c7401c7401c7401c7401c7401c74200000000001a7401a7421c7401c74221740217421f7401f7401f7401f7422474024740247402474222740217401f7401f740
c02000000e045150450e04513045150450e04507045100450e0450e0400e045150450e04515045100450e0450704507045150450e045100450e045000450704507045100450e045180450e045130450e04513045
482000001f7401f7401f7421d7401a74024740247402474024742227401f740217402174021740217402174021740217421f7401f7401f7401f7401f742167401874018740187401874018742187401a7401c740
c0200000130450e0450704500045070451804518045130450e045130450c0450e0450704507045130450e0450c0450e0453e73505045050450e0450c045160450c045110450c04511045110450c045050453e735
482000001c7401c7401c7401c742187401a7401f7401f7401f7421c7401c7401c7421d7401d7401d7401d7401d742187401a7401a7401a7401a742000001a7401c7401d7401d7401d7401d7401d7421c7401a740
c0200000050451604516045110450c045110450a0450c0450504505045110450c0450a0450c0450004507045070450e0450e045180450e045180450e04518045180450e045070450004507045180451804513045
0020000018950187401874018742167401a7401a7421c7401c7401c7401c74200000000000000000000157401a7401d7401d7401d7401d742187401a7401c7401f7401f7421d7401d7421c7401c7421a7401a740
__music__
00 18401819
00 1a1a1b1c
00 1d1d1e1f
00 20202122
00 2323241c
00 2525261f
00 27402819
00 29402a1c
00 2b402c1f
00 2d402e22
00 2f403031
00 3240321f
00 33403334
00 35354036
00 37374038
00 3939403a
00 3b3b403c
00 3d3d403e
00 3f3f4080
00 80804080
00 80404080
00 80404080
00 80404080
00 80404080
00 80404080
00 80404080
00 80404080
00 40404080
04 40404080

