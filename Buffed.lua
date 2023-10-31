-- Print a message when the addon is loaded
local function OnAddonLoaded()
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFF[Buffed] |cFFFFFFFFLoaded|r", 0, 1, 1)
    SlashCmdList["BUFFED"] = BuffedMenuCommandHandler
    SLASH_BUFFED1 = "/buffed"
end

OnAddonLoaded()

local hourBurn = 0
local minutes = 0
local lastRestingEnd = nil
local BuffedFrame

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


-- Function to create the Buffed frame
local function CreateBuffedFrame()
    if not BuffedFrame then
        hideOnEscape = true
        -- Create the main frame
        BuffedFrame = CreateFrame("Frame", "BuffedMainFrame", UIParent)
        BuffedFrame:SetWidth(225)
        BuffedFrame:SetHeight(200)
        BuffedFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        BuffedFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
  
         -- Create a title frame and text
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

        -- Function to calculate modulo
        local function Modulo(a, b)
            return a - math.floor(a / b) * b
        end

        -- Create a title for the input fields
        local detailTitle = BuffedFrame:CreateFontString(nil, "HIGH", "GameFontNormal")
        detailTitle:SetText("|cFFFFFFFFPhysical Details")
        detailTitle:SetPoint("TOPLEFT", 20, -30)

        -- Height Label
        local heightLabel = BuffedFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        heightLabel:SetText("Height (in inches):")
        heightLabel:SetPoint("TOPLEFT", 20, -55)

        -- Height EditBox
        local heightBox = CreateFrame("EditBox", nil, BuffedFrame)
        heightBox:SetPoint("LEFT", heightLabel, "RIGHT", 10, 0)
        heightBox:SetWidth(50)
        heightBox:SetHeight(20)
        heightBox:SetFontObject(GameFontHighlightSmall)
        heightBox:SetTextInsets(0, 0, 0, 0) -- Adds some padding
        heightBox:SetAutoFocus(false) -- Avoids automatically taking focus
        heightBox:SetScript("OnEnterPressed", function(self)
            self:ClearFocus() -- Removes focus when Enter key is pressed
        end)
        heightBox:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
            tile = true, tileSize = 16, edgeSize = 1,
            insets = { left = 3, right = 3, top = 2, bottom = 2 }
        })
        heightBox:SetBackdropColor(0, 0, 0, 0.5)
        heightBox:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
        heightBox:SetTextInsets(8, 8, 0, 0)

        -- Weight Label
        local weightLabel = BuffedFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        weightLabel:SetText("Weight (in pounds):")
        weightLabel:SetPoint("TOPLEFT", heightLabel, "BOTTOMLEFT", 0, -10)

        -- Weight EditBox
        local weightBox = CreateFrame("EditBox", nil, BuffedFrame)
        weightBox:SetPoint("LEFT", weightLabel, "RIGHT", 10, 0)
        weightBox:SetWidth(50)
        weightBox:SetHeight(20)
        weightBox:SetFontObject(GameFontHighlightSmall)
        weightBox:SetTextInsets(8, 8, 8, 8) -- Adds some padding
        weightBox:SetAutoFocus(false) -- Avoids automatically taking focus
        weightBox:SetScript("OnEnterPressed", function(self)
            self:ClearFocus() -- Removes focus when Enter key is pressed
        end)

        -- Set the background and border to make it look like a typical WoW EditBox
        weightBox:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
            tile = true, tileSize = 16, edgeSize = 1,
            insets = { left = 3, right = 3, top = 2, bottom = 2 }
        })

        -- This line ensures that your frame can receive key presses.
        BuffedFrame:EnableKeyboard(true)

        BuffedFrame:SetScript("OnKeyDown", function(self, key)
            if key == "TOGGLEGAMEMENU" then
                self:Hide()  -- Hide the frame when the "Escape" key is pressed
            end
        end)

        weightBox:SetBackdropColor(0, 0, 0, 0.5)
        weightBox:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)

        -- Add a blinking cursor for a better visual indication while editing
        weightBox:SetTextInsets(8, 8, 0, 0)



        -- Sex Label
        local sexLabel = BuffedFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        sexLabel:SetText("Sex:")
        sexLabel:SetPoint("TOPLEFT", weightLabel, "BOTTOMLEFT", 0, -10)

        -- Sex "Radio" CheckButtons
        local maleCheckbox = CreateFrame("CheckButton", "MaleCheckbox", BuffedFrame, "UICheckButtonTemplate")
        maleCheckbox:SetWidth(20)
        maleCheckbox:SetHeight(20)
        maleCheckbox:SetPoint("LEFT", sexLabel, "RIGHT", 10, 0)
        maleCheckbox.text = maleCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        maleCheckbox.text:SetText("Male")
        maleCheckbox.text:SetPoint("LEFT", maleCheckbox, "RIGHT", 5, 0)
            
        local femaleCheckbox = CreateFrame("CheckButton", "FemaleCheckbox", BuffedFrame, "UICheckButtonTemplate")
        femaleCheckbox:SetWidth(20)
        femaleCheckbox:SetHeight(20)
        femaleCheckbox:SetPoint("LEFT", maleCheckbox, "Right", 40, 0)
        femaleCheckbox.text = femaleCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        femaleCheckbox.text:SetText("Female")
        femaleCheckbox.text:SetPoint("LEFT", femaleCheckbox, "RIGHT", 5, 0)
            
        -- Behavior to ensure only one checkbox is checked at a time
        maleCheckbox:SetScript("OnClick", function()
            femaleCheckbox:SetChecked(not maleCheckbox:GetChecked())
        end)
        
        femaleCheckbox:SetScript("OnClick", function()
            maleCheckbox:SetChecked(not femaleCheckbox:GetChecked())
        end)

        local selectedSex = maleCheckbox:GetChecked() and "Male" or (femaleCheckbox:GetChecked() and "Female" or nil)

        -- Calories Per Hour Label
        local calLabel = BuffedFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        calLabel:SetText("Calories Per Hour:")
        calLabel:SetPoint("TOPLEFT", sexLabel, "BOTTOMLEFT", 0, -10)

        -- Calories EditBox
        local calBox = CreateFrame("EditBox", nil, BuffedFrame)
        calBox:SetPoint("LEFT", calLabel, "RIGHT", 10, 0)
        calBox:SetWidth(50)
        calBox:SetHeight(20)
        calBox:SetFontObject(GameFontHighlightSmall)
        calBox:SetTextInsets(8, 8, 8, 8) -- Adds some padding
        calBox:SetAutoFocus(false) -- Avoids automatically taking focus
        calBox:SetScript("OnEnterPressed", function(self)
            self:ClearFocus() -- Removes focus when Enter key is pressed
        end)

        -- Set the background and border to make it look like a typical WoW EditBox
        calBox:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
            tile = true, tileSize = 16, edgeSize = 1,
            insets = { left = 3, right = 3, top = 2, bottom = 2 }
        })
        calBox:SetBackdropColor(0, 0, 0, 0.5)
        calBox:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)

        -- Add a blinking cursor for a better visual indication while editing
        calBox:SetTextInsets(8, 8, 0, 0)

        local CalculateButton = CreateFrame("Button", "BuffedCalculateButton", BuffedFrame, "UIPanelButtonTemplate")
        CalculateButton:SetText("Calculate")
        CalculateButton:SetWidth(90)
        CalculateButton:SetHeight(25)
        CalculateButton:SetPoint("TOPLEFT", calLabel, "BOTTOM", -7, -7)
        CalculateButton:SetScript("OnClick", function()
            local weight = tonumber(weightBox:GetText())
            local height = tonumber(heightBox:GetText())
            if weight and height then
                local isMale = maleCheckbox:GetChecked()
                local isFemale = femaleCheckbox:GetChecked()

                local BMR
                if isMale then
                    -- Convert weight to kg and height to cm for the formula
                    BMR = 88.362 + (13.397 * (weight * 0.453592)) + (4.799 * (height * 2.54))
                elseif isFemale then
                    BMR = 447.593 + (9.247 * (weight * 0.453592)) + (3.098 * (height * 2.54))
                else
                    -- If neither checkbox is checked, give a prompt and return
                    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFF[Buffed] |cFFFFFFFFPlease select a gender.|r")
                    return
                end
                hourBurn = math.floor(BMR/24)
                calBox:SetText(tostring(hourBurn))
            else
                DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFF[Buffed] |cFFFFFFFFPlease enter valid weight and height.|r")
            end
        end)


        -- Create an "Okay" button
        local OkayButton = CreateFrame("Button", "BuffedOkayButton", BuffedFrame, "UIPanelButtonTemplate")
        OkayButton:SetText("Save")
        OkayButton:SetWidth(80)
        OkayButton:SetHeight(25)
        OkayButton:SetPoint("BOTTOMLEFT", 30, 10)
        OkayButton:SetScript("OnClick", function()
            BuffedFrame:Hide()
            -- Handle the Okay button action (e.g., saving checkbox states)
        end)

        -- Create a "Cancel" button
        local CancelButton = CreateFrame("Button", "BuffedCancelButton", BuffedFrame, "UIPanelButtonTemplate")
        CancelButton:SetText("Cancel")
        CancelButton:SetWidth(80)
        CancelButton:SetHeight(25)
        CancelButton:SetPoint("BOTTOMRIGHT", -30, 10)
        CancelButton:SetScript("OnClick", function()
            BuffedFrame:Hide()
        end)

        BuffedFrame:Hide()

        -- Function to close the frame when "Escape" key is pressed
        BuffedFrame:SetScript("OnKeyDown", function(self, key)
            if key == "ESCAPE" then
                self:Hide()  -- Hide the frame when the "Escape" key is pressed
            end
        end)
    else
        BuffedFrame:Show()
    end
    BuffedFrame:RegisterEvent("PLAYER_UPDATE_RESTING")

    BuffedFrame:SetScript("OnEvent", function(self, event, ...)
        
        if IsResting() == 1 then
            if lastRestingEnd then
                local durationSinceLastRest = GetTime() - lastRestingEnd
                local secondsInHour = 3600
                local toBurn = floor(durationSinceLastRest / secondsInHour * hourBurn)
                local share = toBurn / 5

                pushups = math.floor(share / CALORIES_PUSHUP)
                situps = math.floor(share / CALORIES_SITUP)
                planks = math.floor(share / CALORIES_PLANK_SECOND)
                pistolsquats = math.floor(share / CALORIES_PISTOLSQUAT)
                pullups = math.floor(share / CALORIES_PULLUP)
                DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFF00FFFF[Buffed] |cFFFFFFFFIt has been %d seconds since you last rested. Need to burn %d calories.|r", durationSinceLastRest, toBurn))
            end
            UpdateBuffedRestingAlertText()
            StaticPopup_Show("BUFFED_RESTING_ALERT")
            lastRestingEnd = nil
        else
            lastRestingEnd = GetTime()
        end
        
    end)  
end

function UpdateBuffedRestingAlertText()
    StaticPopupDialogs["BUFFED_RESTING_ALERT"].text = string.format("\n|cFF00FFFF[Buffed] |cFFFFFFFFWorkout Results:\n\n|cffff0000[Push-Ups]|cFFFFFFFF: %d\n|cffff0000[Pull-Ups]|cFFFFFFFF: %d\n|cffff0000[Sit-Ups]|cFFFFFFFF: %d\n|cffff0000[Pistol Squats]|cFFFFFFFF: %d\n|cffff0000[Seconds Planking]|cFFFFFFFF: %d|r", pushups, pullups, situps, pistolsquats, planks)
end

StaticPopupDialogs["BUFFED_RESTING_ALERT"] = {
    text = "",
    button1 = "Okay",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,  -- this ensures a unique ID for this popup, change if conflicts
}

-- Function to handle the "/buffed menu" command
local function BuffedMenuCommandHandler()
    CreateBuffedFrame()
end

-- Register for the chat command
SLASH_BUFFED1 = "/buffed"
SlashCmdList["BUFFED"] = BuffedMenuCommandHandler
