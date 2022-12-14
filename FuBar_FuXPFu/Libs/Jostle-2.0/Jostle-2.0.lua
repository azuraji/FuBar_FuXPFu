--[[
Name: Jostle-2.0
Revision: $Rev: 59177 $
Author(s): ckknight (ckknight@gmail.com)
Website: http://ckknight.wowinterface.com/
Documentation: http://wiki.wowace.com/index.php/Jostle-2.0
SVN: http://svn.wowace.com/root/trunk/JostleLib/Jostle-2.0
Description: A library to handle rearrangement of blizzard's frames when bars are added to the sides of the screen.
Dependencies: AceLibrary, AceOO-2.0, AceEvent-2.0
License: LGPL v2.1
]]

local MAJOR_VERSION = "Jostle-2.0"
local MINOR_VERSION = "$Revision: 59177 $"

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end
if not AceLibrary:HasInstance("AceOO-2.0") then error(MAJOR_VERSION .. " requires AceOO-2.0.") end
if not AceLibrary:HasInstance("AceEvent-2.0") then error(MAJOR_VERSION .. " requires AceEvent-2.0.") end

if Rock and Rock:HasLibrary("LibJostle-3.0") then
	return
end

local AceEvent = AceLibrary("AceEvent-2.0")

local Jostle = {}
local blizzardFrames = {
	'PlayerFrame',
	'TargetFrame',
	'MinimapCluster',
	'PartyMemberFrame1',
	'TicketStatusFrame',
	'WorldStateAlwaysUpFrame',
	'MainMenuBar',
	'MultiBarRight',
	'CT_PlayerFrame_Drag',
	'CT_TargetFrame_Drag',
	'Gypsy_PlayerFrameCapsule',
	'Gypsy_TargetFrameCapsule',
	-- 'TemporaryEnchantFrame',
	-- 'DEFAULT_CHAT_FRAME',
	-- 'ChatFrame2',
	'GroupLootFrame1',
	'TutorialFrameParent',
	'FramerateLabel',
	'QuestTimerFrame',
	'DurabilityFrame',
	'CastingBarFrame',
}
local blizzardFramesData = {}

local _G = _G

function Jostle:PLAYER_AURAS_CHANGED()
	self:ScheduleEvent("Jostle-Refresh", self.Refresh, 0, self)
end

function Jostle:AceEvent_FullyInitialized()
	for k,v in pairs(blizzardFramesData) do
		blizzardFramesData[k] = nil
	end
	self:ScheduleEvent("Jostle-Refresh", self.Refresh, 0, self)
end

function Jostle:WorldMapFrame_Hide()
	self:ScheduleEvent("Jostle-Refresh", self.Refresh, 0, self)
end

function Jostle:TicketStatusFrame_OnEvent()
	self:Refresh(TicketStatusFrame, TemporaryEnchantFrame)
end

function Jostle:FCF_UpdateCombatLogPosition()
	self:Refresh(ChatFrame2)
end

function Jostle:UIParent_ManageFramePositions()
	self:Refresh(GroupLootFrame1, TutorialFrameParent, FramerateLabel, QuestTimerFrame, DurabilityFrame)
end

function Jostle:GetScreenTop()
	local bottom = GetScreenHeight()
	for _,frame in ipairs(self.topFrames) do
		if frame.IsShown and frame:IsShown() and frame.GetBottom and frame:GetBottom() and frame:GetBottom() < bottom then
			bottom = frame:GetBottom()
		end
	end
	return bottom
end

function Jostle:GetScreenBottom()
	local top = 0
	for _,frame in ipairs(self.bottomFrames) do
		if frame.IsShown and frame:IsShown() and frame.GetTop and frame:GetTop() and frame:GetTop() > top then
			top = frame:GetTop()
		end
	end
	return top
end

function Jostle:RegisterTop(frame)
	for k,f in ipairs(self.bottomFrames) do
		if f == frame then
			table.remove(self.bottomFrames, k)
			break
		end
	end
	for _,f in ipairs(self.topFrames) do
		if f == frame then
			return
		end
	end
	table.insert(self.topFrames, frame)
	self:Refresh()
	return true
end

function Jostle:RegisterBottom(frame)
	for k,f in ipairs(self.topFrames) do
		if f == frame then
			table.remove(self.topFrames, k)
			break
		end
	end
	for _,f in ipairs(self.bottomFrames) do
		if f == frame then
			return
		end
	end
	table.insert(self.bottomFrames, frame)
	self:Refresh()
	return true
end

