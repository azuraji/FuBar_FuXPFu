local dewdrop = AceLibrary("Dewdrop-2.0")
local tablet = AceLibrary("Tablet-2.0")

local jostle = AceLibrary:HasInstance("Jostle-2.0") and AceLibrary("Jostle-2.0") or nil
local crayon = AceLibrary:HasInstance("Crayon-2.0") and AceLibrary("Crayon-2.0") or nil

FuXP = AceLibrary("AceAddon-2.0"):new("FuBarPlugin-2.0", "AceDB-2.0", "AceEvent-2.0", "AceConsole-2.0", "AceHook-2.1")

local defaults = {
	FuBarFactionLink = false,
	TekAutoRepLink = false,
	WatchedFaction = false,
	Faction = 0,
	ShowText = "None",
	ShowRep = false,
	ShowXP = true,
	Shadow = true,
	Thickness = 2,
	Spark = 1,
	Spark2 = 1,
	ToGo = true,
	BorderTop = true,
	XP = {0, 0.4,.9,1},
	Rest = {1, 0.2, 1, 1},
	None = {0.3, 0.3, 0.3, 0},
	Rep = {
		0.0549019607843137, -- [1]
		0.631372549019608, -- [2]
		0.184313725490196, -- [3]
	},
	ParagonRep = {0.7, 0.84, 0.97, 1},
	NoRep = {
		0, -- [1]
		0.298039215686275, -- [2]
		0, -- [3]
		0, -- [4]
	}
}

local L = AceLibrary("AceLocale-2.2"):new("FuXP")

function FuXP:GetXPColor()
	return self.db.profile.XP[1], self.db.profile.XP[2], self.db.profile.XP[3], self.db.profile.XP[4]
end

function FuXP:SetXPColor(r, g, b, a)
	self.db.profile.XP = {r, g, b, a}
	self.XPBarTex:SetVertexColor(r, g, b, a)
	self.Spark:SetVertexColor(r, g, b, a)
end

function FuXP:GetRepColor()
	return self.db.profile.Rep[1], self.db.profile.Rep[2], self.db.profile.Rep[3], self.db.profile.Rep[4]
end

function FuXP:SetRepColor(r, g, b, a)
	self.db.profile.Rep = {r, g, b, a}
	self.RepBarTex:SetVertexColor(r, g, b, a)
	self.RepSpark:SetVertexColor(r, g, b, a)
end

function FuXP:GetNoRepColor()
	return self.db.profile.NoRep[1], self.db.profile.NoRep[2], self.db.profile.NoRep[3], self.db.profile.NoRep[4]
end

function FuXP:SetNoRepColor(r, g, b, a)
	self.db.profile.NoRep = {r, g, b, a}
	self.NoRepTex:SetVertexColor(r, g, b, a)
end

function FuXP:GetRestColor()
	return self.db.profile.Rest[1], self.db.profile.Rest[2], self.db.profile.Rest[3], self.db.profile.Rest[4]
end

function FuXP:SetRestColor(r, g, b, a)
	self.db.profile.Rest = {r, g, b, a}
	self.RestedXPTex:SetVertexColor(r, g, b, a)
end

function FuXP:GetNoXPColor()
	return self.db.profile.None[1], self.db.profile.None[2], self.db.profile.None[3], self.db.profile.None[4]
end

function FuXP:SetNoXPColor(r, g, b, a)
	self.db.profile.None = {r, g, b, a}
	self.NoXPTex:SetVertexColor(r, g, b, a)
end

