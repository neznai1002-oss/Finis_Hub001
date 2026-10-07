-- Подпишитесь на канал Tg: @Finis_Paralich4
-- Finis Hub — full build with cinematic intro

local P  = game:GetService("Players")
local U  = game:GetService("UserInputService")
local T  = game:GetService("TweenService")
local R  = game:GetService("RunService")
local W  = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local LP = P.LocalPlayer
local Cam = W.CurrentCamera
local PG = (function()
	local ok, r = pcall(function() return gethui and gethui() end)
	if ok and r and typeof(r) == "Instance" then return r end
	return LP:WaitForChild("PlayerGui")
end)()

-- =========================================================
-- helpers
-- =========================================================
local function mk(c, p, par)
	local o = Instance.new(c)
	if p then for k, v in pairs(p) do o[k] = v end end
	if par then o.Parent = par end
	return o
end
local function crn(o, r) return mk("UICorner", {CornerRadius = UDim.new(0, r or 8)}, o) end
local function strk(o, c, t, tr) return mk("UIStroke", {Color = c or Color3.fromRGB(60,60,70), Thickness = t or 1, Transparency = tr or 0}, o) end
local function tw(o, info, props)
	if not o or not o.Parent then return end
	local i = info
	if type(info) == "number" then i = TweenInfo.new(info) end
	local ok, t = pcall(function() return T:Create(o, i, props) end)
	if ok and t then pcall(function() t:Play() end) end
	return t
end
local Cx = {}
local function bnd(sig, fn) local c = sig:Connect(fn); table.insert(Cx, c); return c end

-- =========================================================
-- palette
-- =========================================================
local C = {
	bg=Color3.fromRGB(10,10,13), cd=Color3.fromRGB(21,21,25), cdh=Color3.fromRGB(27,27,33),
	bd=Color3.fromRGB(34,34,40), tx=Color3.fromRGB(232,232,238), td=Color3.fromRGB(140,140,150),
	tm=Color3.fromRGB(90,90,100), ac=Color3.fromRGB(0,180,220), ach=Color3.fromRGB(0,230,255),
	acd=Color3.fromRGB(0,130,165), to=Color3.fromRGB(0,180,220), tf=Color3.fromRGB(55,55,65),
	tk=Color3.fromRGB(42,42,50), wt=Color3.fromRGB(255,255,255),
	pl=Color3.fromRGB(15,15,20), plh=Color3.fromRGB(24,24,30),
	ibg=Color3.fromRGB(3,3,6), pnk=Color3.fromRGB(255,120,220), blu=Color3.fromRGB(120,180,255),
}

-- =========================================================
-- state
-- =========================================================
local Lang = "en"
local LS = {
	en = {
		w="WELCOME", tb={AimBot="AimBot",Visuals="Visuals",Blatant="Blatant",Guns="Guns",Misc="Misc"},
		sec={pe="Player ESP",ex="ESP Extras",tt="ESP Text",trc="Bullet Tracer",tg="Triggerbot",ab="Aimbot",sa="Silent Aim",sp="Spin",ch="Character",mv="Movement",am="Ammo",it="Interface"},
		ui={on="Enabled",off="Disabled",scale="Menu Scale",fovc="FOV Circle",safe="Safe Mode",showtxt="Show Text",behind="Behind Walls",mode="Mode",size="Size",stroke="Stroke",
			color="Color",style="Style",fill="Fill",rainbow="Rainbow Speed",hs="Headshot %",visible="Require Visible",dur="Duration",delay="Delay",smooth="Smoothness",spd="Speed",
			inv="Infinite Ammo",nrl="No Reload",maxspd="Max Speed",ws="WalkSpeed",noclip="Noclip",air="Air Jump",fly="Fly",flyspd="Fly Speed",
			chams="Chams",outline="Outline",both="Both",none="None",name="Name",dist="Distance",coord="Coords"},
		sponsor = "finishub.cc  •  @Finis_Paralich4"
	},
	ru = {
		w="ДОБРО ПОЖАЛОВАТЬ", tb={AimBot="Аим",Visuals="Визуалы",Blatant="Читы",Guns="Оружие",Misc="Разное"},
		sec={pe="ESP Игроков",ex="Доп. ESP",tt="Текст ESP",trc="Трассер",tg="Триггербот",ab="Аимбот",sa="Тихий Прицел",sp="Спин",ch="Персонаж",mv="Движение",am="Патроны",it="Интерфейс"},
		ui={on="Включено",off="Выключено",scale="Размер меню",fovc="Круг FOV",safe="Безопасный режим",showtxt="Показывать текст",behind="Сквозь стены",mode="Режим",size="Размер",stroke="Обводка",
			color="Цвет",style="Стиль",fill="Заливка",rainbow="Скорость радуги",hs="Шанс в голову",visible="Только видимых",dur="Длительность",delay="Задержка",smooth="Плавность",spd="Скорость",
			inv="Беск. патроны",nrl="Без перезарядки",maxspd="Макс. скорость",ws="Скорость ходьбы",noclip="Сквозь стены",air="Воздушный прыжок",fly="Полёт",flyspd="Скорость полёта",
			chams="Заливка",outline="Обводка",both="Оба",none="Нет",name="Имя",dist="Дистанция",coord="Координаты"},
		sponsor = "finishub.cc  •  @Finis_Paralich4"
	}
}
local function TT(k) return (LS[Lang] and LS[Lang][k]) or LS.en[k] or k end
local function TS(cat, k) local p = LS[Lang] or LS.en; return (p[cat] and p[cat][k]) or k end

local CB = {
	trigger=false, tFov=140, tDel=0.35,
	aAim=false, afov=220, asm=10,
	silent=false, sFov=300, sHead=100, sVis=false, sDur=0.12,
	spin=false, spSpd=180,
	tracer=false,
	maxSpd=false, msVal=20,
	noclip=false, showFov=true, safe=true,
	air=false, fly=false, flySpd=60,
	ammo=false, noreload=false,
	esp=false, espStyle="Chams", espCol="Pink", espFill=0.15, espOut=1,
	espWall=true, espTxt=true, espTxtMode="Coords", espTxtCol=Color3.fromRGB(255,235,255),
	espTxtSz=12, espTxtStk=true, espHs=1.0, headDot=false, box=false, hp=false,
}

local ECols = {
	Pink={Color3.fromRGB(255,150,230),Color3.fromRGB(255,240,255)},
	Blue={Color3.fromRGB(120,180,255),Color3.fromRGB(220,240,255)},
	Red={Color3.fromRGB(255,70,70),Color3.fromRGB(255,220,220)},
	Green={Color3.fromRGB(90,220,130),Color3.fromRGB(220,255,220)},
	White={Color3.fromRGB(255,255,255),Color3.fromRGB(255,255,255)},
	Purple={Color3.fromRGB(180,120,255),Color3.fromRGB(240,220,255)},
	Yellow={Color3.fromRGB(255,220,90),Color3.fromRGB(255,250,200)},
	Cyan={Color3.fromRGB(0,220,240),Color3.fromRGB(200,250,255)},
	Rainbow={nil,nil},
}

-- =========================================================
-- GUI root
-- =========================================================
local G = mk("ScreenGui", {Name="FinisHub", ResetOnSpawn=false, IgnoreGuiInset=true,
	DisplayOrder=9999, ZIndexBehavior=Enum.ZIndexBehavior.Sibling}, PG)

local fovCircle = mk("Frame", {AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5),
	Size=UDim2.fromOffset(400,400), BackgroundTransparency=1, BorderSizePixel=0, Visible=false, ZIndex=2}, G)
crn(fovCircle, 5000)
local fovStroke = strk(fovCircle, C.wt, 1.5, 0.4)

-- =========================================================
-- =========================================================
-- INTRO
-- =========================================================
-- =========================================================
local OV = mk("Frame", {Size=UDim2.fromScale(1,1), BackgroundColor3=C.ibg,
	BackgroundTransparency=1, BorderSizePixel=0, ZIndex=5000}, G)
tw(OV, 0.5, {BackgroundTransparency=0})

-- Vignette
mk("Frame", {Size=UDim2.new(1,0,0.35,0), BackgroundColor3=Color3.fromRGB(0,0,0),
	BackgroundTransparency=0.55, BorderSizePixel=0, ZIndex=5001}, OV)
mk("Frame", {Size=UDim2.new(1,0,0.35,0), Position=UDim2.new(0,0,0.65,0),
	BackgroundColor3=Color3.fromRGB(0,0,0), BackgroundTransparency=0.55,
	BorderSizePixel=0, ZIndex=5001}, OV)

-- Grid
local GRID = mk("Frame", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, ZIndex=5002}, OV)
for i = 1, 18 do
	local cl = mk("Frame", {Size=UDim2.new(0,1,1,0), Position=UDim2.new((i-1)/17,0,0,0),
		BackgroundColor3=C.ach, BackgroundTransparency=1, BorderSizePixel=0, ZIndex=5002}, GRID)
	task.delay(0.1 + i*0.03, function()
		tw(cl, TweenInfo.new(0.9, Enum.EasingStyle.Sine), {BackgroundTransparency=0.88})
		task.delay(1.8, function()
			if cl.Parent then tw(cl, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {BackgroundTransparency=0.96}) end
		end)
	end)
end
for i = 1, 10 do
	local rw = mk("Frame", {Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,(i-1)/9,0),
		BackgroundColor3=C.ach, BackgroundTransparency=1, BorderSizePixel=0, ZIndex=5002}, GRID)
	task.delay(0.15 + i*0.04, function()
		tw(rw, TweenInfo.new(0.9, Enum.EasingStyle.Sine), {BackgroundTransparency=0.92})
		task.delay(1.8, function()
			if rw.Parent then tw(rw, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {BackgroundTransparency=0.97}) end
		end)
	end)
end

-- Rotating background rings (faint)
local BG_RINGS = mk("Frame", {AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5),
	Size=UDim2.fromOffset(0,0), BackgroundTransparency=1, ZIndex=5003}, OV)
for i = 1, 3 do
	local ring = mk("Frame", {AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5),
		Size=UDim2.fromOffset(300 + i*180, 300 + i*180), BackgroundTransparency=1,
		BorderSizePixel=0, ZIndex=5003}, BG_RINGS)
	crn(ring, 1000)
	local s = strk(ring, (i % 2 == 0) and C.pnk or C.ach, 1, 0.92)
	task.spawn(function()
		while OV and OV.Parent do
			tw(ring, TweenInfo.new(14 + i*4, Enum.EasingStyle.Linear),
				{Rotation = ring.Rotation + ((i % 2 == 0) and -360 or 360)})
			task.wait(14 + i*4)
			if ring.Parent then ring.Rotation = ring.Rotation % 360 else break end
		end
	end)
end