function Jostle:Unregister(frame)
	for k,f in ipairs(self.topFrames) do
		if f == frame then
			table.remove(self.topFrames, k)
			self:Refresh()
			return true
		end
	end
	for k,f in ipairs(self.bottomFrames) do
		if f == frame then
			table.remove(self.bottomFrames, k)
			self:Refresh()
			return true
		end
	end
end

function Jostle:IsTopAdjusting()
	return self.topAdjust
end

function Jostle:EnableTopAdjusting()
	if not self.topAdjust then
		self.topAdjust = not self.topAdjust
		self:Refresh()
	end
end

function Jostle:DisableTopAdjusting()
	if self.topAdjust then
		self.topAdjust = not self.topAdjust
		self:Refresh()
	end
end

function Jostle:IsBottomAdjusting()
	return self.bottomAdjust
end

function Jostle:EnableBottomAdjusting()
	if not self.bottomAdjust then
		self.bottomAdjust = not self.bottomAdjust
		self:Refresh()
	end
end

function Jostle:DisableBottomAdjusting()
	if self.bottomAdjust then
		self.bottomAdjust = not self.bottomAdjust
		self:Refresh()
	end
end

local function getsecond(_, value)
	return value
end

local function getthird(_,_,value)
	return value
end

local tmp = {}
local queue = {}
local inCombat = false
function Jostle:ProcessQueue()
	if not inCombat and HasFullControl() then
		for k in pairs(queue) do
			self:Refresh(k)
			queue[k] = nil
		end
	end
end

function Jostle:PLAYER_REGEN_ENABLED()
	inCombat = false
	self:ProcessQueue()
end

function Jostle:PLAYER_REGEN_DISABLED()
	inCombat = true
end

