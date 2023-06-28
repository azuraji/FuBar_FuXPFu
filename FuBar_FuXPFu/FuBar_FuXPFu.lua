local dewdrop = AceLibrary("Dewdrop-2.0")
local tablet = AceLibrary("Tablet-2.0")

local jostle = AceLibrary:HasInstance("Jostle-2.0") and AceLibrary("Jostle-2.0") or nil
local crayon = AceLibrary:HasInstance("Crayon-2.0") and AceLibrary("Crayon-2.0") or nil

FuXP = AceLibrary("AceAddon-2.0"):new("FuBarPlugin-2.0", "AceDB-2.0", "AceEvent-2.0", "AceConsole-2.0", "AceHook-2.1")

local watchedFactionIndex = "0"
local watchedFactionID = 0

local queryFactions = true

local defaults = {
	ShowRep = false,
	ShowXP = true,
	Shadow = true,
	Thickness = 2.4,
	UndockedLoc = "Bottom",
	Spark = 1,
	Spark2 = 1,
	XP = {0, 0.4,.9,1},
	Rest = {1, 0.2, 1, 1},
	None = {
		0.3, 			-- [1]
		0.3, 			-- [2]
		0.3, 			-- [3]
		0 				-- [4]
	},
	NoRep = {
		0, 								 -- [1]
		0.298039215686275, -- [2]
		0, 								 -- [3]
		0, 								 -- [4]
	},
	Rep = {
		0.0549019607843137, -- [1]
		0.631372549019608,  -- [2]
		0.184313725490196,  -- [3]
		0 								  -- [4]
	},
	RenownRep = {0, 0.6901, 0.741176},
	ParagonRep = {0.7, 0.84, 0.97},
	FriendshipRep = {1, 0.870588235, 0.631372549},
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

function FuXP:UpdateFactionMenu()
	if not self.OnMenuRequest then return end

	if queryFactions then
		local factionTable = {}
		local watchedFactionID = select(6, GetWatchedFactionInfo())

		for factionIndex = 1, GetNumFactions() do
			local name, _, _, _, _, _, _, _, isHeader, _, hasRep, _, _, factionID  = GetFactionInfo(factionIndex)

			if not isHeader or hasRep then
				if watchedFactionID == factionID then
					watchedFactionIndex = tostring(factionIndex)
				end

				factionTable[tostring(factionIndex)] = name
			end
		end

		self.OnMenuRequest.args.faction.validate = factionTable
		self.refreshMenu = true
	else
		queryFactions = true
	end
end

function FuXP:SetupMenu()
	local optionsTable = {
		type = 'group',
		args = {
			faction = {
				type = 'text',
				name = "|cff71d5ff" .. L["Watched Faction"] .. "|r",
				desc = L["Select faction to watch"],
				tooltipTitle = L["Watched Faction"],
				get = function()
								return watchedFactionIndex
							end,
				set = function(v)
								SetWatchedFactionIndex(tonumber(v));
							end,
				validate = {},
				order = 120,
			},
			properties = {
				type = 'group',
				name = L["Bar Properties"],
				desc = L["Set the Bar Properties"],
				args = {
					spark = {
						type = 'range',
						name = L["Spark intensity"],
						desc = L["Brightness level of Spark"],
						get = function() return self.db.profile.Spark end,
						set = function(v) 
										self.db.profile.Spark = v
										self:SetSparkAlpha(v)
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
						get = function() return self.db.profile.Thickness end,
						set = function(v)
										self:SetThickness(v)
									end,
						min = 1.5,
						max = 8,
						step = 0.1,
						order = 116
					},
					shadow = {
						type = 'toggle',
						name = L["Shadow"],
						desc = L["Toggles Shadow under the bottommost bar"],
						get = function() return self.db.profile.Shadow end,
						set = function()
										self.db.profile.Shadow = not self.db.profile.Shadow
										self:Reanchor()
									end,
						order = 117
					},
					showxp = {
						type = 'toggle',
						name = L["Show XP Bar"],
						desc = L["Show the XP Bar"],
						get = function() return self.db.profile.ShowXP end,
						set = function()
										self.db.profile.ShowXP = not self.db.profile.ShowXP
										self:Reanchor()
									end,
						order = 119
					},
					showrep = {
						type = 'toggle',
						name = L["Show Rep Bar"],
						desc = L["Show the Rep Bar"],
						get = function() return self.db.profile.ShowRep end,
						set = function()
										self.db.profile.ShowRep = not self.db.profile.ShowRep
										self:Reanchor()
									end,
						order = 120
					},
					undocked = {
						type = 'text',
						name = L["Undocked position"],
						desc = L["Selects which side of an undocked panel you want the bars on."],
						get = function() return self.db.profile.UndockedLoc end,
						set = function(loc)
										self.db.profile.UndockedLoc = loc
										self:Reanchor()
									end,
						validate = { [1] = L["Top"], [2] = L["Bottom"] },
						order = 123,
					}
				},
				order = 121,
			},
			colours = {
				type = 'group',
				name = L["Colors"],
				desc = L["Set the Bar Colors"],
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
						name = L["Rep"],
						desc = L["Sets the color of the Rep Bar"],
						hasAlpha = true,
						get = "GetRepColor",
						set = "SetRepColor",
						order = 113,
					},
					norep = {
						type = 'color',
						name = L["No Rep"],
						desc = L["Sets the empty color of the Rep Bar"],
						hasAlpha = true,
						get = "GetNoRepColor",
						set = "SetNoRepColor",
						order = 114,
					},
				},
				order = 122,
			},
		}
	}

	self.OnMenuRequest = optionsTable
	self:UpdateFactionMenu()

	self:RegisterChatCommand(L["AceConsole-commands"], optionsTable)
