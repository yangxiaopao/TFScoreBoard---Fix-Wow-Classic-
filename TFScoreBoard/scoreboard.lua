local TFScore = CreateFrame("Frame","TFScoreBoard",UIParent)
TFScoreBoard = LibStub("AceAddon-3.0"):NewAddon("TFScoreBoard")
local TFScoreBoard = TFScoreBoard
local db
local defaults = { 
	profile = {
		isNameClassColor = true,
		pmodSetPortraitZoom = 0,
	}, 
}

local myOptionsTable = {
  type = "group",
  name = "TFScoreBoard 战场分数板配置",
  args = {
    enable = {
      name = "战场名字职业颜色",
      desc = "名字颜色按职业进行染色",
      type = "toggle",
      set = function(info,val) 
      			db.isNameClassColor = val  
      			updateHorde()
      			updateAlliance()
  			end,
      get = function(info) return db.isNameClassColor end
    }
  }
}

local activeBg = ""
local allianceScoreText
local hordeScoreText
local numAllianceText 
local numHordeText
local numHordeFrame
local numAllianceFrame
local alliancePlayerIndicator
local hordePlayerIndicator
local aScoreChild
local hScoreChild

local tfinit = nil;
local classes = {}

local psname = {};
local pstats = {};

local hclass = {};
local hnames = {};
local hkb = {};
local hdeaths = {};

local aclass = {};
local anames = {};
local akb = {};
local adeaths = {};

local textures = {};

local GetfactionMaxNum = function(bgName) 
	if bgName == "奥特兰克山谷" then
		return 40
	elseif bgName == "冬拥湖" then
		return 120
	elseif bgName == "战歌峡谷" then
		return 10
	else
		return 15
	end
end

local pmod

local function setfs(parent, frame, size, att1, att2, x, y, just, t, ...)
	frame:SetFont(GameFontNormal:GetFont(), size,"OUTLINE");
	frame:SetPoint(att1, parent, att2, x, y);
	frame:SetJustifyH(just);
	if t then frame:SetText(t) end;
	frame:SetVertexColor(...);
end;

local function SetPmodZoom(p)
	p:SetPortraitZoom(db.pmodSetPortraitZoom)
	if(db.pmodSetPortraitZoom == 1) then
		p:SetCamDistanceScale(1.7)
	else
		p:SetCamDistanceScale(1)
	end
end