-- Star particles (deeper field)
for i = 1, 40 do
	local sz = math.random(2, 6)
	local col = ({C.ach, C.pnk, C.blu})[math.random(1,3)]
	local p = mk("Frame", {Size=UDim2.fromOffset(sz,sz), Position=UDim2.new(math.random()*0.9 + 0.05, 0, 1.1, 0),
		BackgroundColor3=col, BackgroundTransparency=0.6, BorderSizePixel=0, Rotation=45, ZIndex=5004}, OV)
	crn(p, 2)
	local dur = 4 + math.random()*4
	tw(p, TweenInfo.new(dur, Enum.EasingStyle.Linear),
		{Position=UDim2.new(0.05 + math.random()*0.85, 0, -0.15, 0), BackgroundTransparency=1})
	task.delay(dur + 0.2, function() if p.Parent then p:Destroy() end end)
end

-- Scanline sweep
local SCAN = mk("Frame", {Size=UDim2.new(1,0,0,2), Position=UDim2.new(0,0,-0.05,0),
	BackgroundColor3=C.ach, BackgroundTransparency=0.4, BorderSizePixel=0, ZIndex=5005}, OV)
task.spawn(function()
	for _ = 1, 7 do
		if not OV.Parent then break end
		SCAN.Position = UDim2.new(0,0,-0.05,0)
		tw(SCAN, TweenInfo.new(1.4, Enum.EasingStyle.Linear), {Position=UDim2.new(0,0,1.05,0)})
		task.wait(1.5)
	end
end)

-- shockwave helper
local function shockwave(pos, fromSz, toSz, dur, col, thick)
	local r = mk("Frame", {AnchorPoint=Vector2.new(.5,.5), Position=pos,
		Size=UDim2.fromOffset(fromSz,fromSz), BackgroundTransparency=1,
		BorderSizePixel=0, ZIndex=5030, Rotation=45}, OV)
	crn(r, 1000)
	strk(r, col or C.ach, thick or 2, 0.4)
	tw(r, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size=UDim2.fromOffset(toSz,toSz)})
	task.delay(dur + 0.05, function() if r.Parent then r:Destroy() end end)
	return r
end

-- particle burst helper
local function burst(pos, count, col)
	count = count or 6
	for _ = 1, count do
		local ang = math.random() * math.pi * 2
		local dist = 30 + math.random() * 80
		local sz = math.random(3, 7)
		local p = mk("Frame", {AnchorPoint=Vector2.new(.5,.5), Position=pos,
			Size=UDim2.fromOffset(sz,sz), BackgroundColor3=col or C.ach,
			BackgroundTransparency=0.3, BorderSizePixel=0, Rotation=45, ZIndex=5031}, OV)
		crn(p, 2)
		tw(p, TweenInfo.new(0.6 + math.random()*0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Position=UDim2.new(pos.X.Scale, pos.X.Offset + math.cos(ang)*dist,
				pos.Y.Scale, pos.Y.Offset + math.sin(ang)*dist),
			 BackgroundTransparency=1, Rotation=math.random(0,360)})
		task.delay(1.1, function() if p.Parent then p:Destroy() end end)
	end
end

-- WELCOME letters
local WH = mk("Frame", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, ZIndex=5010}, OV)
local WWORD = string.upper(TT("w"))
local WLetters = {}
local WSpc = 92
local WStart = -(#WWORD - 1) * WSpc / 2
for i = 1, #WWORD do
	local ch = string.sub(WWORD, i, i)
	local L = mk("TextLabel", {
		AnchorPoint = Vector2.new(.5,.5),
		Position = UDim2.new(0.5, WStart + (i-1)*WSpc, 0.5, 0),
		Size = UDim2.fromOffset(100, 100),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBlack, Text = ch, TextColor3 = C.wt, TextSize = 68,
		TextTransparency = 1, ZIndex = 5012,
	}, WH)
	local us = mk("UIScale", {Scale=0}, L)
	local glow = strk(L, C.ach, 1, 1)
	table.insert(WLetters, {lbl=L, us=us, glow=glow, i=i, xOff=WStart + (i-1)*WSpc})
end

-- FINIS HUB screen
local FH = mk("Frame", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1,
	ZIndex=5020, Visible=false}, OV)

local Ring = mk("Frame", {AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5),
	Size=UDim2.fromOffset(0,0), BackgroundTransparency=1, BorderSizePixel=0, ZIndex=5015}, FH)
crn(Ring, 1000)
local ringSt = strk(Ring, C.ach, 2, 0.4)
local Ring2 = mk("Frame", {AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5),
	Size=UDim2.fromOffset(0,0), BackgroundTransparency=1, BorderSizePixel=0, ZIndex=5014}, FH)
crn(Ring2, 1000)
local ring2St = strk(Ring2, C.pnk, 1, 0.5)

local Ring3 = mk("Frame", {AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5),
	Size=UDim2.fromOffset(0,0), BackgroundTransparency=1, BorderSizePixel=0, ZIndex=5013}, FH)
crn(Ring3, 1000)
local ring3St = strk(Ring3, C.blu, 1, 0.6)

local FWORD = "Finis Hub"
local FLetters = {}
local FSpc = 64
local FStart = -(#FWORD - 1) * FSpc / 2
for i = 1, #FWORD do
	local ch = string.sub(FWORD, i, i)
	local L = mk("TextLabel", {
		AnchorPoint = Vector2.new(.5,.5),
		Position = UDim2.new(0.5, FStart + (i-1)*FSpc, 0.5, 0),
		Size = UDim2.fromOffset(80, 100),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBlack, Text = ch, TextColor3 = C.wt, TextSize = 72,
		TextTransparency = 1, ZIndex = 5022,
	}, FH)
	local us = mk("UIScale", {Scale=0}, L)
	local glow = strk(L, C.ach, 1, 1)
	table.insert(FLetters, {lbl=L, us=us, glow=glow, i=i, xOff=FStart + (i-1)*FSpc})
end

local UL = mk("Frame", {AnchorPoint=Vector2.new(.5,.5), Position=UDim2.new(.5,0,.5,66),
	Size=UDim2.new(0,0,0,3), BackgroundColor3=C.ac, BorderSizePixel=0,
	BackgroundTransparency=0.2, ZIndex=5023}, FH)
crn(UL, 2)
mk("UIGradient", {Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
	ColorSequenceKeypoint.new(0.5, C.ach),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
})}, UL)

local SUB = mk("TextLabel", {AnchorPoint=Vector2.new(.5,.5), Position=UDim2.new(.5,0,.5,100),
	Size=UDim2.fromOffset(400,20), BackgroundTransparency=1, Font=Enum.Font.GothamMedium,
	Text="I N T E R N A L   B U I L D", TextColor3=C.td, TextSize=12,
	TextTransparency=1, ZIndex=5024}, FH)

local SPON = mk("TextLabel", {AnchorPoint=Vector2.new(.5,.5), Position=UDim2.new(.5,0,.5,132),
	Size=UDim2.fromOffset(400,20), BackgroundTransparency=1, Font=Enum.Font.GothamMedium,
	Text=LS.en.sponsor, TextColor3=C.ach, TextSize=13,
	TextTransparency=1, ZIndex=5024}, FH)

-- Progress bar (bottom)
local PROG_BAR = mk("Frame", {AnchorPoint=Vector2.new(.5,1), Position=UDim2.new(.5,0,1,-40),
	Size=UDim2.fromOffset(360, 4), BackgroundColor3=Color3.fromRGB(20,20,26),
	BackgroundTransparency=0.3, BorderSizePixel=0, ZIndex=5040}, OV)
crn(PROG_BAR, 100)
local PROG_FILL = mk("Frame", {Size=UDim2.new(0,0,1,0), BackgroundColor3=C.ach,
	BorderSizePixel=0, ZIndex=5041}, PROG_BAR)
crn(PROG_FILL, 100)
local PROG_LBL = mk("TextLabel", {AnchorPoint=Vector2.new(.5,0), Position=UDim2.new(.5,0,1,-16),
	Size=UDim2.fromOffset(360, 14), BackgroundTransparency=1, Font=Enum.Font.GothamMedium,
	Text="LOADING  0%", TextColor3=C.tm, TextSize=11, ZIndex=5041}, PROG_BAR)

-- SKIP button
local SKIP = mk("TextButton", {AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,-20,0,20),
	Size=UDim2.fromOffset(80,30), BackgroundColor3=Color3.fromRGB(20,20,26),
	BackgroundTransparency=0.4, BorderSizePixel=0, Text="SKIP",
	Font=Enum.Font.GothamBold, TextColor3=C.td, TextSize=11,
	AutoButtonColor=false, ZIndex=6000}, OV)
crn(SKIP, 15)
strk(SKIP, Color3.fromRGB(50,50,60), 1, 0.4)
bnd(SKIP.MouseEnter, function()
	tw(SKIP, 0.15, {BackgroundTransparency=0.1, TextColor3=C.tx})
end)
bnd(SKIP.MouseLeave, function()
	tw(SKIP, 0.15, {BackgroundTransparency=0.4, TextColor3=C.td})
end)

-- Audio-visual level bars (bottom left)
local BARS = mk("Frame", {AnchorPoint=Vector2.new(0,1), Position=UDim2.new(0,20,1,-20),
	Size=UDim2.fromOffset(60, 20), BackgroundTransparency=1, ZIndex=5050}, OV)
local BAR_ELS = {}
for i = 1, 5 do
	local b = mk("Frame", {AnchorPoint=Vector2.new(0,1), Position=UDim2.fromOffset((i-1)*10, 20),
		Size=UDim2.new(0, 5, 0, 3), BackgroundColor3=C.ach, BorderSizePixel=0, ZIndex=5051}, BARS)
	crn(b, 2)
	table.insert(BAR_ELS, b)
end
task.spawn(function()
	while OV and OV.Parent do
		for _, b in ipairs(BAR_ELS) do
			tw(b, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Size = UDim2.new(0, 5, 0, 3 + math.random() * 17)})
		end
		task.wait(0.14)
	end
end)

-- intro control
local DONE = false
local function finish()
	if DONE then return end
	DONE = true
	tw(UL, 0.4, {Size=UDim2.new(0,0,0,3)})
	for _, L in ipairs(FLetters) do
		tw(L.lbl, 0.5, {TextTransparency=1, Rotation=20})
		tw(L.us, 0.5, {Scale=1.4})
	end
	tw(SUB, 0.35, {TextTransparency=1})
	tw(SPON, 0.35, {TextTransparency=1})
	tw(PROG_BAR, 0.35, {BackgroundTransparency=1})
	tw(PROG_LBL, 0.35, {TextTransparency=1})
	tw(Ring, 0.5, {Size=UDim2.fromOffset(1200,1200)})
	tw(Ring2, 0.5, {Size=UDim2.fromOffset(1400,1400)})
	tw(Ring3, 0.5, {Size=UDim2.fromOffset(1600,1600)})
	task.wait(0.5)
	tw(OV, 0.7, {BackgroundTransparency=1})
	task.wait(0.75)
	if G and G.Parent then OV:Destroy() end
	if getgenv then getgenv().FinisIntroDone = true end
	if openMenu then openMenu() end
end

bnd(SKIP.MouseButton1Click, function() if not DONE then finish() end end)
bnd(U.InputBegan, function(input, gp)
	if gp then return end
	if (input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.Return) and not DONE then
		finish()
	end
end)