end

FuXP.hasIcon = true
FuXP.cannotDetachTooltip = true
FuXP.defaultPosition = "CENTER"
FuXP.hideWithoutStandby = true
FuXP.cannotAttachToMinimap = true
FuXP.independentProfile = true

function FuXP:OnInitialize()
	self:RegisterDB("FuXPDB")
	self:RegisterDefaults('profile', defaults)
	-- self:SetupMenu()

	local RestedXP = CreateFrame("Frame", "FuRestXPBar", UIParent)
	local restex = RestedXP:CreateTexture("RestedXPTex")
	restex:SetTexture("Interface\\AddOns\\FuBar_FuXPFu\\Textures\\texture.tga")
  restex:SetVertexColor(self.db.profile.Rest[1], self.db.profile.Rest[2], self.db.profile.Rest[3], self.db.profile.Rest[4])
	restex:ClearAllPoints()
	restex:SetAllPoints(RestedXP)
	RestedXP:SetHeight(self.db.profile.Thickness)

	local XPBar = CreateFrame("Frame", "FuXPBar", UIParent)
	local tex = XPBar:CreateTexture("XPBarTex")
	tex:SetTexture("Interface\\AddOns\\FuBar_FuXPFu\\Textures\\texture.tga")
	tex:SetVertexColor(self.db.profile.XP[1], self.db.profile.XP[2], self.db.profile.XP[3], self.db.profile.XP[4])
	tex:ClearAllPoints()
	tex:SetAllPoints(XPBar)
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
	spark2:SetHeight((self.db.profile.Thickness) * 8)
	spark2:SetBlendMode("ADD")

	local NoXP = CreateFrame("Frame", "FuNoXPBar", UIParent)
	local notex = NoXP:CreateTexture("NoXPTex")
	notex:SetTexture("Interface\\AddOns\\FuBar_FuXPFu\\Textures\\texture.tga")
  notex:SetVertexColor(self.db.profile.None[1], self.db.profile.None[2], self.db.profile.None[3], self.db.profile.None[4])
	notex:ClearAllPoints()
	notex:SetAllPoints(NoXP)
	NoXP:SetHeight(self.db.profile.Thickness)
	
	local Rep = CreateFrame("Frame", "FuRepBar", UIParent)
	local reptex = Rep:CreateTexture("RepTex", "BACKGROUND")
	reptex:SetTexture("Interface\\AddOns\\FuBar_FuXPFu\\Textures\\texture.tga")
  reptex:SetVertexColor(self.db.profile.Rep[1], self.db.profile.Rep[2], self.db.profile.Rep[3], self.db.profile.Rep[4])
	reptex:ClearAllPoints()
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
	rspark2:SetHeight((self.db.profile.Thickness) * 8)
	rspark2:SetBlendMode("ADD")

	local NoRep = CreateFrame("Frame", "FuNoRepBar", UIParent)
	local noreptex = NoRep:CreateTexture("NoRepTex")
	noreptex:SetTexture("Interface\\AddOns\\FuBar_FuXPFu\\Textures\\texture.tga")
  noreptex:SetVertexColor(self.db.profile.NoRep[1], self.db.profile.NoRep[2], self.db.profile.NoRep[3], self.db.profile.NoRep[4])
	noreptex:ClearAllPoints()
	noreptex:SetAllPoints(NoRep)
	NoRep:SetHeight(self.db.profile.Thickness)

	local Border = CreateFrame("Frame", "BottomBorder", UIParent)
	local bordtex = Border:CreateTexture("BottomBorderTex")
	bordtex:SetTexture("Interface\\AddOns\\FuBar_FuXPFu\\Textures\\border.tga")
	bordtex:SetVertexColor(0, 0, 0, 1)
	bordtex:ClearAllPoints()
	bordtex:SetAllPoints(Border)
	Border:SetHeight(5)


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

	self:RegisterEvent("PLAYER_XP_UPDATE", "OnTextUpdate")
	self:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED", "OnTextUpdate")
	self:RegisterEvent("UPDATE_FACTION", "OnUpdateFaction")
	
	self:SecureHook("SetWatchedFactionIndex");
	self:ScheduleRepeatingEvent("XPFuBar", self.Reanchor, 1, self)

	self:SetupMenu()
