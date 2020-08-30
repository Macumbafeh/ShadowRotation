if select(2, UnitClass("player")) ~= "PRIEST" then
	return
end

local ShadowRotationFrame = CreateFrame("Frame", "ShadowRotationFrame", UIParent)
ShadowRotationFrame:SetPoint("CENTER")
ShadowRotationFrame:SetWidth(175)
ShadowRotationFrame:SetHeight(90)
ShadowRotationFrame:SetMovable(true)
ShadowRotationFrame:EnableMouse(true)
ShadowRotationFrame:RegisterForDrag("LeftButton")
ShadowRotationFrame:SetScript("OnDragStart", function() ShadowRotationFrame:StartMoving() end)
ShadowRotationFrame:SetScript("OnDragStop", function() ShadowRotationFrame:StopMovingOrSizing() end)

local ShadowRotationBackground = ShadowRotationFrame:CreateTexture(nil, "BACKGROUND")
ShadowRotationBackground:SetAllPoints()
ShadowRotationBackground:SetTexture(0, 0, 0, 0.4)
ShadowRotationBackground:SetWidth(130)
ShadowRotationBackground:SetHeight(90)

for i=1,3 do
	if i < 3 then
		local spellFrame = CreateFrame("Frame", nil, ShadowRotationFrame)
		spellFrame:SetPoint("TOPLEFT", 0, 45-i*45)
		spellFrame:SetWidth(45)
		spellFrame:SetHeight(45)
		local spellTexture = spellFrame:CreateTexture(nil)
		spellTexture:SetTexCoord(0.06, 0.94, 0.06, 0.94)
		spellTexture:SetAllPoints()
		local spellCooldown = CreateFrame("Cooldown", "ShadowRotationCooldown"..i, spellFrame, "CooldownFrameTemplate")
		spellCooldown:SetAllPoints()
		local spellCooldownFrame = CreateFrame("Frame")
		spellCooldownFrame:SetFrameLevel(4)
		local spellCooldownFont = spellCooldownFrame:CreateFontString("ShadowRotationCooldownFont"..i, "ARTWORK", "GameFontNormal")
		spellCooldownFont:SetPoint("CENTER", spellFrame)
		spellCooldownFont:SetFont("Fonts\\FRIZQT__.TTF", 16, "THICKOUTLINE")
		spellCooldownFont:SetTextColor(1, 0, 0)
		spellCooldownFont:SetText("")

		if i == 1 then
			spellTexture:SetTexture("Interface\\Icons\\Spell_Shadow_UnholyFrenzy")
		else
			spellTexture:SetTexture("Interface\\Icons\\Spell_Shadow_DemonicFortitude")
		end
	end

	local dotTexture = ShadowRotationFrame:CreateTexture(nil)
	dotTexture:SetPoint("TOPLEFT", 45, -90+i*30)
	dotTexture:SetWidth(30)
	dotTexture:SetHeight(30)
	dotTexture:SetTexCoord(0.06, 0.94, 0.06, 0.94)

	local statusBar = CreateFrame("StatusBar", "ShadowRotationBar"..i, ShadowRotationFrame)
	statusBar:SetPoint("TOPLEFT", 75, -90+i*30)
	statusBar:SetStatusBarTexture("Interface\\AddOns\\ShadowRotation\\UI-StatusBar")
	statusBar:SetOrientation("HORIZONTAL")
	statusBar:SetWidth(100)
	statusBar:SetHeight(30)
	statusBar:SetMinMaxValues(0, 1)
	statusBar:SetValue(1)
	statusBar:SetFrameLevel(1)
	statusBar:SetValue(0)

	local spark = ShadowRotationBar1:CreateTexture("ShadowRotationSpark"..i, "OVERLAY") -- sparks to display mind flay ticks
	spark:SetPoint("LEFT", -37+i*33, 0)
	spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	spark:SetWidth(10)
	spark:SetHeight(40)
	spark:SetBlendMode("ADD")
	spark:Hide()

	if i == 1 then
		dotTexture:SetTexture("Interface\\Icons\\Spell_Shadow_SiphonMana")
		statusBar:SetStatusBarColor(0, 0.5, 1)
	elseif i == 2 then
		dotTexture:SetTexture("Interface\\Icons\\Spell_Shadow_ShadowWordPain")
		statusBar:SetStatusBarColor(1, 0.55, 0)
	else
		dotTexture:SetTexture("Interface\\Icons\\Spell_Holy_Stoicism")
		statusBar:SetStatusBarColor(0.54, 0.18, 0.89)
	end
end

local shadowRotationCheck = {}
local shadowRotationSpells = {"Mind Flay", "Shadow Word: Pain", "Vampiric Touch", "Mind Blast", "Shadow Word: Death"}
local ShadowUpdateFrame = CreateFrame("Frame")
ShadowUpdateFrame:SetScript("OnUpdate", function(self, elapsed)
	for k=1,2 do -- cooldowns
		local shadowRotationSpell = shadowRotationSpells[3+k]
		if GetSpellCooldown(shadowRotationSpell) ~= GetSpellCooldown("Inner Fire") or _G["ShadowRotationCooldownFont"..k]:GetText() ~= "" then
			local start, dur = GetSpellCooldown(shadowRotationSpell)
			_G["ShadowRotationCooldown"..k]:SetCooldown(start, dur)
			if dur > 2 then
				_G["ShadowRotationCooldownFont"..k]:SetText(start + dur - GetTime() - ((start + dur - GetTime()) % 0.1))
				shadowRotationCheck[3+k] = 1
			elseif shadowRotationCheck[3+k] == 1 then
				_G["ShadowRotationCooldownFont"..k]:SetText("")
				shadowRotationCheck[3+k] = 0
			end
		end
	end

	if UnitExists("target") then -- dots
		for k=1,3 do -- resets the check value for spells 1-3
			shadowRotationCheck[k] = 0
		end
		for i=1,40 do
			if select(1, UnitDebuff("target", i)) ~= nil then
				local spellName, _, _, _, _, spellDur, spellTimer = UnitDebuff("target", i)
				for k=1,3 do -- checks if spells 1-3 from shadowRotationSpells are on target's debuffs
					if spellName == shadowRotationSpells[k] and (k ~= 1 or k == 1 and spellTimer ~= nil) then
						_G["ShadowRotationBar"..k]:SetValue(spellTimer/spellDur)
						shadowRotationCheck[k] = 1
						if k == 1 and not ShadowRotationSpark1:IsShown() then
							ShadowRotationSpark1:Show()
							ShadowRotationSpark2:Show()
							ShadowRotationSpark3:Show()
						end
					end
				end
			else -- hides spells which were not found
				for k=1,3 do
					if shadowRotationCheck[k] == 0 and _G["ShadowRotationBar"..k]:GetValue() ~= 0 then
						_G["ShadowRotationBar"..k]:SetValue(0)
						if k == 1 and ShadowRotationSpark1:IsShown() then
							ShadowRotationSpark1:Hide()
							ShadowRotationSpark2:Hide()
							ShadowRotationSpark3:Hide()
						end
					end
				end
				break
			end
		end
	else -- hides spells if no target is found
		for k=1,3 do
			_G["ShadowRotationBar"..k]:SetValue(0)
			if _G["ShadowRotationSpark"..k]:IsShown() then
				_G["ShadowRotationSpark"..k]:Hide()
			end
		end
	end
end)