function FuXP:SetupMenu()
	FuXP:QueryFactions()
	local optionsTable = {
	type = 'group',
	args = {
		colours = {
			type = 'group',
			name = L["Colours"],
			desc = L["Set the Bar Colours"],
			args = {
				currentXP = {
					type = "color",
					name = L["Current XP"],
					desc = L["Sets the color of the XP Bar"],
					hasAlpha = true,
					get = "GetXPColor",
					set = "SetXPColor",
					order = 110,
				},
				restedXP = {
					type = 'color',
					name = L["Rested XP"],
					desc = L["Sets the color of the Rested Bar"],
					hasAlpha = true,
					get = "GetRestColor",
					set = "SetRestColor",
					order = 111,
				},
				color = {
					type = 'color',
					name = L["No XP"],
					desc = L["Sets the empty color of the XP Bar"],
					hasAlpha = true,
					get = "GetNoXPColor",
					set = "SetNoXPColor",
					order = 112,
				},
				rep = {
					type = 'color',
					name = L["Reputation"],
					desc = L["Sets the color of the Rep Bar"],
					hasAlpha = true,
					get = "GetRepColor",
					set = "SetRepColor",
					order = 113,
				},
				norep = {
					type = 'color',
					name = L["No Rep"],
					desc = L["Sets the empty color of the Reputation Bar"],
					hasAlpha = true,
					get = "GetNoRepColor",
					set = "SetNoRepColor",
					order = 114,
				},
			},
		},
		properties = {
			type = 'group',
			name = L["Properties"],
			desc = L["Set the Bar Properties"],
			args = {
				spark = {
					type = 'range',
					name = L["Spark intensity"],
					desc = L["Brightness level of Spark"],
					get = function() return FuXP.db.profile.Spark end,
					set = function(v) 
						FuXP.db.profile.Spark = v
						FuXP.Spark:SetAlpha(v)
						FuXP.Spark2:SetAlpha(v)
						FuXP.RepSpark:SetAlpha(v)
						FuXP.RepSpark2:SetAlpha(v)
					end,
					min = 0,
					max = 1,
					step = 0.01,
					bigStep = 0.05,
					order = 115
				},
				thickness = {
					type = 'range',
					name = L["Thickness"],
					desc = L["Sets thickness of XP Bar"],
					get = function() return FuXP.db.profile.Thickness end,
					set = function(v)
						FuXP:SetThickness(v)
					end,
					min = 1.5,
					max = 8,
					step = 0.1,
					order = 116
				},
				shadow = {
					type = 'toggle',
					name = L["Shadow"],
					desc = L["Toggles Shadow under XP Bar"],
					get = function() return FuXP.db.profile.Shadow end,
					set = function()
						FuXP.db.profile.Shadow = not FuXP.db.profile.Shadow
						if FuXP.db.profile.Shadow then
							FuXP.Border:Show()
						else
							FuXP.Border:Hide()
						end
					end,
					order = 117
				},
				showxp = {
					type = 'toggle',
					name = L["Show XP Bar"],
					desc = L["Show the XP Bar"],
					get = function() return FuXP.db.profile.ShowXP end,
					set = function()
						FuXP.db.profile.ShowXP = not FuXP.db.profile.ShowXP
						FuXP:Reanchor()
					end,
					order = 119
				},
				showrep = {
					type = 'toggle',
					name = L["Show Rep Bar"],
					desc = L["Show the Reputation Bar"],
					get = function() return FuXP.db.profile.ShowRep end,
					set = function()
						FuXP.db.profile.ShowRep = not FuXP.db.profile.ShowRep
						FuXP:Reanchor()
					end,
					order = 120
				},
				undocked = {
					type = 'text',
					usage = '<'..L['Location']..'>',
					name = L["Undocked Position"],
					desc = L["Selects which side of an undocked panel you want the bars on."],
					get = function() return FuXP.db.profile.UndockedLoc end,
					set = function(loc) 
						FuXP.db.profile.UndockedLoc = loc
						FuXP:Reanchor()
					end,
					validate = { ["Top"] = L["Top"], ["Bottom"] = L["Bottom"] },
					order = 123,
				}
			},
		},
		faction = {
			type = 'text',
			usage = '<'.. L["Faction"].. '>',
			name = L["Faction"],
			desc = L["Select Faction"],
			get = function() 
					return tostring(self.db.profile.Faction) 
				end,
			set = function(v) 
					self.db.profile.Faction = tostring(v); 
					SetWatchedFactionIndex(tonumber(v));	
				end,
			validate = FuXP.FactionTable, 
			order = 121,
		},
		showtext = {
			type = 'text',
			usage = '<'..L["None||Rep||XP"]..'>',
			name = L["Show Text"],
			desc = L["Show the XP or Rep"],
			get = function() return FuXP.db.profile.ShowText end,
			set = function(show)
					FuXP.db.profile.ShowText = show;
          FuXP:OnTextUpdate();
				end,
			validate = { ["XP"] = L["XP"], ["Rep"] = L["Rep"], ["None"] = L["None"] },
			order = 122
		},
		togo = {
			type = 'toggle',
			name = L["XP to go"],
			desc = L["Show XP to go"],
			get  = function() return self.db.profile.ToGo end,
			set  = function() self.db.profile.ToGo = not self.db.profile.ToGo; self:UpdateText() end,
			order = 123
		},
	}
}

	FuXP.OnMenuRequest = optionsTable
	FuXP:RegisterChatCommand(L["AceConsole-commands"], optionsTable)
end

	FuXP.hasIcon = true
	FuXP.cannotDetachTooltip = true
	FuXP.defaultPosition = "CENTER"
	FuXP.hideWithoutStandby = true
	FuXP.cannotAttachToMinimap = true
	FuXP.independentProfile = true

