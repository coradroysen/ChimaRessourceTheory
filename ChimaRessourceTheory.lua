local currentMana

local tickTimer = 0

local fiveSecondsActive = false
local fiveSecondsTimer = 0

local function ChimaRessourceTheory_UpdateValues(self, elapsed)
  -- regen tick
  if UnitPower("player", 0) < UnitPowerMax("player", 0) then
    tickTimer = tickTimer + elapsed

    local tickPercent = PlayerFrameManaBar:GetWidth() * (tickTimer/2)
    if tickPercent > PlayerFrameManaBar:GetWidth() then tickPercent = PlayerFrameManaBar:GetWidth() end
    tickSpark:SetPoint("CENTER", PlayerFrameManaBar, "LEFT", tickPercent, 0)
    ChimaRessourceTheory_ActiveSpark("tickSpark")

    if UnitPower("player", 0) ~= currentMana then
      tickTimer = 0
      currentMana = UnitPower("player", 0)
    end
  else
    ChimaRessourceTheory_DeactiveSpark("tickSpark")
  end

  -- five second rule
  if fiveSecondsActive then
    fiveSecondsTimer = fiveSecondsTimer + elapsed

    local fiveSecondsPercent = PlayerFrameManaBar:GetWidth() * (fiveSecondsTimer/5)
    if fiveSecondsPercent > PlayerFrameManaBar:GetWidth() then fiveSecondsPercent = PlayerFrameManaBar:GetWidth() end
    fiveSecondsSpark:SetPoint("CENTER", PlayerFrameManaBar, "LEFT", fiveSecondsPercent, 0)

    PlayerFrameManaBar:SetStatusBarColor(0.4, 0.5, 0.8)

    if fiveSecondsTimer >= 5 then
      PlayerFrameManaBar:SetStatusBarColor(0, 0, 1)
      fiveSecondsActive = false
      fiveSecondsTimer = 0

      ChimaRessourceTheory_DeactiveSpark("fiveSecondsSpark", "PlayerFrameManaBar")
    end
  end
end



function ChimaRessourceTheory_CreateElements()
  PlayerFrameManaBar:CreateTexture("fiveSecondsSpark", "ARTWORK")
  fiveSecondsSpark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
  fiveSecondsSpark:SetWidth(16)
  fiveSecondsSpark:SetHeight(PlayerFrameManaBar:GetHeight() + 10)
  fiveSecondsSpark:SetVertexColor(1, 1, 1)
  fiveSecondsSpark:SetBlendMode("ADD")

  ChimaRessourceTheory_DeactiveSpark("fiveSecondsSpark", "PlayerFrameManaBar")


  PlayerFrameManaBar:CreateTexture("tickSpark", "ARTWORK")
  tickSpark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
  tickSpark:SetWidth(10)
  tickSpark:SetHeight(PlayerFrameManaBar:GetHeight() + 10)
  tickSpark:SetVertexColor(0.35, 0.35, 0.35)
  tickSpark:SetBlendMode("ADD")

  ChimaRessourceTheory_DeactiveSpark("tickSpark", "PlayerFrameManaBar")
end



function ChimaRessourceTheory_OnLoad(self, event, ...)
  self:RegisterEvent("ADDON_LOADED")
end

function ChimaRessourceTheory_OnEvent(self, event, ...)
   if event == "ADDON_LOADED" and ... == "ChimaRessourceTheory" then
      self:UnregisterEvent("ADDON_LOADED")

      self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")
      self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

      currentMana = UnitPower("player", 0)
      maxMana = UnitPowerMax("player", 0)

      ChimaRessourceTheory_CreateElements()

  	  ressourceFrame:SetScript("OnUpdate", ChimaRessourceTheory_UpdateValues)
	end

  if event == "CURRENT_SPELL_CAST_CHANGED"  then
    currentMana = UnitPower("player", 0)
  end

  if event == "UNIT_SPELLCAST_SUCCEEDED" then
    if UnitPower("player", 0) < currentMana then
      ChimaRessourceTheory_ActiveSpark("fiveSecondsSpark")
      fiveSecondsActive = true
      fiveSecondsTimer = 0
    end
  end
end



function ChimaRessourceTheory_ActiveSpark(sparkName)
  _G[sparkName]:Show()
end

function ChimaRessourceTheory_DeactiveSpark(sparkName, parentBar)
  _G[sparkName]:SetPoint("CENTER", _G[parentBar], "LEFT")
  _G[sparkName]:Hide()
end