-- progress bar timeline (10s)
task.spawn(function()
	local total = 10.0
	local start = os.clock()
	while not DONE and OV and OV.Parent do
		local elapsed = os.clock() - start
		local pct = math.clamp(elapsed / total, 0, 1)
		PROG_FILL.Size = UDim2.new(pct, 0, 1, 0)
		PROG_LBL.Text = string.format("%s  %d%%", string.upper(Lang == "ru" and "ЗАГРУЗКА" or "LOADING"), math.floor(pct*100+0.5))
		if pct >= 1 then break end
		task.wait(0.08)
	end
	if not DONE then
		PROG_LBL.Text = string.upper(Lang == "ru" and "ГОТОВО" or "READY")
		tw(PROG_LBL, 0.2, {TextColor3=C.ach})
		task.wait(0.3)
		if PROG_LBL and PROG_LBL.Parent then tw(PROG_LBL, 0.3, {TextColor3=C.tm}) end
	end
end)

-- MAIN INTRO TIMELINE
task.spawn(function()
	-- WELCOME letters in
	task.wait(0.5)
	for i, L in ipairs(WLetters) do
		if DONE then return end
		task.spawn(function()
			L.lbl.Position = UDim2.new(0.5, L.xOff + math.random(-200,200), 0.5, -400 - math.random(0,200))
			L.lbl.Rotation = math.random(-720, 720)
			L.us.Scale = 0
			L.lbl.TextTransparency = 1
			task.wait((i-1) * 0.14)
			if DONE then return end

			tw(L.lbl, TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{Position=UDim2.new(0.5, L.xOff, 0.5, 0), Rotation=0})
			tw(L.us, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale=1})
			tw(L.lbl, 0.4, {TextTransparency=0, TextColor3=C.ach})
			task.wait(0.45)
			tw(L.lbl, 0.4, {TextColor3=C.wt})
			task.wait(0.35)
			if DONE then return end
			task.spawn(function()
				shockwave(UDim2.new(0.5, L.xOff, 0.5, 0), 8, 120, 0.5, C.blu)
			end)
			burst(UDim2.new(0.5, L.xOff, 0.5, 0), 5, C.ach)
		end)
	end

	-- Welcome pulse
	task.wait(2.1)
	if DONE then return end
	for _, L in ipairs(WLetters) do
		task.spawn(function()
			tw(L.us, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale=1.22})
			tw(L.lbl, 0.3, {TextColor3=C.ach})
			tw(L.glow, 0.3, {Transparency=0})
			task.wait(0.32)
			tw(L.us, 0.35, {Scale=1})
			tw(L.lbl, 0.4, {TextColor3=C.wt})
			tw(L.glow, 0.5, {Transparency=0.8})
		end)
	end

	-- Big shockwave
	task.wait(0.5)
	if DONE then return end
	shockwave(UDim2.fromScale(0.5,0.5), 30, 1100, 0.95, C.ach, 3)
	shockwave(UDim2.fromScale(0.5,0.5), 30, 900, 0.8, C.pnk, 2)
	shockwave(UDim2.fromScale(0.5,0.5), 30, 700, 0.7, C.blu, 2)

	-- Welcome scatter
	task.wait(0.4)
	if DONE then return end
	for i, L in ipairs(WLetters) do
		task.spawn(function()
			tw(L.lbl, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{Position=UDim2.new(0.5, (i-4)*180, 0.5, -280),
				 Rotation=math.random(-360,360), TextTransparency=1})
			tw(L.us, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale=0.3})
		end)
	end

	task.wait(0.6)
	if DONE then return end
	WH.Visible = false
	FH.Visible = true

	-- FINIS HUB letters
	for i, L in ipairs(FLetters) do
		if DONE then return end
		task.spawn(function()
			local side = (i % 2 == 0) and 1 or -1
			L.lbl.Position = UDim2.new(0.5 + side*0.85, L.xOff, 0.5 + (math.random()-0.5)*0.6, 0)
			L.lbl.Rotation = math.random(-540, 540) * side
			L.us.Scale = 0
			L.lbl.TextTransparency = 1
			task.wait((i-1) * 0.1)
			if DONE then return end
			tw(L.lbl, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{Position=UDim2.new(0.5, L.xOff, 0.5, 0), Rotation=0})
			tw(L.us, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale=1})
			tw(L.lbl, 0.4, {TextTransparency=0, TextColor3=C.ach})
			task.wait(0.4)
			tw(L.lbl, 0.35, {TextColor3=C.wt})
			if DONE then return end
			burst(UDim2.new(0.5, L.xOff, 0.5, 0), 4, C.pnk)
		end)
	end

	-- Rings
	task.wait(1.0)
	if DONE then return end
	tw(Ring, TweenInfo.new(0.9, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=UDim2.fromOffset(440,440)})
	tw(Ring2, TweenInfo.new(1.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=UDim2.fromOffset(520,520)})
	tw(Ring3, TweenInfo.new(1.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=UDim2.fromOffset(600,600)})

	task.spawn(function()
		while Ring and Ring.Parent and not DONE do
			tw(Ring, TweenInfo.new(6, Enum.EasingStyle.Linear), {Rotation=Ring.Rotation + 360})
			tw(Ring2, TweenInfo.new(9, Enum.EasingStyle.Linear), {Rotation=Ring2.Rotation - 360})
			tw(Ring3, TweenInfo.new(12, Enum.EasingStyle.Linear), {Rotation=Ring3.Rotation + 360})
			task.wait(6)
			if Ring then Ring.Rotation = Ring.Rotation % 360 end
			if Ring2 then Ring2.Rotation = Ring2.Rotation % 360 end
			if Ring3 then Ring3.Rotation = Ring3.Rotation % 360 end
		end
	end)
	task.spawn(function()
		while Ring and Ring.Parent and not DONE do
			tw(ringSt, TweenInfo.new(1.1, Enum.EasingStyle.Sine), {Transparency=0.05, Thickness=3})
			tw(ring2St, TweenInfo.new(1.1, Enum.EasingStyle.Sine), {Transparency=0.2, Thickness=2})
			tw(ring3St, TweenInfo.new(1.1, Enum.EasingStyle.Sine), {Transparency=0.3, Thickness=1.5})
			task.wait(1.1)
			if Ring and Ring.Parent and not DONE then
				tw(ringSt, TweenInfo.new(1.1, Enum.EasingStyle.Sine), {Transparency=0.55, Thickness=1.5})
				tw(ring2St, TweenInfo.new(1.1, Enum.EasingStyle.Sine), {Transparency=0.65, Thickness=1})
				tw(ring3St, TweenInfo.new(1.1, Enum.EasingStyle.Sine), {Transparency=0.75, Thickness=1})
			end
			task.wait(1.1)
		end
	end)

	task.wait(0.35)
	if DONE then return end
	tw(UL, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size=UDim2.new(0, 360, 0, 3)})
	task.wait(0.4)
	if DONE then return end
	tw(SUB, 0.5, {TextTransparency=0})
	task.wait(0.35)
	if DONE then return end
	tw(SPON, 0.6, {TextTransparency=0})

	-- Logo pulse
	task.wait(0.7)
	if DONE then return end
	for _, L in ipairs(FLetters) do
		task.spawn(function()
			tw(L.us, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale=1.18})
			tw(L.lbl, 0.4, {TextColor3=C.ach})
			tw(L.glow, 0.4, {Transparency=0})
			task.wait(0.42)
			tw(L.us, 0.4, {Scale=1})
			tw(L.lbl, 0.45, {TextColor3=C.wt})
			tw(L.glow, 0.5, {Transparency=0.8})
		end)
	end
	shockwave(UDim2.fromScale(0.5,0.5), 40, 800, 1.0, C.pnk, 2)

	-- Zoom out
	task.wait(1.2)
	if DONE then return end
	for _, L in ipairs(FLetters) do
		tw(L.lbl, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{TextTransparency=1, Rotation=25})
		tw(L.us, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale=1.8})
	end
	tw(SUB, 0.5, {TextTransparency=1})
	tw(SPON, 0.5, {TextTransparency=1})
	tw(UL, 0.5, {Size=UDim2.new(0,0,0,3)})
	tw(Ring, 0.7, {Size=UDim2.fromOffset(1200,1200)})
	tw(Ring2, 0.7, {Size=UDim2.fromOffset(1400,1400)})
	tw(Ring3, 0.7, {Size=UDim2.fromOffset(1600,1600)})

	task.wait(1.1)
	if DONE then return end
	finish()
end)

-- failsafe
task.delay(12, function() if not DONE then pcall(finish) end end)

-- =========================================================
-- =========================================================
-- MENU
-- =========================================================
-- =========================================================
local menuOpen = false
local main, mainScale
local function openMenu()
	if menuOpen then return end
	menuOpen = true
	if not main then return end
	main.Visible = true
	main.BackgroundTransparency = 1
	mainScale.Scale = 0.85
	tw(main, 0.22, {BackgroundTransparency=0})
	tw(mainScale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale=1})
	if staggerCards then staggerCards() end
end
local function closeMenu()
	if not menuOpen then return end
	menuOpen = false
	if not main then return end
	tw(main, 0.18, {BackgroundTransparency=1})
	tw(mainScale, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale=0.9})
	task.delay(0.22, function() if not menuOpen and main then main.Visible = false end end)
end
getgenv and (getgenv().FinisToggleMenu = function() if menuOpen then closeMenu() else openMenu() end end)

main = mk("Frame", {Name="Main", Size=UDim2.fromScale(.95,.9),
	Position=UDim2.new(.5,0,.5,0), AnchorPoint=Vector2.new(.5,.5),
	BackgroundColor3=C.bg, BorderSizePixel=0, Visible=false,
	BackgroundTransparency=1, ZIndex=900}, G)
crn(main, 12)
strk(main, C.bd, 1, 0.2)
mk("UISizeConstraint", {MinSize=Vector2.new(320,340), MaxSize=Vector2.new(720,520)}, main)
mainScale = mk("UIScale", {Scale=0.85}, main)

-- top accent
local ACC_LINE = mk("Frame", {Size=UDim2.new(0,0,0,2), Position=UDim2.new(.5,0,0,0),
	AnchorPoint=Vector2.new(.5,0), BackgroundColor3=C.ac, BackgroundTransparency=0.3,
	BorderSizePixel=0, ZIndex=950}, main)
crn(ACC_LINE, 1)
mk("UIGradient", {Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, C.acd),
	ColorSequenceKeypoint.new(0.5, C.ach),
	ColorSequenceKeypoint.new(1, C.acd),
})}, ACC_LINE)
task.spawn(function()
	while G and G.Parent and ACC_LINE and ACC_LINE.Parent do
		tw(ACC_LINE, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{Size=UDim2.new(0.78,0,0,2), BackgroundTransparency=0.55})
		task.wait(1.4)
		if not (G and G.Parent and ACC_LINE and ACC_LINE.Parent) then break end
		tw(ACC_LINE, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{Size=UDim2.new(0.42,0,0,2), BackgroundTransparency=0.2})
		task.wait(1.4)
	end
end)

local TOP_H = 52
local BOT_H = 58
local topBar = mk("Frame", {Size=UDim2.new(1,0,0,TOP_H), BackgroundTransparency=1, ZIndex=901}, main)