function FuXP:OnInitialize()
	self.version = "3.".. string.sub("$Revision: 61204 $", 12, -3)
	self:RegisterDB("FuXPDB")
	self:RegisterDefaults('profile', defaults)
	self:SetupMenu()

	local XPBar = CreateFrame("Frame", "FuXPBar", UIParent)
	local tex = XPBar:CreateTexture("XPBarTex")
	-- XPBar:SetFrameStrata("MEDIUM")
	tex:SetTexture("Interface\\AddOns\\FuBar_FuXPFu\\Textures\\texture.tga")
	tex:SetVertexColor(self.db.profile.XP[1], self.db.profile.XP[2], self.db.profile.XP[3], self.db.profile.XP[4])
	tex:ClearAllPoints()
	tex:SetAllPoints(XPBar)
	tex:Show()
	XPBar:SetHeight(self.db.profile.Thickness)
	
	local spark = XPBar:CreateTexture("XPSpark", "OVERLAY")
	spark:SetTexture("Interface\\AddOns\\FuBar_FuXPFu\\Textures\\glow.tga")
	spark:SetWidth(128)
	spark:SetHeight(self.db.profile.Thickness * 8)
  spark:SetVertexColor(self.db.profile.XP[1], self.db.profile.XP[2], self.db.profile.XP[3], self.db.profile.Spark or 1)
	spark:SetBlendMode("ADD")

	local spark2 = XPBar:CreateTexture("XPSpark2", "OVERLAY")
	spark2:SetTexture("Interface\\AddOns\\FuBar_FuXPFu\\Textures\\glow2.tga")
	spark2:SetWidth(128)
	spark2:SetAlpha(self.db.profile.Spark or 1)
	spark2:SetHeight((self.db.profile.Thickness) * 8)
	spark2:SetBlendMode("ADD")

	local RestedXP = CreateFrame("Frame", "FuRestXPBar", UIParent)
	local restex = RestedXP:CreateTexture("RestedXPTex")
	restex:SetTexture("Interface\\AddOns\\FuBar_FuXPFu\\Textures\\texture.tga")
  restex:SetVertexColor(self.db.profile.Rest[1], self.db.profile.Rest[2], self.db.profile.Rest[3], self.db.profile.Rest[4])
	restex:ClearAllPoints()
	restex:Show()
	restex:SetAllPoints(RestedXP)
	RestedXP:SetHeight(self.db.profile.Thickness)

	local NoXP = CreateFrame("Frame", "FuNoXPBar", UIParent)
	local notex = NoXP:CreateTexture("NoXPTex")
	notex:SetTexture("Interface\\AddOns\\FuBar_FuXPFu\\Textures\\texture.tga")
  notex:SetVertexColor(self.db.profile.None[1], self.db.profile.None[2], self.db.profile.None[3], self.db.profile.None[4])
	notex:ClearAllPoints()
	notex:Show()
	notex:SetAllPoints(NoXP)
	NoXP:SetHeight(self.db.profile.Thickness)
	
	local Rep = CreateFrame("Frame", "FuRepBar", UIParent)
	-- Rep:SetFrameStrata("BACKGROUND")
	local reptex = Rep:CreateTexture("RepTex", "BACKGROUND")
	reptex:SetTexture("Interface\\AddOns\\FuBar_FuXPFu\\Textures\\texture.tga")
  reptex:SetVertexColor(self.db.profile.Rep[1], self.db.profile.Rep[2], self.db.profile.Rep[3], self.db.profile.Rep[4])
	reptex:ClearAllPoints()
	reptex:Show()
	reptex:SetAllPoints(Rep)
	Rep:SetHeight(self.db.profile.Thickness)

	local rspark = Rep:CreateTexture("RepSpark", "OVERLAY")
	rspark:SetTexture("Interface\\AddOns\\FuBar_FuXPFu\\Textures\\glow.tga")
	rspark:SetWidth(128)
	rspark:SetHeight((self.db.profile.Thickness) * 8)
  rspark:SetVertexColor(self.db.profile.Rep[1], self.db.profile.Rep[2], self.db.profile.Rep[3], self.db.profile.Spark or 1)
	rspark:SetBlendMode("ADD")

	local rspark2 = Rep:CreateTexture("RepSpark2", "OVERLAY")
	rspark2:SetTexture("Interface\\AddOns\\FuBar_FuXPFu\\Textures\\glow2.tga")
	rspark2:SetWidth(128)
	rspark2:SetAlpha(self.db.profile.Spark or 1)
	rspark2:SetHeight((self.db.profile.Thickness) * 8)
	rspark2:SetBlendMode("ADD")

	local NoRep = CreateFrame("Frame", "FuNoRepBar", UIParent)
	local noreptex = NoRep:CreateTexture("NoRepTex")
	noreptex:SetTexture("Interface\\AddOns\\FuBar_FuXPFu\\Textures\\texture.tga")
  noreptex:SetVertexColor(self.db.profile.NoRep[1], self.db.profile.NoRep[2], self.db.profile.NoRep[3], self.db.profile.NoRep[4])
	noreptex:ClearAllPoints()
	noreptex:Show()
	noreptex:SetAllPoints(NoRep)
	NoRep:SetHeight(self.db.profile.Thickness)

	--Rep:SetFrameLevel(2)
	Rep:SetFrameLevel(NoRep:GetFrameLevel() + 1) -- An attempt to fix the spark...

	local Border = CreateFrame("Frame", "BottomBorder", UIParent)
	local bordtex = Border:CreateTexture("BottomBorderTex")
	bordtex:SetTexture("Interface\\AddOns\\FuBar_FuXPFu\\Textures\\border.tga")
	bordtex:SetVertexColor(0, 0, 0, 1)
	bordtex:ClearAllPoints()
	bordtex:SetAllPoints(Border)
	Border:SetHeight(5)

	if not self.db.profile.Shadow then
		Border:Hide()
	end


	self.XPBar = XPBar
	self.XPBarTex = tex
	self.Spark = spark
	self.Spark2 = spark2
	self.NoXP = NoXP
	self.NoXPTex = notex
	self.RestedXP = RestedXP
	self.RestedXPTex = restex
	self.RepBar = Rep
	self.RepBarTex = reptex
	self.RepSpark = rspark
	self.RepSpark2 = rspark2
	self.NoRep = NoRep
	self.NoRepTex = noreptex
	self.Border = Border
	self.BorderTex = bordtex
	self.Spark:SetParent(self.XPBar)
	self.Spark2:SetParent(self.XPBar)
	self.RestedXP:SetParent(self.XPBar)
	self.NoXP:SetParent(self.XPBar)
	self.RepBar:SetParent(self.XPBar)
	self.RepSpark:SetParent(self.RepBar)
	self.RepSpark2:SetParent(self.RepBar)
	self.NoRep:SetParent(self.RepBar)
	self.Border:SetParent(self.XPBar)