function TFScoreBoard:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("TFScoreBoard", defaults)
    db = self.db.profile
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("TFScoreBoard", myOptionsTable)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("TFScoreBoard", "TFScoreBoard")

	local ti = {
	{{0,0,0,0.4}, 700, 500, "CENTER", 0, 0},
	{"Interface\\AddOns\\TFScoreBoard\\tex\\tl", 16, 16, "TOPLEFT", 0, 16, 0, 0, 0, 0.4},
	{"Interface\\AddOns\\TFScoreBoard\\tex\\tr", 16, 16, "TOPRIGHT", 0, 16, 0, 0, 0, 0.4},
	{"Interface\\AddOns\\TFScoreBoard\\tex\\bl", 16, 16, "BOTTOMLEFT", 0, -16, 0, 0, 0, 0.4},
	{"Interface\\AddOns\\TFScoreBoard\\tex\\br", 16, 16, "BOTTOMRIGHT", 0, -16, 0, 0, 0, 0.4},
	{{0,0,0,0.4}, 668, 16, "TOP", 0, 16},
	{{0,0,0,0.4}, 668, 16, "BOTTOM", 0, -16},
	{{1, 0.25, 0.2, 0.4}, 340, 20, "TOPRIGHT", 0, 60},
	{"Interface\\AddOns\\TFScoreBoard\\tex\\tl", 16, 16, "TOPRIGHT", -324, 76, 1, 0.25, 0.2, 0.4},
	{"Interface\\AddOns\\TFScoreBoard\\tex\\tr", 16, 16, "TOPRIGHT", 0, 76, 1, 0.25, 0.2, 0.4},
	{"Interface\\AddOns\\TFScoreBoard\\tex\\bl", 16, 16, "TOPRIGHT", -324, 40, 1, 0.25, 0.2, 0.4},
	{"Interface\\AddOns\\TFScoreBoard\\tex\\br", 16, 16, "TOPRIGHT", 0, 40, 1, 0.25, 0.2, 0.4},
	{{1, 0.25, 0.2, 0.4}, 308, 16, "TOPRIGHT", -16, 76},
	{{1, 0.25, 0.2, 0.4}, 308, 16, "TOPRIGHT", -16, 40},
	{{0.62, 0.8, 0.98, 0.4}, 340, 20, "TOPLEFT", 0, 60},
	{"Interface\\AddOns\\TFScoreBoard\\tex\\tl", 16, 16, "TOPLEFT", 0, 76, 0.62, 0.8, 0.98, 0.4},
	{"Interface\\AddOns\\TFScoreBoard\\tex\\tr", 16, 16, "TOPLEFT", 324, 76, 0.62, 0.8, 0.98, 0.4},
	{"Interface\\AddOns\\TFScoreBoard\\tex\\bl", 16, 16, "TOPLEFT", 0, 40, 0.62, 0.8, 0.98, 0.4},
	{"Interface\\AddOns\\TFScoreBoard\\tex\\br", 16, 16, "TOPLEFT", 324, 40, 0.62, 0.8, 0.98, 0.4},
	{{0.62, 0.8, 0.98, 0.4}, 308, 16, "TOPLEFT", 16, 76},
	{{0.62, 0.8, 0.98, 0.4}, 308, 16, "TOPLEFT", 16, 40},
	{{0,0,0,1}, 2, 370, "CENTER", 0, 70},
	{{1,1,1,0.5}, 320, 1, "TOPRIGHT", -20, -11},
	{{1,1,1,0.5}, 320, 1, "TOPLEFT", 20, -11},
	{{0,0,0,1}, 668, 100, "BOTTOMLEFT", 16, 0},
	};

	TFScore:SetFrameStrata("DIALOG");
	TFScore:SetWidth(700);
	TFScore:SetHeight(500);
	TFScore:SetPoint("CENTER",0,0);
		
	for i=1, #ti do
		textures[i] = TFScore:CreateTexture(nil,"BACKGROUND");
		if type(ti[i][1]) == "string" then
		 textures[i]:SetTexture(ti[i][1]);
		 textures[i]:SetVertexColor(ti[i][7],ti[i][8],ti[i][9],ti[i][10]);
		else
		 textures[i]:SetColorTexture(ti[i][1][1],ti[i][1][2],ti[i][1][3],ti[i][1][4]);
		end;
		textures[i]:SetWidth(ti[i][2]);
		textures[i]:SetHeight(ti[i][3]);
		textures[i]:SetPoint(ti[i][4],ti[i][5],ti[i][6]);
		

	end;


	local sepstat = TFScore:CreateTexture(nil,"MEDIUM");
	sepstat:SetWidth(500);
	sepstat:SetHeight(2);
	sepstat:SetPoint("BOTTOMRIGHT" ,-32 ,70);
	sepstat:SetTexture(1, 0.25, 0.2);
	local pname = TFScore:CreateFontString(nil, "MEDIUM");
	setfs(TFScore,pname, 30, "BOTTOMLEFT", "BOTTOMLEFT", 170, 70, "LEFT", 1, 0.25, 0.2);
	pname:SetText(UnitName("player"));

	if UnitFactionGroup("player") == "Horde" then
		sepstat:SetTexture(1, 0.25, 0.2);
		pname:SetVertexColor(1, 0.25, 0.2);
	else
		sepstat:SetTexture(0.62, 0.8, 0.98);
		pname:SetVertexColor(0.62, 0.8, 0.98);
	end
	
	pmod = CreateFrame("PlayerModel" ,nil , TFScore);
	pmod:SetPoint("TOPLEFT", TFScore, "BOTTOMLEFT" ,16 ,150);
	pmod:SetPoint("BOTTOMRIGHT", TFScore, "BOTTOMLEFT",166 ,0);
	pmod:SetUnit("player");
	SetPmodZoom(pmod)

	local pmodBtn = CreateFrame("Button","pmodBtn",pmod)
	pmodBtn:SetAllPoints()
	pmodBtn:SetSize(pmod:GetWidth(),pmod:GetHeight())
	pmodBtn:SetScript("OnClick",function()
		if(db.pmodSetPortraitZoom == 0) then
			db.pmodSetPortraitZoom = 1
		else
			db.pmodSetPortraitZoom = 0
		end
		SetPmodZoom(pmod)
	end)

	local TFHordetext = TFScore:CreateFontString(nil, "MEDIUM");
	 setfs(TFScore,TFHordetext, 50, "BOTTOMRIGHT", "TOPRIGHT", -20, 30, "RIGHT", "部落", 0.93, 0.89, 0.78);

	 --player num horde

	numHordeFrame = CreateFrame("Frame",nil,TFScore)
	numHordeFrame:SetPoint("BOTTOMRIGHT",TFScore,"TOPRIGHT",-150,34)
	numHordeFrame:SetSize(100,20)

	numHordeText = numHordeFrame:CreateFontString(nil, "MEDIUM");
	numHordeText:SetFont(GameFontNormal:GetFont(), 16,"OUTLINE")
	numHordeText:SetVertexColor(0.93, 0.89, 0.78)
	numHordeText:SetPoint("CENTER")
	numHordeText:SetText("1个玩家")

	hordeScoreText = TFScore:CreateFontString(nil, "MEDIUM");
	 setfs(TFScore,hordeScoreText, 40, "BOTTOM", "TOP", 60, 32, "RIGHT", nil, 0.93, 0.89, 0.78);	

	local TFAllitext = TFScore:CreateFontString(nil, "MEDIUM");
	 setfs(TFScore,TFAllitext, 50, "BOTTOMLEFT", "TOPLEFT", 20, 30, "RIGHT", "联盟", 0.93, 0.89, 0.78);

	 --player num frame alliance

	numAllianceFrame = CreateFrame("Frame",nil,TFScore)
	numAllianceFrame:SetPoint("BOTTOMLEFT",TFScore,"TOPLEFT",150,34)
	numAllianceFrame:SetSize(100,20)

	numAllianceText = numAllianceFrame:CreateFontString(nil, "MEDIUM");
	numAllianceText:SetFont(GameFontNormal:GetFont(), 16,"OUTLINE")
	numAllianceText:SetVertexColor(0.93, 0.89, 0.78)
	numAllianceText:SetPoint("CENTER")
	numAllianceText:SetText("1个玩家")

	allianceScoreText = TFScore:CreateFontString(nil, "MEDIUM");
	 setfs(TFScore,allianceScoreText, 40, "BOTTOM", "TOP", -60, 32, "LEFT", nil, 0.93, 0.89, 0.78);
		
	local nameheader1 = TFScore:CreateFontString(nil, "MEDIUM");
	 setfs(TFScore,nameheader1, 14, "TOPLEFT", "TOPLEFT", 45, 2, "LEFT", "名字", 1,1,1);
	local killsheader1 = TFScore:CreateFontString(nil, "MEDIUM");
	 setfs(TFScore,killsheader1, 14, "TOP", "TOP", -70, 2, "LEFT", "击杀", 1,1,1);
	local deathsheader1 = TFScore:CreateFontString(nil, "MEDIUM");
	 setfs(TFScore,deathsheader1, 14, "TOP", "TOP", -30, 2, "LEFT", "死亡", 1,1,1);
		
	local nameheader2 = TFScore:CreateFontString(nil, "MEDIUM");
	 setfs(TFScore,nameheader2, 14, "TOP", "TOP", 55, 2, "LEFT", "名字", 1,1,1);
	local killsheader2 = TFScore:CreateFontString(nil, "MEDIUM");
	 setfs(TFScore,killsheader2, 14, "TOPRIGHT", "TOPRIGHT", -60, 2, "LEFT", "击杀", 1,1,1);
	local deathsheader2 = TFScore:CreateFontString(nil, "MEDIUM");
	setfs(TFScore,deathsheader2, 14, "TOPRIGHT", "TOPRIGHT", -22, 2, "LEFT", "死亡", 1,1,1);
		
		
	local st = {"击杀:", "死亡:", "治疗输出:", "伤害输出:", "荣誉击杀:", "获得荣誉:", nil, nil, nil, nil, nil, nil};

	for i=1, 12 do
		psname[i] = TFScore:CreateFontString(nil, "MEDIUM");
		setfs(TFScore,psname[i], 14, "BOTTOMRIGHT", "BOTTOMRIGHT", ((208*floor((i-1)/4))-460), (52-(15*floor((i-1)%4))), "RIGHT", st[i], 1,1,1);
		pstats[i] = TFScore:CreateFontString(nil, "MEDIUM");
		setfs(TFScore,pstats[i], 14, "BOTTOMLEFT", "BOTTOMRIGHT", ((208*floor((i-1)/4))-460), (52-(15*floor((i-1)%4))), "LEFT", nil, 1,1,1);
	end

	--scoreframe scrollable
	local aScoreframe = CreateFrame("ScrollFrame", "ascoreframe", TFScore, "UIPanelScrollFrameTemplate");
	aScoreframe:SetPoint("TOPLEFT",TFScore,"TOPLEFT",10,-20)
	aScoreframe:SetSize(340,365)
	aScoreframe.ScrollBar:SetAlpha(0)

	aScoreChild = CreateFrame("Frame","aScoreChild",aScoreframe)
	aScoreChild:SetSize(aScoreframe:GetWidth(),aScoreframe:GetHeight())
	aScoreframe:SetScrollChild(aScoreChild)

	local hScoreframe = CreateFrame("ScrollFrame", "hscoreframe", TFScore, "UIPanelScrollFrameTemplate");
	hScoreframe:SetPoint("TOPLEFT",TFScore,"TOP",10,-20)
	hScoreframe:SetSize(340,365)
	hScoreframe.ScrollBar:SetAlpha(0)

	hScoreChild = CreateFrame("Frame","hScoreChild",hScoreframe)
	hScoreChild:SetSize(hScoreframe:GetWidth(),hScoreframe:GetHeight())
	hScoreframe:SetScrollChild(hScoreChild)

	alliancePlayerIndicator = aScoreChild:CreateTexture(nil,"BACKGROUND")
	alliancePlayerIndicator:SetTexture(1, 1, 1, 0.1)
	alliancePlayerIndicator:SetWidth(320)
	alliancePlayerIndicator:SetHeight(20)
	alliancePlayerIndicator:SetPoint("CENTER")
	alliancePlayerIndicator:Hide()

	hordePlayerIndicator = hScoreChild:CreateTexture(nil,"BACKGROUND")
	hordePlayerIndicator:SetTexture(1, 1, 1, 0.1)
	hordePlayerIndicator:SetWidth(320)
	hordePlayerIndicator:SetHeight(20)
	hordePlayerIndicator:SetPoint("CENTER")
	hordePlayerIndicator:Hide()

	for i=1, 120 do

		--horde names
		hnames[i] = hScoreChild:CreateFontString(nil, "MEDIUM");
		setfs(hScoreChild,hnames[i], 16, "TOPLEFT", "TOPLEFT", 35, -((i - 1)*22), "LEFT", nil, 1, 0.25, 0.2);
		hnames[i]:SetWidth(220);

		hkb[i] = hScoreChild:CreateFontString(nil, "MEDIUM");
		setfs(hScoreChild,hkb[i], 16, "TOPRIGHT", "TOPRIGHT", -45, -((i -1)*22), "LEFT", nil, 1, 0.25, 0.2);
		hkb[i]:SetWidth(40);


		hdeaths[i] = hScoreChild:CreateFontString(nil, "MEDIUM");
		setfs(hScoreChild,hdeaths[i], 16, "TOPRIGHT", "TOPRIGHT", -5, -((i - 1)*22), "LEFT", nil, 1, 0.25, 0.2);
		hdeaths[i]:SetWidth(40);

		hclass[i] = hScoreChild:CreateTexture(nil,"MEDIUM");
		hclass[i]:SetWidth(16);
		hclass[i]:SetHeight(16);
		hclass[i]:SetPoint("TOPLEFT", hScoreChild, "TOPLEFT", 15, -(1+(i - 1)*22));
		hclass[i]:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes");

		hclass[i]:SetTexCoord(1, 1, 1, 1);

		--alliance names
		anames[i] = aScoreChild:CreateFontString(nil, "MEDIUM");
		setfs(aScoreChild,anames[i], 16, "TOPLEFT", "TOPLEFT", 35, -((i - 1)*22), "LEFT", nil, 0.62, 0.8, 0.98);
		anames[i]:SetWidth(220);

		akb[i] = aScoreChild:CreateFontString(nil, "MEDIUM");
		setfs(aScoreChild,akb[i], 16, "TOPRIGHT", "TOPRIGHT", -45, -((i - 1)*22), "LEFT", nil, 0.62, 0.8, 0.98);
		akb[i]:SetWidth(40);

		adeaths[i] = aScoreChild:CreateFontString(nil, "MEDIUM");
		setfs(aScoreChild,adeaths[i], 16, "TOPRIGHT", "TOPRIGHT", -5, -((i-1)*22), "LEFT", nil, 0.62, 0.8, 0.98);
		adeaths[i]:SetWidth(40);

		aclass[i] = aScoreChild:CreateTexture(nil,"MEDIUM");
		aclass[i]:SetWidth(16);
		aclass[i]:SetHeight(16);
		aclass[i]:SetPoint("TOPLEFT", aScoreChild, "TOPLEFT", 15, -(1+(i - 1)*22));
		aclass[i]:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes");
		aclass[i]:SetTexCoord(1, 1, 1, 1);
	end;	