end

function FuXP:OnUpdateFaction()
	self:UpdateFactionMenu()
	self:OnTextUpdate()
end

function FuXP:SetWatchedFactionIndex(index)
	queryFactions = false
	if not index then index = 0 end

	watchedFactionIndex = tostring(index)
end

function FuXP:OnHide()
	self:HideBar()
end

function FuXP:OnDisable()
	self:HideBar()
end

function FuXP:FuBar_ChangedPanels()
	if self.Loaded then
		self:Reanchor()
		self:SetupMenu()
	end
end

function FuXP:SetSparkAlpha(alpha)
	self.Spark:SetAlpha(alpha)
	self.Spark2:SetAlpha(alpha)
	self.RepSpark:SetAlpha(alpha)
	self.RepSpark2:SetAlpha(alpha)
end

function FuXP:Reanchor()
	if self.db.profile.hidden or self.panel and self.panel.GetAttachPoint then 
		self:CancelScheduledEvent("XPFuBar")

		if self.db.profile.hidden then return end
	else
		if self.Loaded then
			self:HideBar()
		end

		return
	end

	self.Loaded = true
	self.Panel = self.db.profile.hidden and (FuBar:GetTopmostBottomPanel() or FuBar:GetBottommostTopPanel()) or self.panel 
	if not self.Panel then
		self.Panel = self.panel
	end
	
	self.BorderTex:SetTexCoord(1, 0, 0, 1)
	
	local point, relpoint, y
	if self.Panel:GetAttachPoint() == "BOTTOM" then
		self.Side = "BOTTOM"
		self.FuPanel = FuBar:GetTopmostBottomPanel()
		point = "BOTTOMLEFT"
		relpoint = "TOPLEFT"
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
		if jostle then
			jostle:RegisterTop(self.XPBar)
			jostle:RegisterTop(self.RepBar)
		end
		y = -1
	else
		if self.db.profile.UndockedLoc == "Top" then
			self.Side = "BOTTOM"
			point = "BOTTOMLEFT"
			relpoint = "TOPLEFT"
			y = 1
		else 																			-- Bottom
			self.Side = "TOP"
			point = "TOPLEFT"
			relpoint = "BOTTOMLEFT"
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

	local xpBarYOffset = 7.6
	local barFrameLevel = 200
	local isMaxLevel = UnitLevel("player") == MAX_PLAYER_LEVEL
	if self.db.profile.ShowXP and not isMaxLevel then
		self.XPBar:SetParent(self.FuPanel.frame)

		if self.db.profile.UndockedLoc == "Top" then
			self.XPBar:SetPoint(point, self.FuPanel.frame, relpoint, 0, y * xpBarYOffset - self.db.profile.Thickness)
		else
			self.XPBar:SetPoint(point, self.FuPanel.frame, relpoint, 0, y * xpBarYOffset)
		end

		self.Spark:SetPoint("RIGHT", self.XPBar, "RIGHT", 11, 0)
		self.Spark2:SetPoint("RIGHT", self.XPBar, "RIGHT", 11, 0)
		self.RestedXP:SetPoint("LEFT", self.XPBar, "RIGHT")
		self.NoXP:SetPoint("LEFT", self.RestedXP, "RIGHT")

		self.XPBar:SetFrameLevel(barFrameLevel)
		self.RestedXP:SetFrameLevel(barFrameLevel - 1)

		if self.db.profile.Shadow == true then
			self.Border:SetParent(self.XPBar)
			self.Border:SetPoint("TOPLEFT", self.XPBar, "BOTTOMLEFT")
			self.Border:SetFrameLevel(barFrameLevel - 1)
		end
	end
	if self.db.profile.ShowRep and watchedFactionID ~= 0 then
		self.RepBar:SetParent(self.FuPanel.frame)

		if self.db.profile.UndockedLoc == "Top" then
			self.RepBar:SetPoint(point, self.FuPanel.frame, relpoint, 0, y * xpBarYOffset)
		else
			self.RepBar:SetPoint(point, self.FuPanel.frame, relpoint, 0, y * (xpBarYOffset - self.db.profile.Thickness))
		end

		if self.db.profile.ShowXP and not isMaxLevel then
			self.RepBar:SetFrameLevel(barFrameLevel + 1)

			if self.db.profile.Shadow == true then
				self.Border:SetParent(self.XPBar)
				self.Border:SetPoint("TOPLEFT", self.XPBar, "BOTTOMLEFT")
				self.Border:SetFrameLevel(barFrameLevel)
			end
		else
			self.RepBar:SetFrameLevel(barFrameLevel)

			if self.db.profile.Shadow == true then
				self.Border:SetParent(self.RepBar)
				self.Border:SetPoint("TOPLEFT", self.RepBar, "BOTTOMLEFT")
				self.Border:SetFrameLevel(barFrameLevel - 1)
			end
		end

		self.NoRep:SetPoint("LEFT", self.RepBar, "RIGHT")
		self.NoRep:SetFrameLevel(self.RepBar:GetFrameLevel() - 1)
		self.RepSpark:SetPoint("RIGHT", self.RepBar, "RIGHT", 11, 0)
		self.RepSpark2:SetPoint("RIGHT", self.RepBar, "RIGHT", 11, 0)
	end
	self:SetSparkAlpha(self.db.profile.Spark)

	self:ShowBar()
	self:UpdateData()
	if jostle then jostle:Refresh() end