local logoDot = mk("Frame", {Size=UDim2.fromOffset(8,18), Position=UDim2.fromOffset(20,17),
	BackgroundColor3=C.ac, BorderSizePixel=0, ZIndex=902, Rotation=45}, topBar)
crn(logoDot, 2)
mk("TextLabel", {Size=UDim2.fromOffset(60,18), Position=UDim2.fromOffset(36,17),
	BackgroundTransparency=1, Font=Enum.Font.GothamBold, Text="Finis",
	TextColor3=C.tx, TextSize=15, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=902}, topBar)
mk("TextLabel", {Size=UDim2.fromOffset(90,18), Position=UDim2.fromOffset(74,17),
	BackgroundTransparency=1, Font=Enum.Font.GothamMedium, Text="Internal",
	TextColor3=C.td, TextSize=15, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=902}, topBar)

local ClB = mk("TextButton", {Size=UDim2.fromOffset(36,36), Position=UDim2.new(1,-44,0,8),
	BackgroundTransparency=1, Font=Enum.Font.GothamBold, Text="x",
	TextColor3=C.td, TextSize=18, AutoButtonColor=false, ZIndex=905}, topBar)
local ClS = mk("UIScale", {Scale=1}, ClB)
bnd(ClB.MouseEnter, function()
	tw(ClS, 0.15, {Scale=1.25}); tw(ClB, 0.15, {TextColor3=C.tx, Rotation=90})
end)
bnd(ClB.MouseLeave, function()
	tw(ClS, 0.15, {Scale=1}); tw(ClB, 0.15, {TextColor3=C.td, Rotation=0})
end)

local content = mk("Frame", {Size=UDim2.new(1,0,1,-(TOP_H+BOT_H)),
	Position=UDim2.fromOffset(0,TOP_H), BackgroundTransparency=1,
	ClipsDescendants=true, ZIndex=901}, main)
mk("UIPadding", {PaddingLeft=UDim.new(0,14), PaddingRight=UDim.new(0,14)}, content)

local botBar = mk("Frame", {Size=UDim2.new(1,0,0,BOT_H), Position=UDim2.new(0,0,1,-BOT_H),
	BackgroundTransparency=1, ZIndex=901}, main)

-- pages
local NAV = {"AimBot","Visuals","Blatant","Guns","Misc"}
local navSel = "Visuals"
local navB = {}
local navP = {}
local curP
for _, n in ipairs(NAV) do
	local pg = mk("ScrollingFrame", {Name=n, Size=UDim2.fromScale(1,1),
		BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=0,
		CanvasSize=UDim2.new(0,0,0,0), Visible=(n==navSel), ZIndex=901}, content)
	local ls = mk("UIListLayout", {Padding=UDim.new(0,10), SortOrder=Enum.SortOrder.LayoutOrder}, pg)
	local function rf() pg.CanvasSize = UDim2.new(0,0,0, ls.AbsoluteContentSize.Y + 20) end
	ls:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(rf)
	task.defer(rf)
	navP[n] = pg
	if n == navSel then curP = pg end
end

for i, n in ipairs(NAV) do
	local sel = (n == navSel)
	local wr = mk("TextButton", {Size=UDim2.new(1/#NAV, 0, 1, 0),
		Position=UDim2.fromScale((i-1)/#NAV, 0), BackgroundTransparency=1,
		Text="", AutoButtonColor=false, ZIndex=902}, botBar)
	local wr_sc = mk("UIScale", {Scale=1}, wr)
	local tl = mk("TextLabel", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1,
		Font=sel and Enum.Font.GothamBold or Enum.Font.GothamMedium,
		Text=TS("tb", n), TextColor3=sel and C.tx or C.td, TextSize=13, ZIndex=903}, wr)
	local un = mk("Frame", {Size=UDim2.new(sel and .45 or 0, 0, 0, 3),
		Position=UDim2.new(.5,0,1,-4), AnchorPoint=Vector2.new(.5,1),
		BackgroundColor3=C.ac, BorderSizePixel=0, ZIndex=904}, wr)
	crn(un, 2)
	navB[n] = {btn=wr, sc=wr_sc, lbl=tl, ul=un}
	bnd(wr.MouseEnter, function()
		if n ~= navSel then
			tw(tl, 0.15, {TextColor3=C.tx})
			tw(wr_sc, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Scale=1.06})
		end
	end)
	bnd(wr.MouseLeave, function()
		if n ~= navSel then
			tw(tl, 0.15, {TextColor3=C.td})
			tw(wr_sc, 0.18, {Scale=1})
		end
	end)
end

-- builders
local allCards = {}
local allSections = {}
local function addSection(p, ord, key)
	local h = mk("Frame", {Size=UDim2.new(1,0,0,26), BackgroundTransparency=1,
		LayoutOrder=ord, ZIndex=903}, p)
	local d = mk("Frame", {Size=UDim2.fromOffset(6,6), Position=UDim2.fromOffset(0,10),
		BackgroundColor3=C.ac, BorderSizePixel=0, Rotation=45, ZIndex=904}, h)
	crn(d, 1)
	local l = mk("TextLabel", {Size=UDim2.new(1,-18,1,0), Position=UDim2.fromOffset(16,0),
		BackgroundTransparency=1, Font=Enum.Font.GothamSemibold, Text=TS("sec", key),
		TextColor3=C.tx, TextSize=15, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=904}, h)
	table.insert(allSections, {lbl=l, key=key})
	task.spawn(function()
		while G and G.Parent and d and d.Parent do
			tw(d, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{BackgroundColor3=C.ach, Rotation=d.Rotation + 180})
			task.wait(1.4)
			if not (G and G.Parent and d and d.Parent) then break end
			tw(d, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{BackgroundColor3=C.ac, Rotation=d.Rotation + 180})
			task.wait(1.4)
		end
	end)
end

local function addCard(p, ord)
	local cd = mk("Frame", {Size=UDim2.new(1,0,0,0), BackgroundColor3=C.cd,
		BorderSizePixel=0, LayoutOrder=ord, AutomaticSize=Enum.AutomaticSize.Y, ZIndex=903}, p)
	crn(cd, 10)
	local s = strk(cd, C.bd, 1, 0.2)
	local sc = mk("UIScale", {Scale=1}, cd)
	mk("UIListLayout", {Padding=UDim.new(0,0), SortOrder=Enum.SortOrder.LayoutOrder}, cd)
	mk("UIPadding", {PaddingTop=UDim.new(0,4), PaddingBottom=UDim.new(0,4)}, cd)
	bnd(cd.MouseEnter, function()
		tw(cd, 0.18, {BackgroundColor3=C.cdh})
		tw(s, 0.18, {Color=C.ac, Transparency=0.6})
		tw(sc, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Scale=1.008})
	end)
	bnd(cd.MouseLeave, function()
		tw(cd, 0.18, {BackgroundColor3=C.cd})
		tw(s, 0.18, {Color=C.bd, Transparency=0.2})
		tw(sc, 0.2, {Scale=1})
	end)
	table.insert(allCards, cd)
	return cd
end

local function addToggle(p, ord, title, sub, def, cb)
	local r = mk("TextButton", {Size=UDim2.new(1,0,0,52), BackgroundTransparency=1,
		Text="", AutoButtonColor=false, LayoutOrder=ord, ZIndex=904}, p)
	mk("TextLabel", {Size=UDim2.new(1,-90,0,20),
		Position=UDim2.fromOffset(14, sub and 8 or 16), BackgroundTransparency=1,
		Font=Enum.Font.GothamSemibold, Text=title, TextColor3=C.tx, TextSize=14,
		TextXAlignment=Enum.TextXAlignment.Left, ZIndex=905}, r)
	if sub then
		mk("TextLabel", {Size=UDim2.new(1,-90,0,14), Position=UDim2.fromOffset(14,27),
			BackgroundTransparency=1, Font=Enum.Font.Gotham, Text=sub,
			TextColor3=C.td, TextSize=11, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=905}, r)
	end
	local trk = mk("Frame", {Size=UDim2.fromOffset(38,22), Position=UDim2.new(1,-50,.5,0),
		AnchorPoint=Vector2.new(0,.5), BackgroundColor3=def and C.to or C.tf,
		BorderSizePixel=0, ZIndex=905}, r)
	crn(trk, 100)
	local tsc = mk("UIScale", {Scale=1}, trk)
	strk(trk, C.to, 1, 0.5)
	local kn = mk("Frame", {Size=UDim2.fromOffset(18,18),
		Position=def and UDim2.new(1,-20,.5,-9) or UDim2.new(0,2,.5,-9),
		BackgroundColor3=C.wt, BorderSizePixel=0, ZIndex=906}, trk)
	crn(kn, 100)
	local st = {en = def or false}
	local function ap(en, sil)
		tw(trk, 0.18, {BackgroundColor3=en and C.to or C.tf})
		tw(kn, TweenInfo.new(0.22, Enum.EasingStyle.Back), {
			Position=en and UDim2.new(1,-20,.5,-9) or UDim2.new(0,2,.5,-9)})
		if not sil and cb then cb(en) end
	end
	bnd(r.MouseEnter, function()
		if not st.en then tw(trk, 0.16, {BackgroundColor3=Color3.fromRGB(65,65,75)}) end
	end)
	bnd(r.MouseLeave, function()
		if not st.en then tw(trk, 0.16, {BackgroundColor3=C.tf}) end
	end)
	bnd(r.MouseButton1Click, function()
		st.en = not st.en
		ap(st.en)
		tw(tsc, TweenInfo.new(0.1, Enum.EasingStyle.Back), {Scale=1.15})
		task.delay(0.1, function() tw(tsc, 0.2, {Scale=1}) end)
	end)
	if def and cb then cb(true) end
	return st
end