end

	
function hidetfs()
	TFScore:Hide();
end;
function toggletfs()
		
if TFScore:IsShown() then
		hidetfs();
	else
		showtfs();
	end;
end;
function showtfs()
	pmod:SetUnit("player");
	TFScore:Show();
	RequestBattlefieldScoreData();
	--[[if GetBattlefieldWinner() then
		leaveButton:Show();
	end;]]
end;
	
TFScore:Hide();
tfinit = 1;

local function updateHorde()
	hordePlayerIndicator:Hide();
	local k=1;
	local name, killingBlows, honorableKills, deaths, honorGained, faction, classToken, damageDone, healingDone, temp;
	local num = GetfactionMaxNum(activeBg)
	for i=1,num do
		while k< num * 2 +1 do
			_, _, _, _, _, faction = GetBattlefieldScore(k);
			k=k+1;
			if faction==0 then break end
		end	
		name, killingBlows, honorableKills, deaths, honorGained, faction, _, _,_, classToken, damageDone, healingDone = GetBattlefieldScore(k-1);
			if ( name ) then
				hnames[i]:SetText(name);
				if(db.isNameClassColor and name~=UnitName("player")) then
					local r,g,b = GetClassColor(classToken)
					hnames[i]:SetVertexColor(r,g,b)
				else
					hnames[i]:SetVertexColor(1, 0.25, 0.2)
				end
				hkb[i]:SetText(killingBlows);
				hdeaths[i]:SetText(deaths);
				
				t1,t2,t3,t4 = unpack(CLASS_ICON_TCOORDS[classToken]);
				hclass[i]:SetTexCoord(t1,t2,t3,t4);

				hclass[i]:Show()
				hnames[i]:Show()
				hkb[i]:Show()
				hdeaths[i]:Show()	
				
			else
				hnames[i]:SetText(nil);
				hkb[i]:SetText(nil);
				hdeaths[i]:SetText(nil);
				hclass[i]:SetTexCoord(1, 1, 1, 1);
			end
			if ( name==UnitName("player") ) then

				hordePlayerIndicator:Show();
				hordePlayerIndicator:ClearAllPoints();
				hordePlayerIndicator:SetPoint("TOPRIGHT", -20, 1-(22*(i - 1)));
			end
	end
