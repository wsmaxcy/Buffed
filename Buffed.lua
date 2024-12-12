-- Buffed Addon by Clempton
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

local session_exercises = {
    s_pushups = 0,
    s_situps = 0,
    s_planks = 0,
    s_pistolsquats = 0,
    s_pullups = 0
}

local total_exercises = {
    t_pushups = 0,
    t_situps = 0,
    t_planks = 0,
    t_pistolsquats = 0,
    t_pullups = 0
}


local function CreateBuffedRestingAlertFrame()


    if BuffedRestingFrame == nil then
        -- Main Frame
        BuffedRestingFrame = CreateFrame("Frame", "BuffedRestingFrame", UIParent)
        BuffedRestingFrame:SetWidth(280)
        BuffedRestingFrame:SetHeight(235)
        BuffedRestingFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 400)    
        BuffedRestingFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        BuffedRestingFrame:SetBackdropColor(0, 0, 0, 0.8)
        BuffedRestingFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

        table.insert(UISpecialFrames, "BuffedRestingFrame") -- ESC closes the frame

        local detailTitle = BuffedRestingFrame:CreateFontString(nil, "HIGH", "GameFontNormal")
        detailTitle:SetText("|cFFFFFFFFWorkout Details")
        detailTitle:SetPoint("TOPLEFT", 20, -35)

        -- Header Frame with Texture
        local titleFrame = CreateFrame("Frame", nil, BuffedRestingFrame)
        titleFrame:SetPoint("TOP", BuffedRestingFrame, "TOP", 0, 12)
        titleFrame:SetWidth(256)
        titleFrame:SetHeight(64)

        local titleTex = titleFrame:CreateTexture(nil, "OVERLAY")
        titleTex:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
        titleTex:SetAllPoints()

        local title = titleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetText("|cFF00FFFF[Buffed]|r Workout")
        title:SetPoint("TOP", 0, -14)

        -- Section Frame for Exercises
        local sectionFrame = CreateFrame("Frame", nil, BuffedRestingFrame)
        sectionFrame:SetPoint("TOPLEFT", BuffedRestingFrame, "TOPLEFT", 15, -50)
        sectionFrame:SetPoint("BOTTOMRIGHT", BuffedRestingFrame, "BOTTOMRIGHT", -15, 50)
        sectionFrame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 8, edgeSize = 16,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        sectionFrame:SetBackdropColor(.2,.2,.2,1)
        sectionFrame:SetBackdropBorderColor(.5,.5,.5,1)

        -- Exercise List
        local exerciseTexts = {}
        local exercises = {
            { name = "Push-Ups:", key = "pushups" },
            { name = "Pull-Ups:", key = "pullups" },
            { name = "Sit-Ups:", key = "situps" },
            { name = "Pistol Squats:", key = "pistolsquats" },
            { name = "Planking (sec):", key = "planks" }
        }

        local xNameOffset = 10     -- X position for exercise names
        local xCountOffset = 115   -- X position for aligned numbers (adjust as needed)
        local xCount2Offset = 165  -- X position for aligned numbers (adjust as needed)
        local xCount3Offset = 215  -- X position for aligned numbers (adjust as needed)
        local yOffset = -30

        -- Create Exercise Titles and Count Texts
        local exerciseTitle = sectionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        exerciseTitle:SetText("Exercise")
        exerciseTitle:SetPoint("TOPLEFT", xNameOffset + 5, yOffset + 20)

        local countTitle = sectionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        countTitle:SetText("Now")
        countTitle:SetPoint("TOPLEFT", xCountOffset - 7, yOffset + 20)

        local countTitle2 = sectionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        countTitle2:SetText("Session")
        countTitle2:SetPoint("TOPLEFT", xCount2Offset - 17, yOffset + 20)

        local countTitle3 = sectionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        countTitle3:SetText("Total")
        countTitle3:SetPoint("TOPLEFT", xCount3Offset - 8, yOffset + 20)


        
        for _, exercise in ipairs(exercises) do
            -- Create FontString for the exercise name
            local nameText = sectionFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            nameText:SetPoint("TOPLEFT", xNameOffset, yOffset)
            nameText:SetText(string.format("|cffff0000• %s|r", exercise.name))
        
            -- "Now" Count FontString
            local countText = sectionFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            countText:SetPoint("TOPLEFT", xCountOffset, yOffset)
            countText:SetText("|cFFFFFFFF0|r")
        
            -- "Session" Count FontString
            local countText2 = sectionFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            countText2:SetPoint("TOPLEFT", xCount2Offset, yOffset)
            countText2:SetText(string.format("|cFFFFFFFF%d|r", session_exercises["s_" .. exercise.key] or 0))
        
            -- "Total" Count FontString
            local countText3 = sectionFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            countText3:SetPoint("TOPLEFT", xCount3Offset, yOffset)
            countText3:SetText(string.format("|cFFFFFFFF%d|r", total_exercises["t_" .. exercise.key] or 0))
        
            -- Store references in exerciseTexts
            exerciseTexts[exercise.key] = countText
        
            if not exerciseTexts.session then exerciseTexts.session = {} end
            if not exerciseTexts.total then exerciseTexts.total = {} end
        
            exerciseTexts.session[exercise.key] = countText2
            exerciseTexts.total[exercise.key] = countText3
        
            -- Move to the next line
            yOffset = yOffset - 20
        end
        

        -- Buttons: "I Did It!", "Skip", "Close"
        local button1 = CreateFrame("Button", "BuffedDidItButton", BuffedRestingFrame, "UIPanelButtonTemplate")
        button1:SetWidth(80)
        button1:SetHeight(24)
        button1:SetPoint("BOTTOMLEFT", 20, 15)
        button1:SetText("I Did It!")
        button1:SetScript("OnClick", function()
            accumulatingTime = false
            lastRestingEnd = GetTime()

            -- Add to session totals
            session_exercises.s_pushups = session_exercises.s_pushups + pushups
            session_exercises.s_situps = session_exercises.s_situps + situps
            session_exercises.s_planks = session_exercises.s_planks + planks
            session_exercises.s_pistolsquats = session_exercises.s_pistolsquats + pistolsquats
            session_exercises.s_pullups = session_exercises.s_pullups + pullups

            -- Add to total totals
            total_exercises.t_pushups = BuffDB.t_pushups + pushups
            total_exercises.t_situps = BuffDB.t_situps + situps
            total_exercises.t_planks = BuffDB.t_planks + planks
            total_exercises.t_pistolsquats = BuffDB.t_pistolsquats + pistolsquats
            total_exercises.t_pullups = BuffDB.t_pullups + pullups

            -- Update BuffDB totals
            BuffDB.t_pushups = BuffDB.t_pushups + pushups
            BuffDB.t_situps = BuffDB.t_situps + situps
            BuffDB.t_planks = BuffDB.t_planks + planks
            BuffDB.t_pistolsquats = BuffDB.t_pistolsquats + pistolsquats
            BuffDB.t_pullups = BuffDB.t_pullups + pullups

            
            -- Update the UI
            exerciseTexts.session["pushups"]:SetText(string.format("|cFFFFFFFF%d|r", session_exercises.s_pushups))
            exerciseTexts.session["situps"]:SetText(string.format("|cFFFFFFFF%d|r", session_exercises.s_situps))
            exerciseTexts.session["planks"]:SetText(string.format("|cFFFFFFFF%d|r", session_exercises.s_planks))
            exerciseTexts.session["pistolsquats"]:SetText(string.format("|cFFFFFFFF%d|r", session_exercises.s_pistolsquats))
            exerciseTexts.session["pullups"]:SetText(string.format("|cFFFFFFFF%d|r", session_exercises.s_pullups))

            exerciseTexts.total["pushups"]:SetText(string.format("|cFFFFFFFF%d|r", total_exercises.t_pushups))
            exerciseTexts.total["situps"]:SetText(string.format("|cFFFFFFFF%d|r", total_exercises.t_situps))
            exerciseTexts.total["planks"]:SetText(string.format("|cFFFFFFFF%d|r", total_exercises.t_planks))
            exerciseTexts.total["pistolsquats"]:SetText(string.format("|cFFFFFFFF%d|r", total_exercises.t_pistolsquats))
            exerciseTexts.total["pullups"]:SetText(string.format("|cFFFFFFFF%d|r", total_exercises.t_pullups))
            
            BuffedRestingFrame:UpdateResults()

            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFF[Buffed]|r Great job! Keep it up!")
            BuffedRestingFrame:Hide()
        end)

        local button2 = CreateFrame("Button", "BuffedSkipButton", BuffedRestingFrame, "UIPanelButtonTemplate")
        button2:SetWidth(80)
        button2:SetHeight(24)
        button2:SetPoint("BOTTOM", 0, 15)
        button2:SetText("I Will..")
        button2:SetScript("OnClick", function()
            accumulatingTime = true
            DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFF00FFFF[Buffed] |cFFFFFFFFStill %d seconds since last rested|r", lastDurationSinceLastRest))
            BuffedRestingFrame:Hide()
        end)

        local closeButton  = CreateFrame("Button", nil, BuffedRestingFrame, "UIPanelButtonTemplate")
        closeButton:SetWidth(80)
        closeButton:SetHeight(24)
        closeButton:SetPoint("BOTTOMRIGHT", -20, 15)
        closeButton:SetText("I Won't")
        closeButton:SetScript("OnClick", function()
            accumulatingTime = false
            lastRestingEnd = GetTime()
            SendChatMessage("Hey everybody, I'm a big LAZY BONES!", "YELL")
            BuffedRestingFrame:Hide()
        end)

        -- Function to Update Exercise Results
        BuffedRestingFrame.UpdateResults = function()
            exerciseTexts["pushups"]:SetText(string.format("|cFFFFFFFF%d|r", pushups))
            exerciseTexts["pullups"]:SetText(string.format("|cFFFFFFFF%d|r", pullups))
            exerciseTexts["situps"]:SetText(string.format("|cFFFFFFFF%d|r", situps))
            exerciseTexts["pistolsquats"]:SetText(string.format("|cFFFFFFFF%d|r", pistolsquats))
            exerciseTexts["planks"]:SetText(string.format("|cFFFFFFFF%d|r", planks))
        end
    end

    -- Ensure UpdateResults is called and the frame is shown
    BuffedRestingFrame:UpdateResults()
    BuffedRestingFrame:Show()