local function addSlider(p, ord, title, mn, mx, df, su, cb)
	local r = mk("Frame", {Size=UDim2.new(1,0,0,66), BackgroundTransparency=1,
		LayoutOrder=ord, ZIndex=904}, p)
	mk("TextLabel", {Size=UDim2.new(1,-90,0,18), Position=UDim2.fromOffset(14,12),
		BackgroundTransparency=1, Font=Enum.Font.GothamSemibold, Text=title,
		TextColor3=C.tx, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=905}, r)
	local vl = mk("TextLabel", {Size=UDim2.new(0,80,0,18), Position=UDim2.new(1,-94,0,12),
		BackgroundTransparency=1, Font=Enum.Font.Gotham,
		Text=tostring(df)..(su or ""), TextColor3=C.td, TextSize=13,
		TextXAlignment=Enum.TextXAlignment.Right, ZIndex=905}, r)
	local th = mk("Frame", {Size=UDim2.new(1,-28,0,18), Position=UDim2.fromOffset(14,38),
		BackgroundTransparency=1, ZIndex=905}, r)
	local tr2 = mk("Frame", {Size=UDim2.new(1,0,0,4), Position=UDim2.new(0,0,.5,-2),
		BackgroundColor3=C.tk, BorderSizePixel=0, ZIndex=905}, th)
	crn(tr2, 100)
	local fl = mk("Frame", {Size=UDim2.new(0,0,1,0), BackgroundColor3=C.ac,
		BorderSizePixel=0, ZIndex=906}, tr2)
	crn(fl, 100)
	local kn = mk("Frame", {Size=UDim2.fromOffset(14,14), AnchorPoint=Vector2.new(.5,.5),
		Position=UDim2.new(0,0,.5,0), BackgroundColor3=C.wt,
		BorderSizePixel=0, ZIndex=907}, tr2)
	crn(kn, 100)
	strk(kn, C.tx, 1, 0.2)
	local hit = mk("TextButton", {Size=UDim2.new(1,20,1,20), Position=UDim2.fromOffset(-10,-10),
		BackgroundTransparency=1, Text="", AutoButtonColor=false, ZIndex=908}, th)
	local isF = (mx <= 1.5 and df < 1.5)
	local val = df
	local drg = false
	local function sv(v, sil)
		val = math.clamp(v, mn, mx)
		local a = (val-mn)/(mx-mn)
		fl.Size = UDim2.new(a,0,1,0)
		kn.Position = UDim2.new(a,0,.5,0)
		vl.Text = isF and string.format("%.2f", val)..(su or "") or tostring(math.floor(val+.5))..(su or "")
		if not sil and cb then cb(val) end
	end
	local function fa(x)
		local rl = (x-hit.AbsolutePosition.X)/hit.AbsoluteSize.X
		rl = math.clamp(rl, 0, 1)
		sv(mn + rl*(mx-mn))
	end
	bnd(hit.InputBegan, function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			drg = true; fa(i.Position.X)
			tw(kn, TweenInfo.new(0.15, Enum.EasingStyle.Back), {Size=UDim2.fromOffset(18,18)})
			tw(fl, 0.15, {BackgroundColor3=C.ach})
		end
	end)
	bnd(U.InputChanged, function(i)
		if drg and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			fa(i.Position.X)
		end
	end)
	bnd(U.InputEnded, function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			if drg then
				drg = false
				tw(kn, 0.15, {Size=UDim2.fromOffset(14,14)})
				tw(fl, 0.2, {BackgroundColor3=C.ac})
			end
		end
	end)
	sv(df, true)
	if cb then cb(df) end
	return {set=sv, get=function() return val end}
end