end

function FuXP:OnProfileEnable()
	self:SetupMenu()
end

function FuXP:OnEnable()
	self:RegisterBucketEvent("UPDATE_EXHAUSTION", 60, "Update")
    self:RegisterEvent("PLAYER_UPDATE_RESTING", "CheckIcon")
	-- self:RegisterEvent("PLAYER_LEVEL_UP", "OnLevelUp")
	self:RegisterEvent("PLAYER_XP_UPDATE", "OnTextUpdate")

	self:RegisterEvent("UPDATE_FACTION", "OnTextUpdate")
	self:SecureHook("SetWatchedFactionIndex", "UpdateInABit");
	self:ScheduleRepeatingEvent("XPFuBar", self.Reanchor, 1, self)
	self:ScheduleRepeatingEvent("XPFuRep", self.GetRep, 3, self)

	self:SetupMenu()
end
function FuXP:GetRep()
	if not self.FactionTable or #self.FactionTable == 0 then
		self:QueryFactions()
	else
		self:CancelScheduledEvent("XPFuRep")
	end
end

function FuXP:UpdateInABit(index)
	
	if(not index) then index = self.db.profile.Faction end

	if index == 0 then
		self.db.profile.Faction = 0
		self.db.profile.ShowRep = false;
		self:Update()
		return
	end
	self.db.profile.Faction = index;
	self:ScheduleEvent(function() FuXP:Update() end, 2);
end

function FuXP:CheckIcon()
    if IsResting() then
        self:SetIcon('iconrest.tga')
    else
        self:SetIcon(true)
    end
end

function FuXP:OnDisable()
	self:HideBar()
	-- MainMenuExpBar:Show()
	-- ReputationWatchBar:Show()
	-- ExhaustionTick:Show()
end

function FuXP:FuBar_ChangedPanels()
	if self.Loaded then
		self:Reanchor()
		self:SetupMenu()
	end
end