end

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
            CreateBuffedRestingAlertFrame()

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
        title:SetText("|cFF00FFFF[Buffed]|r Options")
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
                print("Fart")
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

            BuffDB.height = height
            BuffDB.weight = weight
            BuffDB.sex = sex
            BuffDB.hourBurn = hourBurnValue
            
            
        
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
        heightBox:SetText(BuffDB.height)
        weightBox:SetText(BuffDB.weight)
            
        if BuffDB.sex == "Male" then
            maleCheckbox:SetChecked(true)
            femaleCheckbox:SetChecked(false)
        elseif BuffDB.sex == "Female" then
            femaleCheckbox:SetChecked(true)
            maleCheckbox:SetChecked(false)
        else
            maleCheckbox:SetChecked(false)
            femaleCheckbox:SetChecked(false)
        end
        
        calBox:SetText(BuffDB.hourBurn)
        
        PerformCalculation(heightBox, weightBox, maleCheckbox, femaleCheckbox, calBox)


        BuffedFrame:Hide()
    else
        BuffedFrame:Show()
    end
end

--


-- A function that calculates hourBurn based on BuffDB values (no UI needed):
local function CalculateHourBurnFromDB()
    local weight = tonumber(BuffDB.weight)
    local height = tonumber(BuffDB.height)
    local sex = BuffDB.sex
    

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
    BuffDB.hourBurn = tostring(newHourBurn) -- Store as string if you prefer
    lastRestingEnd = GetTime()