function Jostle:Refresh(...)
	if not AceEvent:IsFullyInitialized() then
		return
	end
	
	local screenHeight = GetScreenHeight()
	local topOffset = self:IsTopAdjusting() and self:GetScreenTop() or screenHeight
	local bottomOffset = self:IsBottomAdjusting() and self:GetScreenBottom() or 0
	if topOffset ~= screenHeight or bottomOffset ~= 0 then
		self:ScheduleEvent("Jostle-Refresh", self.Refresh, 10, self)
	end
	
	local frames
	if select('#', ...) >= 1 then
		for k in pairs(tmp) do
			tmp[k] = nil
		end
		for i = 1, select('#', ...) do
			tmp[i] = select(i, ...)
		end
		frames = tmp
	else
		frames = blizzardFrames
	end

	if inCombat or not HasFullControl() then
		for _,frame in ipairs(frames) do
			if type(frame) == "string" then
				frame = _G[frame]
			end
			if frame then
				queue[frame] = true
			end
		end
		return
	end
	
	local screenHeight = GetScreenHeight()
	for _,frame in ipairs(frames) do
		if type(frame) == "string" then
			frame = _G[frame]
		end

		local framescale = frame and frame.GetScale and frame:GetScale() or 1

		if frame and not blizzardFramesData[frame] and frame.GetTop and frame:GetCenter() and getsecond(frame:GetCenter()) then
			if getsecond(frame:GetCenter()) <= screenHeight / 2 or frame == MultiBarRight then
				blizzardFramesData[frame] = {y = frame:GetBottom(), top = false}
			else
				blizzardFramesData[frame] = {y = frame:GetTop() - screenHeight / framescale, top = true}
			end
		end
	end
	
	for _,frame in ipairs(frames) do
		if type(frame) == "string" then
			frame = _G[frame]
		end

		local framescale = frame and frame.GetScale and frame:GetScale() or 1

		if ((frame and frame.IsUserPlaced and not frame:IsUserPlaced()) or ((frame == DEFAULT_CHAT_FRAME or frame == ChatFrame2) and SIMPLE_CHAT == "1") or frame == FramerateLabel) and (frame ~= ChatFrame2 or SIMPLE_CHAT == "1") then
			local frameData = blizzardFramesData[frame]
			if (getsecond(frame:GetPoint(1)) ~= UIParent and getsecond(frame:GetPoint(1)) ~= WorldFrame) then
				-- do nothing
			elseif frame == PlayerFrame and (CT_PlayerFrame_Drag or Gypsy_PlayerFrameCapsule) then
				-- do nothing
			elseif frame == TargetFrame and (CT_TargetFrame_Drag or Gypsy_TargetFrameCapsule) then
				-- do nothing
			elseif frame == PartyMemberFrame1 and (CT_MovableParty1_Drag or Gypsy_PartyFrameCapsule) then
				-- do nothing
			elseif frame == MainMenuBar and Gypsy_HotBarCapsule then
				-- do nothing
			elseif frame == MinimapCluster and getthird(frame:GetPoint(1)) ~= "TOPRIGHT" then
				-- do nothing
			elseif frame == DurabilityFrame and DurabilityFrame:IsShown() and (DurabilityFrame:GetLeft() > GetScreenWidth() or DurabilityFrame:GetRight() < 0 or DurabilityFrame:GetBottom() > GetScreenHeight() or DurabilityFrame:GetTop() < 0) then
				DurabilityFrame:Hide()
			elseif frame == FramerateLabel and ((frameData.lastX and frameData.lastX ~= frame:GetLeft()) or WorldFrame:GetHeight() * WorldFrame:GetScale() ~= UIParent:GetHeight() * UIParent:GetScale())  then
				-- do nothing
			elseif frame == TemporaryEnchantFrame or frame == CastingBarFrame or frame == TutorialFrameParent or frame == FramerateLabel or frame == QuestTimerFrame or frame == DurabilityFrame or frame == QuestWatchFrame or not (frameData.lastScale and frame.getscale and frameData.lastScale == frame:GetScale()) or not (frameData.lastX and frameData.lastY and (frameData.lastX ~= frame:GetLeft() or frameData.lastY ~= frame:GetTop())) then
				local anchor
				local anchorAlt
				local width, height = GetScreenWidth(), GetScreenHeight()
				local x

				if frame:GetRight() and frame:GetLeft() then
					local anchorFrame = UIParent
					if frame == MainMenuBar or frame == GroupLootFrame1 or frame == FramerateLabel then
						x = 0
						anchor = ""
					elseif frame:GetRight() / framescale <= width / 2 then
						x = frame:GetLeft() / framescale
						anchor = "LEFT"
					else
						x = frame:GetRight() - width / framescale
						anchor = "RIGHT"
					end
					local y = blizzardFramesData[frame].y
					local offset = 0
					if blizzardFramesData[frame].top then
						anchor = "TOP" .. anchor
						offset = ( topOffset - height ) / framescale
					else
						anchor = "BOTTOM" .. anchor
						offset = bottomOffset / framescale
					end
					-- if frame == MinimapCluster and not MinimapBorderTop:IsShown() then
					-- 	offset = offset + MinimapBorderTop:GetHeight() * 3/5
					-- elseif frame == TemporaryEnchantFrame and TicketStatusFrame:IsShown() then
					-- 	offset = offset - TicketStatusFrame:GetHeight() * TicketStatusFrame:GetScale()
					-- elseif frame == DEFAULT_CHAT_FRAME then
					-- 	y = MainMenuBar:GetHeight() * MainMenuBar:GetScale() + 32
					-- 	if PetActionBarFrame:IsShown() or ShapeshiftBarFrame:IsShown() then
					-- 		offset = offset + ShapeshiftBarFrame:GetHeight() * ShapeshiftBarFrame:GetScale()
					-- 	end
					-- 	if MultiBarBottomLeft:IsShown() then
					-- 		offset = offset + MultiBarBottomLeft:GetHeight() * MultiBarBottomLeft:GetScale() - 21
					-- 	end
					-- elseif frame == ChatFrame2 then
					-- 	y = MainMenuBar:GetHeight() * MainMenuBar:GetScale() + 32
					-- 	if MultiBarBottomRight:IsShown() then
					-- 		offset = offset + MultiBarBottomRight:GetHeight() * MultiBarBottomRight:GetScale() - 21
					-- 	end
					if frame == CastingBarFrame then
						y = MainMenuBar:GetHeight() * MainMenuBar:GetScale() + 17
						if PetActionBarFrame:IsShown() or ShapeshiftBarFrame:IsShown() then
							offset = offset + ShapeshiftBarFrame:GetHeight() * ShapeshiftBarFrame:GetScale()
						end
						if MultiBarBottomLeft:IsShown() or MultiBarBottomRight:IsShown() then
							offset = offset + MultiBarBottomLeft:GetHeight() * MultiBarBottomLeft:GetScale()
						end
					elseif frame == GroupLootFrame1 or frame == TutorialFrameParent or frame == FramerateLabel then
						if MultiBarBottomLeft:IsShown() or MultiBarBottomRight:IsShown() then
							offset = offset + MultiBarBottomLeft:GetHeight() * MultiBarBottomLeft:GetScale()
						end
					elseif frame == QuestTimerFrame or frame == DurabilityFrame or frame == QuestWatchFrame then
						anchorFrame = MinimapCluster
						x = 0
						y = 0
						offset = 0
						if frame ~= QuestTimerFrame and QuestTimerFrame:IsShown() then
							y = y - QuestTimerFrame:GetHeight() * QuestTimerFrame:GetScale()
						end
						if frame == QuestWatchFrame and DurabilityFrame:IsShown() then
							y = y - DurabilityFrame:GetHeight() * DurabilityFrame:GetScale()
						end
						if frame == DurabilityFrame then
							x = -20
						end
						anchor = "TOPRIGHT"
						anchorAlt = "BOTTOMRIGHT"
						if MultiBarRight:IsShown() then
							x = x - MultiBarRight:GetWidth() * MultiBarRight:GetScale()
							if MultiBarLeft:IsShown() then
								x = x - MultiBarLeft:GetWidth() * MultiBarLeft:GetScale()
							end
						end
					end
					if frame == FramerateLabel then
						anchorFrame = WorldFrame
					end
					frame:ClearAllPoints()
					frame:SetPoint(anchor, anchorFrame, anchorAlt or anchor, x, y + offset)
					blizzardFramesData[frame].lastX = frame:GetLeft()
					blizzardFramesData[frame].lastY = frame:GetTop()
					blizzardFramesData[frame].lastScale = framescale
				end
			end
		end
	end