function FuXP:Reanchor()
	local point, relpoint, y

	if self.db.profile.hidden or self.panel and self.panel["GetAttachPoint"] then 
		self:CancelScheduledEvent("XPFuBar") 
	else
		return
	end

	self.Loaded = true
	self.Panel = self.db.profile.hidden and (FuBar:GetTopmostBottomPanel() or FuBar:GetBottommostTopPanel()) or self.panel 
	if not self.Panel then
		self.Panel = self.panel
	end

	if self.Panel:GetAttachPoint() == "BOTTOM" then
		self.Side = "BOTTOM"
		self.FuPanel = FuBar:GetTopmostBottomPanel()
		point = "BOTTOMLEFT"
		relpoint = "TOPLEFT"
		self.BorderTex:SetTexCoord(1,0,1,0)
		if jostle then
			jostle:RegisterBottom(self.XPBar)
			jostle:RegisterBottom(self.RepBar)
		end
		y = 1
	elseif self.Panel:GetAttachPoint() == "TOP" then
		self.Side = "TOP"
		self.FuPanel = FuBar:GetBottommostTopPanel()
		point = "TOPLEFT"
		relpoint = "BOTTOMLEFT"
		self.BorderTex:SetTexCoord(1,0,0,1)
		if jostle then
			jostle:RegisterTop(self.XPBar)
			jostle:RegisterTop(self.RepBar)
		end
		y = -1
	else
		if FuXP.db.profile.UndockedLoc == "Top" then
			self.Side = "BOTTOM"
			point = "BOTTOMLEFT"
			relpoint = "TOPLEFT"
			self.BorderTex:SetTexCoord(1,0,1,0)
			y = 1
		else
			self.Side = "TOP"
			point = "TOPLEFT"
			relpoint = "BOTTOMLEFT"
			self.BorderTex:SetTexCoord(1,0,0,1)
			y = -1
		end
		if jostle then
			jostle:Unregister(self.XPBar)
			jostle:Unregister(self.RepBar)
		end
	end
	if not self.FuPanel then
		self.FuPanel = self.panel
	end
	self.XPBar:ClearAllPoints()
	self.Spark:ClearAllPoints()
	self.NoXP:ClearAllPoints()
	self.Spark2:ClearAllPoints()
	self.RestedXP:ClearAllPoints()

	self.RepBar:ClearAllPoints()
	self.NoRep:ClearAllPoints()
	self.RepSpark:ClearAllPoints()
	self.RepSpark2:ClearAllPoints()

	self.Border:ClearAllPoints()
	if self.db.profile.ShowXP then
		self.XPBar:SetParent(self.FuPanel.frame)
		self.XPBar:SetPoint(point, self.FuPanel.frame, relpoint, 0, 0)
		self.Spark:SetPoint("RIGHT", self.XPBar, "RIGHT",11,0)
		self.Spark2:SetPoint("RIGHT", self.XPBar, "RIGHT",11,0)
		self.RestedXP:SetPoint("LEFT", self.XPBar, "RIGHT")
		self.NoXP:SetPoint("LEFT", self.RestedXP, "RIGHT")
	end
	if self.db.profile.ShowRep then
		if self.db.profile.ShowXP then
			self.RepBar:SetParent(self.FuPanel.frame)

			if UnitLevel("player") ~= MAX_PLAYER_LEVEL then
				self.RepBar:SetPoint(point, self.FuPanel.frame, relpoint, 0, y * self.XPBar:GetHeight())
			else
				self.RepBar:SetPoint(point, self.FuPanel.frame, relpoint, 0, y * self.XPBar:GetHeight() - 2)
			end
		else
			self.RepBar:SetParent(self.FuPanel.frame)
			self.RepBar:SetPoint(point, self.FuPanel.frame, relpoint, 0, 0)
		end
		self.NoRep:SetPoint("LEFT", self.RepBar, "RIGHT")
		self.RepSpark:SetPoint("RIGHT", self.RepBar, "RIGHT", 11, 0)
		self.RepSpark2:SetPoint("RIGHT", self.RepBar, "RIGHT", 11, 0)
	end
	self.Border:SetParent(self.db.profile.ShowRep and self.RepBar or self.XPBar)
	self.Border:SetPoint(point, self.db.profile.ShowRep and self.RepBar or self.XPBar, relpoint)
	self.RepBar:SetFrameLevel(self.NoRep:GetFrameLevel() + 1)
	self:ShowBar()
	self:UpdateData()
	if jostle then jostle:Refresh() end
end

function FuXP:ShowBar()
	self:HideBar()	
	if self.db.profile.ShowXP == true then
		self.XPBar:Show()
		self.Spark:Show()
		self.Spark2:Show()
		self.RestedXP:Show()
		self.NoXP:Show()
	end
	if self.db.profile.Shadow == true then
		self.Border:Show()
	end
	if self.db.profile.ShowRep == true then
		self.RepBar:Show()
		self.RepSpark:Show()
		self.RepSpark2:Show()
		self.NoRep:Show()
	end