local function addSelector(p, ord, title, opts, di, cb)
	local r = mk("TextButton", {Size=UDim2.new(1,0,0,52), BackgroundTransparency=1,
		Text="", AutoButtonColor=false, LayoutOrder=ord, ZIndex=904}, p)
	mk("TextLabel", {Size=UDim2.new(1,-140,0,20), Position=UDim2.fromOffset(14,16),
		BackgroundTransparency=1, Font=Enum.Font.GothamSemibold, Text=title,
		TextColor3=C.tx, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=905}, r)
	local bx = mk("Frame", {Size=UDim2.fromOffset(120,32), Position=UDim2.new(1,-134,.5,0),
		AnchorPoint=Vector2.new(0,.5), BackgroundColor3=Color3.fromRGB(30,30,36),
		BorderSizePixel=0, ZIndex=905}, r)
	crn(bx, 6)
	strk(bx, C.bd, 1, 0.2)
	local vl = mk("TextLabel", {Size=UDim2.new(1,-24,1,0), Position=UDim2.fromOffset(8,0),
		BackgroundTransparency=1, Font=Enum.Font.Gotham, Text=tostring(opts[di] or opts[1]),
		TextColor3=C.tx, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=906}, bx)
	local ar = mk("TextLabel", {Size=UDim2.fromOffset(20,20), Position=UDim2.new(1,-22,.5,-10),
		BackgroundTransparency=1, Font=Enum.Font.GothamBold, Text="v",
		TextColor3=C.td, TextSize=12, ZIndex=906}, bx)
	local i = di or 1
	local function ap(n, sil)
		i = ((n-1) % #opts) + 1
		vl.Text = tostring(opts[i])
		if not sil and cb then cb(opts[i], i) end
	end
	ap(i, true)
	bnd(r.MouseEnter, function()
		tw(bx, 0.16, {BackgroundColor3=Color3.fromRGB(38,38,45)})
		tw(ar, 0.16, {TextColor3=C.ac})
	end)
	bnd(r.MouseLeave, function()
		tw(bx, 0.16, {BackgroundColor3=Color3.fromRGB(30,30,36)})
		tw(ar, 0.16, {TextColor3=C.td})
	end)
	bnd(r.MouseButton1Click, function()
		ap(i+1)
		tw(bx, 0.08, {BackgroundColor3=C.acd})
		task.delay(0.08, function() tw(bx, 0.2, {BackgroundColor3=Color3.fromRGB(30,30,36)}) end)
		tw(ar, TweenInfo.new(0.18, Enum.EasingStyle.Back), {Rotation=180})
		task.delay(0.18, function() if ar.Parent then ar.Rotation = 0 end end)
	end)
	return {get=function() return opts[i] end, set=function(n) ap(n) end}
end

-- =========================================================
-- NOCLIP
-- =========================================================
local function forceNoclip()
	local ch = LP.Character
	if not ch or not ch.Parent then return end
	for _, d in ipairs(ch:GetDescendants()) do
		if d:IsA("BasePart") and d.CanCollide then d.CanCollide = false end
	end
end
local function restoreNoclip()
	local ch = LP.Character
	if not ch then return end
	for _, d in ipairs(ch:GetDescendants()) do
		if d:IsA("BasePart") then
			local n = d.Name
			if n == "HumanoidRootPart" then d.CanCollide = false
			elseif n == "Torso" or n == "UpperTorso" or n == "LowerTorso" or n == "Head" then d.CanCollide = true
			else d.CanCollide = false end
		end
	end
end
bnd(R.Stepped, function() if CB.noclip then pcall(forceNoclip) end end)
bnd(R.Heartbeat, function() if CB.noclip then pcall(forceNoclip) end end)
bnd(R.RenderStepped, function() if CB.noclip then pcall(forceNoclip) end end)
local function watchPart(p)
	if not p:IsA("BasePart") then return end
	bnd(p:GetPropertyChangedSignal("CanCollide"), function()
		if CB.noclip and p.CanCollide then p.CanCollide = false end
	end)
end
local function installWatchers(ch)
	if not ch then return end
	for _, d in ipairs(ch:GetDescendants()) do watchPart(d) end
	bnd(ch.DescendantAdded, watchPart)
end

-- =========================================================
-- TRACERS + cleanup
-- =========================================================
local tracerFolder = mk("Folder", {Name="FinisTracers"}, W)
tracerFolder:SetAttribute("FinisOwned", true)
local TRACER_NAMES = {"tracer","tracers","bullettracer","bullettrail","bulletline","shotline","shotray","raybeam","hitline","firingline"}
local KEEP = {Trail=true, Beam=true, Laser=true, Smoke=true, Fire=true}
local function isForeign(x)
	if not x then return false end
	if not (x:IsA("BasePart") or x:IsA("Folder") or x:IsA("Model")) then return false end
	if KEEP[x.Name] then return false end
	local n = x.Name:lower()
	for _, p in ipairs(TRACER_NAMES) do if n:find(p, 1, true) then return true end end
	return false
end
local function isOurs(x)
	if not tracerFolder then return false end
	local c = x
	while c and c.Parent do
		if c.Parent == tracerFolder or c == tracerFolder then return true end
		c = c.Parent
	end
	return false
end
bnd(W.DescendantAdded, function(inst)
	if isOurs(inst) then return end
	if inst.Parent == W and isForeign(inst) then pcall(function() inst:Destroy() end); return end
	local pr = inst.Parent
	if pr and pr.Parent == W and isForeign(pr) and not isOurs(pr) then pcall(function() pr:Destroy() end) end
end)

local lastT = 0
local function getMuzzle()
	local ch = LP.Character
	if not ch then return nil end
	local t = ch:FindFirstChildOfClass("Tool")
	if t then
		local h = t:FindFirstChild("Handle")
		if h then
			local m = h:FindFirstChild("Muzzle") or h:FindFirstChild("MuzzleAttachment") or h:FindFirstChild("Barrel")
			if m then
				if m:IsA("BasePart") then return m.Position end
				if m:IsA("Attachment") then return m.WorldPosition end
			end
			return h.Position
		end
	end
	local hd = ch:FindFirstChild("Head")
	return hd and hd.Position or nil
end
local function drawTracer(f, to)
	if not CB.tracer or not f or not to then return end
	if os.clock() - lastT < 0.05 then return end
	lastT = os.clock()
	local dist = (to - f).Magnitude
	if dist < 1.5 then return end
	local p = mk("Part", {Anchored=true, CanCollide=false, CanQuery=false, CanTouch=false,
		CastShadow=false, Material=Enum.Material.Neon, Color=Color3.fromRGB(255,245,120),
		Size=Vector3.new(0.12, 0.12, dist), CFrame=CFrame.new((f+to)*0.5, to),
		Transparency=0.1}, tracerFolder)
	tw(p, TweenInfo.new(0.4), {Transparency=1, Size=Vector3.new(0.05, 0.05, dist)})
	task.delay(0.45, function() if p.Parent then p:Destroy() end end)
end
local function onShot()
	if not CB.tracer then return end
	local f = getMuzzle()
	if not f then return end
	local mouse = LP:GetMouse()
	local tp = mouse.Hit.Position
	if tp then drawTracer(f, tp) end
end

-- =========================================================
-- ESP
-- =========================================================
local espCache = {}
local function isEnemy(p)
	if p == LP then return false end
	if p.Team and LP.Team and p.Team == LP.Team then return false end
	return true
end
local function espColor(t)
	if CB.espCol ~= "Rainbow" then
		local c = ECols[CB.espCol]
		if c and c[1] then return c[1], c[2] end
	end
	local h = (t * 0.15 * CB.espHs) % 1
	return Color3.fromHSV(h, 0.65, 1), Color3.fromHSV(h, 0.3, 1)
end
local function ensureE(ch)
	local e = espCache[ch]
	if e and e.hl and e.hl.Parent == ch then return e end
	if e and e.hl then pcall(function() e.hl:Destroy() end) end
	if e and e.hd then pcall(function() e.hd:Destroy() end) end
	if e and e.bx then pcall(function() e.bx:Destroy() end) end
	local hl = Instance.new("Highlight")
	hl.Name = "FinisESP"
	hl.FillTransparency = CB.espFill
	hl.OutlineTransparency = CB.espOut
	hl.DepthMode = CB.espWall and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
	hl.Adornee = ch
	hl.Parent = ch
	local hd = ch:FindFirstChild("Head")
	local txt, dot, bx
	if hd then
		txt = Instance.new("BillboardGui")
		txt.Name = "FinisESPText"
		txt.Size = UDim2.new(0, 220, 0, 22)
		txt.StudsOffset = Vector3.new(0, 2.8, 0)
		txt.AlwaysOnTop = true; txt.LightInfluence = 0; txt.Parent = hd
		local l = Instance.new("TextLabel")
		l.Name = "L"; l.Size = UDim2.fromScale(1,1); l.BackgroundTransparency = 1
		l.Font = Enum.Font.Code; l.TextSize = CB.espTxtSz; l.TextColor3 = CB.espTxtCol
		l.TextStrokeTransparency = CB.espTxtStk and 0 or 1
		l.TextStrokeColor3 = Color3.fromRGB(0,0,0); l.Text = ""; l.Parent = txt

		dot = Instance.new("BillboardGui")
		dot.Name = "FinisHeadDot"; dot.Size = UDim2.new(0,14,0,14)
		dot.AlwaysOnTop = true; dot.Parent = hd
		local dfr = Instance.new("Frame")
		dfr.Name = "Dot"; dfr.Size = UDim2.fromScale(1,1)
		dfr.BackgroundColor3 = Color3.fromRGB(255,150,230)
		dfr.BorderSizePixel = 0; dfr.Parent = dot
		local dc = Instance.new("UICorner"); dc.CornerRadius = UDim.new(1,0); dc.Parent = dfr
		local ds = Instance.new("UIStroke"); ds.Color = Color3.fromRGB(255,255,255); ds.Thickness = 2; ds.Parent = dfr

		bx = Instance.new("BillboardGui")
		bx.Name = "FinisBox"; bx.Size = UDim2.new(0,70,0,100)
		bx.AlwaysOnTop = true; bx.Adornee = ch:FindFirstChild("HumanoidRootPart") or hd
		bx.Parent = ch
		local hol = Instance.new("Frame")
		hol.Name = "Holder"; hol.Size = UDim2.fromScale(1,1)
		hol.BackgroundTransparency = 1; hol.Parent = bx
		local function edge(n, sz, pos)
			local x = Instance.new("Frame")
			x.Name = n; x.Size = sz; x.Position = pos
			x.BackgroundColor3 = Color3.fromRGB(255,150,230)
			x.BorderSizePixel = 0; x.Parent = hol
		end
		edge("Top",    UDim2.new(1,0,0,1.5), UDim2.new(0,0,0,0))
		edge("Bottom", UDim2.new(1,0,0,1.5), UDim2.new(0,0,1,-1.5))
		edge("Left",   UDim2.new(0,1.5,1,0), UDim2.new(0,0,0,0))
		edge("Right",  UDim2.new(0,1.5,1,0), UDim2.new(1,-1.5,0,0))
		local hpbg = Instance.new("Frame")
		hpbg.Name = "HPBg"; hpbg.Size = UDim2.new(0,3,1,0)
		hpbg.Position = UDim2.new(0,-6,0,0)
		hpbg.BackgroundColor3 = Color3.fromRGB(20,20,20)
		hpbg.BorderSizePixel = 0; hpbg.Parent = hol
		local hpf = Instance.new("Frame")
		hpf.Name = "HPFill"; hpf.Size = UDim2.fromScale(1,1)
		hpf.Position = UDim2.new(0,0,1,0); hpf.AnchorPoint = Vector2.new(0,1)
		hpf.BackgroundColor3 = Color3.fromRGB(0,220,100)
		hpf.BorderSizePixel = 0; hpf.Parent = hpbg
	end
	local newE = {hl=hl, txt=txt, hd=dot, bx=bx}
	espCache[ch] = newE
	return newE
end
local function ftext(p, ch)
	local m = CB.espTxtMode
	if m == "None" then return "" end
	if m == "Name" then return p.Name end
	if m == "Distance" then
		local mch = LP.Character
		local mr = mch and mch:FindFirstChild("HumanoidRootPart")
		local tr = ch:FindFirstChild("HumanoidRootPart")
		if mr and tr then return tostring(math.floor((mr.Position - tr.Position).Magnitude)).." st" end
		return ""
	end
	if m == "Coords" then
		local r = ch:FindFirstChild("HumanoidRootPart")
		if r then return string.format("%d, %d", math.floor(r.Position.X), math.floor(r.Position.Z)) end
		return ""
	end
	return ""
end
task.spawn(function()
	local t = 0
	while G and G.Parent do
		t = t + 0.03
		local fc, oc = espColor(t)
		if not CB.esp then
			for _, e in pairs(espCache) do
				if e.hl then e.hl.Enabled = false end
				if e.txt then e.txt.Enabled = false end
				if e.hd then e.hd.Enabled = false end
				if e.bx then e.bx.Enabled = false end
			end
		else
			for _, p in ipairs(P:GetPlayers()) do
				if p ~= LP and isEnemy(p) then
					local ch = p.Character
					if ch then
						local h = ch:FindFirstChildOfClass("Humanoid")
						if h and h.Health > 0 then
							pcall(function()
								local e = ensureE(ch)
								if e.hl then
									e.hl.Enabled = true
									if CB.espStyle == "Outline" then
										e.hl.FillTransparency = 1; e.hl.OutlineTransparency = 0
									elseif CB.espStyle == "Chams" then
										e.hl.FillTransparency = CB.espFill
										e.hl.OutlineTransparency = CB.espOut
									else
										e.hl.FillTransparency = CB.espFill
										e.hl.OutlineTransparency = 0
									end
									e.hl.FillColor = fc
									e.hl.OutlineColor = oc
									e.hl.DepthMode = CB.espWall and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
								end
								if e.txt and e.txt.Parent then
									e.txt.Enabled = CB.espTxt
									local l = e.txt:FindFirstChild("L")
									if l then
										l.Text = ftext(p, ch)
										l.TextColor3 = CB.espTxtCol
										l.TextSize = CB.espTxtSz
										l.TextStrokeTransparency = CB.espTxtStk and 0 or 1
									end
								end
								if e.hd and e.hd.Parent then
									e.hd.Enabled = CB.headDot
									local d = e.hd:FindFirstChild("Dot")
									if d then
										d.BackgroundColor3 = fc
										local s = d:FindFirstChildOfClass("UIStroke")
										if s then s.Color = oc end
									end
								end
								if e.bx and e.bx.Parent then
									e.bx.Enabled = CB.box
									local hol = e.bx:FindFirstChild("Holder")
									if hol then
										for _, edge in ipairs(hol:GetChildren()) do
											if edge:IsA("Frame") and edge.Name ~= "HPBg" then
												edge.BackgroundColor3 = fc
											end
										end
										local hpbg = hol:FindFirstChild("HPBg")
										if hpbg then
											hpbg.Visible = CB.hp
											local hpf = hpbg:FindFirstChild("HPFill")
											if hpf then
												local ratio = math.clamp(h.Health / math.max(h.MaxHealth,1), 0, 1)
												hpf.Size = UDim2.new(1,0,ratio,0)
												local col = Color3.fromRGB(0,220,100)
												if ratio < 0.3 then col = Color3.fromRGB(240,40,40)
												elseif ratio < 0.6 then col = Color3.fromRGB(255,190,40) end
												hpf.BackgroundColor3 = col
											end
										end
									end
								end
							end)
						end
					end
				end
			end
		end
		task.wait(0.03)
	end
end)

-- =========================================================
-- FLY / AIR / SILENT / AMMO
-- =========================================================
local FS = {bv=nil, bg=nil, up=false, dn=false}
local function startFly()
	local ch = LP.Character
	local hr = ch and ch:FindFirstChild("HumanoidRootPart")
	local hm = ch and ch:FindFirstChildOfClass("Humanoid")
	if not hr or not hm or FS.bv then return end
	local bv = Instance.new("BodyVelocity")
	bv.Name = "FinisFlyBV"; bv.MaxForce = Vector3.new(1e9,1e9,1e9)
	bv.P = 1250; bv.Velocity = Vector3.new(0,0,0); bv.Parent = hr
	local bg = Instance.new("BodyGyro")
	bg.Name = "FinisFlyBG"; bg.MaxTorque = Vector3.new(1e9,1e9,1e9)
	bg.P = 3000; bg.D = 100; bg.CFrame = hr.CFrame; bg.Parent = hr
	hm.PlatformStand = true
	FS.bv, FS.bg = bv, bg
end
local function stopFly()
	if FS.bv then FS.bv:Destroy() FS.bv = nil end
	if FS.bg then FS.bg:Destroy() FS.bg = nil end
	FS.up, FS.dn = false, false
	local ch = LP.Character
	local hm = ch and ch:FindFirstChildOfClass("Humanoid")
	if hm then hm.PlatformStand = false end
end
bnd(R.Heartbeat, function()
	if not CB.fly then
		if FS.bv then stopFly() end
		return
	end
	if not FS.bv then startFly() end
	local ch = LP.Character
	local hm = ch and ch:FindFirstChildOfClass("Humanoid")
	local rt = ch and ch:FindFirstChild("HumanoidRootPart")
	if not hm or not rt or not FS.bv then return end
	local cm = W.CurrentCamera
	local lk = cm.CFrame.LookVector
	local rg = cm.CFrame.RightVector
	local md = hm.MoveDirection
	local d = Vector3.new(0,0,0)
	if md.Magnitude > 0.01 then d = d + (lk*md.Z) + (rg*md.X) end
	if FS.up then d = d + Vector3.new(0,1,0) end
	if FS.dn then d = d - Vector3.new(0,1,0) end
	if d.Magnitude > 0.01 then d = d.Unit * CB.flySpd end
	FS.bv.Velocity = d
	FS.bg.CFrame = CFrame.new(rt.Position, rt.Position + lk)
end)
bnd(U.JumpRequest, function()
	if not CB.air then return end
	local ch = LP.Character
	if not ch then return end
	local h = ch:FindFirstChildOfClass("Humanoid")
	if not h then return end
	local st = h:GetState()
	if st == Enum.HumanoidStateType.Jumping or st == Enum.HumanoidStateType.Freefall then
		h:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- silent
local Snap = {cf=nil, at=0, act=false}
local function getSnapTarget()
	local vp = Cam.ViewportSize
	local cn = Vector2.new(vp.X*0.5, vp.Y*0.5)
	local best, bestScore = nil, math.huge
	for _, p in ipairs(P:GetPlayers()) do
		if isEnemy(p) then
			local ch = p.Character
			if ch then
				local hd = ch:FindFirstChild("Head")
				local rt = ch:FindFirstChild("HumanoidRootPart")
				local hm = ch:FindFirstChildOfClass("Humanoid")
				if hd and rt and hm and hm.Health > 0 then
					local sp, on = Cam:WorldToViewportPoint(hd.Position)
					if on and sp.Z > 0 then
						local d = (Vector2.new(sp.X, sp.Y) - cn).Magnitude
						if d <= CB.sFov and d < bestScore then
							bestScore = d
							best = {head=hd, root=rt, ch=ch, pl=p}
						end
					end
				end
			end
		end
	end
	return best
end
local function doSnap()
	if not CB.silent then return end
	local t = getSnapTarget()
	if not t then return end
	local part = (math.random(1,100) <= CB.sHead) and t.head or t.root
	local ch = LP.Character
	local hr = ch and ch:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	if not Snap.act then Snap.cf = hr.CFrame; Snap.act = true end
	local flat = Vector3.new(part.Position.X, hr.Position.Y, part.Position.Z)
	hr.CFrame = CFrame.lookAt(hr.Position, flat)
	Snap.at = os.clock() + CB.sDur
end
bnd(R.RenderStepped, function()
	if Snap.act and os.clock() >= Snap.at then
		local ch = LP.Character
		local hr = ch and ch:FindFirstChild("HumanoidRootPart")
		if hr and Snap.cf then hr.CFrame = Snap.cf end
		Snap.act = false; Snap.cf = nil
	end
end)

-- tools
local function hookTool(t)
	if not t:IsA("Tool") then return end
	if t:GetAttribute("FH") then return end
	t:SetAttribute("FH", true)
	bnd(t.Activated, function()
		pcall(doSnap)
		pcall(onShot)
	end)
end
local function installTools(ch)
	if not ch then return end
	for _, c in ipairs(ch:GetDescendants()) do
		if c:IsA("Tool") then hookTool(c) end
	end
	bnd(ch.ChildAdded, function(c)
		if c:IsA("Tool") then task.wait(0.05); hookTool(c) end
	end)
end
if LP.Character then installTools(LP.Character); installWatchers(LP.Character) end
LP.CharacterAdded:Connect(function(ch)
	task.wait(0.25)
	installTools(ch); installWatchers(ch)
end)

-- ammo
local AN = {"ammo","clip","mag","bullets","rounds"}
local RN = {"reload"}
task.spawn(function()
	while G and G.Parent do
		local ch = LP.Character
		if ch then
			for _, t in ipairs(ch:GetChildren()) do
				if t:IsA("Tool") then
					if CB.ammo then
						for k, v in pairs(t:GetAttributes()) do
							if typeof(v) == "number" then
								local l = k:lower()
								for _, n in ipairs(AN) do
									if l:find(n, 1, true) and v < 999 then
										pcall(function() t:SetAttribute(k, 999) end)
									end
								end
							end
						end
					end
					if CB.noreload then
						for k, v in pairs(t:GetAttributes()) do
							local l = k:lower()
							for _, n in ipairs(RN) do
								if l:find(n, 1, true) then
									if typeof(v) == "boolean" and v then
										pcall(function() t:SetAttribute(k, false) end)
									elseif typeof(v) == "number" and v > 0 then
										pcall(function() t:SetAttribute(k, 0) end)
									end
								end
							end
						end
					end
				end
			end
		end
		task.wait(0.12)
	end
end)

-- =========================================================
-- pill (right after intro, top-left)
-- =========================================================
local PH = mk("Frame", {Name="PillHUD", Size=UDim2.fromOffset(230,40),
	Position=UDim2.new(0,-260,0,12), BackgroundTransparency=1, ZIndex=1000}, G)
local PB = mk("TextButton", {Size=UDim2.fromScale(1,1), BackgroundColor3=C.pl,
	BorderSizePixel=0, Text="", AutoButtonColor=false, ZIndex=1000}, PH)
crn(PB, 10)
local pbS = strk(PB, Color3.fromRGB(35,35,45), 1, 0.1)
local PIcon = mk("Frame", {Size=UDim2.fromOffset(11,11), Position=UDim2.fromOffset(18,14),
	BackgroundColor3=C.ach, BorderSizePixel=0, Rotation=45, ZIndex=1002}, PB)
crn(PIcon, 2)
task.spawn(function()
	while G and G.Parent and PIcon and PIcon.Parent do
		tw(PIcon, TweenInfo.new(2.5, Enum.EasingStyle.Linear), {Rotation=PIcon.Rotation + 360})
		task.wait(2.5)
		if PIcon and PIcon.Parent then PIcon.Rotation = PIcon.Rotation % 360 else break end
	end
end)
mk("TextLabel", {Size=UDim2.fromOffset(60,20), Position=UDim2.fromOffset(42,10),
	BackgroundTransparency=1, Font=Enum.Font.GothamBold, Text="finis",
	TextColor3=C.tx, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=1002}, PB)
mk("TextLabel", {Size=UDim2.fromOffset(10,20), Position=UDim2.fromOffset(88,10),
	BackgroundTransparency=1, Font=Enum.Font.Gotham, Text="|", TextColor3=C.tm, TextSize=13, ZIndex=1002}, PB)
mk("TextLabel", {Size=UDim2.fromOffset(90,20), Position=UDim2.fromOffset(98,10),
	BackgroundTransparency=1, Font=Enum.Font.GothamMedium, Text="finishub.cc",
	TextColor3=C.td, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=1002}, PB)
mk("TextLabel", {Size=UDim2.fromOffset(10,20), Position=UDim2.fromOffset(184,10),
	BackgroundTransparency=1, Font=Enum.Font.Gotham, Text="|", TextColor3=C.tm, TextSize=13, ZIndex=1002}, PB)
mk("TextLabel", {Size=UDim2.fromOffset(60,20), Position=UDim2.fromOffset(194,10),
	BackgroundTransparency=1, Font=Enum.Font.GothamMedium, Text="internal",
	TextColor3=C.td, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=1002}, PB)

local pDrag, pMoved, pHold = nil, false, nil
local pSC = mk("UIScale", {Scale=1}, PH)
bnd(PB.InputBegan, function(x)
	if x.UserInputType == Enum.UserInputType.MouseButton1 or x.UserInputType == Enum.UserInputType.Touch then
		pDrag = {sp=x.Position, st=PH.Position}
		pMoved = false
		pHold = os.clock()
	end
end)
bnd(U.InputChanged, function(x)
	if not pDrag then return end
	if x.UserInputType == Enum.UserInputType.MouseMovement or x.UserInputType == Enum.UserInputType.Touch then
		local d = x.Position - pDrag.sp
		if math.abs(d.X) + math.abs(d.Y) > 12 then pMoved = true end
		if pMoved then
			PH.Position = UDim2.new(pDrag.st.X.Scale, pDrag.st.X.Offset+d.X, pDrag.st.Y.Scale, pDrag.st.Y.Offset+d.Y)
		end
	end
end)
bnd(U.InputEnded, function(x)
	if not pDrag then return end
	if x.UserInputType == Enum.UserInputType.MouseButton1 or x.UserInputType == Enum.UserInputType.Touch then
		local hold = pHold and (os.clock() - pHold) > 1.5
		local tap = not pMoved and not hold
		pDrag = nil; pHold = nil
		if tap and not DONE == false and not introActive then
			if not menuOpen then openMenu() else closeMenu() end
		end
	end
end)
bnd(PB.MouseEnter, function()
	tw(PB, 0.18, {BackgroundColor3=C.plh})
	tw(pSC, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Scale=1.05})
end)
bnd(PB.MouseLeave, function()
	tw(PB, 0.18, {BackgroundColor3=C.pl})
	tw(pSC, 0.18, {Scale=1})
end)
local introActive = true

-- =========================================================
-- PAGES
-- =========================================================
do
	local p = navP.Visuals
	addSection(p, 1, "pe")
	local cd = addCard(p, 2)
	addToggle(cd, 1, "Enable ESP", "Highlight enemies", false, function(o) CB.esp = o end)
	addToggle(cd, 2, "Behind Walls", "See through obstacles", true, function(o) CB.espWall = o end)
	local cl = {}; for k in pairs(ECols) do table.insert(cl, k) end; table.sort(cl)
	addSelector(cd, 3, "Color", cl, 1, function(v) CB.espCol = v end)
	addSelector(cd, 4, "Style", {"Chams","Outline","Both"}, 1, function(v) CB.espStyle = v end)
	addSlider(cd, 5, "Fill", 0, 1, 0.15, "", function(v) CB.espFill = v end)
	addSlider(cd, 6, "Rainbow", 0.2, 3, 1, "x", function(v) CB.espHs = v end)

	addSection(p, 3, "ex")
	local c2 = addCard(p, 4)
	addToggle(c2, 1, "Head Dot", "", false, function(o) CB.headDot = o end)
	addToggle(c2, 2, "2D Box", "", false, function(o) CB.box = o end)
	addToggle(c2, 3, "Health Bar", "", false, function(o) CB.hp = o end)

	addSection(p, 5, "tt")
	local c3 = addCard(p, 6)
	addToggle(c3, 1, "Show Text", "", true, function(o) CB.espTxt = o end)
	addSelector(c3, 2, "Mode", {"None","Name","Distance","Coords"}, 4, function(v) CB.espTxtMode = v end)
	addSlider(c3, 3, "Size", 8, 24, 12, "", function(v) CB.espTxtSz = math.floor(v+0.5) end)
	addToggle(c3, 4, "Stroke", "", true, function(o) CB.espTxtStk = o end)

	addSection(p, 7, "trc")
	local c4 = addCard(p, 8)
	addToggle(c4, 1, "Show Tracer", "Line on shot only", false, function(o) CB.tracer = o end)
end

do
	local p = navP.AimBot
	addSection(p, 1, "tg")
	local c1 = addCard(p, 2)
	addToggle(c1, 1, "Enabled", "Auto-shoot on enemy", false, function(o) CB.trigger = o end)
	addSlider(c1, 2, "FOV", 40, 500, 140, " px", function(v) CB.tFov = v end)
	addSlider(c1, 3, "Delay", 200, 900, 350, " ms", function(v) CB.tDel = v/1000 end)

	addSection(p, 3, "ab")
	local c2 = addCard(p, 4)
	addToggle(c2, 1, "Enabled", "Smooth camera lock", false, function(o) CB.aAim = o end)
	addSlider(c2, 2, "FOV", 40, 500, 220, " px", function(v) CB.afov = v end)
	addSlider(c2, 3, "Smooth", 5, 20, 10, "", function(v) CB.asm = v end)

	addSection(p, 5, "sa")
	local c3 = addCard(p, 6)
	addToggle(c3, 1, "Enabled", "Character snap on shoot", false, function(o) CB.silent = o end)
	addSlider(c3, 2, "FOV", 40, 800, 300, " px", function(v) CB.sFov = v end)
	addSlider(c3, 3, "Head %", 0, 100, 100, "%", function(v) CB.sHead = math.floor(v+0.5) end)
	addToggle(c3, 4, "Visible", "Only visible targets", false, function(o) CB.sVis = o end)
	addSlider(c3, 5, "Duration", 5, 50, 12, " cs", function(v) CB.sDur = v/100 end)

	addSection(p, 7, "sp")
	local c4 = addCard(p, 8)
	addToggle(c4, 1, "Enabled", "Character rotates", false, function(o)
		CB.spin = o
		local ch = LP.Character
		local h = ch and ch:FindFirstChildOfClass("Humanoid")
		if h then h.AutoRotate = not o end
	end)
	addSlider(c4, 2, "Speed", 60, 900, 180, " deg", function(v) CB.spSpd = v end)
end

do
	local p = navP.Blatant
	addSection(p, 1, "ch")
	local c1 = addCard(p, 2)
	addToggle(c1, 1, "Max Speed", "Custom WalkSpeed", false, function(o)
		CB.maxSpd = o
		if not o then
			local ch = LP.Character
			local h = ch and ch:FindFirstChildOfClass("Humanoid")
			if h then h.WalkSpeed = 16 end
		end
	end)
	addSlider(c1, 2, "WalkSpeed", 16, 30, 20, "", function(v) CB.msVal = math.floor(v+0.5) end)
	addToggle(c1, 3, "Noclip", "Through walls", false, function(o)
		CB.noclip = o
		if o then pcall(forceNoclip) else pcall(restoreNoclip) end
	end)
	addToggle(c1, 4, "Air Jump", "Infinite jumps", false, function(o) CB.air = o end)

	addSection(p, 3, "mv")
	local c2 = addCard(p, 4)
	addToggle(c2, 1, "Fly", "Free fly", false, function(o)
		CB.fly = o
		if not o then pcall(stopFly) end
	end)
	addSlider(c2, 2, "Fly Speed", 20, 200, 60, "", function(v) CB.flySpd = math.floor(v+0.5) end)
end

do
	local p = navP.Guns
	addSection(p, 1, "am")
	local c1 = addCard(p, 2)
	addToggle(c1, 1, "Infinite Ammo", "Keep top-up", false, function(o) CB.ammo = o end)
	addToggle(c1, 2, "No Reload", "Prevent reload", false, function(o) CB.noreload = o end)
end

do
	local p = navP.Misc
	addSection(p, 1, "it")
	local c1 = addCard(p, 2)
	addSlider(c1, 1, "Menu Scale", 60, 150, 100, "%", function(v) mainScale.Scale = v/100 end)
	addToggle(c1, 2, "FOV Circle", "", true, function(o) CB.showFov = o end)
	addToggle(c1, 3, "Safe Mode", "", true, function(o) CB.safe = o end)
end

-- switch
local function switchPage(n)
	if n == navSel and curP and curP.Visible then return end
	navSel = n
	for pn, pg in pairs(navP) do
		if pg and pn ~= n and pg.Visible then
			pg.Visible = false
			pg.Position = UDim2.fromOffset(0,0)
		end
	end
	for nm, o in pairs(navB) do
		local s = (nm == n)
		o.lbl.TextColor3 = s and C.tx or C.td
		o.lbl.Font = s and Enum.Font.GothamBold or Enum.Font.GothamMedium
		tw(o.ul, TweenInfo.new(0.28, Enum.EasingStyle.Back), {Size=UDim2.new(s and 0.45 or 0, 0, 0, 3)})
	end
	local np = navP[n]
	if np then
		np.Position = UDim2.fromOffset(0, 22)
		np.Visible = true
		tw(np, TweenInfo.new(0.26, Enum.EasingStyle.Quart), {Position=UDim2.fromOffset(0,0)})
		curP = np
	end
end
for nm, d in pairs(navB) do bnd(d.btn.MouseButton1Click, function() switchPage(nm) end) end

-- drag
local mDrag = nil
bnd(topBar.InputBegan, function(x)
	if x.UserInputType == Enum.UserInputType.MouseButton1 or x.UserInputType == Enum.UserInputType.Touch then
		mDrag = {sp=x.Position, st=main.Position}
	end
end)
bnd(U.InputChanged, function(x)
	if not mDrag then return end
	if x.UserInputType == Enum.UserInputType.MouseMovement or x.UserInputType == Enum.UserInputType.Touch then
		local d = x.Position - mDrag.sp
		main.Position = UDim2.new(mDrag.st.X.Scale, mDrag.st.X.Offset+d.X, mDrag.st.Y.Scale, mDrag.st.Y.Offset+d.Y)
	end
end)
bnd(U.InputEnded, function(x)
	if x.UserInputType == Enum.UserInputType.MouseButton1 or x.UserInputType == Enum.UserInputType.Touch then
		mDrag = nil
	end
end)

function staggerCards()
	for i, cd in ipairs(allCards) do
		if cd and cd.Parent then
			local s = cd:FindFirstChildOfClass("UIScale")
			cd.BackgroundTransparency = 1
			if s then s.Scale = 0.94 end
			task.delay((i-1)*0.03, function()
				if cd and cd.Parent then
					tw(cd, 0.32, {BackgroundTransparency=0})
					if s then tw(s, TweenInfo.new(0.36, Enum.EasingStyle.Back), {Scale=1}) end
				end
			end)
		end
	end
end

bnd(ClB.MouseButton1Click, closeMenu)

-- refresh localization
local function refreshLocale()
	for nm, d in pairs(navB) do d.lbl.Text = TS("tb", nm) end
	for _, e in ipairs(allSections) do
		if e.lbl and e.lbl.Parent then e.lbl.Text = TS("sec", e.key) end
	end
	if SPON and SPON.Parent then SPON.Text = LS[Lang].sponsor or LS.en.sponsor end
end

-- hook endIntro to refresh + open menu
local _oldFinish = finish
finish = function()
	if DONE then return end
	introActive = false
	_oldFinish()
	refreshLocale()
	-- pill slide in
	PH.Position = UDim2.new(0, -260, 0, 12)
	PB.BackgroundTransparency = 1
	tw(PH, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Position=UDim2.new(0, 12, 0, 12)})
	tw(PB, 0.4, {BackgroundTransparency=0})
	task.delay(0.55, function() openMenu() end)