end

function FuXP:ShowBar()
	self:HideBar()

	if self.db.profile.ShowXP == true and UnitLevel("player") ~= MAX_PLAYER_LEVEL then
		self.XPBar:Show()
		self.Spark:Show()
		self.Spark2:Show()
		self.RestedXP:Show()
		self.NoXP:Show()
	end
	if self.db.profile.Shadow == true then
		self.Border:Show()
	end

	if self.db.profile.ShowRep == true and watchedFactionID ~= 0 then
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
	self.Border:SetHeight(thickness)
	self.db.profile.Thickness = thickness
	self:Reanchor()
	if jostle then jostle:Refresh() end
end

function FuXP:OnDataUpdate()
	if not self.Panel then return end
	local total = self.Panel.frame:GetWidth()

	if self.db.profile.ShowRep == true and watchedFactionID ~= 0 then
		local name, standing, minRep, maxRep, currentRep, factionID = GetWatchedFactionInfo()
		
		local renownReputationData = C_MajorFactions.GetMajorFactionData(factionID)
		local currentRepParagon, maxRepParagon = C_Reputation.GetFactionParagonInfo(factionID)
		local friendshipReputationInfo = C_GossipInfo.GetFriendshipReputation(factionID)

		if renownReputationData ~= nil then																			--Renown
			minRep = 0
			maxRep = renownReputationData.renownLevelThreshold
			currentRep = renownReputationData.renownReputationEarned

			self.RepBarTex:SetVertexColor(self.db.profile.RenownRep[1], self.db.profile.RenownRep[2], self.db.profile.RenownRep[3], 1)
			self.RepSpark:SetVertexColor(self.db.profile.RenownRep[1], self.db.profile.RenownRep[2], self.db.profile.RenownRep[3], self.db.profile.Spark)
		elseif currentRepParagon ~= nil then																		--Paragon
			minRep = 0
			maxRep = maxRepParagon
			currentRep = currentRepParagon % maxRepParagon

			self.RepBarTex:SetVertexColor(self.db.profile.ParagonRep[1], self.db.profile.ParagonRep[2], self.db.profile.ParagonRep[3], self.db.profile.ParagonRep[4])
			self.RepSpark:SetVertexColor(self.db.profile.ParagonRep[1], self.db.profile.ParagonRep[2], self.db.profile.ParagonRep[3], self.db.profile.Spark)
		elseif friendshipReputationInfo and friendshipReputationInfo.friendshipFactionID == factionID then		--Friendship
			minRep = 0
			maxRep = friendshipReputationInfo.nextThreshold and friendshipReputationInfo.nextThreshold - friendshipReputationInfo.reactionThreshold or friendshipReputationInfo.maxRep
			currentRep = maxRep - (friendshipReputationInfo.nextThreshold and friendshipReputationInfo.nextThreshold - friendshipReputationInfo.standing or 0)

			self.RepBarTex:SetVertexColor(self.db.profile.FriendshipRep[1], self.db.profile.FriendshipRep[2], self.db.profile.FriendshipRep[3], self.db.profile.FriendshipRep[4])
			self.RepSpark:SetVertexColor(self.db.profile.FriendshipRep[1], self.db.profile.FriendshipRep[2], self.db.profile.FriendshipRep[3], self.db.profile.Spark)
		else
			self.RepBarTex:SetVertexColor(self.db.profile.Rep[1], self.db.profile.Rep[2], self.db.profile.Rep[3], self.db.profile.Rep[4])
			self.RepSpark:SetVertexColor(self.db.profile.Rep[1], self.db.profile.Rep[2], self.db.profile.Rep[3], self.db.profile.Spark)
		end
		
		local repBarWidth = (maxRep - currentRep == 0 and 1 or ((currentRep - minRep) / (maxRep - minRep)))  * total
		if repBarWidth == 0 then
			repBarWidth = 0.1
		end

		self.RepBar:SetWidth(repBarWidth)
		self.Border:SetWidth(repBarWidth + 4)
		self.NoRep:SetWidth(((maxRep - currentRep) / (maxRep - minRep)) * total)
	end

	if self.db.profile.ShowXP == true and UnitLevel("player") ~= MAX_PLAYER_LEVEL then
		local currentXP = UnitXP("player")
		local maxXP = UnitXPMax("player")
		local restXP = GetXPExhaustion() or 0
		local remainXP = maxXP - (currentXP + restXP)
		
		if remainXP < 0 then
			remainXP = 0
		end

		local xpBarWidth = (currentXP / maxXP) * total

		if xpBarWidth == 0  then xpBarWidth = 0.1 end

		self.XPBar:SetWidth(xpBarWidth)
		self.Border:SetWidth(xpBarWidth)
		if (restXP + currentXP) / maxXP > 1 then
			self.RestedXP:SetWidth(total - self.XPBar:GetWidth())
		else
			self.RestedXP:SetWidth((restXP / maxXP) * total + 0.001)
		end
		self.NoXP:SetWidth((remainXP / maxXP) * total)
	end