end

local function updateAlliance()
	alliancePlayerIndicator:Hide();
	local k=1
	local name, killingBlows, honorableKills, deaths, honorGained, faction, classToken, damageDone, healingDone, temp
	local num =  GetfactionMaxNum(activeBg)
	for i=1,num do
		while k<num * 2 + 1 do
			_, _, _, _, _, faction = GetBattlefieldScore(k)
			k=k+1
			
			if faction==1 then break end
		end	
				
		name, killingBlows, honorableKills, deaths, honorGained, faction, _, _,_, classToken, damageDone, healingDone = GetBattlefieldScore(k-1)
		if ( name ) then
			anames[i]:SetText(name)
			if(db.isNameClassColor and name~=UnitName("player")) then
				local r,g,b = GetClassColor(classToken)
				anames[i]:SetVertexColor(r,g,b)
			else
				anames[i]:SetVertexColor(0.62, 0.8, 0.98)
			end
			akb[i]:SetText(killingBlows)
			adeaths[i]:SetText(deaths)
					
			t1,t2,t3,t4 = unpack(CLASS_ICON_TCOORDS[classToken])
			aclass[i]:SetTexCoord(t1,t2,t3,t4);

			aclass[i]:Show()
			anames[i]:Show()
			akb[i]:Show()
			adeaths[i]:Show()
		else
			anames[i]:SetText(nil)
			akb[i]:SetText(nil)
			adeaths[i]:SetText(nil)
			aclass[i]:SetTexCoord(1, 1, 1, 1)
		end
		if ( name==UnitName("player") ) then

			alliancePlayerIndicator:Show()
			alliancePlayerIndicator:ClearAllPoints()
			alliancePlayerIndicator:SetPoint("TOPLEFT", 20, 1-(22*(i - 1)))
		end		
	end