end

function FuXP:HideBar()
	self.XPBar:Hide()
	self.Spark:Hide()
	self.Spark2:Hide()
	self.RestedXP:Hide()
	self.NoXP:Hide()
	self.Border:Hide()
	self.RepBar:Hide()
	self.RepSpark:Hide()
	self.RepSpark2:Hide()
	self.NoRep:Hide()
end

function FuXP:SetThickness(thickness)
	self.XPBar:SetHeight(thickness)
	self.Spark:SetHeight((thickness) * 8)
	self.Spark2:SetHeight((thickness) * 8)
	self.RestedXP:SetHeight(thickness)
	self.NoXP:SetHeight(thickness)
	self.RepBar:SetHeight(thickness)
	self.RepSpark:SetHeight((thickness) * 8)
	self.RepSpark2:SetHeight((thickness) * 8)
	self.NoRep:SetHeight(thickness)
	self.db.profile.Thickness = thickness
	self:Reanchor()
	if jostle then jostle:Refresh() end
end

function FuXP:OnDataUpdate()
	if not self.Panel then return end

	local name, standing, minRep, maxRep, currentRep, factionID = GetWatchedFactionInfo()
	local total = self.Panel.frame:GetWidth()
	
	local currentRepParagon, maxRepParagon = C_Reputation.GetFactionParagonInfo(factionID)

	if currentRepParagon ~= nil then
		minRep = 0
		maxRep = maxRepParagon
		currentRep = currentRepParagon % maxRepParagon

    self.RepBarTex:SetVertexColor(self.db.profile.ParagonRep[1], self.db.profile.ParagonRep[2], self.db.profile.ParagonRep[3], self.db.profile.ParagonRep[4])
    self.RepSpark:SetVertexColor(self.db.profile.ParagonRep[1], self.db.profile.ParagonRep[2], self.db.profile.ParagonRep[3], self.db.profile.ParagonRep[4])
	else
    self.RepBarTex:SetVertexColor(self.db.profile.Rep[1], self.db.profile.Rep[2], self.db.profile.Rep[3], self.db.profile.Rep[4])
    self.RepSpark:SetVertexColor(self.db.profile.Rep[1], self.db.profile.Rep[2], self.db.profile.Rep[3], self.db.profile.Spark or 1)
	end

	if self.db.profile.ShowRep == true then
		local repBarWidth = ((currentRep - minRep)/(maxRep-minRep))*total
		if repBarWidth == 0 then
			repBarWidth = 0.1
		end

		self.RepBar:SetWidth(repBarWidth)
		self.NoRep:SetWidth(((maxRep - currentRep)/(maxRep - minRep))*total)
	end
	
	self.XPBar:Hide()
	self.RestedXP:Hide()
	self.NoXP:Hide()
	self.Border:Hide()

	if self.db.profile.ShowXP == true and UnitLevel("player") ~= MAX_PLAYER_LEVEL then
		local currentXP = UnitXP("player")
		local maxXP = UnitXPMax("player")
		local restXP = GetXPExhaustion() or 0
		local remainXP = maxXP - (currentXP + restXP)
		
		if remainXP < 0 then
			remainXP = 0
		end

		self.XPBar:SetWidth((currentXP / maxXP) * total)
		if (restXP + currentXP) / maxXP > 1 then
			self.RestedXP:SetWidth(total - self.XPBar:GetWidth())
		else
			self.RestedXP:SetWidth((restXP / maxXP) * total + 0.001)
		end
		self.NoXP:SetWidth((remainXP / maxXP) * total)

		self.XPBar:Show()
		self.RestedXP:Show()
		self.NoXP:Show()
		self.Border:Show()
	end
end

-- function FuXP:OnLevelUp(newLevel)
-- 	if self.db.profile.ShowXP == true and newLevel == MAX_PLAYER_LEVEL then
-- 		self.XPBar:Hide()
-- 		self.Spark:Hide()
-- 		self.Spark2:Hide()
-- 		self.RestedXP:Hide()
-- 		self.NoXP:Hide()
-- 	end
-- end