end

local function activate(self, oldLib, oldDeactivate)
	Jostle = self
	if oldLib then
		self.hooks = oldLib.hooks
		self.topFrames = oldLib.topFrames
		self.bottomFrames = oldLib.bottomFrames
		self.topAdjust = oldLib.topAdjust
		self.bottomAdjust = oldLib.bottomAdjust
	end
	
	if not self.hooks then
		self.hooks = {}
	end
	if not self.topFrames then
		self.topFrames = {}
	end
	if not self.bottomFrames then
		self.bottomFrames = {}
	end
	if self.topAdjust == nil then
		self.topAdjust = true
	end
	if self.bottomAdjust == nil then
		self.bottomAdjust = true
	end
	
	if not self.hooks.WorldMapFrame_Hide then
		self.hooks.WorldMapFrame_Hide = true
		hooksecurefunc(WorldMapFrame, "Hide", function()
			if self.WorldMapFrame_Hide then
				self:WorldMapFrame_Hide()
			end
		end)
	end
	
	if not self.hooks.TicketStatusFrame_OnEvent then
		self.hooks.TicketStatusFrame_OnEvent = true
		hooksecurefunc("TicketStatusFrame_OnEvent", function()
			if self.TicketStatusFrame_OnEvent then
				self:TicketStatusFrame_OnEvent()
			end
		end)
	end
	
	if not self.hooks.FCF_UpdateDockPosition then
		self.hooks.FCF_UpdateDockPosition = true
		hooksecurefunc("FCF_UpdateDockPosition", function()
			if self.FCF_UpdateDockPosition then
				self:FCF_UpdateDockPosition()
			end
		end)
	end
		
	if not self.hooks.FCF_UpdateCombatLogPosition then
		self.hooks.FCF_UpdateCombatLogPosition = true
		hooksecurefunc("FCF_UpdateCombatLogPosition", function()
			if self.FCF_UpdateCombatLogPosition then
				return self:FCF_UpdateCombatLogPosition()
			end
		end)
	end
	
	if not self.hooks.UIParent_ManageFramePositions then
		self.hooks.UIParent_ManageFramePositions = true
		hooksecurefunc("UIParent_ManageFramePositions", function()
			if self.UIParent_ManageFramePositions then
				return self:UIParent_ManageFramePositions()
			end
		end)
	end
	
	if oldDeactivate then
		oldDeactivate(oldLib)
	end
end

local function external(self, major, instance)
	if major == "AceEvent-2.0" then
		instance:embed(self)

		self:UnregisterAllEvents()
		self:CancelAllScheduledEvents()
		self:RegisterEvent("PLAYER_AURAS_CHANGED")
		if instance:IsFullyInitialized() then
			self:ScheduleEvent("Jostle-Refresh", self.Refresh, 0, self)
		else
			self:RegisterEvent("AceEvent_FullyInitialized")
		end
		
		self:RegisterEvent("PLAYER_REGEN_DISABLED", "PLAYER_REGEN_DISABLED")
		self:RegisterEvent("PLAYER_REGEN_ENABLED", "PLAYER_REGEN_ENABLED")
		self:RegisterEvent("PLAYER_CONTROL_GAINED", "ProcessQueue")
	end
end

AceLibrary:Register(Jostle, MAJOR_VERSION, MINOR_VERSION, activate, nil, external)