end

-- https://stackoverflow.com/a/10990879/633098
local function numWithCommas(n)
	return tostring(math.floor(n)):reverse():gsub("(%d%d%d)","%1,"):gsub(",(%-?)$","%1"):reverse()
end

function FuXP:OnTextUpdate()
	local name, standing, minRep, maxRep, currentRep, factionID = GetWatchedFactionInfo()
	
	watchedFactionID = factionID
	
	self:OnDataUpdate()
	self:Reanchor()

	-- Setup watched factions

	if factionID ~= 0 then			-- 'Unknown' usually means that the player just started their character and aren't tracking any faction
		-- Renown Reputation introduced in Dragonflight:
		-- https://wowpedia.fandom.com/wiki/API_C_MajorFactions.GetMajorFactionData
		
		local renownReputationData = C_MajorFactions.GetMajorFactionData(factionID)

		-- Paragon Reputation introduced in Legion:
		-- https://wow.gamepedia.com/Reputation#Paragon
		-- https://wow.gamepedia.com/API_C_Reputation.GetFactionParagonInfo

		local currentRepParagon, maxRepParagon = C_Reputation.GetFactionParagonInfo(factionID)
		
		-- Friendship Reputation introduced in Mists of Pandaria:
		-- https://wowpedia.fandom.com/wiki/API_C_GossipInfo.GetFriendshipReputation

		local friendshipReputationInfo = C_GossipInfo.GetFriendshipReputation(factionID)
		
		local factionStandingLabel = _G["FACTION_STANDING_LABEL" .. standing]

		if renownReputationData ~= nil then																		--Renown
			minRep = 0
			maxRep = renownReputationData.renownLevelThreshold
			currentRep = renownReputationData.renownReputationEarned

			factionStandingLabel = "|cff00b0bdRenown " .. renownReputationData.renownLevel

			if currentRepParagon ~= nil then																		--Renown + Paragon
				maxRep = maxRepParagon
				currentRep = currentRepParagon % maxRepParagon

				factionStandingLabel = factionStandingLabel .. "|r |cffffffff+|r |cffB2D7F7Paragon"
			end
		elseif currentRepParagon ~= nil then																	--Paragon
			minRep = 0
			maxRep = maxRepParagon
			currentRep = currentRepParagon % maxRepParagon

			factionStandingLabel = "|cffB2D7F7Paragon"
		elseif friendshipReputationInfo and friendshipReputationInfo.friendshipFactionID == factionID then	--Friendship
			minRep = 0
			maxRep = friendshipReputationInfo.nextThreshold and friendshipReputationInfo.nextThreshold - friendshipReputationInfo.reactionThreshold or friendshipReputationInfo.maxRep
			currentRep = maxRep - (friendshipReputationInfo.nextThreshold and friendshipReputationInfo.nextThreshold - friendshipReputationInfo.standing or 0)

			factionStandingLabel = "|cffffdea1" .. friendshipReputationInfo.reaction .. "|r"
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

			factionStandingLabel = standingColor .. factionStandingLabel
		end
		
		if UnitLevel("player") ~= MAX_PLAYER_LEVEL then
			local max, xp = UnitXPMax("player"), UnitXP("player")
			local toGo = max - xp

			if maxRep - currentRep > 0 then
				self:SetText(string.format(L["%s: %3.0f%% (%s/%s)  (%s) // XP: %3.0f%%/%s to go"], name, ((currentRep - minRep) / (maxRep - minRep)) * 100, numWithCommas(currentRep - minRep), numWithCommas(maxRep - minRep), factionStandingLabel .. "|r", math.floor(xp / max * 100), numWithCommas(toGo)))
			else
				self:SetText(string.format(L["%s  (%s) // XP: %3.0f%%/%s to go"], name, factionStandingLabel .. "|r", math.floor(xp / max * 100), numWithCommas(toGo)))
			end
		else
			if currentRep == minRep and minRep == maxRep then -- Max reputation
				self:SetText(string.format("%s  (%s)", name, factionStandingLabel .. "|r"))
			else
				self:SetText(string.format(L["%s: %3.0f%% (%s/%s)  (%s)"], name, ((currentRep - minRep) / (maxRep - minRep)) * 100 , numWithCommas(currentRep - minRep), numWithCommas(maxRep - minRep), factionStandingLabel .. "|r"))
			end
		end
	else
		self:SetText(string.format(L["XP: %3.0f%%/%s to go"], math.floor(xp / max * 100), numWithCommas(toGo)))
	end
