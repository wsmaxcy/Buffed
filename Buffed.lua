-- Buffed Addon by You
-- No saved variables; user inputs height/weight each session.

local ADDON_NAME = "Buffed"

-- Print a message when the addon is loaded
DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFF[Buffed] |cFFFFFFFFLoaded|r", 0, 1, 1)

local hourBurn = 0
local minutes = 0
local lastRestingEnd = nil
local BuffedFrame
local lastDurationSinceLastRest = 0


local CALORIES_PUSHUP = 0.3
local CALORIES_SITUP = 0.4
local CALORIES_PLANK_SECOND = 0.12
local CALORIES_PISTOLSQUAT = 2
local CALORIES_PULLUP = 1

local pushups = 0
local situps = 0
local planks = 0
local pistolsquats = 0
local pullups = 0


-- Update resting alert text
function UpdateBuffedRestingAlertText()
    local textFormat = 
        "|cFF00FFFF[Buffed]|r\n" ..
        "|cFFFFFFFF--- Workout Results ---|r\n\n" ..
        "|cffff0000• Push-Ups:|r %d\n" ..
        "|cffff0000• Pull-Ups:|r %d\n" ..
        "|cffff0000• Sit-Ups:|r %d\n" ..
        "|cffff0000• Pistol Squats:|r %d\n" ..
        "|cffff0000• Planking (sec):|r %d"
        
    StaticPopupDialogs["BUFFED_RESTING_ALERT"].text = string.format(textFormat, pushups, pullups, situps, pistolsquats, planks)
end


