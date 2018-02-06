
-- return window where fullUrl is to be opened
--
-- window 1 is default profile (me) 
-- window 2 is for mesos profile
--
function detangle(fullUrl)
    local defaultWindow = 1
    local urlWindowMapper = {
        ["aws.mesosphere.com"] = 2,
        ["github.com/mesosphere"] = 2,
        ["jira.mesosphere.com"] = 2,
        ["teamcity.mesosphere.io"] = 2,
        ["ccm.mesosphere.com"] = 2
      }

      for url, window in pairs(urlWindowMapper) do
        if string.find(fullUrl, url) ~= nil then
            return window
        end
      end

      return defaultWindow
end

hs.urlevent.httpCallback = function(scheme, host, params, fullUrl)

    --  tell application "System Events" to tell process "Google Chrome"
    --     set frontmost to true
    --     tell menu bar 1
    --      click menu item PROFILE of menu 1 of menu bar item "People"
    --      keystroke "t" using {command down}
    --      keystroke theURL
    --      key code 36
    --     end tell
    -- end tell

    local script = [[
        set theWINDOW to %d
        set theURL to "%s"

        if application "Google Chrome" is not running then
            error number -128
        end if

        tell application "Google Chrome"
            activate
            make new tab at end of window theWINDOW with properties {URL:theURL}
        end tell
    ]]

    local window = detangle(fullUrl)
    script = string.format(script, window, fullUrl)

    ok = hs.osascript.applescript(script)
    if not ok then
        hs.alert("Failed to open link.")
    end
end