end


local loadFrame = CreateFrame("Frame")
loadFrame:RegisterEvent("VARIABLES_LOADED")
loadFrame:SetScript("OnEvent", function()    
    if event == "VARIABLES_LOADED" then
        if BuffDB.height == nil then BuffDB.height = "0" end
        if BuffDB.weight == nil then BuffDB.weight = "0" end
        if BuffDB.sex == nil then BuffDB.sex = "Male" end
        if BuffDB.hourBurn == nil then BuffDB.hourBurn = "0" end
        if BuffDB.t_pushups == nil then BuffDB.t_pushups = "0" end
        if BuffDB.t_situps == nil then BuffDB.t_situps = "0" end
        if BuffDB.t_planks == nil then BuffDB.t_planks = "0" end
        if BuffDB.t_pistolsquats == nil then BuffDB.t_pistolsquats = "0" end
        if BuffDB.t_pullups == nil then BuffDB.t_pullups = "0" end

        
        CalculateHourBurnFromDB()
    end
end)

if not BuffDB then
    BuffDB = {}
end


-- Function to handle the "/buffed" command
local function BuffedMenuCommandHandler(msg)
    if msg and string.lower(msg) == "clear" then
        -- Reset BuffDB total values
        BuffDB.t_pushups = 0
        BuffDB.t_pullups = 0
        BuffDB.t_situps = 0
        BuffDB.t_pistolsquats = 0
        BuffDB.t_planks = 0
        
        -- Reset local total variables (optional)
        total_exercises.t_pushups = 0
        total_exercises.t_pullups = 0
        total_exercises.t_situps = 0
        total_exercises.t_pistolsquats = 0
        total_exercises.t_planks = 0

        -- Reset session variables as well
        session_exercises.s_pushups = 0
        session_exercises.s_pullups = 0
        session_exercises.s_situps = 0
        session_exercises.s_pistolsquats = 0
        session_exercises.s_planks = 0

        -- Print confirmation
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFF[Buffed]|r Total and session counts reset to 0!")

    else
        -- Open the Buffed options frame
        CreateBuffedFrame()
    end
end

-- Register the slash command
SLASH_BUFFED1 = "/buffed"
SlashCmdList["BUFFED"] = BuffedMenuCommandHandler