end

function FuXP:OnTooltipUpdate()
	local totalXP = UnitXPMax("player")
	local currentXP = UnitXP("player")
	local toLevelXP = totalXP - currentXP
	local toLevelXPPercent = math.floor((currentXP / totalXP) * 100)
	local xpCat = tablet:AddCategory('columns', 2)

	local showXPBar = self.db.profile.ShowXP == true and UnitLevel('player') ~= MAX_PLAYER_LEVEL
	if showXPBar then
		local xpEx, xpExPercent

		if GetXPExhaustion() then
			xpEx = GetXPExhaustion()

			if xpEx - toLevelXP > 0 then
				xpExPercent = math.floor(((xpEx - toLevelXP) / totalXP) * 100)
			else
				xpExPercent = math.floor((xpEx / totalXP) * 100)
			end
			if crayon then
				-- Scale: 1 - 100
				-- ExXP:  1 - toLevelXP
				xpEx = "|cff" .. crayon:GetThresholdHexColor(xpEx, 1, toLevelXP * 0.25, toLevelXP * 0.5, toLevelXP * 0.75, toLevelXP) .. numWithCommas(xpEx) .. "|r"
				xpExPercent = "|cff" .. crayon:GetThresholdHexColor(xpExPercent, 1, 25, 50, 75, 100) .. xpExPercent .. "|r"
			end
			if GetXPExhaustion() - toLevelXP > 0 then
				xpExPercent = "100% + " .. xpExPercent
			end
			
		end
		if crayon then
			currentXP = "|cff"..crayon:GetThresholdHexColor(currentXP, 1, totalXP * 0.25, totalXP * 0.5, totalXP * 0.75, totalXP) .. numWithCommas(currentXP) .. "|r"
			toLevelXP = "|cff"..crayon:GetThresholdHexColor(toLevelXP, totalXP, totalXP * 0.75, totalXP * 0.5, totalXP * 0.25, 1) .. numWithCommas(toLevelXP) .. "|r"
			toLevelXPPercent = "|cff"..crayon:GetThresholdHexColor(toLevelXPPercent, 1, 25, 50, 75, 100) .. toLevelXPPercent .. "|r"
		end
		xpCat:AddLine(
			'text', L["Current XP"],
			'text2', string.format("%s/%s (%s%%)", currentXP, numWithCommas(totalXP), toLevelXPPercent),
			'size2', 11
		)
		xpCat:AddLine(
			'text', L["To level"],
			'text2', toLevelXP,
			'size2', 11
		)
		if (xpEx) then
			xpCat:AddLine(
				'text', L["Rested XP"],
				'text2', string.format("%s (%s%%)", xpEx, xpExPercent),
				'size2', 11
			)
		end
	end

	if self.db.profile.ShowRep == true then
		local _, standing, _, _, _, factionID = GetWatchedFactionInfo()
		
		if standing > 0 then 		-- 'Unknown' usually means that the player just started their character and aren't tracking any faction
			local name, _, _, minRep, maxRep, currentRep = GetFactionInfoByID(factionID)

			local standingColor

			local renownReputationData = C_MajorFactions.GetMajorFactionData(factionID)
			local currentRepParagon, maxRepParagon = C_Reputation.GetFactionParagonInfo(factionID)
			local friendshipReputationInfo = C_GossipInfo.GetFriendshipReputation(factionID)

			if renownReputationData ~= nil then
				maxRep = renownReputationData.renownLevelThreshold
				currentRep = renownReputationData.renownReputationEarned

				standing = "|cff00b0bdRenown " .. renownReputationData.renownLevel .. "|r" --Renown

				if currentRepParagon ~= nil then																					 --Renown + Paragon
					maxRep = maxRepParagon
					currentRep = currentRepParagon % maxRepParagon

					standing = standing .. " |cffffffff+|r |cffB2D7F7Paragon|r"
				end
			elseif currentRepParagon ~= nil then
				maxRep = maxRepParagon
				currentRep = currentRepParagon % maxRepParagon

				standing = "|cffB2D7F7Paragon|r" 																					 --Paragon
			elseif friendshipReputationInfo and friendshipReputationInfo.friendshipFactionID == factionID then
				maxRep = friendshipReputationInfo.nextThreshold and friendshipReputationInfo.nextThreshold - friendshipReputationInfo.reactionThreshold or friendshipReputationInfo.maxRep
				currentRep = maxRep - (friendshipReputationInfo.nextThreshold and friendshipReputationInfo.nextThreshold - friendshipReputationInfo.standing or 0)

				local rankInfo = C_GossipInfo.GetFriendshipReputationRanks(factionID)
				standing = "|cffffdea1" .. friendshipReputationInfo.reaction .. " (" .. rankInfo.currentLevel .. "/" .. rankInfo.maxLevel .. ")|r" 			 --Friendship
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

				standing = standingColor .. _G["FACTION_STANDING_LABEL" .. standing] .. "|r"
			end

			tablet:AddCategory(
				'text', "|cffe3e3e3" .. name .. "|r",
				'justify', 'CENTER',
				'size', 13,
				'hideBlankLine', not showXPBar
			):AddLine('text', '')

			local repCat2 = tablet:AddCategory(
				'columns', 2,
				'hideBlankLine', true
			)
			repCat2:AddLine(
				'text', L["Current standing"],
				'text2', standing
			)
			if maxRep - currentRep > 0 then
				repCat2:AddLine(
					'text', L["Reputation to next standing"],
					'text2', "|cffffffff" .. numWithCommas(maxRep - currentRep) .. "|r",
					'size2', 11
				)
			end

			if renownReputationData ~= nil then
				local repCat3 = tablet:AddCategory()
			
				if renownReputationData.isUnlocked then
					repCat3:AddLine(
						'text', "|cffe8e8e8Click to view |r|cff00b0bdRenown|r",
						'justify', 'CENTER',
						'size', 10
					)
				else
					repCat3:AddLine(
						'text', "|cffff2020To view Renown, " .. string.gsub(renownReputationData.unlockDescription, "^Complete the quest", "complete the quest\n") .. "|r",
						'justify', 'CENTER',
						'size', 10,
						'wrap', true
					)
				end
			elseif friendshipReputationInfo.friendshipFactionID == factionID then
				local repCat3 = tablet:AddCategory()
			
				repCat3:AddLine(
					'text', "|cffffdea1" .. friendshipReputationInfo.text .. "|r",
					'justify', 'CENTER',
					'size', 10,
					'wrap', true
				)
			end
		end
	end
end

function FuXP:OnClick()
	local renownReputationData = C_MajorFactions.GetMajorFactionData(watchedFactionID)
	
	if renownReputationData ~= nil and renownReputationData.isUnlocked then
		tablet:Close()

		MajorFactions_LoadUI();

		if MajorFactionRenownFrame:IsShown() and MajorFactionRenownFrame:GetCurrentFactionID() == watchedFactionID then
			ToggleMajorFactionRenown();
		else
			HideUIPanel(MajorFactionRenownFrame);
			EventRegistry:TriggerEvent("MajorFactionRenownMixin.MajorFactionRenownRequest", watchedFactionID);
			ShowUIPanel(MajorFactionRenownFrame);
		end
	end
end