StaticPopupDialogs["BUFFED_RESTING_ALERT"] = {
    text = "",
    button1 = "I Did It!",
    button2 = "I Didn't Do It...",
    -- On "I Did It!"
    OnAccept = function()
        accumulatingTime = false
        lastRestingEnd = GetTime()
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFF[Buffed]|r Great job! Keep it up!")
    end
,
    OnCancel = function()
        -- User didn't do it, show the next popup to decide what to do.
        StaticPopup_Show("I_DIDNT_DO_IT")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["I_DIDNT_DO_IT"] = {
    text = "Do you want to keep the timer going for next time and accumulate the workout?",
    button1 = "Yes!",
    button2 = "I'm Lazy",
    OnAccept = function()
        accumulatingTime = true
        DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFF00FFFF[Buffed] |cFFFFFFFFStill %d seconds since last rested|r", lastDurationSinceLastRest))
        -- Do NOT reset lastRestingEnd here. Just leave it as is.
    end,
    OnCancel = function()
        accumulatingTime = false
        SendChatMessage("Hey everybody, I'm a big LAZY BONES!", "YELL")
        lastRestingEnd = GetTime()
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFF[Buffed] |cFFFFFFFFNo worries! You can do it next time!|r")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}


-- Event handling frame for resting
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_UPDATE_RESTING")
eventFrame:SetScript("OnEvent", function(self, event)
    if IsResting() == 1 then
        if lastRestingEnd then
            local durationSinceLastRest = GetTime() - lastRestingEnd
            lastDurationSinceLastRest = durationSinceLastRest

            local secondsInHour = 3600
            local toBurn = floor(durationSinceLastRest / secondsInHour * hourBurn)
            local share = toBurn / 5

            pushups = math.floor(share / CALORIES_PUSHUP)
            situps = math.floor(share / CALORIES_SITUP)
            planks = math.floor(share / CALORIES_PLANK_SECOND)
            pistolsquats = math.floor(share / CALORIES_PISTOLSQUAT)
            pullups = math.floor(share / CALORIES_PULLUP)

        end
        -- Before showing the popup, check if all values are zero
        if (pushups == 0 and pullups == 0 and situps == 0 and pistolsquats == 0 and planks == 0) then
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFF[Buffed] |cFFFFFFFFType '/buffed' to begin your exercise tracking!|r")
            return
        else
            -- Not all zero, update and show the popup
            UpdateBuffedRestingAlertText()
            StaticPopup_Show("BUFFED_RESTING_ALERT")
        end
        
    else
            -- Leaving rested area
        if not accumulatingTime then
            -- If not accumulating, reset the timer start point
            lastRestingEnd = GetTime()
        end
        -- If we are accumulatingTime = true, do not touch lastRestingEnd.
        -- It remains pointing to the original time we started accumulating.
    end
end)

local function PerformCalculation(heightBox, weightBox, maleCheckbox, femaleCheckbox, calBox)
    local weight = tonumber(weightBox:GetText())
    local height = tonumber(heightBox:GetText())
    if weight and height then
        local isMale = maleCheckbox:GetChecked()
        local isFemale = femaleCheckbox:GetChecked()

        if not isMale and not isFemale then
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFF[Buffed] |cFFFFFFFFPlease select a gender.|r")
            return
        end

        -- Calculate BMR and hourBurn
        local BMR
        if isMale then
            BMR = 88.362 + (13.397 * (weight * 0.453592)) + (4.799 * (height * 2.54))
        else
            BMR = 447.593 + (9.247 * (weight * 0.453592)) + (3.098 * (height * 2.54))
        end
        hourBurn = math.floor(BMR/24)
        calBox:SetText(tostring(hourBurn))
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFF[Buffed] |cFFFFFFFFPlease enter valid weight and height.|r")
    end
end

local function CreateBuffedFrame()

    if not BuffedFrame then
        BuffedFrame = CreateFrame("Frame", "BuffedMainFrame", UIParent)
        BuffedFrame:SetWidth(250)
        BuffedFrame:SetHeight(250)
        BuffedFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

        table.insert(UISpecialFrames, "BuffedMainFrame") -- ESC closes the frame
        BuffedFrame:EnableKeyboard(true) -- Allow key input on the main frame

        BuffedFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })

        local titleFrame = CreateFrame("Frame", nil, BuffedFrame)
        titleFrame:SetPoint("TOP", BuffedFrame, "TOP", 0, 12)
        titleFrame:SetWidth(256)
        titleFrame:SetHeight(64)

        local titleTex = titleFrame:CreateTexture(nil, "MEDIUM")
        titleTex:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
        titleTex:SetAllPoints()

        local title = titleFrame:CreateFontString(nil, "HIGH", "GameFontNormal")
        title:SetText("Buffed Options")
        title:SetPoint("TOP", 0, -14)

        local detailTitle = BuffedFrame:CreateFontString(nil, "HIGH", "GameFontNormal")
        detailTitle:SetText("|cFFFFFFFFPhysical Details")
        detailTitle:SetPoint("TOPLEFT", 20, -30)

        -- Create a neat section frame
        local sectionFrame = CreateFrame("Frame", nil, BuffedFrame)
        sectionFrame:SetPoint("TOPLEFT", BuffedFrame, "TOPLEFT", 15, -45)
        sectionFrame:SetPoint("BOTTOMRIGHT", BuffedFrame, "BOTTOMRIGHT", -15, 70)
        sectionFrame:SetBackdrop({
          bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
          edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
          tile = true, tileSize = 8, edgeSize = 16,
          insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        sectionFrame:SetBackdropColor(.2,.2,.2,1)
        sectionFrame:SetBackdropBorderColor(.5,.5,.5,1)

        -- We'll organize the input fields in rows, each 30px apart vertically
        local yOffset = -15
        local xLabel = 10
        local xInput = 130

        -- Height
        local heightLabel = sectionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        heightLabel:SetText("Height (inches):")
        heightLabel:SetPoint("TOPLEFT", xLabel, yOffset)

        local heightBox = CreateFrame("EditBox", nil, sectionFrame)
        heightBox:SetPoint("TOPLEFT", xInput, yOffset)
        heightBox:SetWidth(70)
        heightBox:SetHeight(20)
        heightBox:SetFontObject(GameFontHighlightSmall)
        heightBox:SetAutoFocus(false)
        heightBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
        heightBox:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
            tile = true, tileSize = 16, edgeSize = 1,
            insets = { left = 3, right = 3, top = 2, bottom = 2 }
        })
        heightBox:SetBackdropColor(0, 0, 0, 0.5)
        heightBox:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
        heightBox:SetTextInsets(8, 8, 0, 0)
        heightBox:EnableKeyboard(true)

        -- Weight
        yOffset = yOffset - 30
        local weightLabel = sectionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        weightLabel:SetText("Weight (lbs):")
        weightLabel:SetPoint("TOPLEFT", xLabel, yOffset)

        local weightBox = CreateFrame("EditBox", nil, sectionFrame)
        weightBox:SetPoint("TOPLEFT", xInput, yOffset)
        weightBox:SetWidth(70)
        weightBox:SetHeight(20)
        weightBox:SetFontObject(GameFontHighlightSmall)
        weightBox:SetAutoFocus(false)
        weightBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
        weightBox:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
            tile = true, tileSize = 16, edgeSize = 1,
            insets = { left = 3, right = 3, top = 2, bottom = 2 }
        })
        weightBox:SetBackdropColor(0, 0, 0, 0.5)
        weightBox:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
        weightBox:SetTextInsets(8, 8, 0, 0)
        weightBox:EnableKeyboard(true)

        -- Sex
        yOffset = yOffset - 30
        local sexLabel = sectionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        sexLabel:SetText("Sex:")
        sexLabel:SetPoint("TOPLEFT", xLabel, yOffset)

        local maleCheckbox = CreateFrame("CheckButton", "MaleCheckbox", sectionFrame, "UICheckButtonTemplate")
        maleCheckbox:SetWidth(20)
        maleCheckbox:SetHeight(20)
        maleCheckbox:SetPoint("TOPLEFT", xInput - 60, yOffset)
        maleCheckbox.text = maleCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        maleCheckbox.text:SetText("Male")
        maleCheckbox.text:SetPoint("LEFT", maleCheckbox, "RIGHT", 2, 0)

        local femaleCheckbox = CreateFrame("CheckButton", "FemaleCheckbox", sectionFrame, "UICheckButtonTemplate")
        femaleCheckbox:SetWidth(20)
        femaleCheckbox:SetHeight(20)
        femaleCheckbox:SetPoint("LEFT", maleCheckbox.text, "RIGHT", 20, 0)
        femaleCheckbox.text = femaleCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        femaleCheckbox.text:SetText("Female")
        femaleCheckbox.text:SetPoint("LEFT", femaleCheckbox, "RIGHT", 2, 0)

        maleCheckbox:SetScript("OnClick", function()
            femaleCheckbox:SetChecked(not maleCheckbox:GetChecked())
        end)

        femaleCheckbox:SetScript("OnClick", function()
            maleCheckbox:SetChecked(not femaleCheckbox:GetChecked())
        end)



        -- Calories Per Hour
        yOffset = yOffset - 70
        local calLabel = sectionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        calLabel:SetText("Calories/Hour:")
        calLabel:SetPoint("TOPLEFT", xLabel, yOffset)

        local calBox = CreateFrame("EditBox", nil, sectionFrame)
        calBox:SetPoint("TOPLEFT", xInput, yOffset)
        calBox:SetWidth(70)
        calBox:SetHeight(20)
        calBox:SetFontObject(GameFontHighlightSmall)
        calBox:SetAutoFocus(false)
        calBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
        calBox:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
            tile = true, tileSize = 16, edgeSize = 1,
            insets = { left = 3, right = 3, top = 2, bottom = 2 }
        })
        calBox:SetBackdropColor(0, 0, 0, 0.5)
        calBox:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
        calBox:SetTextInsets(8, 8, 0, 0)
        calBox:EnableKeyboard(true)
        
        heightBox:SetScript("OnEscapePressed", function() BuffedFrame:Hide() end)
        weightBox:SetScript("OnEscapePressed", function() BuffedFrame:Hide() end)
        calBox:SetScript("OnEscapePressed", function() BuffedFrame:Hide() end)

        -- After creating heightBox, weightBox, calBox:
        -- Ensure no OnKeyDown scripts since we're not using them now
        heightBox:SetScript("OnKeyDown", nil)
        weightBox:SetScript("OnKeyDown", nil)
        calBox:SetScript("OnKeyDown", nil)
            
        -- Handle ESC to close
        heightBox:SetScript("OnEscapePressed", function() BuffedFrame:Hide() end)
        weightBox:SetScript("OnEscapePressed", function() BuffedFrame:Hide() end)
        calBox:SetScript("OnEscapePressed", function() BuffedFrame:Hide() end)

        -- Handle TAB and ESC in edit boxes
        local editBoxes = { heightBox, weightBox, calBox }

        local function MoveFocus(self, forward)
            -- forward: true if tabbing forward, false if tabbing backward (not implemented here)
            for i, box in ipairs(editBoxes) do
                if box == self then
                    local nextIndex = i + 1
                    if nextIndex > editBoxes then
                        nextIndex = 1
                    end
                    editBoxes[nextIndex]:SetFocus()
                    return
                end
            end
        end

        local function OnEditBoxKeyDown(self, key)
            if key == "TAB" then
                self:ClearFocus()
                MoveFocus(self, true)
            elseif key == "ESCAPE" then
                BuffedFrame:Hide()
            end
        end

        for _, box in ipairs(editBoxes) do
            box:SetScript("OnKeyDown", OnEditBoxKeyDown)
        end

        -- Calculate Button (placed below the fields)
        local CalculateButton = CreateFrame("Button", "BuffedCalculateButton", BuffedFrame, "UIPanelButtonTemplate")
        CalculateButton:SetText("Calculate")
        CalculateButton:SetWidth(90)
        CalculateButton:SetHeight(25)
        CalculateButton:SetPoint("TOP", BuffedFrame, "TOP", 0, yOffset)
        CalculateButton:SetScript("OnClick", function()
            PerformCalculation(heightBox, weightBox, maleCheckbox, femaleCheckbox, calBox)
        end)

        

        -- Okay and Cancel Buttons at the bottom
        local OkayButton = CreateFrame("Button", "BuffedOkayButton", BuffedFrame, "UIPanelButtonTemplate")
        OkayButton:SetText("Save")
        OkayButton:SetWidth(80)
        OkayButton:SetHeight(25)
        OkayButton:SetPoint("BOTTOMLEFT", 30, 10)
        OkayButton:SetScript("OnClick", function()
            BuffedFrame:Hide()
            local height = heightBox:GetText()
            local weight = weightBox:GetText()
            local isMale = maleCheckbox:GetChecked()
            local isFemale = femaleCheckbox:GetChecked()
            local sex = (isMale and "Male") or (isFemale and "Female") or "Not Selected"
            local hourBurnValue = calBox:GetText()

            BDB.height = height
            BDB.weight = weight
            BDB.sex = sex
            BDB.hourBurn = hourBurnValue
            
            
        
            DEFAULT_CHAT_FRAME:AddMessage(string.format(
                "|cFF00FFFF[Buffed]|r Values Saved: Height=%s inches, Weight=%s lbs, Sex=%s, Calories/Hour=%s",
                height, weight, sex, hourBurnValue
            ))
        
            lastRestingEnd = GetTime()
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFF[Buffed]|r Workout timer started!")
        end)
        

        local CancelButton = CreateFrame("Button", "BuffedCancelButton", BuffedFrame, "UIPanelButtonTemplate")
        CancelButton:SetText("Cancel")
        CancelButton:SetWidth(80)
        CancelButton:SetHeight(25)
        CancelButton:SetPoint("BOTTOMRIGHT", -30, 10)
        CancelButton:SetScript("OnClick", function()
            BuffedFrame:Hide()
        end)

        -- When showing the frame:
        BuffedFrame:SetScript("OnShow", function()
            PlaySound("igMainMenuOpen")
        end)

        -- When hiding the frame:
        BuffedFrame:SetScript("OnHide", function()
            PlaySound("igMainMenuClose")
        end)

        -- After heightBox, weightBox, calBox, maleCheckbox, femaleCheckbox are created:
        heightBox:SetText(BDB.height)
        weightBox:SetText(BDB.weight)
            
        if BDB.sex == "Male" then
            maleCheckbox:SetChecked(true)
            femaleCheckbox:SetChecked(false)
        elseif BDB.sex == "Female" then
            femaleCheckbox:SetChecked(true)
            maleCheckbox:SetChecked(false)
        else
            maleCheckbox:SetChecked(false)
            femaleCheckbox:SetChecked(false)
        end
        
        calBox:SetText(BDB.hourBurn)
        
        PerformCalculation(heightBox, weightBox, maleCheckbox, femaleCheckbox, calBox)


        BuffedFrame:Hide()
    else
        BuffedFrame:Show()
    end