end

local function getRealmText(list)
	local keys = {}
	for k, v in pairs(list) do
		table.insert(keys,k)
	end

	table.sort(keys,function(keyL,keyR)
      return list[keyL] > list[keyR]
	end)

	local realmText = ""
	for k,v in pairs(keys) do
		realmText = realmText .. string.format("%s：%s\n",v,list[v])
	end

	return realmText
end


local function updateMisc()
	
	local numHorde = 0
	local numAlliance = 0
	local temp
	local playerRealm = GetRealmName()
	local list = {}
	local realmHorde = {}
	local realmAlliance = {}

	for i=1, GetNumBattlefieldScores() do
		name, killingBlows, honorableKills, deaths, honorGained, faction, _, _,_, classToken, damageDone, healingDone = GetBattlefieldScore(i)

		
		local _,realm = strsplit("-", name)
		
		if(not realm) then realm = playerRealm end

		if ( faction ) then
			if ( faction == 0 ) then
				numHorde = numHorde + 1
				list = realmHorde
			else
				list = realmAlliance
				numAlliance = numAlliance + 1
			end
		end

		if(not list[realm]) then 
			list[realm] = 1
		else 
			list[realm] = list[realm] + 1
		end

		if ( name==UnitName("player") ) then
			pstats[1]:SetText(killingBlows)
			pstats[2]:SetText(deaths)
			pstats[3]:SetText(healingDone)
			pstats[4]:SetText(damageDone)
			pstats[5]:SetText(honorableKills)
			pstats[6]:SetText(honorGained)
			for k = 1, 6 do
				temp = GetBattlefieldStatInfo(k)
				if temp then
					psname[k+6]:SetText(temp ..":")
					temp = GetBattlefieldStatData(i,k)
					pstats[k+6]:SetText(temp)
				else
					psname[k+6]:SetText(nil)
					pstats[k+6]:SetText(nil)
				end
			end
		end
	end

	local realmHordeText = getRealmText(realmHorde)
	local realmAllianceText = getRealmText(realmAlliance)

	numHordeFrame:SetScript("OnEnter",function(self)
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
		GameTooltip:AddLine(realmHordeText)
		GameTooltip:Show()
	end)

	numHordeFrame:SetScript("OnLeave",function(self)
		GameTooltip:Hide()
	end)

	numAllianceFrame:SetScript("OnEnter",function(self)
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
		GameTooltip:AddLine(realmAllianceText)
		GameTooltip:Show()
	end)

	numAllianceFrame:SetScript("OnLeave",function(self)
		GameTooltip:Hide()
	end)



	numAllianceText:SetText(numAlliance.." 玩家")
	numHordeText:SetText(numHorde.." 玩家")

	for i = numAlliance + 1,120 do
		aclass[i]:Hide()
		anames[i]:Hide()
		akb[i]:Hide()
		adeaths[i]:Hide()
	end

	for i = numHorde + 1,120 do
		hclass[i]:Hide()
		hnames[i]:Hide()
		hkb[i]:Hide()
		hdeaths[i]:Hide()	
	end
	

	