end
-- override finish reference used inside intro calls
-- (intro calls finish via upvalue, we replaced var, but need to reassign inside delayed runtimes)
-- simpler: endIntro closure rebinding
local function newFinish()
	if DONE then return end
	DONE = true
	introActive = false
	for _, L in ipairs(FLetters) do
		tw(L.lbl, 0.5, {TextTransparency=1, Rotation=20})
		tw(L.us, 0.5, {Scale=1.4})
	end
	tw(SUB, 0.35, {TextTransparency=1})
	tw(SPON, 0.35, {TextTransparency=1})
	tw(PROG_BAR, 0.35, {BackgroundTransparency=1})
	tw(PROG_LBL, 0.35, {TextTransparency=1})
	tw(Ring, 0.5, {Size=UDim2.fromOffset(1200,1200)})
	tw(Ring2, 0.5, {Size=UDim2.fromOffset(1400,1400)})
	tw(Ring3, 0.5, {Size=UDim2.fromOffset(1600,1600)})
	task.wait(0.5)
	tw(OV, 0.7, {BackgroundTransparency=1})
	task.wait(0.75)
	if OV and OV.Parent then OV:Destroy() end
	refreshLocale()
	PH.Position = UDim2.new(0, -260, 0, 12)
	PB.BackgroundTransparency = 1
	tw(PH, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Position=UDim2.new(0, 12, 0, 12)})
	tw(PB, 0.4, {BackgroundTransparency=0})
	task.wait(0.55)
	openMenu()