end

--


-- A function that calculates hourBurn based on BDB values (no UI needed):
local function CalculateHourBurnFromDB()
    local weight = tonumber(BDB.weight)
    local height = tonumber(BDB.height)
    local sex = BDB.sex
    

    if not weight or not height or sex == "Not Selected" then
        -- Can't calculate properly if data is missing or invalid
        return
    end

    local BMR
    if sex == "Male" then
        BMR = 88.362 + (13.397 * (weight * 0.453592)) + (4.799 * (height * 2.54))
    elseif sex == "Female" then
        BMR = 447.593 + (9.247 * (weight * 0.453592)) + (3.098 * (height * 2.54))
    else
        return
    end

    local newHourBurn = math.floor(BMR/24)
    BDB.hourBurn = tostring(newHourBurn) -- Store as string if you prefer
    lastRestingEnd = GetTime()
end


local loadFrame = CreateFrame("Frame")
loadFrame:RegisterEvent("VARIABLES_LOADED")
loadFrame:SetScript("OnEvent", function()    
    if event == "VARIABLES_LOADED" then
        if BDB.height == nil then BDB.height = "0" end
        if BDB.weight == nil then BDB.weight = "0" end
        if BDB.sex == nil then BDB.sex = "Not Selected" end
        if BDB.hourBurn == nil then BDB.hourBurn = "0" end
        
        CalculateHourBurnFromDB()
    end
end)


--

-- Function to handle the "/buffed" command
local function BuffedMenuCommandHandler()
    CreateBuffedFrame()
end

-- Register the slash command
SLASH_BUFFED1 = "/buffed"
SlashCmdList["BUFFED"] = BuffedMenuCommandHandler
