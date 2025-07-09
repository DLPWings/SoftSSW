-- ############################################################################# 
-- # DC-24 Demos 
-- #
-- # Copyright (c) 2016, JETI model s.r.o.
-- # All rights reserved.
-- #
-- # Redistribution and use in source and binary forms, with or without
-- # modification, are permitted provided that the following conditions are met:
-- # 
-- # 1. Redistributions of source code must retain the above copyright notice, this
-- #    list of conditions and the following disclaimer.
-- # 2. Redistributions in binary form must reproduce the above copyright notice,
-- #    this list of conditions and the following disclaimer in the documentation
-- #    and/or other materials provided with the distribution.
-- # 
-- # THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- # ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- # WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- # DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
-- # ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- # (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- # LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- # ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- # (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- # SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- # 
-- # The views and conclusions contained in the software and documentation are those
-- # of the authors and should not be interpreted as representing official policies,
-- # either expressed or implied, of the FreeBSD Project.                    
-- #                       
-- # V1.0 - Initial release
-- #############################################################################

local appName="Soft Safety-SW" 
local ctrlIdx

local switch
local currentValue
local outOfSync = false

local fnName = "Soft Safety Switch"
local fnDesc = "by DLPWings"

local onMsg
local offMsg


-- Form initialization

local function switchChanged(value)
    switch=value
    system.pSave("switch",value)
    currentValue = system.getInputsVal(value)
end

local function onChanged(value)
    onMsg = value
    system.pSave("onMsg",value)
end
local function offChanged(value)
    offMsg = value
    system.pSave("offMsg",value)
end

local function initForm()
    form.addRow(2)
    form.addLabel({label="Selected Switch"})
    form.addInputbox(switch, false, switchChanged) 
    form.addRow(2)
    form.addLabel({label="Switch On:"})
    form.addTextbox(onMsg,20,onChanged)
    form.addRow(2)
    form.addLabel({label="Switch Off:"})
    form.addTextbox(offMsg,20,offChanged)

    form.addRow(1) form.addLabel({label="", font=FONT_MINI})
    form.addRow(1)
    form.addLabel({label="Software alternative to mechanical safety switch, similar", font=FONT_MINI})
    form.addRow(1)
    form.addLabel({label="to RC Switch. If you don't confirm YES with [F5] function", font=FONT_MINI})
    form.addRow(1)
    form.addLabel({label="status remains unchanged.", font=FONT_MINI})
    form.addRow(1) form.addLabel({label="", font=FONT_MINI})
    form.addRow(1)
    form.addLabel({label="Turbine trim up/down example of usage:", font=FONT_MINI})

    form.addRow(1)
    form.addLabel({label="- Remove any previous Throttle Trim settings", font=FONT_MINI})
    form.addRow(1)
    form.addLabel({label="- Assign Throttle-Idle SW to 'User Applications/SSW'", font=FONT_MINI})
    form.addRow(1)
    form.addLabel({label="  and offset value to 20% in: 'Menu > Advanced -", font=FONT_MINI})
    form.addRow(1)
    form.addLabel({label="  Properties > Other Model Options'", font=FONT_MINI})

    form.addRow(1)
    form.addLabel({label="- Run your turbine 'RC-Learning/Radio Setup' again.", font=FONT_MINI})
    collectgarbage()

end


local function printForm()

end
--------------------------------------------------------------------
-- Loop function
local function loop()   
  local val = system.getInputsVal(switch)
  local res = 0 
  
  if(currentValue ~= val) then
        
        if(outOfSync == false) then
            --local res = form.question("Enable function?", "Function will be enabled", "Description of the function", 3000,false,0)
            if(val == 1) then 
                system.playBeep (1, 4000, 100)                
                res = form.question(onMsg, fnName, fnDesc, 3000, false, 0) 

            else 
                system.playBeep (1, 4000, 100)
                res = form.question(offMsg, fnName, fnDesc, 3000, false, 0) 

            end
            if(res == 1) then
                if(ctrlIdx) then
                    system.setControl(1, val ,0,0)
                end
                outOfSync = false
                currentValue = val
            else
                outOfSync = true
            end  
        end
  else
        outOfSync = false
  end
    
    collectgarbage()

end
 
--------------------------------------------------------------------
-- Init function
local function init() 
    system.registerForm(1,MENU_ADVANCED,"Soft Safety Switch",initForm, nil,nil) 
    lastTimeChecked = system.getTimeCounter() 
    ctrlIdx = system.registerControl(1, "Soft Safety-SW","SSW")
    switch = system.pLoad("switch")
    currentValue = system.getInputsVal(switch)
    onMsg = system.pLoad("onMsg", "Turbine Trim Up?")
    offMsg = system.pLoad("offMsg", "Turbine Trim Down?")

    collectgarbage()
end

--------------------------------------------------------------------

return { init=init, loop=loop, author="JETI model", version="1.00",name=appName}