function FuXP:OnTextUpdate()
	FuXP:OnDataUpdate()
	-- Setup watched factions
	if self.db.profile.ShowText == "Rep" and self.db.profile.Faction ~= 0 then
		local name, standing, minRep, maxRep, currentRep, factionID = GetWatchedFactionInfo()
		if standing <= 0 then return end -- 'Unknown' usually means that the player just started their character and aren't tracking any faction

		local max, xp = UnitXPMax("player"), UnitXP("player")
		local toGo = max - xp

		-- Paragon Reputation introduced in Legion:
		-- https://wow.gamepedia.com/Reputation#Paragon
		-- https://wow.gamepedia.com/API_C_Reputation.GetFactionParagonInfo

		local currentRepParagon, maxRepParagon = C_Reputation.GetFactionParagonInfo(factionID)

		local factionStandingLabel = _G["FACTION_STANDING_LABEL"..standing]

		if currentRepParagon ~= nil then
			minRep = 0
			maxRep = maxRepParagon
			currentRep = currentRepParagon % maxRepParagon

			factionStandingLabel = "|cffB2D7F7Paragon"
		else
			local standingColor

			if standing == 1 then
				standingColor = "|cffcc2222" --Hated
			elseif standing == 2 then
				standingColor = "|cffff0000" --Hostile
			elseif standing == 3 then
				standingColor = "|cffee6622" --Unfriendly
			elseif standing == 4 then
				standingColor = "|cffD1BB48" --Neutral
			elseif standing == 5 then
				standingColor = "|cff00ff00" --Friendly
			elseif standing == 6 then
				standingColor = "|cff00ff88" --Honored
			elseif standing == 7 then
				standingColor = "|cff00ffcc" --Revered
			elseif standing == 8 then
				standingColor = "|cff00ffff" --Exalted
			end

			factionStandingLabel = standingColor..factionStandingLabel
		end

		
		if name then
			if UnitLevel("player") == MAX_PLAYER_LEVEL then
				self:SetText(string.format(L["%s: %3.0f%% (%s/%s)  (%s)"], name, ((currentRep-minRep)/(maxRep-minRep))*100 , currentRep-minRep, maxRep-minRep, factionStandingLabel.."|r"))
			else
				self:SetText(string.format(L["%s: %3.0f%% (%s/%s)  (%s) // XP: %s%%/%s to go"], name, ((currentRep-minRep)/(maxRep-minRep))*100 , currentRep-minRep, maxRep-minRep, factionStandingLabel.."|r", math.floor(xp/max * 100), toGo))
			end
		end
	elseif self.db.profile.ShowText == "XP" then
			local max, xp = UnitXPMax("player"), UnitXP("player")
			local toGo = max - xp
			local percentToGo = math.floor(toGo / max * 100)
			if crayon then
					toGo = "|cff"..crayon:GetThresholdHexColor(toGo, 0) .. toGo .. "|r"
					percentToGo = "|cff"..crayon:GetThresholdHexColor(percentToGo) .. percentToGo .. "|r"
			end
			if self.db.profile.ToGo then
					self:SetText(string.format("%s (%s%%)", toGo, percentToGo))
			else 
					self:SetText(string.format("%s/%s (%s%%)", xp, max, math.floor(xp/max * 100)))
			end
	else
			self:SetText("FuXPFu")
	end
end