end

bnd(SKIP.MouseButton1Click, function() if not DONE then pcall(newFinish) end end)
task.delay(11.5, function() if not DONE then pcall(newFinish) end end)

-- =========================================================
-- spin / aim / fov / speed loops
-- =========================================================
local sAng = 0
bnd(R.RenderStepped, function(dt)
	if not CB.spin then return end
	local ch = LP.Character
	if not ch then return end
	local hr = ch:FindFirstChild("HumanoidRootPart")
	local hm = ch:FindFirstChildOfClass("Humanoid")
	if not hr or not hm or hm.Health <= 0 then return end
	if hm.AutoRotate then hm.AutoRotate = false end
	sAng = sAng + dt * math.rad(CB.spSpd)
	if sAng > math.pi * 2 then sAng = sAng - math.pi * 2 end
	hr.CFrame = CFrame.new(hr.Position) * CFrame.Angles(0, sAng, 0)
end)

local function getFovTarget(fov)
	local vp = Cam.ViewportSize
	local cn = Vector2.new(vp.X*0.5, vp.Y*0.5)
	local best, ba = nil, fov
	local mc = LP.Character
	if not mc or not mc:FindFirstChild("HumanoidRootPart") then return nil end
	for _, p in ipairs(P:GetPlayers()) do
		if isEnemy(p) then
			local ch = p.Character
			if ch then
				local hd = ch:FindFirstChild("Head")
				local rt = ch:FindFirstChild("HumanoidRootPart")
				local hm = ch:FindFirstChildOfClass("Humanoid")
				if hd and rt and hm and hm.Health > 0 then
					local sp, on = Cam:WorldToViewportPoint(rt.Position)
					if on and sp.Z > 0 then
						local d = (Vector2.new(sp.X, sp.Y) - cn).Magnitude
						if d < ba then
							ba = d
							best = {head=hd, root=rt, ch=ch, pl=p}
						end
					end
				end
			end
		end
	end
	return best
end

local lf = 0
bnd(R.Heartbeat, function()
	local ch = LP.Character
	if not ch then return end
	local hm = ch:FindFirstChildOfClass("Humanoid")
	if not hm or hm.Health <= 0 then return end
	if CB.trigger then
		local t = getFovTarget(CB.tFov)
		if t and t.head then
			local lk = CFrame.lookAt(Cam.CFrame.Position, t.head.Position)
			Cam.CFrame = Cam.CFrame:Lerp(lk, 0.35)
			local tt = ch:FindFirstChildOfClass("Tool")
			local n = os.clock()
			local dl = CB.tDel + (CB.safe and math.random()*0.06 or 0)
			if tt and n - lf >= dl then
				lf = n
				pcall(function() tt:Activate() end)
			end
		end
	end
	if CB.aAim then
		local t = getFovTarget(CB.afov)
		if t and t.head then
			local lk = CFrame.lookAt(Cam.CFrame.Position, t.head.Position)
			local s = math.clamp(1/CB.asm, 0.05, 0.35)
			Cam.CFrame = Cam.CFrame:Lerp(lk, s)
		end
	end
end)

bnd(R.RenderStepped, function()
	local a, r = false, 0
	if CB.trigger then a=true; r=math.max(r, CB.tFov) end
	if CB.aAim then a=true; r=math.max(r, CB.afov) end
	if CB.silent then a=true; r=math.max(r, CB.sFov) end
	fovCircle.Visible = a and CB.showFov
	if r > 0 then fovCircle.Size = UDim2.fromOffset(r*2, r*2) end
end)

bnd(R.Heartbeat, function()
	if not CB.maxSpd then return end
	local ch = LP.Character
	local hm = ch and ch:FindFirstChildOfClass("Humanoid")
	if not hm then return end
	local t = CB.msVal
	local cr = hm.WalkSpeed
	if math.abs(cr - t) > 0.5 then
		local s = math.clamp(t - cr, -0.5, 0.5)
		hm.WalkSpeed = cr + s
	end
end)

bnd(U.InputBegan, function(x, gp)
	if gp then return end
	if x.KeyCode == Enum.KeyCode.RightShift then
		if not introActive then
			if menuOpen then closeMenu() else openMenu() end
		end
	end
end)

task.defer(function()
	for n, o in pairs(navB) do
		local s = (n == navSel)
		o.lbl.TextColor3 = s and C.tx or C.td
		o.lbl.Font = s and Enum.Font.GothamBold or Enum.Font.GothamMedium
		o.ul.Size = UDim2.new(s and 0.45 or 0, 0, 0, 3)
	end
	local p = navP[navSel]
	if p then p.Position = UDim2.fromOffset(0,0) end
end)

if getgenv then
	getgenv().FinisHub = {
		Combat = CB, GUI = G, Main = main,
		OpenMenu = openMenu, CloseMenu = closeMenu,
		SwitchPage = switchPage,
		SetLang = function(l) Lang = l; if refreshLocale then refreshLocale() end end,
		EndIntro = newFinish,
	}
	getgenv().FinisToggleMenu = function() if menuOpen then closeMenu() else openMenu() end end
end