end

local function updateScores()
	local index=1
	local status, pattern, temp
	local topCenter = C_UIWidgetManager.GetTopCenterWidgetSetID()
	local widgets = C_UIWidgetManager.GetAllWidgetsBySetID(topCenter)
	local scoreText = {}
	for i, w in pairs(widgets) do
		widgetInfo = C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo(w.widgetID)
   		scoreText[i] = widgetInfo.text
	end
	for i = 1, GetMaxBattlefieldID() do
		status, temp = GetBattlefieldStatus(i)
		if status == "active" then
			activeBg = temp
			if temp == "奥特兰克山谷" then
				pattern = "(%d+)"
			elseif temp == "冬拥湖" then
				--冬拥湖暂时不显示比分（只有载具数量）
				return
			else
				pattern = "(%d+)/(.+)"
			end
			if scoreText[1] then
				allianceScoreText:SetText(scoreText[1]:match(pattern))
			else
				allianceScoreText:SetText(nil)
			end

			if scoreText[2] then	
				hordeScoreText:SetText(scoreText[2]:match(pattern))
			else
				hordeScoreText:SetText(nil)
			end
		end
	end
end
	
TFScore:SetScript("OnEvent", function(a1,event,a2)
	if(event=="UPDATE_BATTLEFIELD_SCORE") and tfinit then
		updateHorde()
		updateAlliance()
		updateMisc()
	end
	
	if(event=="UPDATE_UI_WIDGET" or event == "UPDATE_BATTLEFIELD_STATUS") and tfinit then
		updateScores()	
	end
end)

TFScore:RegisterEvent"UPDATE_BATTLEFIELD_SCORE"
TFScore:RegisterEvent"UPDATE_UI_WIDGET"
TFScore:RegisterEvent"UPDATE_BATTLEFIELD_STATUS"

BINDING_HEADER_TFKB = "TF Scoreboard"
BINDING_NAME_TFONDOWN = "show while held down"
BINDING_NAME_TFTOGGLE = "toggle"