function FuXP:OnTooltipUpdate()
	local totalXP = UnitXPMax("player")
	local currentXP = UnitXP("player")
	local toLevelXP = totalXP - currentXP
	local toLevelXPPercent = math.floor((currentXP / totalXP) * 100)
	local xp = tablet:AddCategory(
		'columns', 2
	)

	if self.panel:GetAttachPoint() ~= self.Side then
		self:Reanchor()
	end

	if self.db.profile.ShowXP == true and UnitLevel('player') < MAX_PLAYER_LEVEL then
		if GetXPExhaustion() then
			local xpEx = GetXPExhaustion()
			local xpExPercent
			if xpEx - toLevelXP > 0 then
				xpExPercent = math.floor(((xpEx - toLevelXP) / totalXP) * 100)
			else
				xpExPercent = math.floor((xpEx / totalXP) * 100)
			end
			if crayon then
				-- Scale: 1 - 100
				-- ExXP:  1 - toLevelXP
				xpEx = "|cff"..crayon:GetThresholdHexColor(xpEx, 1, toLevelXP * 0.25, toLevelXP * 0.5, toLevelXP * 0.75, toLevelXP) .. xpEx .. "|r"
				xpExPercent = "|cff"..crayon:GetThresholdHexColor(xpExPercent, 1, 25, 50, 75, 100) .. xpExPercent .. "|r"
			end
			if GetXPExhaustion() - toLevelXP > 0 then
				xpExPercent = "100% + "..xpExPercent
			end
			xp:AddLine(
				'text', L["Rested XP"],
				'text2', string.format("%s (%s%%)", xpEx, xpExPercent)
			)
		end
		if crayon then
			currentXP = "|cff"..crayon:GetThresholdHexColor(currentXP, 1, totalXP * 0.25, totalXP * 0.5, totalXP * 0.75, totalXP) .. currentXP .. "|r"
			toLevelXP = "|cff"..crayon:GetThresholdHexColor(toLevelXP, totalXP, totalXP * 0.75, totalXP * 0.5, totalXP * 0.25, 1) .. toLevelXP .. "|r"
			toLevelXPPercent = "|cff"..crayon:GetThresholdHexColor(toLevelXPPercent, 1, 25, 50, 75, 100) .. toLevelXPPercent .. "|r"
		end
		xp:AddLine(
			'text', L["Current XP"],
			'text2', string.format("%s/%s (%s%%)", currentXP, totalXP, toLevelXPPercent)
		)
		xp:AddLine(
			'text', L["To Level"],
			'text2', toLevelXP
		)
	end
	if self.db.profile.ShowRep == true then
		local name, _, standing, _, maxRep, currentRep, _, _, _, _, _, _, _, factionID = GetFactionInfo(self.db.profile.Faction)
		
		local standingColor

		local currentRepParagon, maxRepParagon = C_Reputation.GetFactionParagonInfo(factionID)

		if currentRepParagon ~= nil then
			maxRep = maxRepParagon
			currentRep = currentRepParagon % maxRepParagon

			standing = "|cffB2D7F7Paragon|r" --Paragon
		else
			if standing == 1 then
				standingColor = "|cffcc2222" --Hated
			elseif standing == 2 then
				standingColor = "|cffff0000" --Hostile
			elseif standing == 3 then
				standingColor = "|cffee6622" --Unfriendly
			elseif standing == 4 then
				standingColor = "|cffD1BB48" --Neutral
			elseif standing == 5 then
				standingColor = "|cff00ff00" --Friendly
			elseif standing == 6 then
				standingColor = "|cff00ff88" --Honored
			elseif standing == 7 then
				standingColor = "|cff00ffcc" --Revered
			elseif standing == 8 then
				standingColor = "|cff00ffff" --Exalted
			end

			standing = standingColor.._G["FACTION_STANDING_LABEL"..standing].."|r"
		end

		xp:AddLine(
			'text', L["Faction"],
			'text2', "|cffFFEBBB"..name.."|r",
			'size2', 13
		)
		xp:AddLine(
			'text', L["Rep to next standing"],
			'text2',"|cffffffff"..(maxRep - currentRep).."|r" ,
			'size2', 12
		)

		xp:AddLine(
			'text', L["Current standing"],
			'text2', standing
		)
	end
	-- local Hint = ""

	-- Hint = L["Click to send your current xp to an open editbox."]
	-- if self.db.profile.Faction ~= 0 then
	-- 	Hint = Hint .."\n"..L["Shift Click to send your current rep to an open editbox."]
	-- end

	-- tablet:SetHint(Hint)
end

function FuXP:OnClick()
	local totalXP = UnitXPMax("player")
	local currentXP = UnitXP("player")
	local toLevelXP = totalXP - currentXP
	local name, desc, standing, minRep, maxRep, currentRep = GetFactionInfo(self.db.profile.Faction)
	local xpEx = GetXPExhaustion() or 0
			local xpExPercent
			if xpEx - toLevelXP > 0 then
				xpExPercent = math.floor(((xpEx - toLevelXP) / totalXP) * 100)
			else
				xpExPercent = math.floor((xpEx / totalXP) * 100)
			end

	if not IsShiftKeyDown() or self.db.profile.Faction == 0 then
		DEFAULT_CHAT_FRAME.editBox:SetText(string.format("%s/%s (%3.0f%%) %d to go (%3.0f%% rested)", currentXP,totalXP, (currentXP/totalXP)*100, totalXP - currentXP, xpExPercent))
	elseif self.db.profile.Faction ~= 0 then
		DEFAULT_CHAT_FRAME.editBox:SetText(string.format("%s: %s/%s (%3.2f%%, %s)",
					name,
					currentRep - minRep,
					maxRep - minRep, 
					(currentRep-minRep)/(maxRep-minRep)*100,
					_G["FACTION_STANDING_LABEL"..standing]))
	end
end

function FuXP:QueryFactions(noupdate)
	if not self.FactionTable then self.FactionTable = {} end;
	local WatchedFaction = GetWatchedFactionInfo();
	for factionIndex = 1, GetNumFactions() do
		local name, _, _, _, _ , _ ,_ , _, isHeader = GetFactionInfo(factionIndex)

		if not isHeader then
			if WatchedFaction == name then
				self.db.profile.Faction = factionIndex;
			end
			self.FactionTable[tostring(factionIndex)] = name
		end
	end
	return self.FactionTable
end
